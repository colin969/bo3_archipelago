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

    archi_save::send_save_data("zm_theater");

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
    archi_save::wait_restore_ready("zm_theater");
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
    else
    {
        self archi_save::initial_loadout();
    }
}

function clear_state()
{
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_theater");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function setup_locations()
{
    level flag::wait_till("initial_blackscreen_passed");

    foreach (player in level.players)
    {
        player thread onplayerconnect();
    }
    callback::on_connect(&onplayerconnect);

    level thread _flag_to_location_thread("power_on", level.archi.mapString + " Turn on the Power");
    level thread _notify_to_location_thread("play_movie", level.archi.mapString + " Watch a Movie");
    level thread _flag_to_location_thread("snd_song_completed", level.archi.mapString + " Music EE - 115");
    // level thread _notify_to_location_thread("zhd_knocker_success", level.archi.mapString + " Samantha's Sorrow");

    level thread _rocket_ee(level.archi.mapString + " Launch the Toy Rocket");
}

function _rocket_ee(location)
{
    rocket_stand = getent("trigger_jump", "targetname");
    rocket_stand waittill("hash_88782877");
    archi_core::send_location(location);
}

function onplayerconnect()
{
    self thread _monitor_teleport();
}

function _monitor_teleport(location)
{
    self waittill("player_teleported", n_loc);

    archi_core::send_location(location);
}

// === AP Check Utilities ===

// Collect a check when a level flag gets set
// level thread _flag_to_location_thread("flag", level.archi.mapString + " locationName");
function _flag_to_location_thread(flag, location)
{
    level endon("end_game");

    level flag::wait_till(flag);
    archi_core::send_location(location);
}

// Collect a check when a level notification happens
// level thread _notify_to_location_thread("notification", level.archi.mapString + " locationName");
function _notify_to_location_thread(str, location)
{
    level endon("end_game");

    level waittill(str);
    archi_core::send_location(location);
}

function save_map_state()
{
    
}

function restore_map_state()
{
    
}