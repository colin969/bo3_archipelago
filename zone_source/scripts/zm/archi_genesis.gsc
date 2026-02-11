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
#using scripts\shared\scene_shared;
#using scripts\zm\_zm_unitrigger;

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
    archi_save::save_zombie_count();
    archi_save::save_power_on();
    archi_save::save_doors_and_debris();

    archi_save::save_players(&save_player_data);

    save_map_state();

    archi_save::send_save_data("zm_genesis");
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
    archi_save::wait_restore_ready("zm_genesis");
    archi_save::restore_zombie_count();
    archi_save::restore_round_number();
    archi_save::restore_power_on();
    archi_save::restore_doors_and_debris();

    archi_save::restore_players(&restore_player_data);

    restore_map_state();

    wait(10);
    level flag::clear("ap_prevent_checkpoints");
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
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_genesis");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function setup_main_quest()
{
    level thread _any_power_station(level.archi.mapString + " Main Quest - Override a Corruption Engine");
    level thread _all_power_stations(level.archi.mapString + " Main Quest - Override all 4 Corruption Engines");
    level thread _flag_to_location_thread("apotho_pack_freed", level.archi.mapString + " Main Quest - Free the Pack-A-Punch");
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
    level thread _wearable_wolf(level.archi.mapString + " Unlock the Wolf Mask");
    // level thread _wearable_siegfried(level.archi.mapString + " Unlock the Helmet of Siegfried");
    level thread _wearable_king(level.archi.mapString + " Unlock the Helmet of the King");
    level thread _wearable_keeper_skull(level.archi.mapString + " Unlock the Keeper Skull Mask");
    level thread _wearable_margwa(level.archi.mapString + " Unlock the Margwa Mask");
    level thread _wearable_apothigod(level.archi.mapString + " Unlock the Apothigod Mask");
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

function hard_checkpoint_trigger()
{
    level flag::wait_till_clear("ap_prevent_checkpoints");
    level flag::wait_till("book_runes_in_progress");
    level.archi.save_checkpoint = true;
    save_state();
    level.archi.save_checkpoint = false;
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
    level flag::wait_till_any(array("power_on1", "power_on2", "power_on3", "power_on4"));
    archi_core::send_location(location);
}

function _all_power_stations(location)
{
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
    // batteries = struct::get_array("ancient_battery", "targetname");
    // archi_core::send_location(location);
}

function _wearable_king(location)
{
	level flag::wait_till_all(array("mechz_gun_flag", "mechz_mask_flag", "mechz_trap_flag"));
    archi_core::send_location(location);
}

function _wearable_keeper_skull(location)
{
	level flag::wait_till_all(array("keeper_skull_turret_flag", "keeper_skull_zombie_flag"));
    archi_core::send_location(location);
}

function _wearable_margwa(location)
{
    level flag::wait_till_all(array("margwa_head_wasps_flag", "margwa_head_fire_flag", "margwa_head_shadow_flag"));
    archi_core::send_location(location);
}

function _wearable_apothigod(location)
{
	level flag::wait_till_all(array("apothicon_mask_all_zombies_killed", "apothicon_mask_all_wasps_killed", "apothicon_mask_all_spiders_killed", "apothicon_mask_all_margwas_killed", "apothicon_mask_all_fury_killed", "apothicon_mask_all_keepers_killed"));
    archi_core::send_location(location);
}

function reset_summoning_key_listener()
{
    level endon("end_game");

    ModVar("ARCHIPELAGO_GENESIS_RESET_SUMMONING_KEY", "");

    while(true)
    {  
        dvar_value = GetDvarString("ARCHIPELAGO_GENESIS_RESET_SUMMONING_KEY", "");
        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("ARCHIPELAGO_GENESIS_RESET_SUMMONING_KEY", "");
            if (level flag::get("grand_tour"))
            {
                e_player = level.players[0];
                ball = level.ball;
                ball.visuals[0] clientfield::set("ball_on_ground_fx", 0);
                ball.trigger.baseorigin = e_player.origin;
                foreach (visual in ball.visuals)
                {
                visual.baseorigin = e_player.origin;
                }
                ball.isresetting = 1;
                prev_origin = self.trigger.origin;
                ball notify("reset");
                ball gameobjects::move_visuals_to_base();
                ball.trigger.origin = ball.trigger.baseorigin;
                ball.curorigin = self.trigger.origin;
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
    foreach (player in level.players)
    {
        player _save_map_state_player();
    }
}

function restore_map_state()
{
    tape_recorders = struct::get_array("audio_reel_place", "targetname");
    archi_save::restore_flag("shards_done");
    if (level flag::get("shards_done"))
    {
        shards = struct::get_array("shard_piece", "targetname");
        foreach (shard in shards)
        {
            shard delete();
        }
    }
    archi_save::restore_flag("all_power_on");
    if (level flag::get("all_power_on"))
    {
        level flag::set("power_on");
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
    }
    wait(0.1);
    // phased_sophia_start should flag auto
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
    callback::on_spawned(player, &_restore_map_state_player);
}

function set_arena_teleport()
{
    if (!level flag::get("toys_collected"))
    {
        level.var_62552381 = 1;
    }
    else 
    {
        wait(0.1);
        // Already done step, delete key
        s_loc = struct::get("arena_reward_pickup", "targetname");
	    zm_unitrigger::unregister_unitrigger(s_loc.unitrigger_stub);
        ball_visual = level.ball.visuals[0];
        ball_visual.origin = (10000,10000,10000);
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