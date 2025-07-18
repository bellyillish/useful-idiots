> [!TIP]
> Документация на русском языке доступна [здесь](README_ru.md).

# Useful Idiots for Anomaly and GAMMA

Overhauls the companion system with:

- [Over 50 commands](#movement-commands) for controlling your idiots
- A dynamic and customizable [UI replacement](#replacement-ui) for the companion wheel
- Extensive support for [keybinds and modifiers](#keybinds-and-modifiers) (powered by MCM)
- Lots of AI [improvements and bug fixes](#improvements-and-fixes), some for companions and some for everyone

Does not (and never will) overwrite any base game files to keep it as compatible as possible out of the box with other mods.

## Installation Requirements

- Requires [Modded EXEs](https://github.com/themrdemonized/xray-monolith/releases)
- Requires [Mod Configuration Menu](https://www.moddb.com/mods/stalker-anomaly/addons/anomaly-mod-configuration-menu)
- Safe to add or remove at any point

## Installation Instructions

1. Download the ZIP from here or from [GitHub Releases](https://github.com/bellyillish/useful-idiots/releases).
2. Install it with [Mod Organizer 2](https://anomalymodding.blogspot.com/2021/04/Mod-Organizer-2-setup-and-Amomaly-modding-guide.html). It is included with GAMMA but is strongly encouraged either way. Priority doesn't matter for Anomaly. For GAMMA just put it below the mods that come with it.
3. Go to **Mod Configuration Menu -> Useful Idiots** to customize and configure to your liking.

## Mod Interactions

- **NPC Stops Dropping Weapons and Looting Dead Bodies** interferes with looting and gathering. An MCM option is included instead that does the same thing. It defaults to enabled in GAMMA and disabled in Anomaly.

- **NPC Use Grenade Launchers:** contains a syntax error that crashes scripts in the base game. Useful Idiots relies on one of those scripts so using the two together will result in a CTD. I'd recommend avoiding that mod entirely until it is fixed and properly tested.

- **Companion Anti AWOL for Anomaly:** doesn't conflict but can *sort of* get in the way. You'll have plenty of control over your idiots, but this can make them de-aggro in front of enemies and leave them defenseless. It works fine so it's your call, but keep it in mind.

- **He Is With Me:** also doesn't conflict but is redundant since a replacement with [slightly modified logic](#he-is-with-me) is already included.

- **Mora's Combat Ignore Military Fix:** overwrites core files and is not compatible. I made a replacement for this mod instead called [Cordon Truce](https://github.com/bellyillish/cordon-truce):

- **Settings -> Gameplay -> General:** If "Only Companions Can Loot and Gather Items" is enabled in the mod settings, I'd suggest turning "Corpse Loot Distance" down to 0-2m. If disabled Anomaly's default is fine but GAMMA's is a bit high (I'd suggest 5-6m)

- **NPCs Die in Emissions For Real:** Works fine but Useful Idiots replaces its cover behavior scheme with its own only for companions

- **TB Coordinate Based Surge Covers:** Works fine but companions will not use TB covers.

- **Dynamic Emission Cover:** Works fine as both mods' dynamic cover detectors will work alongside each other for the actor. DEC's HUD meter won't show Useful Idiots' dynamic covers however, and you may prefer to disable one or the other (Useful Idiots' dynamic cover detection can be disabled for the actor in MCM).

<br>

## Replacement UI

A new UI replaces the base game's Companion Wheel. The same keybind opens it. It includes:
- Central access to [all commands](#movement-commands) (no more digging through nested dialogs)
- Shows which commands are enabled and disabled at all times
- Tabs to issue commands to individual idiots or all at once
- Numeric indicators above idiots to show which tab is theirs

It behaves like the original companion wheel when opened:
- When pointing at an idiot the UI opens to that idiot's tab
- When pointing at nobody the UI opens to the "All" tab

<br>

## Keybinds and Modifiers

Every available command can be assigned to a key with alt/ctrl/shift and click/hold/double-tap modifiers. You can also choose whether keys enable a command, toggle it, or cycle through groups of related ones. [Some commands](#keyboard-only-commands) are only available using keybinds.

<br>

## Movement Commands
These control what your idiots do when they're not busy shooting at things.

### Follow
Like "Follow Me" but rewritten with [formation](#formations) support and new pathfinding. Idiots move like a single squad with you as leader. In enclosed spaces they stay closer to you and on the same side of walls. They avoid following you into cramped spaces unless you tell them to [stay near](#distances). Followers automatically sprint, crouch, go prone, and adjust their headlamps to match your actions (each can be disabled in MCM).
<a name="formations"></a>

#### You can assign followers to one of 4 formations:
- **Bunch:**   to randomly cluster behind you in a group
- **Spread:**  to spread out laterally behind you
- **Line:**    to follow behind you in single-file line
- **Covered:** to follow while staying in cover if possible
> [!TIP]
> You can only assign formations to an entire group (not to individual idiots).
<a name="distances"></a>

#### You can make them stay a certain distance from you:
- **Stay Near:** at least 2.5m away
- **Normal:**    at least   5m away
- **Stay Far:**  at least  10m away
<a name="stances"></a>

#### You can also assign them one of 3 stances:
- **Prone:** no crawl animation exists so they sneak when moving
- **Sneak**
- **Stand**

### Wait
Like "Wait Here" but without the constant staring, which makes them more useful as lookouts and less creepy. They perform idle activities when boredom sets in. Eventually you may catch them smoking, drinking, or sitting on the job.

### Find Cover
Idiots will look for nearby cover (relative to you) to hide and wait behind. If there's no suitable cover they will behave the same as "Wait".

### Relax
Idiots will look for a nearby campfire with room to sit. If none are nearby they will find a random location, usually indoors or with their backs to something. When relaxing they may smoke, drink, eat, use their PDA, or eventually nap.
> [!NOTE]
> My implementation is a bit different becuase it doesn't rely on base game's "camp" mechanics, which allows them to use any nearby campfire including ones you place with the "Placeable Campfires" mod.

### Patrol
Like "Patrol an Area" but they continue to loop through their waypoints instead of stopping at the last one.
> [!TIP]
> As in the base game, you must assign them 2 or more waypoints before you can use "Patrol". You can only [add waypoints](#waypoints) or assign "Patrol" to one Idiot at a time (not on the entire group).

<br>

## Combat Commands

These control what your idiots do when they *are* shooting at things. Idiots always do the following in all combat modes besides "Default Combat":

- Dodge grenades without disengaging
- Efficiently avoid friendly fire
- Locate enemies by sound
- Share enemy locations with each other
- Find and correctly position themselves behind partial (low/mid/high) cover
- Use augmented sight to see properly through anomalies and geometry issues

### Default Combat
Bypasses the mod and uses the vanilla engine-based combat system instead.

### Assault Combat
An offensive-geared combat mode inspired by the base game's "Monolith" scheme. Idiots pursue the enemy to a distance suitable for their weapon type. They attempt to flank enemies that are distracted by other NPCs. They switch strategies when fighting mutants, rush downed enemies, duck behind cover when reloading, fall back and recover when hurt, and search the surrounding area for lost enemies.

### Guard Combat
A defensive-geared combat mode inspired by the base game's "Camper" scheme. Idiots guard their initial position. They may move to improve their cover, reacquire an enemy, evade mutants, rush downed enemies, and duck behind cover when reloading, but always stay within a radius around their initial position.

### Support Combat
Very similar to "Guard Combat" except they guard your position instead of their initial position and move with you. They try their best to stay out of your line of fire (but accidents happen).
> [!TIP]
> [Stay near](#distances), [normal](#distances) and [stay far](#distances) keep them within 8m, 16m, and 24m of your position respectively.

### Sniper Combat
Keeps them fixed in their current position at all times. This mode is for when you want complete control over where they are positioned during combat or wish to guide them manually with [move to point](#keyboard-only-commands)
<a name="readiness"></a>

#### You can choose how your idiots respond to threats:
- **Attack Enemies:** engage enemies on sight
- **Defend Only:**    only engage enemies that attack you
- **Ignore Combat:**  ignore all enemies
<a name="weapon-type"></a>

#### You can tell them which weapon type to choose from their inventory:
- **Best:** determined by repair kit tier. Weapons without kits (like RPGs) are considered best. Ties are broken by comparing weapon cost.
- **Pistol**
- **Shotgun**
- **Rifle/SMG**
- **Sniper**
<a name="legacy-combat"></a>

#### You can also enable 3 additional combat modes from the base game:
- **Monolith**
- **Camper**
- **Zombied**
> [!CAUTION]
> These modes are functional but you may run into issues oddities. They come as-is and are not supported in any way. Consider them "bonus" content:

<br>

## Other Commands

### Waypoints
- **Add Waypoint:** assigns a patrol waypoint at your current position
- **Clear All Waypoints:** clears all patrol waypoints and switches them out of "Patrol"

### Headlamps
- **Lights On:** forces headlamps on
- **Lights Off:** forces headlamps off
- **Default Lights:** lets the base game or other mods control headlamps

### Toggles
- **Hurry:**                     forces them to run to their destination
- **Loot Corpses (on/off):**     lets them loot items from dead bodies
- **Gather Items (on/off):**     lets them pick up items lying around
- **Gather Artifacts (on/off):** lets them detect and retrieve nearby artifacts
- **Help Wounded:**              lets them heal wounded allies (including during combat)

### Utilities
- **Open Inventory:** opens their inventory (if they're less than 8 meters away)
- **Reload Weapons:** forces them to reload their active weapon, or all weapons if enabled in MCM
- **Retreat:** Sets [follow](#follow), [hurry](#toggles), [ignore Combat](#readiness), and [stay near](#distances) simultaneously (when you need to get your idiots out of trouble)
- **Unstick:** Triggers a fix for stuck or unresponsive idiots
- **Re-Sync:** Syncs idiots to the current state of the "All" tab

> [!TIP]
> Only the items your idiots pick up while looting or gathering are accessible when opening their inventories. All other items including their original primary weapon remain hidden from you.

> [!CAUTION]
> "Gather Artifacts" is disabled in MCM. Enabling it takes the fun out of artifact hunting and is technically cheating so use it with caution. In order to enable it "Gather Items" must also be enabled.

<br>

## Keyboard-Only Commands

These additional commands are only available via keyboard shortcut:

- **Select Companion:**    selects individual idiots to command with your cursor
- **Clear all Selected:**  clears all selected idiots to resume commanding all of them
- **Move to Point:**       tells idiots to move to your cursor
- **Look at Point:**       tells idiots to look at your cursor
- **Move Out of the Way:** tells idiots around your cursor to clear a path for you
- **Add Waypoint:**        assigns a patrol waypoint at your cursor

"Move to Point" affects idiots differently depending on which command is active:

- **Follow:**         moves to your cursor but resumes following when you move
- **Wait:**           moves directly to your cursor
- **Find Cover:**     takes cover near your cursor
- **Relax:**          finds a spot to relax near your cursor
- **Assault Combat:** moves to your cursor but resumes combat afterwards
- **Support Combat:** moves to your cursor but resumes combat afterwards
- **Guard Combat:**   moves to guard your cursor position
- **Sniper Combat:**  moves to your cursor and stays there

<br>

## Improvements and Fixes

Useful Idiots addresses lots of bugs, inconsistencies, and overall jank. Your idiots should feel much snappier and more responsive, pathfind better, respect personal space, and be less inclined to get stuck on random rocks and trees. They should spend more time following your orders and less time blankly staring at you.

Useful Idiots isn't meant to be an all-encompassing "Improved AI" mod. It mainly cares about what makes companions work better. That said, some fixes and improvements gave idiots an unfair advantage over their enemies. Some general AI improvements have been made in those cases to re-level the playing field, and it's possible for one or more to overlap with other AI-focused mods.

To this end, everything in Useful Idiots is done via DLTX, DXML, callbacks, and monkey patching. In the future you will also be able to individually disable anything that affects non-companions just in case you encounter weirdness with other mods.

<br>

## Base Game Changes

Source code for changes are commented and can be found [in here](https://github.com/bellyillish/useful-idiots/tree/main/gamedata/scripts/illish/patches).

- [Ignoring Combat (xr_combat_ignore)](#ignoring-combat-xr_combat_ignore)
- [Danger Detection (xr_danger)](#danger-detection-xr_danger)
- [Friendly Fire (rx_ff)](#friendly-fire-rx_ff)
- [Weapon Jamming (xr_weapon_jam)](#weapon-jamming-xr_weapon_jam)
- [Automatic Weapon Switching](#automatic-weapon-switching)
- [Melee Combat (xr_facer)](#melee-combat-xr_facer)
- [Reloading](#reloading)
- [Invalid Bone IDs](#invalid-bone-ids)
- [State Manager (state_mgr)](#state-manager-state_mgr)
- [Picking Up Weapons](#picking-up-weapons)
- [He is With Me](#he-is-with-me)
- [Items Manager](#items-manager)
- [Surge Behavior](#surge-behavior)

### Ignoring Combat (xr_combat_ignore)

Useful Idiots replaces `xr_combat_ignore.is_enemy()` to fix bugs and add the following improvements:

1. Hard-coded distance values have been moved to `xr_combat_ignore.ltx` (which is no longer unused)
2. Vision degrades *gradually* at night (6-9pm) and improves in the morning (3-6am)
3. Vision degrades *gradually* from rain strength
4. Night and rain effects now stack and affect all NPCs relatively the same
5. Companions and actor enemies have equal and consistent vision ranges for balance purposes

### Danger Detection (xr_danger)

Useful Idiots replaces `xr_danger.is_danger()` to a few fix bugs. Most are already fixed in GAMMA but included here as well for Anomaly. A long-standing GAMMA bug where neutral NPCs panic when you pass is also fixed. Idiots in the danger scheme don't respond to commands, so following changes were made specifically for them as a workaround:

1. Idiots only stay in danger mode for 4 seconds

2. Idiots don't enter danger mode when hearing something but will instead turn to look at the source

3. Idiots still enter danger mode to dodge grenades or react to being hit by gunfire but ignore all other sources of danger (like corpses)

### Friendly Fire (rx_ff)

NPCs enter this scheme way too early and often, stay in it way too long, and move in a way causes it to trigger over and over again. If you've ever witnessed a squad vs. squad conflict that looks more like a dance-off than an actual gunfight, this is probably why.

1. Added a 1.5s grace period to let allies pass by. If their LOF clears up before then they will immediately return to combat.

2. If their LOF does not clear they will strafe but a much shorter distance and re-enter combat as soon as their LOF has been clear for 500ms.

3. Allies have to be closer to the LOF in order to be considered "in the way"

4. Better-randomized strafing direction (coming soon)

### Weapon Jamming (xr_weapon_jam)

1. Fixed it being impossible to disable because it didn't parse its LTX file correctly.

2. Fixed a calculation error that made the first jam trigger a max chance of a 2nd jam immediately after.

3. Changed how NPC jam chance is calculated. Instead of a fixed per-shot percentage, it starts low and gradually increases as more rounds are spent (up to a max). Chance resets on each jam, and clip size is also taken into account to even it out among different gun types. It should now be very rare for multiple jams to happen in a row, and the overall frequency of NPC jams should feel much less absurd making them more effective in combat.

### Automatic Weapon Switching

The engine forces NPCs to switch weapons at certain distances, which would always trigger at the worst time and leave them vulnerable. If you've ever witnessed an NPC rush an enemy only to switch to an unloaded pistol or shotgun and immediately get blown up trying to reload it directly in front of them, or 2 enemies locked in a cycle of weapon switching and interrupted attempts at reloading instead of shooting each other, this is probably why.

1. Idiots always use their best weapon (based on [weapon type](#weapon-type)) and will never switch to another unless you tell them to. I plan to extend this to all NPCs in the future.

2. A hacky little fix was added to prevent taking your idiot's remaining weapon away (e.g. with "Show All Items in Companion Inventories" enabled) would get them temporarily stuck with empty hands. Now they switch back to the weapon(s) you give them afterwards.

### Melee Combat (xr_facer)

The config file for `xr_facer` was missing a few ranks which meant some NPCs would never use melee combat at close range and be at disadvantage vs. (possibly lower-ranked) NPCs that did. The missing ranks have been filled in so that everyone can use melee combat including your idiots.

### Reloading

1. NPCs don't reload after combat which puts them in a bad spot the next time around. Spending the first few seconds of a gunfight reloading your weapon in front of an enemy is rarely a good strategy, so Useful Idiots forces all NPCs to reload their weapon when empty.

2. NPC reload animations were fixed to no longer loop or repeat multiple times after their weapon is loaded. Non clip-fed weapons like shotguns are still not exactly right, but overall things are improved and NPCs should spend more time shooting and less time pretending to reload.

### Invalid Bone IDs

Some mutants have inconsistent and arbitrary names for their bone IDs (because of course they do). This can cause "Invalid Bone ID" errors and issues in scripts that rely on `utils_obj.safe_bone_pos()`. This affected Useful Idiots when calculating aim direction, detecting line of sight, and evaluating cover. A patch is included that tries to translate the asinine bone IDs into ones that are consistent with everything else and helps `utils_obj.safe_bone_pos()` return the correct bone information.

### State Manager (state_mgr)

1. The "prone" animation looks nicer when companions go into a prone position but looks janky when they move or turn. A patch is added to replace it with "prone_idle" after 1 second. Various other config fixes were also applied to make prone animations work properly.

2. `{fast_set = true}` is appended to all `state_mgr.set_state()` calls (unless explicitly set to `false` in the original call). This seems to make NPCs get stuck less and makes companions feel less sluggish when responding to commands.

3. When `state_mgr.set_state()` tells NPCs to look at a position with a very small magnitude (e.g. at their feet) the NPC can disappear into an alternate dimension and never be seen again. I accidentally did this a lot early on in development. As an extra safeguard I added a patch that detects and removes this when it happens. Just in case.

### Picking Up Weapons

NPCs no longer magically hoover up weapons off the ground with their toes. However if allowed to [gather items](#toggles) they will pick up weapons the correct way with a proper animation.

### He is With Me

Useful Idiots includes a modified replacement for this mod. My version uses the following logic:
1. Companions never fight other companions
2. Companions never fight NPCs that are not your enemy
3. NPCs that are not your enemy never fight companions

### Items Manager

Useful Idiots patches a typo in `itms_manager.actor_on_item_take()`. I have no idea what it does or if this makes any difference though.

### Surge Behavior

Companions now run from surges. An MCM option also toggles whether they can be hurt by them as well. Useful Idiots scans around objects on a map at load and around the actor when a surge starts for additional cover options for companions to use. A dynamic cover system has been written and works for both the actor and companions. Companions ignore combat until close to cover, and once in cover do not leave it to fight until after the surge ends. Companions prioritize cover near them vs. cover near the actor.

## Monkey Patching LUA Files

Do you want to patch something in `gamedata/illish/` for your own mod? It's actually just as easy, if not easier, than monkey patching a main-folder script file. As an example I'm going to choose a random function in a random file -- let's go with the function `VEC.pointsAlongAxis()` which is in `gamedata/illish/lib/vector.lua`.

> **SIDE NOTE:** If you want to use LUA "require" to import your own files into your mod, just make sure that your first folder inside of `gamedata/` is unique to you or your mod. This ensures it won't clash with another author's mod that wants to do the same. That's why I named mine "illish". Inside that folder you are free to organize and name your LUA files any way you wish (that's one of the nice things about it IMO because I'm a little OCD).

1. In your script, import the file the same way I did in my scripts:
   ```lua
   -- Step 1 --
   local VEC = require "illish.lib.vector"
   ```

2. Save a reference to the original function (assuming you want to call it in your patch):
   ```lua
   -- Step 1 --
   local VEC = require "illish.lib.vector"

   -- Step 2 --
   local pointsAlongAxis_patched = VEC.pointsAlongAxis
   ```

3. Replace it with your own function:
   ```lua
   -- Step 1 --
   local VEC = require "illish.lib.vector"

   -- Step 2 --
   local pointsAlongAxis_patched = VEC.pointsAlongAxis

   -- Step 3 --
   function VEC.pointsAlongAxis(options)
     -- Do whatever you want here. For this example I'll just
     -- change one of its default options to something else
     -- (not super recommended, but again just as an example)

     -- Because it's possible for 'options' to be nil:
     options = options or {}

     -- Change this from '180':
     options.arcAngle = 360

     -- Call the original (don't forget to 'return' of course):
     return pointsAlongAxis_patched(options)
   end
   ```

And that's all there is to it, easy peasy. Now everything that calls `VEC.pointsAlongAxis()` expecting to get a 180� arc of points will now get a full 360� circle of points instead. Surprise, bitches.

### Wait, so is monkey patching always that easy?

It really is. Any top-level variable, object or function without `local` in front of it, in any script, can be patched or replaced in your script without needing to replace the whole file. It's one of the 3-4 pillars to keeping your mod compatible with other mods. [See this for more info](https://igigog.github.io/anomaly-modding-book/tutorials/scripting/monkey-patching.html).

It's still possible to reach things with `local` in front. It's just a tiny bit more work and [is covered here](https://igigog.github.io/anomaly-modding-book/tutorials/addons/lua-unlocalizer.html?highlight=unlocalize#lua-variables-unlocalizer).
