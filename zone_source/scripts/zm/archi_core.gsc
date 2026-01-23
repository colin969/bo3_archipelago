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
#using scripts\zm\_zm_score;

#using scripts\zm\archi_items;
#using scripts\zm\archi_commands;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#using scripts\zm\_zm_bgb_machine;

#insert scripts\zm\archi_core.gsh;

#namespace archi_core;

#precache( "eventstring", "ap_notification" );
#precache( "eventstring", "ap_ui_get" );
#precache( "eventstring", "ap_ui_send" );

REGISTER_SYSTEM_EX("archipelago_core", &__init__, &__main__, undefined)

function __init__()
{
    SetDvar( "MOD_VERSION", MOD_VERSION );
    //
    //Message Passing Dvars
    SetDvar("ARCHIPELAGO_ITEM_GET", "NONE");
    SetDvar("ARCHIPELAGO_LOCATION_SEND", "NONE");
    SetDvar("ARCHIPELAGO_SAY_SEND", "NONE");
    //Lua Log Passing Dvars
    SetDvar("ARCHIPELAGO_LOG_MESSAGE", "NONE");

	callback::on_start_gametype( &game_start );
	callback::on_connect( &on_player_connect );
	callback::on_spawned( &on_player_spawned ); 


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

    level.custom_door_buy_check = &archi_blocker_buy_check;
    level.custom_debris_buy_check = &archi_blocker_buy_check;

}

function __main__()
{
    archi_commands::init_commands();
    level thread round_start_location();
    level thread round_end_noti();
    level thread repaired_board_noti();
}

function on_archi_connect_settings()
{

    //TODO: Add some Archipelago settings, then put them in here

	
}

function init_string_mappings(mapString)
{
    if (!isdefined(level.archi.perk_strings_to_names))
    {
        level.archi.perk_strings_to_names = [];
    }

    if (!isdefined(level.archi.blocker_ids_to_names))
    {
        level.archi.blocker_ids_to_names = [];
    }

    if (!isdefined(level.archi.craftable_piece_to_location))
    {
        level.archi.craftable_piece_to_location = [];
    }

    // TODO: Settings check for disabled map specific machine strings
    level.archi.perk_strings_to_names[PERK_JUGGERNOG] = level.archi.mapString + " " + ARCHIPELAGO_ITEM_PERK_JUGGERNOG;
    level.archi.perk_strings_to_names[PERK_QUICK_REVIVE] = level.archi.mapString + " " + ARCHIPELAGO_ITEM_PERK_QUICK_REVIVE;
    level.archi.perk_strings_to_names[PERK_SLEIGHT_OF_HAND] = level.archi.mapString + " " + ARCHIPELAGO_ITEM_PERK_SLEIGHT_OF_HAND;
    level.archi.perk_strings_to_names[PERK_DOUBLETAP2] = level.archi.mapString + " " + ARCHIPELAGO_ITEM_PERK_DOUBLETAP2;
    level.archi.perk_strings_to_names[PERK_STAMINUP] = level.archi.mapString + " " + ARCHIPELAGO_ITEM_PERK_STAMINUP;
    level.archi.perk_strings_to_names[PERK_PHDFLOPPER] = level.archi.mapString + " " + ARCHIPELAGO_ITEM_PERK_PHDFLOPPER;
    level.archi.perk_strings_to_names[PERK_DEAD_SHOT] = level.archi.mapString + " " + ARCHIPELAGO_ITEM_PERK_DEAD_SHOT;
    level.archi.perk_strings_to_names[PERK_ADDITIONAL_PRIMARY_WEAPON] = level.archi.mapString + " " + ARCHIPELAGO_ITEM_PERK_ADDITIONAL_PRIMARY_WEAPON;
    level.archi.perk_strings_to_names[PERK_ELECTRIC_CHERRY] = level.archi.mapString + " " + ARCHIPELAGO_ITEM_PERK_ELECTRIC_CHERRY;
    level.archi.perk_strings_to_names[PERK_TOMBSTONE] = level.archi.mapString + " " + ARCHIPELAGO_ITEM_PERK_TOMBSTONE;
    level.archi.perk_strings_to_names[PERK_WHOSWHO] = level.archi.mapString + " " + ARCHIPELAGO_ITEM_PERK_WHOSWHO;
    level.archi.perk_strings_to_names[PERK_VULTUREAID] = level.archi.mapString + " " + ARCHIPELAGO_ITEM_PERK_VULTUREAID;
    level.archi.perk_strings_to_names[PERK_WIDOWS_WINE] = level.archi.mapString + " " + ARCHIPELAGO_ITEM_PERK_WIDOWS_WINE;
}

