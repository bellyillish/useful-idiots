local UTIL  = require "illish.util"
local RAY   = require "illish.ray"
local VEC   = require "illish.vector"
local NPC   = require "illish.npc"


local COMBAT = {}


-- CONSTS --
  COMBAT.COMBAT_ANIMATIONS = {
    stand = {
      idle = {
        snipe  = "threat_sniper_fire",
        fire   = "threat_fire",
        reload = "hide_fire",
        hold   = "threat_na",
      },
      move = {
        snipe  = "assault_fire",
        fire   = "assault_fire",
        reload = "assault_fire",
        hold   = "assault",
      }
    },
    sneak = {
      idle = {
        snipe  = "hide_sniper_fire",
        fire   = "hide_fire",
        reload = "hide_fire",
        hold   = "hide_na",
      },
      move = {
        snipe  = "assault_fire",
        fire   = "assault_fire",
        reload = "assault_fire",
        hold   = "assault",
      }
    },
    prone = {
      idle = {
        snipe  = "prone_sniper_fire",
        fire   = "prone_fire",
        reload = "prone_fire",
        hold   = "prone",
      },
      move = {
        snipe  = "sneak_fire",
        fire   = "sneak_fire",
        reload = "sneak_fire",
        hold   = "sneak_run",
      }
    }
  }

  COMBAT.COVER_STANCES = {
    peek = {
      [0] = false,
      [1] = "prone",
      [2] = "sneak",
      [3] = "sneak",
      [4] = "stand",
      [5] = "stand",
      [6] = false,
    },
    shoot = {
      [0] = false,
      [1] = "sneak",
      [2] = "sneak",
      [3] = "stand",
      [4] = "stand",
      [5] = "stand",
      [6] = false,
    }
  }

  COMBAT.COVER_ORDER = {
    peek  = {5, 3, 1, 4, 2, 0, 6},
    shoot = {4, 2, 3, 1, 0, 5, 6},
  }
--


-- SIGHT --
  function COMBAT.squadSeesEnemy(npc, enemy)
    local squad = get_object_squad(npc)

    if squad then
      for member in squad:squad_members() do
        local squaddie = NPC.get(member.id)
        if squaddie and squaddie:see(enemy) then
          return true
        end
      end
    end

    return false
  end


  function COMBAT.teamSeesEnemy(npc, enemy)
    if not NPC.isCompanion(npc) then
      return COMBAT.squadSeesEnemy(npc, enemy)
    end

    if db.actor:see(enemy) and COMBAT.hasLineOfSight(db.actor, enemy) then
      return true
    end

    for i, companion in ipairs(NPC.getCompanions()) do
      if companion:see(enemy) then
        return true
      end
    end

    return false
  end


  function COMBAT.hasLineOfSight(npc, enemy)
    local enemyDir   = VEC.direction(npc:position(), enemy:position())
    local enemyAngle = VEC.dotProduct(npc:direction(), enemyDir)

    if enemyAngle < 0 then
      return false
    end

    local wpnBone = utils_obj.safe_bone_pos(npc, "bip01_r_finger02")
    local aimBone = utils_obj.safe_bone_pos(enemy, "bip01_head")

    local aimDir  = VEC.direction(wpnBone, aimBone)
    local aimDist = VEC.distance(wpnBone, aimBone)
    local cast    = RAY.distance(wpnBone, aimDir, aimDist)

    return math.floor(aimDist - cast) <= 0
  end


  function COMBAT.getActorMovement(self)
    local state = self.st.state
    local npc   = self.object

    local pos, savedActorPos = lvpos(state.vid), state.actorPos

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
--


