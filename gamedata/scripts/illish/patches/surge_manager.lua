local POS   = require "illish.lib.pos"
local NPC   = require "illish.lib.npc"
local SURGE = require "illish.lib.surge"


local PATCH = {}

-- Temp cache for obfuscated companions
PATCH.OBFUSCATED = nil


-- Temporarily hide companions from scripts to allow them to die in GAMMA
function PATCH.obfuscateCompanions()
  local companions = NPC.getCompanions()

  if not (companions and #companions > 0) then
    return
  end

  for i, npc in ipairs(companions) do
    npc:disable_info_portion("npcx_is_companion")
  end

  PATCH.OBFUSCATED = {
    squads     = axr_companions.companion_squads,
    nonTask    = axr_companions.non_task_companions,
    companions = companions,
  }

  axr_companions.companion_squads    = {}
  axr_companions.non_task_companions = {}
end

-- Restore companions to their original state
function PATCH.deobfuscateCompanions()
  if not PATCH.OBFUSCATED then
    return
  end

  for i, npc in ipairs(PATCH.OBFUSCATED.companions) do
    npc:give_info_portion("npcx_is_companion")
  end

  axr_companions.companion_squads    = PATCH.OBFUSCATED.squads
  axr_companions.non_task_companions = PATCH.OBFUSCATED.nonTask

  PATCH.OBFUSCATED = nil
end


-- Temporarily add dummy story IDs for companions to prevent Anomaly from killing them
function PATCH.addCompanionStoryIds()
  local ids = story_objects.story_id_by_object_id

  for i, npc in ipairs(NPC.getCompanions()) do
    if not ids[npc:id()] then
      ids[npc:id()] = "useful_idiot"
    end
  end
end

-- Remove dummy companion story IDs
function PATCH.removeCompanionStoryIds()
  local ids = story_objects.story_id_by_object_id

  for i, npc in ipairs(NPC.getCompanions()) do
    if ids[npc:id()] == "useful_idiot" then
      ids[npc:id()] = nil
    end
  end
end


-- Use dynamic surge cover for companions if enabled
local surge_manager_pos_in_cover = surge_manager.CSurgeManager.pos_in_cover

function surge_manager.CSurgeManager:pos_in_cover(pos, byName)
  local dynamic = ui_mcm.get("idiots/options/dynamicSurgeCover")
  local result  = surge_manager_pos_in_cover(self, pos, byName)

  if result or dynamic == "neither" then
    return result
  end

  return SURGE.isDynamicCover(pos)
end


-- Use dynamic surge cover for the player if enabled
local actor_status_scan_safe_zone_old = actor_status.scan_safe_zone_old

function actor_status.scan_safe_zone_old()
  local dynamic = ui_mcm.get("idiots/options/dynamicSurgeCover")
  local curr, near, num = actor_status_scan_safe_zone_old()

  if not curr and dynamic == "both" then
    curr = SURGE.isDynamicCover(db.actor:position())
  end

  return curr, near, num
end


-- Kill or spare companions in emission depending on settings
local surge_manager_kill_objects_at_pos = surge_manager.CSurgeManager.kill_objects_at_pos

function surge_manager.CSurgeManager:kill_objects_at_pos(...)
  local killCompanions = ui_mcm.get("idiots/options/surgesKillCompanions")

  if killCompanions
    then PATCH.obfuscateCompanions()
    else PATCH.addCompanionStoryIds()
  end

  surge_manager_kill_objects_at_pos(self, ...)

  if killCompanions
    then PATCH.deobfuscateCompanions()
    else PATCH.removeCompanionStoryIds()
  end
end


-- Kill or spare companions in psi storms depending on settings
local psi_storm_manager_kill_objects_at_pos = psi_storm_manager.CPsiStormManager.kill_objects_at_pos

function psi_storm_manager.CPsiStormManager:kill_objects_at_pos(...)
  local killCompanions = ui_mcm.get("idiots/options/surgesKillCompanions")

  if killCompanions
    then PATCH.obfuscateCompanions()
    else PATCH.addCompanionStoryIds()
  end

  psi_storm_manager_kill_objects_at_pos(self, ...)

  if killCompanions
    then PATCH.deobfuscateCompanions()
    else PATCH.removeCompanionStoryIds()
  end
end


-- Manage the surge cover cache
RegisterScriptCallback("idiots_on_start", function()
  RegisterScriptCallback("actor_on_first_update", function()
    SURGE.buildCovers()
  end)

  RegisterScriptCallback("mcm_option_change", function()
    SURGE.buildCovers(true)
  end)
end)


return PATCH
