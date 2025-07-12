local TABLE = require "illish.lib.table"
local VEC   = require "illish.lib.vector"
local POS   = require "illish.lib.pos"
local RAY   = require "illish.lib.ray"

local SURGE = {}


-- CONSTANTS --
  SURGE.UNSAFE_MATERIALS = {
    ["materials\\fake"]         = true,
    ["materials\\bush"]         = true,
    ["materials\\cloth"]        = true,
    ["materials\\water"]        = true,
    ["materials\\bush_sux"]     = true,
    ["materials\\tree_trunk"]   = true,
    ["materials\\setka_rabica"] = true,
  }

  SURGE.SEARCH_AREAS = {
    camp_zone        = true,
    climable_object  = true,
    space_restrictor = true,
    smart_terrain    = true,
    level_door       = true,
  }

  SURGE.COVER_CACHE = nil
--


-- UTILS --
  function SURGE.isActive()
    return surge_manager.is_loaded() and surge_manager.is_started()
      or psi_storm_manager.is_loaded() and psi_storm_manager.is_started()
  end


  function SURGE.isDynamicCover(pos)
    local headPos = VEC.set(pos):add(0, 2, 0)
    local dist    = 64
    local score   = 0
    local __debug = {}

    local points = VEC.pointsAlongAxis({
        direction  = VEC.set(1, 0, 0),
        position   = headPos,
        arcAngle   = 360,
        rowSpacing = 0.3,
        spacing    = 1.2,
        radius     = 0.6,
        rows       = 2,
    })

    table.insert(points, headPos)

    for i, point in ipairs(points) do
      local dir = VEC.direction(pos, VEC.set(point):add(0, 1, 0))
      local ray = RAY.cast(point, dir, dist)

      ray:query()

      local result  = ray:get_result()
      local covered = result.range > 0 and not SURGE.UNSAFE_MATERIALS[result.material_name]

      if covered then
        score = score + 1 / #points
      end

      table.insert(__debug, {
        covered = covered,
        result  = result,
        pos     = point,
        dist    = dist,
        dir     = dir,
      })
    end

    return score > 0.8, score, __debug
  end


  function SURGE.buildCovers(force)
    if force or SURGE.COVER_CACHE and SURGE.COVER_CACHE.level ~= level.name() then
      SURGE.COVER_CACHE = nil
    end

    if SURGE.COVER_CACHE and SURGE.COVER_CACHE.areas then
      return SURGE.COVER_CACHE.areas
    end

    local sm = surge_manager.get_surge_manager()
    local objects = {}
    local areas   = {}

    alife():iterate_objects(function(obj)
      if obj.online and SURGE.SEARCH_AREAS[obj:section_name()] then
        table.insert(objects, {
          name   = obj:section_name(),
          pos    = obj.position,
          id     = obj.id,
          covers = nil,
        })
      end
    end)

    if SURGE.SEARCH_AREAS.level_door then
      for id, pos in pairs(db.level_doors) do
        table.insert(objects, {
          name   = "level_door",
          pos    = pos,
          id     = id,
          covers = nil,
        })
      end
    end

    for i, obj in ipairs(objects) do
      obj.covers = SURGE.nearbyCovers(obj.pos)
      if obj.covers then
        table.insert(areas, obj)
      end
    end

    SURGE.COVER_CACHE = {areas = areas, level = level.name()}
    return areas, objects
  end


  function SURGE.nearbyCovers(pos)
    local sm = surge_manager.get_surge_manager()
    local covers = {}

    local points = VEC.pointsAlongAxis({
      position   = pos,
      direction  = VEC.set(1, 0, 0),
      scatter    = {0.3, 0.3},
      arcAngle   = 360,
      radius     = 18,
      rows       = 5,
      rowSpacing = 6,
      spacing    = 6,
    })

    table.insert(points, pos)

    for i, point in ipairs(points) do
      local pos, vid = POS.snap(point)
      if vid ~= POS.INVALID_LVID and sm:pos_in_cover(pos) then
        table.insert(covers, vid)
      end
    end

    if #covers > 0 then
      return covers
    end
  end


  function SURGE.pickBestCover(npc)
    local pos   = npc:position()
    local areas = dup_table(SURGE.buildCovers())

    local actorArea = {
      name   = "actor",
      pos    = db.actor:position(),
      id     = db.actor:id(),
      covers = SURGE.nearbyCovers(db.actor:position()),
    }

    if actorArea.covers then
      table.insert(areas, actorArea)
    end

    table.sort(areas, function(a, b)
      local apos = POS.position(a.covers[1])
      local bpos = POS.position(b.covers[1])

      return VEC.distance(apos, pos) < VEC.distance(bpos, pos)
    end)

    for i, area in ipairs(areas) do
      for i, vid in ipairs(TABLE.shuffle(area.covers)) do
        local cpos = POS.position(vid)
        local cvid = POS.bestInsideUnoccupiedLVID(npc, cpos, cpos, 3)
        if POS.isValidLVID(npc, cvid) then
          return cvid
        end
      end
    end

    return POS.INVALID_LVID
  end
--


return SURGE
