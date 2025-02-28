local UTIL = require "illish.lib.util"
local VEC  = require "illish.lib.vector"
local NPC  = require "illish.lib.npc"


local PATCH = {}


PATCH.STATE_FIXES = {
  hide  = "hide_na",
  prone = "prone_idle",
}


-- Patch with various fixes
local PATCH_set_state = state_mgr.set_state

function state_mgr.set_state(npc, state, callback, timeout, target, extra)
  -- 1. Swap hide with hide_na after "in" animation because it makes companions
  --    twitch oddly when idle
  -- 2. Swap prone with prone_idle after "in" animation because otherwise
  --    companions get up with every direction change
  if NPC.isCompanion(npc) then
    local st = db.storage[npc:id()]

    local timeout = st.IDIOTS_STATE_FIXES
      and st.IDIOTS_STATE_FIXES[state]

    -- Clear all other state timeouts
    st.IDIOTS_STATE_FIXES = {}

    -- Replace with idle version
    for animState, idleState in pairs(PATCH.STATE_FIXES) do
      if state == animState then
        st.IDIOTS_STATE_FIXES[state] = timeout or time_plus(1000)
        if time_expired(timeout) then
          state = idleState
        end
        break
      end
    end
  end

  -- Force {fast_set = true} on all companion animations because it seems to
  -- fix some issues with them getting stuck or being unresponsive
  if NPC.isCompanion(npc) then
    extra = extra or {}
    extra.fast_set = extra.fast_set ~= false
  end

  -- Validate look_position and look_dir because directions with very small
  -- or zero magnitudes can make NPCs/companions disappear
  if target and target.look_position then
    local dir = VEC.direction(npc:position(), target.look_position)
    if UTIL.round(dir:magnitude()) ~= 1 then
      target.look_position = nil
    end

  elseif target and target.look_dir then
    if UTIL.round(target.look_dir:magnitude()) ~= 1 then
      target.look_dir = nil
    end
  end

  return PATCH_set_state(npc, state, callback, timeout, target, extra)
end


-- Various fixes for prone stance
state_lib.states.prone.movement              = move.stand
state_lib.states.prone_idle.movement         = move.stand
state_lib.states.prone_fire.movement         = move.stand
state_lib.states.prone_sniper_fire.movement  = move.stand
state_lib.states.prone_sniper_fire.direction = nil

state_mgr_animation_list.animations.prone.prop.moving      = nil
state_mgr_animation_list.animations.prone_idle.prop.moving = nil


return PATCH
