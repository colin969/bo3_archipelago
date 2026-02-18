#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\laststand_shared;
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
#using scripts\zm\_zm_weapons;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\zm\archi_items;
#using scripts\zm\archi_commands;
#using scripts\zm\archi_castle;
#using scripts\zm\archi_island;
#using scripts\zm\archi_stalingrad;
#using scripts\zm\archi_genesis;
#using scripts\zm\archi_zod;
#using scripts\zm\archi_factory;
#using scripts\zm\archi_save;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_bgb_machine;

#insert scripts\zm\archi_core.gsh;

#namespace archi_core;

#precache( "eventstring", "ap_save_checkpoint_data");
#precache( "eventstring", "ap_save_data" );
#precache( "eventstring", "ap_save_data_universal" );
#precache( "eventstring", "ap_load_data" );
#precache( "eventstring", "ap_load_data_universal" );
#precache( "eventstring", "ap_clear_data" );
#precache( "eventstring", "ap_debug_magicbox" );
#precache( "eventstring", "ap_notification" );
#precache( "eventstring", "ap_init_dll" );
#precache( "eventstring", "ap_init_state" );
#precache( "eventstring", "ap_init_goal_cond" );
#precache( "eventstring", "ap_deathlink_triggered" );

REGISTER_SYSTEM_EX("archipelago_core", &__init__, &__main__, undefined)

