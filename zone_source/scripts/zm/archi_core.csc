#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\lui_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_score;

#using scripts\zm\archi_items;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;

#namespace archi_core;

REGISTER_SYSTEM("archipelago_core", &__init__, undefined)

function __init__()
{
    level._ap_weapon_data = [];
    level._ap_weapon_bits = [];

    mapName = GetDvarString( "mapname" );
    level._ap_mapname = mapName;

    level._ap_weapons_vanilla = 1;
    level._ap_weapons_special = 1;
    level._ap_weapons_expanded = 0;

    switch (mapName) {
        case "zm_zod":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_zod_weapons.csv";
            break;
        case "zm_castle":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_castle_weapons.csv";
            break;
        case "zm_island":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_island_weapons.csv";
            break;
        case "zm_stalingrad":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_stalingrad_weapons.csv";
            break;
        case "zm_genesis":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_genesis_weapons.csv";
            break;
        case "zm_factory":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_factory_weapons.csv";
            break;
        case "zm_theater":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_theater_weapons.csv";
            break;
        case "zm_westernz":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_westernz_weapons.csv";
            break;
    }

    // Read weapons table into what we need ahead of time
    if (isdefined(level._ap_weapons_table))
    {
        custom_load_csv(level._ap_weapons_table);
    }

    clientfield::register("world", "ap_mystery_box_changes", 1, 31, "int", &update_mystery_box, 0, 0);
    clientfield::register("world", "ap_box_contents", 1, 3, "int", &update_mystery_box_settings, 0, 0);
}

function custom_load_csv(table)
{
    index = 1;
    row = tablelookuprow(table, index);
    while (isdefined(row))
    {
        weapon_name = checkStringValid(row[0]);
        upgrade_name = checkStringValid(row[1]);
        in_box = tolower(row[9]) == "true";
        upgrade_in_box = tolower(row[10]) == "true";

        weapon_data = SpawnStruct();
        weapon_data.name = weapon_name;
        weapon_data.in_box = in_box;
        level._ap_weapon_data[level._ap_weapon_data.size] = weapon_data;
        if (isdefined(upgrade_name))
        {
            upgrade_weapon_data = SpawnStruct();
            upgrade_weapon_data.name = upgrade_name;
            upgrade_weapon_data.in_box = upgrade_in_box;
            level._ap_weapon_data[level._ap_weapon_data.size] = upgrade_weapon_data;
        }
        index++;
        row = tablelookuprow(table, index);
    }
}

function update_mystery_box_settings( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
    level._ap_weapons_vanilla = (newval & 1) != 0;
    level._ap_weapons_special = (newval & 2) != 0;
    level._ap_weapons_expanded = (newval & 4) != 0;

    level._ap_weapon_bits = archi_items::get_box_bit_table(level._ap_mapname, level._ap_weapons_vanilla, level._ap_weapons_special, level._ap_weapons_expanded);
    cur_box_value = level clientfield::get("ap_mystery_box_changes");
    update_mystery_box(localclientnum, 0, cur_box_value, 0, 0, "", 0);
}

function update_mystery_box( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
    IPrintLnBold("CHANGING");
    added_weapons = 0;
    if (level._ap_weapon_data.size > 0)
    {
        // Reset box and add back weapons we know are in there
        ResetZombieBoxWeapons();
        foreach (weapon_data in level._ap_weapon_data)
        {
            // Check if we're a registered weapon
            if (isdefined(level._ap_weapon_bits[weapon_data.name]))
            {
                if (level._ap_weapon_bits[weapon_data.name] > 30)
                {
                    continue;
                }
                bitmask = 1 << level._ap_weapon_bits[weapon_data.name];
                is_available = (newval & bitmask) != 0;
                if (!is_available)
                {
                    continue;
                }
            }
            else if (isdefined(weapon_data.in_box) && !weapon_data.in_box)
            {
                continue;
            }

            weapon = GetWeapon(weapon_data.name);
            AddZombieBoxWeapon(weapon, weapon.worldmodel, weapon.isdualwield);
            added_weapons++;
        }

        IPrintLnBold("Set box weapons for " + added_weapons);

        if (added_weapons == 0)
        {
            // No bit passed weapon added visually, we need to add something
            weapon = GetWeapon(level._ap_weapon_data[0].name);
            AddZombieBoxWeapon(weapon, weapon.weaponmodelname, weapon.isdualwield);
        }
    }
}

function checkStringValid( str )
{
	if( str != "" )
		return str;
	return undefined;
}