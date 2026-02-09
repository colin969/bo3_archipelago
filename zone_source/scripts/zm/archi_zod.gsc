#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
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
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;

#using scripts\zm\archi_core;
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

    archi_save::send_save_data("zm_zod");
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
    level flag::init("ap_got_summoning_key");

    archi_save::wait_restore_ready("zm_zod");
    archi_save::restore_zombie_count();
    archi_save::restore_round_number();
    archi_save::restore_power_on();
    archi_save::restore_doors_and_debris();

    restore_map_state();

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
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_zod");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function setup_locations()
{
    level flag::wait_till("initial_blackscreen_passed");

    setup_main_quest();
    setup_side_ee();
    setup_main_ee();
    setup_sword_quest();
}

function setup_side_ee()
{
    level thread _laundry_ticket();
}

function setup_main_quest()
{
    level thread _flag_to_location_thread("ritual_magician_complete", level.archi.mapString + " Main Quest - Magician's Ritual");
    level thread _flag_to_location_thread("ritual_boxer_complete", level.archi.mapString + " Main Quest - Boxer's Ritual");
    level thread _flag_to_location_thread("ritual_detective_complete", level.archi.mapString + " Main Quest - Detectives's Ritual");
    level thread _flag_to_location_thread("ritual_femme_complete", level.archi.mapString + " Main Quest - Femme Fatale's Ritual");
    level thread _flag_to_location_thread("ritual_pap_complete", level.archi.mapString + " Main Quest - Open the Portal");
}

function setup_main_ee()
{
    level thread _patch_player_requirement();
    for(i = 1; i < 4; i++)
	{
		level thread _patch_electrified_rail(i);
	}
    level thread _flag_to_location_thread("ee_book", level.archi.mapString + " Main Easter Egg - Find Nero's Book");
    level thread _flag_to_location_thread("ee_boss_defeated", level.archi.mapString + " Main Easter Egg - Defeat the Shadowman");
    level thread _flag_to_location_thread("ee_final_boss_defeated", level.archi.mapString + " Main Easter Egg - Defeat the Giant Space Squid");
    level thread _flag_to_location_thread("ee_complete", level.archi.mapString + " Main Easter Egg - Victory");
}

function setup_sword_quest()
{
    level thread _flag_to_location_thread("keeper_sword_locker", level.archi.mapString + " Apothicon Sword - Enter the Code");

    array::thread_all(level.players, &_player_sword_quest_monitor);
    callback::on_connect(&_player_sword_quest_monitor);
}

function _player_sword_quest_monitor()
{
    while(true)
    {
        // Triggers when sword upgrade stage changes?
        self waittill("hash_b29853d8");
        if (isdefined(self.sword_quest) && isdefined(self.sword_quest.upgrade_stage))
        {
            if (self.sword_quest.upgrade_stage == 1)
            {
                archi_core::send_location(level.archi.mapString + " Apothicon Sword - Collect your Sword");
            }
            else if (self.sword_quest.upgrade_stage == 2)
            {
                archi_core::send_location(level.archi.mapString + " Apothicon Sword - Collect your upgraded Sword");
            }
        } 
    }
}

function _patch_player_requirement()
{
    // If we do it too early, it will skip sword upgrade requirement
    level waittill("ee_boss_started");
    // Disables 4 player requirement for ending
    level.var_421ff75e = 1;
}

function _patch_electrified_rail(n_rail)
{
    rail_name = "ee_district_rail_electrified_" + n_rail;
    scene_name = _electrified_rail_scene(n_rail);

    while (true)
    {
        // Wait until rail activated
        level flag::wait_till(rail_name);
        // If you've got 4 players, do the actual thing
        if (level.players.size < 4) {
            t_rail = getent(rail_name, "targetname");
            t_update = getent(t_rail.target, "targetname");
            wait(3);
            // Wait until rail turns off
            level flag::wait_till_clear(rail_name);
            wait(0.5);

            // Turn rail back on permanently
            t_update clientfield::set("ee_rail_electricity_state", 1);
            level flag::set(rail_name);
            showmiscmodels("train_rail_glow_" + n_rail);
            hidemiscmodels("train_rail_wet_" + n_rail);
            level thread scene::play(scene_name);
        }
    }
}

