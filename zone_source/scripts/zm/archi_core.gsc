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
    //Lua Log Passing Dvars
    SetDvar("ARCHIPELAGO_LOG_MESSAGE", "NONE");


	callback::on_start_gametype( &game_start );
	callback::on_connect( &on_player_connect );
	callback::on_spawned( &on_player_spawned ); 


    //Clientfields (Mostly Tracker stuff)
    //TODO Put this in a library?
    //TODO Figure out if I need to set these to 0 if maps are swapped down the line
    clientfield::register("world", "ap_item_juggernog", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_double_tap", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_quick_revive", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_speed_cola", VERSION_SHIP, 2, "int");
    clientfield::register("world", "ap_item_mule_kick", VERSION_SHIP, 2, "int");
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
    level thread round_start_location();
    level thread round_end_noti();
    level thread repaired_board_noti();
}

function on_archi_connect_settings()
{

    //TODO: Add some Archipelago settings, then put them in here

	
}

function init_location_mapping()
{
    level.archi.location_to_id = [];

    // Round locations (IDs 1-99)
    level.archi.location_to_id["(The Giant) Round 01"] = 1;
    level.archi.location_to_id["(The Giant) Round 02"] = 2;
    level.archi.location_to_id["(The Giant) Round 03"] = 3;
    level.archi.location_to_id["(The Giant) Round 04"] = 4;
    level.archi.location_to_id["(The Giant) Round 05"] = 5;
    level.archi.location_to_id["(The Giant) Round 06"] = 6;
    level.archi.location_to_id["(The Giant) Round 07"] = 7;
    level.archi.location_to_id["(The Giant) Round 08"] = 8;
    level.archi.location_to_id["(The Giant) Round 09"] = 9;
    level.archi.location_to_id["(The Giant) Round 10"] = 10;
    level.archi.location_to_id["(The Giant) Round 11"] = 11;
    level.archi.location_to_id["(The Giant) Round 12"] = 12;
    level.archi.location_to_id["(The Giant) Round 13"] = 13;
    level.archi.location_to_id["(The Giant) Round 14"] = 14;
    level.archi.location_to_id["(The Giant) Round 15"] = 15;
    level.archi.location_to_id["(The Giant) Round 16"] = 16;
    level.archi.location_to_id["(The Giant) Round 17"] = 17;
    level.archi.location_to_id["(The Giant) Round 18"] = 18;
    level.archi.location_to_id["(The Giant) Round 19"] = 19;
    level.archi.location_to_id["(The Giant) Round 20"] = 20;
    level.archi.location_to_id["(The Giant) Round 21"] = 21;
    level.archi.location_to_id["(The Giant) Round 22"] = 22;
    level.archi.location_to_id["(The Giant) Round 23"] = 23;
    level.archi.location_to_id["(The Giant) Round 24"] = 24;
    level.archi.location_to_id["(The Giant) Round 25"] = 25;
    level.archi.location_to_id["(The Giant) Round 26"] = 26;
    level.archi.location_to_id["(The Giant) Round 27"] = 27;
    level.archi.location_to_id["(The Giant) Round 28"] = 28;
    level.archi.location_to_id["(The Giant) Round 29"] = 29;
    level.archi.location_to_id["(The Giant) Round 30"] = 30;
    level.archi.location_to_id["(The Giant) Round 31"] = 31;
    level.archi.location_to_id["(The Giant) Round 32"] = 32;
    level.archi.location_to_id["(The Giant) Round 33"] = 33;
    level.archi.location_to_id["(The Giant) Round 34"] = 34;
    level.archi.location_to_id["(The Giant) Round 35"] = 35;
    level.archi.location_to_id["(The Giant) Round 36"] = 36;
    level.archi.location_to_id["(The Giant) Round 37"] = 37;
    level.archi.location_to_id["(The Giant) Round 38"] = 38;
    level.archi.location_to_id["(The Giant) Round 39"] = 39;
    level.archi.location_to_id["(The Giant) Round 40"] = 40;
    level.archi.location_to_id["(The Giant) Round 41"] = 41;
    level.archi.location_to_id["(The Giant) Round 42"] = 42;
    level.archi.location_to_id["(The Giant) Round 43"] = 43;
    level.archi.location_to_id["(The Giant) Round 44"] = 44;
    level.archi.location_to_id["(The Giant) Round 45"] = 45;
    level.archi.location_to_id["(The Giant) Round 46"] = 46;
    level.archi.location_to_id["(The Giant) Round 47"] = 47;
    level.archi.location_to_id["(The Giant) Round 48"] = 48;
    level.archi.location_to_id["(The Giant) Round 49"] = 49;
    level.archi.location_to_id["(The Giant) Round 50"] = 50;
    level.archi.location_to_id["(The Giant) Round 51"] = 51;
    level.archi.location_to_id["(The Giant) Round 52"] = 52;
    level.archi.location_to_id["(The Giant) Round 53"] = 53;
    level.archi.location_to_id["(The Giant) Round 54"] = 54;
    level.archi.location_to_id["(The Giant) Round 55"] = 55;
    level.archi.location_to_id["(The Giant) Round 56"] = 56;
    level.archi.location_to_id["(The Giant) Round 57"] = 57;
    level.archi.location_to_id["(The Giant) Round 58"] = 58;
    level.archi.location_to_id["(The Giant) Round 59"] = 59;
    level.archi.location_to_id["(The Giant) Round 60"] = 60;
    level.archi.location_to_id["(The Giant) Round 61"] = 61;
    level.archi.location_to_id["(The Giant) Round 62"] = 62;
    level.archi.location_to_id["(The Giant) Round 63"] = 63;
    level.archi.location_to_id["(The Giant) Round 64"] = 64;
    level.archi.location_to_id["(The Giant) Round 65"] = 65;
    level.archi.location_to_id["(The Giant) Round 66"] = 66;
    level.archi.location_to_id["(The Giant) Round 67"] = 67;
    level.archi.location_to_id["(The Giant) Round 68"] = 68;
    level.archi.location_to_id["(The Giant) Round 69"] = 69;
    level.archi.location_to_id["(The Giant) Round 70"] = 70;
    level.archi.location_to_id["(The Giant) Round 71"] = 71;
    level.archi.location_to_id["(The Giant) Round 72"] = 72;
    level.archi.location_to_id["(The Giant) Round 73"] = 73;
    level.archi.location_to_id["(The Giant) Round 74"] = 74;
    level.archi.location_to_id["(The Giant) Round 75"] = 75;
    level.archi.location_to_id["(The Giant) Round 76"] = 76;
    level.archi.location_to_id["(The Giant) Round 77"] = 77;
    level.archi.location_to_id["(The Giant) Round 78"] = 78;
    level.archi.location_to_id["(The Giant) Round 79"] = 79;
    level.archi.location_to_id["(The Giant) Round 80"] = 80;
    level.archi.location_to_id["(The Giant) Round 81"] = 81;
    level.archi.location_to_id["(The Giant) Round 82"] = 82;
    level.archi.location_to_id["(The Giant) Round 83"] = 83;
    level.archi.location_to_id["(The Giant) Round 84"] = 84;
    level.archi.location_to_id["(The Giant) Round 85"] = 85;
    level.archi.location_to_id["(The Giant) Round 86"] = 86;
    level.archi.location_to_id["(The Giant) Round 87"] = 87;
    level.archi.location_to_id["(The Giant) Round 88"] = 88;
    level.archi.location_to_id["(The Giant) Round 89"] = 89;
    level.archi.location_to_id["(The Giant) Round 90"] = 90;
    level.archi.location_to_id["(The Giant) Round 91"] = 91;
    level.archi.location_to_id["(The Giant) Round 92"] = 92;
    level.archi.location_to_id["(The Giant) Round 93"] = 93;
    level.archi.location_to_id["(The Giant) Round 94"] = 94;
    level.archi.location_to_id["(The Giant) Round 95"] = 95;
    level.archi.location_to_id["(The Giant) Round 96"] = 96;
    level.archi.location_to_id["(The Giant) Round 97"] = 97;
    level.archi.location_to_id["(The Giant) Round 98"] = 98;
    level.archi.location_to_id["(The Giant) Round 99"] = 99;
    
    // Misc location
    level.archi.location_to_id["Repair Windows 5 Times"] = 9001;
}

