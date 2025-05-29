local POS    = require "illish.lib.pos"
local NPC    = require "illish.lib.npc"
local COMBAT = require "illish.lib.combat"


local State = {}


function State:new(scheme)
  local state = {
    action      = nil,
    vid         = nil,
    expires     = nil,
    grenades    = nil,
    weapon      = nil,
    cover       = nil,
    coverOrder  = nil,
    ffDelay     = nil,
    ffTimeout   = nil,
    reached     = false,
    reloading   = false,
    recovering  = false,
    dontShoot   = false,
  }

  local instance = setmetatable({
    scheme = scheme,
    enemy  = scheme.st.enemy,
    config = scheme.st.config,
    state  = state,
    last   = {},
  }, State)

  return instance
end


function State:updateState()
  self.last = dup_table(self.state)

  local npc    = self.scheme.object
  local config = self.scheme.st.config
  local enemy  = self.scheme.st.enemy
  local state  = self.state
  local last   = self.last

  state.grenades = POS.nearbyGrenades(npc:position(), config.dodgeDist)

  state.cover = POS.assessCover(npc:position(), enemy.pos)

  state.weapon = NPC.getWeaponType(npc)

  state.dontShoot = db.storage[npc:id()].rx_dont_shoot

  if state.dontShoot then
    state.ffTimeout = time_plus(500)

    if state.reached and not state.ffDelay then
      state.ffDelay = time_plus_rand(config.ffDelay)
    end
  end

  -- TODO: deprecate this
  self.state.coverOrder = "shoot"
end


function State:updateDestination()
  local npc    = self.scheme.object
  local state  = self.state
  local last   = self.last

  if last.action ~= state.action or time_expired(state.expires) then
    state.expires = nil
    state.vid     = nil
  end

  if last.action ~= state.action and (last.action == "ffstrafe" or last.action == "movePoint") and state.action ~= "dodge" then
    state.vid     = npc:level_vertex_id()
    state.reached = true
  end
end


function State:updateAnimation()
  local npc    = self.scheme.object
  local config = self.scheme.st.config
  local state  = self.state

  if not POS.isValidLVID(npc, state.vid) then
    state.vid     = npc:level_vertex_id()
    state.expires = time_plus(config.vidRetry)
  end

  state.reached = state.vid == npc:level_vertex_id()
  POS.setLVID(npc, state.vid)

  if state.reached then
    self.scheme.st.moveState = nil
  end

  local move = COMBAT.getCombatMoveState(self.scheme)
  local look = COMBAT.getCombatLookState(self.scheme)

  state_mgr.set_state(npc, move, nil, nil, look, {fast_set = true})
end


--


function State:__index(key)
  if State[key] then
    return State[key]
  end

  return self.state[key]
end


function State:__newindex(key, value)
  if State[key] then
    return
  end

  self.state[key] = value
end


--[[
  config.alwaysSee
  config.useTeamSight
  config.recoverHealth

  config.dodgeDist
  config.maxDist
  config.moveDist
  config.mutantDist
  config.zones
  config.targetZone

  config.spottedTimeout
  config.ffDelay
  config.holdDelay
  config.lookTimeout
  config.moveDelay
  config.vidRetry


  state.currentZone
  state.nextZone
  state.targetZone
  state.maxDist
  state.moveDist

  state.startPos
  state.vid
  state.action
  state.reached

  state.dontShoot
  state.grenades
  state.recovering
  state.reloading
  state.weapon
  state.cover

  state.actorPos
  state.keepType

  state.expires
  state.ffDelay
  state.ffTimeout


  enemy.id
  enemy.dir
  enemy.lookDir
  enemy.dist
  enemy.pos
  enemy.seen
  enemy.spotted

  enemy.space
  enemy.flankable
  enemy.mutant
  enemy.wounded

  enemy.spottedUntil
  enemy.holdUntil
--]]
