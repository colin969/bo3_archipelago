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
#insert scripts\zm\_zm_perks.gsh;

#insert scripts\zm\archi_core.gsh;

function save_state_manager()
{
    level flag::init("ap_allow_player_restore");
    // Keep perk machine fx behaving
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

function save_state()
{
    archi_save::save_round_number();
    archi_save::save_zombie_count();
    archi_save::save_power_on();
    archi_save::save_doors_and_debris();
    archi_save::save_spent_tokens();

    archi_save::save_players(&save_player_data);

    save_map_state();

    archi_save::send_save_data("zm_island");

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

    bucket_held = self clientfield::get_to_player("bucket_held");
    archi_save::save_player_val("bucket_held", bucket_held, xuid);

    has_island_seed = self clientfield::get_to_player("has_island_seed");
    archi_save::save_player_val("has_island_seed", has_island_seed, xuid);

    bucket_bucket_water_type = self clientfield::get_to_player("bucket_bucket_water_type");
    archi_save::save_player_val("bucket_bucket_water_type", bucket_bucket_water_type, xuid);

    bucket_bucket_water_level = self clientfield::get_to_player("bucket_bucket_water_level");
    archi_save::save_player_val("bucket_bucket_water_level", bucket_bucket_water_level, xuid);
}

function load_state()
{
    level flag::init("ap_skullroom_finished");
    archi_save::wait_restore_ready("zm_island");
    level flag::wait_till("ap_attachment_rando_ready");
    archi_save::restore_spent_tokens();
    archi_save::restore_zombie_count();
    archi_save::restore_round_number();
    level thread patch_perk_machines();
    restore_power_on();
    archi_save::restore_doors_and_debris();

    level flag::set("ap_allow_player_restore");

    restore_map_state();

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
        hero_weapon = self zm_utility::get_player_hero_weapon();
        if (hero_weapon != level.weaponnone)
        {
            self flag::set("has_skull");
            self clientfield::set_to_player("skull_skull_state", 3);
            WAIT_SERVER_FRAME
        }

        has_island_seed = archi_save::restore_player_val_int("has_island_seed", xuid);
        IPrintLn(has_island_seed);
        self clientfield::set_to_player("has_island_seed", has_island_seed);
        switch(has_island_seed)
        {
            case 0:
            {
                self clientfield::set_to_player("bucket_seed_01", 0);
                self clientfield::set_to_player("bucket_seed_02", 0);
                self clientfield::set_to_player("bucket_seed_03", 0);
                break;
            }
            case 1:
            {
                self clientfield::set_to_player("bucket_seed_01", 1);
                self clientfield::set_to_player("bucket_seed_02", 0);
                self clientfield::set_to_player("bucket_seed_03", 0);
                break;
            }
            case 2:
            {
                self clientfield::set_to_player("bucket_seed_01", 1);
                self clientfield::set_to_player("bucket_seed_02", 1);
                self clientfield::set_to_player("bucket_seed_03", 0);
                break;
            }
            case 3:
            {
                self clientfield::set_to_player("bucket_seed_01", 1);
                self clientfield::set_to_player("bucket_seed_02", 1);
                self clientfield::set_to_player("bucket_seed_03", 1);
                break;
            }
        }
        WAIT_SERVER_FRAME

        bucket_held = archi_save::restore_player_val_int("bucket_held", xuid);
        IPrintLn(bucket_held);
        WAIT_SERVER_FRAME
        if (bucket_held > 0)
        {
            // Pick up a bucket
            bucket_locs = struct::get_array("water_bucket_location", "targetname");
            foreach (loc in bucket_locs)
            {
                if (isdefined(loc.trigger))
                {
                    loc.trigger notify("trigger", self);
                    wait(0.1);
                    break;
                }
            }
        }

        bucket_bucket_water_type = archi_save::restore_player_val_int("bucket_bucket_water_type", xuid);
        IPrintLn(bucket_bucket_water_type);
        self.var_c6cad973 = bucket_bucket_water_type + 1;
        self clientfield::set_to_player("bucket_bucket_water_type", bucket_bucket_water_type);
        WAIT_SERVER_FRAME

        bucket_bucket_water_level = archi_save::restore_player_val_int("bucket_bucket_water_level", xuid);
        IPrintLn(bucket_bucket_water_level);
        self.var_bb2fd41c = bucket_bucket_water_level;
        self clientfield::set_to_player("bucket_bucket_water_level", bucket_bucket_water_level);

        if (self.var_6fd3d65c == 1) {
            foreach(water_source in level.var_4a0060c0)
            {
                if (water_source.script_int == bucket_bucket_water_type && bucket_bucket_water_level == 3)
                {
                    water_source SetInvisibleToPlayer(self);
                }
                water_source SetVisibleToPlayer(self);
            }
            if(bucket_bucket_water_level === 3)
            {
                foreach(power_bucket in level.var_769c0729)
                {
                    if(isdefined(power_bucket))
                    {
                        power_bucket sethintstringforplayer(self, &"ZOMBIE_ELECTRIC_SWITCH");
                    }
                }
            }
            else
            {
                if(bucket_bucket_water_level > 0)
                {
                    foreach(power_bucket in level.var_769c0729)
                    {
                        if(isdefined(power_bucket))
                        {
                            power_bucket sethintstringforplayer(self, &"ZM_ISLAND_POWER_SWITCH_NEEEDS_MORE_WATER");
                        }
                    }
                }
                else
                {
                    foreach(power_bucket in level.var_769c0729)
                    {
                        if(isdefined(power_bucket))
                        {
                            power_bucket sethintstringforplayer(self, &"ZM_ISLAND_POWER_SWITCH_NEEEDS_WATER");
                        }
                    }
                }
            }
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
    level thread _flag_to_location_thread("wwup_ready", level.archi.mapString + " Masamune - Build the Wonder Weapon");

    level thread _first_skull_cleanse(level.archi.mapString + " Skull of Nan'Sapwe - Cleanse a Ritual Skull");
    level thread _all_skull_cleanse(level.archi.mapString + " Skull of Nan'Sapwe - Cleanse all 4 Ritual Skulls");
    level thread _skull_room_defense(level.archi.mapString + " Skull of Nan'Sapwe - Survive the Skull Room");
}

function setup_side_ee()
{
    level thread _track_music_deadflowers();
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

function adjust_bgb_pack()
{
    while(!isdefined(self.bgb_pack))
    {
        wait(0.05);
    }
    wait(0.05);

    foreach(gum in self.bgb_pack)
    {
        if (gum == "zm_bgb_anywhere_but_here")
        {
            return;
        }
    }

    self.bgb_pack[4] = "zm_bgb_anywhere_but_here";
}

function _track_music_deadflowers()
{
    puppets = struct::get_array("side_ee_song_bear", "targetname");
	while(true)
	{
		level waittill("hash_c3f82290");
		if(level.var_51d5c50c == puppets.size)
		{
			break;
		}
	}
    archi_core::send_location(level.archi.mapString + " Music EE - Dead Flowers");
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
    if(!level flag::exists("skullroom_defend_inprogress"))
	{
		level flag::init("skullroom_defend_inprogress");
	}
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

// All elevator gears obtained
function hard_checkpoint_trigger()
{
    level flag::wait_till_clear("ap_prevent_checkpoints");
    if (level flag::get("elevator_part_gear1_found") && level flag::get("elevator_part_gear2_found") && level flag::get("elevator_part_gear_found"))
    {
        return;
    }
    level flag::wait_till_all(array("elevator_part_gear1_found", "elevator_part_gear2_found", "elevator_part_gear3_found"));
    level.archi.save_checkpoint = true;
    save_state();
    level.archi.save_checkpoint = false;
}

// KT-4 or Skull Gun obtained
function medium_checkpoint_trigger()
{
    level flag::wait_till_clear("ap_prevent_checkpoints");
    if (level flag::get("ww_obtained") || level flag::get("a_player_got_skullgun"))
    {
        return;
    }
    level flag::wait_till_any(array("ww_obtained", "a_player_got_skullgun"));
    level.archi.save_checkpoint = true;
    save_state();
    level.archi.save_checkpoint = false;
}

function easy_checkpoint_trigger()
{
    level flag::wait_till_clear("ap_prevent_checkpoints");
    if (level flag::get("pap_open"))
    {
        return;
    }
    level flag::wait_till("pap_open");
    level.archi.save_checkpoint = true;
    save_state();
    level.archi.save_checkpoint = false;
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
    archi_save::save_flag("ap_skullroom_finished");
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
    callback::on_spawned(&_restore_map_state_player);

    if (level flag::get("a_player_got_skullgun"))
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
    power_on = GetDvarInt("ARCHIPELAGO_LOAD_DATA_POWER_ON", 0);
    if (power_on > 0)
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
                }
            }
        }
    }
}

// Perk machine spawning is really unreliable, just force it ourselves
function patch_perk_machines()
{
    // Give time to make sure they're buried
	level flag::wait_till("all_players_spawned");
	level flag::wait_till("zones_initialized");
    wait(1);

    foreach(perk in level.var_fd5c770c)
    {
        if(isdefined(perk.var_f11ace87))
        {
            perk reveal_perk_machine();
        }
    }
}

function reveal_perk_machine()
{
    v_loc = self.var_f11ace87;
    v_angles = self.var_d7ae6fe9;
    self.origin = v_loc;
    self.clip.origin = v_loc - vectorscale((0, 0, 1), 60);
    self.machine.origin = v_loc - vectorscale((0, 0, 1), 60);
    self.bump.origin = v_loc - vectorscale((0, 0, 1), 30);
	self.angles = v_angles;
	self.machine.angles = v_angles;
	self.clip.angles = v_angles;
	self.bump.angles = v_angles;
    self.var_f11ace87 = undefined;
    self.var_d7ae6fe9 = undefined;
    self.var_f391d884 = 0;
}