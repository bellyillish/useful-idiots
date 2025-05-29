local POS    = require "illish.lib.pos"
local COMBAT = require "illish.lib.combat"


--[[
  PROPS:
  enemy.holdUntil

  METHODS:
  self.enemySpace = POS.assessSpace
  COMBAT.hasLineOfSight
  COMBAT.teamSeesEnemy
--]]


local Enemy = {}


function Enemy:new(scheme)
  local config = {
    alwaysSee      = 2,
    useTeamSight   = true,
    spottedTimeout = {800,  1200},
    holdDelay      = {1600, 3200},
  }

  local enemy = {
    id           = nil,
    pos          = nil,
    dir          = nil,
    lookDir      = nil,
    dist         = nil,
    seen         = false,
    spotted      = true,
    spottedUntil = nil,
    space        = nil,
    wounded      = false,
    flankable    = false,
    mutant       = false,
  }

  return setmetatable({
    scheme = scheme,
    config = config,
    enemy  = enemy,
    last   = {},
  }, Enemy)
end


function Enemy:update()
  self.last = dup_table(self.enemy)

  local npc    = self.scheme.object
  local config = self.config
  local enemy  = self.enemy

  local be = npc:best_enemy()

  if not be then
    return
  end

  if enemy.id ~= be:id() then
    enemy.spotted = true
  end

  enemy.seen   = npc:see(be) or COMBAT.hasLineOfSight(npc, be)
  enemy.mutant = IsMonster(be) or character_community(be) == "zombied"
  enemy.id     = be:id()

  local reset = false
  local pos   = false

  if enemy.seen or enemy.spotted then
    reset = true
    pos   = true

  elseif distance_between(be, npc) <= config.alwaysSee then
    reset = true
    pos   = true

  elseif config.useTeamSight and COMBAT.teamSeesEnemy(npc, be) then
    reset = true
    pos   = true

  elseif not time_expired(enemy.spottedUntil) then
    pos = true
  end

  local ally = pos and be:best_enemy() or npc

  if pos then
    enemy.pos       = utils_obj.safe_bone_pos(be, "bip01_head")
    enemy.space     = POS.assessSpace(enemy.pos)
    enemy.flankable = ally:id() ~= npc:id()
    enemy.wounded   = IsWounded(be)
  end

  if reset then
    enemy.spottedUntil = time_plus_rand(config.spottedTimeout)
  end

  if time_expired(enemy.spottedUntil) then
    enemy.holdUntil = enemy.holdUntil or time_plus_rand(config.holdDelay)
  else
    enemy.holdUntil = nil
  end

  enemy.dir     = vec_dir(utils_obj.safe_bone_pos(npc, "bip01_r_finger02"),  enemy.pos)
  enemy.dist    = vec_dist(npc:position(), enemy.pos)
  enemy.lookDir = vec_dir(enemy.pos, ally:position())

  enemy.spotted = false
end


function Enemy:__index(key)
  if Enemy[key] then
    return Enemy[key]
  end

  return self.enemy[key]
end


function Enemy:__newindex(key, value)
  if Enemy[key] then
    return
  end

  self.enemy[key] = value
end


return Enemy
