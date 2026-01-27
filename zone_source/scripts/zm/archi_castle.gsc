#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\player_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\hud_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_weapons;

#using scripts\zm\archi_core;
#using scripts\zm\archi_save;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\archi_core.gsh;

function save_state_manager()
{
    level waittill("end_game");

    if (level.host_ended_game == 1)
    {
        IPrintLn("Host ended game, saving data...");
        save_state();
    } else {
        IPrintLn("Host did not end game, clearing data...");
        clear_state();
    }
}

function save_data_round_end()
{
    level endon("end_game");
    level waittill("initial_blackscreen_passed");

    while (true)
    {
        level waittill("start_of_round");
        if (level.round_number != 1)
        {
            save_state();
        }
    }
}

function save_state()
{
    archi_save::save_round_number();
    archi_save::save_power_on();
    archi_save::save_doors_and_debris();

    archi_save::save_players(&save_player_data);

    archi_save::send_save_data("zm_castle");
}

// self is player
function save_player_data(xuid)
{  
    self archi_save::save_player_score(xuid);
    self archi_save::save_player_perks(xuid);
    self archi_save::save_player_loadout(xuid);
}

function load_state()
{
    archi_save::wait_restore_ready("zm_castle");
    archi_save::restore_round_number();
    archi_save::restore_power_on();
    archi_save::restore_doors_and_debris();

    archi_save::restore_players(&restore_player_data);
}

// self is player
function restore_player_data()
{
    xuid = self GetXuid();

    if (archi_save::can_restore_player(xuid))
    {
        self archi_save::restore_player_score(xuid);
        self archi_save::restore_player_perks(xuid);
        self archi_save::restore_player_loadout(xuid);
    }
}

function clear_state()
{
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_castle");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function setup_soul_catchers()
{
    level thread _all_soul_catchers_filled_thread();
}

function setup_landing_pads()
{
    // Add activate notifier on each landing pad
    landing_pads = struct::get_array("115_flinger_landing_pad", "targetname");
    array::thread_all(landing_pads, &_landing_pad_notify);

    // Listen for activation events forwarded from landing pad notifiers
    level thread _all_landing_pads_activated(landing_pads.size);
}

function setup_music_ee_trackers()
{
    level thread _track_music_dead_again();
    level thread _track_music_requiem();
}

function _track_music_dead_again()
{
    level endon("end_game");

    level waittill("initial_blackscreen_passed");

    bears_activated = 0;
    bears = struct::get_array("hs_bear", "targetname");
    array::thread_all(bears, &_track_trigger_dead_again);

    while(bears_activated < bears.size)
    {
		level waittill("ap_castle_dead_again");
        IPrintLn("Bear Activated");
        bears_activated += 1;
    }

    archi_core::send_location(level.archi.mapString + " Music EE - Dead Again");
}

function _track_trigger_dead_again()
{
    e_origin = ArrayGetClosest( self.origin, GetEntArray( "script_origin", "classname" ) );
    
    while( !IS_TRUE( e_origin.b_activated ) )
    {
        e_origin waittill( "trigger_activated" );
        // Allow e_origin's own waittill to run first so b_activated is changed
        WAIT_SERVER_FRAME
    }
    
    level notify("ap_castle_dead_again");
}

function _track_music_requiem()
{
    level endon("end_game");

    level waittill("initial_blackscreen_passed");

    gramophones_activated = 0;
    gramophones = getentarray("hs_gramophone", "targetname");
    array::thread_all(gramophones, &_track_trigger_requiem);

    while(gramophones_activated < gramophones.size)
    {
		level waittill("ap_castle_requiem");
        IPrintLn("Gramophone Activated");
        gramophones_activated += 1;
    }

    archi_core::send_location(level.archi.mapString + " Music EE - Requiem");
}

function _track_trigger_requiem()
{
    while( !IS_TRUE( self.b_activated ) )
    {
        self waittill( "trigger_activated" );
        // Allow e_origin's own waittill to run first so b_activated is changed
        WAIT_SERVER_FRAME
    }
    
    level notify("ap_castle_requiem");
}

function setup_weapon_ee_storm_bow()
{
    level thread _elemental_storm_quest_started();
    level thread _elemental_storm_beacons_thread();
    level thread _flag_to_location_thread("elemental_storm_wallrun", level.archi.mapString + " Storm Bow - Wallrun Switches");
    level thread _flag_to_location_thread("elemental_storm_batteries", level.archi.mapString + " Storm Bow - Charge the Batteries");
    level thread _flag_to_location_thread("elemental_storm_beacons_charged", level.archi.mapString + " Storm Bow - Charge the Beacons");
    level thread _flag_to_location_thread("elemental_storm_repaired", level.archi.mapString + " Storm Bow - Repair the Arrow");
    level thread _flag_to_location_thread("elemental_storm_spawned", level.archi.mapString + " Storm Bow - Forge the Bow");
}

function _flag_to_location_thread(flag, location)
{
    level endon("end_game");

    level flag::wait_till(flag);
    archi_core::send_location(location);
}

function _elemental_storm_quest_started()
{
    level endon("end_game");

    level waittill(#"hash_6d0730ef");
    archi_core::send_location(level.archi.mapString + " Storm Bow - Take Broken Arrow");
}

function _elemental_storm_beacons_thread()
{
    level endon("end_game");

    beacons = getentarray("aq_es_beacon_trig", "script_noteworthy");
    array::wait_till(beacons, "beacon_activated");
    archi_core::send_location(level.archi.mapString + " Storm Bow - Light the Beacons");
}

function _all_soul_catchers_filled_thread()
{
    level endon("end_game");

    level flag::wait_till("soul_catchers_charged");
    archi_core::send_location(level.archi.mapString + " Feed the Dragonheads");
}

function _all_landing_pads_activated(pad_count)
{
    level endon("end_game");

    pads_activated = 0;
    while (pads_activated < pad_count)
    {
        level waittill("ap_castle_landing_pad_activated");
        pads_activated += 1;
    }
    archi_core::send_location(level.archi.mapString + " Turn on all Landing Pads");
}


function _landing_pad_notify()
{
    level endon("end_game");

    level flag::wait_till(self.script_noteworthy);
    IPrintLn("Landing Pad Activated");
    level notify("ap_castle_landing_pad_activated");
}


