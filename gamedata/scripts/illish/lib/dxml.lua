local TABLE = require "illish.lib.table"


local NO_EXTEND = {
  extendXMLObject = true,
  mergeBounds     = true,
}

local DXML = {}


-- utils --
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

    if not (attrs.x or tonumber(attrs.width)) then
      return
    end

    local width = tonumber(attrs.width) and attrs.width * ratio
    local x = attrs.x

    local xalign = el.parent and XML:getElementAttr(el.parent).xalign
    local parent = el.parent and XML:getElementName(el.parent)

    if parent == "w" and xalign == "c" and x and width then
      x = x + (attrs.width - width) / 2
    elseif parent == "w" and xalign == "r" and x and width then
      x = x + (attrs.width - width)
    elseif x and width then
      x = x * ratio
    end

    XML:setElementAttr(el, {x = x, width = width})
  end


  function DXML.scaleElement(XML, el, xscale, yscale)
    xscale = (xscale or 1) * math.min(1080 / device().height, 1)
    yscale = (yscale or 1) * math.min(1080 / device().height, 1)

    local attrs = XML:getElementAttr(el)

    if not (attrs.x or attrs.y or attrs.width or attrs.height) then
      return
    end

    local width  = tonumber(attrs.width)  and attrs.width  * xscale
    local height = tonumber(attrs.height) and attrs.height * yscale
    local x, y   = attrs.x, attrs.y

    local xalign = el.parent and XML:getElementAttr(el.parent).xalign
    local yalign = el.parent and XML:getElementAttr(el.parent).yalign
    local parent = el.parent and XML:getElementName(el.parent)

    if parent == "w" and xalign == "c" and x and width then
      x = x + (attrs.width - width) / 2
    elseif parent == "w" and xalign == "r" and x and width then
      x = x + (attrs.width - width)
    elseif x and width then
      x = x * xscale
    end

    if parent == "w" and yalign == "c" and y and height then
      y = y + (attrs.height - height) / 2
    elseif parent == "w" and yalign == "b" and y and height then
      y = y + (attrs.height - height)
    elseif y and height then
      y = y * yscale
    end

    XML:setElementAttr(el, {width = width, height = height, x = x, y = y})
  end


  function DXML.fixAndScaleAll(XML, el, xscale, yscale)
    DXML.iterateElements(XML, el, function(child)
      DXML.fixAndScaleAll(XML, child, xscale, yscale)
    end)

    if XML:getRoot() ~= el then
      if DXML.getNearestAttr(XML, el, "compact") == "1" then
        xscale = math.min(xscale, yscale)
        yscale = xscale
      end

      DXML.fixAspectRatio(XML, el)
      DXML.scaleElement(XML, el, xscale, yscale)
    end
  end


  function DXML.mergeBounds(...)
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


  function DXML.getElementBounds(XML, el)
    local attrs = XML:getElementAttr(el)

    local x, y, w, h =
      attrs.x      or 0,
      attrs.y      or 0,
      tonumber(attrs.width)  or 0,
      tonumber(attrs.height) or 0

    return {
      l = x, t = y,
      w = w, h = h,
      r = x + w,
      b = y + h,
    }
  end


  function DXML.getChildrenBounds(XML, el)
    local bounds

    DXML.iterateElements(XML, el, function(child)
      local b = DXML.getElementBounds(XML, child)

      if not bounds then
        bounds = b
      else
        bounds = DXML.mergeBounds(bounds, b)
      end
    end)

    return bounds
  end


  function DXML.getNearestAttr(XML, el, attr, default)
    while DXML.isValid(XML, el) do
      if el.el == "!doc" then
        break
      end

      local value = XML:getElementAttr(el)[attr]
      if value ~= nil then
        return value
      end

      el = el.parent
    end

    return default
  end


  function DXML.renameElement(XML, el, name)
    local renamed = XML:convertElement({
      attr = XML:getElementAttr(el),
      name = name,
    })

    el.el = renamed.el
  end


  function DXML.wrapChildren(XML, el, wrapper)
    wrapper.parent = el
    wrapper.kids   = el.kids

    el.kids = {wrapper}

    for i, kid in ipairs(wrapper.kids) do
      kid.parent = wrapper
    end
  end


  function DXML.wrapElement(XML, el, wrapper)
    local index  = XML:getElementPosition(el)
    local parent = el.parent
    local kids   = el.kids

    parent.kids[index] = wrapper

    wrapper.parent = parent
    wrapper.kids   = {el}

    el.parent = wrapper
  end


  function DXML.unwrapElement(XML, el)
    if not (el.kids and #el.kids > 0) then
      XML:removeElement(el)
      return
    end

    local index  = XML:getElementPosition(el)
    local before = {}
    local after  = {}

    if not index then
      return
    end

    if index > 1 then
      before = {unpack(el.parent.kids, 1, index - 1)}
    end
    if index < #el.parent.kids then
      after = {unpack(el.parent.kids, index + 1, #el.parent.kids)}
    end

    el.parent.kids = TABLE.imerge(before, el.kids, after)

    for i, kid in ipairs(el.parent.kids) do
      kid.parent = el.parent
    end
  end


  function DXML.extendXMLObject(XML)
    if XML.extended then
      return
    end

    XML.extended = true

    for name, fn in pairs(DXML) do
      if not NO_EXTEND[name] then
        XML[name] = fn
      end
    end

    -- bug fix
    local insert = XML.insertElement

    function XML:insertElement(args, where, pos)
      local el, pos = insert(self, args, where, pos)
      el.parent = where
      return el, pos
    end
  end
--


return DXML
