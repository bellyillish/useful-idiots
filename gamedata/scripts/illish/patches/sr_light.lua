local NPC = require "illish.lib.npc"


-- Adds controllable headlamps for companions
local PATCH_check_light = sr_light.check_light

function sr_light.check_light(npc)
  if not NPC.isCompanion(npc) then
    PATCH_check_light(npc)
    return
  end

  local state = NPC.getActiveState(npc, "light")
  local torch = npc:object("device_torch")

  if not (torch and state) then
    PATCH_check_light(npc)
    return
  end

  -- Override if not set to "default"
  if state == "off" or state == "on" then
    torch:enable_attachable_item(state == "on")
    return
  end

  local mimicActor = ui_mcm.get("idiots/options/autoLight")

  -- Defer to other mods if not following with "auto headlamps" enabled
  if not (mimicActor and NPC.isFollower(npc)) then
    PATCH_check_light(npc)
    return
  end

  -- Override with actor's headlamp state
  local actorTorch   = db.actor:item_in_slot(10)
  local actorEnabled = actorTorch and actorTorch:torch_enabled() or false

  torch:enable_attachable_item(actorEnabled)
end
