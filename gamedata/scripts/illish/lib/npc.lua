local UTIL  = require "illish.lib.util"
local TABLE = require "illish.lib.table"
local VEC   = require "illish.lib.vector"
local POS   = require "illish.lib.pos"
local WPN   = require "illish.lib.weapon"


local NPC = {}


-- Tracks looted/gathered items
NPC.LOOT_SHARED_ITEMS = {}
NPC.LOOT_SHARING_NPCS = {}


-- CONSTS --
  NPC.ACTIONS = {
    {
      name = "movement",
      cycle = true,
      actions = {
        {name = "follow", next = "wait", default = true},
        {name = "wait",   next = "cover",  info = "npcx_beh_wait", teleport = false},
        {name = "cover",  next = "relax",  info = "npcx_beh_hide_in_cover", teleport = false},
        {name = "relax",  next = "follow", info = "npcx_beh_substate_relax", teleport = false},
        {name = "patrol", info = "npcx_beh_patrol_mode", teleport = false},
      }
    },
    {
      name = "speed",
      toggle = true,
      actions = {
        {name = "hurry", info = "npcx_beh_hurry"},
      },
    },
    {
      name = "stance",
      cycle = true,
      actions = {
        {name = "stand", next = "sneak", default = true},
        {name = "sneak", next = "prone", info = "npcx_beh_substate_stealth"},
        {name = "prone", next = "stand", info = "npcx_beh_substate_prone"},
      },
    },
    {
      name = "distance",
      cycle = true,
      actions = {
        {name = "near",   next = "normal", info = "npcx_beh_distance_near"},
        {name = "normal", next = "far",    default = true},
        {name = "far",    next = "near",   info = "npcx_beh_distance_far"},
      },
    },
    {
      name = "combat",
      cycle = true,
      actions = {
        {name = "default",  next = "assault", default = true},
        {name = "assault",  next = "support", info = "npcx_beh_combat_tactics_assault"},
        {name = "support",  next = "guard",   info = "npcx_beh_combat_tactics_support"},
        {name = "guard",    next = "snipe",   info = "npcx_beh_combat_tactics_guard"},
        {name = "snipe",    next = "default", info = "npcx_beh_combat_tactics_snipe"},
        {name = "monolith", info = "npcx_beh_combat_tactics_monolith"},
        {name = "camper",   info = "npcx_beh_combat_tactics_camper"},
        {name = "zombied",  info = "npcx_beh_combat_tactics_zombied"},
      }
    },
    {
      name = "weapon",
      cycle = true,
      actions = {
        {name = "best",    next = "pistol",  default = true},
        {name = "pistol",  next = "shotgun", info = "npcx_beh_weapon_pistol"},
        {name = "shotgun", next = "rifle",   info = "npcx_beh_weapon_shotgun"},
        {name = "rifle",   next = "sniper",  info = "npcx_beh_weapon_rifle"},
        {name = "sniper",  next = "best",    info = "npcx_beh_weapon_sniper"},
      }
    },
    {
      name = "readiness",
      cycle = true,
      actions = {
        {name = "attack", next = "defend", default = true},
        {name = "defend", next = "ignore", info = "npcx_beh_ignore_actor_enemies"},
        {name = "ignore", next = "attack", info = "npcx_beh_ignore_combat"},
      },
    },
    {
      name = "jobs",
      toggle = true,
      actions = {
        {name = "loot_items",     info = "npcx_beh_gather_items"},
        {name = "loot_corpses",   info = "npcx_beh_loot_corpses"},
        {name = "loot_artifacts", info = "npcx_beh_gather_artifacts"},
        {name = "help_wounded",   info = "npcx_beh_help_wounded"},
      },
    },
    {
      name = "formation",
      cycle = true,
      actions = {
        {name = "bunch",   next = "spread",  default = true},
        {name = "spread",  next = "line",    info = "npcx_beh_formation_spread"},
        {name = "line",    next = "covered", info = "npcx_beh_formation_line"},
        {name = "covered", next = "bunch",   info = "npcx_beh_formation_covered"},
      },
    },
    {
      name = "light",
      cycle = true,
      actions = {
        {name = "auto", next="off",  default = true},
        {name = "off",  next="on",   info = "npcx_beh_light_off"},
        {name = "on",   next="auto", info = "npcx_beh_light_on"},
      },
    },
  }

  NPC.ACTIONS_KEYED = {}
  NPC.DEFAULT_STATE = {}
  NPC.GLOBAL_STATE  = {}
  NPC.SELECTED_IDS  = {}

  -- populate keyed actions
  for ig, group in ipairs(NPC.ACTIONS) do
    NPC.ACTIONS_KEYED[group.name] = dup_table(group)
    NPC.ACTIONS_KEYED[group.name].actions = {}

    for ia, action in ipairs(group.actions) do
      NPC.ACTIONS_KEYED[group.name].actions[action.name] = action
    end
  end

  -- populate default state
  for ig, group in ipairs(NPC.ACTIONS) do
    NPC.DEFAULT_STATE[group.name] = {}

    for ia, action in ipairs(group.actions) do
      NPC.DEFAULT_STATE[group.name][action.name] = action.default or false
    end
  end

  NPC.GLOBAL_STATE = dup_table(NPC.DEFAULT_STATE)
