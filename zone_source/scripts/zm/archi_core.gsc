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
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\zm\perks\archi_perk_phdflopper;

#using scripts\zm\archi_castle;
#using scripts\zm\archi_island;
#using scripts\zm\archi_stalingrad;
#using scripts\zm\archi_genesis;
#using scripts\zm\archi_zod;
#using scripts\zm\archi_factory;
#using scripts\zm\archi_theater;
#using scripts\zm\archi_moon;
#using scripts\zm\archi_tomb;
#using scripts\zm\archi_westernz;

#using scripts\zm\archi_items;
#using scripts\zm\archi_commands;
#using scripts\zm\archi_save;
#using scripts\zm\archi_shop;
#using scripts\zm\archi_magicbox;
#using scripts\zm\archi_mappings;

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
#precache( "eventstring", "ap_save_player_data" );
#precache( "eventstring", "ap_restore_player_data" );

REGISTER_SYSTEM_EX("archipelago_core", &__init__, &__main__, undefined)

function __init__()
{
    clientfield::register("world", "ap_mystery_box_changes", 1, 31, "int");
    clientfield::register("world", "ap_box_contents", 1, 3, "int");
    level flag::init("ap_prevent_checkpoints", 1);
    level flag::init("ap_attachment_rando_ready");
    level flag::init("ap_loaded_save_data");
    level flag::init("ap_universal_restored");
    level flag::init("ap_deathlink_send_active", 1);

    // Prevent oob deaths just incase
    level.player_out_of_playable_area_monitor = false;

    // Some maps make requirements harder if not in a ranked match
    level.rankedmatch = 1;
    SetDvar("zm_private_rankedmatch", 1);

    SetDvar( "MOD_VERSION", MOD_VERSION );

    // First gobblegum free each round
    SetDvar("scr_firstGumFree", 1);

    // Setup PhD
    mapName = GetDvarString( "mapname" );
    switch(mapName)
    {
        case "zm_zod":
        case "zm_westernz":
            break;
        default:
            level thread archi_perk_phdflopper::init();
            break;
    }
    
    //Message Passing Dvars
    SetDvar("ARCHIPELAGO_MAP_UNLOCK_NOTIFY", "NONE");
    SetDvar("ARCHIPELAGO_ITEM_GET", "NONE");
    SetDvar("ARCHIPELAGO_LOCATION_SEND", "NONE");
    SetDvar("ARCHIPELAGO_SAY_SEND", "NONE"); 
    SetDvar("ARCHIPELAGO_SAVE_DATA", "NONE");
    SetDvar("ARCHIPELAGO_LOAD_DATA", "NONE");
    SetDvar("ARCHIPELAGO_LOAD_DATA_SEED", "NONE");
    SetDvar("ARCHIPELAGO_LOAD_DATA_UNIVERAL", "NONE");
    SetDvar("ARCHIPELAGO_SAVE_PROGRESS", "NONE");
    SetDvar("ARCHIPELAGO_DEATHNLINK_RECIEVED", "NONE");
    SetDvar("ARCHIPELAGO_LUA_CLEAR_DATA", "");
    SetDvar("ARCHIPELAGO_CLEAR_DATA_CHECKPOINTS", "NONE");
    //Lua Log Passing Dvars
    SetDvar("ARCHIPELAGO_LOG_MESSAGE", "NONE");
    SetDvar("ARCHIPELAGO_LOAD_READY", 0);
    SetDvar("ARCHIPELAGO_SEED", "");
    settingsDone = GetDvarString("ARCHIPELAGO_SETTINGS_READY", "");
    if (settingsDone == "")
    {
        SetDvar("ARCHIPELAGO_SETTINGS_READY", "");
    }

    //Server-wide thread to print Log messages from Lua/LUI
    level thread log_from_lua();

    level flag::init("ap_dll_started");
    level flag::init("ap_loaded");

    level thread lua_init();

	callback::on_start_gametype( &wait_for_start );
	callback::on_connect( &on_player_connect );
    callback::on_connect( &patch_solo_quick_revive );
    // callback::on_connect( &force_player_spawn );
    callback::on_spawned( &watch_max_ammo );
    callback::on_spawned( &watch_carpenter );

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

    level.archi.original_func_override_wallbuy_prompt = level.func_override_wallbuy_prompt;
    level.archi.func_override_wallbuy_prompt = &func_override_wallbuy_prompt;
}

