local UTIL  = require "illish.lib.util"
local TABLE = require "illish.lib.table"
local VEC   = require "illish.lib.vector"
local RAY   = require "illish.lib.ray"


local POS = {}


-- CONSTANTS --
  POS.INVALID_LVID = 4294967295

  POS.COVER = {0.3, 0.7, 0.9, 1.3, 1.5, 1.8}
  POS.COVER.SHOOT_LOW  = 0
  POS.COVER.PEEK_LOW   = POS.COVER[1]
  POS.COVER.SHOOT_MID  = POS.COVER[2]
  POS.COVER.PEEK_MID   = POS.COVER[3]
  POS.COVER.SHOOT_HIGH = POS.COVER[4]
  POS.COVER.PEEK_HIGH  = POS.COVER[5]
  POS.COVER.FULL       = POS.COVER[6]

  POS.AIM = {0.22, 0.94, 1.50}
  POS.AIM.LOW  = POS.AIM[1]
  POS.AIM.MID  = POS.AIM[2]
  POS.AIM.HIGH = POS.AIM[3]
--


-- CONVERT --
  function POS.lvid(pos)
    return level.vertex_id(pos) or 4294967295
  end


  function POS.position(vid)
    return VEC.set(level.vertex_position(vid))
  end


  function POS.snap(pos)
    local vid = POS.lvid(pos)
    local pos = POS.position(vid)
    return pos, vid
  end
--


-- CLAIM LVID --
  function POS.claimLVID(npc, vid)
    POS.unclaimLVID(npc)
    db.used_level_vertex_ids[vid] = npc:id()
  end


  function POS.unclaimLVID(npc, vid)
    local used = db.used_level_vertex_ids

    if vid and used[vid] == npc:id() then
      used[vid] = nil
      return
    end

    for v, id in pairs(used) do
      if id == npc:id() then
        used[v] = nil
      end
    end
  end


  function POS.setLVID(npc, vid)
    POS.clearLVID(npc)
    POS.claimLVID(npc, vid)
    npc:set_dest_level_vertex_id(vid)
  end


  function POS.clearLVID(npc)
    POS.unclaimLVID(npc)
    npc:set_desired_position()
    npc:set_desired_direction()
    npc:set_path_type(game_object.level_path)
    npc:set_detail_path_type(move.line)
  end
--


-- VALIDATE LVID --
  function POS.isValidLVID(npc, vid)
    return npc and vid
      and vid ~= POS.INVALID_LVID
      and npc:accessible(vid)
  end


  function POS.isUnclaimedLVID(npc, vid, space)
    space = space or 0.4

    if not POS.isValidLVID(npc, vid) then
      return false
    end

    if space > 0 then
      for v, id in pairs(db.used_level_vertex_ids) do
        if id ~= npc:id() then
          if v == vid or VEC.distance(POS.position(v), POS.position(vid)) < space then
            return false
          end
        end
      end
    end

    return true
  end


  function POS.isUnoccupiedLVID(npc, vid, space)
    local space = space or 0.8

    if not POS.isUnclaimedLVID(npc, vid, space) then
      return false
    end

    local pos = POS.position(vid)
    local unoccupied = true

    level.iterate_nearest(pos, space + 0.1, function(obj)
      if not IsStalker(obj) or obj:id() == npc:id() then
        return
      end

      local objPos = obj:position()
      local used = TABLE.keyof(db.used_level_vertex_ids, obj:id())

      if used and used ~= vid then
        objPos = POS.position(used)
      end

      if VEC.distance(pos, objPos) < space then
        unoccupied = false
        return true
      end
    end)

    return unoccupied
  end
--


