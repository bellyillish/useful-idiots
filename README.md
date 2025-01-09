# Useful Idiots for GAMMA and Anomaly

> [!TIP]
> Документация на русском языке доступна [здесь](README_ru.md).

Overhauls the companion system with new and improved commands, configurable keybinds, a new UI, and several fixes and tweaks to companion behavior. 

*Does not (and hopefully never will) overwrite any core files to play nice with other mods.*

## UI

Replaces the companion wheel (and is available via the same keybind). Functions similarly: when pointing at a companion, commands are given only to that companion. When pointed at nobody, commands are given to everyone.
- Shows all commands to control companions in one place
- Always indicates which commands are set globally and for each companion
- Tabs let you directly access global or individual companions' commands at all times
- When open, numeric indicators are shown above companions indicating their tab number (can be disabled via MCM)

It includes the following commands (more info on each below):
- [Movement Commands](#behaviors): follow, wait, find cover, relax, patrol
- [Formations](#formations): bunch, spread, line, cover
- [Stance](#stances): stand, sneak, prone
- [Distance](#distances): far, normal, near
- [Combat Readiness](#combat-readiness): ignore, defend player, attack
- [Combat Modes](#combat-modes): default, assault, support, guard, snipe
- [Weapon Types](#weapon-types): best, pistol, shotgun, SMG, rifle, sniper, RPG
- [Headlamps](#headlamps): auto, on, off
- [Toggles](#toggles): hurry, gather items, gather artifacts*, loot corpses, help wounded
- [Buttons](#buttons): add waypoint, clear all waypoints, open inventory, reload weapons*, retreat*, fix/unstick*, re-sync to global state

\* = *disabled by default in MCM*

## Keybinds

You can set and configure keybinds for any of the commands above. There are also a few additional commands that are only available via keybind:

- **Select companion:** Lets you select one or more companions with the cursor. Subsequent keybind presses will affect only selected companions instead of everyone.
- **Clear all selected companions:** Clears any selected companions. Subsequent keybind presses will resume affecting everyone.
- **Add waypoint:** Adds a patrol waypoint where the cursor is pointed
- **Move to point:** Moves companions to where the cursor is pointed (same behavior as Anomaly keybind).
- **Look at point:** Forces companions to look where the cursor is pointed.
- **Move out of the way:** Forces companions near the cursor to try to move out of the way and clear a path for the player.

## Commands

### Behaviors
---
> [!NOTE]
> Affects companions when not engaged in combat.

- **Follow:** Follow the actor in the formation selected in the UI. Similar to vanilla but with rewritten pathfinding logic.
  - Rather than moving as individual squads they move more like a single squad with you as the squad leader.
  - They obey "Move to Point" but will break off and resume following when the player moves. "Move to Point" can automatically switch them to "Wait" via MCM.
  - Companions will automically sprint, crouch, go prone, and adjust their headlamps to match the player (these can all be disabled via MCM).
  - Companions detect when the player is in an open, enclosed, or cramped space and follow accordingly. In an enclosed space they favor staying on the same side of any obstacles (e.g. walls) as the player. They try to avoid following the player into cramped spaces unless they are set to "Stay Near".

- **Wait:** Stop immediately and wait at the current position. Similar to vanilla. After a few seconds they will stop looking at the player and instead look in a fixed direction. You can make them look in a specific direction by using the "Look at Point" command. When using "Move to Point" they will go directly to that point.

- **Find Cover:** Try to find suitable cover nearby and wait there. If there isn't any nearby they will wait at their current position. When using "Move to Point" they will seek cover around that point.

- **Relax:** Try to find a nearby campfire with room to sit/kneel. If none are aound with room, pick a random spot nearby (usually indoors or in front of a wall or other large object). This behavior does not rely on the "camp" scheme, so they will use any nearby campfire including ones you set (if you have a mod installed that lets you do so). When using "Move to Point" they will relax near that point.

- **Patrol:** Patrol between 2 or more waypoints. Similar to vanila except they continue to patrol back and forth instead of stopping at the last waypoint. Companions can only be set to "Patrol" if at least two waypoints have been set using the "Add Waypoint" command.

Companions also perform various idle animations and get increasingly bored as time passes. Eventually you might catch them smoking or sitting on the job. When relaxing they might eat, drink, pull out their PDA, or sleep.

### Formations
---
> [!NOTE]
> Affects companions that are set to "Follow" and are not engaged in combat. They can only be set globally in the "All" tab.

- **Bunch:** Follow the player in a random, bunched-up formation similar to vanilla.
- **Spread:** Follow the player while side-by-side in a lateral line.
- **Line:** Follow the player in a single-file line.
- **Covered:** Follow the player while trying to stay in cover as much as possible.

### Stances
---
> [!NOTE]
> Affect companions that are idle, following, or in combat (combat logic will sometimes override their stance).

- **Stand:** Stand/walk/jog/run (same as vanilla when not using stealth).
- **Sneak:** Crouch/sneak (same as vanilla when using stealth).
- **Prone:** Prone/sneak (no animations for moving in a prone position exist AFAIK).

### Distances
---
> [!NOTE]
> Affects companions that are set to "Follow" or in "Support" combat. Distances below apply to "Follow".

- **Near:** Stay at least ~2.5m from the player.
- **Normal:** Stay at least ~5m from the player.
- **Far:** Stay at least ~10m from the player.

### Combat Readiness
---
- **Attack Enemies:** Engage enemies on sight (same as vanilla)
- **Defend Only:** Only engage if an enemy attacks the player (same as "Don't attack unless attacked" in vanilla)
- **Ignore Combat:** Ignore enemies always (same as vanilla)

### Combat Modes
---
> [!NOTE]
> All custom combat modes have the following behaviors built in:
> - Dodge grenades (without disengaging with the enemy)
> - Avoid friendly fire (with minimal disengagement)
> - Melee attack enemies at close range
> - Use hearing to locate enemies
> - Share locations of enemies when spotted or spotted by the player
> - Find the best high/mid/low cover depending on the situation
> - Stand or crouch to shoot from or hide behind cover
> - Use raycasting to augment their sight and help them see through obstacles like transparent anomalies

- **Default:** Bypasses this mod and uses the default engine-based combat scheme instead.

- **Assault Combat:** An "offensive" combat style. They approach the enemy in stages to a distance suitable for their active weapon's range and preferring partial cover that they can shoot behind. They pursue differently when the enemy is in an enclosed space (e.g. in a building). When their enemy is focused on another NPC, they try to flank. When fighting mutants they backpedal and evade while firing. When losing sight of the enemy they search starting at the last known position. They rush wounded enemy NPCs. They fall back and seek higher cover when injured.

- **Guard Combat:** A "defensive" combat style. They fight the enemy while staying within a radius around their initial position, defending/guarding it. They move periodically to regain sight of the enemy or to seek better cover. They evade when fighting mutants. They rush wounded enemy NPCs that are inside the radius.

- **Support Combat:** They fight the enemy while staying within a radius around the player, providing covering or supporting fire. They move periodically to regain sight of the enemy or to seek better cover. They evade when fighting mutants. They rush wounded enemy NPCs that are inside the radius. They obey "Stay Near", "Normal", and "Stay Far" by staying 8m/16m/24m from the player respectively. They try not to cross into the line of fire between the player and enemy as much as possible.

- **Sniper Combat:** They in their current fixed position. They only move to dodge grenades or avoid friendly fire regardless of whether they are fighting NPCs or mutants.

Combat modes respond to the "Move to Point" command in a way that fits their scheme. For example in "Guard" or "Snipe" that point will become their new permanent fixed position. In "Assault" or "Support" they will move to that point but resume their normal combat behavior afterwards. "Move to Point" can automatically switch them to "Guard Combat" via an MCM option.

> [!WARNING]
>You can also enable the **"Monolith"**, **"Camper"** and **"Zombied"** combat modes that ship with Anomaly via MCM. AFAIK thse are not used by Anomaly, but are used by GAMMA and some other mods. They work for the most part but have some issues and jankiness. Therefore they are **disabled by default not supported in any way**. Consider them "bonus content".

### Weapon Types
---
> [!NOTE]
> In vanilla companions switch weapons based on enemy distance. This is determined by the engine and can happen at inopportune times. If they're on top of a boundary between two of these distances, they may repeatedly switch back and forth between weapons and get caught in reload animations that cancel before they finish. This leaves them vulnerable and unable to defend themselves.

When **"Best"** is selected, companions always use their best weapon. The "best" weapon is determined by:
  1. Repair kit tier (weapons without repair kits like RPGs are considered best)
  2. For weapons that use the same repair kit, the one with the highest cost is considered best

You can also command them to use specific weapon types by choosing **"Pistol"**, **"Shotgun"**, **"SMG"**, **"Rifle"**, **"Sniper"** or **"RPG"**. But regardless of what is selected, they will never switch weapons during combat unless you tell them to.

### Headlamps
---
- **Default Light:** Let vanilla or other mods control headlamps.
- **Light Off:** Force headlamps off.
- **Light On:** Force headlamps on.

When in "Follow", companions will match how the player's headlamp is set when using "Default Light" and when not overriden by another mod. This can be disabled via MCM.

### Toggles
---
- **Hurry:** Run to the destination.
- **Gather Items:** Pick up items lying around in the world.
- **Gather Artifacts:** Retrieve artifacts (can only be enabled if "Gather Items" is also enabled).
- **Loot Corpses:** Loot nearby corpses.
- **Help Wounded:** Patch up wounded friendly NPCs (including during combat).

Any items picked up by companions while looting or gathering is enabled can be accessed via their inventories. All other items they're carrying will remain hideen from the player as usual.

> [!IMPORTANT]
> When using these commands, Make sure to disable any mods that interfere with or prevent NPCs from looting and gathering. You can contol whether non-companion NPCs can loot or gather via MCM instead. By default this is disabled for GAMMA but enabled otherwise.

> [!CAUTION]
> Since NPCs are impervious to anomalies, "Gather Artifacts" is technically cheating. I'd only reccommend enabling it if you also use other mods that compensate (e.g. mods that make NPCs avoid anomalies and/or get hurt by them).

### Buttons
---
- **Add Waypoint:** Add a patrol waypoint for a companion. They can be placed in "Patrol" once two or more waypoints have been added.
- **Clear All Waypoints:** Clear all patrol waypoints and switch them out of "Patrol" if they're in it.
- **Open Inventory:** Open their inventory. The companion must be 8m or less from the player to use this.
- **Reload Weapons:** Force companions to reload all empty or partially-loaded weapons. Pressing it again cancels the reloading process. Hidden by default but can be enabled in MCM.
- **Retreat:** Simultaneously sets "Follow", "Hurry", "Ignore Combat", and "Stay Near". Useful for emergencies. Hidden by default but can be enabled in MCM.
- **Unstick:** Triggers an "unstick" function which can fix stuck or unresponsive companions. Hidden by default but can be enabled in MCM.
- **Re-Sync:** Resets all companions to the global state (the state shown in the "All" tab in the UI).

## Other AI Improvements

### Friendly Fire AI
---
> [!NOTE]
> The vanilla "friendly fire" scheme (`rx_ff.script`) is a huge hindrance to NPC combat AI. When you see them constantly moving side-to-side and not firing their weapon, this is the reason. As soon as a friendly or neutral NPC gets near their line of fire, they immediately leave combat, strafe 10-12 meters, and not re-enter combat for a minimum of 2.5 seconds. On top of that, the strafe logic strongly favors one direction over the other. This means that multiple NPCs strafing at the same time will continue to be in each other's way and further delay them from re-entering combat. This is why large firefights tend to look more like a dance-off than actual combat.

Useful Idiots **modifies the friendly fire behavior** in a couple ways to improve combat without causing too much disruption to AI or overall balance:

1. When a friendly/neutral NPC gets in the LoF, there is a 1.5 second grace period before the NPC starts strafing. During this period they stop firing but immediately re-enter combat once the LoF is clear. This allows NPCs to pass through without interrupting combat for a long period of time.

2. If the LoF is still obstructed after 1.5s they will strafe a shorter distance. If the LoF clears during strafing, they will stop and re-enter combat after 500ms instead of waiting the entire 2.5s.

For companions, friendly fire logic is built into the [custom combat modes](#combat-modes), but it functions nearly identically. The only difference is the strafe direction is better randomized.

### Reloading AI
---
> [!NOTE]
> Another hindrance to combat effectiveness is NPC reloading behavior. Aside from the engine switching them to unloaded weapons in the middle of combat or keeping them in and endless reload loop, they also tend to keep their weapons empty or mostly unloaded after leaving combat. Once re-entering combat, they then have to immediately stop and reload, once again making themselves vulnerable.

In addition to [improved weapon switching](#weapon-types), useful idiots also makes two additions to reloading behavior:
1. Companions automatically reload their active weapon after leaving combat, when first joining, or when loading a save (they can be told to reload all of their weapons instead via MCM).
2. Companions automatically reload their weapons during combat right before they start searching for an enemy.


## Fixes

Useful Idiots fixes many bugs, issues, inconsistencies, and general wonkiness with companions. They should feel much snappier and more responsive in general, pathfind better, respect personal space more, and get stuck much less. They no longer ignore enemies that are less than 30m from them (and vice versa) while they are sneaking. They no longer stop, creepily stare at you, and ignore their commands when you are near them. Many values have been tweaked or reworked via DLTX.
