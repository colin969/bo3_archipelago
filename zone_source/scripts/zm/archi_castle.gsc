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
#using scripts\shared\scene_shared;
#using scripts\shared\scene_debug_shared;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\zm\archi_core;
#using scripts\zm\archi_save;
#using scripts\zm\archi_commands;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;

#insert scripts\zm\archi_core.gsh;

#define AP_LOCATION_DRAGONHEADS " Feed the Dragonheads"
#define AP_LOCATION_LANDINGPADS " Turn on all Landing Pads"

function save_state_manager()
{
    level flag::init("ap_allow_player_restore");
    // Keep perk machine fx behaving
    callback::on_connect(&_player_connect);

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
    level flag::wait_till("ap_attachment_rando_ready");
    // Disable rocket pad death plane
    level flag::set("castle_teleporter_used");
    archi_save::restore_zombie_count();
    archi_save::restore_round_number();
    archi_save::restore_power_on();
    archi_save::restore_doors_and_debris();
    restore_landingpads();

    level flag::set("ap_allow_player_restore");

    restore_map_state();

    wait(10);
    level flag::clear("ap_prevent_checkpoints");
}

// self is player
function restore_player_data(xuid)
{
    level endon("end_game");
    self endon("disconnect");

    level flag::wait_till("ap_allow_player_restore");

    if (self archi_save::can_restore_player(xuid))
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
    
    while(true)
    {
        level waittill("hash_c8347a07");
        archi_core::send_location(level.archi.mapString + " Demon Gate - Take Broken Arrow");
        wait(3);
        xuid = level.var_6e68c0d8 GetXuid();
        level.archi.void_owner = xuid;
    }
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

    while(true)
    {
        level waittill("hash_44c83018");
        archi_core::send_location(level.archi.mapString + " Wolf Howl - Take Broken Arrow");
        wait(3);
        xuid = level.var_52978d72 GetXuid();
        level.archi.wolf_owner = xuid;
    }
}

function _wolf_howl_skull_collected()
{
    level endon("end_game");
    
    level waittill("hash_88b82583");
    level.archi.wolf_skull_collected = true;
    archi_core::send_location(level.archi.mapString + " Wolf Howl - Collect the Skull");
}

function _elemental_storm_take_broken_arrow()
{
    level endon("end_game");

    while(true)
    {
        level waittill("hash_6d0730ef");
        archi_core::send_location(level.archi.mapString + " Storm Bow - Take Broken Arrow");
        wait(3);
        xuid = level.var_f8d1dc16 GetXuid();
        level.archi.storm_owner = xuid;
    }
}