--


-- NPCS --
  function NPC.get(id)
    return db.storage[id] and db.storage[id].object or level.object_by_id(id)
  end


  function NPC.getAvgPosition(objects)
    local pos = {}
    local dir = {}

    for i, npc in ipairs(objects) do
      pos[i] = npc:position()
      dir[i] = npc:direction()
    end

    return VEC.average(pos), VEC.average(dir)
  end


  function NPC.isInventoryOpen(npc)
    if not Check_UI("UIInventory") or not ui_inventory.GUI then
      return false
    end

    return ui_inventory.GUI.npc_id == npc:id()
  end


  function NPC.createOwnSquad(id)
    local se    = alife():object(id)
    local squad = alife():object(se.group_id)

    if not se or not squad then
      return
    end

    local pos  = se.position
    local lvid = se.m_level_vertex_id
    local gvid = se.m_game_vertex_id

    local newSquad = alife_create(squad:section_name(), pos, lvid, gvid)

    squad:unregister_member(se.id)
    newSquad:register_member(se.id)

    return newSquad
  end
--


-- WEAPONS --
  function NPC.getGuns(npc)
    local guns = {}

    npc:inventory_for_each(function(item)
      if WPN.isGun(item) then
        table.insert(guns, item)
      end
    end)

    return guns
  end


  function NPC.isReloading(npc)
    return WPN.isGun(npc:active_item())
      and npc:active_item():get_state() == 7
      and not NPC.isInventoryOpen(npc)
      or  false
  end


  function NPC.getWeaponType(npc)
    local weapon = npc:active_item()

    return IsWeapon(weapon)
      and WPN.getType(weapon)
      or  WPN.getType(npc:best_weapon())
  end


  function NPC.getCurrentAmmo(npc)
    return WPN.getAmmoCount(npc:active_item()).current
  end


  function NPC.getTotalAmmo(npc)
    return WPN.getAmmoCount(npc:active_item()).total
  end


  function NPC.setReloadModes(npc, wmode, emode)
    db.storage[npc:id()].IDIOTS_RELOAD = {
      wmode = wmode or WPN.RELOAD_ACTIVE,
      emode = emode or WPN.EMPTY,
    }
  end


  function NPC.getReloadModes(npc)
    return db.storage[npc:id()].IDIOTS_RELOAD or {
      wmode = WPN.RELOAD_ACTIVE,
      emode = WPN.EMPTY,
    }
  end


  function NPC.setForcingWeapon(npc, force)
    db.storage[npc:id()].IDIOTS_FORCE_WEAPON = force and true or nil
  end


  function NPC.getForcingWeapon(npc)
    return db.storage[npc:id()].IDIOTS_FORCE_WEAPON or false
  end


  function NPC.forceWeapon(npc)
    local stance = NPC.getActiveState(npc, "stance")
    local state  = state_mgr.get_state(npc)

    local anim = nil
      or stance == "prone"       and (state == "sneak_fire" and "hide_fire" or "sneak_fire")
      or stance == "sneak"       and (state == "sneak_fire" and "hide_fire" or "sneak_fire")
      or state  == "threat_fire" and "guard_fire" or "threat_fire"

    state_mgr.set_state(npc, anim, nil, nil, nil, {fast_set = true})
  end
--


