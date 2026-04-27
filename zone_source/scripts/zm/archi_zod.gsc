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
#using scripts\zm\_zm_weapons;

#using scripts\zm\archi_core;
#using scripts\zm\archi_save;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;

#insert scripts\zm\archi_core.gsh;

function save_state_manager()
{
    level flag::init("ap_allow_player_restore");
    callback::on_connect(&_player_connect);

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

function easy_checkpoint_trigger()
{
    level flag::wait_till_clear("ap_prevent_checkpoints");
    if (level flag::get("ritual_pap_complete"))
    {
        return;
    }
    level flag::wait_till("ritual_pap_complete");
    level.archi.save_checkpoint = true;
    save_state();
    level.archi.save_checkpoint = false;
}

function medium_checkpoint_trigger()
{
    level flag::wait_till_clear("ap_prevent_checkpoints");
    foreach(player in level.players)
    {
        hero_weapon = player zm_utility::get_player_hero_weapon();
        if (hero_weapon != level.weaponnone)
        {
            return;
        }
    }
    foreach (player in level.players)
    {
        player thread sword_watcher();
    }
    callback::on_connect(&sword_watcher);
    level waittill("player_got_sword");
    level.archi.save_checkpoint = true;
    save_state();
    level.archi.save_checkpoint = false;
}

function sword_watcher()
{
    self waittill("hash_b29853d8");
    level notify("player_got_sword");
}

function hard_checkpoint_trigger()
{
    level flag::wait_till_clear("ap_prevent_checkpoints");
    if (level flag::get("ee_book"))
    {
        return;
    }
    level flag::wait_till("ee_book");
    level.archi.save_checkpoint = true;
    save_state();
    level.archi.save_checkpoint = false;
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

    archi_save::send_save_data("zm_zod");

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
    self archi_save::save_player_val("fumigator", self.var_abe77dc0, xuid);
    if (isdefined(self.sword_quest))
    {
        self archi_save::save_player_val("sword_upgrade_stage", self.sword_quest.upgrade_stage, xuid);
    }
    // self save_player_sword_quest(xuid);
}

function load_state()
{
    level.b_allow_idgun_pap = 1;
    weapon = getweapon("idgun_0");
    upgraded_weapon = getweapon("idgun_upgraded_0");
    level.zombie_weapons[weapon].upgrade = upgraded_weapon;
    level.zombie_weapons_upgraded[upgraded_weapon] = weapon;
    level.aat_exemptions[upgraded_weapon] = 1;
    level.limited_weapon[upgraded_weapon] = 0;

    weapon = getweapon("idgun_1");
    upgraded_weapon = getweapon("idgun_upgraded_1");
    level.zombie_weapons[weapon].upgrade = upgraded_weapon;
    level.zombie_weapons_upgraded[upgraded_weapon] = weapon;
    level.aat_exemptions[upgraded_weapon] = 1;
    level.limited_weapon[upgraded_weapon] = 0;

    weapon = getweapon("idgun_2");
    upgraded_weapon = getweapon("idgun_upgraded_2");
    level.zombie_weapons[weapon].upgrade = upgraded_weapon;
    level.zombie_weapons_upgraded[upgraded_weapon] = weapon;
    level.aat_exemptions[upgraded_weapon] = 1;
    level.limited_weapon[upgraded_weapon] = 0;

    weapon = getweapon("idgun_3");
    upgraded_weapon = getweapon("idgun_upgraded_3");
    level.zombie_weapons[weapon].upgrade = upgraded_weapon;
    level.zombie_weapons_upgraded[upgraded_weapon] = weapon;
    level.aat_exemptions[upgraded_weapon] = 1;
    level.limited_weapon[upgraded_weapon] = 0;

    level flag::init("ap_got_summoning_key");

    archi_save::wait_restore_ready("zm_zod");
    level flag::wait_till("ap_attachment_rando_ready");
    archi_save::restore_spent_tokens();
    archi_save::restore_zombie_count();
    archi_save::restore_round_number();
    archi_save::restore_power_on();
    archi_save::restore_doors_and_debris();

    level thread patch_callboxes();

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
        self archi_save::restore_player_loadout(xuid, true);

        fumigator = self archi_save::restore_player_val("fumigator", xuid);
        if (fumigator == "1")
        {
            self.var_abe77dc0 = 1;
        }

        if (isdefined(self.var_abe77dc0) && self.var_abe77dc0 == 1)
        {
            self clientfield::set_to_player("pod_sprayer_held", 1);
            level flag::set("any_player_has_pod_sprayer");
        }

        self restore_player_sword_quest(xuid);
    }
    else
    {
        self archi_save::initial_loadout();
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
    level thread _track_music_snakeskin();
    level thread _track_music_coldhardcash();
    level thread _track_margwa_head();
    level thread _octobomb_upgraded();
    level thread _doughnut_mines();
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

function _track_music_snakeskin()
{
    radios = getentarray("hs_radio", "targetname");
    while(true)
	{
		level waittill("hash_da6d056e");
		if(level.var_89ad28cd == radios.size)
		{
			break;
		}
	}
    archi_core::send_location(level.archi.mapString + " Music EE - Snakeskin Boots");
}

function _track_music_coldhardcash()
{
    stage_items = getentarray("hs_item", "targetname");
	while(true)
	{
		level waittill("hash_bcead67a");
		if(level.var_d98fa1f1 == stage_items.size)
		{
			break;
		}
	}
    archi_core::send_location(level.archi.mapString + " Music EE - Cold Hard Cash");
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

// function _track_gobblegum_quest()
// {
//     level flag::wait_till_any("awarded_lion_gumball1", "awarded_lion_gumball2", "awarded_lion_gumball3", "awarded_lion_gumball4");
//     archi_core::send_location(level.archi.mapString + " Grow a Mega Gobblegum");
// }

function _track_margwa_head()
{
    counter = 0;
    while (counter < 6)
    {
        level waittill("hash_1a2d33d7");
        counter++;
    }
    archi_core::send_location(level.archi.mapString + " Unlock the Margwa's Head");
}

function _octobomb_upgraded()
{
    level waittill("hash_21edb6b6");
    archi_core::send_location(level.archi.mapString + " Upgrade the Li'l Arnies");
}

function _doughnut_mines()
{
    level waittill("hash_25ff6e8", entity);
    archi_core::send_location(level.archi.mapString + " Unlock the Doughnut or Cream Cake Mines");
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

    smashables_str = "";
    smash_keys = GetArrayKeys(level.zod_smashables);
    foreach (key in smash_keys)
    {
        smashable = level.zod_smashables[key];
        if (smashable.m_b_shader_on == 0)
        {
            // Shader off, is broken
            if (smashables_str == "")
            {
                smashables_str = key;
            }
            else
            {
                smashables_str += ";" + key;
            }
        }
    }
    if (smashables_str != "")
    {
        archi_save::save_val("smashed", smashables_str);
    }

    archi_save::save_flag("ee_book");

    archi_save::save_flag("ee_keeper_detective_resurrected");
    archi_save::save_flag("ee_keeper_boxer_resurrected");
    archi_save::save_flag("ee_keeper_femme_resurrected");
    archi_save::save_flag("ee_keeper_magician_resurrected");
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

    // If any ritual was completed, start with the summoning key
    if (level flag::get("ritual_boxer_complete") || level flag::get("ritual_magician_complete") || level flag::get("ritual_detective_complete") || level flag::get("ritual_femme_complete"))
    {
        mdl_key = getent("quest_key_pickup", "targetname");
        mdl_key ghost();
        level.quest_key_can_be_picked_up = 0;
        level clientfield::set("quest_key", 1);
        foreach(o_defend_area in level.a_o_defend_areas)
        {
            thread [[ o_defend_area ]]->set_availability(1);
        }
        foreach (player in level.players)
        {
            player clientfield::set_to_player("used_quest_key", 0);
        }
        zm_unitrigger::unregister_unitrigger(mdl_key.unitrigger_stub);
    }


    worms_held = 0;
    if (level flag::get("ritual_boxer_complete"))
    {
        level clientfield::set("ritual_state_boxer", 3);
        level clientfield::set("holder_of_boxer", player_idx);
        give_piece("ritual_pap", "relic_boxer");
        level clientfield::set("quest_state_boxer", 4);
        worms_held++;
    }
    if (level flag::get("ritual_magician_complete"))
    {
        level clientfield::set("ritual_state_magician", 3);
        level clientfield::set("holder_of_magician", player_idx);
        give_piece("ritual_pap", "relic_magician");
        level clientfield::set("quest_state_magician", 4);
        exploder::stop_exploder("fx_exploder_magician_candles");
        HideMiscModels(("ritual_candles_magician") + "_on");
        ShowMiscModels(("ritual_candles_magician") + "_off");
        worms_held++;
    }
    if (level flag::get("ritual_detective_complete"))
    {
        level clientfield::set("ritual_state_detective", 3);
        level clientfield::set("holder_of_detective", player_idx);
        give_piece("ritual_pap", "relic_detective");
        level clientfield::set("quest_state_detective", 4);
        worms_held++;
    }
    if (level flag::get("ritual_femme_complete"))
    {
        level clientfield::set("ritual_state_femme", 3);
        level clientfield::set("holder_of_femme", player_idx);
        give_piece("ritual_pap", "relic_femme");
        level clientfield::set("quest_state_femme", 4);
        worms_held++;
    }

    if (worms_held >= 4)
    {
        level thread restore_pap_ritual();
    }

	if(!isdefined(level.mementos_picked_up))
	{
		level.mementos_picked_up = 0;
		level.relics_picked_up = 0;
		level.sndritualmementos = 1;
	}

    foreach (key in ritual_array)
    {
        defend_area = level.a_o_defend_areas[key];
        if (level flag::get("ritual_" + key + "_complete"))
        {
            // Kill craftable
            craftable = level.zombie_include_craftables["ritual_" + key];
            if (isdefined(craftable))
            {
                // Crafting table trigger
                foreach(stub in level.a_uts_craftables)
                {
                    if (stub.equipname == "ritual_" + key)
                    {
                        zm_unitrigger::unregister_unitrigger(stub);
                    }
                }

                // Break onPickup for memento
                foreach(stub in craftable.a_pieceStubs)
                {
                    if (stub.pieceName == "memento_" + key)
                    {
                        stub.onPickup = &fn_stub;
                    }
                }
            }


            // Kill defend areas
            level.relics_picked_up++;
            level thread exploder::stop_exploder(("ritual_light_" + key) + "_fin");
            defend_area thread kill_defend_area();
        }
    }

    if (level flag::get("pap_door_open"))
    {
        enter_subway_trigger = getent("keeper_subway_welcome", "targetname");
        enter_subway_trigger delete();
    }

    smashables_str = archi_save::restore_val("smashed");
    smashable_keys = strtok(smashables_str, ";");
    foreach (key in smashable_keys)
    {
        smashable = level.zod_smashables[key];
        if (isdefined(smashable))
        {
            // Force open
            smashable.m_e_trigger notify("trigger", level.players[0]);
        }
        else
        {
            IPrintLn("Could not find smashable " + key);
        }
    }

    level thread _restore_boss_ready();
}

function restore_pap_ritual()
{
    for (i = 0; i < 4; i++)
    {
        basin_number = i + 1;
        str_flag = "pap_basin_" + basin_number;
        s_basin = struct::get(str_flag, "script_noteworthy");
        archi_core::notify_trigger_with_player(s_basin.unitrigger_stub, level.players[0]);
        wait(0.2);
    }
}

function _restore_boss_ready()
{
    level flag::wait_till("ritual_pap_complete");
    wait(3);

    // archi_save::restore_flag("ee_book");
    // if (!level flag::get("ee_book"))
    // {
    //     return;
    // }

    // characters = array("detective", "boxer", "femme", "magician");
    // s_loc = struct::get("ee_totem_landed_position", "targetname");

    // num_done = 0;
    // foreach (str_charname in characters)
    // {
    //     archi_save::restore_flag("ee_keeper_" + str_charname + "_resurrected");
    //     if (level flag::get("ee_keeper_" + str_charname + "_resurrected"))
    //     {
    //         num_done++;
    //         level clientfield::set(("ee_keeper_" + str_charname) + "_state", 3);
    //     }
    // }
    // wait(0.1);

    // // All done, hide totem
    // if (num_done >= 4)
    // {
    //     totem = getent("ee_totem_hanging", "targetname");
    //     totem ghost();
    //     totem clientfield::set("totem_state_fx", 0);
    //     level clientfield::set("ee_totem_state", 0);

    //     // Remove trigger if available
    //     triggers = get_all_unitriggers();
    //     closest = zm_unitrigger::get_closest_unitriggers(s_loc.origin, triggers, 2);
    //     foreach(stub in closest)
    //     {
    //         zm_unitrigger::unregister_unitrigger(stub);
    //     }
    // }
    // wait(0.1);


}

function fn_stub()
{

}

function restore_player_sword_quest(xuid)
{
    while (!isdefined(self.sword_quest)) {
        wait(0.1);
    }

    hero_weapon = self zm_utility::get_player_hero_weapon();

    upgrade_stage = archi_save::restore_player_val("sword_upgrade_stage", xuid);
    IPrintLn("Sword upgrade stage: " + upgrade_stage);
    if (upgrade_stage == "")
    {
        return;
    }
    upgrade_stage = Int(upgrade_stage);

    s_loc = struct::get("keeper_spirit_" + self.characterindex, "targetname");
    
    if (upgrade_stage > 0)
    {
        // Pre-complete the soul statues
        foreach (e_statue in level.sword_quest.statues)
        {
            if (e_statue.script_noteworthy != "initial_egg_statue")
            {
                sword_rock = e_statue;
                continue;
            }
            if (isdefined(e_statue.trigger))
            {
                self.sword_quest.kills[e_statue.statue_id] = 12;
                wait(0.1);
            }
        }

        // Set up state as if we finished all 4 statues and are holding the egg
        self.var_b170d6d6 = 0;
        self.sword_quest.egg_placement = undefined;
        self.sword_quest.all_kills_completed = 1;
        self.sword_quest.upgrade_stage = 1;
        // Place egg
        sword_rock notify("trigger", self);
        self notify("hash_1867e603");
        self clientfield::set_player_uimodel("zmInventory.player_sword_quest_egg_state", 5); 
        wait(0.1);
        self zm_weapons::weapon_give(level.sword_quest.weapons[self.characterindex][1], 0, 0, 1);
    	self.sword_power = 1;
        self.current_sword = self.current_hero_weapon;
	    self gadgetpowerset(0, 100);
        self clientfield::set_player_uimodel("zmhud.swordEnergy", self.sword_power);
    }

    if (upgrade_stage > 1)
    {
        level flag::wait_till("ritual_pap_complete");
        self.sword_quest.upgrade_stage = 2;
        self.var_b170d6d6 = 0;
        self.sword_quest.egg_placement = undefined;
        self clientfield::set_player_uimodel("zmInventory.player_sword_quest_egg_state", 5); 
        self clientfield::set_player_uimodel("zmInventory.player_sword_quest_completed_level_1", 1);
        level clientfield::set("keeper_quest_state_" + self.characterindex, 1);

        self.sword_quest_2.all_kills_completed = 1;
        level clientfield::set("keeper_quest_state_" + self.characterindex, 6);

        wait(2);

        self clientfield::set_player_uimodel("zmInventory.widget_egg", 0);
        level clientfield::set("keeper_quest_state_" + self.characterindex, 7);

        wait(2);

        level clientfield::set("keeper_quest_state_" + self.characterindex, 8);

        switch(self.characterindex)
		{
			case 0:
			{
				level.sword_quest.swords[self.characterindex] setmodel("wpn_t7_zmb_zod_sword2_box_world");
				break;
			}
			case 1:
			{
				level.sword_quest.swords[self.characterindex] setmodel("wpn_t7_zmb_zod_sword2_det_world");
				break;
			}
			case 2:
			{
				level.sword_quest.swords[self.characterindex] setmodel("wpn_t7_zmb_zod_sword2_fem_world");
				break;
			}
			case 3:
			{
				level.sword_quest.swords[self.characterindex] setmodel("wpn_t7_zmb_zod_sword2_mag_world");
				break;
			}
		}
        cur_hero_weapon = self zm_utility::get_player_hero_weapon();
	    self zm_weapons::weapon_take(cur_hero_weapon);
        WAIT_SERVER_FRAME
        self zm_weapons::weapon_give(level.sword_quest.weapons[self.characterindex][2], 0, 0, 1);
        self.sword_power = 1;
        self.current_sword = self.current_hero_weapon;
	    self gadgetpowerset(0, 100);
        self clientfield::set_player_uimodel("zmhud.swordEnergy", self.sword_power);
    }
}

function kill_defend_area()
{
    while(self.m_b_started != 1)
    {
        wait(0.1);
    }
    wait(0.1);
    zm_unitrigger::unregister_unitrigger(self.m_t_use);
    self notify("defend_area_completed");
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

function _player_connect()
{
    sync_perk_exploders();
}

function sync_perk_exploders()
{
    wait(0.2);
    if (isdefined(level.archi.active_perk_machines))
    {
        perk_keys = GetArrayKeys(level.archi.active_perk_machines);
        foreach (perk in perk_keys)
        {
            if (level.archi.active_perk_machines[perk] == true)
            {
                switch (perk)
                {
                    case PERK_JUGGERNOG:
                    	level clientfield::set("perk_light_juggernog", 1);
                        break;
                    case PERK_DOUBLETAP2:
                    	level clientfield::set("perk_light_doubletap", 1);
                        break;
                    case PERK_ADDITIONAL_PRIMARY_WEAPON:
                    	level clientfield::set("perk_light_mule_kick", 1);
                        break;
                    case PERK_QUICK_REVIVE:
                    	level clientfield::set("perk_light_quick_revive", 1);
                        break;
                    case PERK_SLEIGHT_OF_HAND:
                    	level clientfield::set("perk_light_speed_cola", 1);
                        break;
                    case PERK_STAMINUP:
                    	level clientfield::set("perk_light_staminup", 1);
                        break;
                    case PERK_WIDOWS_WINE:
                        level clientfield::set("perk_light_widows_wine", 1);
                        break;
                }
            }
            else
            {
                switch (perk)
                {
                    case PERK_JUGGERNOG:
                        level clientfield::set("perk_light_juggernog", 0);
                        break;
                    case PERK_DOUBLETAP2:
                    	level clientfield::set("perk_light_doubletap", 0);
                        break;
                    case PERK_ADDITIONAL_PRIMARY_WEAPON:
                    	level clientfield::set("perk_light_mule_kick", 0);
                        break;
                    case PERK_QUICK_REVIVE:
                    	level clientfield::set("perk_light_quick_revive", 0);
                        break;
                    case PERK_SLEIGHT_OF_HAND:
                    	level clientfield::set("perk_light_speed_cola", 0);
                        break;
                    case PERK_STAMINUP:
                    	level clientfield::set("perk_light_staminup", 0);
                        break;
                    case PERK_WIDOWS_WINE:
                        level clientfield::set("perk_light_widows_wine", 0);
                        break;
                }
            }
        }
    }
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

function patch_callboxes()
{
    wait(5);
    triggers = get_all_unitriggers();
    train = level.o_zod_train;

    a_callboxes = getentarray("train_call_lever", "targetname");
    foreach(e_callbox in a_callboxes)
    {
        e_lever = train.m_a_s_stations[e_callbox.script_string].callbox;
        // Find trigger next to it
        closest = zm_unitrigger::get_closest_unitriggers(e_lever.origin, triggers, 2);
        foreach(stub in closest)
        {
            stub thread monitor_callbox();
        }
    }
}

function monitor_callbox()
{
    self.allow_beastmode = 1;

    while(true)
    {
        if (isdefined(self.trigger))
        {
            if (!isdefined(self.trigger.allow_beastmode) || self.trigger.allow_beastmode != 1)
            {
                self.trigger.allow_beastmode = 1;
                self zm_unitrigger::run_visibility_function_for_all_triggers();
            }
        }
        wait(0.5);
    }
}