-- GET LVID --
  function POS.bestOutsideLVID(npc, fromPos, pos, validator, spacing)
    spacing = spacing or 0.8

    local dirs      = 8
    local maxDist   = 8
    local baseAngle = 360 / dirs
    local baseDir   = VEC.direction(fromPos, pos)

    for dist = 0, maxDist, spacing do
      for i = 0, dirs - 1 do
        for f = -1, 1, 2 do
          local dir = VEC.rotate(baseDir, baseAngle * i * f)
          local vid = POS.lvid(VEC.offset(pos, dir, dist))

          if validator(npc, vid, spacing) then
            return vid
          end
        end
      end
    end

    return POS.INVALID_LVID
  end


  function POS.bestOutsideValidLVID(npc, fromPos, pos, spacing)
    return POS.bestOutsideLVID(npc, fromPos, pos, POS.isValidLVID, spacing)
  end


  function POS.bestOutsideUnclaimedLVID(npc, fromPos, pos, spacing)
    return POS.bestOutsideLVID(npc, fromPos, pos, POS.isUnclaimedLVID, spacing)
  end


  function POS.bestOutsideUnoccupiedLVID(npc, fromPos, pos, spacing)
    return POS.bestOutsideLVID(npc, fromPos, pos, POS.isUnoccupiedLVID, spacing)
  end


  function POS.bestInsideLVID(npc, fromPos, pos, validator, spacing)
    spacing = spacing or 1

    local castY    = 1.9
    local basePos  = VEC.set(fromPos):add(0, castY, 0)
    local baseDist = VEC.distance(basePos, pos)
    local baseDir  = VEC.direction(basePos, pos)
    baseDir.y = 0

    local castDist = RAY.distance(basePos, baseDir, baseDist)
    local dist = castDist

    while dist > 0 do
      local vid = POS.lvid(VEC.offset(basePos, baseDir, dist))

      if validator(npc, vid, spacing) then
        return vid
      end

      dist = dist - spacing
    end

    return POS.INVALID_LVID
  end


  function POS.bestInsideValidLVID(npc, fromPos, pos, spacing)
    return POS.bestInsideLVID(npc, fromPos, pos, POS.isValidLVID, spacing)
  end


  function POS.bestInsideUnclaimedLVID(npc, fromPos, pos, spacing)
    return POS.bestInsideLVID(npc, fromPos, pos, POS.isUnclaimedLVID, spacing)
  end


  function POS.bestInsideUnoccupiedLVID(npc, fromPos, pos, spacing)
    return POS.bestInsideLVID(npc, fromPos, pos, POS.isUnoccupiedLVID, spacing)
  end


  function POS.legacyLVID(npc, fromPos, pos, validator, spacing)
    spacing = spacing or 1

    local dist = VEC.distance(fromPos, pos)
    local dir  = VEC.direction(fromPos, pos)

    while dist > 0 do
      local vid = level.vertex_in_direction(POS.lvid(fromPos), dir, dist)

      if validator(npc, vid, spacing) then
        return vid
      end

      dist = dist - spacing
    end

    return POS.INVALID_LVID
  end


  function POS.legacyValidLVID(npc, fromPos, pos, spacing)
    return POS.legacyLVID(npc, fromPos, pos, POS.isValidLVID, spacing)
  end


  function POS.legacyUnclaimedLVID(npc, fromPos, pos, spacing)
    return POS.legacyLVID(npc, fromPos, pos, POS.isUnclaimedLVID, spacing)
  end


  function POS.legacyUnoccupiedLVID(npc, fromPos, pos, spacing)
    return POS.legacyLVID(npc, fromPos, pos, POS.isUnoccupiedLVID, spacing)
  end
--