-- ZONES --
  function COMBAT.getCurrentZone(self)
    local config = self.st.config
    local state  = self.st.state
    local enemy  = self.st.enemy

    local zones = config.zones[state.weapon] or config.zones.other

    for i = 1, #zones do
      if enemy.dist < zones[i] then
        return i - 1
      end
    end

    return #zones
  end


  function COMBAT.getTargetZone(self)
    local config = self.st.config
    local state  = self.st.state
    local enemy  = self.st.enemy
    local npc    = self.object

    local be         = NPC.get(enemy.id)
    local targetZone = config.targetZone
    local zoneConfig = config.zones[state.weapon] or config.zones.other

    if state.recovering then
      targetZone = targetZone + 1
    end

    return clamp(targetZone, 1, #zoneConfig - 1)
  end


  function COMBAT.updateNextZone(self)
    local config = self.st.config
    local state  = self.st.state

    local nextZone, currentZone, targetZone =
      state.nextZone,
      state.currentZone,
      state.targetZone

    local zones = config.zones[state.weapon] or config.zones.other

    if not nextZone or currentZone == targetZone then
      nextZone = currentZone
    elseif currentZone < targetZone then
      nextZone = currentZone + 1
    else
      nextZone = currentZone - 1
    end

    state.nextZone = clamp(nextZone, 1, #zones - 1)

    return (zones[state.nextZone] + zones[state.nextZone + 1]) / 2
  end
--


-- ANIMATIONS --
  function COMBAT.getCombatMoveState(self)
    if self.st.moveState then
      return self.st.moveState
    end

    local config = self.st.config
    local enemy = self.st.enemy
    local state = self.st.state
    local npc   = self.object

    if state.action == "dodge" then
      return "panic"
    end

    local body = state.reached
      and COMBAT.COVER_STANCES[state.coverOrder][state.cover]
      or  NPC.getActiveState(npc, "stance")

    local move = state.reached
      and "idle"
      or  "move"

    local fire = nil
      or state.reloading and "reload"
      or state.dontShoot and "hold"
      or state.action == "idle" and "hold"
      or enemy.seen and state.weapon == "sniper" and "snipe"
      or enemy.seen and "fire"
      or "hold"

    return COMBAT.COMBAT_ANIMATIONS[body][move][fire]
  end


  function COMBAT.getCombatLookState(self)
    local npc    = self.object
    local config = self.st.config
    local state  = self.st.state
    local enemy  = self.st.enemy

    local lookDir = state.action == "search"
      and VEC.set(enemy.dir):invert()
      or  enemy.dir

    if enemy.seen then
      return {look_object = NPC.get(enemy.id)}
    end

    if not state.reached or not UTIL.timeExpired(enemy.spottedUntil) then
      return {look_dir = lookDir}
    end

    if NPC.getState(npc, "stance", "prone") then
      return {look_dir = lookDir}
    end

    if not state.lookAround then
      if not state.__looksign then
        state.__looksign = UTIL.randomChance(50) and -1 or 1
      end

      state.lookAround = UTIL.throttle(function(lookDir)
        local dir = VEC.rotate(lookDir, UTIL.random(30, 60) * state.__looksign)
        state.__looksign = -state.__looksign
        return dir
      end, config.lookTimeout[1], config.lookTimeout[2])
    end

    return {look_dir = state.lookAround(lookDir)}
  end
--


-- CALLBACKS --
  function COMBAT.combatHitCallback(self, obj, amount, direction, who, bone)
    local enemy = self.st.enemy
    local state = self.st.state
    local npc   = self.object

    if not (npc and obj:id() == npc:id() and who and who:id() == enemy.id) then
      return
    end

    enemy.spotted = true

    if state.reached then
      state.expires = 0
    end
  end


  function COMBAT.combatHearCallback(self, obj, whoid, type, position, power)
    local enemy = self.st.enemy
    local state = self.st.state
    local npc   = self.object

    if not (npc and obj:id() == npc:id() and enemy.id == whoid) then
      return
    end

    enemy.spotted = true

    if UTIL.timeExpired(enemy.spottedUntil) then
      state.expires = 0
    end
  end
--


return COMBAT
