local TABLE = require "illish.lib.table"
local NPC   = require "illish.lib.npc"
local WPN   = require "illish.lib.weapon"


local PATCH = {}


-- Custom combat types to inject
PATCH.CUSTOM_COMBAT = {
  idiots_combat_assault,
  idiots_combat_support,
  idiots_combat_snipe,
  idiots_combat_guard,
}


-- Force combat type to update to fix an issue where companions can get stuck
-- in legacy scripted combat (because the original was probably not written to
-- work with condlists)
local PATCH_evaluate = xr_combat.evaluator_check_combat.evaluate

function xr_combat.evaluator_check_combat:evaluate()
  xr_combat.set_combat_type(self.object, db.actor, self.st)
  return PATCH_evaluate(self)
end


-- Inject custom combat types
local PATCH_add_to_binder = xr_combat.add_to_binder

function xr_combat.add_to_binder(npc, ini, scheme, section, storage, temp)
  PATCH_add_to_binder(npc, ini, scheme, section, storage, temp)

  local manager = npc:motivation_action_manager()

  if manager and temp.section then
    for i, scheme in ipairs(PATCH.CUSTOM_COMBAT) do
      if scheme and scheme.add_to_binder then
        scheme.add_to_binder(npc, ini, storage, manager, temp)
      end
    end
  end
end


-- Patch zombied combat type to allow companions to use it (for lulz)
local PATCH_zombied_evaluate = xr_combat_zombied.evaluator_combat_zombied.evaluate

function xr_combat_zombied.evaluator_combat_zombied:evaluate()
  local enabled = ui_mcm.get("idiots/options/zombiedCombat")
  local npc = self.object

  if enabled and NPC.isCompanion(npc) and NPC.getState(npc, "combat", "zombied") then
    return true
  end

  return PATCH_zombied_evaluate(self)
end


-- Override weapon selection for companions
function PATCH.onChooseWeapon(npc, wpn, flags)
  if not NPC.isCompanion(npc) then
    return
  end

  local selected = NPC.getActiveState(npc, "weapon")
  local wmode    = NPC.getReloadWeaponMode(npc)
  local weapons  = NPC.getGuns(npc)

  -- unloaded
  if wmode then
    local id = NPC.setReloadWeapon(npc)

    if id then
      flags.gun_id = id
      return
    end

    if wmode == WPN.RELOAD_ALL then
      for i, weapon in ipairs(weapons) do
        if WPN.isUnloaded(weapon) then
          flags.gun_id = weapon:id()
          return
        end
      end
    end
  end

  -- nothing to reload
  NPC.setReloadModes(npc, 0, 0)

  table.sort(weapons, function(w1, w2)
    -- selected in UI
    local t1 = WPN.getType(w1)
    local t2 = WPN.getType(w2)

    if t1 == "smg" then
      t1 = "rifle"
    end
    if t2 == "smg" then
      t2 = "rifle"
    end

    if t1 ~= t2 and t1 == selected then
      return true
    elseif t1 ~= t2 and t2 == selected then
      return false
    end

    -- repair kit type
    local kits = {"pistol", "shotgun", "rifle_5", "rifle_7"}
    local p1 = TABLE.keyof(kits, WPN.getRepairType(w1)) or 5
    local p2 = TABLE.keyof(kits, WPN.getRepairType(w2)) or 5

    if p1 > p2 then
      return true
    elseif p1 < p2 then
      return false
    end

    -- cost
    return WPN.getCost(w2) < WPN.getCost(w1)
  end)

  if weapons[1] then
    flags.gun_id = weapons[1]:id()
  end
end


-- Prevent error from companion_anti_awol accessing this before it's defined
if companion_anti_awol then
  companion_anti_awol.companion_retreat = {}
end


-- Disable "cover" because it is not a valid scripted combat scheme
if schemes_ai_gamma and schemes_ai_gamma.scheme_cover then
  function schemes_ai_gamma.scheme_cover()
    return false
  end
end


-- Callbacks
RegisterScriptCallback("idiots_on_start", function()
  RegisterScriptCallback("npc_on_choose_weapon", PATCH.onChooseWeapon)
end)


return PATCH
