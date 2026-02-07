#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\player_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\hud_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\scene_shared;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;

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

    save_map_state();

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
    level flag::init("ap_skullroom_finished");
    archi_save::wait_restore_ready("zm_island");
    archi_save::restore_round_number();
    restore_power_on();
    archi_save::restore_doors_and_debris();

    archi_save::restore_players(&restore_player_data);

    restore_map_state();

    if (level flag::get("ap_skullroom_finished"))
    {
        foreach (skull in level.var_a576e0b9)
        {
            skull.mdl_skull_p.origin = skull.mdl_skull_s.origin;
            skull.mdl_skull_p.angles = skull.mdl_skull_s.angles;
            skull.mdl_skull_p show();
            skull.mdl_skull_s ghost();
            skull.str_state = "completed";
        }
        level thread exploder::exploder("fxexp_503");
        wait(0.25);
        foreach (skull in level.var_a576e0b9)
        {
            skull.mdl_skull_p clientfield::set("skullquest_finish_done_glow_fx", 1);
        }
        level.var_d19220ee = 1; // Skull room unlocked
        skullroom = struct::get("s_ut_skullroom", "targetname");
        level thread play_skull_room();
    }

    // Prevent checkpointing during initial load, just in case
    wait(10);
    level flag::clear("ap_prevent_checkpoints");
}

function play_skull_room()
{
    level thread exploder::exploder("fxexp_500");
	level thread scene::play("p7_fxanim_zm_island_alter_stairs_bundle");
    entities = getentarray("dais_center", "targetname");
	if(isdefined(entities))
	{
		foreach(e_piece in entities)
		{
			e_piece delete();
		}
	}
	mdl_skullroom_seal = getent("mdl_skullroom_seal", "targetname");
    mdl_skullroom_seal ghost();
    mdl_skullroom_seal notsolid();
    exploder::stop_exploder("fxexp_501");
    mdl_skullroom_seal connectpaths();
    level.var_a5db31a9 = 0; // Something to do with zones?
	level flag::set("connect_ruins_to_ruins_underground");
    if(!level flag::exists("skullroom_defend_inprogress"))
	{
		level flag::init("skullroom_defend_inprogress");
	}
    if(isdefined(level.var_55c48492))
	{
		level.var_55c48492 show(); // Show skull gun model
	}
    level.var_b10ab148 = 1; // Keeper kill count reached?
    level clientfield::set("keeper_spawn_portals", 0); // Hide keeper portal fx
    level flag::set("skull_quest_complete");
    skull_gun_trigger = level.var_b2152df5;
    skull_gun_trigger.script_unitrigger_type = "unitrigger_radius_use";
    skull_gun_trigger.cursor_hint = "HINT_NOICON";
    skull_gun_trigger.prompt_and_visibility_func = &skull_gun_prompt;
    zm_unitrigger::register_static_unitrigger(skull_gun_trigger, &skull_gun_think);
}

function skull_gun_prompt(player)
{
    if (player HasWeapon(level.var_c003f5b, 1))
    {
        self SetHintString("");
        return false;
    }
    self SetHintString(&"ZM_ISLAND_SKULLQUEST_GET_SKULLGUN");
    return true;
}

