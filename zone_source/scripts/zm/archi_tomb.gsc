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
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\zm\archi_core;
#using scripts\zm\archi_items;
#using scripts\zm\archi_save;
#using scripts\zm\archi_commands;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\archi_core.gsh;

function save_state_manager()
{
    level.archi.map_kvals = [];
    level.archi.save_state = &save_state;
    level thread archi_save::save_on_round_change();
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

function save_state()
{
    archi_save::save_round_number();
    archi_save::save_zombie_count();
    archi_save::save_power_on();
    archi_save::save_doors_and_debris();
    archi_save::save_spent_tokens();

    archi_save::save_players(&save_player_data);

    save_map_state();

    archi_save::send_save_data("zm_tomb");

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

function load_state()
{
    archi_save::wait_restore_ready("zm_tomb");
    level flag::wait_till("ap_attachment_rando_ready");
    archi_save::restore_zombie_count();
    archi_save::restore_round_number();
    archi_save::restore_power_on();
    archi_save::restore_doors_and_debris();

    restore_map_state();

    wait(10);
    level flag::clear("ap_prevent_checkpoints");
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

    w_beacon = getweapon("beacon");
    loadout = self zm_weapons::player_get_loadout();
    m_weapon = self zm_utility::get_player_melee_weapon();
    if (isdefined(m_weapon) && IsSubStr(m_weapon.name, "one_inch_punch") && m_weapon.name != "one_inch_punch")
    {
        parts = StrTok(m_weapon.name, "_");
        self.b_punch_upgraded = 1;
        self.str_punch_element = parts[3];
        all_upgraded = 1;
        foreach(player in level.players)
		{
			if(!isdefined(player.b_punch_upgraded) || !player.b_punch_upgraded)
			{
				all_upgraded = 0;
			}
		}
        if (all_upgraded == 1)
        {
            level flag::set("ee_all_players_upgraded_punch");
        }
    }
    foreach (weapon_data in loadout)
    {
        if (weapon_data.weapon.name == w_beacon.name)
        {
            self.beacon_ready = 1;
            if(isdefined(level.zombie_include_weapons[w_beacon]) && !level.zombie_include_weapons[w_beacon])
			{
				level.zombie_include_weapons[w_beacon] = 1;
				level.zombie_weapons[w_beacon].is_in_box = 1;
			}
        }
    }
}

function clear_state()
{
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_tomb");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function setup_locations()
{
	a_boxes = getentarray("foot_box", "script_noteworthy");
    id = 0;
    foreach (box in a_boxes)
    {
        box.ap_id = id;
        id++;
    }

    level.archi.map_kvals["_craftable_gramophone_vinyl_player"] = 0;
    level.archi.map_kvals["_craftable_gramophone_vinyl_master"] = 0;

    level.archi.map_kvals["_craftable_elemental_staff_water_upper_staff"] = 0;
    level.archi.map_kvals["_craftable_elemental_staff_water_middle_staff"] = 0;
    level.archi.map_kvals["_craftable_elemental_staff_water_lower_staff"] = 0;

    level.archi.map_kvals["_craftable_elemental_staff_fire_upper_staff"] = 0;
    level.archi.map_kvals["_craftable_elemental_staff_fire_middle_staff"] = 0;
    level.archi.map_kvals["_craftable_elemental_staff_fire_lower_staff"] = 0;

    level.archi.map_kvals["_craftable_elemental_staff_air_upper_staff"] = 0;
    level.archi.map_kvals["_craftable_elemental_staff_air_middle_staff"] = 0;
    level.archi.map_kvals["_craftable_elemental_staff_air_lower_staff"] = 0;

    level.archi.map_kvals["_craftable_elemental_staff_lightning_upper_staff"] = 0;
    level.archi.map_kvals["_craftable_elemental_staff_lightning_middle_staff"] = 0;
    level.archi.map_kvals["_craftable_elemental_staff_lightning_lower_staff"] = 0;

    level flag::wait_till("initial_blackscreen_passed");

    level thread archi_commands::_basic_trigger("ap_gem_print", &print_gem_targets);
    level thread archi_commands::_basic_trigger("ap_solve_staff", &debug_solve_staff);
    level thread archi_commands::_basic_trigger("ap_build_staff", &restore_staff_built);
    level thread archi_commands::_basic_trigger("ap_generator", &start_generator);

    level thread watch_teleports();
    level thread watch_mound_opened();
    level thread watch_generators();

    level thread _notify_kval("elemental_staff_air_crafted", level.archi.mapString + " Wind Staff - Craft the Staff");
    level thread _flag_kval("air_puzzle_1_complete", level.archi.mapString + " Wind Staff - Solve the Crazy Place Puzzle");
    level thread _flag_kval("air_puzzle_2_complete", level.archi.mapString + " Wind Staff - Redirect all the Smoke Stacks");
    level thread _flag_kval("staff_air_upgrade_unlocked", level.archi.mapString + " Wind Staff - Send the Orb to the Crazy Place");
    level thread _watch_staff_upgraded("staff_air", level.archi.mapString + " Wind Staff - Upgrade the Staff");

    level thread _notify_kval("elemental_staff_fire_crafted", level.archi.mapString + " Fire Staff - Craft the Staff");
    level thread _flag_kval("fire_puzzle_1_complete", level.archi.mapString + " Fire Staff - Light the Crazy Place Braziers");
    level thread _flag_kval("fire_puzzle_2_complete", level.archi.mapString + " Fire Staff - Solve the Church Torch Puzzle");
    level thread _flag_kval("staff_fire_upgrade_unlocked", level.archi.mapString + " Fire Staff - Send the Orb to the Crazy Place");
    level thread _watch_staff_upgraded("staff_fire", level.archi.mapString + " Fire Staff - Upgrade the Staff");

    level thread _notify_kval("elemental_staff_lightning_crafted", level.archi.mapString + " Lightning Staff - Craft the Staff");
    level thread _flag_kval("electric_puzzle_1_complete", level.archi.mapString + " Lightning Staff - Solve the Crazy Place Piano Puzzle");
    level thread _flag_kval("electric_puzzle_2_complete", level.archi.mapString + " Lightning Staff - Correctly set the Electrical Boxes");
    level thread _flag_kval("staff_lightning_upgrade_unlocked", level.archi.mapString + " Lightning Staff - Send the Orb to the Crazy Place");
    level thread _watch_staff_upgraded("staff_lightning", level.archi.mapString + " Lightning Staff - Upgrade the Staff");

    level thread _notify_kval("elemental_staff_water_crafted", level.archi.mapString + " Ice Staff - Craft the Staff");
    level thread _flag_kval("ice_puzzle_1_complete", level.archi.mapString + " Ice Staff - Solve the Crazy Place Puzzle");
    level thread _flag_kval("ice_puzzle_2_complete", level.archi.mapString + " Ice Staff - Smash the Three Gravestones");
    level thread _flag_kval("staff_water_upgrade_unlocked", level.archi.mapString + " Ice Staff - Send the Orb to the Crazy Place");
    level thread _watch_staff_upgraded("staff_water", level.archi.mapString + " Ice Staff - Upgrade the Staff");

    level thread _flag_kval("ee_all_staffs_upgraded", level.archi.mapString + " Main Easter Egg - Upgrade all Elemental Staffs");
    level thread _flag_kval("ee_all_staffs_placed", level.archi.mapString + " Main Easter Egg - Placed all 4 Upgraded Elemental Staffs");
    level thread _flag_kval("ee_mech_zombie_hole_opened", level.archi.mapString + " Main Easter Egg - Blow open the Panzer Hole");
    level thread _flag_kval("ee_maxis_drone_retrieved", level.archi.mapString + " Main Easter Egg - Retrieve Maxis Drone from Zombie Blood Plane");
    level thread _flag_kval("ee_souls_absorbed", level.archi.mapString + " Main Easter Egg - Charge the Mound with Souls");
    level thread _flag_to_location_thread("ee_samantha_released", level.archi.mapString + " Main Easter Egg - Send Maxis to Samantha");
    level thread _flag_to_location_thread("ee_samantha_released", level.archi.mapString + " Main Easter Egg - Victory");

    level thread _flag_kval("ee_all_players_upgraded_punch");
    level thread _flag_kval("ee_mech_zombie_fight_completed");
}

function watch_generators()
{
    level.archi.map_kvals["generator_start_bunker"] = 0;
    level.archi.map_kvals["generator_tank_trench"] = 0;
    level.archi.map_kvals["generator_mid_trench"] = 0;
    level.archi.map_kvals["generator_nml_right"] = 0;
    level.archi.map_kvals["generator_nml_left"] = 0;
    level.archi.map_kvals["generator_church"] = 0;

    while(true)
    {
        level waittill("zone_captured_by_player", zone);
        level.archi.map_kvals[zone] = 1;
        count = get_captured_zone_count();
        if (count == 1)
        {
            archi_core::send_location(level.archi.mapString + " Power up any Generator");
        }
        if (count == 3)
        {
            archi_core::send_location(level.archi.mapString + " Power up 3 Generators");
        }
        if (count == 6)
        {
            archi_core::send_location(level.archi.mapString + " Power up all 6 Generators");
            break;
        }
    }
}

function watch_mound_opened()
{
    level.archi.map_kvals["crypt_opened"] = 0;
    level flag::wait_till("crypt_opened");
    level.archi.map_kvals["crypt_opened"] = 1;
}

function watch_teleports()
{
    for (i = 1; i < 5; i++)
    {
        level.archi.map_kvals["teleporter_used_" + i] = 0;
    }
    while(true)
    {
        level waittill("player_teleported", who, num);
        level.archi.map_kvals["teleporter_used_" + num] = 1;
    }
}

function _watch_staff_upgraded(staff, location)
{
    level flag::wait_till(staff + "_upgrade_unlocked");
    s_staff = level.a_elemental_staffs[staff];
    while(true)
    {
        if (s_staff.charger.charges_received >= 20)
        {
            break;
        }
        wait(1);
    }
    archi_core::send_location(location);
}

// === AP Check Utilities ===

// Collect a check when a level flag gets set
// If an array is given it will wait for all flags to be set
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
    level.archi.map_kvals[flag] = 0;
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
    level.archi.map_kvals[flag] = 1;
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
    level.archi.map_kvals[str] = 0;
    level endon("end_game");

    level waittill(str);
    if (isdefined(location))
    {
        archi_core::send_location(location);
    }

    level.archi.map_kvals[str] = 1;
}

function save_map_state()
{
    save_map_kval("ee_all_staffs_placed");
    save_map_kval("ee_mech_zombie_fight_completed");
    save_map_kval("ee_maxis_drone_retrieved");
    save_map_kval("ee_all_players_upgraded_punch");
    save_map_kval("ee_souls_absorbed");

    save_map_kval("generator_start_bunker");
    save_map_kval("generator_tank_trench");
    save_map_kval("generator_mid_trench");
    save_map_kval("generator_nml_right");
    save_map_kval("generator_nml_left");
    save_map_kval("generator_church");

    // Part pickups that aren't AP items
    save_map_kval("_craftable_gramophone_vinyl_player");
    save_map_kval("_craftable_gramophone_vinyl_master");

    save_map_kval("_craftable_elemental_staff_water_upper_staff");
    save_map_kval("_craftable_elemental_staff_water_middle_staff");
    save_map_kval("_craftable_elemental_staff_water_lower_staff");

    save_map_kval("_craftable_elemental_staff_fire_upper_staff");
    save_map_kval("_craftable_elemental_staff_fire_middle_staff");
    save_map_kval("_craftable_elemental_staff_fire_lower_staff");

    save_map_kval("_craftable_elemental_staff_air_upper_staff");
    save_map_kval("_craftable_elemental_staff_air_middle_staff");
    save_map_kval("_craftable_elemental_staff_air_lower_staff");

    save_map_kval("_craftable_elemental_staff_lightning_upper_staff");
    save_map_kval("_craftable_elemental_staff_lightning_middle_staff");
    save_map_kval("_craftable_elemental_staff_lightning_lower_staff");

    // Has used teleporter (reveals gem)
    save_map_kval("teleporter_used_1");
    save_map_kval("teleporter_used_2");
    save_map_kval("teleporter_used_3");
    save_map_kval("teleporter_used_4");
    save_map_kval("crypt_opened");

    // Ice Staff
    save_map_kval("elemental_staff_water_crafted");
    save_map_kval("ice_puzzle_1_complete");
    save_map_kval("ice_puzzle_2_complete");
    save_map_kval("staff_water_upgrade_unlocked");
    level.archi.map_kvals["staff_water_upgrade_charges"] = level.a_elemental_staffs["staff_water"].charger.charges_received;
    save_map_kval("staff_water_upgrade_charges");
    
    // Fire Staff
    save_map_kval("elemental_staff_fire_crafted");
    save_map_kval("fire_puzzle_1_complete");
    save_map_kval("fire_puzzle_2_complete");
    save_map_kval("staff_fire_upgrade_unlocked");
    level.archi.map_kvals["staff_fire_upgrade_charges"] = level.a_elemental_staffs["staff_fire"].charger.charges_received;
    save_map_kval("staff_fire_upgrade_charges");
    
    // Air/Wind Staff
    save_map_kval("elemental_staff_air_crafted");
    save_map_kval("air_puzzle_1_complete");
    save_map_kval("air_puzzle_2_complete");
    save_map_kval("staff_air_upgrade_unlocked");
    level.archi.map_kvals["staff_air_upgrade_charges"] = level.a_elemental_staffs["staff_air"].charger.charges_received;
    save_map_kval("staff_air_upgrade_charges");
    
    // Lightning Staff
    save_map_kval("elemental_staff_lightning_crafted");
    save_map_kval("electric_puzzle_1_complete");
    save_map_kval("electric_puzzle_2_complete");
    save_map_kval("staff_lightning_upgrade_unlocked");
    level.archi.map_kvals["staff_lightning_upgrade_charges"] = level.a_elemental_staffs["staff_lightning"].charger.charges_received;
    save_map_kval("staff_lightning_upgrade_charges");

    a_boxes = getentarray("foot_box", "script_noteworthy");
    for(i = 0; i < 4; i++)
    {
        foreach (box in a_boxes)
        {
            level.archi.map_kvals["box_souls" + box.ap_id] = box.n_souls_absorbed;
            save_map_kval("box_souls" + box.ap_id);
            continue;
        }
        level.archi.map_kvals["box_souls" + i] = 30;
        save_map_kval("box_souls" + i);
    }
}

function restore_nonap_piece(craftable_name, piece_name)
{
    restore_map_kval("_craftable_" + craftable_name + "_" + piece_name);
    if (has_map_kval("_craftable_" + craftable_name + "_" + piece_name))
    {
        archi_items::give_piece(craftable_name, piece_name);
    }
}

function restore_power_generator(str_generator)
{
    restore_map_kval(str_generator);
    if (has_map_kval(str_generator))
    {
        start_generator(str_generator);
    }
}

function restore_map_state()
{
    restore_map_kval("ee_all_staffs_placed");
    if (has_map_kval("ee_all_staffs_placed"))
    {
        level flag::set("ee_all_staffs_placed");
    }
    restore_map_kval("ee_mech_zombie_fight_completed");
    if (has_map_kval("ee_mech_zombie_fight_completed"))
    {
        level flag::set("ee_mech_zombie_fight_completed");
        level flag::set("ee_mech_zombie_hole_opened");
    }
    restore_map_kval("ee_maxis_drone_retrieved");
    if (has_map_kval("ee_maxis_drone_retrieved"))
    {
        level flag::set("ee_maxis_drone_retrieved");
    }
    restore_map_kval("ee_all_players_upgraded_punch");
    if (has_map_kval("ee_all_players_upgraded_punch"))
    {
        level flag::set("ee_all_players_upgraded_punch");
    }
    restore_map_kval("ee_souls_absorbed");
    if (has_map_kval("ee_souls_absorbed"))
    {
        level flag::set("ee_souls_absorbed");
    }

    restore_power_generator("generator_start_bunker");
    restore_power_generator("generator_tank_trench");
    restore_power_generator("generator_mid_trench");
    restore_power_generator("generator_nml_right");
    restore_power_generator("generator_nml_left");
    restore_power_generator("generator_church");

    // Part pickups that aren't AP items
    restore_nonap_piece("gramophone", "vinyl_player");
    restore_nonap_piece("gramophone", "vinyl_master");

    restore_nonap_piece("elemental_staff_water", "upper_staff");
    restore_nonap_piece("elemental_staff_water", "middle_staff");
    restore_nonap_piece("elemental_staff_water", "lower_staff");

    restore_nonap_piece("elemental_staff_fire", "upper_staff");
    restore_nonap_piece("elemental_staff_fire", "middle_staff");
    restore_nonap_piece("elemental_staff_fire", "lower_staff");

    restore_nonap_piece("elemental_staff_air", "upper_staff");
    restore_nonap_piece("elemental_staff_air", "middle_staff");
    restore_nonap_piece("elemental_staff_air", "lower_staff");

    restore_nonap_piece("elemental_staff_lightning", "upper_staff");
    restore_nonap_piece("elemental_staff_lightning", "middle_staff");
    restore_nonap_piece("elemental_staff_lightning", "lower_staff");

    // Has used teleporter (reveals gem)
    restore_map_kval("teleporter_used_1");
    restore_map_kval("teleporter_used_2");
    restore_map_kval("teleporter_used_3");
    restore_map_kval("teleporter_used_4");
    restore_map_kval("crypt_opened");
    // Trigger teleport funcs - MUST BE BEFORE STAFF RESTORE
    restore_teleports();
    wait(1);
    level thread restore_crypt_opened();

    // Ice Staff
    restore_map_kval_int("staff_water_upgrade_charges");
    restore_map_kval("elemental_staff_water_crafted");
    if (has_map_kval("elemental_staff_water_crafted"))
    {
        piecespawn = zm_craftables::get_craftable_piece("elemental_staff_water", "gem");
        piecespawn zm_craftables::piece_unspawn();
        archi_items::give_piece("gramophone", "vinyl_ice");
        WAIT_SERVER_FRAME
        restore_staff_built("elemental_staff_water");
        WAIT_SERVER_FRAME
    }
    restore_map_kval("ice_puzzle_1_complete");
    restore_map_kval("ice_puzzle_2_complete");
    restore_map_kval("staff_water_upgrade_unlocked");
    
    // Fire Staff
    restore_map_kval_int("staff_fire_upgrade_charges");
    restore_map_kval("elemental_staff_fire_crafted");
    if (has_map_kval("elemental_staff_fire_crafted"))
    {
        piecespawn = zm_craftables::get_craftable_piece("elemental_staff_fire", "gem");
        piecespawn zm_craftables::piece_unspawn();
        archi_items::give_piece("gramophone", "vinyl_fire");
        WAIT_SERVER_FRAME
        restore_staff_built("elemental_staff_fire");
        WAIT_SERVER_FRAME
    }
    restore_map_kval("fire_puzzle_1_complete");
    restore_map_kval("fire_puzzle_2_complete");
    restore_map_kval("staff_fire_upgrade_unlocked");
    
    // Air/Wind Staff
    restore_map_kval_int("staff_air_upgrade_charges");
    restore_map_kval("elemental_staff_air_crafted");
    if (has_map_kval("elemental_staff_air_crafted"))
    {
        piecespawn = zm_craftables::get_craftable_piece("elemental_staff_air", "gem");
        piecespawn zm_craftables::piece_unspawn();
        archi_items::give_piece("gramophone", "vinyl_air");
        WAIT_SERVER_FRAME
        restore_staff_built("elemental_staff_air");
        WAIT_SERVER_FRAME
    }
    restore_map_kval("air_puzzle_1_complete");
    restore_map_kval("air_puzzle_2_complete");
    restore_map_kval("staff_air_upgrade_unlocked");
    
    // Lightning Staff
    restore_map_kval_int("staff_lightning_upgrade_charges");
    restore_map_kval("elemental_staff_lightning_crafted");
    if (has_map_kval("elemental_staff_lightning_crafted"))
    {
        piecespawn = zm_craftables::get_craftable_piece("elemental_staff_lightning", "gem");
        piecespawn zm_craftables::piece_unspawn();
        archi_items::give_piece("gramophone", "vinyl_elec");
        WAIT_SERVER_FRAME
        restore_staff_built("elemental_staff_lightning");
        WAIT_SERVER_FRAME
    }
    restore_map_kval("electric_puzzle_1_complete");
    restore_map_kval("electric_puzzle_2_complete");
    restore_map_kval("staff_lightning_upgrade_unlocked");

    level.archi.staff_restore_id = 0;
    level thread restore_air_staff();
    level thread restore_fire_staff();
    level thread restore_lightning_staff();
    level thread restore_ice_staff();

    a_boxes = getentarray("foot_box", "script_noteworthy");
    foreach (box in a_boxes)
    {
        restore_map_kval_int("box_souls" + box.ap_id);
        souls_absorbed = get_map_kval("box_souls" + box.ap_id);
        box.n_souls_absorbed = souls_absorbed;
        if (box.n_souls_absorbed >= 30)
        {
            box notify("soul_absorbed", level.players[0]);
        }
        else if (box.n_souls_absorbed >= 1)
        {
            box thread scene::play("p7_fxanim_zm_ori_challenge_box_open_bundle", box);
            box util::delay(1, undefined, &clientfield::set, "foot_print_box_glow", 1);
        }
    }
}

function restore_staff_built(craftable_name)
{
    IPrintLn("restoring " + craftable_name);
    craftable = zm_craftables::find_craftable_stub(craftable_name);
    foreach (s_piece in craftable.a_piecestubs)
    {
        level.players[0] zm_craftables::player_take_piece(s_piece.piecespawn);
        WAIT_SERVER_FRAME
    }

    zm_craftables::complete_craftable(craftable_name);
    // WAIT_SERVER_FRAME

    player = level.players[0];
	// zm_unitrigger::complete_craftable doesn't like things that aren't open tables!
    foreach (uts_craftable in level.a_uts_craftables)
    {
        if (uts_craftable.craftablestub.name == craftable_name)
        {
            // Restart craftable place think
            // Don't call onfullycrafted, the place think will do it itself after restarting!
            zm_unitrigger::unregister_unitrigger(uts_craftable);
            WAIT_SERVER_FRAME
            zm_unitrigger::register_static_unitrigger(uts_craftable, &zm_craftables::craftable_place_think);
            break;
        }
    }
}

function get_staff_info_from_element_index(n_index)
{
	foreach (s_staff in level.a_elemental_staffs)
	{
		if(s_staff.enum == n_index)
		{
			return s_staff;
		}
	}
	return undefined;
}

function restore_crypt_opened()
{
    if (has_map_kval("crypt_opened"))
    {
        // a_door_main = getentarray("chamber_entrance", "targetname");
        // main_door = a_door_main[1];
        // trig_position = struct::get(main_door.targetname + "_position", "targetname");
        // t_door = trig_position.trigger;

        // // Unregister gramophone trigger
        // zm_unitrigger::unregister_unitrigger(t_door);

        // // Remove blockers
        // a_blockers = getentarray("junk_nml_chamber", "targetname");
        // m_blocker = getent("junk_nml_chamber", "targetname");
        // s_blocker_end = struct::get(m_blocker.script_linkto, "script_linkname");
        // m_blocker thread zm_blockers::debris_move(s_blocker_end);
        // m_blocker_clip = getent("junk_nml_chamber_clip", "targetname");
        // m_blocker_clip connectpaths();
        // m_blocker waittill(#"movedone");
        // m_blocker_clip delete();

        // // Cleanup
        // level clientfield::set("crypt_open_exploder", 1);

        // main_door movez(-260, 10, 1, 1);
        // main_door waittill("move_done");

        // a_door_main[0] connectpaths();
        // a_door_main delete();

        // main_door delete();
    }
}

function restore_teleports()
{
    for (i = 1; i < 5; i++)
    {
        notif = "teleporter_used_" + i;
        if (has_map_kval(notif))
        {
            level notify("player_teleported", level.players[0], i);
            WAIT_SERVER_FRAME
        }
    }
}

function restore_air_staff()
{
    w_staff = getweapon("staff_air");

    staff = level.a_elemental_staffs["staff_air"];
    staff.charger.charges_received = get_map_kval("staff_air_upgrade_charges");

    if(has_map_kval("air_puzzle_1_complete"))
    {
        level flag::set("air_puzzle_1_complete");
        WAIT_SERVER_FRAME
    }


    if(has_map_kval("air_puzzle_2_complete"))
    {
        a_smoke_pos = struct::get_array("puzzle_smoke_origin", "targetname");
        foreach (a_smoke in a_smoke_pos)
        {
            a_smoke.solved = 1;
        }
        WAIT_SERVER_FRAME
        level notify("air_puzzle_smoke_solved");
        level flag::wait_till("air_puzzle_2_complete");
    }

    if(has_map_kval("staff_air_upgrade_unlocked"))
    {
        // while(true)
        // {
        //     if (level.archi.staff_restore_id == 0)
        //     {
        //         break;
        //     }
        //     wait(0.1);
        // }
        // // Set up the discs
        // set_discs_for_gem("crypt_gem_air");
        // wait(0.1);
        // // Charge orb
        // e_model = get_crypt_orb("crypt_gem_air");
        // e_model notify("damage", 1, level.players[0], (0, 0, 0), (0, 0, 0), "", "", "", "", w_staff);
        // level flag::wait_till("staff_air_upgrade_unlocked");
        level flag::set("staff_air_upgrade_unlocked");
    }
    level.archi.staff_restore_id++;
}

function restore_lightning_staff()
{
    w_staff = getweapon("staff_lightning");

    staff = level.a_elemental_staffs["staff_lightning"];
    staff.charger.charges_received = get_map_kval("staff_lightning_upgrade_charges");

    if(has_map_kval("electric_puzzle_1_complete"))
    {
        // Force solve the piano puzzle
        a_chord_order = array("a_minor", "e_minor", "d_minor");
        foreach(chord_name in a_chord_order)
        {
            s_chord = struct::get("piano_chord_" + chord_name, "script_noteworthy");
            level.a_piano_keys_playing = array(s_chord.notes[0], s_chord.notes[1], s_chord.notes[2]);
            
            level notify("piano_key_played");
            wait(0.1);
        }
        level flag::set("electric_puzzle_1_complete");
    }


    if(has_map_kval("electric_puzzle_2_complete"))
    {
        level flag::set("electric_puzzle_2_complete");
    }

    if(has_map_kval("staff_lightning_upgrade_unlocked"))
    {
        // while(true)
        // {
        //     if (level.archi.staff_restore_id == 1)
        //     {
        //         break;
        //     }
        //     wait(0.1);
        // }
        // // Set up the discs
        // set_discs_for_gem("crypt_gem_elec");
        // wait(0.1);
        // // Charge orb
        // e_model = get_crypt_orb("crypt_gem_elec");
        // e_model notify("damage", 1, level.players[0], (0, 0, 0), (0, 0, 0), "", "", "", "", w_staff);
        // level flag::wait_till("staff_lightning_upgrade_unlocked");
        level flag::set("staff_lightning_upgrade_unlocked");
    }
    level.archi.staff_restore_id++;
}

function restore_fire_staff()
{
    w_staff = getweapon("staff_fire");

    staff = level.a_elemental_staffs["staff_fire"];
    staff.charger.charges_received = get_map_kval("staff_fire_upgrade_charges");

    if(has_map_kval("fire_puzzle_1_complete"))
    {
        level flag::set("flame_on");
	    foreach (vol in level.sacrifice_volumes)
        {
            vol.b_gods_pleased = 1;
        }
        level notify("fire_sacrifice_completed");
        wait(0.1);
    }


    if(has_map_kval("fire_puzzle_2_complete"))
    {
        level flag::set("fire_puzzle_2_complete");
    }


    if(has_map_kval("staff_fire_upgrade_unlocked"))
    {
        // while(true)
        // {
        //     if (level.archi.staff_restore_id == 2)
        //     {
        //         break;
        //     }
        //     wait(0.1);
        // }
        // // Set up the discs
        // set_discs_for_gem("crypt_gem_fire");
        // wait(0.1);
        // // Charge orb
        // e_model = get_crypt_orb("crypt_gem_fire");
        // e_model notify("damage", 1, level.players[0], (0, 0, 0), (0, 0, 0), "", "", "", "", w_staff);
        // level flag::wait_till("staff_fire_upgrade_unlocked");
        level flag::set("staff_fire_upgrade_unlocked");
    }
    level.archi.staff_restore_id++;
}

function restore_ice_staff()
{
    w_staff = getweapon("staff_water");
    // We need a projectile weapon for breaking the gravestones
    w_manowar = getweapon("ar_damage");

    staff = level.a_elemental_staffs["staff_water"];
    staff.charger.charges_received = get_map_kval("staff_water_upgrade_charges");

    if(has_map_kval("ice_puzzle_1_complete"))
    {
        // Force this to be the last tile to solve, and rig the value
        a_ceiling_tile_brushes = getentarray("ice_ceiling_tile", "script_noteworthy");
        level.unsolved_tiles = array(a_ceiling_tile_brushes[0]);
        ice_gem = getent("ice_chamber_gem", "targetname");
        ice_gem.value = a_ceiling_tile_brushes[0].value;

        // Trigger the flip via damage to solve the puzzle
        a_ceiling_tile_brushes[0] notify("damage", 1, level.players[0], (0, 0, 0), a_ceiling_tile_brushes[0].origin, "", "", "", "", w_staff);
        wait(0.1);
    }
    
    if(has_map_kval("ice_puzzle_2_complete"))
    {
        a_stone_positions = struct::get_array("puzzle_stone_water", "targetname");
        foreach(stone in a_stone_positions)
        {
            stone.e_model notify("damage", 1, level.players[0], (0, 0, 0), (0, 0, 0), "", "", "", "", w_staff, "");
            WAIT_SERVER_FRAME
            stone.e_model notify("damage", 1, level.players[0], (0, 0, 0), (0, 0, 0), "MOD_BULLET", "", "", "", w_manowar, "");
            WAIT_SERVER_FRAME
        }
        wait(0.1);
    }

    if(has_map_kval("staff_water_upgrade_unlocked"))
    {
        // while(true)
        // {
        //     if (level.archi.staff_restore_id == 3)
        //     {
        //         break;
        //     }
        //     wait(0.1);
        // }
        // // Set up the discs
        // set_discs_for_gem("crypt_gem_ice");
        // wait(0.1);
        // // Charge orb
        // e_model = get_crypt_orb("crypt_gem_ice");
        // e_model notify("damage", 1, level.players[0], (0, 0, 0), (0, 0, 0), "", "", "", "", w_staff);
        // level flag::wait_till("staff_water_upgrade_unlocked");
        level flag::set("staff_water_upgrade_unlocked");
    }
}

function start_generator(str_generator_name)
{
    // Get the generator struct from the global array
    s_generator = level.zone_capture.zones[str_generator_name];
    
    if(isdefined(s_generator) && !s_generator flag::get("player_controlled"))
    {
        s_generator flag::set("player_controlled");
        s_generator flag::clear("attacked_by_recapture_zombies");
        level clientfield::set("zone_capture_hud_generator_" + s_generator.script_int, 1);
	    level clientfield::set("zone_capture_monolith_crystal_" + s_generator.script_int, 0);
        if(!isdefined(s_generator.perk_fx_func) || [[s_generator.perk_fx_func]]())
        {
            level clientfield::set("zone_capture_perk_machine_smoke_fx_" + s_generator.script_int, 1);
        }
        level clientfield::set("state_" + s_generator.script_noteworthy, 1);
        wait(0.1);
        level clientfield::set("state_" + s_generator.script_noteworthy, 2);
        wait(0.1);
        level clientfield::set("state_" + s_generator.script_noteworthy, 6);
        update_captured_zone_count();
        s_generator enable_perk_machines_in_zone();
        s_generator enable_random_perk_machines_in_zone();
        s_generator enable_mystery_boxes_in_zone();
        level flag::set("power_on" + s_generator.script_int);
        level notify("zone_captured_by_player", s_generator.str_zone);
    }
}

function get_crypt_orb(gem_name)
{
    str_orb_path = undefined;    
    switch(gem_name)  // Fixed: was self.gem_name
    {
        case "crypt_gem_air":
        {
            str_orb_path = "air_orb_exit_path";
            break;
        }
        case "crypt_gem_ice":
        {
            str_orb_path = "ice_orb_exit_path";
            break;
        }
        case "crypt_gem_fire":
        {
            str_orb_path = "fire_orb_exit_path";
            break;
        }
        case "crypt_gem_elec":
        {
            str_orb_path = "lightning_orb_exit_path";
            break;
        }
        default:
        {
            return undefined;
        }
    }

    s_start = struct::get(str_orb_path, "targetname");
    entities = GetEntArray("script_model", "classname");
    
    foreach(ent in entities)
    {
        if(ent.model == s_start.model)
        {
            return ent;
        }
    }
}

// Rotate all discs into position and notify that clearance has changed
function set_discs_for_gem(gem_name)
{
    main_disc = getent("crypt_puzzle_disc_main", "targetname");
    target_pos = (main_disc.position + level.gem_start_pos[gem_name]) % 4;
    discs = getentarray("crypt_puzzle_disc", "script_noteworthy");
    foreach (disc in discs)
    {
        if (disc.targetname === "crypt_puzzle_disc_main")
        {
            continue;
        }

        // Rotate disc into position
        if (disc.position != target_pos)
        {
            disc.position = target_pos;
            new_angles = (disc.angles[0], disc.position * 90, disc.angles[2]);
            disc RotateTo(new_angles, 0.1, 0, 0);
        }
    }
    wait(0.2);
    level notify("crypt_disc_rotation");
}

function print_gem_targets()
{
    gems = getentarray("crypt_gem", "script_noteworthy");
    foreach (gem in gems)
    {
        IPrintLn(gem.targetname);
        wait(1);
    }
}

function save_map_kval(key)
{
    archi_save::save_val(key, level.archi.map_kvals[key]);
}

function restore_map_kval(key)
{
    level.archi.map_kvals[key] = archi_save::restore_val_bool(key);
}

function restore_map_kval_int(key)
{
    level.archi.map_kvals[key] = archi_save::restore_val_int(key);
}

function has_map_kval(key)
{
    if (isdefined(level.archi.map_kvals[key]) && level.archi.map_kvals[key] != 0)
    {
        return true;
    }
    return false;
}

function get_map_kval(key)
{
    if (isdefined(level.archi.map_kvals[key]) && level.archi.map_kvals[key] != 0)
    {
        return level.archi.map_kvals[key];
    }
    return 0;
}

function debug_solve_staff(val)
{
    if (val == "all")
    {
        staffs = array("ice", "fire", "air", "elec");
        foreach (staff in staffs)
        {
            level thread debug_solve_staff(staff + " 3");
        }
        return;
    }

    parts = StrTok(val, " ");
    if (parts.size < 2) 
    {
        IPrintLn("Too short");
        return;
    }
    stage = Int(parts[1]);
    switch (parts[0])
    {
       case "ice":
            level.archi.map_kvals["ice_puzzle_1_complete"] = 1;
            if (stage > 1)
            {
                level.archi.map_kvals["ice_puzzle_2_complete"] = 1;
            }
            if (stage > 2)
            {
                level.archi.map_kvals["staff_water_upgrade_unlocked"] = 1;
            }
            level thread restore_ice_staff();
            break;
            
        case "fire":
            level.archi.map_kvals["fire_puzzle_1_complete"] = 1;
            if (stage > 1)
            {
                level.archi.map_kvals["fire_puzzle_2_complete"] = 1;
            }
            if (stage > 2)
            {
                level.archi.map_kvals["staff_fire_upgrade_unlocked"] = 1;
            }
            level thread restore_fire_staff();
            break;
            
        case "wind":
        case "air":
            level.archi.map_kvals["air_puzzle_1_complete"] = 1;
            if (stage > 1)
            {
                level.archi.map_kvals["air_puzzle_2_complete"] = 1;
            }
            if (stage > 2)
            {
                level.archi.map_kvals["staff_air_upgrade_unlocked"] = 1;
            }
            level thread restore_air_staff();
            break;
        
        case "elec":
        case "lightning":
            level.archi.map_kvals["electric_puzzle_1_complete"] = 1;
            if (stage > 1)
            {
                level.archi.map_kvals["electric_puzzle_2_complete"] = 1;
            }
            if (stage > 2)
            {
                level.archi.map_kvals["staff_lightning_upgrade_unlocked"] = 1;
            }
            level thread restore_lightning_staff();
            break;
            
        default:
            IPrintLn("Not a valid staff");
            break;
    }
}

function give_MaxisDronePart_Body()
{
    archi_items::give_piece("equip_dieseldrone", "body");
}

function give_MaxisDronePart_Brain()
{
    archi_items::give_piece("equip_dieseldrone", "brain");
}

function give_MaxisDronePart_Engine()
{
    archi_items::give_piece("equip_dieseldrone", "engine");
}

function give_GramophonePart_Player()
{
    archi_items::give_piece("gramophone", "vinyl_player");
}

function give_GramophonePart_BlankDisc()
{
    archi_items::give_piece("gramophone", "vinyl_master");
}

function give_GramophonePart_FireDisc()
{
    archi_items::give_piece("gramophone", "vinyl_fire");
}

function give_GramophonePart_WindDisc()
{
    archi_items::give_piece("gramophone", "vinyl_air");
}

function give_GramophonePart_LightningDisc()
{
    archi_items::give_piece("gramophone", "vinyl_elec");
}

function give_GramophonePart_IceDisc()
{
    archi_items::give_piece("gramophone", "vinyl_ice");
}

function give_ElementalStaffPart_Ice_Gem()
{
    archi_items::give_piece("elemental_staff_water", "gem");
}

function give_ElementalStaffPart_Ice_UpperStaff()
{
    archi_items::give_piece("elemental_staff_water", "upper_staff");
}

function give_ElementalStaffPart_Ice_MiddleStaff()
{
    archi_items::give_piece("elemental_staff_water", "middle_staff");
}

function give_ElementalStaffPart_Ice_LowerStaff()
{
    archi_items::give_piece("elemental_staff_water", "lower_staff");
}

function give_ElementalStaffPart_Fire_Gem()
{
    archi_items::give_piece("elemental_staff_fire", "gem");
}

function give_ElementalStaffPart_Fire_UpperStaff()
{
    archi_items::give_piece("elemental_staff_fire", "upper_staff");
}

function give_ElementalStaffPart_Fire_MiddleStaff()
{
    archi_items::give_piece("elemental_staff_fire", "middle_staff");
}

function give_ElementalStaffPart_Fire_LowerStaff()
{
    archi_items::give_piece("elemental_staff_fire", "lower_staff");
}

function give_ElementalStaffPart_Air_Gem()
{
    archi_items::give_piece("elemental_staff_air", "gem");
}

function give_ElementalStaffPart_Air_UpperStaff()
{
    archi_items::give_piece("elemental_staff_air", "upper_staff");
}

function give_ElementalStaffPart_Air_MiddleStaff()
{
    archi_items::give_piece("elemental_staff_air", "middle_staff");
}

function give_ElementalStaffPart_Air_LowerStaff()
{
    archi_items::give_piece("elemental_staff_air", "lower_staff");
}

function give_ElementalStaffPart_Lightning_Gem()
{
    archi_items::give_piece("elemental_staff_lightning", "gem");
}

function give_ElementalStaffPart_Lightning_UpperStaff()
{
    archi_items::give_piece("elemental_staff_lightning", "upper_staff");
}

function give_ElementalStaffPart_Lightning_MiddleStaff()
{
    archi_items::give_piece("elemental_staff_lightning", "middle_staff");
}

function give_ElementalStaffPart_Lightning_LowerStaff()
{
    archi_items::give_piece("elemental_staff_lightning", "lower_staff");
}

function update_captured_zone_count()
{
	level.total_capture_zones = get_captured_zone_count();
	if(level.total_capture_zones == 6)
	{
		level flag::set("all_zones_captured");
	}
	else
	{
		level flag::clear("all_zones_captured");
	}
}

function get_captured_zone_count()
{
	n_player_controlled_zones = 0;
	foreach(generator in level.zone_capture.zones)
	{
		if(generator flag::get("player_controlled"))
		{
			n_player_controlled_zones++;
		}
	}
	return n_player_controlled_zones;
}

function enable_random_perk_machines_in_zone()
{
	if(isdefined(self.perk_machines_random) && isarray(self.perk_machines_random))
	{
		foreach(random_perk_machine in self.perk_machines_random)
		{
			random_perk_machine.is_locked = 0;
			if(isdefined(random_perk_machine.current_perk_random_machine) && random_perk_machine.current_perk_random_machine)
			{
				random_perk_machine set_perk_random_machine_state("idle");
				continue;
			}
			random_perk_machine set_perk_random_machine_state("away");
		}
	}
}

function enable_mystery_boxes_in_zone()
{
	foreach(mystery_box in self.mystery_boxes)
	{
		mystery_box.is_locked = 0;
		mystery_box.zbarrier set_magic_box_zbarrier_state("player_controlled");
		mystery_box.zbarrier clientfield::set("magicbox_runes", 1);
	}
}

function enable_perk_machines_in_zone()
{
	if(isdefined(self.perk_machines) && isarray(self.perk_machines))
	{
		a_keys = getarraykeys(self.perk_machines);
		for(i = 0; i < a_keys.size; i++)
		{
			level notify(a_keys[i] + "_on");
		}
		for(i = 0; i < a_keys.size; i++)
		{
			e_perk_trigger = self.perk_machines[a_keys[i]];
			e_perk_trigger.is_locked = 0;
			e_perk_trigger zm_perks::reset_vending_hint_string();
		}
	}
}

function set_perk_random_machine_state(state)
{
	wait(0.1);
	for(i = 0; i < self getnumzbarrierpieces(); i++)
	{
		self hidezbarrierpiece(i);
	}
	self notify("zbarrier_state_change");
	self [[level.perk_random_machine_state_func]](state);
}

function set_magic_box_zbarrier_state(state)
{
	for(i = 0; i < self getnumzbarrierpieces(); i++)
	{
		self hidezbarrierpiece(i);
	}
	self notify("zbarrier_state_change");
	switch(state)
	{
		case "away":
		{
			self showzbarrierpiece(0);
			self.state = "away";
			self.owner.is_locked = 0;
			break;
		}
		case "arriving":
		{
			self showzbarrierpiece(1);
			self thread magic_box_arrives();
			self.state = "arriving";
			break;
		}
		case "initial":
		{
			self showzbarrierpiece(1);
			self thread zm_magicbox::magic_box_initial();
			thread zm_unitrigger::register_static_unitrigger(self.owner.unitrigger_stub, &zm_magicbox::magicbox_unitrigger_think);
			self.state = "close";
			break;
		}
		case "open":
		{
			self showzbarrierpiece(2);
			self thread magic_box_opens();
			self.state = "open";
			break;
		}
		case "close":
		{
			self showzbarrierpiece(2);
			self thread magic_box_closes();
			self.state = "close";
			break;
		}
		case "leaving":
		{
			self showzbarrierpiece(1);
			self thread magic_box_leaves();
			self.state = "leaving";
			self.owner.is_locked = 0;
			break;
		}
		case "zombie_controlled":
		{
			if(isdefined(level.zombie_vars["zombie_powerup_fire_sale_on"]) && level.zombie_vars["zombie_powerup_fire_sale_on"])
			{
				self showzbarrierpiece(2);
				self clientfield::set("magicbox_amb_fx", 0);
			}
			if(self.state == "initial" || self.state == "close")
			{
				self showzbarrierpiece(1);
				self clientfield::set("magicbox_amb_fx", 1);
			}
			else
			{
				if(self.state == "away")
				{
					self showzbarrierpiece(0);
					self clientfield::set("magicbox_amb_fx", 0);
				}
				else if(self.state == "open" || self.state == "leaving")
				{
					self showzbarrierpiece(2);
					self clientfield::set("magicbox_amb_fx", 0);
				}
			}
			break;
		}
		case "player_controlled":
		{
			if(self.state == "arriving" || self.state == "close")
			{
				self showzbarrierpiece(2);
				self clientfield::set("magicbox_amb_fx", 2);
				break;
			}
			if(self.state == "away")
			{
				self showzbarrierpiece(0);
				self clientfield::set("magicbox_amb_fx", 3);
			}
			break;
		}
		default:
		{
			if(isdefined(level.custom_magicbox_state_handler))
			{
				self [[level.custom_magicbox_state_handler]](state);
			}
			break;
		}
	}
}

function magic_box_opens()
{
	self clientfield::set("magicbox_open_fx", 1);
	self setzbarrierpiecestate(2, "opening");
	self playsound("zmb_hellbox_open");
	while(self getzbarrierpiecestate(2) == "opening")
	{
		wait(0.1);
	}
	self notify("opened");
	self thread magic_box_open_idle();
}

function magic_box_closes()
{
	self notify("stop_open_idle");
	self hidezbarrierpiece(5);
	self showzbarrierpiece(2);
	self setzbarrierpiecestate(2, "closing");
	self playsound("zmb_hellbox_close");
	self clientfield::set("magicbox_open_fx", 0);
	while(self getzbarrierpiecestate(2) == "closing")
	{
		wait(0.1);
	}
	self notify("closed");
}

function magic_box_leaves()
{
	self notify("stop_open_idle");
	self clientfield::set("magicbox_leaving_fx", 1);
	self clientfield::set("magicbox_open_fx", 0);
	self setzbarrierpiecestate(1, "closing");
	self playsound("zmb_hellbox_rise");
	while(self getzbarrierpiecestate(1) == "closing")
	{
		wait(0.1);
	}
	self notify("left");
	s_zone_capture_area = level.zone_capture.zones[self.zone_capture_area];
	if(isdefined(s_zone_capture_area))
	{
		if(s_zone_capture_area flag::get("player_controlled"))
		{
			self clientfield::set("magicbox_amb_fx", 3);
		}
		else
		{
			self clientfield::set("magicbox_amb_fx", 0);
		}
	}
	if(isdefined(level.dig_magic_box_moved) && !level.dig_magic_box_moved)
	{
		level.dig_magic_box_moved = 1;
	}
}

function magic_box_arrives()
{
	self clientfield::set("magicbox_leaving_fx", 0);
	self setzbarrierpiecestate(1, "opening");
	while(self getzbarrierpiecestate(1) == "opening")
	{
		wait(0.05);
	}
	self notify("arrived");
	self.state = "close";
	s_zone_capture_area = level.zone_capture.zones[self.zone_capture_area];
	if(isdefined(s_zone_capture_area))
	{
		if(!s_zone_capture_area flag::get("player_controlled"))
		{
			self clientfield::set("magicbox_amb_fx", 1);
		}
		else
		{
			self clientfield::set("magicbox_amb_fx", 2);
		}
	}
}

function magic_box_open_idle()
{
	self endon("stop_open_idle");
	self hidezbarrierpiece(2);
	self showzbarrierpiece(5);
	while(true)
	{
		self setzbarrierpiecestate(5, "opening");
		while(self getzbarrierpiecestate(5) != "open")
		{
			wait(0.05);
		}
	}
}
