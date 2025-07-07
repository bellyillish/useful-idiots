local TABLE = require "illish.lib.table"
local UTIL  = require "illish.lib.util"
local VEC   = require "illish.lib.vector"
local POS   = require "illish.lib.pos"
local NPC   = require "illish.lib.npc"


local BEH = {}


-- CONSTS --
  BEH.ANIMATIONS = {
    guard = {
      guard                 = {6, 0},
      guard_na              = {4, 0},
      guard_chasovoy        = {2, 30000},
      binocular             = {2, 30000},
      ward                  = {1, 60000},
      animpoint_stay_ohrana = {1, 60000},
      smoking_stand         = {3, 60000},
      wait                  = {2, 120000},
      wait_na               = {2, 120000},
      fold_arms             = {1, 120000},
    },
    hide = {
      hide           = {8, 0},
      sit_ass_weapon = {1, 120000},
    },
    sit_ass = {
      animpoint_sit_ass              = {4, 0},
      animpoint_sit_ass_use_pda      = {2, 0},
      animpoint_sit_ass_smoking_sit  = {2, 0},
      animpoint_sit_ass_drink_vodka  = {2, 30000},
      animpoint_sit_ass_eat_bread    = {1, 30000},
      animpoint_sit_ass_eat_kolbasa  = {1, 30000},
      animpoint_sit_ass_drink_energy = {1, 30000},
      animpoint_sit_ass_sleep        = {2, 120000},
    },
    sit_knee = {
      animpoint_sit_ass               = {4, 0},
      animpoint_sit_knee_drink_vodka  = {2, 30000},
      animpoint_sit_knee_eat_bread    = {1, 30000},
      animpoint_sit_knee_eat_kolbasa  = {1, 30000},
      animpoint_sit_knee_drink_energy = {1, 30000},
      animpoint_sit_knee_sleep        = {2, 120000},
    },
  }

  BEH.RELOAD_ANIMATIONS = {
    guard   = "guard_fire",
    patrol  = "patrol_fire",
    assault = "assault_fire",
    threat  = "threat_fire",
    sneak   = "sneak_fire",
    raid    = "raid_fire",
    hide    = "hide_fire",
  }
--


