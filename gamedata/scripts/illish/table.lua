local TABLE = {}


function TABLE.merge(...)
  local args   = {...}
  local result = {}

  for _, arg in ipairs(args) do
    for key, value in pairs(arg) do
      result[key] = value
    end
  end

  return result
end


function TABLE.imerge(...)
  local args   = {...}
  local result = {}

  for _, arg in ipairs(args) do
    for _, value in ipairs(arg) do
      result[#result + 1] = value
    end
  end

  return result
end


function TABLE.pairscb(tbl, cb)
  local results

  for key, value in pairs(tbl) do
    local rkey, rvalue = cb(key, value, tbl)
    if rkey ~= nil and rvalue ~= nil then
      if not results then
        results = {}
      end
      results[rkey] = rvalue
    end
  end

  return results
end


function TABLE.ipairscb(tbl, cb)
  local results

  for index, value in ipairs(tbl) do
    local rvalue = cb(value, index, tbl)
    if rvalue then
      if not results then
        results = {}
      end
      table.insert(results, rvalue)
    end
  end

  return results
end


function TABLE.keyof(tbl, value)
  for k, v in pairs(tbl) do
    if v == value or type(value) == "function" and value(v) then
      return k
    end
  end
end


function TABLE.reverse(tbl)
  local result = {}

  for i, v in ipairs(tbl) do
    result[#tbl + 1 - i] = v
  end

  return result
end


return TABLE
