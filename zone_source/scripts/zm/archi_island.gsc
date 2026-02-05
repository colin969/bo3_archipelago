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
    archi_save::save_power_on();
    archi_save::save_doors_and_debris();

    archi_save::save_players(&save_player_data);

    archi_save::send_save_data("zm_island");
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
    archi_save::wait_restore_ready("zm_island");
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
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_island");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function setup_main_quest()
{
    level thread _flag_to_location_thread("any_player_has_bucket", level.archi.mapString + " Main Quest - Find a Bucket");
    level thread _flag_to_location_thread("power_on3", level.archi.mapString + " Main Quest - Enter the Bunker"); // Doesn't work?
    level thread _flag_to_location_thread("power_on", level.archi.mapString + " Main Quest - Turn on the Power");
    level thread _flag_to_location_thread("pap_open", level.archi.mapString + " Main Quest - Drain the Pack-A-Punch");
    // Add one for draining the water fully
}

function setup_main_ee_quest()
{
    level thread _flag_to_location_thread("player_has_aa_gun_ammo", level.archi.mapString + " Main Easter Egg - Grow an Anti-Aircraft Shell");
    level thread _flag_to_location_thread("aa_gun_ee_complete", level.archi.mapString + " Main Easter Egg - Shoot down the Plane");
    level thread _flag_to_location_thread("elevator_part_gear2_found", level.archi.mapString + " Main Easter Egg - Collect the Cog from the Zipline drop");
    level thread _flag_to_location_thread("elevator_part_gear1_found", level.archi.mapString + " Main Easter Egg - Collect the Cog from the Gobblegum teleport");
    level thread _flag_to_location_thread("takeo_freed", level.archi.mapString + " Main Easter Egg - Free Takeo");
    level thread _flag_to_location_thread("flag_play_outro_cutscene", level.archi.mapString + " Main Easter Egg - Victory");
}

function setup_weapon_quests()
{
    level thread _flag_to_location_thread("ww1_found", level.archi.mapString + " KT-4 - Collect the Green Vial");
    level thread _flag_to_location_thread("ww2_found", level.archi.mapString + " KT-4 - Collect the Underwater Flower");
    level thread _flag_to_location_thread("ww3_venom_extractor_used", level.archi.mapString + " KT-4 - Extract the Spider Venom");
    level thread _flag_to_location_thread("wwup1_found", level.archi.mapString + " Masamune - Collect the Vial of Element 115");
    level thread _flag_to_location_thread("wwup2_found", level.archi.mapString + " Masamune - Take the Spider Queen's Tooth");
    level thread _flag_to_location_thread("wwup3_found", level.archi.mapString + " Masamune - Grow the Rainbow Plant");
    
    level thread _first_skull_cleanse(level.archi.mapString + " Skull of Nan'Sapwe - Cleanse a Ritual Skull");
    level thread _all_skull_cleanse(level.archi.mapString + " Skull of Nan'Sapwe - Cleanse all 4 Ritual Skulls");
    level thread _skull_room_defense(level.archi.mapString + " Skull of Nan'Sapwe - Survive the Skull Room Assault");
}

function setup_challenges()
{
    level thread _flag_to_location_thread("flag_player_completed_challenge_1", level.archi.mapString + " Complete Challenge 1");
    level thread _flag_to_location_thread("flag_player_completed_challenge_2", level.archi.mapString + " Complete Challenge 2");
    level thread _flag_to_location_thread("flag_player_completed_challenge_3", level.archi.mapString + " Complete Challenge 3");
    level thread _flag_to_location_thread("all_challenges_completed", level.archi.mapString + " Complete all Challenge");
}

function _first_skull_cleanse(location)
{
    level flag::wait_till_any(array("skullquest_ritual_complete1", "skullquest_ritual_complete2", "skullquest_ritual_complete3", "skullquest_ritual_complete4"));
    archi_core::send_location(location);
}

function _all_skull_cleanse(location)
{
    level flag::wait_till_all(array("skullquest_ritual_complete1", "skullquest_ritual_complete2", "skullquest_ritual_complete3", "skullquest_ritual_complete4"));
    archi_core::send_location(location);
}

function _skull_room_defense(locations)
{
    level flag::wait_till("skullroom_defend_inprogress");
    level flag::wait_till_clear("skullroom_defend_inprogress");
    archi_core::send_location(location);
}

function _waittill_to_location_thread(listener, hash, location)
{
    listener waittill(hash);

    archi_core::send_location(location);
}

function _flag_to_location_thread(flag, location)
{
    level endon("end_game");

    level flag::wait_till(flag);
    archi_core::send_location(location);
}

function give_GasmaskPart_Visor()
{
    give_piece("gasmask", "part_visor");
}

function give_GasmaskPart_Filter()
{
    give_piece("gasmask", "part_filter");
}

function give_GasmaskPart_Strap()
{
    give_piece("gasmask", "part_strap");
}