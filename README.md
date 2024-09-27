# Useful Idiots for Anomaly and GAMMA

Overhauls the companion system for Anomaly/GAMMA. It includes a new UI, fixes several bugs, and tweaks/patches to companion behavior.

## UI Replacement for Companion Wheel

  - Less intrusive and blocks less of your view compared to the wheel.
  - Shows all useful commands in one place (no more digging through the dialogs or blindly toggling buttons in the wheel).
  - Indicates the current global state and state of all companions (which commands are currently active/selected)
  - Provides tabs to access each individual companion at all times.
  - When the UI is open, numeric indicators are shown above each companion to indicate which tab belongs to them.

### Choose Between 4 Behaviors:
---
#### 1. Follow / Follow in Cover
  - Companions either follow directly, or if "Use Cover" is enabled, they try to remain in cover if possible.
  - Companions stay at least 4m away from the player, or if "Stay Far" is enabled, at least 10m away.
  - If "Hurry Up" is enabled, companions will sprint/run to their destination.
  - Companions can follow in one of 3 formations:
    1. "Bunch" - (closest to current behavior)
    2. "Spread" - they follow in an arc behind the actor
    3. "Line" - they line up single file

#### 2. Wait / Wait in Cover
  - Similar to current functionality, or if "Use Cover" is enabled, they will try to find cover to wait behind.
  - Companions will use a small variety of animations depending on how long they've been idle.

#### 3. Relax
  - Companions will sit by a campfire any are nearby with room to spare. All nearby campfires will potentially be used.
  - If no campfires are available they will pick a random out-of-the-way spot nearby to relax.
  - Does not rely on the "camp" system, so they can use any campfire including ones you place yourself.
  - Companions will use a variety of sit/kneel/nap animations depending on how long they've been relaxing.

#### 4. Patrol
  - Similar to current functionality, except now they will loop through visting their waypoints instead of stopping at the last one.
  - Can only be activated for individual companions that have at least 2 waypoints assigned.

### Choose Between 3 Stances:
---
  1. **Stand** - Default and same as current.
  2. **Sneak** - Same as current "use stealth" functionality.
  3. **Prone** - There doesn't appear to be a "crawl" animation, so they sneak while moving and go prone when idle.

**Note:** When the player crouches or low-crouches, all companions that are following will sneak or go prone accordingly.

### Choose Between 3 Combat Styles:
---
#### 1. Default Combat
The original, engine-based combat system that companions used before.

#### 3. Monolith Combat
This existed in the code but was disabled. And for good reason as it was rudimentary and very buggy. I've completely rewritten this scheme but tried to keep the spirit of what the original author intended:

  1. When far from the enemy, the companion will move to a spot (random but roughly half way) between them and the enemy. They will use cover if possible.
  2. At medium distance, they will move directly to a spot that's at close range to the enemy (random but roughly 20m). Again they will use cover if possible.
  3. At close range they will keep moving around the enemy using any close cover.
  4. When losing sight of the enemy they will go the last known position and search.
  5. If significantly injured they will retreat to a safe place and recover. They will keep moving if pursued.
  6. When reloading they will duck or move behind close cover.
  7. They will crouch behind low cover and stand behind high cover when engaging.

#### 4. Camper Combat
Like Monolith Combat, this also existed but was disabled. I also rewrote this trying to keep the spirit of the original:

  1. If not "prone", companions will look for cover near their initial position.
  2. If significantly injured, they will retreat to a safe place and recover. They will keep moving if pursued.
  3. Every so often they will move to a new position but will always be tethered to within ~8m of their initial position.

**Note:** for Monolith and Camper Combat, companions "share" enemy positions with each other. If a companion loses sight of an enemy while fighting, as long as any other companion (or the player) sees that enemy they will be aware of the enemy's current position.

### Choose Between 3 Combat Readiness Modes:
---
  1. **Attack** - (same as before)
  2. **Defend Only** - (same as the current "don't attack unless attacked" dialog option)
  3. **Ignore Combat** - (same as before)

### Assign Any of 4 Jobs:
---
  1. **Gather Items** - pick up items lying around in the world.
  2. **And Artifacts** - also retrieve artifacts nearby.
  3. **Loot Corpses** - loot items from dead bodies.
  4. **Help Wounded** - assist wounded companions and allies.

**Note:** any items or artifacts companions pick up while one of the jobs below will be visible in their inventory and available to the player. However any items they were carrying from before will remain hidden/unavailable.

Also, this mod enables the features below for companions only and disables them for other NPCs. You should disable any other mods that prevent NPCs from looting or gathering as it's no longer necessary and may interfere with the functionality below.

### Other Available Actions in the UI
---
  1. Add patrol waypoint at actor's position
  2. Clear all patrol waypoints for a companion
  3. Open a companion's inventory
  4. Re-sync companion (or all companions) to the current global state

## Additional Fixes/Patches
- Fixes most instances of slow/sluggish/unresponsive animations. Companions should beel snappier and more responsive in general.
- Fixes various issues with "prone" animations.
- Fixes issue with companions stopping at their last patrol waypoint.
- Fixes many (but not all or even most) issues with companions getting stuck behind obstacles/objects while moving to a destination.
- Fixes a bug causing companions to get stuck in scripted combat permanently and become unresponsive.
- Fixes a bug causing companions and enemies to ignore eachother when the companion is sneaking and they are within 30m of each other.
- Fixes various issues/inconsistencies with companion state setters in `axr_companions` and `dialogs_axr_companion`. It does so by using its own code lib to manage companion states.
- Fixes various issues with incorrect/bad values in various ltx files in both Anomaly and GAMMA.
- Fixes various issues with `used_level_vertex_ids` not being maintained/preserved/respected causing collisions and conflicts between multiple companions.
- Companions now obey commands even if you are close to them instead stopping and creepily staring at the player.
- Companions look around when idle instead of fixating on the player.
