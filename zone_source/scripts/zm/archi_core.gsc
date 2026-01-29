#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\hud_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perks;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\zm\archi_items;
#using scripts\zm\archi_commands;
#using scripts\zm\archi_castle;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_bgb_machine;

#insert scripts\zm\archi_core.gsh;

#namespace archi_core;

#precache( "eventstring", "ap_save_data" );
#precache( "eventstring", "ap_load_data" );
#precache( "eventstring", "ap_clear_data" );
#precache( "eventstring", "ap_debug_magicbox" );
#precache( "eventstring", "ap_notification" );
#precache( "eventstring", "ap_ui_get" );
#precache( "eventstring", "ap_ui_send" );

REGISTER_SYSTEM_EX("archipelago_core", &__init__, &__main__, undefined)

function __init__()
{
    // Some maps make requirements harder if not in a ranked match
    level.rankedmatch = 1;
    SetDvar("zm_private_rankedmatch", 1);

    SetDvar( "MOD_VERSION", MOD_VERSION );
    
    //Message Passing Dvars
    SetDvar("ARCHIPELAGO_ITEM_GET", "NONE");
    SetDvar("ARCHIPELAGO_LOCATION_SEND", "NONE");
    SetDvar("ARCHIPELAGO_SAY_SEND", "NONE"); 
    SetDvar("ARCHIPELAGO_SAVE_DATA", "NONE");
    SetDvar("ARCHIPELAGO_LOAD_DATA", "NONE");
    SetDvar("ARCHIPELAGO_LOAD_DATA_SEED", "NONE");
    SetDvar("ARCHIPELAGO_SAVE_PROGRESS", "NONE");
    //Lua Log Passing Dvars
    SetDvar("ARCHIPELAGO_LOG_MESSAGE", "NONE");

    level flag::init("ap_settings_ready");
    level thread get_ap_settings();

	callback::on_start_gametype( &game_start );
	callback::on_connect( &on_player_connect );


    //Clientfields (Mostly Tracker stuff)
    //TODO Put this in a library?
    //TODO Figure out if I need to set these to 0 if maps are swapped down the line
    clientfield::register("world", "ap_item_" + PERK_JUGGERNOG, VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_" + PERK_QUICK_REVIVE, VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_" + PERK_SLEIGHT_OF_HAND, VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_" + PERK_DOUBLETAP2, VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_" + PERK_STAMINUP, VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_" + PERK_PHDFLOPPER, VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_" + PERK_DEAD_SHOT, VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_" + PERK_ADDITIONAL_PRIMARY_WEAPON, VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_" + PERK_ELECTRIC_CHERRY, VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_" + PERK_TOMBSTONE, VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_" + PERK_WHOSWHO, VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_" + PERK_VULTUREAID, VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_" + PERK_WIDOWS_WINE, VERSION_SHIP, 2, "int");

    clientfield::register("world", "ap_item_wunderfizz", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_power_on", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_wallbuys", VERSION_SHIP, 2, "int");

    clientfield::register("world", "ap_item_region_1", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_region_2", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_region_3", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_region_4", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_region_5", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_region_6", VERSION_SHIP, 2, "int");

    clientfield::register("world", "ap_weapon_ar_icr", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_hvk", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_manowar", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_m8a7", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_sheiva", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_kn44", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_ffar", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_garand", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_peacekeeper", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_an94", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_galil", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_m14", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_m16", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_basilisk", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_xr2", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_weapon_ar_stg44", VERSION_SHIP, 2, "int");
}

function __main__()
{
    archi_commands::init_commands();
    level thread round_start_location();
    level thread round_end_noti();
    level thread repaired_board_noti();
}

function get_ap_settings()
{
    // Wait until the LUA client has set the settings dvars
    while (true)
    {
        dvar_value = GetDvarString("ARCHIPELAGO_SETTINGS_READY", "");
        if (isdefined(dvar_value) && dvar_value != "")
        {
            break;
        }       
        WAIT_SERVER_FRAME
    }   
    level flag::set("ap_settings_ready");
}

function init_string_mappings()
{
    level.archi.perk_strings_to_names = [];
    level.archi.active_perk_machines = [];

    perk_mappings = [];
    perk_mappings[PERK_JUGGERNOG] = ARCHIPELAGO_ITEM_PERK_JUGGERNOG;
    perk_mappings[PERK_QUICK_REVIVE] = ARCHIPELAGO_ITEM_PERK_QUICK_REVIVE;
    perk_mappings[PERK_SLEIGHT_OF_HAND] = ARCHIPELAGO_ITEM_PERK_SLEIGHT_OF_HAND;
    perk_mappings[PERK_DOUBLETAP2] = ARCHIPELAGO_ITEM_PERK_DOUBLETAP2;
    perk_mappings[PERK_STAMINUP] = ARCHIPELAGO_ITEM_PERK_STAMINUP;
    perk_mappings[PERK_PHDFLOPPER] = ARCHIPELAGO_ITEM_PERK_PHDFLOPPER;
    perk_mappings[PERK_DEAD_SHOT] = ARCHIPELAGO_ITEM_PERK_DEAD_SHOT;
    perk_mappings[PERK_ADDITIONAL_PRIMARY_WEAPON] = ARCHIPELAGO_ITEM_PERK_ADDITIONAL_PRIMARY_WEAPON;
    perk_mappings[PERK_ELECTRIC_CHERRY] = ARCHIPELAGO_ITEM_PERK_ELECTRIC_CHERRY;
    perk_mappings[PERK_TOMBSTONE] = ARCHIPELAGO_ITEM_PERK_TOMBSTONE;
    perk_mappings[PERK_WHOSWHO] = ARCHIPELAGO_ITEM_PERK_WHOSWHO;
    perk_mappings[PERK_VULTUREAID] = ARCHIPELAGO_ITEM_PERK_VULTUREAID;
    perk_mappings[PERK_WIDOWS_WINE] = ARCHIPELAGO_ITEM_PERK_WIDOWS_WINE;

	foreach (perk, ap_item in perk_mappings) 
    {
        ap_hint_string = "'" + ap_item + "' is required";
        if (IS_TRUE(level.archi.map_specific_machines)) {
            ap_hint_string = "'" + level.archi.mapString + " " + ap_item + "' is required";
        }
        level thread keep_perk_machine_locked(perk, ap_hint_string);
    }

    if (isdefined(level.pack_a_punch.custom_validation))
    {
        level.archi.original_pap_custom_validation = level.pack_a_punch.custom_validation;
    }
    level.pack_a_punch.custom_validation = &custom_pap_validation;

    // Prevent buying perks we don't have the AP item for
    if (isdefined(level.custom_perk_validation)) 
    {
        level.archi.original_custom_perk_validation = level.custom_perk_validation;
    }
    level.custom_perk_validation = &custom_perk_validation;

    level.archi.func_override_wallbuy_prompt = &func_override_wallbuy_prompt;

    // TODO: Settings check for disabled map specific machine strings
    // level.archi.perk_strings_to_names[PERK_JUGGERNOG] = ARCHIPELAGO_ITEM_PERK_JUGGERNOG;
    // level.archi.perk_strings_to_names[PERK_QUICK_REVIVE] = ARCHIPELAGO_ITEM_PERK_QUICK_REVIVE;
    // level.archi.perk_strings_to_names[PERK_SLEIGHT_OF_HAND] = ARCHIPELAGO_ITEM_PERK_SLEIGHT_OF_HAND;
    // level.archi.perk_strings_to_names[PERK_DOUBLETAP2] = ARCHIPELAGO_ITEM_PERK_DOUBLETAP2;
    // level.archi.perk_strings_to_names[PERK_STAMINUP] = ARCHIPELAGO_ITEM_PERK_STAMINUP;
    // level.archi.perk_strings_to_names[PERK_PHDFLOPPER] = ARCHIPELAGO_ITEM_PERK_PHDFLOPPER;
    // level.archi.perk_strings_to_names[PERK_DEAD_SHOT] = ARCHIPELAGO_ITEM_PERK_DEAD_SHOT;
    // level.archi.perk_strings_to_names[PERK_ADDITIONAL_PRIMARY_WEAPON] = ARCHIPELAGO_ITEM_PERK_ADDITIONAL_PRIMARY_WEAPON;
    // level.archi.perk_strings_to_names[PERK_ELECTRIC_CHERRY] = ARCHIPELAGO_ITEM_PERK_ELECTRIC_CHERRY;
    // level.archi.perk_strings_to_names[PERK_TOMBSTONE] = ARCHIPELAGO_ITEM_PERK_TOMBSTONE;
    // level.archi.perk_strings_to_names[PERK_WHOSWHO] = ARCHIPELAGO_ITEM_PERK_WHOSWHO;
    // level.archi.perk_strings_to_names[PERK_VULTUREAID] = ARCHIPELAGO_ITEM_PERK_VULTUREAID;
    // level.archi.perk_strings_to_names[PERK_WIDOWS_WINE] = ARCHIPELAGO_ITEM_PERK_WIDOWS_WINE;

    // if ( isdefined(level._custom_perks[PERK_JUGGERNOG] ))
    // {
    //     if ( isdefined(level._custom_perks[PERK_JUGGERNOG].hint_string) )
    //     {
    //         // Save original so we can restore it once we unlock the machine
    //         level._custom_perks[PERK_JUGGERNOG].original_hint_string = level._custom_perks[PERK_JUGGERNOG].hint_string;
    //     }
    //     level._cuistom_perks[PERK_JUGGERNOG].hint_string = ARCHIPELAGO_ITEM_PERK_VULTUREAID + " is required";
    // }
}

function on_archi_connect_settings()
{
    level flag::wait_till("ap_settings_ready");
    level.archi.perk_limit_default_modifier = GetDvarInt("ARCHIPELAGO_PERK_LIMIT_DEFAULT_MODIFIER", 0);
    level.archi.randomized_shield_parts = GetDvarInt("ARCHIPELAGO_RANDOMIZED_SHIELD_PARTS", 0);
    level.archi.map_specific_wallbuys = GetDvarInt("ARCHIPELAGO_MAP_SPECIFIC_WALLBUYS", 0);
    level.archi.map_specific_machines = GetDvarInt("ARCHIPELAGO_MAP_SPECIFIC_MACHINES", 0);

    init_string_mappings();
}

function game_start()
{
    
    //TODO Error out here if there is no connection settings


    if (!isdefined(level.archi))
    {
        // Hold server-wide Archipelago Information
        level.archi = SpawnStruct();

        level.archi.opened_doors = [];
        level.archi.opened_debris = [];

        zombie_doors = GetEntArray("zombie_door", "targetname");
        for (i = 0; i < zombie_doors.size; i++)
        {
            zombie_doors[i].id = i;
        }
        array::thread_all(zombie_doors, &track_door_open);

        zombie_debris = GetEntArray("zombie_debris", "targetname");
        for (i = 0; i < zombie_debris.size; i++)
        {
            zombie_debris[i].id = i;
        }
        array::thread_all(zombie_debris, &track_debris_open);

        // Get Map Name String
        mapName = GetDvarString( "mapname" );

        level.archi.wallbuy_mappings = [];
        level.archi.wallbuys = [];
        level.archi.craftable_piece_to_location = [];
        level.archi.check_override_wallbuy_purchase = &check_override_wallbuy_purchase;
        level.archi.boarded_windows = 0;

        // Map State
        level.archi.progressive_perk_limit = 0;
        level.archi.craftable_parts = [];
    
        // Settings
        level.archi.perk_limit_default_modifier = 0;
        level.archi.randomized_shield_parts = 0;
        level.archi.map_specific_wallbuys = 0;
        level.archi.map_specific_machines = 0;

        // // Lock Weapons
        // level.archi.weapons["ar_accurate"] = false;
        // level.archi.weapons["ar_cqb"] = false;
        // level.archi.weapons["ar_damage"] = false;
        // level.archi.weapons["ar_longburst"] = false;
        // level.archi.weapons["ar_marksman"] = false;
        // level.archi.weapons["ar_standard"] = false;
        // level.archi.weapons["ar_famas"] = false;
        // level.archi.weapons["ar_garand"] = false;
        // level.archi.weapons["ar_peacekeeper"] = false;
        // level.archi.weapons["ar_an94"] = false;
        // level.archi.weapons["ar_galil"] = false;
        // level.archi.weapons["ar_m14"] = false;
        // level.archi.weapons["ar_m16"] = false;
        // level.archi.weapons["ar_pulse"] = false;
        // level.archi.weapons["ar_fastburst"] = false;
        // level.archi.weapons["ar_stg44"] = false;

        // // Sub Machine Guns
        // level.archi.weapons["smg_burst"] = false;
        // level.archi.weapons["smg_capacity"] = false;
        // level.archi.weapons["smg_fastfire"] = false;
        // level.archi.weapons["smg_standard"] = false;
        // level.archi.weapons["smg_versatile"] = false;
        // level.archi.weapons["smg_sten"] = false;
        // level.archi.weapons["smg_mp40"] = false;
        // level.archi.weapons["smg_ppsh"] = false;
        // level.archi.weapons["smg_thompson"] = false;
        // level.archi.weapons["smg_longrange"] = false;
        // level.archi.weapons["smg_ak74u"] = false;
        // level.archi.weapons["smg_msmc"] = false;
        // level.archi.weapons["smg_nailgun"] = false;
        // level.archi.weapons["smg_rechamber"] = false;
        // level.archi.weapons["smg_sten2"] = false;
        // level.archi.weapons["smg_mp40_1940"] = false;

        // // Shotguns
        // level.archi.weapons["shotgun_fullauto"] = false;
        // level.archi.weapons["shotgun_precision"] = false;
        // level.archi.weapons["shotgun_pump"] = false;
        // level.archi.weapons["shotgun_semiauto"] = false;
        // level.archi.weapons["shotgun_energy"] = false;
        // level.archi.weapons["shotgun_olympia"] = false;

        // // Pistols
        // level.archi.weapons["pistol_revolver38"] = false;
        // level.archi.weapons["pistol_standard"] = false;
        // level.archi.weapons["pistol_burst"] = false;
        // level.archi.weapons["pistol_fullauto"] = false;
        // level.archi.weapons["pistol_energy"] = false;
        // level.archi.weapons["pistol_m1911"] = false;
        // level.archi.weapons["pistol_shotgun_dw"] = false;
        // level.archi.weapons["pistol_c96"] = false;

        // // Melee
        // level.archi.weapons["melee_bowie"] = false;

        archi_items::RegisterUniversalItem("50 Points",&archi_items::give_50Points);
        archi_items::RegisterUniversalItem("500 Points",&archi_items::give_500Points);
        archi_items::RegisterUniversalItem("50000 Points",&archi_items::give_50000Points);

        // Traps
        archi_items::RegisterUniversalItem("Trap - Third Person Mode",&archi_items::give_Trap_ThirdPerson,"ap_trap_thirdperson");
        
        // Gifts
        archi_items::RegisterUniversalItem("Gift - Carpenter Powerup",&archi_items::give_Gift_CarpenterPowerup,"ap_gift_carpenter");
        archi_items::RegisterUniversalItem("Gift - Double Points Powerup",&archi_items::give_Gift_DoublePointsPowerup,"ap_gift_double_points");
        archi_items::RegisterUniversalItem("Gift - InstaKill Powerup",&archi_items::give_Gift_InstaKillPowerup,"ap_gift_instakill");
        archi_items::RegisterUniversalItem("Gift - Fire Sale Powerup",&archi_items::give_Gift_FireSalePowerup,"ap_gift_fire_sale");
        archi_items::RegisterUniversalItem("Gift - Max Ammo Powerup",&archi_items::give_Gift_MaxAmmoPowerup,"ap_gift_max_ammo");
        archi_items::RegisterUniversalItem("Gift - Nuke Powerup",&archi_items::give_Gift_NukePowerup,"ap_gift_nuke");
        archi_items::RegisterUniversalItem("Gift - Free Perk Powerup",&archi_items::give_Gift_FreePerkPowerup,"ap_gift_free_perk");

        // Progressives
        archi_items::RegisterUniversalItem("Progressive - Perk Limit Increase",&archi_items::give_ProgressivePerkLimit,"ap_progressive_perk_limit");

        archi_items::RegisterPap();

        if (mapName == "zm_castle")
        {
            level.archi.mapString = ARCHIPELAGO_MAP_CASTLE;

            // Replace craftable logic with AP locations
            replace_craftable_onPickup("craft_shield_zm");
            level.archi.craftable_piece_to_location["craft_shield_zm_dolly"] = level.archi.mapString + " Shield Part Pickup - Dolly";
            level.archi.craftable_piece_to_location["craft_shield_zm_door"] = level.archi.mapString + " Shield Part Pickup - Door";
            level.archi.craftable_piece_to_location["craft_shield_zm_clamp"] = level.archi.mapString + " Shield Part Pickup - Clamp";

            replace_craftable_onPickup("gravityspike");
            level.archi.craftable_piece_to_location["gravityspike_part_body"] = level.archi.mapString + " Ragnarok DG-4 Part Pickup - Body";
            level.archi.craftable_piece_to_location["gravityspike_part_guards"] = level.archi.mapString + " Ragnarok DG-4 Part Pickup - Guards";
            level.archi.craftable_piece_to_location["gravityspike_part_handle"] = level.archi.mapString + " Ragnarok DG-4 Part Pickup - Handle";

            archi_castle::setup_soul_catchers();
            archi_castle::setup_landing_pads();

            archi_castle::setup_music_ee_trackers();

            archi_castle::setup_weapon_ee_rune_prison();
            archi_castle::setup_weapon_ee_demon_gate();
            archi_castle::setup_weapon_ee_wolf_howl();
            archi_castle::setup_weapon_ee_storm_bow();

            archi_castle::setup_main_ee();

            level thread setup_spare_change_trackers(6);

            // Register Map Unique Items - Item name, callback, clientfield
            archi_items::RegisterItem("Victory",&archi_items::give_Victory,undefined,false);

            archi_items::RegisterItem("Shield Part - Door",&archi_items::give_ShieldPart_Door,undefined,true);
            archi_items::RegisterItem("Shield Part - Dolly",&archi_items::give_ShieldPart_Dolly,undefined,true);
            archi_items::RegisterItem("Shield Part - Clamp",&archi_items::give_ShieldPart_Clamp,undefined,true);

            archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
            archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
            archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
            archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
            archi_items::RegisterPerk("Stamin-up",&archi_items::give_StaminUp,PERK_STAMINUP);
            archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);
        
            archi_items::RegisterWeapon("Wallbuy - RK5",&archi_items::give_Weapon_RK5,"pistol_burst");
            archi_items::RegisterWeapon("Wallbuy - Sheiva",&archi_items::give_Weapon_Sheiva,"ar_marksman");
            archi_items::RegisterWeapon("Wallbuy - L-CAR",&archi_items::give_Weapon_LCAR,"pistol_fullauto");
            archi_items::RegisterWeapon("Wallbuy - KRM-262",&archi_items::give_Weapon_KRM,"shotgun_pump");
            archi_items::RegisterWeapon("Wallbuy - HVK-30",&archi_items::give_Weapon_HVK,"ar_cqb");
            archi_items::RegisterWeapon("Wallbuy - M8A7",&archi_items::give_Weapon_M8A7,"ar_longburst");
            archi_items::RegisterWeapon("Wallbuy - Kuda",&archi_items::give_Weapon_Kuda,"smg_standard");
            archi_items::RegisterWeapon("Wallbuy - VMP",&archi_items::give_Weapon_VMP,"smg_versatile");
            archi_items::RegisterWeapon("Wallbuy - Vesper",&archi_items::give_Weapon_Vesper,"smg_fastfire");
            archi_items::RegisterWeapon("Wallbuy - KN-44",&archi_items::give_Weapon_KN44,"ar_standard");
            archi_items::RegisterWeapon("Wallbuy - BRM",&archi_items::give_Weapon_BRM,"lmg_light");
            archi_items::RegisterWeapon("Wallbuy - Bowie Knife",&archi_items::give_Weapon_BowieKnife,"melee_bowie");
        
            level thread archi_castle::save_state_manager();
            level thread archi_castle::load_state();
        }

        if (mapName == "zm_zod")
        {
            level.archi.mapString = ARCHIPELAGO_MAP_SHADOWS_OF_EVIL;
        }

        if (mapName == "zm_factory")
        {
            level.archi.mapString = ARCHIPELAGO_MAP_THE_GIANT;

            // 7 possible machines, 6 will spawn
            level thread setup_spare_change_trackers(6);

            // Register Map Unique Items - Item name, callback, clientfield
            archi_items::RegisterItem("Victory",&archi_items::give_Victory,undefined,false);
            
            // Register Possible Global Items - Item name, callback, clientfield
            archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
            archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
            archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
            archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
            archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);
            archi_items::RegisterPerk("Stamin-up",&archi_items::give_StaminUp,PERK_STAMINUP);
            archi_items::RegisterPerk("Dead Shot",&archi_items::give_DeadShot,PERK_DEAD_SHOT);

            archi_items::RegisterWeapon("Wallbuy - HVK-30",&archi_items::give_Weapon_HVK,"ar_cqb");
            archi_items::RegisterWeapon("Wallbuy - M8A7",&archi_items::give_Weapon_M8A7,"ar_longburst");
            archi_items::RegisterWeapon("Wallbuy - Sheiva",&archi_items::give_Weapon_Sheiva,"ar_marksman");
            archi_items::RegisterWeapon("Wallbuy - KN-44",&archi_items::give_Weapon_KN44,"ar_standard");
            archi_items::RegisterWeapon("Wallbuy - Kuda",&archi_items::give_Weapon_Kuda,"smg_standard");
            archi_items::RegisterWeapon("Wallbuy - VMP",&archi_items::give_Weapon_VMP,"smg_versatile");
            archi_items::RegisterWeapon("Wallbuy - KRM-262",&archi_items::give_Weapon_KRM,"shotgun_pump");
            archi_items::RegisterWeapon("Wallbuy - L-CAR",&archi_items::give_Weapon_LCAR,"pistol_fullauto");
            archi_items::RegisterWeapon("Wallbuy - RK5",&archi_items::give_Weapon_RK5,"pistol_burst");
            archi_items::RegisterWeapon("Wallbuy - Bowie Knife",&archi_items::give_Weapon_BowieKnife,"melee_bowie");

        }

        level thread setup_can_player_purchase_perk();

        //Server-wide thread to get items from the Lua/LUI
        level thread item_get_from_lua();

        //Server-wide thread to print Log messages from Lua/LUI
        level thread log_from_lua();

        //Collection of Locations that are checked, 
        level.archi.locationQueue = array();

        //Apply settings with Existing DVARS, should be set in menu during initial Room Connection
        level thread on_archi_connect_settings();
    }

    //Setup default map changes
    default_map_changes();
}

