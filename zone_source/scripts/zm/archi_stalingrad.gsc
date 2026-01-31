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
#using scripts\shared\scene_shared;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\zm\archi_core;
#using scripts\zm\archi_save;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\archi_core.gsh;

function save_state_manager()
{
    level.archi.save_state = &save_state;
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

    archi_save::save_players(&save_player_data);

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
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_stalingrad");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function setup_locations()
{
    level waittill("initial_blackscreen_passed");

    setup_main_quest();
    setup_weapon_quests();
    setup_side_ee();
}

function setup_main_quest()
{
    level thread _flag_to_location_thread("dragonride_crafted", level.archi.mapString + " Repair the Dragonride");
    level thread _flag_to_location_thread("lockdown_complete", level.archi.mapString + " Main Quest - Survive the Lockdown");
}

function setup_weapon_quests()
{
    level thread _flag_to_location_thread("dragon_strike_acquired", level.archi.mapString + " Acquire the Dragonstrikes");
    level thread _flag_to_location_thread("draconite_available", level.archi.ampString + " Upgrade the Dragonstrikes");
    level thread _flag_to_location_thread("dragon_egg_acquired", level.archi.mapString + " Dragon Gauntlets - Acquire the Dragon Egg");
    level thread _flag_to_location_thread("egg_awakened", level.archi.mapString + " Dragon Gauntlets - Warm up the Dragon Egg");
    level thread _flag_to_location_thread("hash_68bf9f79", level.archi.mapString + " Dragon Gauntlets - Challenge 1 - Napalm Zombies");
    level thread _flag_to_location_thread("hash_b227a45b", level.archi.mapString + " Dragon Gauntlets - Challenge 2 - Collateral Kills Challenge");
    level thread _flag_to_location_thread("hash_9b46a273", level.archi.mapString + " Dragon Gauntlets - Challenge 3 - Knife Kills Challenge");
    level thread _flag_to_location_thread("gauntlet_quest_complete", level.archi.mapString + " Dragon Gauntlets - Incubate the Dragon Egg");
    level thread _flag_to_location_thread("drshup_step_1_done", level.archi.mapString + " Tiamat's Maw - 50 Dragon Shield Kills");
    level thread _flag_to_location_thread("drshup_bathed_in_flame", level.archi.mapString + " Tiamat's Maw - Bathe in the Dragon's Flame");
    level thread _tiamats_maw_runes(level.archi.mapString + " Tiamat's Maw - Fire Blast the Purple Runes");
    level thread _flag_to_location_thread("drshup_quest_done", level.archi.mapString + " Tiamat's Maw - Upgrade the Dragon Shield");
}

function setup_side_ee()
{
    level thread _flag_to_location_thread("dragon_wings_items_aquired", level.archi.mapString + " Unlock the Dragon Wings");
    level thread _wearable_mangler_helmet(level.archi.mapString + " Unlock the Mangler Helmet");
    level thread _wearable_valkyrie_helmet(level.archi.mapString + " Unlock the Valkyrie Helmet");
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