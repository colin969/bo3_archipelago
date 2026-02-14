#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;

#using scripts\shared\lui_shared;
#using scripts\zm\_zm_score;

#namespace archi_core;

REGISTER_SYSTEM("archipelago_core", &__init__, undefined)

function __init__()
{
    level._ap_weapon_data = [];
    level._ap_weapon_bits = [];
    mapname = tolower(getdvarstring("mapname"));
    switch (mapname) {
        case "zm_zod":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_zod_weapons.csv";
            level._ap_weapon_bits["idgun_0"] = 0;
            level._ap_weapon_bits["octobomb"] = 1;
            level._ap_weapon_bits["ray_gun"] = 2;
            add_universal_box_bits();
            break;
        case "zm_castle":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_castle_weapons.csv";
            level._ap_weapon_bits["cymbal_monkey"] = 0;
            level._ap_weapon_bits["ray_gun"] = 1;
            add_universal_box_bits();
            break;
        case "zm_island":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_island_weapons.csv";
            level._ap_weapon_bits["cymbal_monkey"] = 0;
            level._ap_weapon_bits["ray_gun"] = 1;
            level._ap_weapon_bits["hero_mirg2000"] = 2;
            add_universal_box_bits();
            break;
        case "zm_stalingrad":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_stalingrad_weapons.csv";
            level._ap_weapon_bits["cymbal_monkey"] = 0;
            level._ap_weapon_bits["ray_gun"] = 1;
            level._ap_weapon_bits["raygun_mark3"] = 2;
            add_universal_box_bits();
            break;
        case "zm_genesis":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_genesis_weapons.csv";
            level._ap_weapon_bits["idgun_genesis_0"] = 0;
            level._ap_weapon_bits["octobomb"] = 1;
            level._ap_weapon_bits["hero_gravityspikes_melee"] = 2;
            level._ap_weapon_bits["thundergun"] = 3;
            level._ap_weapon_bits["ray_gun"] = 4;
            add_universal_box_bits();
            break;
        case "zm_factory":
            level._ap_weapons_table = "gamedata/weapons/zm/zm_factory_weapons.csv";
            level._ap_weapon_bits["cymbal_monkey"] = 0;
            level._ap_weapon_bits["ray_gun"] = 1;
            level._ap_weapon_bits["tesla_gun"] = 2;
            add_universal_box_bits();
            break;
    }

    // Read weapons table into what we need ahead of time
    if (isdefined(level._ap_weapons_table))
    {
        index = 1;
        row = tablelookuprow(level._ap_weapons_table, index);
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
		    row = tablelookuprow(level._ap_weapons_table, index);
        }
    }

    clientfield::register("world", "ap_mystery_box_changes", 1, 28, "int", &update_mystery_box, 0, 0);
}

function update_mystery_box( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
    if (level._ap_weapon_data.size > 0)
    {
        // Reset box and add back weapons we know are in there
        ResetZombieBoxWeapons();
        foreach (weapon_data in level._ap_weapon_data)
        {
            if(isdefined(weapon_data.in_box) && !weapon_data.in_box)
            {
                continue;
            }

            // Check if we're a potentially removed weapons
            if (isdefined(level._ap_weapon_bits[weapon_data.name]))
            {
                bitmask = 1 << level._ap_weapon_bits[weapon_data.name];
                is_removed = (newval & bitmask) != 0;
                if (is_removed)
                {
                    continue;
                }
            }

            weapon = GetWeapon(weapon_data.name);
            AddZombieBoxWeapon(weapon, weapon.worldmodel, weapon.isdualwield);
        }
    }
}

function add_universal_box_bits()
{
    level._ap_weapon_bits["ar_famas"] = 15; // FFAR
    level._ap_weapon_bits["sniper_fastsemi"] = 16; // Drakon
    level._ap_weapon_bits["sniper_fastbolt"] = 17; // Locus
    level._ap_weapon_bits["ar_damage"] = 18; // Man-o-War
    level._ap_weapon_bits["ar_cqb"] = 19; // HVK-30
    level._ap_weapon_bits["ar_accurate"] = 20; // ICR-1
    level._ap_weapon_bits["shotgun_fullauto"] = 21; // Haymaker 12
    level._ap_weapon_bits["shotgun_semiauto"] = 22; // 205 Brecci
    level._ap_weapon_bits["lmg_cqb"] = 23; // Dingo
    level._ap_weapon_bits["lmg_heavy"] = 24; // 48 Dredge
    level._ap_weapon_bits["lmg_rpk"] = 25; // RPK
    level._ap_weapon_bits["smg_versatile"] = 26; // VMP
    level._ap_weapon_bits["smg_fastfire"] = 27; // Vesper
}

function checkStringValid( str )
{
	if( str != "" )
		return str;
	return undefined;
}