function setup_can_player_purchase_perk()
{
    level waittill("initial_blackscreen_passed");

	if(isdefined(level.get_player_perk_purchase_limit))
    {
        level.original_get_player_perk_purchase_limit = level.get_player_purchase_limit;
    }
    level.get_player_perk_purchase_limit = &can_player_purchase_perk;
}

function can_player_purchase_perk()
{
    // Run levels original perk limit check first
    purchase_limit = level.perk_purchase_limit;
    if (isdefined(level.original_get_player_perk_purchase_limit))
    {
        purchase_limit = self [[ level.original_get_player_perk_purchase_limit ]]();
    }
    // Add ours on top of the maps original perk limit
    purchase_limit += level.archi.perk_limit_default_modifier;
    purchase_limit += level.archi.progressive_perk_limit;
    return purchase_limit;
}

function default_map_changes()
{
    level.initial_quick_revive_power_off = true;

    wait 1;
    //Turn off/Hide Gobblebum Machines by Yeeting them into the Sun
    if (isdefined(level.bgb_machines))
    {
        for(i = 0; i < level.bgb_machines.size; i++)
        {
            level.bgb_machines[i].origin = (10000, 10000, 10000);
            level.bgb_machines[i].unitrigger_stub.origin = (10000, 10000, 10000);
        }
    }
}