function __init__()
{
    clientfield::register("world", "ap_mystery_box_changes", 1, 28, "int");
    level flag::init("ap_prevent_checkpoints", 1);
    level flag::init("ap_attachment_rando_ready");
    level flag::init("ap_loaded_save_data");

    // Some maps make requirements harder if not in a ranked match
    level.rankedmatch = 1;
    SetDvar("zm_private_rankedmatch", 1);

    SetDvar( "MOD_VERSION", MOD_VERSION );

    // First gobblegum free each round
    SetDvar("scr_firstGumFree", 1);
    
    //Message Passing Dvars
    SetDvar("ARCHIPELAGO_ITEM_GET", "NONE");
    SetDvar("ARCHIPELAGO_LOCATION_SEND", "NONE");
    SetDvar("ARCHIPELAGO_SAY_SEND", "NONE"); 
    SetDvar("ARCHIPELAGO_SAVE_DATA", "NONE");
    SetDvar("ARCHIPELAGO_LOAD_DATA", "NONE");
    SetDvar("ARCHIPELAGO_LOAD_DATA_SEED", "NONE");
    SetDvar("ARCHIPELAGO_LOAD_DATA_UNIVERAL", "NONE");
    SetDvar("ARCHIPELAGO_SAVE_PROGRESS", "NONE");
    SetDvar("ARCHIPELAGO_DEATHNLINK_RECIEVED", "NONE");
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
    // Wait until the dll client has set the settings dvars
    while (true)
    {
        dvar_value = GetDvarString("ARCHIPELAGO_SETTINGS_READY", "");
        if (dvar_value != "")
        {
            SetDvar("ARCHIPELAGO_SETTINGS_READY", "");
            LUINotifyEvent(&"ap_init_goal_cond", 0);
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
    level.archi.mystery_box_special_items = GetDvarInt("ARCHIPELAGO_MYSTERY_BOX_SPECIAL", 0);
    level.archi.mystery_box_regular_items = GetDvarInt("ARCHIPELAGO_MYSTERY_BOX_REGULAR", 0);
    level.archi.difficulty_gorod_egg_cooldown = GetDvarInt("ARCHIPELAGO_DIFFICULTY_GOROD_EGG_COOLDOWN", 0);
    level.archi.difficulty_gorod_dragon_wings = GetDvarInt("ARCHIPELAGO_DIFFICULTY_GOROD_DRAGON_WINGS", 0);
    level.archi.difficulty_ee_checkpoints = GetDvarInt("ARCHIPELAGO_DIFFICULTY_EE_CHECKPOINTS", 0);
    level.archi.difficulty_round_checkpoints = GetDvarInt("ARCHIPELAGO_DIFFICULTY_ROUND_CHECKPOINTS", 0);
    level.archi.attachments_randomized = GetDvarInt("ARCHIPELAGO_ATTACHMENT_RANDO_ENABLED", 0);
    level.archi.attachments_sight_weight = GetDvarInt("ARCHIPELAGO_ATTACHMENT_RANDO_SIGHT_SIZE_WEIGHT", 25);
    level.archi.deathlink_enabled = GetDvarInt("ARCHIPELAGO_DEATHLINK_ENABLED", 0);
    level.archi.deathlink_send_mode = GetDvarInt("ARCHIPELAGO_DEATHLINK_SEND_MODE", 0);
    level.archi.deathlink_recv_mode = GetDvarInt("ARCHIPELAGO_DEATHLINK_RECV_MODE", 0);

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

        on_archi_connect_settings();

        //Collection of Locations that are checked, 
        level.archi.locationQueue = array();

        level.archi.save_checkpoint = false;
        level.archi.save_zombie_count = true;
        level.archi.opened_doors = [];
        level.archi.opened_debris = [];
        level.archi.excluded_craftable_items = [];
        level.archi.ap_box_keys = [];
        level.archi.ap_box_states = [];
        level.archi.ap_weapon_bits = [];

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

        archi_items::RegisterUniversalItem("50 Points",&archi_items::give_50Points);
        archi_items::RegisterUniversalItem("500 Points",&archi_items::give_500Points);
        archi_items::RegisterUniversalItem("50000 Points",&archi_items::give_50000Points);

        // Traps
        archi_items::RegisterUniversalItem("Trap - Third Person Mode",&archi_items::give_Trap_ThirdPerson);
        archi_items::RegisterUniversalItem("Trap - Grenade Party",&archi_items::give_Trap_GrenadeParty);
        archi_items::RegisterUniversalItem("Trap - Nuke Powerup",&archi_items::give_Trap_NukePowerup);
        archi_items::RegisterUniversalItem("Trap - Knuckle Crack",&archi_items::give_Trap_KnuckleCrack);

        // Gifts
        archi_items::RegisterUniversalItem("Gift - Unlimited Sprint (2 Minutes)",&archi_items::give_Gift_UnlimitedSprint);
        archi_items::RegisterUniversalItem("Gift - Carpenter Powerup",&archi_items::give_Gift_CarpenterPowerup);
        archi_items::RegisterUniversalItem("Gift - Double Points Powerup",&archi_items::give_Gift_DoublePointsPowerup);
        archi_items::RegisterUniversalItem("Gift - InstaKill Powerup",&archi_items::give_Gift_InstaKillPowerup);
        archi_items::RegisterUniversalItem("Gift - Fire Sale Powerup",&archi_items::give_Gift_FireSalePowerup);
        archi_items::RegisterUniversalItem("Gift - Max Ammo Powerup",&archi_items::give_Gift_MaxAmmoPowerup);
        archi_items::RegisterUniversalItem("Gift - Free Perk Powerup",&archi_items::give_Gift_FreePerkPowerup);

        // Progressives
        patch_pap();
        archi_items::RegisterUniversalItem("Progressive - Pack-A-Punch Machine",&archi_items::give_ProgressivePap);
        archi_items::RegisterUniversalItem("Progressive - Perk Limit Increase",&archi_items::give_ProgressivePerkLimit);

        archi_commands::init_commands();
        level thread round_start_location();
        level thread round_end_noti();
        level thread repaired_board_noti();

        if (mapName == "zm_zod")
        {
            level.archi.mapString = ARCHIPELAGO_MAP_SHADOWS_OF_EVIL;

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

            if (level.archi.mystery_box_special_items == 1) {
                archi_items::RegisterBoxWeapon("Mystery Box - Apothicon Servant","idgun_0",0);
                archi_items::RegisterBoxWeapon("Mystery Box - Li'l Arnies","octobomb",1);
                archi_items::RegisterBoxWeapon("Mystery Box - Raygun","ray_gun",2);
            }

            if (level.archi.mystery_box_regular_items == 1) {
                universal_box_registration();
            }

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

            level.archi.save_state_manager = &archi_zod::save_state_manager;
            level.archi.load_state_manager = &archi_zod::load_state;
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

            if (level.archi.mystery_box_special_items == 1) {
                archi_items::RegisterBoxWeapon("Mystery Box - Monkey Bombs","cymbal_monkey",0);
                archi_items::RegisterBoxWeapon("Mystery Box - Raygun","ray_gun",1);
            }

            if (level.archi.mystery_box_regular_items == 1) {
                universal_box_registration();
            }

            level thread archi_castle::setup_locations();

            level thread setup_spare_change_trackers(6);

            // Register Map Unique Items - Item name, callback, clientfield
            archi_items::RegisterItem("Shield Part - Door",&archi_items::give_ShieldPart_Door,undefined,true);
            archi_items::RegisterItem("Shield Part - Dolly",&archi_items::give_ShieldPart_Dolly,undefined,true);
            archi_items::RegisterItem("Shield Part - Clamp",&archi_items::give_ShieldPart_Clamp,undefined,true);

            archi_items::RegisterItem("Ragnarok DG-4 Part - Body",&archi_castle::give_RagnarokPart_Body,undefined,false);
            archi_items::RegisterItem("Ragnarok DG-4 Part - Guards",&archi_castle::give_RagnarokPart_Guards,undefined,false);
            archi_items::RegisterItem("Ragnarok DG-4 Part - Handle",&archi_castle::give_RagnarokPart_Handle,undefined,false);

            // Machines
            archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
            archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
            archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
            archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
            archi_items::RegisterPerk("Stamin-up",&archi_items::give_StaminUp,PERK_STAMINUP);
            archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);

            // Wunderfizz
            archi_items::RegisterPerk("Deadshot Daiquiri",&archi_items::give_DeadShot,PERK_DEAD_SHOT);
            archi_items::RegisterPerk("Electric Cherry",&archi_items::give_WidowsWine,PERK_ELECTRIC_CHERRY);
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
            archi_items::RegisterWeapon("Wallbuy - BRM",&archi_items::give_Weapon_BRM,"lmg_light");
            archi_items::RegisterWeapon("Wallbuy - Bowie Knife",&archi_items::give_Weapon_BowieKnife,"melee_bowie");

            level.archi.save_state_manager = &archi_castle::save_state_manager;
            level.archi.load_state_manager = &archi_castle::load_state;
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

            if (level.archi.mystery_box_special_items == 1) {
                archi_items::RegisterBoxWeapon("Mystery Box - Monkey Bombs","cymbal_monkey",0);
                archi_items::RegisterBoxWeapon("Mystery Box - Raygun","ray_gun",1);
                archi_items::RegisterBoxWeapon("Mystery Box - KT-4","hero_mirg2000",2);
            }

            if (level.archi.mystery_box_regular_items == 1) {
                universal_box_registration();
            }

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

            // Machines
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
            
            level.archi.save_state_manager = &archi_island::save_state_manager;
            level.archi.load_state_manager = &archi_island::load_state;
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

            if (level.archi.mystery_box_special_items == 1) {
                archi_items::RegisterBoxWeapon("Mystery Box - Monkey Bombs","cymbal_monkey",0);
                archi_items::RegisterBoxWeapon("Mystery Box - Raygun","ray_gun",1);
                archi_items::RegisterBoxWeapon("Mystery Box - Raygun Mark 3","raygun_mark3",2);
            }

            if (level.archi.mystery_box_regular_items == 1) {
                universal_box_registration();
            }

            archi_items::RegisterItem("Shield Part - Door",&archi_items::give_ShieldPart_Door,undefined,true);
            archi_items::RegisterItem("Shield Part - Dolly",&archi_items::give_ShieldPart_Dolly,undefined,true);
            archi_items::RegisterItem("Shield Part - Clamp",&archi_items::give_ShieldPart_Clamp,undefined,true);

            archi_items::RegisterItem("Dragonride Network Circuit - Transmitter",&archi_stalingrad::give_DragonridePart_Transmitter,undefined,false);
            archi_items::RegisterItem("Dragonride Network Circuit - Codes",&archi_stalingrad::give_DragonridePart_Codes,undefined,false);
            archi_items::RegisterItem("Dragonride Network Circuit - Map",&archi_stalingrad::give_DragonridePart_Map,undefined,false);

            // Machines
            archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
            archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
            archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
            archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
            archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);
            archi_items::RegisterPerk("Stamin-up",&archi_items::give_StaminUp,PERK_STAMINUP);

            // Wunderfizz
            archi_items::RegisterPerk("Deadshot Daiquiri",&archi_items::give_DeadShot,PERK_DEAD_SHOT);
            archi_items::RegisterPerk("Electric Cherry",&archi_items::give_WidowsWine,PERK_ELECTRIC_CHERRY);
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

            level.archi.save_state_manager = &archi_stalingrad::save_state_manager;
            level.archi.load_state_manager = &archi_stalingrad::load_state;
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

            if (level.archi.mystery_box_special_items == 1) {
                archi_items::RegisterBoxWeapon("Mystery Box - Apothicon Servant","idgun_genesis_0",0);
                archi_items::RegisterBoxWeapon("Mystery Box - Li'l Arnies","octobomb",1);
                archi_items::RegisterBoxWeapon("Mystery Box - Ragnarok DG-4s","hero_gravityspikes_melee",2);
                archi_items::RegisterBoxWeapon("Mystery Box - Thundergun","thundergun",3);
                archi_items::RegisterBoxWeapon("Mystery Box - Raygun","ray_gun",4);
            }

            if (level.archi.mystery_box_regular_items == 1) {
                universal_box_registration();
            }

            // Machines
            archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
            archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
            archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
            archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
            archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);
            archi_items::RegisterPerk("Stamin-up",&archi_items::give_StaminUp,PERK_STAMINUP);
            archi_items::RegisterPerk("Widow's Wine",&archi_items::give_WidowsWine,PERK_WIDOWS_WINE);

            // Wunderfizz
            archi_items::RegisterPerk("Deadshot Daiquiri",&archi_items::give_DeadShot,PERK_DEAD_SHOT);
            archi_items::RegisterPerk("Electric Cherry",&archi_items::give_WidowsWine,PERK_ELECTRIC_CHERRY);

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

            level.archi.save_state_manager = &archi_genesis::save_state_manager;
            level.archi.load_state_manager = &archi_genesis::load_state;
        }

        if (mapName == "zm_factory")
        {
            level.archi.mapString = ARCHIPELAGO_MAP_THE_GIANT;

            // 7 possible machines, 6 will spawn
            level thread setup_spare_change_trackers(6);
            
            if (level.archi.mystery_box_special_items == 1) {
                archi_items::RegisterBoxWeapon("Mystery Box - Monkey Bombs","cymbal_monkey",0);
                archi_items::RegisterBoxWeapon("Mystery Box - Raygun","ray_gun",1);
                archi_items::RegisterBoxWeapon("Mystery Box - Wunderwaffe DG-2","tesla_gun",2);
            }

            if (level.archi.mystery_box_regular_items == 1) {
                universal_box_registration();
            }

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

            level.archi.save_state_manager = &archi_factory::save_state_manager;
            level.archi.load_state_manager = &archi_factory::load_state;
        }

        level thread init_attachment_rando();
        WAIT_SERVER_FRAME
        level thread archi_save::setup_map_saving();

        patch_wunderfizz();

        level thread setup_boarding_window();
        level thread setup_can_player_purchase_perk();

        //Server-wide thread to get items from the Lua/LUI
        level thread item_get_from_lua();

    }

    if (level.archi.deathlink_enabled == 1)
    {
        level thread deathlink_send_monitor();
        level thread deathlink_recv_monitor();
    }

    update_box_clientfield();

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
    level.initial_quick_revive_power_off = 1;

    wait 1;

    zombie_utility::set_zombie_var("zombie_intermission_time", 4);
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
        wait (0.1);
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
                if (isdefined(z_weapon))
                {
                    z_weapon.is_in_box = 1;
                }
                // Update clientfield state
                level.archi.ap_box_states[weapon_name] = 0;
                update_box_clientfield();
            }
        }
        else
        {
            self [[ap_item.getFunc]]();
        }

        // Notification on Hud
        SetDvar("ARCHIPELAGO_UI_GET_TEXT", item);
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
        wait (0.2);
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
            LUINotifyEvent(&"ap_notification", 0);
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
    foreach(t_audio_bump in a_triggers)
	{
		if(t_audio_bump.script_sound === "zmb_perks_bump_bottle")
		{
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
    WAIT_SERVER_FRAME
    // Prevent more spawns
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
        t_machine SetHintString("'Progressive - Pack-A-Punch Machine' is required");
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
            t_machine SetHintString("'Progressive - Pack-A-Punch Machine' is required");
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
            t_machine SetHintString("'Progressive - Pack-A-Punch Machine' is required");
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
    if (IS_TRUE(level.archi.wallbuys[weapon.name])) 
    {
        return false;
    }
    return true;
}


// Good for most official maps
function universal_box_registration()
{
    // 2 best of each, ideally
    archi_items::RegisterBoxWeapon("Mystery Box - FFAR","ar_famas",15);
    archi_items::RegisterBoxWeapon("Mystery Box - Drakon","sniper_fastsemi",16);
    archi_items::RegisterBoxWeapon("Mystery Box - Locus","sniper_fastbolt",17);
    archi_items::RegisterBoxWeapon("Mystery Box - Man-o-War","ar_damage",18);
    archi_items::RegisterBoxWeapon("Mystery Box - HVK-30","ar_cqb",19);
    archi_items::RegisterBoxWeapon("Mystery Box - ICR-1","ar_accurate",20);
    archi_items::RegisterBoxWeapon("Mystery Box - Haymaker 12","shotgun_fullauto",21);
    archi_items::RegisterBoxWeapon("Mystery Box - 205 Brecci","shotgun_semiauto",22);
    archi_items::RegisterBoxWeapon("Mystery Box - Dingo","lmg_cqb",23);
    archi_items::RegisterBoxWeapon("Mystery Box - 48 Dredge","lmg_heavy",24);
    // RPK is on about half the maps
    archi_items::RegisterBoxWeapon("Mystery Box - RPK","lmg_rpk",25);
    archi_items::RegisterBoxWeapon("Mystery Box - VMP","smg_versatile",26);
    archi_items::RegisterBoxWeapon("Mystery Box - Vesper","smg_fastfire",27);
}

function update_box_clientfield()
{
    removed_items = 0;
    foreach (weapon_name in GetArrayKeys(level.archi.ap_weapon_bits))
    {
        if (level.archi.ap_box_states[weapon_name] == 1)
        {
            removed_items |= (1 << level.archi.ap_weapon_bits[weapon_name]);
        }
    }
    level clientfield::set("ap_mystery_box_changes", removed_items);
}

function patch_wunderfizz()
{
    level._random_zombie_perk_cost = 2000;
    // Store original perk list
    level.archi.original_random_perk_list = [];
    foreach (perk in level._random_perk_machine_perk_list)
    {
        level.archi.original_random_perk_list[level.archi.original_random_perk_list.size] = perk;
    }

    // Add monitor to update wunderfizz when contents changes
    level thread update_wunderfizz();
    WAIT_SERVER_FRAME
    level notify("ap_update_wunderfizz");

    level.archi.original_custom_random_perk_weights = level.custom_random_perk_weights;
    level.custom_random_perk_weights = &custom_random_perk_weights;
}

function custom_random_perk_weights()
{
    if(isdefined(level.archi.original_custom_random_perk_weights))
    {
        // Get keys from map's own weighting func
        keys = [[level.archi.original_custom_random_perk_weights]]();
        filtered_perks = [];
        // Remove perks we haven't unlocked yet
        foreach (key in keys) {
            perk = level._random_perk_machine_perk_list[key];
            if (isdefined(level.archi.active_perk_machines[perk]))
            {
                if (level.archi.active_perk_machines[perk])
                {
                    filtered_perks[filtered_perks.size] = perk;
                }
            }
            else
            {
                filtered_perks[filtered_perks.size] = perk;
            }
        }
        level._random_perk_machine_perk_list = filtered_perks;
        return GetArrayKeys(filtered_perks);
    }
    else
    {
        // No level weighting, just randomly return
        temp_array = array::randomize(level._random_perk_machine_perk_list);
        keys = GetArrayKeys(temp_array);
        return keys;
        
        
    }
}

// Updating list is important for trigger to go invisible for player with all available perks
function update_wunderfizz()
{
    level endon("end_game");

    while(true)
    {
        level waittill("ap_update_wunderfizz");

        level._random_perk_machine_perk_list = [];
        foreach (perk in level.archi.original_random_perk_list)
        {
            if (isdefined(level.archi.active_perk_machines[perk]))
            {
                if (level.archi.active_perk_machines[perk])
                {
                    level._random_perk_machine_perk_list[level._random_perk_machine_perk_list.size] = perk;
                }
            }
            else
            {
                level._random_perk_machine_perk_list[level._random_perk_machine_perk_list.size] = perk;
            }
        }
    }
}

function register_weapon_attachments( weapon_name )
{
    switch( weapon_name )
    {
        case "ar_garand":
        case "ar_galil":
        case "ar_famas":
        case "ar_m16":
        case "ar_standard":
        case "ar_marksman":
        case "ar_longburst":
        case "ar_damage":
        case "ar_cqb":
        case "ar_accurate":
            self.ap_sights_large = array( "acog", "dualoptic", "ir" );
            self.ap_sights_small = array( "none", "holo", "reddot", "reflex" );
            self.ap_attachments = array( "damage", "extbarrel", "extclip", "fastreload", "fmj", "grip", "quickdraw", "rf", "stalker", "steadyaim", "suppressed" );
            if( weapon_name == "ar_m16" || weapon_name == "ar_famas" )
            {
                ArrayRemoveValue( self.ap_sights_large, "dualoptic" );
            }
            break;

        case "lmg_rpk":
        case "lmg_slowfire":
        case "lmg_light":
        case "lmg_heavy":
        case "lmg_cqb":
            self.ap_sights_large = array( "acog", "dualoptic", "ir" );
            self.ap_sights_small = array( "none", "holo", "reddot", "reflex" );
            self.ap_attachments = array( "extclip", "fastreload", "fmj", "grip", "quickdraw", "rf", "stalker", "steadyaim", "suppressed" );
            if( weapon_name == "lmg_rpk" )
            {
                ArrayRemoveValue( self.ap_sights_large, "dualoptic" );
            }
            break;

        case "smg_ak74u":
        case "smg_versatile":
        case "smg_standard":
        case "smg_ppsh":
        case "smg_fastfire":
        case "smg_capacity":
        case "smg_longrange":
        case "smg_burst":
        case "smg_mp40":
            self.ap_sights_large = array( "acog", "dualoptic" );
            self.ap_sights_small = array( "none", "holo", "reddot", "reflex" );
            self.ap_attachments = array( "extbarrel", "extclip", "fastreload", "fmj", "grip", "quickdraw", "rf", "stalker", "steadyaim", "suppressed" );
            if( weapon_name == "smg_ak74u" || weapon_name == "smg_mp40" )
            {
                // Bad compat with large scopes
                self.ap_sights_large = self.ap_sights_small;
            }
            if ( weapon_name == "smg_ppsh" ) {
                self.ap_sights_large = array("none");
                self.ap_sights_small = array("none");
            }
            break;

        case "shotgun_semiauto":
        case "shotgun_pump":
        case "shotgun_precision":
        case "shotgun_fullauto":
        case "shotgun_energy":
            // No large sights, duplicate array instead
            self.ap_sights_large = array( "none", "holo", "reddot", "reflex" );
            self.ap_sights_small = array( "none", "holo", "reddot", "reflex" );
            self.ap_attachments = array( "extbarrel", "extclip", "fastreload", "quickdraw", "rf", "stalker", "steadyaim", "suppressed" );
            break;

        case "pistol_fullauto":
        case "pistol_burst":
        case "pistol_energy":
        case "pistol_m1911":
        case "pistol_standard":
            // No large sights, duplicate array instead
            self.ap_sights_large = array( "none", "reddot", "reflex" );
            self.ap_sights_small = array( "none", "reddot", "reflex" );
            self.ap_attachments = array( "damage", "extbarrel", "extclip", "fastreload", "fmj", "quickdraw", "steadyaim", "suppressed" );
            break;

        case "sniper_fastsemi":
        case "sniper_powerbolt":
        case "sniper_fastbolt":
            self.ap_sights_large = array( "none", "acog", "dualoptic", "ir" );
            self.ap_sights_small = array( "reddot" );
            self.ap_attachments = array( "extclip", "fastreload", "fmj", "rf", "stalker", "suppressed", "swayreduc" );
            break;
    }
}

// function attachment_rando()
// {
//     foreach (weapon in GetArrayKeys(level.zombie_weapons))
//     {
//         level.zombie_weapons[weapon] register_weapon_attachments(weapon.name);
//         attachments = generate_attachments(weapon);
//         level.zombie_weapons[weapon].force_attachments = attachments;
//     }
// }

function init_attachment_rando()
{
    level flag::wait_till("ap_loaded_save_data");

    if (level.archi.attachments_randomized == 1)
    {
        foreach (weapon in GetArrayKeys(level.zombie_weapons))
        {
            base_weapon = zm_weapons::get_base_weapon( weapon.rootweapon );
            attachment_str = GetDvarString("ARCHIPELAGO_ATTACHMENT_RANDO_" + ToUpper(base_weapon.name), "");
            if (attachment_str != "")
            {
                level.zombie_weapons[weapon].force_attachments = strtok(attachment_str, "+");
            }
        }
    }

    level flag::set("ap_attachment_rando_ready");
}

function generate_attachments(weapon)
{
    dw_weapons = array("pistol_standard_upgraded","pistol_m1911_upgraded","pistol_revolver38_upgraded","pistol_shotgun_dw","pistol_shotgun_dw_upgraded");
    weapon_name = weapon.name;
    upgrade = StrEndsWith( weapon_name, "_upgraded" );
    base_weapon = zm_weapons::get_base_weapon( weapon.rootweapon );
    weapon_data = level.zombie_weapons[ base_weapon ];
    attachments = [];
    sight = undefined;
    if (isdefined(weapon_data.ap_sights_large) && weapon_data.ap_sights_large.size > 0)
    {
        if (RandomInt(100) < level.archi.attachments_sight_weight)
        {
            sight = array::random(weapon_data.ap_sights_large);
        }
        else
        {
            sight = array::random(weapon_data.ap_sights_small);
        }
        attachments[attachments.size] = sight;
    }
    if (isdefined(weapon_data.ap_attachments))
    {
        num_attachments = min(3, weapon_data.ap_attachments.size);
        attachment_bag = array::randomize(weapon_data.ap_attachments);
        for (i = 0; i < num_attachments; i++)
        {
            attachments[attachments.size] = attachment_bag[i];
        }
    }
    // Add dual wield to expected weapons
    if( IsInArray(dw_weapons, weapon_name) )
    {
        ArrayInsert( attachments, "dw", 0 );
    }
    // Remove either sight or sway reduction since incompatible on snipers
    if( isdefined( sight ) && IsInArray( attachments, "swayreduc" ) )
    {
        ArrayRemoveValue( attachments, ( RandomInt(3) != 0 ? sight : "swayreduc" ) );
    }

    return attachments;
}

function patch_pap()
{
    // Disable AATs WIP
    vending_weapon_upgrade_trigger = zm_pap_util::get_triggers();
    if (vending_weapon_upgrade_trigger.size >= 1)
    {
        array::thread_all(vending_weapon_upgrade_trigger, &keep_aats_locked);
    }
}

function keep_aats_locked()
{
    level endon("ap_aats_enabled");

    if(!isdefined(self.powered) || !self.powered.power)
    {
        level waittill("pack_a_punch_on");
    }
    wait(1);

    while(true)
    {
        vending_weapon_upgrade_trigger.aat_cost = 999999;
        level waittill("hash_ab83a4db");
        WAIT_SERVER_FRAME
        vending_weapon_upgrade_trigger.aat_cost = 999999;
        level waittill("bonfire_sale_off");
        WAIT_SERVER_FRAME
    }
}

function deathlink_recv_monitor()
{
    while(true)
    {
        dvar_value = GetDvarString("ARCHIPELAGO_DEATHNLINK_RECIEVED", "NONE");
        if (dvar_value != "NONE")
        {   
            IPrintLnBold("Deathlink :)");
            SetDvar("ARCHIPELAGO_DEATHNLINK_RECIEVED", "NONE");

            // Down a random player
            if (level.archi.deathlink_recv_mode == 0)
            {
                players = array::randomize(level.players);
                foreach(player in players)
                {
                    if (IsAlive(player) && !player laststand::player_is_in_laststand())
                    {
                        player dodamage(player.health + 666, player.origin);
                        break;
                    }
                }
            }

            // Kill a random player
            if (level.archi.deathlink_recv_mode == 1)
            {
                players = array::randomize(level.players);
                foreach(player in players)
                {
                    if (player.sessionstate != "spectator")
                    {
                        player disableinvulnerability();
                        player.lives = 0;
                        player dodamage(player.health + 1000, player.origin);
                        player.bleedout_time = 0;
                        break;
                    }
                }
            }

            // Down all players
            if (level.archi.deathlink_recv_mode == 2)
            {
                foreach (player in level.players)
                {
                    player dodamage(player.health + 666, player.origin);
                }
            }

            // End game
            if (level.archi.deathlink_recv_mode == 3)
            {
                level notify("end_game");
            }
        }
        wait(0.5);
    }
}

function deathlink_send_monitor()
{
    // Single down
    if (level.archi.deathlink_send_mode == 0)
    {
        foreach(player in level.players)
        {
            player thread deathlink_any_player_down();
        }
        callback::on_connect(&deathlink_any_player_down);
    }

    // Single death
    if (level.archi.deathlink_send_mode == 1)
    {
        foreach(player in level.players)
        {
            player thread deathlink_any_player_death();
        }
        callback::on_connect(&deathlink_any_player_death);
    }

    // Monitor both end game scenarios
    level thread end_game_via_player_death_monitor();

    level waittill("end_game");
    // Check if game ended from a player disconnecting while all others players are on the ground, they'll all be in last stand
    foreach (player in level.players)
    {
        if (!player.sessionstate != "spectator" && !player laststand::player_is_in_laststand())
        {
            return;
        }
    }

    LUINotifyEvent(&"ap_deathlink_triggered", 0);
}

function end_game_via_player_death_monitor()
{
    level waittill("last_player_died");
    LUINotifyEvent(&"ap_deathlink_triggered", 0);
}

function deathlink_any_player_down()
{
    self endon("disconnect");

    while(true) {
        evt = self util::waittill_any_return("death", "player_downed");
        LUINotifyEvent(&"ap_deathlink_triggered", 0);
        if (evt == "player_downed")
        {
            // Make sure death doesn't double trigger
            self util::waittill_any_return("death", "player_revived");
        }
    }
}

function deathlink_any_player_death()
{
    self endon("disconnect");

    while(true) {
        self waittill("death");
        LUINotifyEvent(&"ap_deathlink_triggered", 0);
    }
}