function _elemental_storm_beacons_thread()
{
    level endon("end_game");

    beacons = getentarray("aq_es_beacon_trig", "script_noteworthy");
    array::wait_till(beacons, "beacon_activated");
    archi_core::send_location(level.archi.mapString + " Storm Bow - Light the Beacons");
    level.archi.elemental_storm_beacons_lit = 1;
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
        SetDvar("ARCHIPELAGO_LOAD_DATA_CASTLE_LANDINGPADS", "");
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
    archi_save::save_flag("ee_start_done");
    archi_save::save_flag("ee_golden_key");
    archi_save::save_flag("mpd_canister_replacement");
    archi_save::save_flag("channeling_stone_replacement");
    archi_save::save_flag("start_channeling_stone_step");
    archi_save::save_flag("boss_fight_ready");

    archi_save::save_val("elemental_storm_beacons_lit", IS_TRUE(level.archi.elemental_storm_beacons_lit));
    archi_save::save_flag("elemental_storm_wallrun");
    archi_save::save_flag("elemental_storm_batteries");
    archi_save::save_flag("elemental_storm_beacons_charged");
    archi_save::save_flag("elemental_storm_repaired");

    archi_save::save_flag("wolf_howl_paintings");
    archi_save::save_val("wolf_howl_skull_collected", IS_TRUE(level.archi.wolf_skull_collected));
	archi_save::save_flag("wolf_howl_escort");
	archi_save::save_flag("wolf_howl_repaired");

    archi_save::save_flag("demon_gate_seal");
    archi_save::save_flag("demon_gate_crawlers");
	archi_save::save_flag("demon_gate_runes");
    archi_save::save_flag("demon_gate_repaired");

    archi_save::save_val("storm_owner", level.archi.storm_owner);
    archi_save::save_val("wolf_owner", level.archi.wolf_owner);
    archi_save::save_val("fire_owner", level.archi.fire_owner);
    archi_save::save_val("void_owner", level.archi.void_owner);
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
    archi_save::restore_flag("ee_start_done");
    archi_save::restore_flag("ee_golden_key");
    wait(0.1);
    archi_save::restore_flag("mpd_canister_replacement");
    archi_save::restore_flag("channeling_stone_replacement");
    level.archi.elemental_storm_beacons_lit = archi_save::restore_val("elemental_storm_beacons_lit");
    if (isdefined(level.archi.elemental_storm_beacons_lit))
    {
        level.archi.elemental_storm_beacons_lit = Int(level.archi.elemental_storm_beacons_lit);
    }
    level.archi.storm_owner = archi_save::restore_val("storm_owner");
    level.archi.wolf_owner = archi_save::restore_val("wolf_owner");
    level.archi.fire_owner = archi_save::restore_val("fire_owner");
    level.archi.void_owner = archi_save::restore_val("void_owner");
    level thread setup_bow_restore();
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
}

function _restore_wolf_bow(e_player)
{
    elemental_bow = GetWeapon("elemental_bow");

    archi_save::restore_flag("wolf_howl_paintings");
    wait(0.1);

    // Trigger player stepping near wall
    arrow = struct::get("quest_start_wolf_howl");
    all_uni = [];
    foreach (zone in level.zones)
    {
        if (isdefined(zone.unitrigger_stubs))
        {
            all_uni = ArrayCombine(all_uni, zone.unitrigger_stubs, 1, 0);
        }
    }
    trigger_origin = arrow.origin + (-12, -72, 0);
    closest = zm_unitrigger::get_closest_unitriggers(trigger_origin, all_uni, 5);
    foreach (s_untrigger_stub in closest)
    {
        s_untrigger_stub notify("trigger", e_player);
    }
    wait(3);
    // Trigger arrow pickup
    arrow.var_67b5dd94 notify("trigger", e_player);
    wait(0.1);

    level.archi.wolf_skull_collected = archi_save::restore_val("wolf_howl_skull_collected");
    if (level.archi.wolf_skull_collected == "1")
    {
        falling_skull = getent("aq_wh_skull_shrine_trig", "targetname");
        level.var_52978d72 notify("projectile_impact", elemental_bow, falling_skull.origin);
        wait(0.1);
        wait getanimlength( "p7_fxanim_zm_castle_quest_wolf_skull_roll_down_anim" );
        fallen_skull = getent("wolf_skull_roll_down", "targetname");
        fallen_skull.var_67b5dd94 notify("trigger", e_player);
        wait(0.1);
    }

    archi_save::restore_flag("wolf_howl_escort");
    if (level flag::get("wolf_howl_escort"))
    {
        wait(0.1);
        dig_vols = getentarray("aq_wh_dig_volume", "script_noteworthy");
        foreach(vol in dig_vols)
        {
            vol.var_252d000d = 15;
            vol flag::set("dig_spot_complete");
            skull_trigger = getent("aq_wh_skadi_skull", "targetname");
            skull_trigger.var_67b5dd94 notify("trigger", e_player);
        }
    }
}

