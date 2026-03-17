# Adding a Map

Most of the time The Giant (zm_factory) acts as a good reference point for basic functionality.

Very rough overview of where to look and what to add:

## GSC + Lua / BO3 Mod

### GSC

Make a copy of `archi_map_template.gsc` to `archi_mapname.gsc` and edit the 3 references to `zm_yourmap` to whatever your map name is

`archi_mapname.gsc` - Each map has it's save/load functions, and any map specific functionality in its own named script file.
  - Name of the Map Unlock item
  - Craftables
  - Spare change trackers
  - Mystery Box Special + Regular
  - Machines
  - Wallbuys
  - Archipelago Shop Spawns
  - Save and Load pointers
`archi_core.gsc` - This is where you'll register most AP items for each map, initialize your map, and set pointers for save/load functions.
  - Import your map's script `#using scripts\zm\archi_mapname;`
  - Add an entry for your map script to `zm_mod.zone` so it's included when building the mod `scriptparsetree,scripts/zm/archi_mapname.gsc`
`archi_core.gsh` - Definitions, basically all string definitions. Keep your map string here like you'll see others do.

#### Adding Checks

For official maps, you'll want the decompiled official scripts to reference. https://github.com/shiversoftdev/t7-source

You can usually fit a check into a few different places:
- Level flags
  - Flag names aren't obfuscated, which makes them really good candidates where possible
  - You can find `level flag::init` blocks at the top of most scripts. Following for `level flag::set` or `level flag::wait_till` will give you a better idea of when it's set
  - You can catch single flags - E.G `level flag::wait_till("snow_ee_completed")` for The Giant's secret perk
  - You can catch multiple flags
    - E.G `level flag::wait_till_any(array("teleporter_pad_link_1", "teleporter_pad_link_2", "teleporter_pad_link_3"))` for any of the 3 The Giant teleporter pads being linked
    - E.G `level flag::wait_till_all(array("ee_perk_bear", "ee_bowie_bear", "ee_exp_monkey"));` for all 3 of the toys being shot in The Giant's Fly Trap easter egg
- Notifications
  - Notification names are usually obfuscated, so it's harder to understand why they fire. Sometimes they just don't behave **at all** so it ends up a waste of time testing one.
  - Sometimes levels will use notify to handle multiple actions being required to progress. Commonly this will be for music easter eggs, but it depends. E.G `level waittill("hash_a1b1dadb");` will catch the notification for The Giant music ee.

Be sure to see existing map scripts for practical examples.

You can also create threads attached to players, to track things like player specific notifications, or monitor player state, e.g `self waittill("weapon_change", weapon)`. This is very rare to need, but you can view examples in existing map scripts.
### Lua

The lua (UI driven) scripts are responsible for passing save data to and from the game, so needs to match your save/load from gsc. Lua is how we can exploit loading a dll and making filesystem and networking changes. As usual, refer to The Giant (zm_factory)

The only file you'll usually need to touch is `archipelago/Save.lua`. Refer to the very bottom for the 4 functions to add.

# General Notes

Decompiled scripts preface strings with `#`, e.g `level flag::get(#"ee_step_complete")`. You do not need the hash if using the same names in your own script, infact it will break if you do.