function game_start()
{

    //TODO Error out here if there is no connection settings

    if (!isdefined(level.archi))
    {
        // Hold server-wide Archipelago Information
        level.archi = SpawnStruct();

        // Get Map Name String
        mapName = GetDvarString( "mapname" );

        level.archi.boarded_windows = 0;

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

        // Traps
        archi_items::RegisterItem("Trap - Third Person Mode",&archi_items::give_Trap_ThirdPerson,"ap_trap_thirdperson");
        
        // Gifts
        archi_items::RegisterItem("Gift - Carpenter Powerup",&archi_items::give_Gift_CarpenterPowerup,"ap_gift_carpenter");
        archi_items::RegisterItem("Gift - Double Points Powerup",&archi_items::give_Gift_DoublePointsPowerup,"ap_gift_double_points");
        archi_items::RegisterItem("Gift - InstaKill Powerup",&archi_items::give_Gift_InstaKillPowerup,"ap_gift_instakill");
        archi_items::RegisterItem("Gift - Fire Sale Powerup",&archi_items::give_Gift_FireSalePowerup,"ap_gift_fire_sale");
        archi_items::RegisterItem("Gift - Max Ammo Powerup",&archi_items::give_Gift_MaxAmmoPowerup,"ap_gift_max_ammo");
        archi_items::RegisterItem("Gift - Nuke Powerup",&archi_items::give_Gift_NukePowerup,"ap_gift_nuke");
        archi_items::RegisterItem("Gift - Free Perk Powerup",&archi_items::give_Gift_FreePerkPowerup,"ap_gift_free_perk");

        if (mapName == "zm_castle")
        {
            level.archi.mapString = ARCHIPELAGO_MAP_CASTLE;
            init_string_mappings();

            // Replace craftable logic with AP locations
            replace_craftable_onPickup("craft_shield_zm");
            level.archi.craftable_piece_to_location["craft_shield_zm_dolly"] = level.archi.mapString + " Shield Part Pickup - Dolly";
            level.archi.craftable_piece_to_location["craft_shield_zm_door"] = level.archi.mapString + " Shield Part Pickup - Door";
            level.archi.craftable_piece_to_location["craft_shield_zm_clamp"] = level.archi.mapString + " Shield Part Pickup - Clamp";

            replace_craftable_onPickup("gravityspike");
            level.archi.craftable_piece_to_location["gravityspike_part_body"] = level.archi.mapString + " Ragnarok DG-4 Part Pickup - Body";
            level.archi.craftable_piece_to_location["gravityspike_part_guards"] = level.archi.mapString + " Ragnarok DG-4 Part Pickup - Guards";
            level.archi.craftable_piece_to_location["gravityspike_part_handle"] = level.archi.mapString + " Ragnarok DG-4 Part Pickup - Handle";

            // Register Map Unique Items - Item name, callback, clientfield
            archi_items::RegisterItem(level.archi.mapString + " Victory",&archi_items::give_Victory,undefined);

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
        
            
        }

        if (mapName == "zm_factory")
        {
            level.archi.mapString = ARCHIPELAGO_MAP_THE_GIANT;
            init_string_mappings();

            // Register Map Unique Items - Item name, callback, clientfield
            archi_items::RegisterItem(level.archi.mapString + " Victory",&archi_items::give_Victory,undefined);
            
            archi_items::RegisterItem(level.archi.mapString + " Animal Testing",&archi_items::give_The_Giant_Animal_Testing,"ap_item_region_1");
            archi_items::RegisterItem(level.archi.mapString + " Garage",&archi_items::give_The_Giant_Garage,"ap_item_region_2");
            archi_items::RegisterItem(level.archi.mapString + " Power Room",&archi_items::give_The_Giant_Power_Room,"ap_item_region_3");
            archi_items::RegisterItem(level.archi.mapString + " Teleporter 1",&archi_items::give_The_Giant_Teleporter_1,"ap_item_region_4");
            archi_items::RegisterItem(level.archi.mapString + " Teleporter 2",&archi_items::give_The_Giant_Teleporter_2,"ap_item_region_5");
            archi_items::RegisterItem(level.archi.mapString + " Teleporter 3",&archi_items::give_The_Giant_Teleporter_3,"ap_item_region_6");

            // Register Possible Global Items - Item name, callback, clientfield
            archi_items::RegisterPerk("Juggernog",&archi_items::give_Juggernog,PERK_JUGGERNOG);
            archi_items::RegisterPerk("Quick Revive",&archi_items::give_QuickRevive,PERK_QUICK_REVIVE);
            archi_items::RegisterPerk("Speed Cola",&archi_items::give_SpeedCola,PERK_SLEIGHT_OF_HAND);
            archi_items::RegisterPerk("Double Tap",&archi_items::give_DoubleTap,PERK_DOUBLETAP2);
            archi_items::RegisterPerk("Mule Kick",&archi_items::give_MuleKick,PERK_ADDITIONAL_PRIMARY_WEAPON);

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
            
            //Lock Blockers
            level.archi.blockers[5] = false;
            level.archi.blockers[6] = false;
            level.archi.blockers[4] = false;
            level.archi.blockers[11] = false;
            level.archi.blockers[10] = false;
            level.archi.blockers[7] = false;
            level.archi.blockers[0] = false;

            level.archi.blocker_ids_to_names[5] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_ANIMAL_TESTING; 
            level.archi.blocker_ids_to_names[4] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_GARAGE;
            level.archi.blocker_ids_to_names[10] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_POWER_ROOM + " and " + level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_ANIMAL_TESTING;
            level.archi.blocker_ids_to_names[11] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_POWER_ROOM + " and " + level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_GARAGE;
            level.archi.blocker_ids_to_names[6] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_TELEPORTER_1; 
            level.archi.blocker_ids_to_names[7] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_TELEPORTER_2; 
            level.archi.blocker_ids_to_names[0] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_TELEPORTER_3; 
        }
        
        //TODO: Error if map doesnt exist
        archi_items::RegisterItem("50 Points",&archi_items::give_50Points);
        archi_items::RegisterItem("500 Points",&archi_items::give_500Points);
        archi_items::RegisterItem("50000 Points",&archi_items::give_50000Points);

        //Server-wide thread to get items from the Lua/LUI
        level thread item_get_from_lua();

        //Server-wide thread to print Log messages from Lua/LUI
        level thread log_from_lua();

        //Collection of Locations that are checked, 
        level.archi.locationQueue = array();


        //Apply settings with Existing DVARS, should be set in menu during initial Room Connection
        on_archi_connect_settings();

    }

    //Setup default map changes
    default_map_changes();
}