function _restore_storm_bow(e_player)
{
    elemental_bow = GetWeapon("elemental_bow");

    // Damage weathervane so the broken arrow appears
    e_vane = getent("aq_es_weather_vane_trig", "targetname");
    e_vane notify("damage", 100, e_player, (0, 0, 0), e_vane.origin, undefined, "", "", "", elemental_bow);

    wait(6);
    // Pretend player is on roof volume
    level.var_366df00d = 1;
    level notify("hash_6d0730ef");
    wait(0.5);
    // Force pickup
    arrow_pickup = struct::get("quest_start_elemental_storm");
    arrow_pickup.var_67b5dd94 notify("trigger", e_player);
    wait(0.5);

    if (level.archi.elemental_storm_beacons_lit == 1)
    {
        beacons = getentarray("aq_es_beacon_trig", "script_noteworthy");
        foreach (beacon in beacons)
        {
            level.var_f8d1dc16 notify("projectile_impact", elemental_bow, beacon.origin);
            wait(0.1);
        }
        wait(0.5);
    }

    archi_save::restore_flag("elemental_storm_wallrun");

    // Restore charged batteries
    archi_save::restore_flag("elemental_storm_batteries");
    batteries = getentarray("aq_es_battery_volume", "script_noteworthy");
    if (level flag::get("elemental_storm_batteries"))
    {
        foreach (battery in batteries)
        {
            e_bat = struct::get(self.target, "targetname");
            e_bat.var_bb487f65 = 10;
            e_bat notify("killed");
        }
        wait(0.5);
    }

    // Restore charged beacons
    archi_save::restore_flag("elemental_storm_beacons_charged");
    if (level flag::get("elemental_storm_beacons_charged"))
    {
        for (i = 0; i < beacons.size; i++)
        {
            beacon = beacons[i];
            battery = batteries[i];
            e_sbat = getent(self.targetname + "_charged", "targetname");

            fake_projectile = SpawnStruct();
            fake_projectile.var_e4594d27 = 1;
            fake_projectile.var_8f88d1fd = e_sbat;

            level.var_f8d1dc16 notify("projectile_impact", elemental_bow, beacon.origin, 10, fake_projectile);
            wait(0.1);
        }
        wait(2);
    }
    // archi_save::restore_flag("elemental_storm_repaired");
    // if (level flag::get("elemental_storm_repaired"))
    // {
    //     t_forge = struct::get("quest_reforge_elemental_storm");
    //     t_forge.var_67b5dd94 notify("trigger", e_player);
    //     while (level scene::is_playing("p7_fxanim_zm_castle_pap_complete_reform_bundle")) {
    //         wait(0.05);
    //     }
    //     wait(0.1);
    //     while (level scene::is_playing("p7_fxanim_zm_castle_quest_storm_arrow_whole_bundle")) {
    //         wait(0.05);
    //     }
    //     wait(0.1);
    //     t_forge.var_67b5dd94 notify("trigger", e_player);
    // }
}

function _prefill_pedestal(bow_name, e_target_player)
{
    pedestal = struct::get("upgraded_bow_struct_" + bow_name, "targetname");
    pedestal.var_67b5dd94 waittill("trigger", e_who);
    if (e_who === e_target_player)
    {
        wait(0.1);
        while (level scene::is_playing("p7_fxanim_zm_castle_quest_pedestal_bundle_" + bow_name)) {
            wait(0.05);
        }
        wait(0.1);
        pedestal.var_ce58f456 = 20; // Prefill pedestal kills
    }
}

function _restore_fire_bow(e_player)
{
    elemental_bow = GetWeapon("elemental_bow");

    // Setting this flag early skips something later
    archi_save::restore_flag("rune_prison_obelisk");

    // Pick up broken arrow
    e_clock = getent("aq_rp_clock_wall_trig", "targetname");
    e_clock notify("damage", 100, e_player, (0, 0, 0), e_clock.origin, undefined, "", "", "", elemental_bow);
    wait GetAnimLength("p7_fxanim_zm_castle_quest_rune_clock_wall_bundle");
    wait(0.1);
    arrow = struct::get("quest_start_rune_prison");
    arrow.var_67b5dd94 notify("trigger", e_player);

    wait(1);
    level flag::wait_till("rune_prison_magma_ball");
    wait(0.1);
    runic_volumes = getentarray("aq_rp_runic_circle_volume", "script_noteworthy");
    foreach(circle in runic_volumes)
    {
        circle_trigger = getent(circle.target + "_trig", "targetname");
        circle_trigger notify("damage", 100, e_player, (0, 0, 0), circle_trigger.origin, undefined, "", "", "", elemental_bow);
        wait(0.1);
        for (i = 0; i < 9; i++)
        {
            circle notify("killed");
            wait(0.05);
        }
    }

    archi_save::restore_flag("rune_prison_golf");
}

