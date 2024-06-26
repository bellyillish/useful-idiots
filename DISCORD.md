# Useful Idiots for Anomaly and GAMMA

Overhauls the companion system for Anomaly/GAMMA. It includes a new UI, fixes several bugs, and tweaks/patches to companion behavior.

**New UI (WIP) replaces the Companion Wheel:**
  - Less intrusive
  - Access to all useful commands
  - Shows which are on/off at any given time
  - Tabs to switch between global commands and any companion at all times
  - Shows each companion's tab number above them in the HUD when UI is open

**Choose between 4 behaviors:**
  1. Follow / Follow in Cover
    - Companions can "Stay Far" and/or "Hurry Up"
    - Can set companions to follow in a "Bunch", "Spread", or "Line" formation
  2. Wait / Wait in Cover
    - Varying idle animations
  3. Relax
    - Companions sit near a fire if they can or pick a random nearby spot otherwise
    - They will use any nearby campfire including ones you place, and will use multiple campfires if need be
    - Varying sit/kneel/sleep animations
  4. Patrol
    - Companions now loop through visiting their waypoints instead of stopping at the last one

**Choose between 3 stances:**
  1. Stand
  2. Sneak
  3. Prone (note: there's no "crawl" animation that I could find, so they will sneak when moving and go prone when idle)
Note: companions go sneak/prone when you crouch/low crouch

**Choose between 4 combat styles:**
  1. Default (current engine-based combat)
  2. Fight from Cover
    - Existed but was largely unused, has been patched slightly and may be rewritten later
  3. Monolith Combat
    - Existed but was buggy and disabled, has been completely rewritten from scratch
  4. Camper Combat
    - Existed but was buggy and disabled, has been completely rewritten from scratch

**Choose between 3 different combat readiness modes:**
  1. Attack (same as current default mode)
  2. Defend Only (same as "don't attack unless attacked" dialog option)
  3. Ignore Combat (same as before)

**Assign Any of 4 jobs:**
  1. Gather Items (pick up items laying around in the world)
  2. And Artifacts (also pick up artifacts nearby)
  3. Loot Corpses (loot items from dead bodies)
  4. Help Wounded (assist wounded companions and allies)

Note: items picked up from jobs are visible in their inventories and accessible to the player. Items they already carried remain hidden/inaccessible.

Note: this mod only enables these jobs for companions. They are/remain disabled for NPCs. Disable any other mods that disable NPC looting/gathering because they are no longer needed and may interfere with this mod.

**Other Available Actions in the UI**
  1. Add patrol waypoint at actor's position
  2. Clear all patrol waypoints for a companion
  3. Open a companion's inventory
  4. Re-sync companion (or all companions) to the current global state

**Other Features:**
- Fixes several Anomaly/GAMMA bugs. Companions should feel snappier, more responsive, and get stuck or break less.

There are many more details that won't fit here, so please see the GitHUB README for full details.

*Note: the current UI was originally meant to be a placeholder. I decided it was good enough to roll with for now, but keep in mind that it was designed to be easy to develop/iterate over, not so much for aesthetics.*