function on_player_connect()
{
    if (self IsHost())
    {
        self thread location_check_to_lua();
    }
}

function round_start_location()
{
    
    level endon("end_game");
	level endon("end_round_think");
    while (true)
    {
        
        level waittill("start_of_round");

        //Round 1 Location Check
        if (level.round_number == 1)
        {
            send_location(level.archi.mapString + " Round 01");
        }
    }
}

function send_location(loc_str)
{
    level notify("ap_location_found", loc_str);
    array::add(level.archi.locationQueue, loc_str);
}

function round_end_noti()
{
    level endon("end_game");
	level endon("end_round_think");
    while (true)
    {

        //TODO: Make this all special rounds, and put it in a function for readability
        //TODO: Make this an option in the AP
        //Make sure dogs don't happen
        //level.next_dog_round = 9999;

        level waittill("end_of_round");

        //Round 2+ Location Check
        round = level.round_number+1;
        loc_str = level.archi.mapString + " Round ";
        if (round<10)
        {
            loc_str += "0"+round;
        }
        else
        {
            loc_str += round;
        }
        send_location(loc_str);
    }
}

function repaired_board_noti()
{
    level endon("end_game");

    while (true) 
    {
        level waittill("ap_boarding_window");

        level.archi.boarded_windows += 1;
        if (level.archi.boarded_windows == 5)
        {
            send_location("Repair Windows 5 Times");
        }
    }
}

