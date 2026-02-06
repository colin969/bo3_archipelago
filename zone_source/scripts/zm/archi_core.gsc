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
#using scripts\zm\archi_island;
#using scripts\zm\archi_stalingrad;
#using scripts\zm\archi_genesis;
#using scripts\zm\archi_zod;

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
#precache( "eventstring", "ap_init_dll" );
#precache( "eventstring", "ap_init_state" );

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
    SetDvar("ARCHIPELAGO_LOAD_READY", 0);
    SetDvar("ARCHIPELAGO_SEED", "");
    SetDvar("ARCHIPELAGO_SETTINGS_READY", "");

    //Server-wide thread to print Log messages from Lua/LUI
    level thread log_from_lua();

    level flag::init("ap_dll_started");
    level flag::init("ap_loaded");

    level thread lua_init();

	callback::on_start_gametype( &wait_for_start );
	callback::on_connect( &on_player_connect );

    //Clientfields (Mostly Tracker stuff)
    //TODO Put this in a library?
    //TODO Figure out if I need to set these to 0 if maps are swapped down the line

}

function __main__()
{

}

function lua_init()
{
	level waittill("initial_players_connected");

    LUINotifyEvent(&"ap_init_dll", 0);
    WAIT_SERVER_FRAME
    level flag::set("ap_dll_started");
}

function get_ap_settings()
{
    // Wait until the LUA client has set the settings dvars
    while (true)
    {
        dvar_value = GetDvarString("ARCHIPELAGO_SETTINGS_READY", "");
        if (dvar_value != "")
        {
            SetDvar("ARCHIPELAGO_SETTINGS_READY", "");
            wait(0.1);
            break;
        }       
        wait(0.1);
    }   
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
}

function on_archi_connect_settings()
{
    level.archi.perk_limit_default_modifier = GetDvarInt("ARCHIPELAGO_PERK_LIMIT_DEFAULT_MODIFIER", 0);
    level.archi.randomized_shield_parts = GetDvarInt("ARCHIPELAGO_RANDOMIZED_SHIELD_PARTS", 0);
    level.archi.map_specific_wallbuys = GetDvarInt("ARCHIPELAGO_MAP_SPECIFIC_WALLBUYS", 0);
    level.archi.map_specific_machines = GetDvarInt("ARCHIPELAGO_MAP_SPECIFIC_MACHINES", 0);
    level.archi.randomized_box_wonder_weapons = GetDvarInt("ARCHIPELAGO_BOX_WONDER_WEAPON_ITEM_LOCK", 0);
    level.archi.difficulty_gorod_egg_cooldown = GetDvarInt("ARCHIPELAGO_DIFFICULTY_GOROD_EGG_COOLDOWN", 0);
    level.archi.difficulty_gorod_dragon_wings = GetDvarInt("ARCHIPELAGO_DIFFICULTY_GOROD_DRAGON_WINGS", 0);

    init_string_mappings();
}

function wait_for_start()
{
    level endon("end_game");
    level flag::wait_till("ap_dll_started");
    get_ap_settings();

    LUINotifyEvent(&"ap_init_state", 0);

    // Wait until the client has loaded the data
    while(true)
    {   
        dvar_value = GetDvarInt("ARCHIPELAGO_LOAD_READY", 0);
        if (dvar_value > 0) {
            break;
        }
        wait(0.2);
    }
    
    level flag::set("ap_loaded");
    level thread game_start();
}

