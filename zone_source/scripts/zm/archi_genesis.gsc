#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\player_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\gameobjects_shared;
#using scripts\shared\hud_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\scene_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_power;

#using scripts\zm\archi_core;
#using scripts\zm\archi_items;
#using scripts\zm\archi_save;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\archi_core.gsh;

function save_state_manager()
{
    level.archi.helm_of_siegfried = 0;
    level flag::init("ap_allow_player_restore");

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

    archi_save::send_save_data("zm_genesis");

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
    self save_wearable(xuid);
}

function load_state()
{
    archi_save::wait_restore_ready("zm_genesis");
    level flag::wait_till("ap_attachment_rando_ready");
    archi_save::restore_spent_tokens();
    archi_save::restore_zombie_count();
    archi_save::restore_round_number();
    archi_save::restore_power_on();
    archi_save::restore_doors_and_debris();

    restore_map_state();

    level flag::set("ap_allow_player_restore");

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
        self thread restore_wearable(xuid);
    }
    else
    {
        self archi_save::initial_loadout();
    }
}

function clear_state()
{
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_genesis");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function patch_stomach_gas()
{
    while(true)
    {
        level.var_a5d2ba4 = 1;
        level waittill("exploderfxexp_106");
        wait(154);
        while (level.var_a5d2ba4 != 0)
        {
            WAIT_SERVER_FRAME
        }
    }
}

function patch_fury_counter()
{
    for(kill_count = 0; kill_count < 40; kill_count++)
	{
		level waittill("fury_head_sniper_kill");
	}
    level flag::set("fury_head_sniper_kill");
    playsoundatposition("zmb_wearable_fury_step", (0, 0, 0));
}

function setup_main_quest()
{
    level thread patch_stomach_gas();
    level thread patch_fury_counter();

    level thread _any_power_station(level.archi.mapString + " Main Quest - Override a Corruption Engine");
    level thread _all_power_stations(level.archi.mapString + " Main Quest - Override all 4 Corruption Engines");
    level thread _flag_to_location_thread("apotho_pack_freed", level.archi.mapString + " Main Quest - Free the Pack-A-Punch");
    level thread _track_music_thegift();

    level thread _flag_to_location_thread("writing_on_the_wall_complete", level.archi.mapString + " Writing on the Wall");
}

function setup_main_ee_quest()
{
    level thread _flag_to_location_thread("character_stones_done", level.archi.mapString + " Main Easter Egg - Shoot the Graves");
    level thread _flag_to_location_thread("got_audio1", level.archi.mapString + " Main Easter Egg - Get the first Audio Reel (Keeper Protector)");
    level thread _flag_to_location_thread("got_audio2", level.archi.mapString + " Main Easter Egg - Get the second Audio Reel (Apothicon Stomach)");
    level thread _flag_to_location_thread("got_audio3", level.archi.mapString + " Main Easter Egg - Get the third Audio Reel (Bones)");
    level thread _flag_to_location_thread("sophia_activated", level.archi.mapString + " Main Easter Egg - Help S.O.P.H.I.A Materialize");
    level thread _flag_to_location_thread("book_picked_up", level.archi.mapString + " Main Easter Egg - Pick up the Kronorium");
    level thread _flag_to_location_thread("book_runes_in_progress", level.archi.mapString + " Main Easter Egg - Collect the Runes of Creation"); // Needs re-tested
    level thread _flag_to_location_thread("book_runes_success", level.archi.mapString + " Main Easter Egg - Activate the Book Runes in order");
    level thread _flag_to_location_thread("grand_tour", level.archi.mapString + " Main Easter Egg - Survive the Margwa Gauntlet");
    level thread _flag_to_location_thread("toys_collected", level.archi.mapString + " Main Easter Egg - Collect all 7 objects with the Summoning Key");
    level thread _flag_to_location_thread("final_boss_defeated", level.archi.mapString + " Main Easter Egg - Feed the Shadowman to the Apothicon God");
    level thread _flag_to_location_thread("ending_room", level.archi.mapString + " Main Easter Egg - Victory");

    level thread reset_summoning_key_listener();
}

function setup_keeper_friend()
{
    level thread _flag_to_location_thread("keeper_callbox_totem_found", level.archi.mapString + " Keeper Protector Part Pickup - Totem");
    level thread _flag_to_location_thread("keeper_callbox_head_found", level.archi.mapString + " Keeper Protector Part Pickup - Skull");
    level thread _flag_to_location_thread("keeper_callbox_gem_found", level.archi.mapString + " Keeper Protector Part Pickup - Gem");
}

function setup_weapon_quest()
{
    level thread _flag_to_location_thread("shards_done", level.archi.mapString + " Eat the shards with the Apothicon Servant");
    level thread _flag_to_location_thread("lil_arnie_done", level.archi.mapString + " Upgrade the Li'l Arnies");
}

function setup_wearables()
{
    level thread _wearable_wolf(level.archi.mapString + " Unlock the Dire Wolf Mask - Grenade the hole then 15 kills during low gravity");
    level thread _wearable_siegfried(level.archi.mapString + " Unlock the Helmet of Siegfried - Shoot the clock then charge the soul jars");
    level thread _wearable_king(
        level.archi.mapString + " Unlock the Helmet of the King (1) - 50 Trap Kills",
        level.archi.mapString + " Unlock the Helmet of the King (2) - Break off a Panzer's helmet and gun"
    );
    level thread _wearable_fury(level.archi.mapString + " Unlock the Fury's Head - 40 Fury kills after all power is turned on");
    level thread _wearable_keeper_skull(
        level.archi.mapString + " Unlock the Keeper Skull (1) - Grenade the hole then 15 kills during low gravity",
        level.archi.mapString + " Unlock the Keeper Skull (2) - 30 zombies killed by the Keeper Protector"
    );
    level thread _wearable_margwa(
        level.archi.mapString + " Unlock the Margwa's Head (1) - Explode all of a Margwa's heads with a Sniper",
        level.archi.mapString + " Unlock the Margwa's Head (2) - Kill both a Void and Fire Margwa"
    );
    level thread _wearable_apothigod(
        level.archi.mapString + " Unlock the Apothicon God Mask (1) - 50 Zombie, 5 Spider and 5 Wasp Kills in Stomach Gas",
        level.archi.mapString + " Unlock the Apothicon God Mask (2) - 10 Keeper and 10 Fury kills in Stomach Gas",
        level.archi.mapString + " Unlock the Apothicon God Mask (3) - 3 Margwa Kills in Stomach Gas"
    );
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

function patch_sword_quest()
{
    level flag::wait_till("book_picked_up");
    
    // Flag step done
    level flag::set("hope_done");

    // Add Takeo's Sword Wallbuy
    weapon = getweapon("melee_katana");
	level.var_b9f3bf28.zombie_weapon_upgrade = "melee_katana";
	level.var_b9f3bf28.weapon = weapon;
	level.var_b9f3bf28.trigger_stub.weapon = weapon;
	level.var_b9f3bf28.trigger_stub.cursor_hint_weapon = weapon;

    clientfield::set(level.var_b9f3bf28.trigger_stub.clientfieldname, 0);
    level clientfield::set("time_attack_reward", 5);
    util::wait_network_frame();
	clientfield::set(level.var_b9f3bf28.trigger_stub.clientfieldname, 2);
	util::wait_network_frame();
    clientfield::set(level.var_b9f3bf28.trigger_stub.clientfieldname, 1);
    level flag::set("time_attack_weapon_awarded");

    // Add pack-a-punch overrides
    level.wallbuy_should_upgrade_weapon_override = &hope_wallbuy_override;
    level.magicbox_should_upgrade_weapon_override = &hope_magicbox_override;
}

// Before boss arena
function hard_checkpoint_trigger()
{
    level endon("end_game");

    level flag::wait_till_clear("ap_prevent_checkpoints");
    if (level flag::get("book_runes_in_progress"))
    {
        return;
    }
    level flag::wait_till("book_runes_in_progress");
    level.archi.save_checkpoint = true;
    save_state();
    level.archi.save_checkpoint = false;
}

// After audio reel 2 (9 holes inside apothicon)
function medium_checkpoint_trigger()
{
    level endon("end_game");

    level flag::wait_till_clear("ap_prevent_checkpoints");
    if (level flag::get("got_audio2"))
    {
        return;
    }
    level flag::wait_till("got_audio2");
    level.archi.save_checkpoint = true;
    save_state();
    level.archi.save_checkpoint = false;
}

function easy_checkpoint_trigger()
{
    level endon("end_game");

    level flag::wait_till_clear("ap_prevent_checkpoints");
    if (level flag::get("all_power_on"))
    {
        return;
    }
    level flag::wait_till("all_power_on");
    level.archi.save_checkpoint = true;
    save_state();
    level.archi.save_checkpoint = false;
}

function _track_music_thegift()
{
    level endon("end_game");

    bears = struct::get_array("side_ee_song_bear", "targetname");
	while(true)
	{
		level waittill("hash_c3f82290");
		if(level.var_51d5c50c == bears.size)
		{
			break;
		}
	}
    archi_core::send_location(level.archi.mapString + " Music EE - The Gift");
}

function hope_wallbuy_override()
{
    return true;
}

function hope_magicbox_override(e_player, weapon)
{
    return true;
}

function _patch_genesis_player()
{

}

function _apothicon_stomach_arnies()
{
    level endon("end_game");

    while(true)
    {
        level waittill("hash_ee91de1d");
        arnies_done = level.var_db16318c;
        if (arnies_done == 3)
        {
            archi_core::send_location(level.archi.mapString + " Main Easter Egg - Fi7ll 3 holes with Li'l Arnies");
        }
        if (arnies_done == 6)
        {
            archi_core::send_location(level.archi.mapString + " Main Easter Egg - Fill 6 holes with Li'l Arnies");
        }
        if (arnies_done >= 9)
        {
            break;
        }
    }
}

function _any_power_station(location)
{
    level endon("end_game");

    level flag::wait_till_any(array("power_on1", "power_on2", "power_on3", "power_on4"));
    archi_core::send_location(location);
}

function _all_power_stations(location)
{
    level endon("end_game");

    level flag::wait_till_all(array("power_on1", "power_on2", "power_on3", "power_on4"));
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

function _wearable_wolf(location)
{
	level flag::wait_till_all(array("keeper_skull_dg4_flag", "keeper_skull_turret_flag"));
    archi_core::send_location(location);
}

function _wearable_siegfried(location)
{
    clock = struct::get_array("s_ee_clock", "targetname");
	t_clock = getent("ee_grand_tour_undercroft", "targetname");
    t_clock setcandamage(1);
	n_stage = 9;
    not_solved = 1;
    while(not_solved)
	{
		t_clock waittill("damage", damage, attacker, direction_vec, v_point, type, modelname, tagname, partname, weapon, idflags);
        n_closest = 9999999;
		s_closest = clock[0];
		for(i = 0; i < clock.size; i++)
		{
			n_dist = distance(clock[i].origin, v_point);
			if(n_dist < n_closest)
			{
				n_closest = n_dist;
				s_closest = clock[i];
			}
		}
		switch(n_stage)
		{
			case 9:
			{
				if(s_closest.script_int == 9)
				{
					n_stage = 3;
				}
				break;
			}
			case 3:
			{
				if(s_closest.script_int == 3)
				{
					n_stage = 5;
				}
				else
				{
					n_stage = 9;
				}
				break;
			}
			case 5:
			{
				if(s_closest.script_int == 5)
				{
					not_solved = 0;
				}
				else
				{
					n_stage = 9;
				}
				break;
			}
		}
	}
    wait(5);

    while(level.var_5317b760 > 0)
    {
        wait(1);
    }

    level.archi.helm_of_siegfried = 1;
    archi_core::send_location(location);
}

function _wearable_king(location1, location2)
{
    level thread _flag_to_location_thread("mechz_trap_flag", location1);
    level flag::wait_till_all(array("mechz_gun_flag", "mechz_mask_flag"));
    archi_core::send_location(location2);
}

function _wearable_fury(location)
{
    level flag::wait_till("fury_head_sniper_kill");
    archi_core::send_location(location);
}

function _wearable_keeper_skull(location1, location2)
{
    level thread _flag_to_location_thread("keeper_skull_turret_flag", location1);
    level thread _flag_to_location_thread("keeper_skull_dg4_flag", location2);
}

function _wearable_margwa(location1, location2)
{
    level endon("end_game");
    level thread _flag_to_location_thread("margwa_head_wasps_flag", location1);
    level flag::wait_till_all(array("margwa_head_fire_flag", "margwa_head_shadow_flag"));
    archi_core::send_location(location2);
}

function _wearable_apothigod(location1, location2, location3)
{
    level thread _wearable_apothigod_basic(location1);
    level thread _wearable_apothigod_special(location2);
    level thread _flag_to_location_thread("apothicon_mask_all_margwas_killed", location3);
}

function _wearable_apothigod_basic(location)
{
    level endon("end_game");

	level flag::wait_till_all(array("apothicon_mask_all_zombies_killed", "apothicon_mask_all_wasps_killed", "apothicon_mask_all_spiders_killed"));
    archi_core::send_location(location);

}

function _wearable_apothigod_special(location)
{
    level endon("end_game");

	level flag::wait_till_all(array("apothicon_mask_all_fury_killed", "apothicon_mask_all_keepers_killed"));
    archi_core::send_location(location);
}

function reset_summoning_key_listener()
{
    level endon("end_game");

    SetDvar("ARCHIPELAGO_GENESIS_RESET_SUMMONING_KEY", "");

    while(true)
    {  
        dvar_value = GetDvarString("ARCHIPELAGO_GENESIS_RESET_SUMMONING_KEY", "");
        if(isdefined(dvar_value) && dvar_value != "")
        {
            SetDvar("ARCHIPELAGO_GENESIS_RESET_SUMMONING_KEY", "");
            if (level flag::get("grand_tour"))
            {
                e_player = level.players[0];
                IPrintLn("Moving ball to " + e_player.name);
                ball = level.ball;
                ball.visuals[0] clientfield::set("ball_on_ground_fx", 0);
                ball.trigger.baseorigin = e_player.origin;
                foreach (visual in ball.visuals)
                {
                    visual.baseorigin = e_player.origin;
                }
                ball.isresetting = 1;
                prev_origin = ball.trigger.origin;
                ball notify("reset");
                ball gameobjects::move_visuals_to_base();
                ball.trigger.origin = ball.trigger.baseorigin;
                ball.curorigin = ball.trigger.origin;
                ball [[ball.onreset]](prev_origin, 1, 1);
                ball gameobjects::clear_carrier();
                ball.isresetting = 0;
            }
            else
            {
                IPrintLnBold("Cannot reset the summoning key if you haven't unlocked it yet");
            }
        }
        wait(1);
    }
}

function save_map_state()
{
    archi_save::save_flag("all_power_on");
    archi_save::save_flag("character_stones_done");
    archi_save::save_flag("got_audio1");
    archi_save::save_flag("got_audio2");
    archi_save::save_flag("got_audio3");
    archi_save::save_flag("sophia_beam_locked");
    archi_save::save_flag("book_picked_up");
    archi_save::save_flag("book_placed");
    archi_save::save_flag("grand_tour");
    archi_save::save_flag("toys_collected");
    archi_save::save_flag("acm_done");
    archi_save::save_flag("electricity_rq_done");
    archi_save::save_flag("fire_rq_done");
    archi_save::save_flag("light_rq_done");
    archi_save::save_flag("shadow_rq_done");
    archi_save::save_flag("writing_on_the_wall_complete");
    archi_save::save_flag("keeper_callbox_totem_found");
    archi_save::save_flag("keeper_callbox_head_found");
    archi_save::save_flag("keeper_callbox_gem_found");

    // Wearables
    // Fury
    archi_save::save_flag("fury_head_sniper_kill");
    // Apothicon God
    archi_save::save_flag("apothicon_mask_all_zombies_killed");
    archi_save::save_flag("apothicon_mask_all_wasps_killed");
    archi_save::save_flag("apothicon_mask_all_spiders_killed");
    archi_save::save_flag("apothicon_mask_all_margwas_killed");
    archi_save::save_flag("apothicon_mask_all_fury_killed");
    archi_save::save_flag("apothicon_mask_all_keepers_killed");
    // Margwa Head
    archi_save::save_flag("margwa_head_wasps_flag");
    archi_save::save_flag("margwa_head_fire_flag");
    archi_save::save_flag("margwa_head_shadow_flag");
    // Keeper Skull
    archi_save::save_flag("keeper_skull_turret_flag");
    // Wolf Head
    archi_save::save_flag("keeper_skull_dg4_flag");
    archi_save::save_flag("keeper_skull_zombie_flag");
    // Helm of the King
    archi_save::save_flag("mechz_gun_flag");
    archi_save::save_flag("mechz_mask_flag");
    archi_save::save_flag("mechz_trap_flag");
    // Siegfried
    archi_save::save_val("helm_of_siegfried", level.archi.helm_of_siegfried);

    archi_save::save_flag("shards_done");
    foreach (player in level.players)
    {
        player _save_map_state_player();
    }
}

function feed_batteries()
{
    wait(1);
    bats = struct::get_array("ancient_battery", "targetname");
    foreach(bat in bats)
    {
        for(i = 0; i < 5; i++)
        {
            level.var_98fdd784 = bat.origin;
            level notify("hash_e8c3642d");
            wait(0.9);
        }
    }
    wait(1);
    level flag::set("ap_siegfried_ready");
}

function restore_map_state()
{
    level flag::init("ap_siegfried_ready");
    archi_save::restore_flag("keeper_callbox_totem_found");
    archi_save::restore_flag("keeper_callbox_head_found");
    archi_save::restore_flag("keeper_callbox_gem_found");

    archi_save::restore_flag("writing_on_the_wall_complete");
    if (level flag::get("writing_on_the_wall_complete"))
    {
        wallbuy = getent("smg_thompson_wallbuy_chalk", "targetname");
		wallbuy show();
    }

    // Wearables
    // Fury
    archi_save::restore_flag("fury_head_sniper_kill");
    // Apothicon God
    archi_save::restore_flag("apothicon_mask_all_zombies_killed");
    archi_save::restore_flag("apothicon_mask_all_wasps_killed");
    archi_save::restore_flag("apothicon_mask_all_spiders_killed");
    archi_save::restore_flag("apothicon_mask_all_margwas_killed");
    archi_save::restore_flag("apothicon_mask_all_fury_killed");
    archi_save::restore_flag("apothicon_mask_all_keepers_killed");
    // Margwa Head
    archi_save::restore_flag("margwa_head_wasps_flag");
    archi_save::restore_flag("margwa_head_fire_flag");
    archi_save::restore_flag("margwa_head_shadow_flag");
    // Keeper Skull
    archi_save::restore_flag("keeper_skull_turret_flag");
    // Wolf Head
    archi_save::restore_flag("keeper_skull_dg4_flag");
    archi_save::restore_flag("keeper_skull_zombie_flag");
    // Helm of the King
    archi_save::restore_flag("mechz_gun_flag");
    archi_save::restore_flag("mechz_mask_flag");
    archi_save::restore_flag("mechz_trap_flag");

    level.archi.helm_of_siegfried = archi_save::restore_val_bool("helm_of_siegfried");
    if (level.archi.helm_of_siegfried == 1)
    {
        // Trigger the 9 3 5 symbols on the clock
        clock_nums = struct::get_array("s_ee_clock", "targetname");
        num_9 = undefined;
        num_3 = undefined;
        num_5 = undefined;
        foreach (num in clock_nums)
        {
            if (num.script_int == 9)
            {
                num_9 = num;
            }
            if (num.script_int == 3)
            {
                num_3 = num;
            }
            if (num.script_int == 5)
            {
                num_5 = num;
            }
        }

	    t_clock = getent("ee_grand_tour_undercroft", "targetname");
        t_clock notify("damage", 10, level.players[0], (0,0,0), num_9.origin, "MOD_BULLET", "", "", "", undefined, undefined);
        wait(0.1);
        t_clock notify("damage", 10, level.players[0], (0,0,0), num_3.origin, "MOD_BULLET", "", "", "", undefined, undefined);
        wait(0.1);
        t_clock notify("damage", 10, level.players[0], (0,0,0), num_5.origin, "MOD_BULLET", "", "", "", undefined, undefined);


        // Trigger the kill functions 5 times on each battery, takes 15 seconds so thread it
        level thread feed_batteries();
    }

    tape_recorders = struct::get_array("audio_reel_place", "targetname");
    archi_save::restore_flag("shards_done");
    if (level flag::get("shards_done"))
    {
        shards = struct::get_array("shard_piece", "targetname");
        foreach (shard in shards)
        {
            shard_ent = getent(shard.target, "targetname");
            shard_ent ghost();
        }
    }
    archi_save::restore_flag("all_power_on");
    if (level flag::get("all_power_on"))
    {
        level thread zm_power::turn_power_on_and_open_doors();
        level thread zm_power::turn_power_on_and_open_doors(1);
        level thread zm_power::turn_power_on_and_open_doors(2);
        level thread zm_power::turn_power_on_and_open_doors(3);
        level thread zm_power::turn_power_on_and_open_doors(4);
    }
    archi_save::restore_flag("character_stones_done");
    wait(0.1);
    archi_save::restore_flag("got_audio1");
    wait(0.1);
    if (level flag::get("got_audio1"))
    {
        foreach (recorder in tape_recorders)
        {
            if (recorder.script_int == 1)
            {
                recorder notify ("trigger_activated", level.players[0]);
            }
        }    
    }
    archi_save::restore_flag("acm_done");
    wait(0.1);
    archi_save::restore_flag("got_audio2");
    wait(0.1);
    if (level flag::get("got_audio2"))
    {
        foreach (recorder in tape_recorders)
        {
            if (recorder.script_int == 2)
            {
                recorder notify ("trigger_activated", level.players[0]);
            }
        }
    }
    archi_save::restore_flag("got_audio3");
    wait(0.1);
    if (level flag::get("got_audio3"))
    {
        foreach (recorder in tape_recorders)
        {
            if (recorder.script_int == 3)
            {
                recorder notify ("trigger_activated", level.players[0]);
            }
        }
        wait(0.1);
        // phased_sophia_start should flag auto
        level flag::wait_till("phased_sophia_start");
    }

    wait(0.1);
    archi_save::restore_flag("sophia_beam_locked");
    wait(0.1);
    archi_save::restore_flag("book_picked_up");
    wait(0.1);
    if (level flag::get("book_picked_up"))
    {
        // Place book
        theater_book = struct::get("ee_book_theater", "targetname");
        theater_book notify("trigger_activated", level.players[0]);
        wait(1);
        // Restore collected runes
        if(!isdefined(level.var_b1b99f8d))
        {
            level.var_b1b99f8d = [];
        }
        else if(!isarray(level.var_b1b99f8d))
        {
            level.var_b1b99f8d = array(level.var_b1b99f8d);
        }
        portal_rune_circle = getent("rift_entrance_rune_portal", "targetname");
        archi_save::restore_flag("electricity_rq_done");
        if (level flag::get("electricity_rq_done"))
        {
            level.var_b1b99f8d[level.var_b1b99f8d.size] = 0;
            portal_rune_circle HidePart("tag_electricity_off");
            portal_rune_circle ShowPart("tag_electricity_on");
            level clientfield::set("gen_rune_electricity", 1);
            level notify("widget_ui_override");
        }
        archi_save::restore_flag("fire_rq_done");
        if (level flag::get("fire_rq_done"))
        {
            level.var_b1b99f8d[level.var_b1b99f8d.size] = 1;
            portal_rune_circle HidePart("tag_fire_off");
            portal_rune_circle ShowPart("tag_fire_on");
            level clientfield::set("gen_rune_fire", 1);
            level notify("widget_ui_override");
        }
        archi_save::restore_flag("light_rq_done");
        if (level flag::get("light_rq_done"))
        {
            level.var_b1b99f8d[level.var_b1b99f8d.size] = 2;
            portal_rune_circle HidePart("tag_light_off");
            portal_rune_circle ShowPart("tag_light_on");
            level clientfield::set("gen_rune_light", 1);
            level notify("widget_ui_override");
        }
        archi_save::restore_flag("shadow_rq_done");
        if (level flag::get("shadow_rq_done"))
        {
            level.var_b1b99f8d[level.var_b1b99f8d.size] = 3;
            portal_rune_circle HidePart("tag_shadow_off");
            portal_rune_circle ShowPart("tag_shadow_on");
            level clientfield::set("gen_rune_shadow", 1);
            level notify("widget_ui_override");
        }
    }
    wait(0.1);
    archi_save::restore_flag("toys_collected");
    // If step in progress, teleport to arena to collect key first
    archi_save::restore_flag_cb("grand_tour", &set_arena_teleport);
    if (level flag::get("toys_collected"))
    {
        level clientfield::set("ee_quest_state", 10);
    }

    foreach (player in level.players)
    {
        player thread _restore_map_state_player();
    }
    callback::on_spawned(&_restore_map_state_player);
}

function set_arena_teleport()
{
    if (!level flag::get("toys_collected"))
    {
        level.var_62552381 = 1;
    }
    else 
    {
        level thread delayed_ball_deleter();
    }
}

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

// Self is player
function _restore_map_state_player()
{
    level flag::wait_till("flag_init_player_challenges");
    WAIT_SERVER_FRAME
    xuid = self GetXuid();
    self archi_save::restore_player_flag("flag_player_completed_challenge_1", xuid);
    self archi_save::restore_player_flag("flag_player_completed_challenge_2", xuid);
    self archi_save::restore_player_flag("flag_player_completed_challenge_3", xuid);
    wait(0.1);
    self archi_save::restore_player_flag("flag_player_collected_reward_1", xuid);
    self archi_save::restore_player_flag("flag_player_collected_reward_2", xuid);
    self archi_save::restore_player_flag("flag_player_collected_reward_3", xuid);
}

function delayed_ball_deleter()
{
    wait(5);
    s_loc = struct::get("arena_reward_pickup", "targetname");
    zm_unitrigger::unregister_unitrigger(s_loc.unitrigger_stub);
    ball_visual = level.ball.visuals[0];
    ball_visual.origin = (10000,10000,10000);
}

function save_wearable(xuid)
{
    if (isdefined(self.var_bc5f242a) && isdefined(self.var_bc5f242a.str_model))
    {
        archi_save::save_player_val("wearable", self.var_bc5f242a.str_model + "", xuid);
    }
}

function restore_wearable(xuid)
{
    self endon("disconnect");

    str_model = archi_save::restore_player_val("wearable", xuid);
    s_loc = undefined;
    switch (str_model)
    {
        case "c_zom_dlc4_player_arlington_helmet":
            s_loc = struct::get("s_weasels_hat", "targetname");
            break;
        case "c_zom_dlc4_player_siegfried_helmet":
            s_loc = struct::get("s_helm_of_siegfried", "targetname");
            break;
        case "c_zom_dlc4_player_king_helmet":
            s_loc = struct::get("s_helm_of_the_king", "targetname");
            break;
        case "c_zom_dlc4_player_direwolf_helmet":
            s_loc = struct::get("s_dire_wolf_head", "targetname");
            break;
        case "c_zom_dlc4_player_keeper_helmet":
            s_loc = struct::get("s_keeper_skull_head", "targetname");
            break;
        case "c_zom_dlc4_player_margwa_helmet":
            s_loc = struct::get("s_margwa_head", "targetname");
            break;
        case "c_zom_dlc4_player_apothican_helmet":
            s_loc = struct::get("s_apothicon_mask", "targetname");
            break;
        case "c_zom_dlc4_player_fury_helmet":
            s_loc = struct::get("s_fury_head", "targetname");
            break;
    }
    wait(0.1);

    if (isdefined(s_loc))
    {
        // Siegfried takes a while to spawn
        if (str_model == "c_zom_dlc4_player_siegfried_helmet")
        {
            level flag::wait_till("ap_siegfried_ready");
        }

        if (isdefined(s_loc.s_unitrigger))
        {
            IPrintLn("Loaded helm: " + s_loc.s_unitrigger.var_475b0a4e);
            // Get the trigger struct
            archi_core::notify_trigger_with_player(s_loc.s_unitrigger, self);
        }
        else
        {
            IPrintLn("Restoring too early?");
        }
    }
    else
    {
        IPrintLn("no helm found? " + str_model);
    }
}

function always_visible_func()
{
    return true;
}

function get_all_unitriggers()
{
    all_uni = [];
    foreach (zone in level.zones)
    {
        if (isdefined(zone.unitrigger_stubs))
        {
            all_uni = ArrayCombine(all_uni, zone.unitrigger_stubs, 1, 0);
        }
    }
    if (isdefined(level._unitriggers.dynamic_stubs))
    {
        all_uni = ArrayCombine(all_uni, level._unitriggers.dynamic_stubs, 1, 0);
    }
    return all_uni;
}
