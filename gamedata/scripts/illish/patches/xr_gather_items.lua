local NPC = require "illish.lib.npc"


local PATCH = {}


-- Enable/disable gathering items for non-companions
local PATCH_gather_evaluate = xr_gather_items.eva_gather_itm.evaluate

function xr_gather_items.eva_gather_itm:evaluate()
  local noGathering = ui_mcm.get("idiots/options/noNpcLooting")

  if noGathering and not NPC.isCompanion(self.object) then
    return false
  end

  return PATCH_gather_evaluate(self)
end


-- Start tracking gathered items for inventory visiblity
local PATCH_gather_initialize = xr_gather_items.act_gather_itm.initialize

function xr_gather_items.act_gather_itm:initialize()
  if NPC.isCompanion(self.object) then
    NPC.LOOT_SHARING_NPCS[self.object:id()] = true
  end

  PATCH_gather_initialize(self)
end


-- Stop tracking gathered items
local PATCH_gather_finalize = xr_gather_items.act_gather_itm.finalize

function xr_gather_items.act_gather_itm:finalize()
  NPC.LOOT_SHARING_NPCS[self.object:id()] = nil
  PATCH_gather_finalize(self)
end


-- Enable/disable gathering artifacts for companions
local PATCH_gather_find_item  = xr_gather_items.eva_gather_itm.find_valid_item

function xr_gather_items.eva_gather_itm:find_valid_item()
  if NPC.isCompanion(self.object) then
    -- Replace condlist with "false"
    if not self.st.ARTIFACTS_ORIGINAL then
      self.st.ARTIFACTS_ORIGINAL = self.st.gather_artefact_items_enabled
      self.st.ARTIFACTS_DISABLER = {{"false"}}
    end

    local artifactsEnabled = ui_mcm.get("idiots/options/artifacts")

    -- Restore original condlist
    if not artifactsEnabled then
      self.st.gather_artefact_items_enabled = self.st.ARTIFACTS_DISABLER
    else
      self.st.gather_artefact_items_enabled = self.st.ARTIFACTS_ORIGINAL
    end
  end

  return PATCH_gather_find_item(self)
end


-- Don't pickup weapons if disabled
function PATCH.onItemBeforePickup(npc, item, flags)
  if not IsWeapon(item) then
    return
  end

  if NPC.isCompanion(npc) and not NPC.getState(npc, "jobs", "loot_items") then
    flags.ret_value = false
  end

  if not NPC.isCompanion(npc) and ui_mcm.get("idiots/options/noNpcLooting") then
    flags.ret_value = false
  end
end


-- NOTE: Other callbacks are in the xr_corpse_detection patch
function on_game_start()
  RegisterScriptCallback("npc_on_item_before_pickup", PATCH.onItemBeforePickup)
end


return PATCH
