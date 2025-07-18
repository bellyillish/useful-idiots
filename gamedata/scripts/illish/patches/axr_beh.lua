local WP   = world_property
local UTIL = require "illish.lib.util"
local NPC  = require "illish.lib.npc"
local BEH  = require "illish.lib.beh"
local WPN  = require "illish.lib.weapon"


local PATCH = {}

-- Additional targets added by Useful Idiots to beh_companion.ltx and the
-- corresponding functions for their behavior.
PATCH.CUSTOM_TARGETS = {
  cover_spot   = BEH.setTargetCoverSpot,
  cover_actor  = BEH.setTargetFollowActor,
  follow_actor = BEH.setTargetFollowActor,
  look_around  = BEH.setTargetLookAround,
  relax_spot   = BEH.setTargetRelaxSpot,
}


-- Add a "normal" desired distance setting
local PATCH_init_custom_data = axr_beh.init_custom_data

function axr_beh.init_custom_data(npc, ini, section, st, scheme)
  PATCH_init_custom_data(npc, ini, section, st, scheme)
  st.normal_desired_dist = ini:r_string_to_condlist(section, "normal_desired_dist", "4")
end


-- Check if weapon needs to be reloading when entering BEH scheme
local PATCH_initialize = axr_beh.action_beh.initialize

function axr_beh.action_beh:initialize()
  PATCH_initialize(self)
  local npc = self.object

  if not NPC.isCompanion(npc) then
    return
  end

  local wmode = ui_mcm.get("idiots/options/autoReloadAll")
    and WPN.RELOAD_ALL
    or  WPN.RELOAD_ACTIVE

  NPC.setReloadModes(self.object, wmode, WPN.NOT_FULL)
end


-- Inject custom targets into BEH scheme
local PATCH_set_desired_target = axr_beh.action_beh.set_desired_target

function axr_beh.action_beh:set_desired_target()
  local npc = self.object
  local st  = self.st

  if not NPC.isCompanion(npc) then
    return PATCH_set_desired_target(self)
  end

  local target = xr_logic.pick_section_from_condlist(db.actor, npc, st.goto_target)

  -- Remember desired_target values between calls
  if st.target == target and st.desired_target then
    st.savedTarget = dup_table(st.desired_target)
  else
    st.lookTimer   = nil
    st.lookPoint   = nil
    st.savedTarget = {}
  end

  -- Retain previous values to detect changes
  st.lastTarget   = st.target
  st.lastKeepType = st.keepType

  -- Defer to original function first
  local success  = PATCH_set_desired_target(self)
  local targetFn = PATCH.CUSTOM_TARGETS[target]

  -- Run custom target function only if original did not match
  if success or not targetFn then
    return success
  end

  -- globally store this result for use in custom target functions
  st.keepType = xr_logic.pick_section_from_condlist(db.actor, npc, st.keep_distance)

  return targetFn(self)
end


-- Override beh_move
local PATCH_beh_move = axr_beh.action_beh.beh_move

function axr_beh.action_beh:beh_move()
  local npc = self.object
  local st  = self.st

  -- Backward compatibility
  if not (NPC.isCompanion(npc) and PATCH.CUSTOM_TARGETS[st.target]) then
    return PATCH_beh_move(self)
  end

  if not st.setStateFn then
    st.setStateFn = state_mgr.set_state
  end

  local move = BEH.getBehMoveState(self)
  local look = BEH.getBehLookState(self)

  st.setStateFn(npc, move, nil, nil, look, {fast_set = true})
end


-- Override beh_wait
local PATCH_beh_wait = axr_beh.action_beh.beh_wait

function axr_beh.action_beh:beh_wait()
  local npc = self.object
  local st  = self.st

  -- Backward compatibility
  if not (NPC.isCompanion(npc) and PATCH.CUSTOM_TARGETS[st.target]) then
    return PATCH_beh_wait(self)
  end

  self:beh_move()
end


-- Override beh_cover
local PATCH_beh_cover = axr_beh.action_beh.beh_cover

function axr_beh.action_beh:beh_cover()
  local npc = self.object
  local st  = self.st

  -- Backward compatibility
  if not (NPC.isCompanion(npc) and PATCH.CUSTOM_TARGETS[st.target]) then
    return PATCH_beh_cover(self)
  end

  self:beh_move()
end


-- New behavior
function axr_beh.action_beh:beh_relax()
  local npc = self.object
  local st  = self.st

  -- Fallack to beh_wait if something went wrong
  if not (NPC.isCompanion(npc) and PATCH.CUSTOM_TARGETS[st.target]) then
    return PATCH_beh_wait(self)
  end

  self:beh_move()
end


-- Let gather items, loot corpses, and heal wounded to interrupt scheme
local PATCH_beh_add_to_binder = axr_beh.add_to_binder

function axr_beh.add_to_binder(npc, ...)
  PATCH_beh_add_to_binder(npc, ...)

  local manager = npc:motivation_action_manager()
  local action  = manager:action(axr_beh.beh_actid)

  if (schemes.gather_items) then
    action:add_precondition(WP(xr_gather_items.evaid, false))
  end

  if (schemes.corpse_detection) then
    action:add_precondition(WP(xr_evaluators_id.corpse_exist, false))
  end

  if (schemes.help_wounded) then
    action:add_precondition(WP(xr_evaluators_id.wounded_exist, false))
  end

  action:add_precondition(WP(stalker_ids.property_items, false))
end


return PATCH