function _electrified_rail_scene(n_rail)
{
    switch(n_rail)
	{
		case 1:
		{
			return "p7_fxanim_zm_zod_train_rail_spark_canal_bundle";
		}
		case 2:
		{
			return "p7_fxanim_zm_zod_train_rail_spark_waterfront_bundle";
		}
		case 3:
		{
			return "p7_fxanim_zm_zod_train_rail_spark_footlight_bundle";
		}
	}
}

function _laundry_ticket()
{
    ticket = getent("laundry_ticket", "targetname");
    ticket waittill("trigger_activated", e_player);
    archi_core::send_location(level.archi.mapString + " Laundry Ticket");
}

function _flag_to_location_thread(flag, location)
{
    level endon("end_game");

    level flag::wait_till(flag);
    archi_core::send_location(location);
}

function give_ApothiconServantPart_Heart()
{
    give_piece("idgun", "part_heart");
}

function give_ApothiconServantPart_Tentacle()
{
    give_piece("idgun", "part_skeleton");
}

function give_ApothiconServantPart_Xenomatter()
{
    give_piece("idgun", "part_xenomatter");
}

function give_CivilProtectorPart_Fuse01()
{
    give_piece("police_box", "fuse_01");
}

function give_CivilProtectorPart_Fuse02()
{
    give_piece("police_box", "fuse_02");
}

function give_CivilProtectorPart_Fuse03()
{
    give_piece("police_box", "fuse_03");
}

function give_piece(craftableName, pieceName)
{
    level.archi.craftable_parts[craftableName + "_" + pieceName] = true;
    zm_craftables::player_get_craftable_piece(craftableName, pieceName);
}

function save_map_state()
{
    // Rituals
    archi_save::save_flag("ritual_boxer_complete");
    archi_save::save_flag("ritual_magician_complete");
    archi_save::save_flag("ritual_detective_complete");
    archi_save::save_flag("ritual_femme_complete");
    // archi_save::save_flag("ritual_pap_complete");
    archi_save::save_flag("pap_door_open");
    archi_save::save_flag("keeper_sword_locker");
    for (i = 0; i < 30; i++)
    {
        archi_save::save_flag("power_on" + i);
    }
}