//Recieved commands from the Archipelago Lua Coponent
function item_get_from_lua()
{
    level waittill( "initial_blackscreen_passed" );
    wait 5; // Wait for log to clear on game startup
    level endon("end_game");
	level endon("end_round_think");
    while(true)
    {
        item = GetDvarString("ARCHIPELAGO_ITEM_GET");
        if ( item != "NONE" )
        {
            if (isdefined(level.archi.items[item]))
            {
                level.archi.items[item].count += 1;
                self [[level.archi.items[item].getFunc]]();

                if (isdefined(level.archi.items[item].clientField))
                {
                    //TODO: make this safe, so it checks if the clientfield exists first
                    level clientfield::set(level.archi.items[item].clientField, 1);
                }
                //Notif happens a bit too early compared to log messages
                wait .5;
                LUINotifyEvent(&"ap_ui_get", 0);
            }

            SetDvar("ARCHIPELAGO_ITEM_GET","NONE");
            
        }
        wait .5;
    }
    
}

function log_from_lua()
{
    level waittill( "initial_blackscreen_passed" );

    level endon("end_game");
	level endon("end_round_think");
    while(true)
    {
        message = GetDvarString("ARCHIPELAGO_LOG_MESSAGE");
        if ( message != "NONE" )
        {
            
            iPrintln(message);
            SetDvar("ARCHIPELAGO_LOG_MESSAGE","NONE");
            
        }
        wait .5;
    }
}

