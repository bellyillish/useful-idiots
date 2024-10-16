local UTIL = {}


-- MATH --
function UTIL.round(val, prec)
  local e = 10 ^ (prec or 0)
  return math.floor(val * e + 0.5) / e
end


function UTIL.random(min, max, prec, weight)
  min, max, prec, weight = min or 0, max or 1, prec or 0, weight or 1
  local n = 0

  for i = 0, weight - 1 do
    n = n + math.random() / weight
  end

  return UTIL.round(min + n * (max - min), prec)
end


function UTIL.randomRange(mag, prec, weight)
  return UTIL.random(-mag, mag, prec, weight)
end


function UTIL.randomChance(percent)
  return UTIL.random(1, 100) <= percent
end


-- FUNC --
function UTIL.throttle(fn, ms1, ms2)
  local lastRun = 0
  local delay   = 0
  local result  = nil

  return function(...)
    local time = time_global()
    if lastRun + delay <= time then
      delay   = math.random(ms1, ms2 or ms1)
      lastRun = time
      result  = fn(...)
    end

    return result
  end
end


function UTIL.debounce(fn, ms, id, ...)
  local evid = "UTIL.debounce"
  local args = {...}

  if #args > 0 then
    id = id:format(...)
  end

  RemoveTimeEvent(evid, id)

  CreateTimeEvent(evid, id, ms / 1000, function()
    RemoveTimeEvent(evid, id)
    fn()
  end)
end


-- TIME --
function UTIL.timePlus(ms)
  return time_global() + (ms or 0)
end


function UTIL.timePlusRandom(ms1, ms2, weight)
  if type(ms1) == "table" then
    weight = ms2
    ms2 = ms1[2]
    ms1 = ms1[1]
  end

  return UTIL.timePlus(UTIL.random(ms1, ms2, 0, weight))
end


function UTIL.timeExpired(time)
  return time and time <= time_global() or false
end


function UTIL.timeLeft(time)
  return math.max((time or 0) - time_global(), 0)
end


return UTIL