function restore_map_state()
{
    archi_save::restore_flag("ritual_boxer_complete");
    archi_save::restore_flag("ritual_magician_complete");
    archi_save::restore_flag("ritual_detective_complete");
    archi_save::restore_flag("ritual_femme_complete");
    // archi_save::restore_flag("ritual_pap_complete");
    archi_save::restore_flag("pap_door_open");
    archi_save::restore_flag("keeper_sword_locker");
    for (i = 0; i < 30; i++)
    {
        archi_save::restore_flag("power_on" + i);
    }

    player_idx = level.players[0].characterindex + 1;
    ritual_array = array("boxer", "detective", "magician", "femme");

    if (level flag::get("ritual_boxer_complete") || level flag::get("ritual_magician_complete") || level flag::get("ritual_detective_complete") || level flag::get("ritual_femme_complete"))
    {
        mdl_key = getent("quest_key_pickup", "targetname");
        mdl_key ghost();
        level.quest_key_can_be_picked_up = 0;
        level clientfield::set("quest_key", 1);
        foreach (ritual_str in ritual_array)
        {
            if (!(level flag::get("ritual_" + ritual_str + "_complete")))
            {
                thread [[ level.a_o_defend_area[ritual_str] ]]->set_availability(1);

            }
        }
        foreach (player in level.players)
        {
            player clientfield::set_to_player("used_quest_key", 0);
        }
        mdl_key.unitrigger_stub zm_unitrigger::run_visibility_function_for_all_triggers();
    }

    held_state = 3;
    // if (level flag::get("ritual_pap_complete"))
    // {
    //     // Flag all basins as done
    //     level flag::set("pap_basin_1");
    //     level flag::set("pap_basin_2");
    //     level flag::set("pap_basin_3");
    //     level flag::set("pap_basin_4");
    //     pap_defend_area = level.a_o_defend_areas["pap"];
    //     zm_unitrigger::unregister_unitrigger(pap_defend_area.m_t_use);
    //     // Move gateworm models into position
    //     ritual_array = array("relic_boxer", "relic_magician", "relic_detective", "relic_femme");
    //     for(i = 1; i < 5; i++)
    //     {
	//         mdl_gateworm = getent(("quest_ritual_" + ritual_array[i-1]) + "_placed", "targetname");
    //         e_basin = get_worm_basin("pap_basin_" + i);
    //         basin_pos = struct::get("pap_basin_" + i + "_pos", "targetname");
    //         if (isdefined(basin_pos))
    //         {
    //             mdl_gateworm.origin = basin_pos.origin;
    //             mdl_gateworm.angles = basin_pos.angles;
    //         }
    //         else
    //         {
    //             mdl_gateworm.origin = e_basin.origin + vectorscale((0, 0, 1), 40);
    //         }
    //         e_basin clientfield::set("gateworm_basin_fx", 2);
    //         e_basin playloopsound("zmb_zod_ritual_pap_worm_firelvl2", 1);
    //         mdl_gateworm show();
    //         exploder::stop_exploder(("fx_exploder_ritual_pap_basin_" + i) + "_path");
    //         e_basin = get_worm_basin("pap_basin_" + i);
    //         e_basin clientfield::set("gateworm_basin_fx", 2);
    //         e_basin playloopsound("zmb_zod_ritual_pap_worm_firelvl2", 1);
    //     }
    //     level.n_zod_rituals_completed = 5;
    //     level flag::set("can_spawn_margwa");
    //     // Change quest state later when restoring each relic
    //     held_state = 5;
    // }

    if (level flag::get("ritual_boxer_complete"))
    {
        level clientfield::set("ritual_state_boxer", 3);
        level clientfield::set("holder_of_boxer", player_idx);
        level clientfield::set("quest_state_boxer", held_state);
        if (held_state != 5)
        {
            give_piece("ritual_pap", "relic_boxer");
        }
    }
    if (level flag::get("ritual_magician_complete"))
    {
        level clientfield::set("ritual_state_magician", 3);
        level clientfield::set("holder_of_magician", player_idx);
        level clientfield::set("quest_state_magician", held_state);
        exploder::stop_exploder("fx_exploder_magician_candles");
        HideMiscModels(("ritual_candles_magician") + "_on");
        ShowMiscModels(("ritual_candles_magician") + "_off");
        if (held_state != 5)
        {
            give_piece("ritual_pap", "relic_magician");
        }
    }
    if (level flag::get("ritual_detective_complete"))
    {
        level clientfield::set("ritual_state_detective", 3);
        level clientfield::set("holder_of_detective", player_idx);
        level clientfield::set("quest_state_detective", held_state);
        if (held_state != 5)
        {
            give_piece("ritual_pap", "relic_detective");
        }
    }
    if (level flag::get("ritual_femme_complete"))
    {
        level clientfield::set("ritual_state_femme", 3);
        level clientfield::set("holder_of_femme", player_idx);
        level clientfield::set("quest_state_femme", held_state);
        if (held_state != 5)
        {
            give_piece("ritual_pap", "relic_femme");
        }
    }
    // if (level flag::get("ritual_pap_complete"))
    // {
	// 	exploder::stop_exploder("fx_exploder_ritual_pap_altar_path");
    //     exploder::exploder("fx_exploder_ritual_gatestone_explosion");
	//     exploder::exploder("fx_exploder_ritual_gatestone_portal");
    //     HideMiscModels("gatestone_unbroken");
    //     // Remove worm basin triggers
    //     for(i = 1; i < 5; i++)
    //     {
    //         if(isdefined(level.var_f86952c7["pap_basin_" + i]))
    //         {
    //             zm_unitrigger::unregister_unitrigger(level.var_f86952c7["pap_basin_" + i]);
    //         }
    //     }
    //     level notify("ritual_pap_succeed");
    //     level clientfield::set("ritual_current", 0);
	//     level clientfield::set("ritual_state_pap", 3);
    // }
    if (level flag::get("pap_door_open"))
    {
        enter_subway_trigger = getent("keeper_subway_welcome", "targetname");
        enter_subway_trigger delete();
    }
}

function get_worm_basin(str_flag)
{
	a_e_basins = getentarray("worm_basin", "targetname");
	foreach(e_basin in a_e_basins)
	{
		if(e_basin.script_noteworthy === str_flag)
		{
			return e_basin;
		}
	}
}
