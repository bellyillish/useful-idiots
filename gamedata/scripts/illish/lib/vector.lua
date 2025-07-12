local UTIL  = require "illish.lib.util"
local TABLE = require "illish.lib.table"


local VEC = {}


function VEC.set(...)
  return vector():set(...)
end


function VEC.direction(a, b)
  return VEC.set(b):sub(a):normalize()
end


function VEC.distance(a, b)
  return a:distance_to(b)
end


function VEC.offset(point, dir, dist)
  return VEC.set(point):add(
    VEC.set(dir):normalize():mul(dist)
  )
end


function VEC.dotProduct(a, b)
  return VEC.set(a):dotproduct(b)
end


function VEC.average(points)
  local total = VEC.set(0, 0, 0)

  for i, point in ipairs(points) do
    total:add(point)
  end

  return total:div(#points)
end


function VEC.rotate(point, angle)
  return vector_rotate_y(point, angle)
end


function VEC.rotateRandom(point, angle1, angle2, prec, weight)
  point  = point  or VEC.set(1, 0, 0)
  angle1 = angle1 or 180

  if type(angle1) == "table" then
    weight = prec
    prec   = angle2
    angle2 = angle1[2]
    angle1 = angle1[1]
  end

  return VEC.rotate(point, UTIL.random(angle1, angle2, prec, weight))
end


function VEC.rotateRange(point, angle, prec, weight)
  angle = angle or 180
  return VEC.rotateRandom(point, -angle, angle, prec, weight)
end


function VEC.pointsAlongAxis(options)
  options = TABLE.merge({
    position   = db.actor:position(),
    direction  = db.actor:direction(),
    scatter    = {0, 0},
    arcAngle   = 180,
    arcLength  = nil,
    rowSpacing = nil,
    radius     = 16,
    spacing    = 4,
    rows       = 1,
  }, options)

  local basePos, baseDir, spacing =
    options.position,
    options.direction,
    options.spacing

  local rowSpacing = options.rowSpacing
    or spacing

  local points = {}

  for r = 0, options.rows / 2 do
    for rf = 1, (r == 0 and 1 or -1), -2 do
      if rf == -1 and (2 * r + 1) > options.rows then
        break
      end

      local radius = options.radius + (rowSpacing * r * rf)

      local arcAngle = options.arcLength
        and math.deg(options.arcLength / radius)
        or  options.arcAngle

      local arcLength = options.arcLength
        or math.rad(arcAngle) * radius

      local count = math.floor(arcLength / options.spacing)

      if count % 2 == 1 then
        count = count + 1
      end

      local angle = arcAngle % 360 == 0
        and arcAngle / (count + 1)
        or  arcAngle / count

      local bdir = r % 2 == 0
        and VEC.rotate(baseDir, angle * -0.25)
        or  VEC.rotate(baseDir, angle * 0.25)

      local rad = options.rows % 2 == 0
        and radius - rowSpacing / 2
        or  radius

      for i = 0, count / 2 do
        for f = -1, (i == 0 and -1 or 1), 2 do
          local ascatter = UTIL.randomRange(angle   * options.scatter[1], 1)
          local rscatter = UTIL.randomRange(spacing * options.scatter[2], 1)

          local dir = VEC.rotate(bdir, angle * i * f + ascatter)
          points[#points + 1] = VEC.offset(basePos, dir, rad + rscatter)
        end
      end
    end
  end

  return points
end


function VEC.serialize(point)
  return type(point) == "userdata" and point.x and point.y and point.z
    and  {x = point.x, y = point.y, z = point.z}
    or   point
end


function VEC.unserialize(point)
  return point and point.x and point.y and point.z
    and  VEC.set(point.x, point.y, point.z)
    or   point
end


return VEC
