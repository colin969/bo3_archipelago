#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\math_shared;
#using scripts\shared\laststand_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\archi_mappings;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_perks.gsh;

#insert scripts\zm\archi_core.gsh;

#namespace archi_items;

function get_weapon_table_name(mapName)
{
    switch (mapName) {
        case "zm_westernz":
            return "zm_westernz";
        default:
            return "vanilla";
    }
}

function RegisterMapWeapons(mapName)
{
    map_data = get_map_weapon_lists(mapName);
    table = get_weapon_table_name(mapName);

    if (isdefined(map_data))
    {
        foreach(weapon in map_data.vanilla)
        {
            item_name = archi_mappings::get_weapon_item_name(weapon, table);
            RegisterWeapon(item_name, weapon);
        }

        foreach(weapon in map_data.expanded)
        {
            item_name = archi_mappings::get_weapon_item_name(weapon, table);
            RegisterWeapon(item_name, weapon);
        }

        foreach(weapon in map_data.special)
        {
            item_name = archi_mappings::get_weapon_item_name(weapon, table);
            RegisterWeapon(item_name, weapon);
        }
    }
}

function RegisterWeapon(itemName, weapon_name)
{
    item = SpawnStruct();
    item.type = "weapon";
    item.name = level.archi.mapString + " " + itemName;
    item.weapon_name = weapon_name;
    item.count = 0;

    level.archi.wallbuy_mappings[weapon_name] = itemName;
    level.archi.wallbuys[weapon_name] = 0;

    if (isdefined(level.archi.ap_weapon_bits[weapon_name]))
    {
        weapon = GetWeapon(weapon_name);
        if (isdefined(weapon))
        {
            z_weapon = level.zombie_weapons[weapon];
            if (isdefined(z_weapon))
            {
                z_weapon.is_in_box = 0;
                level.archi.ap_box_states[weapon_name] = 0;
            }
            else
            {
                IPrintLn("Weapon found but not in zombie_weapons: " + weapon_name);
            }
        }
        else
        {
            IPrintLn("Weapon not found: " + weapon_name);
        }
    }

    globalItem = SpawnStruct();
    globalItem.type = "weapon";
    globalItem.name = itemName;
    globalItem.weapon_name = weapon_name;
    globalItem.count = 0;
        
    level.archi.items[globalItem.name] = globalItem;
    level.archi.items[item.name] = item;
}

function RegisterItem(itemName, getFunc, clientField, universal) {
    globalItem = SpawnStruct();
    globalItem.name = level.archi.mapString + " " + itemName;
    globalItem.getFunc = getFunc;
    globalItem.clientfield = clientField;
    globalItem.count = 0;

    if (IS_TRUE(universal)) {
        item = SpawnStruct();
        item.name = itemName;
        item.getFunc = getFunc;
        item.clientfield = clientField;
        item.count = 0;

        level.archi.items[itemName] = item;
    }

    level.archi.items[globalItem.name] = globalItem;
}

function RegisterUniversalItem(itemName, getFunc, clientField) {
    item = SpawnStruct();
    item.name = itemName;
    item.getFunc = getFunc;
    item.clientfield = clientField;
    item.count = 0;

    level.archi.items[itemName] = item;
}

function RegisterPerk(itemName, getFunc, specialtyName) {
    item = SpawnStruct();
    item.name = itemName;
    item.getFunc = getFunc;
    item.clientfield = "ap_item_" + specialtyName;
    item.count = 0;

    globalItem = SpawnStruct();
    globalItem.name = level.archi.mapString + " " + itemName;
    globalItem.getFunc = getFunc;
    globalItem.clientfield = "ap_item_" + specialtyName;
    globalItem.count = 0;

    level.archi.active_perk_machines[specialtyName] = false;
    level.archi.items[item.name] = item;
    level.archi.items[globalItem.name] = globalItem;
}

function give_ProgressiveStartingPoints500()
{
    level.archi.progressive_starting_points += 500;
    foreach (player in level.players)
    {
        if (!isdefined(player.ap_starting_points))
        {
            // Make sure player has restored first
            wait(0.05);
        }
        diff = level.archi.progressive_starting_points - player.ap_starting_points;
        if (diff > 0)
        {
            player.ap_starting_points = level.archi.progressive_starting_points;
            player zm_score::add_to_player_score(diff);
        }
    }
}

function give_PerkToken()
{
    level.archi.perk_tokens++;
}

function give_GumToken()
{
    level.archi.gum_tokens++;
}

