local UTIL = require "illish.lib.util"
local WPN  = require "illish.lib.weapon"


-- Overwrite with bug fixes and new implementation
function xr_weapon_jam.npc_on_update(npc)
  local SETTINGS = xr_weapon_jam.SETTINGS
  local TRACKING = xr_weapon_jam.GUN_TRACKING

  -- Properly evaluate SETTINGS.enabled
  if SETTINGS.enabled == "false" then
    return
  end

  if not npc:alive() or not npc:best_enemy() then
    return
  end

  local weapon = npc:active_item()
  if not IsWeapon(weapon) then
    return
  end

  if not TRACKING[weapon:id()] then
    TRACKING[weapon:id()] = {ammo_last_update = 0, rounds_since_jam = 0}
  end

  local ammo = WPN.getAmmoCount(weapon)
  local prevAmmo = TRACKING[weapon:id()].ammo_last_update
  TRACKING[weapon:id()].ammo_last_update = ammo.current

  if ammo.current == 0 or ammo.current >= prevAmmo then
    return
  end

  local totalSpent = TRACKING[weapon:id()].rounds_since_jam + prevAmmo - ammo.current
  TRACKING[weapon:id()].rounds_since_jam = totalSpent

  local rank = ranks.get_obj_rank_name(npc)
  local baseChance = SETTINGS["base_ch_".. rank]
  local maxChance  = SETTINGS["max_ch_" .. rank]

  local chance = math.min(UTIL.round(totalSpent * baseChance / ammo.total ^ SETTINGS.clip_size_factor, 2), maxChance)

  -- Jam and reset jam chance values
  if UTIL.random(1, 100, 2) <= chance then
    weapon:unload_magazine()
    TRACKING[weapon:id()].ammo_last_update = 0
    TRACKING[weapon:id()].rounds_since_jam = 0
  end
end