function skull_gun_think()
{
    while(true)
    {
        self waittill("trigger", ent);
        if (zombie_utility::is_player_valid(ent) && IsAlive(ent) && !ent laststand::player_is_in_laststand())
        {
            if (!ent HasWeapon(level.var_c003f5b, 1))
            {
                // ent DisableWeaponCycling(); // Force the animation to work
               // cur_weapon = ent GetCurrentWeapon();
                ent zm_weapons::weapon_give(level.var_c003f5b, 0, 0, 1); // Mute audio?
                ent GadgetPowerSet(0, 100);
                ent SwitchToWeapon(level.var_c003f5b);
                level flag::set("a_player_got_skullgun");
                //wait(1);
                //ent SwitchToWeapon(cur_weapon);
                //wait(1);
                //ent GadgetPowerSet(0, 100); // Stops the drain from anim?
                //ent SetWeaponAmmoClip(level.var_c003f5b, 0);
                //ent EnableWeaponCycling();
                ent flag::set("has_skull");
                ent clientfield::set_to_player("skull_skull_state", 3);
            }
        }
    }
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
        hero_weapon = self zm_utility::get_player_hero_weapon();
        if (hero_weapon != level.weaponnone)
        {
            self flag::set("has_skull");
            self clientfield::set_to_player("skull_skull_state", 3);
        }
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
    level thread _flag_to_location_thread("all_challenges_completed", level.archi.mapString + " Complete all Challenges");
    foreach(player in level.players)
    {
        player thread player_challenges();
    }
    callback::on_connect(&player_challenges);
}

function player_challenges()
{
    self thread _player_flag_to_location_thread("flag_player_completed_challenge_1", level.archi.mapString + " Complete Challenge 1");
    self thread _player_flag_to_location_thread("flag_player_completed_challenge_2", level.archi.mapString + " Complete Challenge 2");
    self thread _player_flag_to_location_thread("flag_player_completed_challenge_3", level.archi.mapString + " Complete Challenge 3");
}

