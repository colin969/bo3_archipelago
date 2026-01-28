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

#define AP_LOCATION_DRAGONHEADS " Feed the Dragonheads"
#define AP_LOCATION_LANDINGPADS " Turn on all Landing Pads"

function save_state_manager()
{
    level waittill("end_game");
    level thread location_state_tracker();

    if (level.host_ended_game == 1)
    {
        IPrintLn("Host ended game, saving data...");
        save_state();
    } else {
        IPrintLn("Host did not end game, clearing data...");
        //clear_state();
    }
}

function save_data_round_end()
{
    level endon("end_game");

    while (true)
    {
        level waittill("start_of_round");
        if (level.round_number != 1)
        {
            wait(1);
            save_state();
        }
    }
}

function save_state()
{
    archi_save::save_round_number();
    archi_save::save_power_on();
    archi_save::save_doors_and_debris();
    save_dragonheads();
    save_landingpads();

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
    // Disable rocket pad death plane
    level flag::set("castle_teleporter_used");
    archi_save::restore_round_number();
    archi_save::restore_power_on();
    archi_save::restore_doors_and_debris();
    level thread restore_dragonheads();
    restore_landingpads();

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


// Notes:
// Clientfields: quest_state_<bow>_<num> for ui progress
function setup_weapon_ee_rune_prison()
{
    level thread _flag_to_location_thread("rune_prison_obelisk", level.archi.mapString + " Rune Prison - Take the Arrow");
    level thread _flag_to_location_thread("rune_prison_magma_ball", level.archi.mapString + " Rune Prison - Shoot the Orb");
    level thread _rune_prison_runic_circles();
    level thread _flag_to_location_thread("rune_prison_golf", level.archi.mapString + " Rune Prison - Magma Ball Golf");
    level thread _flag_to_location_thread("rune_prison_repaired", level.archi.mapString + " Rune Prison - Repair the Arrow");
    level thread _flag_to_location_thread("rune_prison_spawned", level.archi.mapString + " Rune Prison - Forge the Bow");
}

function setup_weapon_ee_demon_gate()
{
    level thread _demon_gate_take_broken_arrow();
    level thread _flag_to_location_thread("demon_gate_seal", level.archi.mapString + " Demon Gate - Ritual Sacrifice on the Seal");
    level thread _demon_gate_collect_skulls();
    level thread _flag_to_location_thread("demon_gate_crawlers", level.archi.mapString + " Demon Gate - Sacrifice Crawlers");
    level thread _flag_to_location_thread("demon_gate_runes", level.archi.mapString + " Demon Gate - Solve the Rune Puzzle");
    level thread _flag_to_location_thread("demon_gate_repaired", level.archi.mapString + " Demon Gate - Repair the Arrow");
    level thread _flag_to_location_thread("demon_gate_spawned", level.archi.mapString + " Demon Gate - Forge the Bow");
}

function setup_weapon_ee_wolf_howl()
{
    level thread _flag_to_location_thread("wolf_howl_paintings", level.archi.mapString + " Wolf Howl - Painting Puzzle");
    level thread _wolf_howl_take_broken_arrow();
    level thread _wolf_howl_skull_collected();
    level thread _flag_to_location_thread("wolf_howl_escort", level.archi.mapString + " Wolf Howl - Follow the Wolf");
    level thread _flag_to_location_thread("wolf_howl_repaired", level.archi.mapString + " Wolf Howl - Repair the Arrow");
    level thread _flag_to_location_thread("wolf_howl_spawned", level.archi.mapString + " Wolf Howl - Forge the Bow");
}

function setup_weapon_ee_storm_bow()
{
    level thread _elemental_storm_take_broken_arrow();
    level thread _elemental_storm_beacons_thread();
    level thread _flag_to_location_thread("elemental_storm_wallrun", level.archi.mapString + " Storm Bow - Wallrun Switches");
    level thread _flag_to_location_thread("elemental_storm_batteries", level.archi.mapString + " Storm Bow - Charge the Batteries");
    level thread _flag_to_location_thread("elemental_storm_beacons_charged", level.archi.mapString + " Storm Bow - Charge the Beacons");
    level thread _flag_to_location_thread("elemental_storm_repaired", level.archi.mapString + " Storm Bow - Repair the Arrow");
    level thread _flag_to_location_thread("elemental_storm_spawned", level.archi.mapString + " Storm Bow - Forge the Bow");
}

function setup_main_ee()
{
    level thread _flag_to_location_thread("time_travel_teleporter_ready", level.archi.mapString + " Main Easter Egg - Activate Time Travel Teleporter"); // Wasn't paying attention
    level thread _flag_to_location_thread("ee_safe_open", level.archi.mapString + " Main Easter Egg - Unlock the Safe"); // Works
    level thread _flag_to_location_thread("start_channeling_stone_step", level.archi.mapString + " Main Easter Egg - Recover the Rocket"); // Works
    level thread _flag_to_location_thread("see_keeper", level.archi.mapString + " Main Easter Egg - Open the MPD"); // Needs tested
    level thread _flag_to_location_thread("boss_fight_completed", level.archi.mapString + " Main Easter Egg - Win the Boss Fight"); // Works
    level thread _flag_to_location_thread("sent_rockets_to_the_moon", level.archi.mapString + " Main Easter Egg - Blow up the Moon"); // Works
    level thread _flag_to_location_thread("ee_outro", level.archi.mapString + " Main Easter Egg - Victory"); // Works
}

function _flag_to_location_thread(flag, location)
{
    level endon("end_game");

    level flag::wait_till(flag);
    archi_core::send_location(location);
}

function _demon_gate_take_broken_arrow()
{
    level endon("end__game");
    
    level waittill(#"hash_c8347a07");
    archi_core::send_location(level.archi.mapString + " Demon Gate - Take Broken Arrow");
}

function _demon_gate_collect_skulls()
{
    level endon("end_game");

    skulls = getentarray("aq_dg_fossil", "script_noteworthy");
    array::wait_till(skulls, "returned");
    wait(2); // Delay matches ingame
    archi_core::send_location(level.archi.mapString + " Demon Gate - Collect the Skulls");
}

function _rune_prison_runic_circles()
{
    runic_circles = getentarray("aq_rp_runic_circle_volume", "script_noteworthy");
    array::wait_till(runic_circles, "runic_circle_charged");
    archi_core::send_location(level.archi.mapString + " Rune Prison - Charge the Runic Circles");
}

function _wolf_howl_take_broken_arrow()
{
    level endon("end_game");

    level waittill("hash_44c83018");
    archi_core::send_location(level.archi.mapString + " Wolf Howl - Take Broken Arrow");
}

function _wolf_howl_skull_collected()
{
    level endon("end_game");
    
    level waittill("hash_88b82583");
    archi_core::send_location(level.archi.mapString + " Wolf Howl - Collect the Skull");
}

function _elemental_storm_take_broken_arrow()
{
    level endon("end_game");

    level waittill("hash_6d0730ef");
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
    archi_core::send_location(level.archi.mapString + AP_LOCATION_DRAGONHEADS);
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
    archi_core::send_location(level.archi.mapString + AP_LOCATION_LANDINGPADS);
}


function _landing_pad_notify()
{
    level endon("end_game");

    level flag::wait_till(self.script_noteworthy);
    IPrintLn("Landing Pad Activated");
    level notify("ap_castle_landing_pad_activated");
}

function location_state_tracker()
{
    level endon("end_game");

    while(true)
    {
        level waittill("ap_location_found", loc_str);

        if (loc_str === level.archi.mapString + AP_LOCATION_DRAGONHEADS)
        {
            level.archi.zm_castle_dragonheads = 1;
            continue;
        }
        if (loc_str === level.archi.mapString + AP_LOCATION_LANDINGPADS)
        {
            level.archi.zm_castle_landingpads = 1;
            continue;
        }
    }
} 

function save_dragonheads()
{
    if (IS_TRUE(level.archi.zm_castle_dragonheads))
    {
        SetDvar("ARCHIPELAGO_SAVE_DATA_CASTLE_DRAGONHEADS", 1);
    }
}

function save_landingpads()
{
    if (IS_TRUE(level.archi.zm_castle_landingpads))
    {
        SetDvar("ARCHIPELAGO_SAVE_DATA_CASTLE_LANDINGPADS", 1);
    }
}

function save_flag_exists(dvar_name)
{
    dvar_value = GetDvarInt(dvar_name, 0);
    if (dvar_value > 0){
        return true;
    }
    return false;
}

function restore_dragonheads()
{
    if (save_flag_exists("ARCHIPELAGO_LOAD_DATA_CASTLE_DRAGONHEADS"))
    {
        level.archi.zm_castle_dragonheads = 1;
        foreach (soul_catcher in level.soul_catchers)
        {
            // Force eaten count to 8
            // Animations won't work but quest will progress
            soul_catcher.var_98730ffa = 8;
            wait(0.2);
        }
    }
}

function restore_landingpads()
{
    if (save_flag_exists("ARCHIPELAGO_LOAD_DATA_CASTLE_LANDINGPADS"))
    {
        level.archi.zm_castle_landingpads = 1;
        landing_pads = struct::get_array("115_flinger_landing_pad", "targetname");
        foreach(landing_pad in landing_pads)
        {
           level flag::set(landing_pad.script_noteworthy);
        }
    }
}