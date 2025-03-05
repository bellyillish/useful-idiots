local WPN = {
  -- wmode
  RELOAD_ACTIVE = 0,
  RELOAD_ALL    = 1,
  -- emode
  EMPTY         = 0,
  HALF_EMPTY    = 1,
  NOT_FULL      = 2,
}


function WPN.isGun(weapon)
  local type = WPN.getType(weapon)
  return type and type ~= "melee"
end


function WPN.getType(weapon)
  if not IsWeapon(weapon) then
    return
  end

  local type = SYS_GetParam(0, weapon:section(), "kind")

  return nil
    or type == "w_pistol"    and "pistol"
    or type == "w_shotgun"   and "shotgun"
    or type == "w_smg"       and "smg"
    or type == "w_rifle"     and "rifle"
    or type == "w_sniper"    and "sniper"
    or type == "w_explosive" and "rpg"
    or type == "w_melee"     and "melee"
end


function WPN.getRepairType(weapon)
  if IsWeapon(weapon) then
    return SYS_GetParam(0, weapon:section(), "repair_type")
  end
end


function WPN.getCost(weapon)
  if IsWeapon(weapon) then
    return SYS_GetParam(2, weapon:section(), "cost")
  end
end


function WPN.getAmmoCount(weapon)
  local current = 0
  local total   = 0

  if WPN.isGun(weapon) then
    current = weapon:get_ammo_in_magazine() or 0
    total   = SYS_GetParam(2, weapon:section(), "ammo_mag_size", 0)
  end

  return {current = current, total = total}
end


return WPN
