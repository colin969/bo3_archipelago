#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\player_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\hud_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\scene_shared;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_unitrigger;

#using scripts\zm\archi_core;
#using scripts\zm\archi_items;
#using scripts\zm\archi_save;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\archi_core.gsh;

function save_state_manager()
{
    level.archi.save_state = &save_state;
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
    archi_save::save_zombie_count();
    archi_save::save_power_on();
    archi_save::save_doors_and_debris();

    archi_save::save_players(&save_player_data);

    save_map_state();

    archi_save::send_save_data("zm_stalingrad");
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
    archi_save::wait_restore_ready("zm_stalingrad");
    archi_save::restore_zombie_count();
    archi_save::restore_round_number();
    archi_save::restore_power_on();
    archi_save::restore_doors_and_debris();

    archi_save::restore_players(&restore_player_data);

    restore_map_state();
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
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_stalingrad");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function setup_locations()
{
    level flag::wait_till("initial_blackscreen_passed");

    setup_main_quest();
    setup_ee_quest();
    setup_weapon_quests();
    setup_side_ee();
}

function setup_patches()
{
    level flag::wait_till("initial_blackscreen_passed");
    if (level.archi.difficulty_gorod_egg_cooldown == 1)
    {
        level thread _difficulty_quick_egg_flame_cooldown();
        level thread _difficulty_quick_egg_incubator_cooldown();
    }
    if (level.archi.difficulty_gorod_dragon_wings == 1)
    {
        _difficulty_starting_dragon_wings();
    }
}

function setup_main_quest()
{
    level thread _flag_to_location_thread("dragonride_crafted", level.archi.mapString + " Main Quest - Repair the Dragonride");
}

function setup_ee_quest()
{
    level thread _flag_to_location_thread("generator_charged", level.archi.mapString + " Main Easter Egg - Charge the Generator");
    level thread _flag_to_location_thread("tube_puzzle_complete", level.archi.mapString + " Main Easter Egg - Pneumatic Tubes Puzzle");
    level thread _flag_to_location_thread("key_placement", level.archi.mapString + " Main Easter Egg - Enter S.O.P.H.I.A's Password");
    level thread _flag_to_location_thread("keys_placed", level.archi.mapString + " Main Easter Egg - Place the Trophies");
    level thread _flag_to_location_thread("scenarios_complete", level.archi.mapString + " Main Easter Egg - Complete All 6 Scenarios");
    level thread _flag_to_location_thread("weapon_cores_delivered", level.archi.mapString + " Main Easter Egg - Deliver the Power Core to Nikolai");
    level thread _flag_to_location_thread("dragon_boss_dead", level.archi.mapString + " Main Easter Egg - Slay the Dragon");
    level thread _flag_to_location_thread("nikolai_complete", level.archi.mapString + " Main Easter Egg - Defeat Nikolai");
    level thread _ee_outro(level.archi.mapString + " Main Easter Egg - Victory");
}

function setup_weapon_quests()
{
    level thread _flag_to_location_thread("dragon_strike_acquired", level.archi.mapString + " Acquire the Dragonstrikes");
    level thread _dragonstrike_upgrade(level.archi.ampString + " Upgrade the Dragonstrikes");
    level thread _flag_to_location_thread("dragon_egg_acquired", level.archi.mapString + " Dragon Gauntlets - Acquire the Dragon Egg");
    level thread _flag_to_location_thread("egg_awakened", level.archi.mapString + " Dragon Gauntlets - Warm up the Dragon Egg");
    level thread _flag_to_location_thread("gauntlet_step_2_complete", level.archi.mapString + " Dragon Gauntlets - Challenge 1 - Napalm Zombies");
    level thread _flag_to_location_thread("gauntlet_step_3_complete", level.archi.mapString + " Dragon Gauntlets - Challenge 2 - Collateral Kills Challenge");
    level thread _flag_to_location_thread("gauntlet_step_4_complete", level.archi.mapString + " Dragon Gauntlets - Challenge 3 - Knife Kills Challenge");
    level thread _flag_to_location_thread("gauntlet_quest_complete", level.archi.mapString + " Dragon Gauntlets - Incubate the Dragon Egg");
    level thread _flag_to_location_thread("dragon_gauntlet_acquired", level.archi.mapString + " Dragon Gauntlets - Hatch the Baby Dragon");
    level thread _flag_to_location_thread("drshup_step_1_done", level.archi.mapString + " Tiamat's Maw - 50 Dragon Shield Kills");
    level thread _flag_to_location_thread("drshup_bathed_in_flame", level.archi.mapString + " Tiamat's Maw - Bathe in the Dragon's Flame");
    level thread _tiamats_maw_runes(level.archi.mapString + " Tiamat's Maw - Fire Blast the Purple Runes");
    level thread _flag_to_location_thread("drshup_quest_done", level.archi.mapString + " Tiamat's Maw - Upgrade the Dragon Shield");

    foreach (player in GetPlayers())
    {
        player thread track_player_challenges();
    }
    callback::on_connect(&track_player_challenges);
}

function _waittill_to_location_thread(listener, hash, location)
{
    listener waittill(hash);

    archi_core::send_location(location);
}

function _dragonstrike_upgrade(location)
{
    level flag::wait_till("dragon_stage3_started");
    level flag::wait_till("dragonstrike_stage_complete");
    archi_core::send_location(location);
}

function setup_side_ee()
{
    level thread _flag_to_location_thread("dragon_wings_items_aquired", level.archi.mapString + " Unlock the Dragon Wings");
    level thread _wearable_mangler_helmet(level.archi.mapString + " Unlock the Mangler Helmet");
    level thread _wearable_valkyrie_helmet(level.archi.mapString + " Unlock the Valkyrie Helmet");
}

function track_player_challenges()
{
    self thread track_player_challenge_1(level.archi.mapString + " Complete Challenge 1");
    self thread track_player_challenge_2(level.archi.mapString + " Complete Challenge 2");
    self thread track_player_challenge_3(level.archi.mapString + " Complete Challenge 3");
    self thread track_player_challenge_monkey_bombs(level.archi.mapString + " Upgrade the Monkey Bombs");
}

function track_player_challenge_1(location)
{
    self endon("disconnected");

    self waittill("flag_player_completed_challenge_1");
    archi_core::send_location(location);
}


function track_player_challenge_2(location)
{
    self endon("disconnected");

    self waittill("flag_player_completed_challenge_2");
    archi_core::send_location(location);
}


function track_player_challenge_3(location)
{
    self endon("disconnected");

    self waittill("flag_player_completed_challenge_3");
    archi_core::send_location(location);
}

function track_player_challenge_monkey_bombs(location)
{
    self endon("disconnected");

    self waittill("flag_player_collected_reward_5");
    archi_core::send_location(location);
}


function _ee_outro(location)
{
    level waittill("hash_6460283a");
    archi_core::send_location(location);
}

function _tiamats_maw_runes(location)
{
    level flag::wait_till_all(array("drshup_factory_rune_hit", "drshup_judicial_rune_hit", "drshup_library_rune_hit"));
    archi_core::send_location(location);
}

function _wearable_mangler_helmet(location)
{
	level flag::wait_till_all(array("wearables_raz_mask_complete", "wearables_raz_arms_complete"));
    archi_core::send_location(location);
}

function _wearable_valkyrie_helmet(location)
{
    level flag::wait_till_all(array("wearables_sentinel_arms_complete", "wearables_sentinel_camera_complete"));
    archi_core::send_location(location);
}


function _flag_to_location_thread(flag, location)
{
    level endon("end_game");

    level flag::wait_till(flag);
    archi_core::send_location(location);
}

// function_2b0bc12 - Lockdown setup
// function_6236d848 - Runs lockdown with params

function give_DragonridePart_Transmitter()
{
    archi_items::give_piece("dragonride", "part_transmitter");
}

function give_DragonridePart_Codes()
{
    archi_items::give_piece("dragonride", "part_codes");
}

function give_DragonridePart_Map()
{
    archi_items::give_piece("dragonride", "part_map");
}

function _difficulty_quick_egg_flame_cooldown()
{
    level flag::wait_till("egg_bathed_in_flame");
    WAIT_SERVER_FRAME
    level.var_de98e3ce.var_d54b9ade.var_62ceb838 clientfield::set("dragon_egg_heat_fx", 0);
    level flag::set("egg_cooled_hazard");
}

function _difficulty_quick_egg_incubator_cooldown()
{
    level waittill("hash_8c192d5a");
    WAIT_SERVER_FRAME
	level.var_de98e3ce.var_d54b9ade.var_62ceb838 clientfield::set("dragon_egg_heat_fx", 0);
    level flag::set("egg_cooled_incubator");
    // Add pickup trigger response early
    egg = level.var_de98e3ce.var_d54b9ade;
    egg thread _difficult_egg_incubator_cooled_trigger();
}

function _difficult_egg_incubator_cooled_trigger()
{
    self waittill("trigger_activated");
    self.var_62ceb838 delete();
	zm_unitrigger::unregister_unitrigger(self.s_unitrigger);
	level flag::set("gauntlet_quest_complete");
	foreach(e_player in level.activeplayers)
	{
		e_player flag::set("flag_player_completed_challenge_4");
		level scoreevents::processscoreevent("team_challenge_stalingrad", e_player);
	}
	self struct::delete();
}

function _difficulty_starting_dragon_wings()
{
    level flag::set("dragon_wings_items_aquired");
    level flag::set("dragon_platforms_all_used");
}

function save_map_state()
{
    archi_save::save_flag("dragonride_crafted");
    archi_save::save_flag("dragon_strike_quest_complete");

    archi_save::save_flag("generator_charged");
    archi_save::save_flag("tube_puzzle_complete");
    archi_save::save_flag("key_placement");
    archi_save::save_flag("keys_placed");
    archi_save::save_flag("scenarios_complete");

    archi_save::save_flag("dragon_egg_acquired");
    archi_save::save_flag("egg_awakened");
    archi_save::save_flag("gauntlet_step_2_complete");
    archi_save::save_flag("gauntlet_step_3_complete");
    archi_save::save_flag("gauntlet_step_4_complete");
    archi_save::save_flag("gauntlet_quest_complete");

    archi_save::save_flag("dragon_wings_items_aquired");
    archi_save::save_flag("dragon_platforms_all_used");
    archi_save::save_flag("wearables_raz_mask_complete");
    archi_save::save_flag("wearables_raz_arms_complete");
    archi_save::save_flag("wearables_sentinel_arms_complete");
    archi_save::save_flag("wearables_sentinel_camera_complete");

    archi_save::save_flag("drshup_step_1_done");
    archi_save::save_flag("drshup_bathed_in_flame");
    archi_save::save_flag("drshup_factory_rune_hit");
    archi_save::save_flag("drshup_judicial_rune_hit");
    archi_save::save_flag("drshup_library_rune_hit");
    archi_save::save_flag("drshup_rune_step_done");

    foreach (player in level.players)
    {
        player _save_map_state_player();
    }
}

function restore_map_state()
{
    archi_save::restore_flag("dragonride_crafted");
    wait(0.1);
    if (level flag::get("dragonride_crafted"))
    {
        archi_items::give_piece("dragonride", "part_transmitter");
        archi_items::give_piece("dragonride", "part_codes");
        archi_items::give_piece("dragonride", "part_map");
        zm_spawner::register_zombie_death_event_callback();
        fuse_box = getent("dragonride_fuse_box", "targetname");
        fuse_box HidePart("tag_dragon_network_console_screen_red");
        fuse_box ShowPart("tag_dragon_network_console_screen_green");
    }
    archi_save::restore_flag("dragon_strike_quest_complete");
    wait(0.1);
    // if (level flag::get("dragon_strike_quest_complete"))
    // {
    //     // Force the scene to trigger so we don't confuse it later
    //     // Alternatively we could kill the ent and cause a script error deliberately?
    //     scene_trigger = getent("pavlovs_second_floor", "targetname");
    //     start = level.players[0].origin;
    //     level.players[0].origin = scene_trigger.origin;
    //     WAIT_SERVER_FRAME
    //     level.players[0].origin = start;
    // }

    archi_save::restore_flag("generator_charged");

    archi_save::restore_flag("key_placement");
    if (level flag::get("key_placement"))
    {
        level flag::set("tube_puzzle_complete");
        level flag::set("ee_cylinder_acquired");
    }
    archi_save::restore_flag("keys_placed");
    if (level flag::get("keys_placed"))
    {
        // Manually put the models on the shelf
        shelf = getent("ee_map_shelf", "targetname");
        idx_array = array("01", "02", "03", "04", "05", "06");
        foreach(trophy in idx_array)
        {
            str_tag_name = "wall_map_shelf_figure_" + trophy;
            shelf showpart(str_tag_name);
        }

    }
    archi_save::restore_flag("scenarios_complete");
    if (level flag::get("scenarios_complete"))
    {
        // Scenarios done, prevent key placement
	    map_button = struct::get("ee_map_button_struct", "targetname");
        zm_unitrigger::unregister_unitrigger(map_button.s_unitrigger);
    }

    archi_save::restore_flag("dragon_egg_acquired");
    wait(0.1);
    if (level flag::get("dragon_egg_acquired"))
    {
        foreach (player in level.players)
        {
            player clientfield::set_player_uimodel("zmInventory.piece_egg", 1);
        }
        level thread _delete_egg_trigger();
        level flag::set("dragon_pavlov_first_time");
        wait(0.1);
        egg = getent("egg_drop_damage", "targetname");
        egg notify("damage");
    }
    archi_save::restore_flag("egg_awakened");
    wait(0.1);
    archi_save::restore_flag("gauntlet_step_2_complete");
    if (level flag::get("gauntlet_step_2_complete"))
    {
        wait(0.1);
        level notify("hash_68bf9f79");
    }
    archi_save::restore_flag("gauntlet_step_3_complete");
    if (level flag::get("gauntlet_step_3_complete"))
    {
        wait(0.1);
        level notify("hash_b227a45b");
    }
    archi_save::restore_flag("gauntlet_step_4_complete");
    if (level flag::get("gauntlet_step_4_complete"))
    {
        wait(0.1);
        level notify("hash_9b46a273");
    }

    archi_save::restore_flag("gauntlet_quest_complete");
    if (level flag::get("gauntlet_quest_complete"))
    {
        // Incubation done, remove incubator trigger
        incubator = struct::get("gauntlet_incubation_start", "script_noteworthy");
        zm_unitrigger::unregister_unitrigger(incubator.s_unitrigger);
        foreach (player in level.activeplayers)
        {
            player flag::set("flag_player_completed_challenge_4");
        }
    }


    archi_save::restore_flag("dragon_wings_items_aquired");
    archi_save::restore_flag("dragon_platforms_all_used");
    archi_save::restore_flag("wearables_raz_mask_complete");
    archi_save::restore_flag("wearables_raz_arms_complete");
    archi_save::restore_flag("wearables_sentinel_arms_complete");
    archi_save::restore_flag("wearables_sentinel_camera_complete");

    archi_save::restore_flag("drshup_step_1_done");
    archi_save::restore_flag("drshup_bathed_in_flame");
    archi_save::restore_flag("drshup_factory_rune_hit");
    archi_save::restore_flag("drshup_judicial_rune_hit");
    archi_save::restore_flag("drshup_library_rune_hit");
    archi_save::restore_flag("drshup_rune_step_done");

    foreach (player in level.players)
    {
        player thread _restore_map_state_player();
    }
    callback::on_spawned(player, &_restore_map_state_player);
}

function _delete_egg_trigger()
{
    level waittill("hash_698d88e1");
    eggs = struct::get_array("dragon_egg_pickup", "targetname");
	foreach(egg in eggs)
	{
		egg zm_unitrigger::unregister_unitrigger(egg.s_unitrigger);
	}
}

function _save_map_state_player()
{
    xuid = self GetXuid();
    self archi_save::save_player_flag("flag_player_completed_challenge_1", xuid);
    self archi_save::save_player_flag("flag_player_completed_challenge_2", xuid);
    self archi_save::save_player_flag("flag_player_completed_challenge_3", xuid);
    self archi_save::save_player_flag("flag_player_completed_challenge_4", xuid);  
    self archi_save::save_player_flag("flag_player_collected_reward_1", xuid);
    self archi_save::save_player_flag("flag_player_collected_reward_2", xuid);
    self archi_save::save_player_flag("flag_player_collected_reward_3", xuid);
    self archi_save::save_player_flag("flag_player_collected_reward_4", xuid);
    self archi_save::save_player_flag("flag_player_collected_reward_5", xuid);  
}

// Self is player
function _restore_map_state_player()
{
    xuid = self GetXuid();
    wait(0.1);
    self archi_save::restore_player_flag("flag_player_completed_challenge_1", xuid);
    self archi_save::restore_player_flag("flag_player_completed_challenge_2", xuid);
    self archi_save::restore_player_flag("flag_player_completed_challenge_3", xuid);
    self archi_save::restore_player_flag("flag_player_completed_challenge_4", xuid);  
    wait(0.1);
    self archi_save::restore_player_flag("flag_player_collected_reward_1", xuid);
    self archi_save::restore_player_flag("flag_player_collected_reward_2", xuid);
    self archi_save::restore_player_flag("flag_player_collected_reward_3", xuid);
    self archi_save::restore_player_flag("flag_player_collected_reward_4", xuid);
    self archi_save::restore_player_flag("flag_player_collected_reward_5", xuid);  
}