function _restore_void_bow(e_player)
{
    elemental_bow = GetWeapon("elemental_bow");

    // Pick up broken arrow
    e_wall = getent("aq_dg_gatehouse_symbol_trig", "targetname");
    e_wall notify("damage", 100, e_player, (0, 0, 0), e_wall.origin, undefined, "", "", "", elemental_bow);
    wait(0.1);
    level notify("hash_c8347a07");
    wait(0.1);
    arrow = struct::get("quest_start_demon_gate");
    arrow.var_67b5dd94 notify("trigger", e_player);

    archi_save::restore_flag("demon_gate_seal");
    if (level flag::get("demon_gate_seal"))
    {
        wait(0.1);
        s_urn = struct::get("aq_dg_urn_struct", "targetname");
        s_urn.var_67b5dd94 notify("trigger", e_player);
        
        fossils = getentarray("aq_dg_fossil", "script_noteworthy");
        foreach(fossil in fossils)
        {
            fossil.var_67b5dd94 notify("trigger", e_player);
        }
        wait(3);
    }

    archi_save::restore_flag("demon_gate_crawlers");
    if (level flag::get("demon_gate_crawlers"))
    {
        align_fossils = getentarray("aq_dg_fossil_align", "script_noteworthy");
        foreach (f in align_fossils)
        {
            f clientfield::set("fossil_reveal", 0);
        }
    }

    archi_save::restore_flag("demon_gate_runes");
}

function _track_player_connection_bow()
{
    storm_bow = GetWeapon("elemental_bow_storm");
    wolf_bow = GetWeapon("elemental_bow_wolf_howl");
    fire_bow = GetWeapon("elemental_bow_rune_prison");
    void_bow = GetWeapon("elemental_bow_demongate");

    if (self hasweapon(storm_bow))
    {
        level flag::set("elemental_storm_upgraded");
        // level thread _prefill_pedestal("elemental_storm", self);
        level thread _restore_storm_bow(self);
        return;
    }
    else if (self hasweapon(wolf_bow))
    {
        level flag::set("wolf_howl_upgraded");
        level thread _restore_wolf_bow(self);
        return;
    }
    else if (self hasweapon(fire_bow))
    {
        level flag::set("rune_prison_upgraded");
        level thread _restore_fire_bow(self);
        return;
    }
    else if (self hasweapon(void_bow))
    {
        level flag::set("demon_gate_upgraded");
        level thread _restore_void_bow(self);
        return;
    }

    xuid = self GetXuid();
    if (level.archi.storm_owner == xuid)
    {
        level thread _restore_storm_bow(self);
    }
    else if (level.archi.wolf_owner == xuid)
    {
        level thread _restore_wolf_bow(self);
    }
    else if (level.archi.fire_owner == xuid)
    {
        level thread _restore_fire_bow(self);
    }
    else if (level.archi.void_owner == xuid)
    {
        level thread _restore_void_bow(self);
    }
}

function _do_bow_steps(val)
{
    if (val != "")
    {
        parts = strtok(val, " ");
        if (parts.size >= 2)
        {
            bow_name = parts[0];
            player_name = parts[1];

            foreach(player in level.players)
            {
                if (player.name == player_name)
                {
                    if (bow_name == "storm")
                    {
                        IPrintLn("Forcing player storm");
                        level thread _restore_storm_bow(player);
                    }
                    if (bow_name == "wolf")
                    {
                        IPrintLn("Forcing player wolf");
                        level thread _restore_wolf_bow(player);
                    }
                    if (bow_name == "void")
                    {
                        IPrintLn("Forcing player void");
                        level thread _restore_void_bow(player);
                    }
                    if (bow_name == "fire")
                    {
                        IPrintLn("Forcing player fire");
                        level thread _restore_fire_bow(player);
                    }
                }
            }
        }
    }
}