function give_RareGumToken()
{
    level.archi.rare_gum_tokens++;
}

function give_LegendaryGumToken()
{
    level.archi.legendary_gum_tokens++;
}

function give_CheckpointToken()
{
    level.archi.checkpoint_tokens++;
}

//General/Universal gives
function give_1500Points()
{
    foreach (player in getPlayers())
    {
        player zm_score::add_to_player_score(1500);
    }
}

function give_50000Points()
{
    foreach (player in getPlayers())
    {
        player zm_score::add_to_player_score(50000);
    }
}

function give_200Points()
{
    foreach (player in getPlayers())
    {
        player zm_score::add_to_player_score(200);
    }
}

//The Giant Functions

function give_TheGiantRandomPerk()
{
    //TODO: This doesnt work yet. just setting the flag doesnt do it
    
    //Just set the EE to complete, which auto turns on the machine.
    //level flag::set("snow_ee_completed");
}

// Progressive Perk Limits
function give_ProgressivePerkLimit()
{
    level.archi.progressive_perk_limit += 1;
}

function give_ProgressivePap()
{
    item = level.archi.items["Progressive - Pack-A-Punch Machine"];
    if (isdefined(item))
    {
        if (item.count == 1)
        {
            // Unlock pap
            level.archi.pap_active = true;
            level notify("Pack_A_Punch_on");
        }
        if (item.count == 2)
        {
            level notify("ap_aats_enabled");
            wait(0.1);
            vending_weapon_upgrade_trigger = zm_pap_util::get_triggers();
            foreach (trigger in vending_weapon_upgrade_trigger)
            {
                trigger.aat_cost = 2500;
            }
        }
    }
}


function give_Pap()
{
    level notify("Pack_A_Punch_on");
}

function give_Perk(perk)
{
    if (isdefined(level._custom_perks[perk]))
    {
        s_custom_perk = level._custom_perks[perk];
        level.archi.active_perk_machines[perk] = true;
        level notify(s_custom_perk.alias + "_on");
        level notify("ap_update_wunderfizz");
    }

}

//Simple Give Functions notifies
function give_Juggernog()
{
    give_Perk(PERK_JUGGERNOG);
}
function give_QuickRevive()
{
    give_Perk(PERK_QUICK_REVIVE);
}
function give_SpeedCola()
{
    give_Perk(PERK_SLEIGHT_OF_HAND);
}
function give_DoubleTap()
{
    give_Perk(PERK_DOUBLETAP2);
}
function give_StaminUp()
{
    give_Perk(PERK_STAMINUP);
}
function give_MuleKick()
{
    give_Perk(PERK_ADDITIONAL_PRIMARY_WEAPON);
}
function give_DeadShot()
{
    give_Perk(PERK_DEAD_SHOT);
}
function give_WidowsWine()
{
    give_Perk(PERK_WIDOWS_WINE);
}
function give_ElectricCherry()
{
    give_Perk(PERK_ELECTRIC_CHERRY);
}
function give_PhDFlopper()
{
    give_Perk(PERK_PHDFLOPPER);
}

// Shield Parts

function give_ShieldPart_Dolly()
{
    give_piece("craft_shield_zm", "dolly");
}

function give_ShieldPart_Door()
{
    give_piece("craft_shield_zm", "door");
}

function give_ShieldPart_Clamp()
{
    give_piece("craft_shield_zm", "clamp");
}

function give_piece(craftableName, pieceName)
{
    level.archi.craftable_parts[craftableName + "_" + pieceName] = true;
    zm_craftables::player_get_craftable_piece(craftableName, pieceName);
}

// function give_PackAPunch()
// {
//     level notify ("ap_Pack_A_Punch_on");
//     util::wait_network_frame();
// }

// Traps

function give_Trap_ThirdPerson()
{
    level thread _give_Trap_ThirdPerson();
}

function give_Trap_NukePowerup()
{
    _drop_powerup("nuke");
}

function give_Trap_GrenadeParty()
{
    foreach (player in level.players)
    {
        if (IsAlive(player))
        {
            player thread _grenadeparty();
        }
    }
}

function _grenadeparty()
{
    self endon("disconnect");

    spawn_point = (self.origin[0], self.origin[1], self.origin[2] + 1);
    g_weapon = GetWeapon("frag_grenade");
    g_count = RandomIntRange(3, 5);
    for (i = 0; i < g_count; i++)
    {
        wait(0.3);
        // Randomize the general direction
        x_dir = RandomIntRange(30, 60);
        y_dir = RandomIntRange(30, 60);
        if (math::cointoss())
        {
            x_dir = -x_dir;
        }
        if (math::cointoss())
        {
            y_dir = -y_dir;
        }
        self MagicGrenadeType(g_weapon, spawn_point, (x_dir, y_dir, 300), 5);
    }
}

