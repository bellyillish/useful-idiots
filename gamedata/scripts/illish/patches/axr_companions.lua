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


-- Track when a companion is hit for "defend only"
function PATCH.onHitCompanion(npc, amount, local_direction, who, bone_index)
  if NPC.isCompanion(npc) and amount > 0 then
    db.storage[0].companion_hit_by = who:id()
  end
end


-- Split each companion into own squad when joining
local PATCH_become_actor_companion = dialogs_axr_companion.become_actor_companion

function dialogs_axr_companion.become_actor_companion(actor, npc)
  PATCH_become_actor_companion(actor, npc)
  PATCH.splitCompanionSquads()
end


-- Split each companion into own squad when warfare stuff happens
local PATCH_add_companion_squad = sim_squad_warfare.add_companion_squad

function sim_squad_warfare.add_companion_squad(squad)
  PATCH_add_companion_squad(squad)
  PATCH.splitCompanionSquads()
end


-- Overwrite to sync with global state
function axr_companions.add_to_actor_squad(npc)
  axr_companions.non_task_companions[npc:id()] = true
  se_save_var(npc:id(), npc:name(), "companion", true)
  npc:inactualize_patrol_path()

  axr_companions.setup_companion_logic(npc, db.storage[npc:id()], false)

  -- Reset vanilla flags that might interfere
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


-- Call old functions in axr_companions for mod compatibility
function PATCH.callLegacyStateSetters(id, group, action, enabled)
  local npc = id and NPC.getCompanion(id) or NPC.getCompanions()[1]

  if not npc then
    return
  end

  if group == "jobs" and action == "loot_corpses" then
    local lootingItems = NPC.getState(id and npc or nil, "jobs", "loot_items")
    if enabled and lootingItems then
      axr_companions.set_companion_to_loot_items_and_corpses(npc)
    elseif enabled then
      axr_companions.set_companion_to_loot_corpses_only(npc)
    elseif not lootingItems then
      axr_companions.set_companion_to_loot_nothing(npc)
    end
  end

  if group == "jobs" and action == "loot_items" then
    local lootingCorpses = NPC.getState(id and npc or nil, "jobs", "loot_corpses")
    if enabled and lootingCorpses then
      axr_companions.set_companion_to_loot_items_and_corpses(npc)
    elseif enabled then
      axr_companions.set_companion_to_loot_items_only(npc)
    elseif not lootingCorpses then
      axr_companions.set_companion_to_loot_nothing(npc)
    end
  end

  if not enabled then
    return
  end

  if group == "movement" and action == "follow" then
    axr_companions.set_companion_to_follow_state(npc)

  elseif group == "movement" and action == "wait" then
    axr_companions.set_companion_to_wait_state(npc)
    save_var(npc, "fight_from_point", nil)

  elseif group == "movement" and action == "cover" then
    axr_companions.set_companion_hide_in_cover(npc)

  elseif group == "movement" and action == "relax" then
    axr_companions.set_companion_to_relax_substate(npc)

  elseif group == "movement" and action == "patrol" then
    axr_companions.set_companion_to_patrol_state(npc)

  elseif group == "stance" and action == "stand" then
    local relaxing = NPC.getState(id and npc or nil, "movement", "relax")
    axr_companions.set_companion_to_default_substate(npc)
    if relaxing then
      npc:give_info_portion("npcx_beh_substate_relax")
    end

  elseif group == "stance" and action == "sneak" then
    axr_companions.set_companion_to_stealth_substate(npc)

  elseif group == "distance" and action == "near" then
    axr_companions.set_companion_to_stay_close(npc)

  elseif group == "distance" and action == "normal" then
    axr_companions.set_companion_to_stay_close(npc)

  elseif group == "distance" and action == "far" then
    axr_companions.set_companion_to_stay_far(npc)

  elseif group == "readiness" and action == "attack" then
    axr_companions.set_companion_to_attack_state(npc)

  elseif group == "readiness" and action == "defend" then
    axr_companions.set_companion_to_attack_only_actor_combat_enemy_state(npc)
    npc:disable_info_portion("npcx_beh_ignore_combat")

  elseif group == "readiness" and action == "ignore" then
    axr_companions.set_companion_to_ignore_combat_state(npc)
  	npc:disable_info_portion("npcx_beh_ignore_actor_enemies")
  end
end


-- Call old waypoint add/remove functions for compatibility
function PATCH.callLegacyWaypointSetters(group, action, ui)
  if action ~= "add_waypoint" and action ~= "clear_waypoints" then
    return
  end

  local npc = ui.ID and NPC.get(ui.ID)
  if not npc then
    return
  end

  -- but don't let the old functions actually do anything
  local _g_se_load_var = _G.se_load_var
  local _g_se_save_var = _G.se_save_var

  _G.se_load_var = function() end
  _G.se_save_var = function() end

  if action == "add_waypoint" then
    axr_companions.companion_add_waypoints(npc)
  end

  if action == "clear_waypoints" then
    axr_companions.companion_remove_waypoints(npc)
  end

  _G.se_load_var = _g_se_load_var
  _G.se_save_var = _g_se_save_var
end


-- Split existing companions into own squads at load
RegisterScriptCallback("idiots_on_start", function()
  RegisterScriptCallback("npc_on_hit_callback", PATCH.onHitCompanion)
  RegisterScriptCallback("actor_on_first_update", PATCH.splitCompanionSquads)
  RegisterScriptCallback("idiots_on_state_will_change", PATCH.callLegacyStateSetters)
  RegisterScriptCallback("idiots_on_use_button", PATCH.callLegacyWaypointSetters)
end)


return PATCH
