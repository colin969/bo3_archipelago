#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\exploder_shared;
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
#using scripts\zm\craftables\_zm_craftables;

#using scripts\zm\archi_core;
#using scripts\zm\archi_save;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\archi_core.gsh;

#define AP_LOCATION_DRAGONHEADS " Feed the Dragonheads"
#define AP_LOCATION_LANDINGPADS " Turn on all Landing Pads"

function save_state_manager()
{
    if (level.archi.difficulty_ee_checkpoints >= 3)
    {
        level thread easy_checkpoint_trigger();
    }
    if (level.archi.difficulty_ee_checkpoints >= 2)
    {
        level thread medium_checkpoint_trigger();
    }
    if (level.archi.difficulty_ee_checkpoints >= 1)
    {
        level thread hard_checkpoint_trigger();
    }

    level.archi.save_state = &save_state;
    level thread archi_save::save_on_round_change();
    level thread archi_save::round_checkpoints();
    level waittill("end_game");
    level thread location_state_tracker();

    if (isdefined(level.host_ended_game) && level.host_ended_game == 1)
    {
        IPrintLn("Host ended game, saving data...");
        save_state();
    } else {
        IPrintLn("Host did not end game, clearing data...");
        clear_state();
    }
}

function save_state()
{
    archi_save::save_round_number();
    archi_save::save_zombie_count();
    archi_save::save_power_on();
    archi_save::save_doors_and_debris();
    save_landingpads();

    archi_save::save_players(&save_player_data);

    save_map_state();

    archi_save::send_save_data("zm_castle");

    if (level.archi.save_checkpoint == true)
    {
        IPrintLnBold("Checkpoint Saved");
    }
}

// self is player
function save_player_data(xuid)
{  
    self archi_save::save_player_score(xuid);
    self archi_save::save_player_perks(xuid);
    self archi_save::save_player_loadout(xuid);
}

// Boss fight ready
function hard_checkpoint_trigger()
{
    level flag::wait_till_clear("ap_prevent_checkpoints");
    if (level flag::get("boss_fight_ready"))
    {
        return;
    }
    level flag::wait_till("boss_fight_ready");
    level.archi.save_checkpoint = true;
    save_state();
    level.archi.save_checkpoint = false;
}

// Safe opened
function medium_checkpoint_trigger()
{
    level flag::wait_till_clear("ap_prevent_checkpoints");
    if (level flag::get("ee_safe_open"))
    {
        return;
    }
    level flag::wait_till("ee_safe_open");
    level.archi.save_checkpoint = true;
    save_state();
    level.archi.save_checkpoint = false;
}

// Dragonheads fed
function easy_checkpoint_trigger()
{
    level flag::wait_till_clear("ap_prevent_checkpoints");
    if (level flag::get("soul_catchers_charged"))
    {
        return;
    }
    level flag::wait_till("soul_catchers_charged");
    level.archi.save_checkpoint = true;
    save_state();
    level.archi.save_checkpoint = false;
}


