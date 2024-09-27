local TABLE = require "illish.table"


local function mergeBounds(...)
  local bounds

  for i, b in ipairs({...}) do
    if not bounds then
      bounds = dup_table(b)
    else
      bounds = {
        l = math.min(bounds.l, b.l),
        t = math.min(bounds.t, b.t),
        r = math.max(bounds.r, b.r),
        b = math.max(bounds.b, b.b),
      }
    end
  end

  bounds.w = bounds.r - bounds.l
  bounds.h = bounds.b - bounds.t

  return bounds
end


local DXML = {}


function DXML.isValid(XML, el)
  return el and el.el and XML:isElement(el)
end


function DXML.queryOne(XML, query, where)
  local results = XML:query(query, where)

  if results and DXML.isValid(XML, results[1]) then
    return results[1]
  end
end


function DXML.iterateElements(XML, el, cb)
  local results

  XML:iterateChildren(el, function(child, index)
    if not DXML.isValid(XML, child) then
      return
    end

    local result = cb(child, index)

    if result then
      if not results then
        results = {}
      end

      table.insert(results, result)
    end
  end)

  return results
end


function DXML.fixAspectRatio(XML, el)
  local ratio = 1024 / 768 * device().height / device().width
  local attrs = XML:getElementAttr(el)

  if not (attrs.x or attrs.width) then
    return
  end

  XML:setElementAttr(el, {
    x     = attrs.x     and attrs.x * ratio,
    width = attrs.width and attrs.width * ratio,
  })
end


function DXML.scaleElement(XML, el, xscale, yscale)
  xscale = (xscale or 1) * math.min(1080 / device().height, 1)
  yscale = (yscale or 1) * math.min(1080 / device().height, 1)

  local attrs = XML:getElementAttr(el)

  if not (attrs.x or attrs.y or attrs.width or attrs.height) then
    return
  end

  XML:setElementAttr(el, {
    x      = attrs.x      and attrs.x * xscale,
    y      = attrs.y      and attrs.y * yscale,
    width  = attrs.width  and attrs.width  * xscale,
    height = attrs.height and attrs.height * yscale,
  })
end


function DXML.fixAndScaleAll(XML, el, xscale, yscale)
  local attrs = XML:getElementAttr(el)

  DXML.iterateElements(XML, el, function(child)
    DXML.fixAndScaleAll(XML, child, xscale, yscale)
  end)

  DXML.fixAspectRatio(XML, el)
  DXML.scaleElement(XML, el, xscale, yscale)
end


function DXML.getElementBounds(XML, el)
  local attrs = XML:getElementAttr(el)

  local x = attrs.x      or 0
  local y = attrs.y      or 0
  local w = attrs.width  or 0
  local h = attrs.height or 0

  return {
    t = y,
    l = x,
    r = x + w,
    b = y + h,
    w = w,
    h = h,
  }
end


function DXML.getChildBounds(XML, el)
  local bounds

  DXML.iterateElements(XML, el, function(child)
    local b = DXML.getElementBounds(XML, child)
    bounds = bounds and mergeBounds(bounds, b) or b
  end)

  return bounds
end


function DXML.getAttrWithInherit(XML, el, inheritable)
  local current = el.parent
  local inherit = {XML:getElementAttr(el)}

  while current do
    local name  = XML:getElementName(current)
    local attrs = {}

    if not name or name == "w" then
      break
    end

    if not inheritable then
      attrs = XML:getElementAttr(current)

    else
      for source, target in pairs(inheritable) do
        if type(source) == "number" then
          source = target
        end
        attrs[target] = XML:getElementAttr(current)[source]
      end
    end

    inherit[#inherit + 1] = attrs
    current = current.parent
  end

  inherit = TABLE.merge(
    unpack(TABLE.reverse(inherit))
  )

  return inherit
end


function DXML.extendXMLObject(XML)
  if XML.extended then
    return
  end

  XML.extended = true

  for name, fn in pairs(DXML) do
    if name ~= "extendXMLObject" then
      XML[name] = fn
    end
  end
end


return DXML