//When we trip a Location, give to Lua
function location_check_to_lua()
{
    level waittill( "initial_blackscreen_passed" );
    //TODO tune this wait till it feels good vs archipelago log messages
    wait 3;
    self endon( "disconnect" );
    while(true)
    {
        if (level.archi.locationQueue.size > 0)
        {
            location = array::pop(level.archi.locationQueue);
            SetDvar("ARCHIPELAGO_LOCATION_SEND",location);
            IPrintLn("Sending Location " + location);
            LUINotifyEvent(&"ap_notification", 0);

            //Send notification for Send UI Image
            LUINotifyEvent(&"ap_ui_send", 0);
        }
        wait .5;
    }
}

function replace_craftable_onPickup( craftableName )
{
    if ( isdefined(level.zombie_include_craftables) && isdefined(level.zombie_include_craftables[ craftableName ]) )
    {
        craftable_struct = level.zombie_include_craftables[ craftableName ];
        foreach (index, piece in craftable_struct.a_pieceStubs)
        {
            if (isdefined(piece.onPickup))
            {
                piece.original_onPickup = piece.onPickup;
                piece.onPickup = &wrapped_craftable_onPickup;
            } 
            else
            {
                IPrintLn("No pickup defined for piece?");
            }
        }
    }
}

// self is piecespawn
// piecespawn [[piecestub.onpickup]](self);
function wrapped_craftable_onPickup( player )
{
    fullName = self.craftableName + "_" + self.pieceName;
    if ( isdefined(level.archi.craftable_piece_to_location[fullName]) )
    {
        ap_location = level.archi.craftable_piece_to_location[fullName];
        send_location(ap_location);
    } else {
        IPrintLn("No saved location for " + fullName);
    }
    if (isdefined(self.piecestub.original_onPickup))
    {
        self [[self.piecestub.original_onPickup]](player);
    }
    if (self.craftableName == "craft_shield_zm" && level.archi.randomized_shield_parts == 1)
    {
        self thread _remove_piece();
    }
}