-- POIs --
  function POS.nearbyCampfires(pos, radius)
    radius = radius or 32
    local fires = {}

    for id, binders in pairs(bind_campfire.campfires_all) do
      local dist = pos:distance_to(binders.object:position())

      if dist <= radius then
        fires[#fires + 1] = {
          id       = id,
          distance = dist,
          object   = binders.object,
          campfire = binders.campfire,
        }
      end
    end

    table.sort(fires, function(a, b)
      return a.distance < b.distance
    end)

    return fires
  end


  function POS.nearbyGrenades(pos, radius)
    radius = radius or 12
    local positions = {}
    local grenades  = {}

    level.iterate_nearest(pos, radius, function(thing)
      if IsGrenade(thing) and thing:name() == thing:section() then
        table.insert(positions, thing:position())
        table.insert(grenades, thing:id())
      end
    end)

    if #grenades > 0 then
      local avgPos = VEC.average(positions)
      return {
        avgPos   = avgPos,
        avgDir   = VEC.direction(pos, avgPos),
        avgDist  = VEC.distance(pos, avgPos),
        grenades = grenades,
      }
    end
  end


  function POS.assessSpace(pos, options)
    options = TABLE.merge({
      height    = 1.9,
      flags     = 15,
      distance  = 16,
      count     = 16,
      openDist  = 9.8,
      closeDist = 3.2,
    }, options)

    local castPos = VEC.set(pos):add(0, options.height, 0)
    local angle   = 360 / options.count
    local dir     = VEC.set(1, 0, 0)

    local distances = {}

    for i = 1, options.count do
      local castDir  = VEC.rotate(VEC.set(dir), -angle * (i - 1))
      local castDist = RAY.distance(castPos, castDir, options.distance, options.flags)
      distances[i]   = UTIL.round(castDist, 1)
    end

    table.sort(distances)
    local cullCount = UTIL.round(options.count / 10)

    for i = 1, cullCount do
      table.remove(distances, 1)
      table.remove(distances, #distances)
    end

    local avg = TABLE.average(distances)

    local type = avg >= options.openDist and "open"
      or avg >= options.closeDist and "enclosed"
      or "cramped"

    return type, avg
  end


  function POS.assessCover(coverPos, enemyPos, flags)
    local pos   = VEC.set(enemyPos):add(0, POS.AIM.HIGH, 0)
    local score = 0

    local __debug  = {}

    for index, height in ipairs(POS.COVER) do
      local epos = VEC.set(coverPos):add(0, height, 0)
      local dist = VEC.distance(pos, epos)
      local dir  = VEC.direction(pos, epos)
      local cast = RAY.distance(pos, dir, dist, flags)

      table.insert(__debug, {pos = pos, dir = dir, cast = cast})

      if math.floor(dist - cast) <= 0 then
        break
      end

      score = index
    end

    return score, __debug
  end


  function POS.sortByBestCover(vids, options)
    options = TABLE.merge({
      enemyPos = db.actor:position(),
      order    = nil,
    }, options)

    local scores = {}

    for i, vid in ipairs(vids) do
      local score = POS.assessCover(POS.position(vid), options.enemyPos)
      table.insert(scores, {score = score, vid = vid})
    end

    table.sort(scores, function(a, b)
      if options.order then
        local ia = TABLE.keyof(options.order, a.score)
        local ib = TABLE.keyof(options.order, b.score)

        if ia or ib then
          return (ib or #POS.COVER + 1) > (ia or #POS.COVER + 1)
        end
      end

      return b.score < a.score
    end)

    return scores
  end


  function POS.pickByBestCover(npc, points, options)
    options = TABLE.merge({
      findFn     = POS.bestOutsideUnclaimedLVID,
      enemyPos   = db.actor:position(),
      findFrom   = npc:position(),
      pickMethod = "random",
      minDist    = 0,
    }, options)

    local vids = {}

    for i, point in ipairs(points) do
      local vid = options.findFn(npc, options.findFrom, point)

      if POS.isValidLVID(npc, vid) and VEC.distance(POS.position(vid), options.enemyPos) >= options.minDist then
        table.insert(vids, vid)
      end
    end

    local all = POS.sortByBestCover(vids, {
      enemyPos = options.enemyPos,
      order    = options.order,
    })

    local best = TABLE.ipairscb(all, function(value)
      if value.score == all[1].score then
        return value
      end
    end)

    if not best then
      return
    end

    if options.pickMethod == "random" then
      best = TABLE.shuffle(best)
    end

    if options.pickMethod == "farthest" then
      best = TABLE.reverse(best)
    end

    return best[1]
  end


  function POS.getStrafePos(npc, options)
    options = TABLE.merge({
      findFn   = POS.legacyUnclaimedLVID,
      enemyPos = db.actor:position(),
      findFrom = npc:position(),
      range    = 10,
      distance = 8,
      spacing  = 1,
    }, options)

    local enemyDir = VEC.direction(options.findFrom, options.enemyPos)

    local dir1   = vec_rot(enemyDir, -90 + UTIL.randomRange(10))
    local dir2   = vec_rot(enemyDir,  90 + UTIL.randomRange(10))
    local pos1   = vec_offset(options.findFrom, dir1, options.distance)
    local pos2   = vec_offset(options.findFrom, dir2, options.distance)
    local vid1   = options.findFn(npc, options.findFrom, pos1, options.spacing)
    local vid2   = options.findFn(npc, options.findFrom, pos2, options.spacing)
    local valid1 = POS.isValidLVID(npc, vid1)
    local valid2 = POS.isValidLVID(npc, vid2)

    if not (valid1 or valid2) then
      return POS.INVALID_LVID
    end

    if not (valid1 and valid2) then
      return valid1 and vid1 or vid2
    end

    return vec_dist(options.findFrom, lvpos(vid2)) > vec_dist(options.findFrom, lvpos(vid1))
      and vid2
      or  vid1
  end


  function POS.legacySafeCover(npc, options)
    options = TABLE.merge({
      findFn   = POS.bestOutsideUnoccupiedLVID,
      findFrom = npc:position(),
      position = npc:position(),
      radius   = 32,
      distance = 1,
      spacing  = 1,
    }, options)

    local cover = npc:safe_cover(options.position, options.radius, options.distance)

    if not cover then
      return POS.INVALID_LVID
    end

    return options.findFn(npc, options.findFrom, cover:position(), options.spacing)
  end


  function POS.legacyBestCover(npc, options)
    options = TABLE.merge({
      findFn   = POS.bestOutsideUnoccupiedLVID,
      enemyPos = db.actor:position(),
      findFrom = npc:position(),
      spacing  = 1,
    }, options)

    local cover = npc:find_best_cover(options.enemyPos)

    if not cover then
      return POS.INVALID_LVID
    end

    return options.findFn(npc, options.findFrom, cover:position(), options.spacing)
  end


  function POS.legacyCover(npc, options)
    options = TABLE.merge({
      findFn       = POS.bestOutsideUnoccupiedLVID,
      enemyPos     = db.actor:position(),
      findFrom     = npc:position(),
      position     = npc:position(),
      radius       = 8,
      maxRadius    = 32,
      spacing      = 1,
      minEnemyDist = 1,
      maxEnemyDist = 128,
    }, options)

    local radius = options.radius

    while true do
      local cover = npc:best_cover(options.position, options.enemyPos, radius, options.minEnemyDist, options.maxEnemyDist)

      if cover then
        return options.findFn(npc, options.findFrom, cover:position(), options.spacing)
      end
      if radius >= options.maxRadius then
        break
      end

      radius = math.min(radius + math.min(options.radius, 4), options.maxRadius)
    end

    return POS.INVALID_LVID
  end
--


return POS
