local PATCH = {}


-- Creatures (especially mutants) have inconsistent bone IDs for head and spine
-- which trigger errors when safe_bone_pos() is called. This uses pattern
-- matching on the passed ID to help return the correct position.
PATCH.BONE_ALIASES = {
  spine = {"spine", "spine_1", "bip01_spine", "bip01_spine1"},
  head  = {"head", "head_boss", "bip01_head"},
}


function utils_obj.safe_bone_pos(obj, bone)
  -- no patch needed
  if obj:get_bone_id(bone) ~= 65535 then
    return obj:bone_position(bone)
  end

  -- try to match head or spine
  for match, aliases in pairs(PATCH.BONE_ALIASES) do
    if bone:find(match) then
      for i, alias in ipairs(aliases) do
        if obj:get_bone_id(alias) ~= 65535 then
          return obj:bone_position(alias)
        end
      end
    end
  end

  -- fallback to generic position
  return vec(obj:position()):add(0, 0.5, 0)
end


--[[ TODO: refactor to better randomize direction
  -- (they currently favor one side too much)
  function utils_obj.try_go_aside_object(npc, friend, pos, old_vid)
    if not (friend) then
      return
    end

    local mypos = npc:position()

    if (mypos:distance_to_sqr(friend:position()) < 3) then
      return
    end

    local _dir = vec_sub(mypos,pos)
    local dir = {}
    dir[1] = vector_rotate_y(vec_set(_dir),-90)
    dir[2] = vector_rotate_y(vec_set(_dir),90)
    local vid
    local radius = 12
    local base_point = friend:level_vertex_id()

    for i=1,2 do
      while (radius > 0) do
        vid = level.vertex_in_direction(base_point,dir[i],radius)
        if (utils_obj.validate(npc,vid)) then
          return utils_obj.lmove(npc,vid,old_vid)
        end
        radius = radius - 2
      end
    end
  end


  function utils_obj.try_to_strafe(npc, old_vid)
    local _dir = npc:direction()
    local dir = {}
    dir[1] = vector_rotate_y(vec_set(_dir),-90)
    dir[2] = vector_rotate_y(vec_set(_dir),90)
    local vid
    local radius = 10
    local base_point = npc:level_vertex_id()

    for i=1,2 do
      while (radius > 0) do
        vid = level.vertex_in_direction(base_point,dir[i],radius)
        if (utils_obj.validate(npc,vid)) then
          return utils_obj.lmove(npc,vid,old_vid)
        end
        radius = radius - 2
      end
    end
  end
--]]


return PATCH
