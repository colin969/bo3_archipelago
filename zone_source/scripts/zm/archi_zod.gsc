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
    archi_save::wait_restore_ready("zm_zod");
    archi_save::restore_zombie_count();
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