function game_start()
{

    //TODO Error out here if there is no connection settings

    if (!isdefined(level.archi))
    {
        //Hold server-wide Archipelago Information
        level.archi = SpawnStruct();

        // Populate location mappings

        init_location_mapping();

        //Get Map Name String
        mapName = GetDvarString( "mapname" );

        level.archi.boarded_windows = 0;
        
        if (mapName == "zm_factory")
        {
            level.archi.mapString = "(The Giant)";

            //Register Items
            archi_items::RegisterItem("(The Giant) Juggernog",&archi_items::give_Juggernog,"ap_item_juggernog");
            archi_items::RegisterItem("(The Giant) Quick Revive",&archi_items::give_QuickRevive,"ap_item_quick_revive");
            archi_items::RegisterItem("(The Giant) Speed Cola",&archi_items::give_SpeedCola,"ap_item_speed_cola");
            archi_items::RegisterItem("(The Giant) Double Tap",&archi_items::give_DoubleTap,"ap_item_double_tap");
            archi_items::RegisterItem("(The Giant) Mule Kick",&archi_items::give_MuleKick,"ap_item_mule_kick");
            archi_items::RegisterItem("(The Giant) Victory",&archi_items::give_Victory,undefined);
            
            archi_items::RegisterItem("(The Giant) Animal Testing",&archi_items::give_The_Giant_Animal_Testing,"ap_item_region_1");
            archi_items::RegisterItem("(The Giant) Garage",&archi_items::give_The_Giant_Garage,"ap_item_region_2");
            archi_items::RegisterItem("(The Giant) Power Room",&archi_items::give_The_Giant_Power_Room,"ap_item_region_3");
            archi_items::RegisterItem("(The Giant) Teleporter 1",&archi_items::give_The_Giant_Teleporter_1,"ap_item_region_4");
            archi_items::RegisterItem("(The Giant) Teleporter 2",&archi_items::give_The_Giant_Teleporter_2,"ap_item_region_5");
            archi_items::RegisterItem("(The Giant) Teleporter 3",&archi_items::give_The_Giant_Teleporter_3,"ap_item_region_6");

            archi_items::RegisterItem("(Weapon) ICR-1",&archi_items::give_Weapon_ICR,"ap_weapon_ar_icr");
            archi_items::RegisterItem("(Weapon) HVK-30",&archi_items::give_Weapon_HVK,"ap_weapon_ar_hvk");
            archi_items::RegisterItem("(Weapon) Man-o-War",&archi_items::give_Weapon_ManoWar,"ap_weapon_ar_manowar");
            archi_items::RegisterItem("(Weapon) M8A7",&archi_items::give_Weapon_M8A7,"ap_weapon_ar_m8a7");
            archi_items::RegisterItem("(Weapon) Sheiva",&archi_items::give_Weapon_Sheiva,"ap_weapon_ar_sheiva");
            archi_items::RegisterItem("(Weapon) KN-44",&archi_items::give_Weapon_KN44,"ap_weapon_ar_kn44");
            archi_items::RegisterItem("(Weapon) FFAR",&archi_items::give_Weapon_FFAR,"ap_weapon_ar_ffar");
            archi_items::RegisterItem("(Weapon) MX Garand",&archi_items::give_Weapon_Garand,"ap_weapon_ar_garand");
            archi_items::RegisterItem("(Weapon) Peacekeeper MK2",&archi_items::give_Weapon_Peacekeeper,"ap_weapon_ar_peacekeeper");
            archi_items::RegisterItem("(Weapon) AN-94",&archi_items::give_Weapon_AN94,"ap_weapon_ar_an94");
            archi_items::RegisterItem("(Weapon) Galil",&archi_items::give_Weapon_Galil,"ap_weapon_ar_galil");
            archi_items::RegisterItem("(Weapon) M14",&archi_items::give_Weapon_M14,"ap_weapon_ar_m14");
            archi_items::RegisterItem("(Weapon) M16",&archi_items::give_Weapon_M16,"ap_weapon_ar_m16");
            archi_items::RegisterItem("(Weapon) LV8 Basilisk",&archi_items::give_Weapon_Basilisk,"ap_weapon_ar_basilisk");
            archi_items::RegisterItem("(Weapon) XR-2",&archi_items::give_Weapon_XR2,"ap_weapon_ar_xr2");
            archi_items::RegisterItem("(Weapon) STG-44",&archi_items::give_Weapon_STG44,"ap_weapon_ar_stg44");

            //Lock Blockers
            level.archi.blockers[5] = false;
            level.archi.blockers[6] = false;
            level.archi.blockers[4] = false;
            level.archi.blockers[11] = false;
            level.archi.blockers[10] = false;
            level.archi.blockers[7] = false;
            level.archi.blockers[0] = false;

            //Lock Weapons
            level.archi.weapons["ar_accurate"] = false;
            level.archi.weapons["ar_cqb"] = false;
            level.archi.weapons["ar_damage"] = false;
            level.archi.weapons["ar_longburst"] = false;
            level.archi.weapons["ar_marksman"] = false;
            level.archi.weapons["ar_standard"] = false;
            level.archi.weapons["ar_famas"] = false;
            level.archi.weapons["ar_garand"] = false;
            level.archi.weapons["ar_peacekeeper"] = false;
            level.archi.weapons["ar_an94"] = false;
            level.archi.weapons["ar_galil"] = false;
            level.archi.weapons["ar_m14"] = false;
            level.archi.weapons["ar_m16"] = false;
            level.archi.weapons["ar_pulse"] = false;
            level.archi.weapons["ar_fastburst"] = false;
            level.archi.weapons["ar_stg44"] = false;
        }
        
        //TODO: Error if map doesnt exist
        archi_items::RegisterItem("50 Points",&archi_items::give_50Points);
        archi_items::RegisterItem("500 Points",&archi_items::give_500Points);
        

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