-- COMPANIONS --
  function NPC.isCompanion(npc)
    if type(npc) == "number" then
      npc = NPC.get(npc)
    end

    return npc
      and not axr_task_manager.hostages_by_id[npc:id()]
      and npc:has_info("npcx_is_companion")
      and npc:alive()
      and true
      or false
  end


  function NPC.getCompanion(id)
    local npc = NPC.get(id)
    return NPC.isCompanion(npc) and npc or nil
  end


  function NPC.indexOfCompanion(npc)
    if type(npc) == "number" then
      npc = NPC.get(npc)
    end

    if npc then
      return TABLE.keyof(NPC.getCompanions(), function(companion)
        return companion:id() == npc:id()
      end)
    end
  end


  function NPC.getCompanions()
    local companions = {}

    for id, squad in pairs(axr_companions.companion_squads) do
      if not (squad and squad.commander_id) then
        goto continue
      end
      if axr_task_manager.hostages_by_id[squad:commander_id()] then
        goto continue
      end

      for member in squad:squad_members() do
        local companion = NPC.getCompanion(member.id)

        if companion then
          table.insert(companions, companion)
        end
      end

      ::continue::
    end

    return companions
  end


  function NPC.getTargetCompanion(maxDist)
    local npc = level.get_target_obj()

    if not NPC.isCompanion(npc) then
      return
    end

    if maxDist and distance_between(db.actor, npc) > maxDist then
      return
    end

    return npc
  end


  function NPC.getBlockingCompanions()
    local spacing = 1.2
    local maxDist = 12

    local companions = {}

    for i, npc in ipairs(NPC.getCompanions()) do
      local dist = VEC.distance(db.actor:position(), npc:position())
      local dir  = VEC.direction(db.actor:position(), npc:position())

      local maxAngle = math.abs(math.deg(math.tan(spacing / 2 / dist)))
      local angle1   = math.deg(db.actor:direction():getH())
      local angle2   = math.deg(dir:getH())
      local angle    = math.abs(angle2 - angle1)

      if dist <= maxDist and angle <= maxAngle then
        table.insert(companions, npc)
      end
    end

    table.sort(companions, function(a, b)
      return distance_between(a, db.actor) > distance_between(b, db.actor)
    end)

    return companions
  end
--


-- FOLLOWERS --
  function NPC.isFollower(npc)
    if type(npc) == "number" then
      npc = NPC.get(npc)
    end

    return npc
      and NPC.isCompanion(npc)
      and (NPC.getState(npc, "movement", "follow"))
      and true
      or false
  end


  function NPC.indexOfFollower(npc)
    if type(npc) == "number" then
      npc = NPC.get(npc)
    end

    if npc then
      return TABLE.keyof(NPC.getFollowers(), function(follower)
        return follower:id() == npc:id()
      end)
    end
  end


  function NPC.getFollowers()
    local companions = {}

    for i, npc in ipairs(NPC.getCompanions()) do
      if NPC.isFollower(npc) then
        table.insert(companions, npc)
      end
    end

    return companions
  end
--


-- ACTIONS --
  function NPC.select(npc)
    if NPC.SELECTED_IDS[npc:id()] then
      NPC.SELECTED_IDS[npc:id()] = nil
      return false
    end

    NPC.SELECTED_IDS[npc:id()] = true
    return true
  end


  function NPC.deselectAll()
    if #table.keys(NPC.SELECTED_IDS) == 0 then
      return false
    end

    NPC.SELECTED_IDS = {}
    return true
  end


  function NPC.moveToPoint(npc, pos)
    local st = db.storage[npc:id()]

    local points = VEC.pointsAlongAxis({
      direction  = VEC.set(1, 0, 0),
      position   = pos,
      arcAngle   = 360,
      rows       = 2,
      radius     = 3,
      spacing    = 3,
      rowSpacing = 2,
    })

    table.insert(points, 1, pos)

    for i, point in ipairs(points) do
      local vid = POS.lvid(point)

      if POS.isUnclaimedLVID(npc, vid) then
        if st.enemy then
          st.combat.movePoint = vid
        else
          st.beh.movePoint  = vid
          st.beh.rally_lvid = vid
        end

        POS.claimLVID(npc, vid)
        return
      end
    end
  end


  function NPC.lookAtPoint(npc, pos)
    local st = db.storage[npc:id()]

    if st.enemy then
      st.combat.lookPoint = pos
      st.combat.lookTimer = nil
    else
      st.beh.lookPoint = pos
      st.beh.lookTimer = nil
    end
  end


  function NPC.moveOutOfTheWay(npc, options)
    options = TABLE.merge({
      findFn     = POS.legacyValidLVID,
      findFrom   = npc:position(),
      moveState  = "sprint",
      minDist    = 1.2,
      strafeDist = 2.4,
      backDist   = 8.0,
      range      = 180,
      directions = 8,
    }, options)

    local baseDir    = VEC.direction(db.actor:position(), npc:position())
    local randomFlip = UTIL.random(0, 1) * 2 - 1
    local angles     = {}

    local bestVid
    local bestDist = 0

    for i = 0, options.directions do
      table.insert(angles, randomFlip * (options.range / options.directions * i - options.range / 2))
    end

    table.sort(angles, function(a, b)
      return math.abs(a) > math.abs(b)
    end)

    for i, angle in ipairs(angles) do
      local idealDist = math.abs(angle) > 30
        and options.strafeDist
        or  options.backDist

      local dir  = VEC.rotate(baseDir, angle)
      local pos  = VEC.offset(npc:position(), dir, idealDist)
      local vid  = options.findFn(npc, options.findFrom, pos)
      local dist = VEC.distance(npc:position(), POS.position(vid))

      if POS.isValidLVID(npc, vid) then
        if dist > bestDist then
          bestDist = dist
          bestVid  = vid
        end
        if dist >= options.minDist then
          break
        end
      end
    end

    if not bestVid then
      return
    end

    local st = db.storage[npc:id()]

    if st.enemy then
      st.combat.movePoint = bestVid
    else
      st.beh.moveState  = options.moveState
      st.beh.movePoint  = bestVid
      st.beh.rally_lvid = bestVid
    end

    POS.claimLVID(npc, bestVid)
  end
