local SRS = surge_rush_scheme_common

-- Patches "NPCs Die in Emissions for Real" with animation fixes to prevent NPCs
-- from getting stuck waiting out surges

function initialize(self)
  action_base.initialize(self)
  local npc = self.object

  npc:set_desired_position()
  npc:set_desired_direction()
  npc:set_detail_path_type(move.line)
  npc:set_path_type(game_object.level_path)

  local params = SRS.get_cover_params(npc)
  npc:set_dest_level_vertex_id(params.lvid)
end


function execute(self)
  action_base.execute(self)

  local npc    = self.object
  local params = SRS.get_cover_params(npc)
  local state  = "hide"

  if npc:level_vertex_id() ~= params.lvid then
    state = IsWeapon(npc:active_item()) and "sprint" or "panic"
  else
    params.reached = true
  end

  state_mgr.set_state(npc, state, nil, nil, nil, {fast_set = true})
end


function finalize(self)
  action_base.finalize(self)
  local npc = self.object

  if not SRS.surge_started() then
    SRS.reset_cover_params(npc)
  end
end


-- Outside scheme
if SRS and surge_rush_scheme_evaluator_outside then
  surge_rush_scheme_evaluator_outside.action_stalker_surge_rush_outside.initialize = initialize
  surge_rush_scheme_evaluator_outside.action_stalker_surge_rush_outside.execute    = execute
  surge_rush_scheme_evaluator_outside.action_stalker_surge_rush_outside.finalize   = finalize
end

-- Inside scheme (they both do the same thing)
if SRS and surge_rush_scheme_evaluator_inside then
  surge_rush_scheme_evaluator_inside.action_stalker_surge_rush_inside.initialize = initialize
  surge_rush_scheme_evaluator_inside.action_stalker_surge_rush_inside.execute    = execute
  surge_rush_scheme_evaluator_inside.action_stalker_surge_rush_inside.finalize   = finalize
end
