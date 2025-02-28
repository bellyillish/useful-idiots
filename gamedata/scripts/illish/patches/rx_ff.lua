-- Shorten time NPCs are in friendly fire scheme
local PATCH_ff_eval = rx_ff.evaluator_dont_shoot.evaluate

function rx_ff.evaluator_dont_shoot:evaluate()
  local npc = self.object
  local st  = self.st

  -- Don't move immediately
  if not time_expired(st.__wait_until) then
    self.st.vertex_id = npc:level_vertex_id()
  end

  -- Shorten hold time
  if st.__hold_until and st.__hold_until > time_plus(500) then
    st.__hold_until = time_plus(500)
  end

  local eval = PATCH_ff_eval(self)

  -- Let custom combat types handle friendly fire
  local combat = db.storage[npc:id()].script_combat_type

  if combat == "assault" or combat == "guard" or combat == "snipe" or combat == "support" then
    return false
  end

  -- Shorten wait time
  if not eval then
    st.__wait_until = nil
  elseif not time_expired(st.__wait_until) then
    st.__wait_until = st.__wait_until or time_plus(1500)
  end

  return eval
end


-- Overwrite to shorten friend_dist
function rx_ff.evaluator_dont_shoot:check_in_los(ally, enemy, enemyPos)
  local npc = self.object
  local minDist = 0.8

  if not (ally and ally:alive() and npc:see(ally) and npc:relation(ally) < 2) then
    return false
  end

  local pos       = utils_obj.safe_bone_pos(npc, "bip01_r_finger02")
  local allyPos   = utils_obj.safe_bone_pos(ally, "bip01_spine")
  local enemyDist = pos:distance_to(enemyPos)
  local allyDist  = pos:distance_to(allyPos)

  if allyDist < minDist then
    return true
  end

  local enemyDir = vec_sub(enemyPos, pos):normalize()
  local allyDir  = vec_sub(allyPos, pos):normalize()
  local enemyVec = enemyDir:set_length(allyDist)
  local allyVec  = allyDir:set_length(allyDist)

  if allyVec:similar(enemyVec, 0) == 1 or allyVec:similar(enemyVec, 1) == 1 then
    return true
  end
end