// Remove a piecespawn from the shared inventory'
// self is piecespawn
function _remove_piece()
{
    id = self.craftableName + "_" + self.pieceName;
    if (!isdefined(level.archi.craftable_parts[id]))
    {
        WAIT_SERVER_FRAME
        self.in_shared_inventory = 0; // Not sure if this bit actually does anything right now
        level clientfield::set(self.piecestub.client_field_id, 0);
    }
}

function setup_spare_change_trackers(total_machines)
{
    // Wait until we're certain the triggers were spawned?
    level waittill("initial_blackscreen_passed");

    level thread track_all_change_collected_thread(total_machines);
    a_triggers = getentarray("audio_bump_trigger", "targetname");
    // IPrintLn("Found triggers");
    foreach(t_audio_bump in a_triggers)
	{
		if(t_audio_bump.script_sound === "zmb_perks_bump_bottle")
		{
            // IPrintLn("Added thread to bottle bumper");
			t_audio_bump thread track_change_collected_thread();
		}
	}
}

function track_all_change_collected_thread(total_machines)
{
    level endon("end_game");

    checked_machines = 0;
    while (checked_machines < total_machines)
    {
        level waittill("ap_spare_change");
        IPrintLn("Spare Change Collected");
        checked_machines += 1;
    }

    archi_core::send_location(level.archi.mapString + " All Spare Change Collected");
}