function _give_Trap_ThirdPerson()
{
    SetDvar("cg_thirdPerson", 1);
    wait(30);
    SetDvar("cg_thirdPerson", 0);
}

function give_Trap_KnuckleCrack()
{
    foreach (player in level.players)
    {
        if (IsAlive(player))
        {
            p_weapon = player GetCurrentWeapon();
            if (p_weapon.name != "zombie_knuckle_crack")
            {
                player thread _Trap_KnuckleCrack();
            }
        }
    }
}

// See _zm_pack_a_punch.gsc
function _Trap_KnuckleCrack()
{
    self endon(#"disconnect");
	self knuckle_crack_start();
	self util::waittill_any("fake_death", "death", "player_downed", "weapon_change_complete");
	self knuckle_crack_end();
}

function knuckle_crack_start()
{
    self zm_utility::increment_is_drinking();
	self zm_utility::disable_player_move_states(1);
	primaries = self getweaponslistprimaries();
	original_weapon = self getcurrentweapon();
	weapon = getweapon("zombie_knuckle_crack");
	if(original_weapon != level.weaponnone && !zm_utility::is_placeable_mine(original_weapon) && !zm_equipment::is_equipment(original_weapon))
	{
		self notify(#"zmb_lost_knife");
		// self takeweapon(original_weapon);
	}
	else
	{
		return;
	}
	self giveweapon(weapon);
	self switchtoweapon(weapon);
    self DisableWeaponCycling();
}

function knuckle_crack_end()
{
    self zm_utility::enable_player_move_states();
	weapon = getweapon("zombie_knuckle_crack");
    self EnableWeaponCycling();
	if(self laststand::player_is_in_laststand() || (isdefined(self.intermission) && self.intermission))
	{
		self takeweapon(weapon);
		return;
	}
	self zm_utility::decrement_is_drinking();
	self takeweapon(weapon);
	primaries = self getweaponslistprimaries();
	if(self.is_drinking > 0)
	{
		return;
	}
	self zm_weapons::switch_back_primary_weapon();
}

// Gifts

function give_Gift_UnlimitedSprint()
{
    level thread _Gift_UnlimitedSprint();
}

function _Gift_UnlimitedSprint()
{
    SetDvar("player_sprintUnlimited", 1);
    wait(120);
    SetDvar("player_sprintUnlimited", 0);
}

function give_Gift_CarpenterPowerup()
{
    _drop_powerup("carpenter");
}

function give_Gift_DoublePointsPowerup()
{
    _drop_powerup("double_points");
}

function give_Gift_InstaKillPowerup()
{
    _drop_powerup("insta_kill");
}

function give_Gift_FireSalePowerup()
{
    _drop_powerup("fire_sale");
}

function give_Gift_FreePerkPowerup()
{    
    _drop_powerup("free_perk");
}

function give_Gift_MaxAmmoPowerup()
{
    _drop_powerup("full_ammo");
}

function _drop_powerup(powerup)
{
    players = GetPlayers();
    if (players.size > 0) 
    {
        powerup_drop = level zm_powerups::specific_powerup_drop(powerup, players[0].origin);
    }
}

// Utils

function enableWallbuy(itemName)
{
    if (isdefined(level.archi.wallbuys))
    {
        level.archi.wallbuys[itemName] = true;
    }
}

function checkItem(itemName)
{
    return (isdefined(level.archi.items[itemName]) && level.archi.items[itemName].count>0);
}

function get_map_weapon_lists(map_name)
{
    lists = SpawnStruct();
    
    switch(map_name)
    {
        case "zm_zod":
            lists.vanilla = array(
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_semiauto",
                "launcher_standard",
                "smg_burst",
                "smg_capacity",
                "smg_sten",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "sniper_powerbolt"
            );
            lists.expanded = array(
                "pistol_revolver38",
                "bouncingbetty",
                "bowie_knife",
                "ar_longburst",
                "ar_marksman",
                "ar_standard",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_pump",
                "smg_fastfire",
                "smg_standard",
                "smg_versatile"
            );
            lists.special = array(
                "octobomb",
                "ray_gun"
            );
            break;
            
        case "zm_castle":
            lists.vanilla = array(
                "bouncingbetty",
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_marksman",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_semiauto",
                "launcher_standard",
                "smg_burst",
                "smg_capacity",
                "smg_versatile",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "sniper_powerbolt",
                "lmg_rpk"
            );
            lists.expanded = array(
                "pistol_standard",
                "bowie_knife",
                "ar_longburst",
                "ar_standard",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_pump",
                "smg_fastfire",
                "smg_standard"
            );
            lists.special = array(
                "ray_gun",
                "cymbal_monkey"
            );
            break;
            
        case "zm_island":
            lists.vanilla = array(
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_garand",
                "ar_longburst",
                "ar_marksman",
                "ar_standard",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "pistol_shotgun_dw",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_semiauto",
                "launcher_standard",
                "smg_capacity",
                "smg_fastfire",
                "smg_longrange",
                "smg_mp40",
                "smg_standard",
                "smg_versatile",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "sniper_powerbolt"
            );
            lists.expanded = array(
                "pistol_standard",
                "bouncingbetty",
                "bowie_knife",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_pump",
                "smg_burst"
            );
            lists.special = array(
                "cymbal_monkey",
                "ray_gun"
            );
            break;
            
        case "zm_stalingrad":
            lists.vanilla = array(
                "ar_damage",
                "ar_famas",
                "ar_garand",
                "ar_marksman",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "shotgun_fullauto",
                "shotgun_semiauto",
                "launcher_multi",
                "launcher_standard",
                "smg_capacity",
                "smg_mp40",
                "smg_ppsh",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "sniper_powerbolt",
                "special_crossbow_dw",
                "lmg_rpk"
            );
            lists.expanded = array(
                "bouncingbetty",
                "bowie_knife",
                "ar_accurate",
                "ar_cqb",
                "ar_longburst",
                "ar_standard",
                "pistol_standard",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_precision",
                "shotgun_pump",
                "smg_burst",
                "smg_fastfire",
                "smg_standard",
                "smg_versatile",
                "melee_dagger",
                "melee_fireaxe",
                "melee_sword",
                "melee_wrench"
            );
            lists.special = array(
                "cymbal_monkey",
                "ray_gun",
                "raygun_mark3"
            );
            break;
            
        case "zm_genesis":
            lists.vanilla = array(
                "bouncingbetty",
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_longburst",
                "ar_marksman",
                "ar_standard",
                "ar_peacekeeper",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "pistol_energy",
                "shotgun_energy",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_semiauto",
                "launcher_standard",
                "smg_capacity",
                "smg_fastfire",
                "smg_standard",
                "smg_thompson",
                "smg_versatile",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "sniper_powerbolt"
            );
            lists.expanded = array(
                "pistol_standard",
                "bowie_knife",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_pump",
                "smg_burst",
                "melee_boneglass",
                "melee_improvise",
                "melee_nunchuks",
                "melee_mace",
                "melee_katana"
            );
            lists.special = array(
                "ray_gun",
                "thundergun",
                "hero_gravityspikes_melee",
                "octobomb",
                "idgun_genesis_0"
            );
            break;
            
        case "zm_factory":
            lists.vanilla = array(
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_marksman",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_semiauto",
                "launcher_standard",
                "smg_burst",
                "smg_capacity",
                "smg_versatile",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "sniper_powerbolt",
                "lmg_rpk"
            );
            lists.expanded = array(
                "pistol_standard",
                "bouncingbetty",
                "bowie_knife",
                "ar_longburst",
                "ar_standard",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_pump",
                "smg_fastfire",
                "smg_standard"
            );
            lists.special = array(
                "cymbal_monkey",
                "ray_gun",
                "tesla_gun"
            );
            break;
            
        case "zm_theater":
            lists.vanilla = array(
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_famas",
                "ar_galil",
                "ar_longburst",
                "ar_m16",
                "ar_marksman",
                "ar_standard",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "pistol_fullauto",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_pump",
                "shotgun_semiauto",
                "launcher_standard",
                "smg_burst",
                "smg_capacity",
                "smg_fastfire",
                "smg_standard",
                "smg_versatile",
                "smg_mp40_1940",
                "smg_ak74u",
                "sniper_fastsemi",
                "sniper_powerbolt",
                "lmg_rpk",
                "ar_m14"
            );
            lists.expanded = array(
                "pistol_standard",
                "pistol_m1911",
                "bouncingbetty",
                "bowie_knife",
                "pistol_burst"
            );
            lists.special = array(
                "cymbal_monkey",
                "thundergun",
                "ray_gun",
                "raygun_mark2",
                "tesla_gun",
                "hero_annihilator"
            );
            break;

        case "zm_moon":
            lists.vanilla = array(
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_famas",
                "ar_galil",
                "ar_longburst",
                "ar_m16",
                "ar_marksman",
                "ar_standard",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "pistol_fullauto",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_pump",
                "shotgun_semiauto",
                "launcher_multi",
                "launcher_standard",
                "smg_burst",
                "smg_capacity",
                "smg_fastfire",
                "smg_standard",
                "smg_versatile",
                "smg_ak74u",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "lmg_rpk",
                "ar_m14"
            );
            lists.expanded = array(
                "pistol_standard",
                "pistol_m1911",
                "bouncingbetty",
                "bowie_knife",
                "pistol_burst"
            );
            lists.special = array(
                "hero_annihilator",
                "raygun_mark2",
                "quantum_bomb",
                "black_hole_bomb",
                "ray_gun",
                "microwavegundw"
            );
            break;
        case "zm_tomb":
            lists.vanilla = array(
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_longburst",
                "ar_marksman",
                "ar_standard",
                "ar_stg44",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_mg08",
                "lmg_slowfire",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_pump",
                "shotgun_semiauto",
                "launcher_multi",
                "launcher_standard",
                "smg_burst",
                "smg_capacity",
                "smg_fastfire",
                "smg_mp40_1940",
                "smg_standard",
                "smg_thompson",
                "smg_versatile",
                "smg_ak74u",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "lmg_rpk",
                "ar_m14"
            );
            lists.expanded = array(
                "bouncingbetty",
                "bowie_knife",
                "pistol_c96"
            );
            lists.wallbuys = array(
                "pistol_burst",
                "ar_marksman",
                "shotgun_pump",
                "ar_standard",
                "smg_standard",
                "pistol_fullauto",
                "smg_fastfire",
                "ar_accurate",
                "ar_cqb",
                "smg_versatile",
                "shotgun_precision",
                "ar_longburst",
                "smg_mp40_1940",
                "ar_stg44",
                "smg_thompson"
            );
            lists.special = array(
                "cymbal_monkey",
                "ray_gun",
                "raygun_mark2",
                "hero_annihilator"
            );
            break;
        case "zm_westernz":
            lists.vanilla = array(
                "t8_crossbow",
                "bo3_boneglass",
                "t8_allistair_annihalator",
                "m1831",
                "bo3_olympia",
                "henry_m1840",
                "w1887",
                "t8_m1897",
                "ww2_model21",
                "ww2_winchester94",
                "w1892",
                "fc4_m1887_long",
                "lebel_m1811",
                "ww2_lewis",
                "ww2_fliegerfaust",
                "wes_jag42",
                "m1827_exp"
            );
            lists.expanded = array(
                "frag_ww2_dynamite",
                "frag_ww2_molotov",
                "ww2_raven",
                "ww2_iceaxe",
                "bowie_knife",
                "t8_welling",
                "ww2_reichsrevolver",
                "ww2_colt45saa",
                "ww2_enfield2",
                "ww2_enfield2_gold",
                "ww2_m712",
                "m1889",
                "mwr_ranger",
                "m1903_epic",
                "ww2_mosin",
                "m1896_essex",
                "doc_w1866",
                "aw_winchester",
                "ww2_crossbow",
                "ww2_ribeyrolles",
                "bo4_escargot"
            );
            lists.special = array(
                "grenade_homunculus",
                "thundergun",
                "t8_shotgun_blundergat",
                "t8_raygun",
                "tesla_gun"
            );
            break;
        default:
            return undefined;
    }
    
    return lists;
}

function get_box_bit_table(map_name, basic, special, expanded)
{
    ap_weapon_bits = [];
    bit_index = 0;
    lists = get_map_weapon_lists(map_name);

    if(!isdefined(lists))
    {
        return ap_weapon_bits;
    }
    
    if(special && isdefined(lists.special))
    {
        foreach(weapon in lists.special)
        {
            ap_weapon_bits[weapon] = bit_index;
            bit_index++;
        }
    }

    if(expanded && isdefined(lists.expanded))
    {
        foreach(weapon in lists.expanded)
        {
            ap_weapon_bits[weapon] = bit_index;
            bit_index++;
        }
    }
    
    if(basic && isdefined(lists.vanilla))
    {
        foreach(weapon in lists.vanilla)
        {
            ap_weapon_bits[weapon] = bit_index;
            bit_index++;
        }
    }
    
    return ap_weapon_bits;
}
