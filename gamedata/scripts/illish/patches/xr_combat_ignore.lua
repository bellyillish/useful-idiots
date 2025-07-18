local NPC = require "illish.lib.npc"


local PATCH  = {}
PATCH.CONFIG = {}


-- Overwrite with new implementation
function xr_combat_ignore.is_enemy(npc, enemy, noMemory)
  if device().precache_frame > 1 then
    return false
  end

  if not npc:alive() or not enemy:alive() then
    return false
  end

  if npc:clsid() == clsid.crow or enemy:clsid() == clsid.crow then
    return false
  end

  if DEV_DEBUG and xrs_debug_tools.debug_invis and enemy:id() == 0 then
    return false
  end

  -- callback override
  local flags = {
    override = false,
    result   = false
  }

  SendScriptCallback("on_enemy_eval", npc, enemy, flags)

  if flags.override then
    return flags.result
  end

  local pos1 = npc:position()
  local pos2 = enemy:position()
  local dist = pos2:distance_to(pos1)
  local fac1 = character_community(npc)
  local fac2 = character_community(enemy)
  local cfg  = PATCH.getCombatIgnoreConfig(enemy, npc)

  -- ignore bribes
  if enemy:id() == 0 and xr_bribe.at_peace(fac1, fac2, dist * dist) then
    return false
  end

  -- ignore stale enemies
  if IsStalker(npc) and not noMemory then
    -- time-based
    if enemy:id() == 0 and time_global() >  npc:memory_time(enemy) + cfg.memoryTime then
      return false
    end
    -- distance-based
    if dist > cfg.memoryDistance and not enemy:see(npc) then
      return false
    end
  end

  -- respect combat_ignore_keep_when_attacked
  if enemy:id() == 0 and load_var(npc, "xr_combat_ignore_enabled") == false then
    db.storage[npc:id()].enemy_id = enemy:id()
    return true
  end

  -- ignore hostages
  if axr_task_manager.hostages_by_id[enemy:id()] then
    return false
  end

  -- ignore enemies when npc has far surge job
  if xr_conditions.surge_started() and cfg.enemyRangeSurge then
    local smart = xr_gulag.get_npc_smart(npc)
    local task = smart
       and smart.npc_info
       and smart.npc_info[npc:id()]
       and smart.npc_info[npc:id()].job
       and smart.npc_info[npc:id()].job.job_type_id == 2
       and smart.npc_info[npc:id()].job.alife_task

    if task and pos2:distance_to(task:position()) > cfg.enemyRangeSurge then
      return false
    end
  end

  -- ignore enemies in safe zones
  if enemy:id() ~= 0 and IsStalker(npc) and fac2 ~= "zombied" then
    local safeTimes    = xr_combat_ignore.safe_zone_npcs
    local ignoredZones = xr_combat_ignore.ignored_zone

    local se = alife():object(npc:id())
    local id = se and se.group_id ~= 65535 and se.group_id or npc:id()

    if safeTimes[id] then
      db.storage[npc:id()].heli_enemy_flag = nil

      if time_global() - safeTimes[id] < cfg.safezoneExpires then
        return false
      else
        safeTimes[id] = nil
      end

    elseif id then
      for i, zone in ipairs(ignoredZones) do
        if utils_obj.npc_in_zone(npc, zone) then
          safeTimes[id] = time_global()
          return false
        end
      end
    end

    local squad = get_object_squad(enemy)
    id = squad and squad.id or enemy:id()

    if safeTimes[id] then
      return false
    else
      for i, zone in ipairs(ignoredZones) do
        if utils_obj.npc_in_zone(enemy, zone) then
          safeTimes[id] = time_global()
          return false
        end
      end
    end
  end

  -- ignore underground vs. above-ground fights
  if cfg.maxElevation
    and math.abs(pos1.y - pos2.y) > cfg.maxElevation
    and not npc:see(enemy)
    and not enemy:see(npc)
  then
    return false
  end

  -- ignore based on distance
  if cfg.enemyRange and dist > cfg.enemyRange then
    return false
  end

  -- save enemy before overriding
  if npc:relation(enemy) >= game_object.enemy then
    db.storage[npc:id()].enemy_id = enemy:id()
  end

  -- ignore based on overrides
  if xr_combat_ignore.ignore_enemy_by_overrides(npc, enemy) then
    return false
  end

  return true
end