function track_change_collected_thread()
{
	while(true)
	{
		self waittill("trigger", e_player);
		if(e_player getstance() == "prone")
		{
			level notify ("ap_spare_change");
			break;
		}
		wait(0.15);
	}
}

function change_to_round(round_number)
{
    // Kill remaining zombies
    level.zombie_total = 0;

    level notify("end_of_round");
    wait 0.05;
    zm::set_round_number(round_number);

    zombie_utility::ai_calculate_health(round_number);
    SetRoundsPlayed(round_number);

    if (level.gamedifficulty == 0)
    {
        level.zombie_move_speed = round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
    }
    else
    {
        level.zombie_move_speed = round_number * level.zombie_vars["zombie_move_speed_multiplier"];
    }

    level.zombie_vars["zombie_spawn_delay"] = [[level.func_get_zombie_spawn_delay]](round_number);

    level.sndGotoRoundOccurred = true;
}

function track_door_open()
{
    if (self.script_noteworthy == "electric_door" || self.script_noteworthy == "local_electric_door")
    {
        // Ignore non-buyable doors
        return;
    }
    all_trigs = GetEntArray(self.target, "target");
    all_trigs[0] waittill("door_opened");
    level.archi.opened_doors[level.archi.opened_doors.size] = self.id;
}

function track_debris_open()
{
    self waittill("kill_debris_prompt_thread");
    level.archi.opened_debris[level.archi.opened_debris.size] = self.id;
}

