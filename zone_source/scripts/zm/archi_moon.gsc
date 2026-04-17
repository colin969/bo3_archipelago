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
#using scripts\zm\_zm_equipment;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\zm\archi_core;
#using scripts\zm\archi_save;
#using scripts\zm\archi_commands;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\Zm\_zm_perks.gsh;

#insert scripts\zm\archi_core.gsh;

function save_state_manager()
{
    level.archi.moon_kvals = [];
    level.archi.opened_airlocks = [];
    level.archi.save_state = &save_state;
    level thread archi_save::save_on_round_change();
    level thread archi_save::round_checkpoints();

	airlock_buys = getentarray("zombie_airlock_buy", "targetname");
    for (i = 0; i < airlock_buys.size; i++)
    {
        airlock_buys[i].id = i;
    }
    array::thread_all(airlock_buys, &track_airlock_buy);

    level waittill("end_game");

    if (isdefined(level.host_ended_game) && level.host_ended_game == 1)
    {
        IPrintLn("Host ended game, saving data...");
        save_state();
    } else {
        IPrintLn("Host did not end game, clearing data...");
        clear_state();
    }
}

function track_airlock_buy()
{
    self waittill("door_opened");
    level.archi.opened_airlocks[level.archi.opened_airlocks.size] = self.id;
}

function save_state()
{
    archi_save::save_round_number();
    archi_save::save_zombie_count();
    archi_save::save_power_on();
    archi_save::save_doors_and_debris();
    archi_save::save_spent_tokens();

    save_airlocks();

    archi_save::save_players(&save_player_data);

    save_map_state();

    archi_save::send_save_data("zm_moon");

    if (level.archi.save_checkpoint == true)
    {
        IPrintLnBold("Checkpoint Saved");
    }
}

function save_airlocks()
{
    airlock_str = "";
    foreach (airlock_id in level.archi.opened_airlocks)
    {
        airlock_str += airlock_id + ";";
    }

    SetDvar("ARCHIPELAGO_SAVE_DATA_OPENED_AIRLOCKS", airlock_str);
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
    archi_save::wait_restore_ready("zm_moon");
    level flag::wait_till("ap_attachment_rando_ready");
    archi_save::restore_zombie_count();
    archi_save::restore_round_number();
    if (level.archi.restored_round_number > 1) {
        level.nml_last_round = level.archi.restored_round_number;
    }
    archi_save::restore_power_on();
    archi_save::restore_doors_and_debris();
    restore_airlocks();

    restore_map_state();

    wait(10);
    level flag::clear("ap_prevent_checkpoints");
}

function restore_airlocks()
{
    // Open doors
	airlock_buys = getentarray("zombie_airlock_buy", "targetname");
    airlocks_str = GetDvarString("ARCHIPELAGO_LOAD_DATA_OPENED_AIRLOCKS", "");
    if (airlocks_str != "")
    {
        airlock_ids = strtok(airlocks_str, ";");
        foreach (airlock_id_str in airlock_ids)
        {
            airlock_id = int(airlock_id_str);
            if (isdefined(airlock_buys[airlock_id]))
            {
                airlock_buys[airlock_id] notify("trigger", level.players[0], true);
            }
        }
        SetDvar("ARCHIPELAGO_LOAD_DATA_OPENED_AIRLOCKS", "");
    }
}

// self is player
function restore_player_data(xuid)
{
    level endon("end_game");
    self endon("disconnect");

    if (self archi_save::can_restore_player(xuid))
    {
        self archi_save::restore_player_score(xuid);
        self archi_save::restore_player_perks(xuid);
        self archi_save::restore_player_loadout(xuid);
    }
}