function game_start()
{
    //TODO Error out here if there is no connection settings
    if (!isdefined(level.archi))
    {
        // Hold server-wide Archipelago Information
        level.archi = SpawnStruct();

        //Collection of Locations that are checked, 
        level.archi.locationQueue = array();

        level.archi.opened_doors = [];
        level.archi.opened_debris = [];
        level.archi.excluded_craftable_items = [];

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

        archi_items::RegisterUniversalItem("50 Points",&archi_items::give_50Points);
        archi_items::RegisterUniversalItem("500 Points",&archi_items::give_500Points);
        archi_items::RegisterUniversalItem("50000 Points",&archi_items::give_50000Points);

        // Traps
        archi_items::RegisterUniversalItem("Trap - Third Person Mode",&archi_items::give_Trap_ThirdPerson,undefined);
        
        // Gifts
        archi_items::RegisterUniversalItem("Gift - Carpenter Powerup",&archi_items::give_Gift_CarpenterPowerup,undefined);
        archi_items::RegisterUniversalItem("Gift - Double Points Powerup",&archi_items::give_Gift_DoublePointsPowerup,undefined);
        archi_items::RegisterUniversalItem("Gift - InstaKill Powerup",&archi_items::give_Gift_InstaKillPowerup,undefined);
        archi_items::RegisterUniversalItem("Gift - Fire Sale Powerup",&archi_items::give_Gift_FireSalePowerup,undefined);
        archi_items::RegisterUniversalItem("Gift - Max Ammo Powerup",&archi_items::give_Gift_MaxAmmoPowerup,undefined);
        archi_items::RegisterUniversalItem("Gift - Nuke Powerup",&archi_items::give_Gift_NukePowerup,undefined);
        archi_items::RegisterUniversalItem("Gift - Free Perk Powerup",&archi_items::give_Gift_FreePerkPowerup,undefined);

        // Progressives
        archi_items::RegisterUniversalItem("Progressive - Perk Limit Increase",&archi_items::give_ProgressivePerkLimit,undefined);

        archi_items::RegisterPap();

        archi_commands::init_commands();
        level thread round_start_location();
        level thread round_end_noti();
        level thread repaired_board_noti();

        if (mapName == "zm_zod")
        {
            level.archi.mapString = ARCHIPELAGO_MAP_SHADOWS_OF_EVIL;

            level.b_allow_idgun_pap = 1; // Allow apothicon servant to be Pap'd

            replace_craftable_onPickup("craft_shield_zm");
            level.archi.craftable_piece_to_location["craft_shield_zm_dolly"] = level.archi.mapString + " Shield Part Pickup - Dolly";
            level.archi.craftable_piece_to_location["craft_shield_zm_door"] = level.archi.mapString + " Shield Part Pickup - Door";
            level.archi.craftable_piece_to_location["craft_shield_zm_clamp"] = level.archi.mapString + " Shield Part Pickup - Clamp";

            replace_craftable_onPickup("idgun");
            level.archi.craftable_piece_to_location["idgun_part_heart"] = level.archi.mapString + " Apothicon Servant Part Pickup - Margwa Heart";
            level.archi.craftable_piece_to_location["idgun_part_skeleton"] = level.archi.mapString + " Apothicon Servant Part Pickup - Margwa Tentacle";
            level.archi.craftable_piece_to_location["idgun_part_xenomatter"] = level.archi.mapString + " Apothicon Servant Part Pickup - Xenomatter";

            replace_craftable_onPickup("police_box");
            level.archi.craftable_piece_to_location["police_box_fuse_01"] = level.archi.mapString + " Civil Protector Part Pickup - Waterfront Fuse";
            level.archi.craftable_piece_to_location["police_box_fuse_02"] = level.archi.mapString + " Civil Protector Part Pickup - Canals Fuse";
            level.archi.craftable_piece_to_location["police_box_fuse_03"] = level.archi.mapString + " Civil Protector Part Pickup - Footlight Fuse";

            archi_items::RegisterBoxWeapon("Mystery Box - Apothicon Servant","idgun_0");
            archi_items::RegisterBoxWeapon("Mystery Box - Li'l Arnies","octobomb");
            archi_items::RegisterBoxWeapon("Mystery Box - Raygun","ray_gun");

            archi_items::RegisterItem("Shield Part - Door",&archi_items::give_ShieldPart_Door,undefined,true);
            archi_items::RegisterItem("Shield Part - Dolly",&archi_items::give_ShieldPart_Dolly,undefined,true);
            archi_items::RegisterItem("Shield Part - Clamp",&archi_items::give_ShieldPart_Clamp,undefined,true);

            archi_items::RegisterItem("Apothicon Servant Part - Margwa Heart",&archi_zod::give_ApothiconServantPart_Heart,undefined,false);
            archi_items::RegisterItem("Apothicon Servant Part - Margwa Tentacle",&archi_zod::give_ApothiconServantPart_Tentacle,undefined,false);
            archi_items::RegisterItem("Apothicon Servant Part - Xenomatter",&archi_zod::give_ApothiconServantPart_Xenomatter,undefined,false);

            archi_items::RegisterItem("Civil Protector Part - Waterfront Fuse",&archi_zod::give_CivilProtectorPart_Fuse01,undefined,false);
            archi_items::RegisterItem("Civil Protector Part - Canals Fuse",&archi_zod::give_CivilProtectorPart_Fuse02,undefined,false);
            archi_items::RegisterItem("Civil Protector Part - Footlight Fuse",&archi_zod::give_CivilProtectorPart_Fuse03,undefined,false);

            archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
            archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
            archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
            archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
            archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);
            archi_items::RegisterPerk("Stamin-up",&archi_items::give_StaminUp,PERK_STAMINUP);
            archi_items::RegisterPerk("Widow's Wine",&archi_items::give_WidowsWine,PERK_WIDOWS_WINE);

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
            archi_items::RegisterWeapon("Wallbuy - Bootlegger",&archi_items::give_Weapon_BRM,"smg_sten");
            archi_items::RegisterWeapon("Wallbuy - Bowie Knife",&archi_items::give_Weapon_BowieKnife,"melee_bowie");

            level thread archi_zod::setup_locations();

            level thread setup_spare_change_trackers(7);

            level thread archi_zod::save_state_manager();
            level thread archi_zod::load_state();
        }

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

            archi_items::RegisterBoxWeapon("Mystery Box - Monkey Bombs","cymbal_monkey");
            archi_items::RegisterBoxWeapon("Mystery Box - Raygun","ray_gun");

            level thread archi_castle::setup_locations();

            level thread setup_spare_change_trackers(6);

            // Register Map Unique Items - Item name, callback, clientfield
            archi_items::RegisterItem("Shield Part - Door",&archi_items::give_ShieldPart_Door,undefined,true);
            archi_items::RegisterItem("Shield Part - Dolly",&archi_items::give_ShieldPart_Dolly,undefined,true);
            archi_items::RegisterItem("Shield Part - Clamp",&archi_items::give_ShieldPart_Clamp,undefined,true);

            archi_items::RegisterItem("Ragnarok DG-4 Part - Body",&archi_castle::give_RagnarokPart_Body,undefined,false);
            archi_items::RegisterItem("Ragnarok DG-4 Part - Guards",&archi_castle::give_RagnarokPart_Guards,undefined,false);
            archi_items::RegisterItem("Ragnarok DG-4 Part - Handle",&archi_castle::give_RagnarokPart_Handle,undefined,false);

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

        if (mapName == "zm_island")
        {
            level.archi.mapString = ARCHIPELAGO_MAP_ZETSUBOU;

            // 2 underwater
            level thread setup_spare_change_trackers(5);

            replace_craftable_onPickup("craft_shield_zm");
            level.archi.craftable_piece_to_location["craft_shield_zm_dolly"] = level.archi.mapString + " Shield Part Pickup - Dolly";
            level.archi.craftable_piece_to_location["craft_shield_zm_door"] = level.archi.mapString + " Shield Part Pickup - Door";
            level.archi.craftable_piece_to_location["craft_shield_zm_clamp"] = level.archi.mapString + " Shield Part Pickup - Clamp";

            replace_craftable_onPickup("gasmask");
            level.archi.craftable_piece_to_location["gasmask_part_visor"] = level.archi.mapString + " Gasmask Part Pickup - Visor";
            level.archi.craftable_piece_to_location["gasmask_part_filter"] = level.archi.mapString + " Gasmask Part Pickup - Filter";
            level.archi.craftable_piece_to_location["gasmask_part_strap"] = level.archi.mapString + " Gasmask Part Pickup - Strap";

            archi_items::RegisterBoxWeapon("Mystery Box - Monkey Bombs","cymbal_monkey");
            archi_items::RegisterBoxWeapon("Mystery Box - Raygun","ray_gun");
            archi_items::RegisterBoxWeapon("Mystery Box - KT-4","hero_mirg2000");

            archi_items::RegisterItem("Shield Part - Door",&archi_items::give_ShieldPart_Door,undefined,true);
            archi_items::RegisterItem("Shield Part - Dolly",&archi_items::give_ShieldPart_Dolly,undefined,true);
            archi_items::RegisterItem("Shield Part - Clamp",&archi_items::give_ShieldPart_Clamp,undefined,true);

            archi_island::setup_main_quest();
            archi_island::setup_main_ee_quest();
            archi_island::setup_weapon_quests();
            archi_island::setup_challenges();
            archi_island::adjust_host_bgb_pack();

            // TODO
            archi_items::RegisterItem("Gasmask Part - Visor",&archi_island::give_GasmaskPart_Visor,undefined,true);
            archi_items::RegisterItem("Gasmask Part - Filter",&archi_island::give_GasmaskPart_Filter,undefined,true);
            archi_items::RegisterItem("Gasmask Part - Strap",&archi_island::give_GasmaskPart_Strap,undefined,true);

            archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
            archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
            archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
            archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
            archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);
            archi_items::RegisterPerk("Stamin-up",&archi_items::give_StaminUp,PERK_STAMINUP);
            archi_items::RegisterPerk("Widow's Wine",&archi_items::give_WidowsWine,PERK_WIDOWS_WINE);

            archi_items::RegisterWeapon("Wallbuy - RK5",&archi_items::give_Weapon_RK5,"pistol_burst");
            archi_items::RegisterWeapon("Wallbuy - Sheiva",&archi_items::give_Weapon_Sheiva,"ar_marksman");
            archi_items::RegisterWeapon("Wallbuy - Pharo",&archi_items::give_Weapon_Pharo,"smg_burst");
            archi_items::RegisterWeapon("Wallbuy - L-CAR",&archi_items::give_Weapon_LCAR,"pistol_fullauto");
            archi_items::RegisterWeapon("Wallbuy - KRM-262",&archi_items::give_Weapon_KRM,"shotgun_pump");
            archi_items::RegisterWeapon("Wallbuy - Argus",&archi_items::give_Weapon_Argus,"shotgun_precision");
            archi_items::RegisterWeapon("Wallbuy - Kuda",&archi_items::give_Weapon_Kuda,"smg_standard");
            archi_items::RegisterWeapon("Wallbuy - Vesper",&archi_items::give_Weapon_Vesper,"smg_fastfire");
            archi_items::RegisterWeapon("Wallbuy - VMP",&archi_items::give_Weapon_VMP,"smg_versatile");
            archi_items::RegisterWeapon("Wallbuy - KN-44",&archi_items::give_Weapon_KN44,"ar_standard");
            archi_items::RegisterWeapon("Wallbuy - M8A7",&archi_items::give_Weapon_M8A7,"ar_longburst");
            archi_items::RegisterWeapon("Wallbuy - ICR-1",&archi_items::give_Weapon_ICR,"ar_accurate");
            archi_items::RegisterWeapon("Wallbuy - HVK-30",&archi_items::give_Weapon_HVK,"ar_cqb");
            archi_items::RegisterWeapon("Wallbuy - Bowie Knife",&archi_items::give_Weapon_BowieKnife,"melee_bowie");

            level thread archi_island::save_state_manager();
            level thread archi_island::load_state();
        }

        if (mapName == "zm_stalingrad")
        {
            level.archi.mapString = ARCHIPELAGO_MAP_GOROD_KROVI;

            // Mule Kick is underwater
            level thread setup_spare_change_trackers(5);

            level thread archi_stalingrad::setup_locations();
            level thread archi_stalingrad::setup_patches();

            replace_craftable_onPickup("craft_shield_zm");
            level.archi.craftable_piece_to_location["craft_shield_zm_dolly"] = level.archi.mapString + " Shield Part Pickup - Dolly";
            level.archi.craftable_piece_to_location["craft_shield_zm_door"] = level.archi.mapString + " Shield Part Pickup - Door";
            level.archi.craftable_piece_to_location["craft_shield_zm_clamp"] = level.archi.mapString + " Shield Part Pickup - Clamp";

            replace_craftable_onPickup("dragonride");
            level.archi.craftable_piece_to_location["dragonride_part_transmitter"] = level.archi.mapString + " Main Quest - Dragonride Part Pickup - Transmitter";
            level.archi.craftable_piece_to_location["dragonride_part_codes"] = level.archi.mapString + " Main Quest - Dragonride Part Pickup - Codes";
            level.archi.craftable_piece_to_location["dragonride_part_map"] = level.archi.mapString + " Main Quest - Dragonride Part Pickup - Map";

            level.archi.excluded_craftable_items["dragonride_part_transmitter"] = 1;
            level.archi.excluded_craftable_items["dragonride_part_codes"] = 1;
            level.archi.excluded_craftable_items["dragonride_part_map"] = 1;

            archi_items::RegisterBoxWeapon("Mystery Box - Monkey Bombs","cymbal_monkey");
            archi_items::RegisterBoxWeapon("Mystery Box - Raygun","ray_gun");
            archi_items::RegisterBoxWeapon("Mystery Box - Raygun Mark 3","raygun_mark3");

            archi_items::RegisterItem("Shield Part - Door",&archi_items::give_ShieldPart_Door,undefined,true);
            archi_items::RegisterItem("Shield Part - Dolly",&archi_items::give_ShieldPart_Dolly,undefined,true);
            archi_items::RegisterItem("Shield Part - Clamp",&archi_items::give_ShieldPart_Clamp,undefined,true);

            archi_items::RegisterItem("Dragonride Network Circuit - Transmitter",&archi_stalingrad::give_DragonridePart_Transmitter,undefined,false);
            archi_items::RegisterItem("Dragonride Network Circuit - Codes",&archi_stalingrad::give_DragonridePart_Codes,undefined,false);
            archi_items::RegisterItem("Dragonride Network Circuit - Map",&archi_stalingrad::give_DragonridePart_Map,undefined,false);

            archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
            archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
            archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
            archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
            archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);
            archi_items::RegisterPerk("Stamin-up",&archi_items::give_StaminUp,PERK_STAMINUP);

            archi_items::RegisterWeapon("Wallbuy - RK5",&archi_items::give_Weapon_RK5,"pistol_burst");
            archi_items::RegisterWeapon("Wallbuy - Sheiva",&archi_items::give_Weapon_Sheiva,"ar_marksman");
            archi_items::RegisterWeapon("Wallbuy - Pharo",&archi_items::give_Weapon_Pharo,"smg_burst");
            archi_items::RegisterWeapon("Wallbuy - L-CAR",&archi_items::give_Weapon_LCAR,"pistol_fullauto");
            archi_items::RegisterWeapon("Wallbuy - KRM-262",&archi_items::give_Weapon_KRM,"shotgun_pump");
            archi_items::RegisterWeapon("Wallbuy - Kuda",&archi_items::give_Weapon_Kuda,"smg_standard");
            archi_items::RegisterWeapon("Wallbuy - VMP",&archi_items::give_Weapon_VMP,"smg_versatile");
            archi_items::RegisterWeapon("Wallbuy - Vesper",&archi_items::give_Weapon_Vesper,"smg_fastfire");
            archi_items::RegisterWeapon("Wallbuy - Argus",&archi_items::give_Weapon_Argus,"shotgun_precision");
            archi_items::RegisterWeapon("Wallbuy - KN-44",&archi_items::give_Weapon_KN44,"ar_standard");
            archi_items::RegisterWeapon("Wallbuy - ICR-1",&archi_items::give_Weapon_ICR,"ar_accurate");
            archi_items::RegisterWeapon("Wallbuy - M8A7",&archi_items::give_Weapon_M8A7,"ar_longburst");
            archi_items::RegisterWeapon("Wallbuy - HVK-30",&archi_items::give_Weapon_HVK,"ar_cqb");
            archi_items::RegisterWeapon("Wallbuy - Bowie Knife",&archi_items::give_Weapon_BowieKnife,"melee_bowie");

            level thread archi_stalingrad::save_state_manager();
            level thread archi_stalingrad::load_state();
        }

        if (mapName == "zm_genesis")
        {
            level.archi.mapString = ARCHIPELAGO_MAP_REVELATIONS;

            level thread setup_spare_change_trackers(7);

            level thread archi_genesis::setup_main_quest();
            level thread archi_genesis::setup_keeper_friend();
            level thread archi_genesis::setup_main_ee_quest();
            level thread archi_genesis::setup_weapon_quest();
            level thread archi_genesis::setup_wearables();
            level thread archi_genesis::setup_challenges();

            level thread archi_genesis::patch_sword_quest();

            replace_craftable_onPickup("craft_shield_zm");
            level.archi.craftable_piece_to_location["craft_shield_zm_dolly"] = level.archi.mapString + " Shield Part Pickup - Dolly";
            level.archi.craftable_piece_to_location["craft_shield_zm_door"] = level.archi.mapString + " Shield Part Pickup - Door";
            level.archi.craftable_piece_to_location["craft_shield_zm_clamp"] = level.archi.mapString + " Shield Part Pickup - Clamp";

            archi_items::RegisterItem("Shield Part - Door",&archi_items::give_ShieldPart_Door,undefined,true);
            archi_items::RegisterItem("Shield Part - Dolly",&archi_items::give_ShieldPart_Dolly,undefined,true);
            archi_items::RegisterItem("Shield Part - Clamp",&archi_items::give_ShieldPart_Clamp,undefined,true);

            archi_items::RegisterBoxWeapon("Mystery Box - Apothicon Servant","idgun_genesis_0");
            archi_items::RegisterBoxWeapon("Mystery Box - Li'l Arnies","octobomb");
            archi_items::RegisterBoxWeapon("Mystery Box - Ragnarok DG-4s","hero_gravityspikes_melee");
            archi_items::RegisterBoxWeapon("Mystery Box - Thundergun","thundergun");
            archi_items::RegisterBoxWeapon("Mystery Box - Raygun","ray_gun");

            archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
            archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
            archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
            archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
            archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);
            archi_items::RegisterPerk("Stamin-up",&archi_items::give_StaminUp,PERK_STAMINUP);
            archi_items::RegisterPerk("Widow's Wine",&archi_items::give_WidowsWine,PERK_WIDOWS_WINE);

            archi_items::RegisterWeapon("Wallbuy - RK5",&archi_items::give_Weapon_RK5,"pistol_burst");
            archi_items::RegisterWeapon("Wallbuy - Sheiva",&archi_items::give_Weapon_Sheiva,"ar_marksman");
            archi_items::RegisterWeapon("Wallbuy - Pharo",&archi_items::give_Weapon_Pharo,"smg_burst");
            archi_items::RegisterWeapon("Wallbuy - L-CAR",&archi_items::give_Weapon_LCAR,"pistol_fullauto");
            archi_items::RegisterWeapon("Wallbuy - KRM-262",&archi_items::give_Weapon_KRM,"shotgun_pump");
            archi_items::RegisterWeapon("Wallbuy - Kuda",&archi_items::give_Weapon_Kuda,"smg_standard");
            archi_items::RegisterWeapon("Wallbuy - VMP",&archi_items::give_Weapon_VMP,"smg_versatile");
            archi_items::RegisterWeapon("Wallbuy - Vesper",&archi_items::give_Weapon_Vesper,"smg_fastfire");
            archi_items::RegisterWeapon("Wallbuy - Argus",&archi_items::give_Weapon_Argus,"shotgun_precision");
            archi_items::RegisterWeapon("Wallbuy - KN-44",&archi_items::give_Weapon_KN44,"ar_standard");
            archi_items::RegisterWeapon("Wallbuy - ICR-1",&archi_items::give_Weapon_ICR,"ar_accurate");
            archi_items::RegisterWeapon("Wallbuy - M8A7",&archi_items::give_Weapon_M8A7,"ar_longburst");
            archi_items::RegisterWeapon("Wallbuy - HVK-30",&archi_items::give_Weapon_HVK,"ar_cqb");
            archi_items::RegisterWeapon("Wallbuy - Bowie Knife",&archi_items::give_Weapon_BowieKnife,"melee_bowie");
        }

        if (mapName == "zm_factory")
        {
            level.archi.mapString = ARCHIPELAGO_MAP_THE_GIANT;

            // 7 possible machines, 6 will spawn
            level thread setup_spare_change_trackers(6);
            
            archi_items::RegisterBoxWeapon("Mystery Box - Monkey Bombs","cymbal_monkey");
            archi_items::RegisterBoxWeapon("Mystery Box - Raygun","ray_gun");
            archi_items::RegisterBoxWeapon("Mystery Box - Wunderwaffe DG-2","tesla_gun");
            
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

        level thread setup_boarding_window();
        level thread setup_can_player_purchase_perk();

        //Server-wide thread to get items from the Lua/LUI
        level thread item_get_from_lua();

        //Apply settings with Existing DVARS, should be set in menu during initial Room Connection
        level thread on_archi_connect_settings();
    }

    //Setup default map changes
    default_map_changes();
}

