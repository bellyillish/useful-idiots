<!--
> [!TIP]
> ƒокументаци€ на русском €зыке доступна [здесь](README_ru.md).
-->

# Useful Idiots

Overhauls the companion system with:

- [Over 50 commands](#commands) to control them
- A dynamic and customizable [UI replacement](#new-companion-ui) for the Companion Wheel
- Extensive support for [keybinds and modifiers](#extensive-keyboard-support) (powered by MCM)
- Lots of AI [improvements and bug fixes](#improvements-and-fixes) (some for companions and some for all NPCs)

Does not (and never will) overwrite any core files to keep it as compatible as possible out of the box with other mods.

### Installation Requirements

- Requires [Modded EXEs](https://github.com/themrdemonized/xray-monolith/releases)
- Requires [Mod Configuration Menu](https://www.moddb.com/mods/stalker-anomaly/addons/anomaly-mod-configuration-menu)
- Safe to add or remove whenever

### Installation Instructions

1. Download the ZIP file from here or [GitHub Releases](https://github.com/bellyillish/useful-idiots/releases).
2. Install it with [Mod Organizer 2](https://anomalymodding.blogspot.com/2021/04/Mod-Organizer-2-setup-and-Amomaly-modding-guide.html).
It is included with GAMMA but is strongly enouraged either way. Priority doesn't matter for Anomaly. For GAMMA just put it below the mods that come with it.
3. Go to **Mod Configuration Menu -> Useful Idiots** to customize and configure to your liking.

### Known Conflicts

- **NPC Stops Dropping Weapons and Looting Dead Bodies** interferes with looting and gathering. Instead, an MCM option is included that does the exact same thing. By default it is enabled if running GAMMA and disabled otherwise.

- **NPC Use Grenade Launchers:** contains a syntax error that crashes scripts in the base game. Useful Idiots relies on one of these scripts so using the two together will result in a CTD. I'd recommend avoiding that mod entirely until it is fixed and properly tested.

- **Companion Anti AWOL for Anomaly:** doesn't conflict but can get in the way. You'll have plenty of control over your idiots, and this mod can leave them vulnerable by making them de-aggro in front of enemies at inopportune times. It still works so it's your call, but keep this in mind.

- **He Is With Me:** also doesn't conflict but is redundant. A replacement is included (with some [minor changes](#he-is-with-me) to the original's behavior).

- **Settings -> Gameplay -> General:** If "Only Companions Can Loot and Gather Items" is enabled in the mod settings, I'd suggest turning "Corpse Loot Distance" down to 0-2m. If disabled the Anomaly default is fine but GAMMA's is a bit high (I'd suggest 5-6m)

<br>

## Replacement UI

A new UI replaces the base game's Companion Wheel and is opened with the same keybind. It includes:

- Tabbed access to issue commands globally or to individual companions
- Shows which commands are currently enabled and disabled at all times
- Central access to [all commands](#commands) (no more digging through nested dialogs)
- When the UI is open, numeric indicators show which tab belongs to which idiot

The new UI behaves like the Companion Wheel when opened:
- When pointing at an idiot the UI opens to that idiot's tab
- When pointing at nobody the UI opens to the "All" tab which issues comands to all idiots

<br>

## Keybinds and Modifiers

Every available command can be assigned a keybind with alt/ctrl/shift modifiers. Separate keybinds can be assigned to cycle through groups of related commands. There are also a [subset of commands](#keyboard-only-commands) that are *only* available though keybinds.

<br>

## Movemement Commands
These control what your idiots do when they're not busy shooting at things.

### Follow
Like "Follow Me" but rewritten with new pathfinding and [formation](#you-can-assign-followers-to-one-of-4-formations) support. Idiots move like a single squad with you as leader. They stay closer and on the same side of walls and obstacles in enclosed spaces. They avoid following you into cramped spaces unless you tell them to [stay near](#you-can-make-them-stay-a-certain-distance-from-you). Followers automatically sprint, crouch, go prone, and adjust their headlamps to match your actions (all of which can be disabled in MCM).

#### You can assign followers to one of 4 formations:
- **Bunch:**   to randomly cluster behind you in a group
- **Spread:**  to spread out laterally behind you
- **Line:**    to follow behind you in single-file line
- **Covered:** to follow while staying in cover if possible
> [!NOTE]
> You can only assign formations to an entire group (not to individual idiots).

#### You can make them stay a certain distance from you:
- **Stay Near:** at least 2.5m away
- **Normal:**    at least   5m away
- **Stay Far:**  at least  10m away

#### You can also assign them one of 3 stances:
- **Stand**
- **Sneak**
- **Prone:**
> [!NOTE]
> Idiots sneak while moving because no crawl animation exists

### Wait
Like "Wait Here" but without the constant staring. This makes them more useful as lookouts and less creepy. They perform idle activities as boredom sets in. Eventually you may catch them smoking, drinking, or sitting on the job.

### Find Cover
Idiots will look for nearby cover (relative to you) to wait behind. If there's no suitable cover they will behave the same as [Wait](#wait).

### Relax
Idiots will look for a nearby campfire with room to sit. If none are nearby they will find a random location, usually indoors or with their backs to something. When relaxing they may smoke, drink, eat, use their PDA, and eventually nap.
> [!NOTE]
> Unlike many other implementations this does not rely on base game "camp" mechanics. This allows them to use any nearby campfire including ones you place with the "Placeable Campfires" mod.

### Patrol
Like "Patrol an Area" but they keep patrolling between their waypoints rather than stopping at the last one.
> [!NOTE]
> Like in the base game, you must assign them 2 or more waypoints before you can use "Patrol". You can only [Add Waypoints](#waypoints) or assign "Patrol" to one Idiot at a time (not on the entire group).

<br>

<!--  -- >
# Combat Commands
These control what your idiots do when they *are* shooting at things. Idiots do the following things in all combat modes besides "Default Combat":

- Dodge grenades without disengaging
- Efficiently avoid friendly fire
- Locate enemies by sound
- Share enemy locations with each other
- Find and correctly position themselves behind partial (low/mid/high) cover
- Use augmented sight to see properly through anomalies and geometry jank

## Default Combat
Bypasses the mod and uses the vanilla engine-based combat system instead.

## Assault Combat
An offensive-geared combat mode inspired by the base game's "Monolith" scheme. Idiots pursue the enemy to a distance suitable for their weapon type. They attempt to flank enemies that are distracted by other NPCs. They switch strategies when fighting mutants, rush downed enemies, duck behind cover when reloading, fall back and recover when hurt, and search the surrounding area for lost enemies.

## Guard Combat
A defensive-geared combat mode inspired by the base game's "Camper" scheme. Idiots guard their initial position. They may move to improve their cover, reaquire an enemy, evade mutants, rush downed enemies, and duck behind cover when reloading, but always stay within a radius around their initial position.

## Support Combat
Very similar to "Guard Combat" except they guard your position instead of their initial position and move with you. They try their best to stay out of your line of fire but accidents happen.
> [!TIP]
> [Stay Near](#you-can-make-them-stay-a-certain-distance-from-you), [Normal](#you-can-make-them-stay-a-certain-distance-from-you) and [Stay Far](#you-can-make-them-stay-a-certain-distance-from-you) keep them within 8m/16m/24m of your position respectively.

## Sniper Combat
Keeps them fixed in their current position at all times. This mode is for when you want complete control over where they are positioned during combat or wish to guide them manually with [Move to Point](#keyboard-only-commands)

### You can choose how your idiots respond to threats:
- **Attack Enemies:** engage enemies on sight
- **Defend Only:**    only engage enemies that attack you
- **Ignore Combat:**  ignore all enemies

### You can tell them which weapon type to choose from their inventory:
- **Best:**
- **Pistol**
- **Shotgun**
- **Rifle/SMG**
- **Sniper**
> [!NOTE]
> "Best" is determined by repair kit tier. Weapons without kits (like RPGs) are considered best. Ties are broken by comparing weapon cost.

### You can also enable 3 additional combat modes from the base game:
- **Monolith**
- **Camper**
- **Zombied**
> [!CAUTION]
> These modes are functional but you may run into issues and general jank. They come as-is and are not supported in any way. Consider them "bonus" content:

<br>

# Other Commands

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
- **Help Wounded:**              lets them heal wounded friendlies (including during combat)

### Utilities
- **Open Inventory:** opens their inventory (if they're less than 8 meters away)
- **Reload Weapons:** forces them to reload their active weapon, or all weapons if enabled in MCM
- **Retreat:** Sets [Follow](#follow), [Hurry](#toggles), [Ignore Combat](#you-can-choose-how-your-idiots-respond-to-threats), and [Stay Near](#you-can-make-them-stay-a-certain-distance-from-you) simultaneously (when you need to get your idiots out of trouble)
- **Unstick:** Triggers a fix for stuck or unresponsive idiots
- **Re-Sync:** Syncs idiots to the current state of the "All" tab

> [!NOTE]
> Only the items your idiots pick up while looting or gathering are accessible when opening their inventories. All other items including their original primary weapon remain hidden from you.

> [!CAUTION]
> "Gather Artifacts" is disabled in MCM. Enabling it takes the fun out of artifact hunting and is technically cheating so use it with caution. In order to enable it "Gather Items" must also be enabled.

# Keyboard-Only Commands

These additional commands are only available via keyboard shortcut.
- **Select Companion:**    selects individual idiots to apply your next command to
- **Clear all Selected:**  clears all selected idiots so subsequent commands affect all of them
- **Move to Point:**       tells idiots to move to your cursor
- **Look at Point:**       tells idiots to look at your cursor
- **Move Out of the Way:** tells idiots around your cursor to clear a path for you
- **Add Waypoint:**        assigns at waypoint at your cursor

"Move to Point" affects idiots differently depending on which command is active:
- **Follow:**         moves to your cursor but resumes following when you move
- **Wait:**           moves directly to your cursor
- **Find Cover:**     takes cover near your cursor
- **Relax:**          finds a spot to relax near your cursor
- **Assault Combat:** moves to your cursor but resumes combat afterwards
- **Support Combat:** moves to your cursor but resumes combat afterwards
- **Guard Combat:**   moves to guard your cursor position
- **Sniper Combat:**  moves to your cursor and stays there

<!-- -- >
<br>

# Improvements and Fixes

Useful Idiots addresses lots of bugs, inconsistencies, and overall jank. Generally speaking your idiots should feel much snappier and more responsive, pathfind better, respect personal space, and be less inclined to get stuck on random rocks and trees. They should spend more time following your orders and less time blankly staring at you.

This mod is not meant to be an all-encompassing "Improved AI" mod. That said, there are many issues in the codebase that affect how well companions work, and Useful Idiots tries to address as many as possible in order to improve the experience. Some things once fixed give your idiots an unfair advantage over other NPCs. In those cases, Useful Idiots does make AI Improvements that affect all NPCs in order to re-level the playing field. Some might overlap and interact with other "Improved AI" mods.

One thing I refuse to do is overwrite base game files. Everything in Useful Idiots is done via DLTX, DXML, callbacks, and monkey patching. This makes it as compatible as possible with other mods. Since I plan to add or extend more fixes, improvements, and things like custom combat modes to all NPCs, in the future you will be able to configure anything affecting non-companion NPCs so it can be disabled if it interferes with another mod's AI improvements.

Here are some specifics on what Useful Idiots touches:

- ### Ignoring Combat (xr_combat_ignore)

  Useful Idiots replaces `xr_combat_ignore.is_enemy()` because it is filled with too many bugs to monkey patch. (Four significant ones that affect gameplay at last count). While fixing bugs the following improvements were also added:

  - Hard-coded distance values have been moved to `xr_combat_ignore.ltx` (which is no longer unused)
  - Vision degrades *gradually* at night (6-9pm) and improves in the morning (3-6am)
  - Vision degrades *gradually* from rain strength
  - Night and rain effects now stack and affect all NPCs relatively the same
  - Companions and actor enemies have equal and consistent vision ranges for balance purposes

- ### Danger Detection (xr_danger)

  Useful Idiots replaces `xr_danger.is_danger()` because it also has a few scattered bugs and issues. Most of these are fixed in G.A.M.M.A. but are included to fix Anomaly as well. A long-standing G.A.M.M.A. bug where neutral NPCs randmonly panic when you pass by has also been fixed.

  The "danger" scheme also prevents you from controlling your idiots until they either enter combat or the danger passes. To fix this the following changes were made only to companions:

  - They only stay in "danger" for 4 seconds
  - They don't enter "danger" when hearing something but will instead turn to look at the source
  - They still enter "danger" to dodge grenades or react to being hit by gunfire but ignore all other sources of danger (like corpses)

- ### Friendly Fire (rx_ff)

  LOL, this scheme. To summarize, NPCs enter this scheme way too early and often, stay in it way too long, and move in a way causes it to trigger over and over again. The entire time they are out of combat and thus not firing their weapon. If you've ever witnessed a squad vs. squad conflict that looks more like a dance-off than an actual gunfight, this is probably the reason why.

  After I added my own friendly-fire behavior to the custom combat modes I noticed that companions would just mop the floor with squads of much stronger enemies. When I realized this was why I felt the need to fix `rx_ff` as well to balance things back out. I made these changes:

  1. Added a 1.5s grace period to let friendlies pass by. If their LOF clears up before then they will immediately return to combat.
  2. If their LOF does not clear they will strafe but a much shorter distance (10-12m is absurd) and re-enter combat as soon as their LOF has been clear for 500ms (instead of 2.5s)
  3. Friendlies have to be closer (0.8m instead of 2m) in order to be considered "in the way"

  One fix is still needed but not done yet (more random strafe direction). As is now though it's easily the biggest impact on combat out of everything on this list.

- ### Weapon Jamming (xr_weapon_jam)

  Another gem. The original didn't parse its LTX correctly and was impossible to disable. That's been fixed. I also fixed a calculation error that made the first jam trigger a max chance of a 2nd jam immediately after. I also changed how jam chance is calculated for NPCs. Instead of a fixed per-shot percentage, it starts low and gradually increases as more rounds are spent (up to a max). Chance resets on each jam, and clip size is also taken into account to even it out among different gun types. It should now be very rare for multiple jams to happen in a row, and the overall frequency of NPC jams should feel much less absurd making them more effective in combat.

- ### Automatic Weapon Switching

  One thing the game engine really liked to do was force NPCs to switch weapons at certain distances. It would always trigger at the worst times and leave them vulnerable. If you've ever witnessed an NPC rush an enemy only to switch to an unloaded pistol or shotgun and immediately get blown up trying to reload it directly in front of them, or 2 enemies locked in a cycle of weapon switching and interrupted attempts at reloading instead of shooting each other, this is probably why.

  Useful Idiots forces them to always use their best weapon based on your chosen type and will never switch to another unless you tell them to. So far this is only fixed for companions, but I plan to extend it to all NPCS at some point.

  I also added a little hacky fix where taking away their only remaining weapon (e.g. with "Show All Items in Companion Inventories" enabled) would cause them to get temporarily stuck with empty hands. Now they immediately switch to whatever weapon you give them afterwards.

- ### Melee Combat (xr_facer)

  The config file for `xr_facer` was missing a few ranks which meant some NPCs would never use melee combat at close range and be at the mercy of (possibly lower-ranked) NPCs that did. Those missing ranks have been filled in so that everyone can use melee combat. Your idiots also use melee combat now as well.

- ### Reloading

  NPCs don't think to reload after combat which puts them in a bad spot the next time around. Spending the first few seconds of a gunfight reloading your weapon in front of an enemy is rarely a good strategy, so Useful Idiots forces all NPCs to reload their weapon when empty regardless of what scheme they are in.

  NPC reload animations were also fixed to no longer loop or repeat multiple times or continue after their weapon is loaded. It's not a perfect fix -- non clip-fed weapons like shotguns are still a little goofy, but overall it is much improved and NPCs will spend more time shooting and less time stuck in a reload animation.

- ### Invalid Bone IDs

  Some mutants have inconstent and arbitrary names for their bone IDs (because of course they do). This can cause "Invalid Bone ID" errors and issues in scripts that rely on `utils_obj.safe_bone_pos()`. This affected Useful Idiots when calculating aim direction, detecting line of sight, and evaluating cover. A patch is included that tries to translate asinine bone IDs into ones that are consistent with everything else and helps `utils_obj.safe_bone_pos()` return the correct bone information.

- ### State Manager (state_mgr)

  The "hide" and "prone" animations look nicer when companions go into a crouched or prone position but look janky when they move or turn, so their "hide_na" and "prone_idle" counterparts are often used instead. A patch is added to replace the former with the latter after 1 second to get the best of both worlds. Various other config fixes were also applied to make prone animations work properly.

  Useful Idiots also appends `{fast_set = true}` to all `state_mgr.set_state()` calls (unless explicitly set to `false` in the original call). This seems to make companions feel less sluggish when responding to commands.

  Lastly, when `state_mgr.set_state()` tells NPCs to look in a direction with a very small magnitude (e.g. at their feet) the NPC can disappear into an alternate dimension and never be seen again. I accidentally did this a lot early on in development. As an extra safeguard I added a patch that detects and removes this when it happens. Just in case.

- ### Picking Up Weapons

  NPCs no longer magically hoover up weapons off the ground with their toes. However if allowed to gather items, they will pick up weapons the correct way with a proper animation.

- ### He is With Me

  Useful Idiots includes a modified replacement for this popular and awesome mod. My version makes the following changes:
  - Companions will never fight other companions
  - Companions will never fight NPCs that are not your enemy
  - NPCs that are not your enemy will never fight companions
<!-- -->
