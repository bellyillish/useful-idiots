# Useful Idiots for Anomaly and GAMMA

Overhauls the companion system with:

- Over 50 commands to control them
- A dynamic and customizable UI replacement for the Companion Wheel
- Extensive support for keybinds and modifiers (powered by MCM)
- Lots of AI improvements and bug fixes (some for companions and some for all NPCs)

Does not (and never will) overwrite any core files to keep it as compatible as possible out of the box with other mods.

## Installation Requirements

- Requires [Modded EXEs](https://github.com/themrdemonized/xray-monolith/releases)
- Requires [Mod Configuration Menu](https://www.moddb.com/mods/stalker-anomaly/addons/anomaly-mod-configuration-menu)
- Safe to add or remove whenever

## Installation Instructions

1. Download the ZIP file from here or [GitHub Releases](https://github.com/bellyillish/useful-idiots/releases).

2. Install it with [Mod Organizer 2](https://anomalymodding.blogspot.com/2021/04/Mod-Organizer-2-setup-and-Amomaly-modding-guide.html).

It is included with GAMMA but is strongly enouraged either way. Priority doesn't matter for Anomaly. For GAMMA just put it below the mods that come with it.

3. Go to **Mod Configuration Menu -> Useful Idiots** to customize and configure to your liking.

## Known Conflicts

- **NPC Stops Dropping Weapons and Looting Dead Bodies** interferes with looting and gathering. Instead, an MCM option is included that does the exact same thing. By default it is enabled if running GAMMA and disabled otherwise.

- **NPC Use Grenade Launchers:** contains a syntax error that crashes scripts in the base game. Useful Idiots relies on one of these scripts so using the two together will result in a CTD. I'd recommend avoiding that mod entirely until it is fixed and properly tested.

- **Companion Anti AWOL for Anomaly:** doesn't conflict but can get in the way. You'll have plenty of control over your idiots, and this mod can leave them vulnerable by making them de-aggro in front of enemies at inopportune times. It still works so it's your call, but keep this in mind.

- **He Is With Me:** also doesn't conflict but is redundant. A replacement is included (with some minor changes to the original's behavior).

- **Settings -> Gameplay -> General:** If "Only Companions Can Loot and Gather Items" is enabled in the mod settings, I'd suggest turning "Corpse Loot Distance" down to 0-2m. If disabled the Anomaly default is fine but GAMMA's is a bit high (I'd suggest 5-6m)

## Features and Commands

See the GitHub README for full documentation of features and commands.

## Improvements

Useful Idiots addresses lots of bugs, inconsistencies, and overall jank. Your idiots should feel much snappier and more responsive, pathfind better, respect personal space, and be less inclined to get stuck on random rocks and trees. They should spend more time following your orders and less time blankly staring at you.

Useful Idiots isn't meant to be an all-encompassing "Improved AI" mod. It mainly cares about what makes companions work better. That said, some fixes and improvements gave idiots an unfair advantage over their enemies. Some general AI improvements have been made in those cases to re-level the playing field, and it's possible for one or more to overlap with other AI-focused mods.

To this end, everything in Useful Idiots is done via DLTX, DXML, callbacks, and monkey patching. In the future you will also be able to individually disable anything that affects non-companions just in case you encounter weirdness with other mods.

- Details on what changes are made to the base game [are here](#).
- Changes are commented and can be found [in here](https://github.com/bellyillish/useful-idiots/tree/main/gamedata/scripts/illish/patches).
