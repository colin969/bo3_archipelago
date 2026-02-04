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

function setup_main_quest()
{
    level thread _flag_to_location_thread("any_player_has_bucket", level.archi.mapString + " Main Quest - Find a Bucket");
    level thread _waittill_to_location_thread(level, "spawn_bunker_thresher", level.archi.mapString + " Main Quest - Enter the Bunker");
    level thread _waittill_to_location_thread(level, "power_on", level.archi.mapString + " Main Quest - Turn on the Power");
}

function setup_main_ee_quest()
{
    level thread _flag_to_location_thread("player_has_aa_gun_ammo", level.archi.mapString + " Main Easter Egg - Grow an Anti-Aircraft Shell");
    level thread _flag_to_location_thread("aa_gun_ee_complete", level.archi.mapString + " Main Easter Egg - Shoot down the Plane");
    level thread _flag_to_location_thread("elevator_part_gear2_found", level.archi.mapString + " Main Easter Egg - Collect the Cog from the Zipline drop");
    level thread _flag_to_location_thread("elevator_part_gear2_found", level.archi.mapString + " Main Easter Egg - Collect the Cog from the Gobblegum teleport");
    level thread _flag_to_location_thread("takeo_freed", level.archi.mapString + " Main Easter Egg - Free Takeo");
    level thread _flag_to_location_thread("flag_play_outro_cutscene", level.archi.mapString + " Main Easter Egg - Victory");
}

function setup_weapon_quests()
{
    level thread _flag_to_location_thread("ww1_found", level.archi.mapString + " KT-4 - Collect the Green Vial");
    level thread _flag_to_location_thread("ww2_found", level.archi.mapString + " KT-4 - Collect the Underwater Flower");
    level thread _flag_to_location_thread("ww3_venom_extractor_used", level.archi.mapString + " KT-4 - Extract the Spider Venom");
    level thread _flag_to_location_thread("wwup1_found", level.archi.mapString + " Masamune - Collect the Vial of Element 115")
    level thread _flag_to_location_thread("wwup2_found", level.archi.mapString + " Masamune - Take the Spider Queen's Tooth");
    level thread _flag_to_location_thread("wwup3_found", level.archi.mapString + " Masamune - Grow the Rainbow Plant");
    
    level thread _first_skull_cleanse(level.archi.mapString + " Skull of Nan'Sapwe - Cleanse a Ritual Skull");
    level thread _flag_to_location("skullquest_completed", level.archi.mapString + " Skull of Nan'Sapwe - Cleanse all 4 Ritual Skulls");
    level thread _flag_to_location("skull_quest_complete", level.archi.mapString + " Skull of Nan'Sapwe - Survive the Skull Room Assault");
}

function setup_challenges()
{
    level thread _flag_to_location_thread("flag_player_completed_challenge_1", level.archi.mapString + " Complete Trial 1");
    level thread _flag_to_location_thread("flag_player_completed_challenge_2", level.archi.mapString + " Complete Trial 2");
    level thread _flag_to_location_thread("flag_player_completed_challenge_3", level.archi.mapString + " Complete Trial 3");
    level thread _flag_to_location_thread("all_challenges_completed", level.archi.mapString + " Complete all Trials");
}

function _first_skull_cleanse(location)
{
    level flag::wait_till_any(array("skullquest_ritual_complete1", "skullquest_ritual_complete2", "skullquest_ritual_complete3", "skullquest_ritual_complete4"));
    archi_core::send(location);
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