function clear_state()
{
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_moon");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function play_timer_vox(digger_name)
{
    level endon("teleporter_vox_timer_stop");
    time_left = level.diggers_global_time;
    played180sec = 0;
	played120sec = 0;
	played60sec = 0;
	played30sec = 0;
	digger_start_time = gettime();
    while(time_left > 0)
	{
		curr_time = gettime();
		time_used = (curr_time - digger_start_time) / 1000;
		time_left = level.diggers_global_time - time_used;
		if(time_left <= 180 && !played180sec)
		{
			level thread play_mooncomp_vox("vox_mcomp_digger_start_", digger_name);
			played180sec = 1;
		}
		if(time_left <= 120 && !played120sec)
		{
			level thread play_mooncomp_vox("vox_mcomp_digger_start_", digger_name);
			played120sec = 1;
		}
		if(time_left <= 60 && !played60sec)
		{
			level thread play_mooncomp_vox("vox_mcomp_digger_time_60_", digger_name);
			played60sec = 1;
		}
		if(time_left <= 30 && !played30sec)
		{
			level thread play_mooncomp_vox("vox_mcomp_digger_time_30_", digger_name);
			played30sec = 1;
		}
		wait(1);
	}
}

function play_mooncomp_vox(alias, digger)
{
    if (!level.on_the_moon)
    {
        return;
    }
    num = 0; // Teleporter
    level.mooncomp_is_speaking = 1;
    level do_mooncomp_vox(alias + num);
    level.mooncomp_is_speaking = 0;
}

function do_mooncomp_vox(alias)
{
	players = getplayers();
	for(i = 0; i < players.size; i++)
	{
		if(players[i] zm_equipment::is_active(level.var_f486078e))
		{
			players[i] playsoundtoplayer(alias + "_f", players[i]);
		}
	}
	if(!isdefined(level.var_2ff0efb3))
	{
		return;
	}
	foreach(speaker in level.var_2ff0efb3)
	{
		playsoundatposition(alias, speaker.origin);
		wait(0.05);
	}
}

function patch_nml_supersprint()
{
    while(true)
    {
        level flag::wait_till("enter_nml");
        level thread nml_supersprint_timer();
        level flag::wait_till_clear("enter_nml");
    }
}

function nml_supersprint_timer()
{
    level endon("stop_ramp");
    level waittill("start_nml_ramp");
    wait(1);
    while(level flag::get("enter_nml"))
    {
        if (isdefined(level.nml_timer))
        {
            diff = level.nml_timer - level.nml_last_round;
            if (diff >= 5)
            {
                level flag::set("start_supersprint");
                break;
            }
        }
        wait(20);
    }
}

function patch_digger_rng()
{
    while(true)
    {
        level waittill("between_round_over");
        if (level.round_number >= 16)
        {
            wait(2);
            if(level flag::exists("teleporter_used") && level flag::get("teleporter_used"))
            {
                continue;
            }
            if(level flag::get("digger_moving"))
            {
                continue;
            }
            wait(2);
            level flag::set("start_teleporter_digger");
            level thread util::clientnotify("Dz2e");
            wait(1);
            level notify("teleporter_vox_timer_stop");
            level thread play_timer_vox("teleporter");
            return;
        }
    }
}

function customrandomweaponweights(a_keys)
{
    if (level.chest_moves > 0)
    {
        rng_keys = GetArrayKeys(level.ap_moon_box_rng);
        foreach(w_weapon in rng_keys)
        {
            weap_rng = level.ap_moon_box_rng[w_weapon];
            if (weap_rng > 16)
            {
                // More than 16 spins without, add another to the item pool
                a_keys[a_keys.size] = w_weapon;
            }
            if (weap_rng > 8)
            {
                // More than 8 spins without, add another to the item pool
                a_keys[a_keys.size] = w_weapon;
                a_keys = array::randomize(a_keys);
            }
        }
    }

    return a_keys;
}

function any_player_has_equipment(w_weapon)
{
    foreach (player in level.players)
    {
        if (player zm_weapons::has_weapon_or_upgrade(w_weapon))
        {
            return true;
        }
    }
    return false;
}

function func_magicbox_weapon_spawned(w_weapon)
{
    // Weapon spawned, kill its rng adjustment
    if (isdefined(level.ap_moon_box_rng[w_weapon]))
    {
        level.ap_moon_box_rng[w_weapon] = 0;
    }
    else
    {
        if (level.chest_moves > 0)
        {
            // Increase weapon rng adjustment if no player has it
            if (zm_weapons::limited_weapon_below_quota(level.w_microwavegun))
            {
                level.ap_moon_box_rng[level.w_microwavegun]++;
            }

            if (!any_player_has_equipment(level.w_quantum_bomb))
            {
                level.ap_moon_box_rng[level.w_quantum_bomb]++;
            }

            if (!any_player_has_equipment(level.w_black_hole_bomb))
            {
                level.ap_moon_box_rng[level.w_black_hole_bomb]++;
            }
        }
    }
}

function setup_locations()
{
    level flag::wait_till("initial_blackscreen_passed");

    level archi_core::spawn_perk_machine(PERK_PHDFLOPPER, (-670.9, 1675.5, -468.8), (0, 180, 0), PERK_WIDOWS_WINE);
    level thread patch_nml_supersprint();

    // level thread archi_commands::_basic_trigger("ap_ball_print", &show_be_pos);
    // level thread archi_commands::_basic_trigger("ap_nml_print", &debug_nml);

    if (level.archi.difficulty_rng_moon_digger == 1)
    {
        level thread patch_digger_rng();
    }

    if (level.archi.difficulty_rng_moon_box == 1)
    {
        level.ap_moon_box_rng = [];
        level.ap_moon_box_rng[level.w_black_hole_bomb] = 0;
        level.ap_moon_box_rng[level.w_quantum_bomb] = 0;
        level.ap_moon_box_rng[level.w_microwavegun] = 0;
        level.customrandomweaponweights = &customrandomweaponweights;
        level.func_magicbox_weapon_spawned = &func_magicbox_weapon_spawned;
    }

	windows = struct::get_array("exterior_goal", "targetname");
    array::thread_all(windows, &hackable_window);

    level thread _notify_to_location_thread("packapunch_hacked", level.archi.mapString + " Hack the Pack-A-Punch Machine");
    level thread _flag_to_location_thread("override_magicbox_trigger_use", level.archi.mapString + " Hack the Mystery Box");
    level thread _notify_to_location_thread("digger_hacked", level.archi.mapString + " Hack an Excavator");

    level thread _flag_to_location_thread("power_on", level.archi.mapString + " Turn on the Power");

    cushion_sound_triggers = getentarray("trig_cushion_sound", "targetname");
    array::thread_all(cushion_sound_triggers, &safe_landing);

    level thread _notify_kval("sq_ss1_completed", level.archi.mapString + " Main Easter Egg - Samantha Says");
    level thread _notify_kval("release_complete", level.archi.mapString + " Main Easter Egg - Buttons in the Lab");
    level thread _flag_kval("teleporter_breached");
    level thread _notify_kval("complete_be_1", level.archi.mapString + " Main Easter Egg - Transport the Vril Sphere to the MPD");
    level thread _flag_kval("sam_switch_thrown", level.archi.mapString + " Main Easter Egg - Open the MPD");

    level thread _notify_kval("ctvg_tp_done");
    level thread _flag_kval("c_built", level.archi.mapString + " Main Easter Egg - Transport the Hexagonal Plates");
    level thread _flag_kval("w_placed", level.archi.mapString + " Main Easter Egg - Plug in the Computer");
    level thread _flag_kval("vg_placed");
    level thread _notify_kval("kill_press_monitor", level.archi.mapString + " Main Easter Egg - Delete Maxis from the Computer");
    level thread _flag_to_location_thread("second_tanks_charged", level.archi.mapString + " Main Easter Egg - Fill all the MPD Soul Canisters");
    level thread _flag_to_location_thread("soul_swap_done", level.archi.mapString + " Main Easter Egg - Swap Souls");
    level thread _notify_to_location_thread("moon_sidequest_big_bang_achieved", level.archi.mapString + " Main Easter Egg - Nuke the Earth");
    level thread _notify_to_location_thread("moon_sidequest_big_bang_achieved", level.archi.mapString + " Main Easter Egg - Victory");

    level thread _notify_to_location_thread("ap_music_8bit_cominghome", level.archi.mapString + " Music EE - Coming Home 8-Bit");
    level thread _notify_to_location_thread("ap_music_8bit_redamned", level.archi.mapString + " Music EE - Redamned 8-Bit");
    level thread _notify_to_location_thread("ap_music_8bit_pareidolia", level.archi.mapString + " Music EE - Pareidolia 8-Bit");

    level thread space_dog_objects(level.archi.mapString + " Space Dog - Wave Gun Target Practice");
    level thread _flag_kval("sd_hound", level.archi.mapString + " Space Dog - Wave Gun the Toy Hellhound in Area 51");
    level thread _flag_kval("sd_bear", level.archi.mapString + " Space Dog - Wave Gun the Teddy Bear in the Biodome");
    level thread _flag_kval("sd_bone", level.archi.mapString + " Space Dog - Wave Gun the Bone near the Moon Teleporter");
    level thread _flag_to_location_thread("sd_large_complete", level.archi.mapString + " Space Dog - Fill the Dog Bowl with 30 Zombie Souls");
    level thread _flag_to_location_thread("sd_small_complete", level.archi.mapString + " Space Dog - Fill the Dog Bowl with 15 Gas Crawler Souls");

    level thread _flag_to_location_thread("snd_song_completed", level.archi.mapString + " Music EE - Coming Home");
}

function space_dog_objects(location)
{
    s_objects = struct::get_array("sd_start", "script_noteworthy");
    a_flags = [];
    wait(10);
    foreach(s_obj in s_objects)
    {   
        a_flags[a_flags.size] = s_obj.targetname;
    }
    level flag::wait_till_all(a_flags);
}

function safe_landing()
{
    level endon("ap_safe_landing");
    while(true)
    {
        self waittill("trigger", who);
        if(isplayer(who) && (isdefined(who._padded) && who._padded))
        {
           break; 
        }
    }
    archi_core::send_location(level.archi.mapString + " Land safely on a cushion");
    level notify("ap_safe_landing");
}

function hackable_window()
{
    level endon("ap_window_hacked");
    self waittill("blocker_hacked");
    archi_core::send_location(level.archi.mapString + " Hack a Broken Window");
    level notify("ap_window_hacked");
}

// === AP Check Utilities ===

// Collect a check when a level flag gets set
// level thread _flag_to_location_thread("flag", level.archi.mapString + " locationName");
function _flag_to_location_thread(flag, location)
{
    level endon("end_game");

    if (IsArray(flag))
    {
        level flag::wait_till_all(flag);
    }
    else
    {
        level flag::wait_till(flag);
    }
    archi_core::send_location(location);
}

function _flag_kval(flag, location)
{
    level.archi.moon_kvals[flag] = 0;
    level endon("end_game");

    if (IsArray(flag))
    {
        level flag::wait_till_all(flag);
    }
    else
    {
        level flag::wait_till(flag);
    }

    if (isdefined(location))
    {
        archi_core::send_location(location);
    }
    level.archi.moon_kvals[flag] = 1;
}

// Collect a check when a level notification happens
// level thread _notify_to_location_thread("notification", level.archi.mapString + " locationName");
function _notify_to_location_thread(str, location)
{
    level endon("end_game");

    level waittill(str);
    archi_core::send_location(location);
}

function _notify_kval(str, location)
{
    level.archi.moon_kvals[str] = 0;
    level endon("end_game");

    level waittill(str);
    if (isdefined(location))
    {
        archi_core::send_location(location);
    }

    level.archi.moon_kvals[str] = 1;
}

function save_map_state()
{
    save_moon_kval("sq_ss1_completed");
    save_moon_kval("release_complete");
    save_moon_kval("teleporter_breached");
    save_moon_kval("complete_be_1");
    save_moon_kval("sam_switch_thrown");
    save_moon_kval("c_built");
    save_moon_kval("w_placed");
    save_moon_kval("vg_placed");
    save_moon_kval("ctvg_tp_done");
    save_moon_kval("kill_press_monitor");

    save_moon_kval("sd_hound");
    save_moon_kval("sd_bear");
    save_moon_kval("sd_bone");
}

function save_moon_kval(key)
{
    archi_save::save_val(key, level.archi.moon_kvals[key]);
}

function debug_nml()
{
    IPrintLn("nml_timer: " + level.nml_timer);
    IPrintLn("nml round: " + level.nml_last_round);
}

function restore_map_state()
{
    restore_moon_kval("sq_ss1_completed");
    restore_moon_kval("release_complete");
    restore_moon_kval("teleporter_breached");
    restore_moon_kval("complete_be_1");
    restore_moon_kval("sam_switch_thrown");
    restore_moon_kval("c_built");
    restore_moon_kval("w_placed");
    restore_moon_kval("vg_placed");
    restore_moon_kval("ctvg_tp_done");
    restore_moon_kval("kill_press_monitor");

    restore_moon_kval("sd_hound");
    restore_moon_kval("sd_bear");
    restore_moon_kval("sd_bone");

    level flag::init("ap_restore_ee1");
    level flag::init("ap_restore_ee2");
    level flag::init("ap_restore_computer");

    level restore_space_dog();

    level thread restore_ee1();
    level thread restore_ee2();
    level thread restore_computer();

    level flag::wait_till_all(array("ap_restore_ee1", "ap_restore_ee2", "ap_restore_computer")); 
}

function restore_ee1()
{
    if (has_moon_kval("sq_ss1_completed"))
    {
        level flag::wait_till("power_on");
        wait(1);
        while(true)
        {
            if (isdefined(level._ss_sequence_matched))
            {
                break;
            }
            wait(0.1);
        }
        wait(0.1);
        sq_struct = level._zombie_sidequests["sq"].stages["ss1"];
        level flag::wait_till_clear("displays_active");
        level._ss_sequence_matched = 1;
        sq_struct notify("ss_won");

        wait(0.1);
        level flag::set("ss1");
        wait(0.1);
    }

    if (has_moon_kval("release_complete"))
    {
        // So finnicky for lab buttons to properly trigger electric switch later
        level flag::set(level._osc_flags[1]);
        wait(0.1);
        // Trigger success
        level flag::set(level._osc_flags[9]);
        wait(0.1);
        // Cleanup any running older stuff?
        level flag::set(level._osc_flags[8]);
        wait(0.1);

        level notify("sq_osc_over");
        wait(0.1);
    }

    if(has_moon_kval("teleporter_breached"))
    {
        level flag::set("teleporter_breached");
        wait(0.2);
    }

    if(has_moon_kval("complete_be_1"))
    {
        // Detach ball from vehicle
        level._be Unlink();

        // Move to MPD pos
        level._be.origin = (43.99, 3760.5, -541.3);
        level._be.angles = (0, 180.8, 74.74);
        // s = struct::get("be2_pos", "targetname");
        // level._be.origin = s.origin;

        // Set flag and move it into position
        level flag::set("complete_be_1");
        wait(0.1);
    }

    if(has_moon_kval("sam_switch_thrown"))
    {
        // Fill tanks
        while(level._active_tanks.size < 1)
        {
            wait(0.1);
        }
        foreach (tank in level._active_tanks)
        {
            tank.fill = tank.max_fill;
        }
        // Just brute force the timing of the electric switch for the MPD
        elec_switch = getent("use_tank_switch", "targetname");
        while (!level flag::get("sam_switch_thrown"))
        {
            elec_switch notify("trigger");
            wait(0.2);
        }
        level waittill("walls_down");
        level.archi.blocked_powerups["minigun"] = true;
        level thread delayed_minigun_restore();
    }

    level flag::set("ap_restore_ee1");
}

function restore_ee2()
{
    // Wait for computer setup and ee part 1 to be done
    level flag::wait_till_all(array("ap_restore_ee1", "ap_restore_computer"));

    if (has_moon_kval("kill_press_monitor"))
    {
        richtofen = undefined;
        for(i = 0; i < level.players.size; i++)
        {
            player = level.players[i];
            ent_num = player.characterindex;
            if(isdefined(player.zm_random_char))
            {
                ent_num = player.zm_random_char;
            }
            if(ent_num == 2)
            {
                richtofen = level.players[i];
                break;
            }
        }

        // Wipe charge stages to force finish on next end
        while( !isdefined(level._charge_stages) )
        {
            wait(0.1);
        }
        level._charge_stages = [];

        // Finish charge stage
        level._charge_sound_ent notify("press");
        wait(0.1);
    }
}

function delayed_minigun_restore()
{
    wait(1);
    level.archi.blocked_powerups["minigun"] = false;
}

function restore_computer()
{
    level flag::init("ap_restore_plates_grenade");

    if (has_moon_kval("ctvg_tp_done"))
    {
        plates = getentarray("sq_cassimir_plates", "targetname");
	    trig = getent("sq_cassimir_trigger", "targetname");

        // Knock plates down
        while(!level flag::get("ap_restore_plates_grenade"))
        {
            trig notify("damage", 1, level.players[0], (0, 0, 0), (0, 0, 0), "MOD_PROJECTILE", "", "");
            wait(0.2);
        }
        WAIT_SERVER_FRAME
        level notify("ctvg_tp_done");
    }

    if (has_moon_kval("c_built"))
    {
        level thread plates_grenade_watcher();
        
        // We NEED to wait for a player to go to the moon now, otherwise we break nml logic
        targs = struct::get_array("sq_ctvg_tp2", "targetname");
        for(i = 0; i < plates.size; i++)
        {
            plates[i] dontinterpolate();
            plates[i].origin = targs[i].origin;
            plates[i].angles = targs[i].angles;
        }
        level waittill("restart_round");
        WAIT_SERVER_FRAME
        level notify("ctvg_validation");
        level flag::wait_till("c_built");
    }

    if (has_moon_kval("w_placed"))
    {
        // Brute force find the spawned wire?
        entities = GetEntArray("script_model", "classname");
        foreach(ent in entities)
        {
            if(ent.model == "p7_zm_moo_computer_rocket_launch_wire")
            {
                // Found wire
                ent notify("pickedup_wire", level.players[0]);
                break;
            }
        }
        wait(0.1);
        wire_struct = struct::get("sq_wire_final", "targetname");
        wire_struct notify("placed_wire", level.players[0]);

        level flag::wait_till("w_placed");
    }

    if(has_moon_kval("vg_placed"))
    {
        wait(0.1);
        vg_struct = struct::get("sq_charge_vg_pos", "targetname");
        vg_struct notify("vg_placed", level.players[0]);
        WAIT_SERVER_FRAME
    }

    level flag::set("ap_restore_computer");
}

function restore_space_dog()
{
    sd_structs = struct::get_array("sd_start", "script_noteworthy");
    foreach (sd_struct in sd_structs)
    {
        if (has_moon_kval(sd_struct.targetname))
        {
            t_toy = ArrayGetClosest(sd_struct.origin, GetEntArray("trigger_damage", "classname"), 1);
            if (!isdefined(t_toy))
            {
                IPrintLn("Could not find toy trigger");
            }
            t_toy notify("microwaved");
        }
    }
}

function plates_grenade_watcher()
{
    level waittill("stage_1_done");
    level flag::set("ap_restore_plates_grenade");
}

function restore_moon_kval(key)
{
    level.archi.moon_kvals[key] = archi_save::restore_val_bool(key);
}

function has_moon_kval(key)
{
    if (isdefined(level.archi.moon_kvals[key]) && level.archi.moon_kvals[key] != 0)
    {
        return true;
    }
    return false;
}

function show_be_pos()
{
    IPrintLn(level._be.origin);
    IPrintLn(level._be.angles);
}