function setup_can_player_purchase_perk()
{
    level flag::wait_till("initial_blackscreen_passed");

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
    // if (isdefined(level.bgb_machines))
    // {
    //     for(i = 0; i < level.bgb_machines.size; i++)
    //     {
    //         level.bgb_machines[i].origin = (10000, 10000, 10000);
    //         level.bgb_machines[i].unitrigger_stub.origin = (10000, 10000, 10000);
    //     }
    // }
}

function on_player_connect()
{
    if (self IsHost())
    {
        level flag::wait_till("ap_loaded");
        IPrintLn("Location checker started");
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

function setup_boarding_window()
{
    foreach ( player in GetPlayers() )
    {
        player thread watch_player_boarding_window();
    }

    callback::on_connect(&watch_player_boarding_window);
}

function watch_player_boarding_window()
{
    level endon("end_game");
    self endon("disconnect");

    while(true)
    {
        self waittill("boarding_window");
        level notify("ap_boarding_window");
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
    level flag::wait_till( "initial_blackscreen_passed" );
    wait 5; // Wait for log to clear on game startup
    level endon("end_game");
	level endon("end_round_think");
    while(true)
    {
        item = GetDvarString("ARCHIPELAGO_ITEM_GET");
        if ( item != "NONE" )
        {
            award_item(item);
            SetDvar("ARCHIPELAGO_ITEM_GET","NONE");
            
        }
        wait .2;
    }
}

function award_item(item)
{
     if (isdefined(level.archi.items[item]))
    {
        ap_item = level.archi.items[item];
        ap_item.count += 1;
        if (isdefined(ap_item.type))
        {
            if (ap_item.type == "box_weapon" && isdefined(ap_item.weapon_name))
            {
                weapon_name = ap_item.weapon_name;
                weapon = GetWeapon(weapon_name);
                z_weapon = level.zombie_weapons[weapon];
                z_weapon.is_in_box = 1;
            }
        }
        else
        {
            self [[ap_item.getFunc]]();
        }

        // if (isdefined(level.archi.items[item].clientField))
        // {
        //     //TODO: make this safe, so it checks if the clientfield exists first
        //     level clientfield::set(level.archi.items[item].clientField, 1);
        // }
        //Notif happens a bit too early compared to log messages
        wait .5;
        LUINotifyEvent(&"ap_ui_get", 0);
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
    level flag::wait_till( "initial_blackscreen_passed" );
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
    if (self.craftableName == "craft_shield_zm")
    {
        if (level.archi.randomized_shield_parts == 1)
        {
            self thread _remove_piece();
        }
    } 
    else 
    {
        if (!(isdefined(level.archi.excluded_craftable_items) && isdefined(level.archi.excluded_craftable_items[fullName])))
        {
            self thread _remove_piece();
        }
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
    level flag::wait_till("initial_blackscreen_passed");

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
    machines = getentarray(s_custom_perk.radiant_machine_name, "targetname");
    machine_triggers = GetEntArray( s_custom_perk.radiant_machine_name, "target" );
    if (machine_triggers.size > 0 && isdefined(machine_triggers[0].power_on) && machine_triggers[0].power_on)
    {
        level notify(s_custom_perk.alias + "_off");
        // Turn (later map) light and jingle back off
        foreach(machine in machines)
        {
            machine notify("stop_loopsound");
            machine zm_perks::perk_fx(undefined, 1);
        }
    }
    t_perk = undefined;

    while(true)
    {
        // Find the new machine and set our AP hint string
        while(true)
        {
            wait (0.1);
            t_perk = GetEntArray(perk, "script_noteworthy");
            if (isdefined(t_perk))
            {
                foreach(t_perky in t_perk)
                {
                    t_perky SetHintString(ap_hint_string);
                    break;
                }
            }
        }

        // Wait until something powers the machine on
        level waittill(perk + "_power_on");
        if (IS_TRUE(level.archi.active_perk_machines[perk]))
        {
            // We've got the AP item, we can stop turning it off
            if (isdefined(t_perk)) 
            {
                foreach(t_perky in t_perk)
                {
                    t_perky zm_perks::reset_vending_hint_string();
                    break;
                }
            }
            break;
        }
        wait(0.5);
        level notify(s_custom_perk.alias + "_off");
        machines = getentarray(s_custom_perk.radiant_machine_name, "targetname");
        // Turn (later map) light and jingle back off
        foreach(machine in machines)
        {
            machine notify("stop_loopsound");
            machine zm_perks::perk_fx(undefined, 1);
        }
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
    if (isdefined(level.archi.wallbuys[weapon.name]) && IS_TRUE(level.archi.wallbuys[weapon.name])) 
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
