local NPC = require "illish.lib.npc"


local PATCH = {}


-- Split each companion into their own squad for better control
function PATCH.splitCompanionSquads()
  if not ui_mcm.get("idiots/options/splitSquads") then
    return
  end

  for id in pairs(axr_companions.non_task_companions) do
    local se    = alife():object(id)
    local squad = get_object_squad(se)

    if not se or not squad then
      axr_companions.non_task_companions[id] = nil
    else
      for member in squad:squad_members() do
        if squad:npc_count() > 1 then
          local newSquad = NPC.createOwnSquad(member.id)
          if newSquad then
            axr_companions.companion_squads[newSquad.id] = newSquad
            SIMBOARD:setup_squad_and_group(se)
            newSquad:set_squad_relation()
            newSquad:refresh()
          end
        end
      end
    end
  end
end


-- Split each companion into own squad when joining
PATCH.become_actor_companion = dialogs_axr_companion.become_actor_companion

function dialogs_axr_companion.become_actor_companion(actor, npc)
  PATCH.become_actor_companion(actor, npc)
  PATCH.splitCompanionSquads()
end


-- Split each companion into own squad when warfare stuff happens
PATCH.add_companion_squad = sim_squad_warfare.add_companion_squad

function sim_squad_warfare.add_companion_squad(squad)
  PATCH.add_companion_squad(squad)
  PATCH.splitCompanionSquads()
end


-- Overwrite to sync with global state
function axr_companions.add_to_actor_squad(npc)
  axr_companions.non_task_companions[npc:id()] = true
  se_save_var(npc:id(), npc:name(), "companion", true)
  npc:inactualize_patrol_path()

  axr_companions.setup_companion_logic(npc, db.storage[npc:id()], false)

  -- Reset vanilla flags that might interfere
  npc:disable_info_portion("npcx_beh_hide_in_cover")
  save_var(npc, "fight_from_point", nil)

  -- Sync with global state
  NPC.setStates(npc, NPC.GLOBAL_STATE)
end


-- Overwrite to prevent teleporting for additional behaviors
function axr_companions.companion_squad_can_teleport(squad)
  local sim = alife()
  local id  = squad:commander_id()
  local se  = sim:object(id)

  if se and se_load_var(se.id, se:name(), "companion_cannot_teleport") then
    return false
  end

  for ig, group in ipairs(NPC.ACTIONS) do
    for ia, action in ipairs(group.actions) do
      if action.teleport == false and sim:has_info(id, action.info) then
        return false
      end
    end
  end

  return true
end


-- Disable vanilla companion wheel
function axr_companions.on_key_release()
end


-- Disable vanilla "move to point" keybind
function axr_companions.move_to_point()
end


-- Show/hide all inventory items or just looted/gathered items
local PATCH_is_assigned_item = axr_companions.is_assigned_item

function axr_companions.is_assigned_item(npcID, itemID)
  local showAll = ui_mcm.get("idiots/options/showAllItems")

  if NPC.isCompanion(npcID) and (showAll or NPC.LOOT_SHARED_ITEMS[itemID]) then
    return true
  end

  return PATCH_is_assigned_item(npcID, itemID)
end


-- Split existing companions into own squads at load
RegisterScriptCallback("idiots_on_start", function()
  RegisterScriptCallback("actor_on_first_update", PATCH.splitCompanionSquads)
end)


return PATCH
