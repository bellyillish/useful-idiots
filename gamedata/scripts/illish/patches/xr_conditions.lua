local NPC = require "illish.lib.npc"


-- Should companion auto-crouch?
function xr_conditions.follow_crouch(actor, npc)
  if not ui_mcm.get("idiots/options/autoSneak") then
    return false
  end
  return IsMoveState("mcCrouch") and NPC.isFollower(npc)
end


-- Should companion auto-prone?
function xr_conditions.follow_prone(actor, npc)
  if not ui_mcm.get("idiots/options/autoProne") then
    return false
  end
  return IsMoveState("mcCrouch") and IsMoveState("mcAccel") and NPC.isFollower(npc)
end


-- Should companion auto-sprint?
function xr_conditions.follow_sprint(actor, npc)
  if not ui_mcm.get("idiots/options/autoSprint") then
    return false
  end
  return IsMoveState("mcSprint") and NPC.isFollower(npc)
end


-- Is enemy is mutant or zombied?
function xr_conditions.enemy_monster(enemy, npc)
  return IsMonster(enemy) or character_community(enemy) == "zombied"
end


-- Is npc or enemy story related (for xr_combat_ignore)?
function xr_conditions.story_related(enemy, npc)
  if enemy:id() == 0 then
    return false
  end

  if get_object_story_id(npc:id()) or get_object_story_id(enemy:id()) then
    return true
  end

  local nsquad = get_object_squad(npc)
  local esquad = get_object_squad(enemy)

  if nsquad and get_object_story_id(nsquad.id) or esquad and get_object_story_id(esquad.id) then
    return true
  end

  return false
end


-- Is military vs. stalker in Cordon (for xr_combat_ignore)?
function xr_conditions.cordon_army_vs_stalker(enemy, npc)
  if alife():has_info(npc:id(), "npcx_is_companion") then
    return false
  end

  if enemy:id() == 0 or alife():has_info(enemy:id(), "npcx_is_companion") then
    return false
  end

  if level.name() ~= "l01_escape" then
    return false
  end

  local ncomm = character_community(npc)
  local ecomm = character_community(enemy)

  return ncomm == "army"    and ecomm == "stalker"
      or ncomm == "stalker" and ecomm == "army"
end


-- Is npc a companion?
function xr_conditions.npc_companion(enemy, npc)
  return alife():has_info(npc:id(), "npcx_is_companion")
    and true
    or  false
end


-- Is playing GAMMA (by checking if GAMMA manual exists)?
function xr_conditions.is_gamma()
  return grok_gamma_manual_on_startup and true or false
end


-- Is using RE:Done Combat AI?
function xr_conditions.is_redone_combat()
  return redone_ai_schemes and true or false
end


-- Attacked companions
function xr_conditions.enemy_fighting_actor_squad(enemy, npc)
  if not xr_conditions.npc_companion(enemy, npc) then
    return false
  end

  if xr_conditions.is_enemy_fighting_actor(enemy, npc) then
    return true
  end

  local defendMode = ui_mcm.get("idiots/options/defendMode")
  if not defendMode or defendMode == "actor" then
    return false
  end

  local eid = db.storage[npc:id()].hitted_by
  if eid and NPC.get(eid) and NPC.get(eid):alive() then
    return true
  end

  if defendMode == "self" then
    return false
  end

  eid = db.storage[0].companion_hit_by

  return eid and NPC.get(eid) and NPC.get(eid):alive()
end
