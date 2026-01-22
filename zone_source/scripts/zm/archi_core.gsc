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

    level.archi.blocker_ids_to_names[5] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_ANIMAL_TESTING; 
    level.archi.blocker_ids_to_names[4] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_GARAGE;
    level.archi.blocker_ids_to_names[10] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_POWER_ROOM + " and " + level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_ANIMAL_TESTING;
    level.archi.blocker_ids_to_names[11] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_POWER_ROOM + " and " + level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_GARAGE;
    level.archi.blocker_ids_to_names[6] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_TELEPORTER_1; 
    level.archi.blocker_ids_to_names[7] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_TELEPORTER_2; 
    level.archi.blocker_ids_to_names[0] = level.archi.mapString + " " + ARCHIPELAGO_BLOCKER_GIANT_TELEPORTER_3; 
}

function game_start()
{

    //TODO Error out here if there is no connection settings

    if (!isdefined(level.archi))
    {
        //Hold server-wide Archipelago Information
        level.archi = SpawnStruct();

        // Populate location mappings


        //Get Map Name String
        mapName = GetDvarString( "mapname" );

        level.archi.boarded_windows = 0;

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

        // Sub Machine Guns
        level.archi.weapons["smg_burst"] = false;
        level.archi.weapons["smg_capacity"] = false;
        level.archi.weapons["smg_fastfire"] = false;
        level.archi.weapons["smg_standard"] = false;
        level.archi.weapons["smg_versatile"] = false;
        level.archi.weapons["smg_sten"] = false;
        level.archi.weapons["smg_mp40"] = false;
        level.archi.weapons["smg_ppsh"] = false;
        level.archi.weapons["smg_thompson"] = false;
        level.archi.weapons["smg_longrange"] = false;
        level.archi.weapons["smg_ak74u"] = false;
        level.archi.weapons["smg_msmc"] = false;
        level.archi.weapons["smg_nailgun"] = false;
        level.archi.weapons["smg_rechamber"] = false;
        level.archi.weapons["smg_sten2"] = false;
        level.archi.weapons["smg_mp40_1940"] = false;

        // Shotguns
        level.archi.weapons["shotgun_fullauto"] = false;
        level.archi.weapons["shotgun_precision"] = false;
        level.archi.weapons["shotgun_pump"] = false;
        level.archi.weapons["shotgun_semiauto"] = false;
        level.archi.weapons["shotgun_energy"] = false;
        level.archi.weapons["shotgun_olympia"] = false;

        // Pistols
        level.archi.weapons["pistol_revolver38"] = false;
        level.archi.weapons["pistol_standard"] = false;
        level.archi.weapons["pistol_burst"] = false;
        level.archi.weapons["pistol_fullauto"] = false;
        level.archi.weapons["pistol_energy"] = false;
        level.archi.weapons["pistol_m1911"] = false;
        level.archi.weapons["pistol_shotgun_dw"] = false;
        level.archi.weapons["pistol_c96"] = false;

        // Melee
        level.archi.weapons["melee_bowie"] = false;
        
        if (mapName == "zm_factory")
        {
            level.archi.mapString = "(The Giant)";
            init_string_mappings();

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

            // Assault Rifles
            archi_items::RegisterItem("(Weapon) HVK-30",&archi_items::give_Weapon_HVK,"ap_weapon_ar_hvk");
            archi_items::RegisterItem("(Weapon) M8A7",&archi_items::give_Weapon_M8A7,"ap_weapon_ar_m8a7");
            archi_items::RegisterItem("(Weapon) Sheiva",&archi_items::give_Weapon_Sheiva,"ap_weapon_ar_sheiva");
            archi_items::RegisterItem("(Weapon) KN-44",&archi_items::give_Weapon_KN44,"ap_weapon_ar_kn44");
            // Sub Machine Guns
            archi_items::RegisterItem("(Weapon) Kuda",&archi_items::give_Weapon_Kuda,"ap_weapon_smg_standard");
            archi_items::RegisterItem("(Weapon) VMP",&archi_items::give_Weapon_VMP,"ap_weapon_smg_versatile");
            // Shotguns
            archi_items::RegisterItem("(Weapon) KRM-262",&archi_items::give_Weapon_KRM,"ap_weapon_shotgun_pump");
            // Pistols
            archi_items::RegisterItem("(Weapon) L-CAR",&archi_items::give_Weapon_LCAR,"ap_weapon_pistol_fullauto");
            archi_items::RegisterItem("(Weapon) RK5",&archi_items::give_Weapon_RK5,"ap_weapon_pistol_burst");
            // Melee
            archi_items::RegisterItem("(Weapon) Bowie Knife",&archi_items::give_Weapon_BowieKnife,"ap_weapon_melee_bowie");
            
            //Lock Blockers
            level.archi.blockers[5] = false;
            level.archi.blockers[6] = false;
            level.archi.blockers[4] = false;
            level.archi.blockers[11] = false;
            level.archi.blockers[10] = false;
            level.archi.blockers[7] = false;
            level.archi.blockers[0] = false;
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