function load_state()
{
    level.archi.zm_castle_landingpads = 0;
    archi_save::wait_restore_ready("zm_castle");
    // Disable rocket pad death plane
    level flag::set("castle_teleporter_used");
    archi_save::restore_zombie_count();
    archi_save::restore_round_number();
    archi_save::restore_power_on();
    archi_save::restore_doors_and_debris();
    restore_landingpads();

    archi_save::restore_players(&restore_player_data);

    restore_map_state();

    wait(10);
    level flag::clear("ap_prevent_checkpoints");
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

    bears_activated = 0;
    bears = struct::get_array("hs_bear", "targetname");
    array::thread_all(bears, &_track_trigger_dead_again);

    while(bears_activated < bears.size)
    {
		level waittill("ap_castle_dead_again");
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

    gramophones_activated = 0;
    gramophones = getentarray("hs_gramophone", "targetname");
    array::thread_all(gramophones, &_track_trigger_requiem);

    while(gramophones_activated < gramophones.size)
    {
		level waittill("ap_castle_requiem");
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

function setup_locations()
{
    setup_landing_pads();

    level flag::wait_till("initial_blackscreen_passed");

    setup_soul_catchers();

    setup_music_ee_trackers();

    setup_weapon_ee_rune_prison();
    setup_weapon_ee_demon_gate();
    setup_weapon_ee_wolf_howl();
    setup_weapon_ee_storm_bow();

    setup_main_ee();
}

// Notes:
// Clientfields: quest_state_<bow>_<num> for ui progress
function setup_weapon_ee_rune_prison()
{
    level thread _flag_to_location_thread("rune_prison_obelisk", level.archi.mapString + " Rune Prison - Take Broken Arrow");
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
    
    level waittill("hash_c8347a07");
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
    level notify("ap_castle_landing_pad_activated");
}

function location_state_tracker()
{
    level endon("end_game");

    while(true)
    {
        level waittill("ap_location_found", loc_str);

        if (loc_str === level.archi.mapString + AP_LOCATION_LANDINGPADS)
        {
            level.archi.zm_castle_landingpads = 1;
            continue;
        }
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

function give_RagnarokPart_Body()
{
    give_piece("gravityspike", "part_body");
}

function give_RagnarokPart_Guards()
{
    give_piece("gravityspike", "part_guards");
}

function give_RagnarokPart_Handle()
{
    give_piece("gravityspike", "part_handle");
}

function give_piece(craftableName, pieceName)
{
    level.archi.craftable_parts[craftableName + "_" + pieceName] = true;
    zm_craftables::player_get_craftable_piece(craftableName, pieceName);
}

function save_map_state()
{
    archi_save::save_flag("soul_catchers_charged");
    archi_save::save_flag("death_ray_trap_used");
    archi_save::save_flag("ee_fuse_placed");
    archi_save::save_flag("ee_safe_open");
    archi_save::save_flag("tesla_connector_launch_platform");
    archi_save::save_flag("tesla_connector_lower_tower");
    archi_save::save_flag("demon_gate_upgraded");
    archi_save::save_flag("elemental_storm_upgraded");
    archi_save::save_flag("rune_prison_upgraded");
    archi_save::save_flag("wolf_howl_upgraded");
    archi_save::save_flag("ee_start_done");
    archi_save::save_flag("ee_golden_key");
    archi_save::save_flag("mpd_canister_replacement");
    archi_save::save_flag("channeling_stone_replacement");
    archi_save::save_flag("start_channeling_stone_step");
    archi_save::save_flag("boss_fight_ready");
}

function restore_map_state()
{
    archi_save::restore_flag("soul_catchers_charged");
    if (level flag::get("soul_catchers_charged"))
    {
        for(i = 0; i < level.soul_catchers.size; i++)
        {
            // Force eaten count to 8
            level.soul_catchers[i].var_98730ffa = 8;
            wait(0.2);
            // Crumble head
            level clientfield::set(level.soul_catchers[i].script_parameters, 6);
        }
    }
    archi_save::restore_flag("death_ray_trap_used");
    archi_save::restore_flag("ee_safe_open");
    wait(0.1);
    archi_save::restore_flag("tesla_connector_launch_platform");
    if (level flag::get("tesla_connector_launch_platform"))
    {
        tower = struct::get("tc_launch_platform");
	    util::spawn_model("p7_zm_ctl_deathray_base_part", tower.origin, tower.angles);
	    exploder::exploder("fxexp_721");
    }
    archi_save::restore_flag("tesla_connector_lower_tower");
    if (level flag::get("tesla_connector_lower_tower"))
    {
        tower = struct::get("tc_lower_tower");
	    util::spawn_model("p7_zm_ctl_deathray_base_part", tower.origin, tower.angles);
	    exploder::exploder("fxexp_711");
    }
    archi_save::restore_flag("ee_fuse_placed");
    if (level flag::get("ee_fuse_placed"))
    {
        fuse_box = getent("fuse_box", "targetname");
        fuse_box showpart("j_chip01");
		fuse_box showpart("j_chip02");
    }
    wait(0.1);
    archi_save::restore_flag("demon_gate_upgraded");
    archi_save::restore_flag("elemental_storm_upgraded");
    archi_save::restore_flag("rune_prison_upgraded");
    archi_save::restore_flag("wolf_howl_upgraded");
    archi_save::restore_flag("ee_start_done");
    archi_save::restore_flag("ee_golden_key");
    wait(0.1);
    archi_save::restore_flag("mpd_canister_replacement");
    archi_save::restore_flag("channeling_stone_replacement");
    archi_save::restore_flag("start_channeling_stone_step");
    archi_save::restore_flag("boss_fight_ready");
    if (level flag::get("boss_fight_ready"))
    {
        // Uncover MPD
        pyramids = getentarray("pyramid", "targetname");
        foreach(pyramid in pyramids)
        {
            new_origin = (pyramid.origin[0], pyramid.origin[1], pyramid.origin[2] - 96);
            pyramid notsolid();
            pyramid connectpaths();
            pyramid moveto(new_origin, 3);
        }
    }
    // Complete simons says sequence to trigger rocket scene
    if (level flag::get("start_channeling_stone_step"))
    {
        wait(1);
        simon_terminals = struct::get_array("golden_key_slot");
        for (i = 0; i < 2; i++)
        {
            level.var_cf5a713 = simon_terminals[i];
            level flag::set("simon_terminal_activated");
            WAIT_SERVER_FRAME
            level notify("hash_706f7f9a"); // Skip intro
            WAIT_SERVER_FRAME
            level.var_521b0bd1 = 9; // Number of successful presses
            level flag::set("simon_press_check"); // Success press
            WAIT_SERVER_FRAME
            level notify("hash_b7f06cd9"); // Press release (3 seconds later)
            wait(0.5);
        }
        wait(1);
        button = struct::get("death_ray_button");
        button notify("trigger_activated");
    }
}