function setup_bow_restore()
{
    level flag::wait_till("all_players_spawned");

    // Add element if bow is owned by a player
    foreach (player in level.players)
    {
        player thread _track_player_connection_bow();
    }
    callback::on_connect(&_track_player_connection_bow);

    level thread archi_commands::_basic_trigger("ap_bow", &_do_bow_steps);
    
    wait(0.1);

    // Wait until we have bows for the keeper ai to use
    while(!isdefined(level.a_elements.size) || level.a_elements.size == 0)
    {
        wait(1);
    }

    // Complete simons says sequence to trigger rocket scene
    archi_save::restore_flag("start_channeling_stone_step");
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

function _player_connect()
{
    sync_perk_exploders();
}

function sync_perk_exploders()
{
    wait(0.2);
    if (isdefined(level.archi.active_perk_machines))
    {
        perk_keys = GetArrayKeys(level.archi.active_perk_machines);
        foreach (perk in perk_keys)
        {
            if (level.archi.active_perk_machines[perk] == true)
            {
                switch (perk)
                {
                    case PERK_JUGGERNOG:
                    	level clientfield::set("perk_light_juggernaut", 1);
                        exploder::exploder("lgt_vending_juggernaut_castle");
                        break;
                    case PERK_DOUBLETAP2:
                    	level clientfield::set("perk_light_doubletap", 1);
                        exploder::exploder("lgt_vending_doubletap2_castle");
                        break;
                    case PERK_ADDITIONAL_PRIMARY_WEAPON:
                    	level clientfield::set("perk_light_mule_kick", 1);
                        exploder::exploder("lgt_vending_mule_kick_castle");
                        break;
                    case PERK_QUICK_REVIVE:
                    	level clientfield::set("perk_light_quick_revive", 1);
                        exploder::exploder("lgt_vending_quick_revive_castle");
                        break;
                    case PERK_SLEIGHT_OF_HAND:
                    	level clientfield::set("perk_light_speed_cola", 1);
                        exploder::exploder("lgt_vending_sleight_of_hand_castle");
                        break;
                    case PERK_STAMINUP:
                    	level clientfield::set("perk_light_staminup", 1);
                        exploder::exploder("lgt_vending_stamina_up_castle");
                        break;
                }
            }
            else
            {
                switch (perk)
                {
                    case PERK_JUGGERNOG:
                        level clientfield::set("perk_light_juggernaut", 0);
                        exploder::exploder_stop("lgt_vending_juggernaut_castle");
                        break;
                    case PERK_DOUBLETAP2:
                    	level clientfield::set("perk_light_doubletap", 0);
                        exploder::exploder_stop("lgt_vending_doubletap2_castle");
                        break;
                    case PERK_ADDITIONAL_PRIMARY_WEAPON:
                    	level clientfield::set("perk_light_mule_kick", 0);
                        exploder::exploder_stop("lgt_vending_mule_kick_castle");
                        break;
                    case PERK_QUICK_REVIVE:
                    	level clientfield::set("perk_light_quick_revive", 0);
                        exploder::exploder_stop("lgt_vending_quick_revive_castle");
                        break;
                    case PERK_SLEIGHT_OF_HAND:
                    	level clientfield::set("perk_light_speed_cola", 0);
                        exploder::exploder_stop("lgt_vending_sleight_of_hand_castle");
                        break;
                    case PERK_STAMINUP:
                    	level clientfield::set("perk_light_staminup", 0);
                        exploder::exploder_stop("lgt_vending_stamina_up_castle");
                        break;
                }
            }
        }
    }
}