function keep_pap_locked()
{
    level thread keep_pap_hint_string();
    vending_weapon_upgrade_trigger = zm_pap_util::get_triggers();

    foreach(t_machine in vending_weapon_upgrade_trigger)
    {
        t_machine SetHintString("'Pack-A-Punch Machine' is required");
    }

    while(true) 
    {
        level waittill("Pack_A_Punch_on");
        wait (0.5);
        if (IS_TRUE(level.archi.pap_active))
        {
            // Pap active, don't turn back off
            break;
        }
        vending_weapon_upgrade_trigger = zm_pap_util::get_triggers();
        foreach(t_machine in vending_weapon_upgrade_trigger)
        {
            t_machine.powered [[t_machine.powered.power_off_func]](undefined, undefined);
        }
        wait(0.5);
        foreach(t_machine in vending_weapon_upgrade_trigger)
        {
            t_machine SetHintString("'Pack-A-Punch Machine' is required");
        }
    }
}

// This fixes the teleporting PaP from Castle
function keep_pap_hint_string()
{
    level endon("end_game");

    while(true)
    {
        level.pap_machine.zbarrier waittill("zbarrier_state_change");
        wait(0.1);
        if (IS_TRUE(level.archi.pap_active))
        {
            // Pap active, don't keep changing hint string
            break;
        }
        vending_weapon_upgrade_trigger = zm_pap_util::get_triggers();
        foreach(t_machine in vending_weapon_upgrade_trigger)
        {
            t_machine SetHintString("'Pack-A-Punch Machine' is required");
        }
    }


}

function keep_perk_machine_locked(perk, ap_hint_string)
{
    s_custom_perk = level._custom_perks[perk];
    if (!isdefined( s_custom_perk ))
    {
        return;
    }

    // Turn off perk if it's already on
    machine_triggers = GetEntArray( s_custom_perk.radiant_machine_name, "target" );
    if (machine_triggers[0].power_on)
    {
        level notify(s_custom_perk.alias + "_off");
    }

    while(true)
    {
        // Find the new machine and set our AP hint string
        while(true)
        {
            wait (0.1);
            t_perk = GetEnt(perk, "script_noteworthy");
            if (isdefined(t_perk)) {
                t_perk SetHintString(ap_hint_string);
                break;
            }
        }

        // Wait until something powers the machine on
        level waittill(perk + "_power_on");
        if (IS_TRUE(level.archi.active_perk_machines[perk]))
        {
            // We've got the AP item, we can stop turning it off
            t_perk zm_perks::reset_vending_hint_string();
            break;
        }
        wait(0.5);
        level notify(s_custom_perk.alias + "_off");
    }
}

// self is something pap related
function custom_pap_validation(player)
{
    if (!IS_TRUE(level.archi.pap_active))
    {
        return false;
    }
    if (isdefined(level.archi.original_pap_custom_validation))
    {
        return self [[level.archi.original_pap_custom_validation]](player);
    }
    return true;
}

// self is vending trigger
function custom_perk_validation(player)
{
    perk = self.script_noteworthy;
    if (!IS_TRUE(level.archi.active_perk_machines[perk]))
    {
        return false;
    }
    if (isdefined(level.archi.original_custom_perk_validation))
    {
        return self [[level.archi.original_custom_perk_validation]](player);
    }
    return true;
}

// self is weapon spawn
function func_override_wallbuy_prompt(player)
{
    weapon = self.weapon;
    if (IS_TRUE(level.archi.wallbuys[weapon.name])) 
    {
        return true;
    } 
    else
    {
        apItem = level.archi.wallbuy_mappings[weapon.name];
        if (isdefined(apItem))
        {
            hint_string = "'" + apItem + "' is required";
            if (level.archi.map_specific_wallbuys)
            {
                hint_string = "'" + level.archi.mapString + " " + apItem + "' is required";
            }
            self SetHintString(hint_string);
            return false;
        }
    }
    return true;
}

// self is player
function check_override_wallbuy_purchase(weapon, weapon_spawn)
{
    IPrintLn("PIR");
    IPrintLn("Checking " + weapon.name);
    if (IS_TRUE(level.archi.wallbuys[weapon.name])) 
    {
        return false;
    }
    IPrintLn("Nope");
    return true;
}