--


-- STATE --
  function NPC.isStateful(group, action)
    return group and action
      and NPC.DEFAULT_STATE[group]
      and NPC.DEFAULT_STATE[group][action] ~= nil
  end


  function NPC.getState(npc, group, action)
    if not NPC.isStateful(group, action) then
      return
    end

    if not npc then
      return NPC.GLOBAL_STATE[group][action]
    end

    if type(npc) == "number" then
      npc = NPC.getCompanion(npc)
    end

    if not npc then
      return
    end

    local info = NPC.ACTIONS_KEYED[group].actions[action].info

    if info then
      return npc:has_info(info)
    end

    if not NPC.ACTIONS_KEYED[group].cycle then
      return false
    end

    for act, config in pairs(NPC.ACTIONS_KEYED[group].actions) do
      if config.info and npc:has_info(config.info) then
        return false
      end
    end

    return true
  end


  function NPC.getAllStates(npc)
    if npc == nil then
      return dup_table(NPC.GLOBAL_STATE)
    end

    local states = {}

    for group, actions in pairs(NPC.DEFAULT_STATE) do
      states[group] = {}

      for action in pairs(actions) do
        states[group][action] = NPC.getState(npc, group, action)
      end
    end

    return states
  end


  function NPC.getActiveState(npc, group)
    if not (NPC.ACTIONS_KEYED[group] and NPC.ACTIONS_KEYED[group].cycle) then
      return
    end

    for action, config in pairs(NPC.ACTIONS_KEYED[group].actions) do
      if NPC.getState(npc, group, action) then
        return action
      end
    end
  end


  function NPC.__privateSet(npc, group, action, enabled)
    if not NPC.isStateful(group, action) then
      return
    end

    if not npc then
      SendScriptCallback("idiots_on_state_will_change", nil, group, action, enabled)
      NPC.GLOBAL_STATE[group][action] = enabled
      SendScriptCallback("idiots_on_state_change", nil, group, action, enabled)
      return
    end

    if type(npc) == "number" then
      npc = NPC.getCompanion(npc)
    end

    if not npc then
      return
    end

    local info = NPC.ACTIONS_KEYED[group].actions[action].info

    SendScriptCallback("idiots_on_state_will_change", npc:id(), group, action, enabled)

    if info then
      if enabled then
        npc:give_info_portion(info)
      else
        npc:disable_info_portion(info)
      end
    end

    SendScriptCallback("idiots_on_state_change", npc:id(), group, action, enabled)
  end


  function NPC.setState(npc, group, action, enabled)
    if not NPC.isStateful(group, action) then
      return
    end

    if enabled == NPC.getState(npc, group, action) then
      return
    end

    if not NPC.ACTIONS_KEYED[group].cycle then
      NPC.__privateSet(npc, group, action, enabled)
    elseif enabled then
      for other in pairs(NPC.ACTIONS_KEYED[group].actions) do
        NPC.__privateSet(npc, group, other, other == action)
      end
    end

    if not npc then
      for i, npc in ipairs(NPC.getCompanions()) do
        NPC.setState(npc, group, action, enabled)
      end
    end
  end


  function NPC.setStates(npc, states)
    for group, actions in pairs(states) do
      for action, enabled in pairs(actions) do
        NPC.setState(npc, group, action, enabled)
      end
    end
  end


  function NPC.cycleActiveState(npc, group)
    local active = NPC.getActiveState(npc, group)

    if not active then
      return
    end

    local next = NPC.ACTIONS_KEYED[group].actions[active].next

    if next then
      NPC.setState(npc, group, next, true)
      return next
    end
  end


  function NPC.toggleState(npc, group, action)
    if not NPC.isStateful(group, action) then
      return
    end

    local enabled = true

    if NPC.ACTIONS_KEYED[group].toggle then
      enabled = not NPC.getState(npc, group, action)
    end

    if enabled ~= NPC.getState(npc, group, action) then
      NPC.setState(npc, group, action, enabled)
      return enabled
    end
  end


  AddScriptCallback("idiots_on_state_will_change")
  AddScriptCallback("idiots_on_state_change")
--


return NPC