function default_map_changes()
{

    //
    level.initial_quick_revive_power_off = true;

    //Give Every Door and Debris a number
    doorCount = 0;
    debrisCount = 0;
    zombie_doors = getentarray("zombie_door", "targetname");
    zombie_debris = getentarray("zombie_debris", "targetname");

    for(; doorCount < zombie_doors.size; doorCount++)
    {
        IPrintLn(doorCount);
        zombie_doors[doorCount].id = doorCount;
    }
    for(; debrisCount < zombie_debris.size; debrisCount++)
    {
        IPrintLn(doorCount + debrisCount);
        total = debrisCount+doorCount;
        zombie_debris[debrisCount].id = total;
    }

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

function on_player_spawned()
{
	level waittill( "initial_blackscreen_passed" );
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
        IPrintLn("Boarded window");

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

//Custom Door/Debris buy check
function archi_blocker_buy_check(blocker)
{
    if (isdefined(level.archi.blockers[blocker.id]) && (!level.archi.blockers[blocker.id]) )
    {
        return false;
    }
    return true;
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
    IPrintLn("Piece picked up");
    
    if ( isdefined(level.archi.craftable_piece_to_location[self.craftableName + "_" + self.pieceName]) )
    {
        ap_location = level.archi.craftable_piece_to_location[self.craftableName + "_" + self.pieceName];
        send_location(ap_location);
    }

    if (isdefined(self.original_onPickup))
    {
        self [[self.original_onPickup]](player);
    }
}