function on_archi_connect_settings()
{
    level.archi.perk_limit_default_modifier = GetDvarInt("ARCHIPELAGO_PERK_LIMIT_DEFAULT_MODIFIER", 0);
    level.archi.map_specific_machines = GetDvarInt("ARCHIPELAGO_MAP_SPECIFIC_MACHINES", 0);
    level.archi.mystery_box_special_items = GetDvarInt("ARCHIPELAGO_MYSTERY_BOX_SPECIAL", 0);
    level.archi.mystery_box_regular_items = GetDvarInt("ARCHIPELAGO_MYSTERY_BOX_REGULAR", 0);
    level.archi.mystery_box_expanded = GetDvarInt("ARCHIPELAGO_MYSTERY_BOX_EXPANDED", 0);
    level.archi.difficulty_rng_moon_digger = GetDvarInt("ARCHIPELAGO_DIFFICULTY_RNG_MOON_DIGGER", 0);
    level.archi.difficulty_rng_moon_box = GetDvarInt("ARCHIPELAGO_DIFFICULTY_RNG_MOON_BOX", 0);
    level.archi.difficulty_gorod_egg_cooldown = GetDvarInt("ARCHIPELAGO_DIFFICULTY_GOROD_EGG_COOLDOWN", 0);
    level.archi.difficulty_gorod_dragon_wings = GetDvarInt("ARCHIPELAGO_DIFFICULTY_GOROD_DRAGON_WINGS", 0);
    level.archi.difficulty_ee_checkpoints = GetDvarInt("ARCHIPELAGO_DIFFICULTY_EE_CHECKPOINTS", 0);
    level.archi.difficulty_round_checkpoints = GetDvarInt("ARCHIPELAGO_DIFFICULTY_ROUND_CHECKPOINTS", 0);
    level.archi.attachments_randomized = GetDvarInt("ARCHIPELAGO_ATTACHMENT_RANDO_ENABLED", 0);
    level.archi.attachments_sight_weight = GetDvarInt("ARCHIPELAGO_ATTACHMENT_RANDO_SIGHT_SIZE_WEIGHT", 25);
    level.archi.deathlink_enabled = GetDvarInt("ARCHIPELAGO_DEATHLINK_ENABLED", 0);
    level.archi.super_ee_reward = GetDvarInt("ARCHIPELAGO_SUPER_EE_REWARD", 0);
    clientDeathlink = GetDvarInt("ARCHIPELAGO_CLIENT_DEATHLINK", 0);
    if (level.archi.deathlink_enabled == 1 && clientDeathlink == 0)
    {
        level.archi.deathlink_enabled = 0;
    }
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
    // Hold server-wide Archipelago Information
    level.archi = SpawnStruct();

    on_archi_connect_settings();

    //Collection of Locations that are checked, 
    level.archi.locationQueue = array();

    level.archi.blocked_powerups = [];
    level.archi.notifysave = [];
    level.archi.shops = [];
    level.archi.monitor_strings = [];
    level.archi.save_checkpoint = false;
    level.archi.save_zombie_count = true;
    level.archi.opened_doors = [];
    level.archi.opened_debris = [];
    level.archi.excluded_craftable_items = [];
    level.archi.ap_box_keys = [];
    level.archi.ap_box_states = [];
    level flag::init("ap_map_locked");
    level.archi.map_key_item = undefined;

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

    modded_floating_debris = GetEntArray("floating_debris", "targetname");
    for (i = 0; i < modded_floating_debris.size; i++)
    {
        modded_floating_debris[i].id = i;
    }
    level thread track_modded_floating_debris_open();

    // Get Map Name String
    mapName = GetDvarString( "mapname" );

    level.archi._mapName = mapName;

    // Setup mystery box
    archi_mappings::init_weapon_item_names();
    level.archi.ap_weapon_bits = archi_items::get_box_bit_table(mapName, level.archi.mystery_box_regular_items, level.archi.mystery_box_special_items, level.archi.mystery_box_expanded);
    box_settings_bits = 0;
    if (level.archi.mystery_box_regular_items)
    {
        box_settings_bits |= 1;
    }
    if (level.archi.mystery_box_special_items)
    {
        box_settings_bits |= 2;
    }
    if (level.archi.mystery_box_expanded)
    {
        box_settings_bits |= 4;
    }
    level clientfield::set("ap_box_contents", box_settings_bits);

    level.archi.wallbuy_mappings = [];
    level.archi.wallbuys = [];
    level.archi.craftable_piece_to_location = [];
    level.archi.check_override_wallbuy_purchase = &check_override_wallbuy_purchase;
    level.archi.boarded_windows = 0;

    level.archi.progressive_starting_points = 0;
    level.archi.perk_tokens = 0;
    level.archi.gum_tokens = 0;
    level.archi.rare_gum_tokens = 0;
    level.archi.legendary_gum_tokens = 0;
    level.archi.checkpoint_tokens = 1;
    level.archi.spent_checkpoint_tokens = -1;

    // Map State
    level.archi.progressive_perk_limit = 0;
    level.archi.craftable_parts = [];

    archi_items::RegisterUniversalItem("200 Points",&archi_items::give_200Points);
    archi_items::RegisterUniversalItem("1500 Points",&archi_items::give_1500Points);
    archi_items::RegisterUniversalItem("50000 Points",&archi_items::give_50000Points);

    archi_items::RegisterUniversalItem("Progressive - 500 Starting Points",&archi_items::give_ProgressiveStartingPoints500);
    archi_items::RegisterUniversalItem("Shop - Perk Token",&archi_items::give_PerkToken);
    archi_items::RegisterUniversalItem("Shop - Mega Gobblegum Token",&archi_items::give_GumToken);
    archi_items::RegisterUniversalItem("Shop - Rare Mega Gobblegum Token",&archi_items::give_RareGumToken);
    archi_items::RegisterUniversalItem("Shop - Legendary Mega Gobblegum Token",&archi_items::give_LegendaryGumToken);
    archi_items::RegisterUniversalItem("Shop - Checkpoint Token",&archi_items::give_CheckpointToken);

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
    archi_items::RegisterUniversalItem("Progressive - Pack-A-Punch Machine",&archi_items::give_ProgressivePap);
    archi_items::RegisterUniversalItem("Progressive - Perk Limit Increase",&archi_items::give_ProgressivePerkLimit);

    archi_commands::init_commands();
    level thread round_end_noti();
    level thread repaired_board_noti();
    level thread stats_checks_monitor();

    archi_magicbox::init();

    if (mapName == "zm_zod")
    {
        level.archi.mapString = ARCHIPELAGO_MAP_SHADOWS_OF_EVIL;
        level.archi.map_key_item = "Map Unlock - Shadows of Evil";
        level.archi.sync_perk_exploders = &archi_zod::sync_perk_exploders;

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

        archi_items::RegisterMapWeapons(mapName);

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

        level thread archi_zod::setup_locations();

        level thread setup_spare_change_trackers(7);

        spawn_shop((2267, -5513, 128), (0, 90, 0));

        level.archi.save_state_manager = &archi_zod::save_state_manager;
        level.archi.save_player_data = &archi_zod::save_player_data;
        level.archi.load_state_manager = &archi_zod::load_state;
        level.archi.restore_player_data = &archi_zod::restore_player_data;
    }

    if (mapName == "zm_castle")
    {
        level.archi.mapString = ARCHIPELAGO_MAP_CASTLE;
        level.archi.map_key_item = "Map Unlock - Der Eisendrache"; 
        level.archi.sync_perk_exploders = &archi_castle::sync_perk_exploders;

        // Replace craftable logic with AP locations
        replace_craftable_onPickup("craft_shield_zm");
        level.archi.craftable_piece_to_location["craft_shield_zm_dolly"] = level.archi.mapString + " Shield Part Pickup - Dolly";
        level.archi.craftable_piece_to_location["craft_shield_zm_door"] = level.archi.mapString + " Shield Part Pickup - Door";
        level.archi.craftable_piece_to_location["craft_shield_zm_clamp"] = level.archi.mapString + " Shield Part Pickup - Clamp";

        replace_craftable_onPickup("gravityspike");
        level.archi.craftable_piece_to_location["gravityspike_part_body"] = level.archi.mapString + " Ragnarok DG-4 Part Pickup - Body";
        level.archi.craftable_piece_to_location["gravityspike_part_guards"] = level.archi.mapString + " Ragnarok DG-4 Part Pickup - Guards";
        level.archi.craftable_piece_to_location["gravityspike_part_handle"] = level.archi.mapString + " Ragnarok DG-4 Part Pickup - Handle";

        archi_items::RegisterMapWeapons(mapName);

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
        archi_items::RegisterPerk("Electric Cherry",&archi_items::give_ElectricCherry,PERK_ELECTRIC_CHERRY);
        archi_items::RegisterPerk("Widow's Wine",&archi_items::give_WidowsWine,PERK_WIDOWS_WINE);
        archi_items::RegisterPerk("PhD Flopper",&archi_items::give_PhDFlopper,PERK_PHDFLOPPER);

        level.custom_random_perk_weights = &unweighted_random_perks;
    
        spawn_shop((895, 684, -48), (0, -170, 0));

        level.archi.save_state_manager = &archi_castle::save_state_manager;
        level.archi.save_player_data = &archi_castle::save_player_data;
        level.archi.load_state_manager = &archi_castle::load_state;
        level.archi.restore_player_data = &archi_castle::restore_player_data;
    }

    if (mapName == "zm_island")
    {
        level.archi.mapString = ARCHIPELAGO_MAP_ZETSUBOU;
        level.archi.map_key_item = "Map Unlock - Zetsubou No Shima";
        level.archi.sync_perk_exploders = &archi_island::sync_perk_exploders;

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

        archi_items::RegisterMapWeapons(mapName);

        archi_items::RegisterItem("Shield Part - Door",&archi_items::give_ShieldPart_Door,undefined,true);
        archi_items::RegisterItem("Shield Part - Dolly",&archi_items::give_ShieldPart_Dolly,undefined,true);
        archi_items::RegisterItem("Shield Part - Clamp",&archi_items::give_ShieldPart_Clamp,undefined,true);

        archi_island::setup_main_quest();
        archi_island::setup_main_ee_quest();
        archi_island::setup_weapon_quests();
        archi_island::setup_challenges();
        foreach (player in level.players)
        {
            player thread archi_island::adjust_bgb_pack();
        }
        callback::on_spawned(&archi_island::adjust_bgb_pack);
        archi_island::setup_side_ee();

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

        spawn_shop((-411, -2048, -426), (0, 6, 0));

        level.archi.save_state_manager = &archi_island::save_state_manager;
        level.archi.save_player_data = &archi_island::save_player_data;
        level.archi.load_state_manager = &archi_island::load_state;
        level.archi.restore_player_data = &archi_island::restore_player_data;
    }

    if (mapName == "zm_stalingrad")
    {
        level.archi.mapString = ARCHIPELAGO_MAP_GOROD_KROVI;
        level.archi.map_key_item = "Map Unlock - Gorod Krovi";

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

        archi_items::RegisterMapWeapons(mapName);

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
        archi_items::RegisterPerk("Electric Cherry",&archi_items::give_ElectricCherry,PERK_ELECTRIC_CHERRY);
        archi_items::RegisterPerk("Widow's Wine",&archi_items::give_WidowsWine,PERK_WIDOWS_WINE);
        archi_items::RegisterPerk("PhD Flopper",&archi_items::give_PhDFlopper,PERK_PHDFLOPPER);

        level.custom_random_perk_weights = &unweighted_random_perks;

        spawn_shop((-174, 1903, 176), (0, -138, 0));

        level.archi.save_state_manager = &archi_stalingrad::save_state_manager;
        level.archi.save_player_data = &archi_stalingrad::save_player_data;
        level.archi.load_state_manager = &archi_stalingrad::load_state;
        level.archi.restore_player_data = &archi_stalingrad::restore_player_data;
    }

    if (mapName == "zm_genesis")
    {
        level.archi.mapString = ARCHIPELAGO_MAP_REVELATIONS;
        level.archi.map_key_item = "Map Unlock - Revelations";

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

        archi_items::RegisterMapWeapons(mapName);

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
        archi_items::RegisterPerk("Electric Cherry",&archi_items::give_ElectricCherry,PERK_ELECTRIC_CHERRY);
        archi_items::RegisterPerk("PhD Flopper",&archi_items::give_PhDFlopper,PERK_PHDFLOPPER);

        level.custom_random_perk_weights = &unweighted_random_perks;

        spawn_shop((-4757, -264, -448), (0, 87, 0));

        level.archi.save_state_manager = &archi_genesis::save_state_manager;
        level.archi.save_player_data = &archi_genesis::save_player_data;
        level.archi.load_state_manager = &archi_genesis::load_state;
        level.archi.restore_player_data = &archi_genesis::restore_player_data;
    }

    if (mapName == "zm_factory")
    {
        level.archi.mapString = ARCHIPELAGO_MAP_THE_GIANT;
        level.archi.map_key_item = "Map Unlock - The Giant";

        // 7 possible machines, 6 will spawn, 1 is behind a quest
        level thread setup_spare_change_trackers(5);

        archi_factory::setup_locations();
        
        archi_items::RegisterMapWeapons(mapName);

        // Register Possible Global Items - Item name, callback, clientfield
        archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
        archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
        archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
        archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
        archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);

        spawn_shop((-254, 608, 7), (0, -90, 0));

        level.archi.save_state_manager = &archi_factory::save_state_manager;
        level.archi.save_player_data = &archi_factory::save_player_data;
        level.archi.load_state_manager = &archi_factory::load_state;
        level.archi.restore_player_data = &archi_factory::restore_player_data;
    }

    // === Zombie Chronicles ===

    if (mapName == "zm_theater")
    {
        level.archi.mapString = ARCHIPELAGO_MAP_KINO_DER_TOTEN;
        level.archi.map_key_item = "Map Unlock - Kino der Toten";

        level thread setup_spare_change_trackers(5);
        
        archi_theater::setup_locations();

        archi_items::RegisterMapWeapons(mapName);

        // Machines
        archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
        archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
        archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
        archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
        archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);

        // Wunderfizz
        archi_items::RegisterPerk("Widow's Wine",&archi_items::give_WidowsWine,PERK_WIDOWS_WINE);
        archi_items::RegisterPerk("Deadshot Daiquiri",&archi_items::give_DeadShot,PERK_DEAD_SHOT);
        archi_items::RegisterPerk("Stamin-up",&archi_items::give_StaminUp,PERK_STAMINUP);
        archi_items::RegisterPerk("PhD Flopper",&archi_items::give_PhDFlopper,PERK_PHDFLOPPER);

        spawn_shop((-184, -840, 80), (0, 0, 0));

        level.archi.save_state_manager = &archi_theater::save_state_manager;
        level.archi.save_player_data = &archi_theater::save_player_data;
        level.archi.load_state_manager = &archi_theater::load_state;
        level.archi.restore_player_data = &archi_theater::restore_player_data;
    }

    if (mapName == "zm_moon")
    {
        level.archi.mapString = ARCHIPELAGO_MAP_MOON;
        level.archi.map_key_item = "Map Unlock - Moon";

        archi_moon::setup_locations();

        level thread setup_spare_change_trackers(8);

        archi_items::RegisterMapWeapons(mapName);

        archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
        archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
        archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
        archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
        archi_items::RegisterPerk("Dead Shot",&archi_items::give_DeadShot,PERK_DEAD_SHOT);
        archi_items::RegisterPerk("Stamin-up",&archi_items::give_StaminUp,PERK_STAMINUP);
        archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);
        archi_items::RegisterPerk("Widow's Wine",&archi_items::give_WidowsWine,PERK_WIDOWS_WINE);
        archi_items::RegisterPerk("PhD Flopper",&archi_items::give_PhDFlopper,PERK_PHDFLOPPER);

        spawn_shop((411.4, -74.6, -2), (0, -180, 0));

        level.archi.save_state_manager = &archi_moon::save_state_manager;
        level.archi.save_player_data = &archi_moon::save_player_data;
        level.archi.load_state_manager = &archi_moon::load_state;
        level.archi.restore_player_data = &archi_moon::restore_player_data;
    }

    if (mapName == "zm_tomb")
    {
        level.archi.mapString = ARCHIPELAGO_MAP_ORIGINS;
        level.archi.map_key_item = "Map Unlock - Origins";

        archi_tomb::setup_locations();

        level thread setup_spare_change_trackers(5);

        replace_craftable_onPickup("craft_shield_zm");
        level.archi.craftable_piece_to_location["craft_shield_zm_dolly"] = level.archi.mapString + " Shield Part Pickup - Dolly";
        level.archi.craftable_piece_to_location["craft_shield_zm_door"] = level.archi.mapString + " Shield Part Pickup - Door";
        level.archi.craftable_piece_to_location["craft_shield_zm_clamp"] = level.archi.mapString + " Shield Part Pickup - Clamp";

        archi_items::RegisterItem("Shield Part - Door",&archi_items::give_ShieldPart_Door,undefined,true);
        archi_items::RegisterItem("Shield Part - Dolly",&archi_items::give_ShieldPart_Dolly,undefined,true);
        archi_items::RegisterItem("Shield Part - Clamp",&archi_items::give_ShieldPart_Clamp,undefined,true);

        replace_craftable_onPickup("gramophone");
        level.archi.craftable_piece_to_location["gramophone_vinyl_player"] = level.archi.mapString + " Gramophone Part Pickup - Gramophone Player";
        level.archi.craftable_piece_to_location["gramophone_vinyl_master"] = level.archi.mapString + " Gramophone Part Pickup - Blank Disc";
        level.archi.craftable_piece_to_location["gramophone_vinyl_fire"] = level.archi.mapString + " Gramophone Part Pickup - Fire Disc";
        level.archi.craftable_piece_to_location["gramophone_vinyl_air"] = level.archi.mapString + " Gramophone Part Pickup - Wind Disc";
        level.archi.craftable_piece_to_location["gramophone_vinyl_elec"] = level.archi.mapString + " Gramophone Part Pickup - Lightning Disc";
        level.archi.craftable_piece_to_location["gramophone_vinyl_ice"] = level.archi.mapString + " Gramophone Part Pickup - Ice Disc";

        level thread gramophone_disc_pickup_watcher("vinyl_air", "air_staff.quest_state", "zmInventory.air_staff.visible");
        level thread gramophone_disc_pickup_watcher("vinyl_ice", "water_staff.quest_state", "zmInventory.water_staff.visible");
        level thread gramophone_disc_pickup_watcher("vinyl_fire", "fire_staff.quest_state", "zmInventory.fire_staff.visible");
        level thread gramophone_disc_pickup_watcher("vinyl_elec", "lightning_staff.quest_state", "zmInventory.lightning_staff.visible");

        archi_items::RegisterItem("Gramophone Part - Gramophone Player",&archi_tomb::give_GramophonePart_Player,undefined,false);
        archi_items::RegisterItem("Gramophone Part - Blank Disc",&archi_tomb::give_GramophonePart_BlankDisc,undefined,false);
        archi_items::RegisterItem("Gramophone Part - Fire Disc",&archi_tomb::give_GramophonePart_FireDisc,undefined,false);
        archi_items::RegisterItem("Gramophone Part - Wind Disc",&archi_tomb::give_GramophonePart_WindDisc,undefined,false);
        archi_items::RegisterItem("Gramophone Part - Lightning Disc",&archi_tomb::give_GramophonePart_LightningDisc,undefined,false);
        archi_items::RegisterItem("Gramophone Part - Ice Disc",&archi_tomb::give_GramophonePart_IceDisc,undefined,false);

        level.archi.excluded_craftable_items["gramophone_vinyl_player"] = 1;
        level.archi.excluded_craftable_items["gramophone_vinyl_master"] = 1;

        replace_craftable_onPickup("equip_dieseldrone");
        level.archi.craftable_piece_to_location["equip_dieseldrone_body"] = level.archi.mapString + " Maxis Drone Part Pickup - Body";
        level.archi.craftable_piece_to_location["equip_dieseldrone_brain"] = level.archi.mapString + " Maxis Drone Part Pickup - Brain";
        level.archi.craftable_piece_to_location["equip_dieseldrone_engine"] = level.archi.mapString + " Maxis Drone Part Pickup - Valve";

        archi_items::RegisterItem("Maxis Drone Part - Body",&archi_tomb::give_MaxisDronePart_Body,undefined,false);
        archi_items::RegisterItem("Maxis Drone Part - Brain",&archi_tomb::give_MaxisDronePart_Brain,undefined,false);
        archi_items::RegisterItem("Maxis Drone Part - Valve",&archi_tomb::give_MaxisDronePart_Engine,undefined,false);

        replace_craftable_onPickup("elemental_staff_water");
        replace_craftable_onPickup("elemental_staff_fire");
        replace_craftable_onPickup("elemental_staff_lightning");
        replace_craftable_onPickup("elemental_staff_air");

        archi_items::RegisterItem("Ice Staff Part - Gem", &archi_tomb::give_ElementalStaffPart_Ice_Gem, undefined, false);
        archi_items::RegisterItem("Ice Staff Part - Upper Staff", &archi_tomb::give_ElementalStaffPart_Ice_UpperStaff, undefined, false);
        archi_items::RegisterItem("Ice Staff Part - Middle Staff", &archi_tomb::give_ElementalStaffPart_Ice_MiddleStaff, undefined, false);
        archi_items::RegisterItem("Ice Staff Part - Lower Staff", &archi_tomb::give_ElementalStaffPart_Ice_LowerStaff, undefined, false);

        archi_items::RegisterItem("Fire Staff Part - Gem", &archi_tomb::give_ElementalStaffPart_Fire_Gem, undefined, false);
        archi_items::RegisterItem("Fire Staff Part - Upper Staff", &archi_tomb::give_ElementalStaffPart_Fire_UpperStaff, undefined, false);
        archi_items::RegisterItem("Fire Staff Part - Middle Staff", &archi_tomb::give_ElementalStaffPart_Fire_MiddleStaff, undefined, false);
        archi_items::RegisterItem("Fire Staff Part - Lower Staff", &archi_tomb::give_ElementalStaffPart_Fire_LowerStaff, undefined, false);

        archi_items::RegisterItem("Wind Staff Part - Gem", &archi_tomb::give_ElementalStaffPart_Air_Gem, undefined, false);
        archi_items::RegisterItem("Wind Staff Part - Upper Staff", &archi_tomb::give_ElementalStaffPart_Air_UpperStaff, undefined, false);
        archi_items::RegisterItem("Wind Staff Part - Middle Staff", &archi_tomb::give_ElementalStaffPart_Air_MiddleStaff, undefined, false);
        archi_items::RegisterItem("Wind Staff Part - Lower Staff", &archi_tomb::give_ElementalStaffPart_Air_LowerStaff, undefined, false);

        archi_items::RegisterItem("Lightning Staff Part - Gem", &archi_tomb::give_ElementalStaffPart_Lightning_Gem, undefined, false);
        archi_items::RegisterItem("Lightning Staff Part - Upper Staff", &archi_tomb::give_ElementalStaffPart_Lightning_UpperStaff, undefined, false);
        archi_items::RegisterItem("Lightning Staff Part - Middle Staff", &archi_tomb::give_ElementalStaffPart_Lightning_MiddleStaff, undefined, false);
        archi_items::RegisterItem("Lightning Staff Part - Lower Staff", &archi_tomb::give_ElementalStaffPart_Lightning_LowerStaff, undefined, false);

        level.archi.excluded_craftable_items["elemental_staff_water_gem"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_water_upper_staff"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_water_middle_staff"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_water_lower_staff"] = 1;

        level.archi.excluded_craftable_items["elemental_staff_water_gem"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_water_upper_staff"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_water_middle_staff"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_water_lower_staff"] = 1;

        level.archi.excluded_craftable_items["elemental_staff_fire_gem"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_fire_upper_staff"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_fire_middle_staff"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_fire_lower_staff"] = 1;

        level.archi.excluded_craftable_items["elemental_staff_air_gem"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_air_upper_staff"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_air_middle_staff"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_air_lower_staff"] = 1;

        level.archi.excluded_craftable_items["elemental_staff_lightning_gem"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_lightning_upper_staff"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_lightning_middle_staff"] = 1;
        level.archi.excluded_craftable_items["elemental_staff_lightning_lower_staff"] = 1;

        archi_items::RegisterMapWeapons(mapName);

        archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
        archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
        archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
        archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
        archi_items::RegisterPerk("Dead Shot",&archi_items::give_DeadShot,PERK_DEAD_SHOT);
        archi_items::RegisterPerk("Stamin-up",&archi_items::give_StaminUp,PERK_STAMINUP);
        archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);
        archi_items::RegisterPerk("Widow's Wine",&archi_items::give_WidowsWine,PERK_WIDOWS_WINE);
        archi_items::RegisterPerk("Electric Cherry",&archi_items::give_ElectricCherry,PERK_ELECTRIC_CHERRY);
        archi_items::RegisterPerk("PhD Flopper",&archi_items::give_PhDFlopper,PERK_PHDFLOPPER);

        level.custom_random_perk_weights = &unweighted_random_perks;

        spawn_shop((2568.4, 4279.6, -328), (0, 90, 0));

        level.archi.save_state_manager = &archi_tomb::save_state_manager;
        level.archi.save_player_data = &archi_tomb::save_player_data;
        level.archi.load_state_manager = &archi_tomb::load_state;
        level.archi.restore_player_data = &archi_tomb::restore_player_data;
    }

    // === Modded Maps ===
    
    if (mapName == "zm_westernz")
    {
        level.archi.mapString = ARCHIPELAGO_MAP_WANTED;
        level.archi.map_key_item = "Map Unlock - Wanted";

        // 7 possible machines, 6 will spawn
        level thread setup_spare_change_trackers(8);

        replace_craftable_onPickup("craft_westernshield");
        level.archi.craftable_piece_to_location["craft_westernshield_part_0"] = level.archi.mapString + " Shield Part Pickup - Dolly";
        level.archi.craftable_piece_to_location["craft_westernshield_part_1"] = level.archi.mapString + " Shield Part Pickup - Door";
        level.archi.craftable_piece_to_location["craft_westernshield_part_2"] = level.archi.mapString + " Shield Part Pickup - Clamp";

        replace_craftable_onPickup("craft_blundersplat_zm");
        level.archi.craftable_piece_to_location["craft_blundersplat_zm_part_3"] = level.archi.mapString + " Acidgat Upgrade Part Pickup - Engine";
        level.archi.craftable_piece_to_location["craft_blundersplat_zm_part_4"] = level.archi.mapString + " Acidgat Upgrade Part Pickup - Acid";

        archi_items::RegisterItem("Shield Part - Door",&archi_westernz::give_ShieldPart_Door,undefined,true);
        archi_items::RegisterItem("Shield Part - Dolly",&archi_westernz::give_ShieldPart_Dolly,undefined,true);
        archi_items::RegisterItem("Shield Part - Clamp",&archi_westernz::give_ShieldPart_Clamp,undefined,true);

        archi_items::RegisterItem("Acidgat Upgrade Part - Engine",&archi_westernz::give_BlundergatPart_Engine,undefined,false);
        archi_items::RegisterItem("Acidgat Upgrade Part - Acid",&archi_westernz::give_BlundergatPart_Acid,undefined,false);

        archi_westernz::setup_locations();

        archi_items::RegisterMapWeapons(mapName);

        archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
        archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
        archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
        archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
        archi_items::RegisterPerk("Dead Shot",&archi_items::give_DeadShot,PERK_DEAD_SHOT);
        archi_items::RegisterPerk("Stamin-up",&archi_items::give_StaminUp,PERK_STAMINUP);
        archi_items::RegisterPerk("PhD Flopper",&archi_items::give_PhDFlopper,PERK_PHDFLOPPER);
        archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);
        archi_items::RegisterPerk("Electric Cherry",&archi_items::give_WidowsWine,PERK_ELECTRIC_CHERRY);
        archi_items::RegisterPerk("Widow's Wine",&archi_items::give_WidowsWine,PERK_WIDOWS_WINE);

        spawn_shop((1236, 1020, -3), (0, -144, 0));

        level.archi.save_state_manager = &archi_westernz::save_state_manager;
        level.archi.save_player_data = &archi_westernz::save_player_data;
        level.archi.load_state_manager = &archi_westernz::load_state;
        level.archi.restore_player_data = &archi_westernz::restore_player_data;
    }

    zm_weapons::init_chalk_locks();

    level thread map_lock();

    level thread init_attachment_rando();
    WAIT_SERVER_FRAME
    level thread archi_save::setup_map_saving();

    patch_wunderfizz();

    level thread setup_boarding_window();
    level thread setup_can_player_purchase_perk();

    //Server-wide thread to get items from the Lua/LUI
    level thread map_unlock_text();
    level thread item_get_from_lua();

    if (level.archi.deathlink_enabled == 1)
    {
        level thread deathlink_send_monitor();
        level thread deathlink_recv_monitor();
    }
    level thread cleared_restart_ready_montior();

    update_box_clientfield();

    //Setup default map changes
    default_map_changes();

    level thread archi_save::state_other_monitor();
}

function setup_can_player_purchase_perk()
{
    level flag::wait_till("initial_blackscreen_passed");

	if(isdefined(level.get_player_perk_purchase_limit))
    {
        level.archi.original_get_player_perk_purchase_limit = level.get_player_purchase_limit;
    }
    level.get_player_perk_purchase_limit = &get_player_perk_purchase_limit;
}

function get_player_perk_purchase_limit()
{
    // Run levels original perk limit check first
    purchase_limit = level.perk_purchase_limit;
    //IPrintLn("Basic limit - " + purchase_limit);
    if (isdefined(level.archi.original_get_player_perk_purchase_limit))
    {
        purchase_limit = self [[ level.archi.original_get_player_perk_purchase_limit ]]();
    }
    //IPrintLn("Limit after map - " + purchase_limit);
    // Add ours on top of the maps original perk limit
    purchase_limit += level.archi.perk_limit_default_modifier;
    purchase_limit += level.archi.progressive_perk_limit;
    //IPrintLn("True perk limit - " + purchase_limit);
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

function send_location(loc_str)
{
    level notify("ap_location_found", loc_str);
    array::add(level.archi.locationQueue, loc_str);
}

function round_end_noti()
{
    level endon("end_game");
	level endon("end_round_think");
    last_round = 0;
    while (true)
    {
        level waittill("between_round_over");

        if (level.round_number == 1)
        {
            continue;
        }
        if (last_round >= level.round_number)
        {
            continue;
        }
        last_round = level.round_number;
        loc_str = level.archi.mapString + " Round ";
        if (last_round < 10)
        {
            loc_str += "0" + last_round;
        }
        else
        {
            loc_str += last_round;
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
    level endon("end_game");
	level endon("end_round_think");
    level flag::wait_till( "initial_blackscreen_passed" );
    wait 5; // Wait for log to clear on game startup

    while(true)
    {
        item = GetDvarString("ARCHIPELAGO_ITEM_GET");
        if ( item != "NONE" )
        {
            SetDvar("ARCHIPELAGO_ITEM_GET","NONE");
            items = StrTok(item, ";");
            foreach(item_str in items)
            {
                award_item(item_str);
                WAIT_SERVER_FRAME
            }   
        }
        wait (0.2);
    }
}

function map_unlock_text()
{
    level endon("end_game");

    while(true)
    {
        dvar_value = GetDvarString("ARCHIPELAGO_MAP_UNLOCK_NOTIFY", "NONE");
        if (dvar_value != "NONE")
        {
            IPrintLnBold("Map Unlocked - " + dvar_value);
            SetDvar("ARCHIPELAGO_MAP_UNLOCK_NOTIFY", "NONE");
        }
        wait(1);
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
            if (ap_item.type == "weapon" && isdefined(ap_item.weapon_name))
            {
                weapon_name = ap_item.weapon_name;
                // Enable wallbuy
                if (isdefined(level.archi.wallbuys))
                {
                    level.archi.wallbuys[ap_item.weapon_name] = true;
                    zm_weapons::remove_chalk_lock(ap_item.weapon_name);
                }

                // If it's a box weapon (has a bit), add to box
                if (isdefined(level.archi.ap_weapon_bits[ap_item.weapon_name]))
                {
                    weapon = GetWeapon(weapon_name);
                    z_weapon = level.zombie_weapons[weapon];
                    if (isdefined(z_weapon))
                    {
                        z_weapon.is_in_box = 1;
                        level.archi.ap_box_states[weapon_name] = 1;
                    }
                    // Update clientfield state
                    update_box_clientfield();
                }
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
    level endon("end_game");
	level endon("end_round_think");
    level waittill( "initial_blackscreen_passed" );

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
    self endon( "disconnect" );
    level flag::wait_till( "initial_blackscreen_passed" );
    //TODO tune this wait till it feels good vs archipelago log messages
    wait 3;
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
    level endon("end_game");

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

function get_alive_player()
{
    foreach (player in level.players)
    {
        if (zm_utility::is_player_valid(player))
        {
            return player;
        }
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
    level endon("end_game");

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
    level endon("end_game");

    self waittill("kill_debris_prompt_thread");
    level.archi.opened_debris[level.archi.opened_debris.size] = self.id;
}

function track_modded_floating_debris_open()
{
    level endon("end_game");

    while (true)
    {
        level waittill("ap_modded_floating_debris_opened", id);
        level.archi.opened_modded_floating_debris[level.archi.opened_modded_floating_debris.size] = id;
    }
}

// self is something pap related
function custom_pap_validation(player)
{
    item = level.archi.items["Progressive - Pack-A-Punch Machine"];
    if (item.count == 0)
    {
        return false;
    }

	current_weapon = player GetCurrentWeapon();
    weapon_supports_aat = zm_weapons::weapon_supports_aat( current_weapon );
    if (item.count < 2 && weapon_supports_aat)
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
    apItem = level.archi.wallbuy_mappings[weapon.name];
    wallbuy = level.archi.wallbuys[weapon.name];
    if (!isdefined(apItem) || IS_TRUE(wallbuy)) 
    {
        return true;
    } 
    else
    {
        hint_string = "'" + apItem + "' is required";
        self SetHintString(hint_string);
        return false;
    }
    return true;
}

// self is player
function check_override_wallbuy_purchase(weapon, weapon_spawn)
{
    apItem = level.archi.wallbuy_mappings[weapon.name];
    wallbuy = level.archi.wallbuys[weapon.name];
    if (!isdefined(apItem) || IS_TRUE(wallbuy)) 
    {
        return false;
    }
    return true;
}

function update_box_clientfield()
{
    available_items = 0;
    weapon_names = GetArrayKeys(level.archi.ap_weapon_bits);
    foreach (weapon_name in weapon_names)
    {
        bit_index = level.archi.ap_weapon_bits[weapon_name];
        if (bit_index <= 30 && level.archi.ap_box_states[weapon_name] == 1)
        {
            available_items |= (1 << bit_index);
        }
    }
    level clientfield::set("ap_mystery_box_changes", available_items);
}

function patch_wunderfizz()
{
    level._random_zombie_perk_cost = 2000;
    // Store original perk list
    level.archi.original_random_perk_list = [];
    if (isdefined(level._random_perk_machine_perk_list))
    {
        foreach (perk in level._random_perk_machine_perk_list)
        {
            level.archi.original_random_perk_list[level.archi.original_random_perk_list.size] = perk;
        }

        // Add monitor to update wunderfizz when contents changes
        level thread update_wunderfizz();
        WAIT_SERVER_FRAME
        level notify("ap_update_wunderfizz");
    }
    level.archi.wunderfizz_patched = true;

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

    foreach (weapon in GetArrayKeys(level.zombie_weapons))
    {
        base_weapon = zm_weapons::get_base_weapon( weapon.rootweapon );
        camo_index = GetDvarInt("ARCHIPELAGO_CAMO_RANDO_" + ToUpper(base_weapon.name), -1);
        if (camo_index != -1)
        {
            level.zombie_weapons[weapon].ap_camo = camo_index;
        }
        pap_camo_index = GetDvarInt("ARCHIPELAGO_CAMO_RANDO_" + ToUpper(base_weapon.name) + "_UPGRADED", -1);
        if (pap_camo_index != -1)
        {
            level.zombie_weapons[weapon].ap_pap_camo = pap_camo_index;
        }
    }

    foreach (weapon in GetArrayKeys(level.zombie_weapons))
    {
        base_weapon = zm_weapons::get_base_weapon( weapon.rootweapon );
        reticle = GetDvarInt("ARCHIPELAGO_RETICLE_RANDO_" + ToUpper(base_weapon.name), -1);
        if (reticle != -1)
        {
            level.zombie_weapons[weapon].ap_reticle = reticle;
        }
        pap_reticle = GetDvarInt("ARCHIPELAGO_RETICLE_RANDO_" + ToUpper(base_weapon.name) + "_UPGRADED", -1);
        if (pap_reticle != -1)
        {
            level.zombie_weapons[weapon].ap_pap_reticle = pap_reticle;
        }
    }

    level flag::set("ap_attachment_rando_ready");
}

function timed_enable_deathlink_send()
{
    wait(3);
    level flag::set("ap_deathlink_send_active");
}

function deathlink_recv_monitor()
{
    level endon("end_game");

    while(true)
    {
        dvar_value = GetDvarString("ARCHIPELAGO_DEATHNLINK_RECIEVED", "NONE");
        if (dvar_value != "NONE")
        {   
            level flag::clear("ap_deathlink_send_active");
            level thread timed_enable_deathlink_send();
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
                    if (isdefined(player.sessionstate) && player.sessionstate != "spectator")
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

    level waittill("end_game");
    if (isdefined(level.host_ended_game) && level.host_ended_game == 1) {
        return;
    }
    // Check if game ended from a player disconnecting while all others players are on the ground, they'll all be in last stand
    foreach (player in level.players)
    {
        if (!(isdefined(player.sessionstate) && player.sessionstate != "spectator") && !player laststand::player_is_in_laststand())
        {
            return;
        }
    }


    send_deathlink();
}

function cleared_restart_ready_montior()
{
    level endon("end_game");

    while(true)
    {
        wait(0.5);

        dvar_value = GetDvarString("ARCHIPELAGO_LUA_CLEAR_DATA", "");
        if (isdefined(dvar_value) && dvar_value != "")
        {
            IPrintLn("Clearing save data...");
            SetDvar("ARCHIPELAGO_LUA_CLEAR_DATA", "");
            mapName = GetDvarString( "mapname" );
            SetDvar("ARCHIPELAGO_CLEAR_DATA", mapName);
            SetDvar("ARCHIPELAGO_CLEAR_DATA_CHECKPOINTS", "true");
            LUINotifyEvent(&"ap_clear_data", 0);
            while(true)
            {
                dvar_res = GetDvarString("ARCHIPELAGO_CLEAR_DATA", "");
                if (dvar_res == "NONE")
                {
                    break;
                }
                wait(0.2);
            }
            level notify("end_game");
        }
    }
}

function send_deathlink()
{
    if (level flag::get("ap_deathlink_send_active"))
    {
        LUINotifyEvent(&"ap_deathlink_triggered", 0);
    }
}

function deathlink_any_player_down()
{
    self endon("disconnect");

    while(true) {
        evt = self util::waittill_any_return("death", "player_downed");
        send_deathlink();
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
        send_deathlink();
    }
}

function give_Map_Unlock()
{
    level flag::clear("ap_map_locked");

}

function map_lock()
{
    level flag::clear("spawn_zombies");

    level flag::wait_till("ap_universal_restored");

    if (isdefined(level.archi.map_key_item))
    {
        archi_items::RegisterUniversalItem(level.archi.map_key_item,&give_Map_Unlock);
        dvar_value = GetDvarString("ARCHIPELAGO_INIT_MAP_ITEMS", "");
        if (dvar_value != "")
        {
            maps = strtok(dvar_value, ";");
            foreach (map in maps)
            {
                if (map == level.archi.map_key_item)
                {
                    level flag::set("spawn_zombies");
                    return;
                }
            }
        }
        level flag::set("ap_map_locked");
        // Check if we're pre-unlocked


        // Add locks
        level thread map_lock_text();
        foreach (player in level.players)
        {
            player thread map_lock_player();
        }
        callback::on_spawned(&map_lock_player);

        // Allow spawns are unlock
        level flag::wait_till_clear("ap_map_locked");
        level flag::set("spawn_zombies");
    }
}

function map_lock_text()
{
    level endon("end_game");

    while(level flag::get("ap_map_locked")) {
        IPrintLnBold("Item Required: " + level.archi.map_key_item);
        wait(5.1);
    }
}

function map_lock_player()
{
    if (level flag::get("ap_map_locked"))
    {
        wait(3);
        self DisableWeapons();
        level flag::wait_till_clear("ap_map_locked");
        self EnableWeapons();
    }
}

function spawn_shop(origin, angles)
{
    shop = SpawnStruct();
    shop.model = "archipelago_shop";
    shop.origin = origin;
    shop.angles = angles;
    shop thread archi_shop::shop_spawn_init();
    level.archi.shops[level.archi.shops.size] = shop;
}

function watch_max_ammo()
{
	self endon("bled_out");
	self endon("spawned_player");
	self endon("disconnect");

	while(true)
    {
		self waittill("zmb_max_ammo");
		foreach(weapon in self GetWeaponsList(1))
		{
			if(isdefined(weapon.clipsize) && weapon.clipsize > 0)
			{
				self SetWeaponAmmoClip(weapon, weapon.clipsize);
			}
		}
	}
}

function watch_carpenter()
{
    self endon("bled_out");
	self endon("spawned_player");
	self endon("disconnect");

    while(true)
    {
        level waittill("carpenter_finished");

	    if(isdefined(self.hasRiotShield) && self.hasRiotShield)
        {
            self DamageRiotShield(-1500); // Reverse the damage 4head
            self clientfield::set_player_uimodel( "zmInventory.shield_health", 1.0 );
        }
    }
}

function force_player_spawn()
{
    wait(5);
    self zm::spectator_respawn_player();
}

// Gramophone disc parts have weird extra clientfields attached, outside of zm_craftables logic.
function gramophone_disc_pickup_watcher(str_piece, clientfield_str, inv_key)
{
    craftablestub = level.zombie_include_craftables["gramophone"];
    foreach (piecestub in craftablestub.a_piecestubs)
    {
        if (piecestub.piecename == str_piece)
        {
            piecestub.piecespawn = zm_craftables::get_craftable_piece("gramophone", piecestub.pieceName);
            fullName = piecestub.craftableName + "_" + piecestub.pieceName;
            piecestub.piecespawn waittill("pickup");
            wait(0.1);
            if (!isdefined(level.archi.craftable_parts[fullName]))
            {
                level clientfield::set(clientfield_str, 0);
                // Run another watcher so the item being given later will work
                piecestub thread gramophone_replacement_watch_part_pickup(clientfield_str, 1, inv_key);
            }
            return;
        }
    }
}

function gramophone_replacement_watch_part_pickup(str_quest_clientfield, n_clientfield_val, inv_key)
{
	self.piecespawn waittill("pickup");
	level notify(((self.craftablename + "_") + self.piecename) + "_picked_up");
	if(isdefined(str_quest_clientfield) && isdefined(n_clientfield_val))
	{
		level clientfield::set(str_quest_clientfield, n_clientfield_val);
	}
	if(isdefined(inv_key))
	{
		foreach(e_player in level.players)
		{
			e_player thread zm_craftables::player_show_craftable_parts_ui(undefined, inv_key, 0);
		}
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

function wrapped_craftable_onPickup( player )
{
    fullName = self.craftableName + "_" + self.pieceName;
    if ( isdefined(level.archi.map_kvals) && isdefined(level.archi.map_kvals["_craftable_" + fullName]))
    {
        level.archi.map_kvals["_craftable_" + fullName] = 1;
    }
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
    if (!(isdefined(level.archi.excluded_craftable_items) && isdefined(level.archi.excluded_craftable_items[fullName])))
    {
        self thread _remove_piece();
    }
}

function _remove_piece()
{
    id = self.craftableName + "_" + self.pieceName;
    if (!isdefined(level.archi.craftable_parts[id]))
    {
        WAIT_SERVER_FRAME
        self.piece_owner = undefined;
        self.in_shared_inventory = 0; // Not sure if this bit actually does anything right now
        level clientfield::set(self.piecestub.client_field_id, 0);
    }
}

function notify_trigger_with_player(stub, player, force_visibility = 0)
{
    // Get the trigger struct
    trigger = zm_unitrigger::check_and_build_trigger_from_unitrigger_stub(stub, player);

    // Make sure the trigger func is running before notifying
    if (trigger.thread_running != 1)
    {
        IPrintLn("Starting thread...");

        if (force_visibility)
        {
            original_vis = stub.prompt_and_visibility_func;
            stub.prompt_and_visibility_func = &_force_visibility;
        }
        // Assess visibility to make sure thread is running
        zm_unitrigger::assess_and_apply_visibility(trigger, stub, player, 1);
        WAIT_SERVER_FRAME
        trigger notify("trigger", player);  
        WAIT_SERVER_FRAME

        if (force_visibility)
        {
            stub.prompt_and_visibility_func = original_vis;
        }
        // Player has mask, this will return false and kill the thread now
        zm_unitrigger::assess_and_apply_visibility(trigger, stub, player, 1);   
    }
    else
    {
        trigger notify("trigger", player);
    }
}

function _force_visibility()
{
    return true;
}

// If you're using ap_shop_print, add (0, +90, 0) to the angles first
function spawn_perk_machine(machine, origin, angles, swap_machine)
{
    // Phd is backwards compared to other machines for some reason
    if (machine == PERK_PHDFLOPPER && !isdefined(swap_machine))
    {
        angles += (0, 180, 0);
    }

    zm_perks::perk_machine_spawn_init_late(machine, origin, angles);
    WAIT_SERVER_FRAME
    
    // Swap with Widow's Wine
    if (isdefined(swap_machine))
    {
        swap_trigger = zm_perks::get_perk_trigger(swap_machine);
        swap_angles = (swap_trigger.angles[0], swap_trigger.angles[1], swap_trigger.angles[2]);
        if (machine == PERK_PHDFLOPPER)
        {
            swap_angles += (0, 180, 0);
        }
        zm_perks::move_perk_machine(machine, swap_trigger.origin - (0, 0, 60), swap_angles);
        zm_perks::move_perk_machine(swap_machine, origin, angles);
    }
}

function stats_checks_monitor()
{
    kills_75_sent = false; // Round 6
    kills_150_sent = false; // Round 12
    kills_300_sent = false; // Round 16
    kills_500_sent = false; // Round 22
    kills_1000_sent = false; // Round 30

    headshots_25_sent = false;
    headshots_75_sent = false;
    headshots_125_sent = false;
    headshots_250_sent = false;
    headshots_400_sent = false;

    while(true)
    {
        total_kills = 0;
        total_headshots = 0;
        foreach (player in level.players)
        {
            total_kills += player.kills;
            total_headshots += player.headshots;
        }
        
        // Kill thresholds
        if (total_kills >= 75 && !kills_75_sent)
        {
            archi_core::send_location(level.archi.mapString + " " + 75 + " Kills");
            kills_75_sent = true;
        }
        if (total_kills >= 150 && !kills_150_sent)
        {
            archi_core::send_location(level.archi.mapString + " " + 150 + " Kills");
            kills_150_sent = true;
        }
        if (total_kills >= 300 && !kills_300_sent)
        {
            archi_core::send_location(level.archi.mapString + " " + 300 + " Kills");
            kills_300_sent = true;
        }
        if (total_kills >= 500 && !kills_500_sent)
        {
            archi_core::send_location(level.archi.mapString + " " + 500 + " Kills");
            kills_500_sent = true;
        }
        if (total_kills >= 1000 && !kills_1000_sent)
        {
            archi_core::send_location(level.archi.mapString + " " + 1000 + " Kills");
            kills_1000_sent = true;
        }
        
        // Headshot thresholds
        if (total_headshots >= 25 && !headshots_25_sent)
        {
            archi_core::send_location(level.archi.mapString + " " + 25 + " Headshots");
            headshots_25_sent = true;
        }
        if (total_headshots >= 75 && !headshots_75_sent)
        {
            archi_core::send_location(level.archi.mapString + " " + 75 + " Headshots");
            headshots_75_sent = true;
        }
        if (total_headshots >= 125 && !headshots_125_sent)
        {
            archi_core::send_location(level.archi.mapString + " " + 125 + " Headshots");
            headshots_125_sent = true;
        }
        if (total_headshots >= 250 && !headshots_250_sent)
        {
            archi_core::send_location(level.archi.mapString + " " + 250 + " Headshots");
            headshots_250_sent = true;
        }
        if (total_headshots >= 400 && !headshots_400_sent)
        {
            archi_core::send_location(level.archi.mapString + " " + 400 + " Headshots");
            headshots_400_sent = true;
        }
        
        wait(2);
    }
}

function unweighted_random_perks()
{
    temp_array = [];
    temp_array = array::randomize(temp_array);
    level._random_perk_machine_perk_list = array::randomize(level._random_perk_machine_perk_list);
	level._random_perk_machine_perk_list = arraycombine(level._random_perk_machine_perk_list, temp_array, 1, 0);
	keys = getarraykeys(level._random_perk_machine_perk_list);
	return keys;
}

function patch_solo_quick_revive()
{
    while(true)
    {
        self waittill("player_revived");
        level.solo_lives_given = 0;
    }
}