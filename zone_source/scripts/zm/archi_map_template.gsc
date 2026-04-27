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

    archi_save::send_save_data("zm_yourmap");

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
    archi_save::wait_restore_ready("zm_yourmap");
    level flag::wait_till("ap_attachment_rando_ready");
    archi_save::restore_spent_tokens();
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
    else
    {
        self archi_save::initial_loadout();
    }
}

function clear_state()
{
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_yourmap");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function setup_locations()
{
    level flag::wait_till("initial_blackscreen_passed");

    // Setup AP checks here
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
    
}

function restore_map_state()
{
    
}

function save_map_kval(key)
{
    archi_save::save_val(key, level.archi.map_kvals[key]);
}

function restore_map_kval(key)
{
    level.archi.map_kvals[key] = archi_save::restore_val_bool(key);
}

function has_map_kval(key)
{
    if (isdefined(level.archi.map_kvals[key]) && level.archi.map_kvals[key] != 0)
    {
        return true;
    }
    return false;
}