-- UTILS --
  function BEH.getActorMovement(self)
    local npc = self.object
    local st  = self.st

    local pos, savedActorPos =
      st.savedTarget.position,
      st.savedTarget.actorPos

    if not (pos and savedActorPos) then
      return 0
    end

    local actorPos = db.actor:position()
    local actorDir = VEC.direction(pos, actorPos)
    local moveDir  = VEC.direction(savedActorPos, actorPos)
    local moveDist = VEC.distance(savedActorPos, actorPos)

    if VEC.dotProduct(actorDir, moveDir) < 0 then
      moveDist = -moveDist
    end

    return moveDist
  end


  function BEH.getFormation(npc, options)
    local index = NPC.indexOfFollower(npc)

    if not index then
      return
    end

    options = TABLE.merge({
      findFn   = POS.bestInsideUnclaimedLVID,
      findFrom = db.actor:position(),
      position = db.actor:position(),
      spacing  = {1, 1},
      noise    = {0, 0},
      distance = 4,
      columns  = 1,
    }, options)

    local position, distance, columns, spacing, noise =
      options.position,
      options.distance,
      options.columns,
      options.spacing,
      options.noise

    local followers = NPC.getFollowers()
    local avgPos    = NPC.getAvgPosition(followers)
    local avgDir    = VEC.direction(position, avgPos)
    local crossDir  = VEC.rotate(avgDir, 90)

    columns = math.min(columns, #followers)
    index   = index - 1

    local offset = distance + spacing[1] * math.floor(index / columns)
          offset = offset + UTIL.randomRange(noise[1], 1)

    local crossOffset = spacing[2] * math.ceil(index % columns / 2)
          crossOffset = crossOffset * (index % 2 == 1 and -1 or 1)
          crossOffset = crossOffset + UTIL.randomRange(noise[2], 1)

    if columns % 2 == 0 then
      crossOffset = crossOffset + spacing[2] / 2
    end

    local rawPos = VEC.offset(position, avgDir, offset)
          rawPos = VEC.offset(rawPos, crossDir, crossOffset)

    return {
      vid    = options.findFn(npc, options.findFrom, rawPos),
      rawPos = rawPos,
      avgPos = avgPos,
      avgDir = avgDir,
    }
  end


  function BEH.getBunchFormation(npc, dist, findFn)
    local followers = NPC.getFollowers()
    local spacing   = math.max(2, 4.4 - 0.2 * #followers)

    local formation = BEH.getFormation(npc, {
      columns  = math.max(2, UTIL.round(math.sqrt(#followers))),
      spacing  = {spacing, spacing},
      noise    = {0.6, 0.6},
      findFn   = findFn,
      distance = dist,
    })

    return formation and POS.isValidLVID(npc, formation.vid)
      and formation.vid
      or  POS.INVALID_LVID
  end


  function BEH.getLineFormation(npc, dist, findFn)
    local followers = NPC.getFollowers()
    local spacing   = math.max(1.8, 3.8 - 0.2 * #followers)

    local formation = BEH.getFormation(npc, {
      spacing  = {spacing, spacing},
      noise    = {0, 0.4},
      findFn   = findFn,
      distance = dist,
    })

    return formation and POS.isValidLVID(npc, formation.vid)
      and formation.vid
      or  POS.INVALID_LVID
  end


  function BEH.getSpreadFormation(npc, dist, findFn)
    local followers = NPC.getFollowers()
    local spacing   = math.max(2, 7 - 0.5 * #followers)

    local formation = BEH.getFormation(npc, {
      spacing  = {spacing, spacing},
      columns  = #followers,
      noise    = {0.4, 0},
      findFn   = findFn,
      distance = dist,
    })

    return formation and POS.isValidLVID(npc, formation.vid)
      and formation.vid
      or  POS.INVALID_LVID
  end


  function BEH.getCoverFormation(npc, dist, findFn)
    local followers = NPC.getFollowers()
    local spacing   = math.max(3.2, 9.2 - 0.6 * #followers)

    local formation = BEH.getFormation(npc, {
      spacing  = {spacing, spacing},
      columns  = #followers,
      findFn   = findFn,
      distance = dist,
    })

    if not formation then
      return POS.INVALID_LVID
    end

    local vid = POS.legacyCover(npc, {
      enemyPos  = VEC.offset(db.actor:position(), formation.avgDir:invert(), 32),
      position  = formation.rawPos,
      radius    = 2,
    })

    return POS.isValidLVID(npc, vid)
      and vid
      or  formation.vid
  end


  function BEH.saveStorage(id, beh)
    local st = db.storage[id].beh
    local dt = st and st.desired_target

    if not (st and beh) then
      return
    end

    beh[id] = {target = st.target, keepType = st.keepType}

    if not dt then
      return
    end

    beh[id].desired_target = {
      direction       = VEC.serialize(dt.direction),
      position        = VEC.serialize(dt.position),
      actorPos        = VEC.serialize(dt.actorPos),
      level_vertex_id = dt.level_vertex_id,
      followCount     = dt.followCount,
      formation       = dt.formation,
      expires         = dt.expires,
    }
  end


  function BEH.loadStorage(id, beh)
    local st = db.storage[id].beh

    if not (st and beh and beh[id]) then
      return
    end

    if beh[id].target then
      st.target = beh[id].target
    end

    if beh[id].keepType then
      st.keepType = beh[id].keepType
    end

    if not beh[id].desired_target then
      return
    end

    if not st.desired_target then
      st.desired_target = {}
    end

    if beh[id].desired_target.level_vertex_id then
      st.desired_target.level_vertex_id = beh[id].desired_target.level_vertex_id
    end

    if beh[id].desired_target.expires then
      st.desired_target.expires = beh[id].desired_target.expires
    end

    if beh[id].desired_target.position then
      st.desired_target.position = VEC.unserialize(beh[id].desired_target.position)
    end

    if beh[id].desired_target.direction then
      st.desired_target.direction = VEC.unserialize(beh[id].desired_target.direction)
    end

    if beh[id].desired_target.actorPos then
      st.desired_target.actorPos = VEC.unserialize(beh[id].desired_target.actorPos)
    end

    if beh[id].desired_target.followCount then
      st.desired_target.followCount = beh[id].desired_target.followCount
    end

    if beh[id].desired_target.formation then
      st.desired_target.formation = beh[id].desired_target.formation
    end
  end
--


-- UTILS: RELAX --
  function BEH.findCampfireSpot(npc, pos, radius)
    local campfires = POS.nearbyCampfires(pos, radius)

    for _, campfire in ipairs(campfires) do
      local distance  = 1.8
      local increment = 72
      local angle     = 0

      while angle < 360 do
        local rads    = math.rad(angle)
        local firePos = campfire.object:position()
        local offset  = VEC.set(math.cos(rads), 0, math.sin(rads)):mul(distance)
        local spotPos = VEC.set(firePos):add(offset)
        local dir     = VEC.direction(spotPos, firePos)
        local vid     = POS.lvid(spotPos)

        if POS.isUnoccupiedLVID(npc, vid) then
          return {
            campfire = campfire,
            firePos  = firePos,
            spotPos  = spotPos,
            vid      = vid,
            dir      = dir,
          }
        end

        angle = angle + increment
      end
    end
  end


  function BEH.findRandomRelaxSpot(npc, pos, radius)
    radius = radius or 16
    local enemyPos = VEC.offset(pos, VEC.rotateRange(), 32)

    local vid = POS.legacyCover(npc, {
      enemyPos = enemyPos,
      radius   = radius,
      position = pos,
      spacing  = 3,
    })

    local dir = POS.isValidLVID(npc, vid)
      and VEC.direction(enemyPos, POS.position(vid))
      or  VEC.direction(enemyPos, pos)

    return {
      enemyPos = enemyPos,
      vid      = vid,
      dir      = dir,
    }
  end
--


-- UTILS: PATROL --
  BEH.WAYPOINT_DELAY = 8000


  function BEH.getWaypoint(npc, index)
    if type(npc) == "number" then
      npc = NPC.getCompanion(npc)
    end

    if (npc and index) then
      return se_load_var(npc:id(), npc:name(), "pathpoint" .. index)
    end
  end


  function BEH.getAllWaypoints(npc)
    if type(npc) == "number" then
      npc = NPC.getCompanion(npc)
    end

    if not npc then
      return
    end

    local waypoints = {}
    local index = 1
    local waypoint

    repeat
      waypoint = BEH.getWaypoint(npc, index)
      if waypoint then
        waypoints[#waypoints + 1] = waypoint
        index = index + 1
      end
    until waypoint == nil

    return waypoints
  end


  function BEH.addWaypoint(npc, pos)
    if type(npc) == "number" then
      npc = NPC.getCompanion(npc)
    end

    if not (npc and pos) then
      return
    end

    local x, y, z = pos.x, pos.y, pos.z
    local index   = #BEH.getAllWaypoints(npc) + 1
    local delay   = BEH.WAYPOINT_DELAY

    local waypoint = string.format("%s,patrol | pos:%s,%s,%s", delay, x, y, z)
    se_save_var(npc:id(), npc:name(), "pathpoint" ..index, waypoint)

    return index
  end


  function BEH.clearWaypoints(npc)
    if type(npc) == "number" then
      npc = NPC.getCompanion(npc)
    end

    if not npc then
      return
    end

    if NPC.getState(npc, "movement", "patrol") then
      NPC.setState(npc, "movement", NPC.getActiveState(nil, "movement"), true)
    end

    for index in ipairs(BEH.getAllWaypoints(npc)) do
      se_save_var(npc:id(), npc:name(), "pathpoint" .. index, nil)
    end
  end
--


-- TARGETS --
  function BEH.setTargetLookAround(self)
    local npc = self.object
    local st  = self.st

    local vid, pos, dir, reached, facing =
      st.savedTarget.level_vertex_id,
      st.savedTarget.position,
      st.savedTarget.direction,
      st.savedTarget.reached,
      st.savedTarget.facing

    if st.movePoint then
      vid = nil
    end

    if not vid then
      vid = st.movePoint or npc:level_vertex_id()
      st.movePoint = nil
    end

    facing  = dir and VEC.dotProduct(npc:direction(), dir) >= 0.6
    reached = vid == npc:level_vertex_id()
    pos     = POS.position(vid)

    if not st.lookPoint then
      st.lookTimer = nil
    end

    if time_expired(st.lookTimer) then
      st.lookPoint = nil
    end

    if st.lookPoint then
      dir = VEC.direction(npc:position(), st.lookPoint)

      if not st.lookTimer then
        st.lookTimer = UTIL.timePlusRandom(2600, 4200)
      end
    else
      dir = dir or VEC.direction(pos, db.actor:position())
    end

    POS.setLVID(npc, vid)

    st.desired_target = {
      look_dir        = (reached or st.lookPoint) and dir or nil,
      reached         = reached,
      facing          = facing,
      level_vertex_id = vid,
      position        = pos,
      direction       = dir,
    }

    return true
  end


  function BEH.setTargetCoverSpot(self)
    local npc = self.object
    local st  = self.st

    local vid, pos, dir, reached, facing, expires =
      st.savedTarget.level_vertex_id,
      st.savedTarget.position,
      st.savedTarget.direction,
      st.savedTarget.reached,
      st.savedTarget.facing,
      st.savedTarget.expires

    if st.keepType ~= st.lastKeepType
      then vid = nil

    elseif UTIL.timeExpired(expires)
      then vid = nil

    elseif st.movePoint
      then vid = nil
    end

    if not vid then
      local coverPos  = st.movePoint and POS.position(st.movePoint) or npc:position()
      local coverDir  = VEC.direction(db.actor:position(), npc:position())
      local coverDist = st.movePoint and 0 or st.desired_distance

      expires = nil
      st.movePoint = nil
      coverDir.y = 0

      if coverDist > distance_between(npc, db.actor) then
        coverPos = VEC.offset(coverPos, coverDir, coverDist)
      end

      vid = POS.legacyCover(npc, {
        position = coverPos,
        radius   = 12,
        spacing  = 3,
      })

      if not POS.isValidLVID(npc, vid) then
        vid     = npc:level_vertex_id()
        expires = UTIL.timePlus(1000)
      end
    end

    facing  = dir and VEC.dotProduct(npc:direction(), dir) >= 0.6
    reached = vid == npc:level_vertex_id()
    pos     = POS.position(vid)

    if not st.lookPoint then
      st.lookTimer = nil
    end

    if time_expired(st.lookTimer) then
      st.lookPoint = nil
    end

    if st.lookPoint then
      dir = VEC.direction(npc:position(), st.lookPoint)

      if not st.lookTimer then
        st.lookTimer = UTIL.timePlusRandom(2600, 4200)
      end
    else
      dir = dir or VEC.direction(pos, db.actor:position())
    end

    POS.setLVID(npc, vid)

    st.desired_target = {
      look_dir        = (reached or st.lookPoint) and dir or nil,
      reached         = reached,
      facing          = facing,
      expires         = expires,
      level_vertex_id = vid,
      position        = pos,
      direction       = dir,
    }

    return true
  end


  function BEH.setTargetFollowActor(self)
    local npc = self.object
    local st  = self.st

    local vid, pos, dir, reached, facing, expires =
      st.savedTarget.level_vertex_id,
      st.savedTarget.position,
      st.savedTarget.direction,
      st.savedTarget.reached,
      st.savedTarget.facing,
      st.savedTarget.expires

    local savedVid, savedActorPos, savedFormation, savedFollowCount =
      st.savedTarget.level_vertex_id,
      st.savedTarget.actorPos,
      st.savedTarget.formation,
      st.savedTarget.followCount

    local actorPos    = db.actor:position()
    local space       = POS.assessSpace(actorPos)
    local moveDist    = BEH.getActorMovement(self)
    local formation   = NPC.getActiveState(npc, "formation")
    local followCount = #NPC.getFollowers()

    if not savedActorPos or moveDist >= 2 then
      savedActorPos = actorPos
      vid = nil

    elseif formation ~= savedFormation or st.keepType ~= st.lastKeepType
      then vid = nil

    elseif followCount ~= savedFollowCount
      then vid = nil

    elseif UTIL.timeExpired(expires)
      then vid = nil

    elseif st.movePoint
      then vid = nil
    end

    if not vid then
      expires = nil

      local findFn = st.keepType == "near" and space == "cramped"
        and POS.legacyInsideUnclaimedLVID
        or  POS.bestInsideUnclaimedLVID

      if st.movePoint then
        vid = st.movePoint
        st.movePoint = nil

      elseif space == "cramped" and st.keepType ~= "near" then
        expires = UTIL.timePlus(1000)
        vid = savedVid

      elseif formation == "line"
        then vid = BEH.getLineFormation(npc, st.desired_distance, findFn)

      elseif formation == "bunch"
        then vid = BEH.getBunchFormation(npc, st.desired_distance, findFn)

      elseif formation == "spread"
        then vid = BEH.getSpreadFormation(npc, st.desired_distance, findFn)

      elseif formation == "covered"
        then vid = BEH.getCoverFormation(npc, st.desired_distance, findFn)
      end

      if not POS.isValidLVID(npc, vid) then
        vid     = npc:level_vertex_id()
        expires = UTIL.timePlus(1000)
      end
    end

    facing  = dir and VEC.dotProduct(npc:direction(), dir) >= 0.6
    reached = vid == npc:level_vertex_id()
    pos     = POS.position(vid)

    if moveDist >= 2 then
      st.lookPoint = nil
      st.lookTimer = nil
    end

    if not st.lookPoint then
      st.lookTimer = nil
    end

    if time_expired(st.lookTimer) then
      savedActorPos = actorPos
      st.lookPoint  = nil
    end

    if st.lookPoint then
      dir = VEC.direction(npc:position(), st.lookPoint)

      if not st.lookTimer then
        st.lookTimer = UTIL.timePlusRandom(2600, 4200)
      end
    else
      dir = dir or VEC.direction(pos, actorPos)
    end

    POS.setLVID(npc, vid)

    st.desired_target = {
      look_dir        = (reached or st.lookPoint) and dir or nil,
      actorPos        = savedActorPos,
      followCount     = followCount,
      formation       = formation,
      expires         = expires,
      reached         = reached,
      facing          = facing,
      direction       = dir,
      position        = pos,
      level_vertex_id = vid,
    }

    return true
  end


  function BEH.setTargetRelaxSpot(self)
    local npc = self.object
    local st  = self.st

    local vid, dir, pos, reached, facing, expires =
      st.savedTarget.level_vertex_id,
      st.savedTarget.direction,
      st.savedTarget.position,
      st.savedTarget.reached,
      st.savedTarget.facing,
      st.savedTarget.expires

    if UTIL.timeExpired(expires)
      then vid = nil
    elseif st.movePoint
      then vid = nil
    end

    if not vid then
      local startPos = st.movePoint
        and POS.position(st.movePoint)
        or  db.actor:position()

      st.movePoint = nil
      expires      = nil

      local spot = BEH.findCampfireSpot(npc, startPos)

      if not spot then
        local dist = st.keepType == "near" and 8
          or  st.keepType == "far" and 24
          or  16

        spot = BEH.findRandomRelaxSpot(npc, startPos, dist)
      end

      if POS.isValidLVID(npc, spot.vid) then
        vid = spot.vid
        dir = spot.dir
      else
        vid     = npc:level_vertex_id()
        expires = UTIL.timePlus(1000)
        dir     = nil
      end
    end

    facing  = dir and VEC.dotProduct(npc:direction(), dir) >= 0.6
    reached = vid == npc:level_vertex_id()

    pos = POS.position(vid)
    POS.setLVID(npc, vid)

    st.desired_target = {
      look_dir        = reached and dir or nil,
      expires         = expires,
      reached         = reached,
      facing          = facing,
      level_vertex_id = vid,
      direction       = dir,
      position        = pos,
    }

    return true
  end
--


-- ANIMATIONS --
  function BEH.getBehMoveState(self)
    local npc  = self.object
    local st   = self.st
    local dt   = st.desired_target
    local anim = st.moveState

    if dt.reached and dt.facing then
      anim = st.wait_animation
      st.moveState = nil
    end

    if st.lookPoint and NPC.getState(npc, "stance", "stand") then
      anim = "raid"
    end

    if not anim then
      local dist = VEC.distance(npc:position(), dt.position)

      local walkDist = tonumber(
        xr_logic.pick_section_from_condlist(db.actor, npc, st.walk_dist)
        or 4
      )
      local jogDist = tonumber(
        xr_logic.pick_section_from_condlist(db.actor, npc, st.jog_dist)
        or 8
      )

      if dist <= walkDist
        then anim = st.walk_animation
      elseif dist <= jogDist
        then anim = st.jog_animation
        else anim = st.run_animation
      end
    end

    if NPC.isReloading(npc) and BEH.RELOAD_ANIMATIONS[anim] then
      anim = BEH.RELOAD_ANIMATIONS[anim]
    end

    if anim ~= st.lastState then
      st.lastState   = anim
      st.timeInState = nil
      st.animFn      = nil
    end

    if not st.timeInState then
      st.timeInState = time_global()
    end

    if not st.animFn then
      st.animFn = UTIL.throttle(BEH.chooseAnimation, 12000, 48000)
    end

    return st.animFn(self, anim)
  end


  function BEH.getBehLookState(self)
    local dt = self.st.desired_target

    if dt.look_object then
      return {look_object = dt.look_object}
    end

    if dt.look_dir then
      return {look_dir = dt.look_dir}
    end

    return nil
  end


  function BEH.chooseAnimation(self, state)
    local st = self.st

    local anims   = BEH.ANIMATIONS[state]
    local choices = {}

    if not anims then
      return state
    end

    for anim, ops in pairs(anims) do
      local chances   = ops[1] or 1
      local onlyAfter = ops[2] or 0

      if not st.timeInState or UTIL.timeExpired(st.timeInState + onlyAfter) then
        for i = 1, chances do
          choices[#choices + 1] = anim
        end
      end
    end

    return choices[UTIL.random(1, #choices)]
  end
--


return BEH