-- Gather LTX settings
-- (Unused in vanilla so values in original xr_combat_ignore.ltx do nothing)
function PATCH.initCombatIgnoreConfig()
  local ini = ini_file("ai_tweaks\\xr_combat_ignore.ltx")

  PATCH.CONFIG = {
    enemyRange      = ini:r_string_to_condlist("settings", "enemy_range", "nil"),
    enemyRangeMin   = ini:r_string_to_condlist("settings", "enemy_range_min", "nil"),
    enemyRangeSurge = ini:r_string_to_condlist("settings", "enemy_range_surge", "nil"),
    maxElevation    = ini:r_string_to_condlist("settings", "max_elevation", "nil"),
    memoryTime      = ini:r_string_to_condlist("settings", "memory_time", "nil"),
    memoryDistance  = ini:r_string_to_condlist("settings", "memory_distance", "nil"),
    nightMultiplier = ini:r_string_to_condlist("night_settings", "multiplier", "1"),
    rainMultiplier  = ini:r_string_to_condlist("rain_settings", "multiplier", "1"),
    surgeMultiplier = ini:r_string_to_condlist("surge_settings", "multiplier", "1"),
    safezoneExpires = ini:r_float_ex("settings", "safezone_expires", 0),
    nightMinHour    = ini:r_float_ex("night_settings", "min_hour", 18),
    nightMaxHour    = ini:r_float_ex("night_settings", "max_hour", 21),
    rainMinFactor   = ini:r_float_ex("rain_settings", "min_factor", 0),
    rainMaxFactor   = ini:r_float_ex("rain_settings", "max_factor", 1),
  }
end


-- Update settings, parse condlists and calculate vision multipliers
function PATCH.getCombatIgnoreConfig(enemy, npc)
  local cfg = dup_table(PATCH.CONFIG)

  for k, v in pairs(cfg) do
    if type(v) == "table" then
      local value = xr_logic.pick_section_from_condlist(enemy, npc, v)
      cfg[k] = value and value ~= "nil" and tonumber(value) or nil
    end
  end

  cfg.nightMultiplier = PATCH.getNightMultiplier(cfg.nightMinHour, cfg.nightMaxHour, cfg.nightMultiplier)
  cfg.rainMultiplier  = PATCH.getRainMultiplier(cfg.rainMinFactor, cfg.rainMaxFactor, cfg.rainMultiplier)
  cfg.surgeMultiplier = PATCH.getSurgeMultiplier(cfg.surgeMultiplier)

  if cfg.enemyRange and cfg.enemyRangeMin then
    cfg.enemyRange = math.max(cfg.enemyRangeMin, cfg.enemyRange * cfg.nightMultiplier * cfg.rainMultiplier * cfg.surgeMultiplier)
  end

  return cfg
end


-- How much to adjust vision range for time of day
function PATCH.getNightMultiplier(hr1, hr2, multiplier)
  if hr1 > hr2 or multiplier < 0 or multiplier > 1 then
    return 1
  end

  local hour  = level.get_time_hours()
  local mins  = level.get_time_minutes()
  local diff1 = math.abs(hr1 - 12)
  local diff2 = math.abs(hr2 - 12)

  local modifier = hour + (mins / 60)
        modifier = math.abs(modifier - 12)
        modifier = math.min(math.max(modifier, diff1), diff2)
        modifier = 1 - (modifier - diff1) / (hr2 - hr1) * (1 - multiplier)

  return math.min(1, math.max(1 - multiplier, modifier))
end


-- How much to adjust vision range for rain
function PATCH.getRainMultiplier(low, high, multiplier)
  local rain = level.rain_factor()

  if low > high or multiplier < 0 or multiplier > 1 or rain < 0 then
    return 1
  end

  local modifier = 1 - (rain / (high - low) - low) * (1 - multiplier)
        modifier = math.min(modifier, 1)
        modifier = math.max(modifier, 1 - multiplier)

  return math.min(1, math.max(1 - multiplier, modifier))
end


-- How much to adjust vision range for surge
function PATCH.getSurgeMultiplier(multiplier)
  return xr_conditions.surge_started()
    and multiplier
    or  1
end


-- Replacement for "He is With Me"
function PATCH.onEvalEnemy(npc, enemy, flags)
  if NPC.isCompanion(npc) and NPC.isCompanion(enemy) then
    flags.override, flags.result = true, false

  elseif NPC.isCompanion(npc) and enemy:relation(db.actor) < game_object.enemy then
    flags.override, flags.result = true, false

  elseif NPC.isCompanion(enemy) and npc:relation(db.actor) < game_object.enemy then
    flags.override, flags.result = true, false
  end
end


-- Replace "He is With Me" callback if it exists
if he_is_with_me and he_is_with_me.escorteval then
  he_is_with_me.escorteval = PATCH.onEvalEnemy
end


RegisterScriptCallback("idiots_on_start", function()
  PATCH.initCombatIgnoreConfig()

  -- Add new callback if "He is With Me" doesn't exist
  if not (he_is_with_me and he_is_with_me.escorteval) then
    RegisterScriptCallback("on_enemy_eval", PATCH.onEvalEnemy)
  end
end)


return PATCH