function adjust_host_bgb_pack()
{
    e_player = level.players[0];
    foreach(gum in e_player.bgb_pack)
    {
        if (gum == "zm_bgb_anywhere_but_here")
        {
            return;
        }
    }

    e_player.bgb_pack[4] = "zm_bgb_anywhere_but_here";
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

function _skull_room_defense(location)
{
    level flag::wait_till("skullroom_defend_inprogress");
    level flag::wait_till_clear("skullroom_defend_inprogress");
    level flag::set("ap_skullroom_finished");
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

function _player_flag_to_location_thread(flag, location)
{
    self endon("disconnect");

    self flag::wait_till(flag);
    archi_core::send_location(location);
}

function give_GasmaskPart_Visor()
{
    archi_items::give_piece("gasmask", "part_visor");
}

function give_GasmaskPart_Filter()
{
    archi_items::give_piece("gasmask", "part_filter");
}

function give_GasmaskPart_Strap()
{
    archi_items::give_piece("gasmask", "part_strap");
}

function save_map_state()
{
    // KT-4
    archi_save::save_flag("ww1_found");
    archi_save::save_flag("ww2_found");
    archi_save::save_flag("ww3_found");
    archi_save::save_flag("ww_obtained");
    // Masamune
    archi_save::save_flag("wwup1_found");
    archi_save::save_flag("wwup2_found");
    archi_save::save_flag("wwup3_found");
    // EE
    archi_save::save_flag("aa_gun_ee_complete"); // Too finnicky to store gun loaded
    archi_save::save_flag("elevator_part_gear1_found");
    archi_save::save_flag("elevator_part_gear2_found");
    archi_save::save_flag("elevator_part_gear3_found");
    // Challenges
    archi_save::save_flag("all_challenges_completed");
    archi_save::save_flag("trilogy_released");
    archi_save::save_flag("a_player_got_skullgun");
    // PaP Drain
    archi_save::save_flag("valve1_found");
    archi_save::save_flag("valve2_found");
    archi_save::save_flag("valve3_found");
    foreach (player in level.players)
    {
        player _save_map_state_player();
    }
}

// Self is player
function _save_map_state_player()
{
    xuid = self GetXuid();
    self archi_save::save_player_flag("flag_player_completed_challenge_1", xuid);
    self archi_save::save_player_flag("flag_player_completed_challenge_2", xuid);
    self archi_save::save_player_flag("flag_player_completed_challenge_3", xuid);
    self archi_save::save_player_flag("flag_player_collected_reward_1", xuid);
    self archi_save::save_player_flag("flag_player_collected_reward_2", xuid);
    self archi_save::save_player_flag("flag_player_collected_reward_3", xuid); 
}

function restore_map_state()
{
    // KT-4
    archi_save::restore_flag("ww1_found");
    archi_save::restore_flag("ww2_found");
    archi_save::restore_flag("ww3_found");
    archi_save::restore_flag("ww_obtained");
    archi_save::restore_flag("all_challenges_completed");
    wait(0.5); // Probably not needed
    // Masamune
    archi_save::restore_flag("wwup1_found");
    archi_save::restore_flag("wwup2_found");
    archi_save::restore_flag("wwup3_found");
    if (level flag::get("ww1_found")) 
    {
        foreach (player in level.players)
        {
            player clientfield::set_to_player("wonderweapon_part_wwi", 1);
        }
    }
    if (level flag::get("ww2_found")) 
    {
        foreach (player in level.players)
        {
            player clientfield::set_to_player("wonderweapon_part_wwii", 1);
        }
    }
    if (level flag::get("ww3_found")) 
    {
        foreach (player in level.players)
        {
            player clientfield::set_to_player("wonderweapon_part_wwiii", 1);
        }
    }

    // PaP Drain
    archi_save::restore_flag("valve1_found");
    archi_save::restore_flag("valve2_found");
    archi_save::restore_flag("valve3_found");
    if (level flag::get("valve1_found")) 
    {
        foreach (player in level.players)
        {
            player clientfield::set_to_player("valvethree_part_lever", 1); // I know they don't match, deliberate
        }
        level flag::set("pap_gauge");
    }
    if (level flag::get("valve2_found")) 
    {
        foreach (player in level.players)
        {
            player clientfield::set_to_player("valveone_part_lever", 1);
        }
        level flag::set("pap_wheel");
    }
    if (level flag::get("valve3_found")) 
    {
        foreach (player in level.players)
        {
            player clientfield::set_to_player("valvetwo_part_lever", 1);
        }
        level flag::set("pap_whistle");
    }

    archi_save::restore_flag("a_player_got_skullgun");

    archi_save::restore_flag("trilogy_released");
    if (level flag::get("trilogy_released"))
    {
        // Manually reveal the hidden map
        map = getent("mdl_main_ee_map", "targetname");
        map clientfield::set("do_fade_material", 1);
        exploder::exploder("lgt_elevator");
    }
    wait(0.5); // Wait for EE logic to start proper
    archi_save::restore_flag("elevator_part_gear1_found");
    archi_save::restore_flag("elevator_part_gear2_found");
    archi_save::restore_flag("elevator_part_gear3_found");
    if (level flag::get("elevator_part_gear3_found"))
    {
        // Gear gotten, try and disable plane?
        level flag::set("aa_gun_ee_complete");
    }

    // It should be set by now anyway, just to be safe we can wait
    level flag::wait_till("flag_init_player_challenges");
    foreach (player in level.players)
    {
        player thread _restore_map_state_player();
    }
    callback::on_spawned(player, &_restore_map_state_player);
}

// Self is player
function _restore_map_state_player()
{
    xuid = self GetXuid();
    wait(0.1);
    self archi_save::restore_player_flag("flag_player_completed_challenge_1", xuid);
    self archi_save::restore_player_flag("flag_player_completed_challenge_2", xuid);
    self archi_save::restore_player_flag("flag_player_completed_challenge_3", xuid); 
    wait(0.1);
    self archi_save::restore_player_flag("flag_player_collected_reward_1", xuid);
    self archi_save::restore_player_flag("flag_player_collected_reward_2", xuid);
    self archi_save::restore_player_flag("flag_player_collected_reward_3", xuid);
}

function restore_power_on()
{
    level flag::set("power_on1");
    level flag::set("power_on2");
    WAIT_SERVER_FRAME
    level flag::set("power_on3");
    WAIT_SERVER_FRAME
    level flag::set("power_on4");
    WAIT_SERVER_FRAME
    level flag::set("power_on");
}