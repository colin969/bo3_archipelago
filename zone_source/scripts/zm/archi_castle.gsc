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
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_weapons;

#using scripts\zm\archi_core;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\archi_core.gsh;

function save_state_manager()
{
    level waittill("end_game");

    if (level.host_ended_game == 1)
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
    level waittill("initial_blackscreen_passed");

    while (true)
    {
        level waittill("start_of_round");
        if (level.round_number != 1)
        {
            save_state();
        }
    }
}

function save_state()
{
    // Make sure we're not already saving first
    dvar_value = GetDvarString("ARCHIPELAGO_SAVE_PROGRESS", "");
    if (dvar_value == "NONE")
    {
        SetDvar("ARCHIPELAGO_SAVE_PROGRESS", "INPROGRESS");

        // Save current round
        SetDvar("ARCHIPELAGO_SAVE_DATA_ROUND", level.round_number);

        xuidString = "";
        for(i = 0; i < level.players.size; i++)
        {
            e_player = level.players[i];
            xuid = e_player GetXUID();
            IPrintLn("Saving player data for " + e_player.name);
            xuidString += xuid + ";";
            SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_SCORE_" + xuid, e_player.score);

            // Save Power State
            if (level flag::get("power_on"))
            {
                SetDvar("ARCHIPELAGO_SAVE_DATA_POWER_ON", 1);
            } else {
                SetDvar("ARCHIPELAGO_SAVE_DATA_POWER_ON", 0);
            }           
            
            // Save Blocker States
            door_str = "";
            foreach (door_id in level.archi.opened_doors)
            {
                door_str += door_id + ";";
            }

            debris_str = "";
            foreach (debris_id in level.archi.opened_debris)
            {
                debris_str += debris_id + ";";
            }

            SetDvar("ARCHIPELAGO_SAVE_DATA_OPENED_DOORS", door_str);
            SetDvar("ARCHIPELAGO_SAVE_DATA_OPENED_DEBRIS", debris_str);
            
            // Save Perks
            perks = e_player GetPerks();
            for (i = 0; i < perks.size; i++)
            {
                SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_PERK_" + xuid + "_" + i, perks[i]);
            }
            
            // Save Weapon Loadout
            weapons = self GetWeaponsList();
            loadout = e_player zm_weapons::player_get_loadout();
            i = 0;
            foreach ( weapon in loadout.weapons ) 
            {
                SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_" + i + "_WEAPON", weapon["weapon"].name);
                SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_" + i + "_CLIP", weapon["clip"]);
                SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_" + i + "_STOCK", weapon["stock"]);
                SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_" + i + "_LHCLIP", weapon["lh_clip"]);
                SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_" + i + "_ALTCLIP", weapon["alt_clip"]);                SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_" + i + "_ALTCLIP", weapon["alt_clip"]);
                SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_" + i + "_ALTSTOCK", weapon["alt_stock"]);
                i++;
            }
        }

        SetDvar("ARCHIPELAGO_SAVE_DATA_XUIDS", xuidString);
        SetDvar("ARCHIPELAGO_SAVE_DATA", "zm_castle");
        SetDvar("ARCHIPELAGO_SAVE_PROGRESS", "NONE");
        LUINotifyEvent(&"ap_save_data", 0);
    }
}

function clear_state()
{
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_castle");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function load_state()
{
    level waittill("initial_blackscreen_passed");

    SetDvar("ARCHIPELAGO_LOAD_DATA", "zm_castle");
    IPrintLn("Loading save data...");
    LUINotifyEvent(&"ap_load_data", 0);

    while(true)
    {
        // Wait for data to be collected and set to dvars
        WAIT_SERVER_FRAME
        dvar_value = GetDvarString("ARCHIPELAGO_LOAD_DATA", "");
        if (dvar_value == "NONE")
        {
            seed_value = GetDvarString("ARCHIPELAGO_LOAD_DATA_SEED", "");
            if (seed_value == "NONE")
            {
                IPrintLn("Failed to load seed? Are we connected?");
            } 
            else 
            {
                IPrintLn("Loaded Seed " + seed_value);

                // Data has been loaded into dvars
                for(i = 0; i < level.players.size; i++)
                {
                    level.players[i] restore_player_data();   
                }

                // When a new player connects, read in their saved state
                callback::on_connect(&on_player_connect);

                // Restore Power
                power_on = GetDvarInt("ARCHIPELAGO_LOAD_DATA_POWER_ON", 0);
                if (power_on > 0)
                {
                    trig = getent("use_power_switch", "targetname");
                    trig notify("trigger");
                }

                // Open doors
                SetDvar("zombie_unlock_all", 1);
                zombie_doors = GetEntArray("zombie_door", "targetname");
                doors_str = GetDvarString("ARCHIPELAGO_LOAD_DATA_OPENED_DOORS", "");
                if (doors_str != "")
                {
                    door_ids = strtok(doors_str, ";");
                    foreach (door_id_str in door_ids)
                    {
                        door_id = int(door_id_str);
                        if (isdefined(zombie_doors[door_id]))
                        {
                            zombie_doors[door_id] notify("trigger", level.players[0], true);
                        }
                    }
                }

                // Open debris
                zombie_debris = GetEntArray("zombie_debris", "targetname");
                debris_str = GetDvarString("ARCHIPELAGO_LOAD_DATA_OPENED_DEBRIS", "");
                if (debris_str != "")
                {
                    debris_ids = strtok(debris_str, ";");
                    foreach (debris_id_str in debris_ids)
                    {
                        debris_id = int(debris_id_str);
                        for (i = 0; i < zombie_debris.size; i++)
                        {
                            if (zombie_debris[i].id === debris_id)
                            {
                                IPrintLn("Opening id: " + debris_id);
                                zombie_debris[i] notify("trigger", level.players[0], true);
                                break;
                            }
                        }
                    }
                }
                level thread _unset_unlock_all();

                // Update round number
                
                round_number = GetDvarInt("ARCHIPELAGO_LOAD_DATA_ROUND", 0);
                if (round_number > 1) {
                    level thread archi_core::change_to_round(round_number);
                }
            }
            break;
        }
    }
}

function _unset_unlock_all()
{
    wait(0.5);
    SetDvar("zombie_unlock_all", 0);
}

function on_player_connect()
{
    self restore_player_data();
}

function restore_player_data()
{
    xuid = self GetXuid();

    can_restore = GetDvarString("ARCHIPELAGO_LOAD_DATA_XUID_READY_" + xuid, "");
    if (can_restore != "")
    {
        IPrintLn("Restoring player " + xuid);    
        // We have a slot, let's try and read it back
        score = GetDvarInt("ARCHIPELAGO_LOAD_DATA_XUID_SCORE_" + xuid, 0);
        score_diff = score - self.score;
        if (score_diff > 0)
        {
            self zm_score::add_to_player_score(score_diff);
        }

        // Restore Perks
        i = 0;
        while (true) {
            perk = GetDvarString("ARCHIPELAGO_LOAD_DATA_XUID_PERK_" + xuid + "_" + i, "");
            if (perk != "") {
                self zm_perks::give_perk(perk);
            } else {
                break;
            }
            i++;
        }

        // Restore Weapons
        i = 0;
        while (true)
        {
            weapon_name = GetDvarString("ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" + xuid + "_" + i + "_WEAPON", "");
            if (weapon_name != "")
            {
                if (i == 0) {
                    // We're restoring, so remove the starting weapon
                    self zm_weapons::weapon_take(level.start_weapon);
                }
                weapon = GetWeapon(weapon_name);
                self zm_weapons::weapon_give(weapon);
                weapon_clip = GetDvarInt("ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" + xuid + "_" + i + "_CLIP", 0);
                weapon_lh_clip = GetDvarInt("ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" + xuid + "_" + i + "_LHCLIP", 0);
                weapon_stock = GetDvarInt("ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" + xuid + "_" + i + "_STOCK", 0);
                weapon_alt_clip = GetDvarInt("ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" + xuid + "_" + i + "_ALTCLIP", 0);
                weapon_alt_stock = GetDvarInt("ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" + xuid + "_" + i + "_ALTSTOCK", 0);
                
                self SetWeaponAmmoClip(weapon, weapon_clip);
                self SetWeaponAmmoStock(weapon, weapon_stock);
                if (weapon.dualwieldweapon != level.weaponnone)
                {
                    self SetWeaponAmmoClip(weapon.dualwieldweapon, weapon_lh_clip);
                }
                if (weapon.altweapon != level.weaponnone)
                {
                    self SetWeaponAmmoClip(weapon.altweapon, weapon_alt_clip);
                    self SetWeaponAmmoStock(weapon.altweapon, weapon_alt_stock);
                }
            } else {
                break;
            }
            i++;
        }
    } 
    else 
    {
        IPrintLn("Cannot restore player " + xuid);    
    }
}

function save_player_data()
{
    xuid = self GetXuid();
    
    SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_SCORE_" + xuid, self.score);
}

function setup_soul_catchers()
{
    level thread _all_soul_catchers_filled_thread();
}

function setup_landing_pads()
{
    // Add activate notifier on each landing pad
    landing_pads = struct::get_array("115_flinger_landing_pad", "targetname");
    array::thread_all(landing_pads, &_landing_pad_notify);

    // Listen for activation events forwarded from landing pad notifiers
    level thread _all_landing_pads_activated(landing_pads.size);
}

function setup_music_ee_trackers()
{
    level thread _track_music_dead_again();
    level thread _track_music_requiem();
}

function _track_music_dead_again()
{
    level endon("end_game");

    level waittill("initial_blackscreen_passed");

    bears_activated = 0;
    bears = struct::get_array("hs_bear", "targetname");
    array::thread_all(bears, &_track_trigger_dead_again);

    while(bears_activated < bears.size)
    {
		level waittill("ap_castle_dead_again");
        IPrintLn("Bear Activated");
        bears_activated += 1;
    }

    archi_core::send_location(level.archi.mapString + " Music EE - Dead Again");
}

function _track_trigger_dead_again()
{
    e_origin = ArrayGetClosest( self.origin, GetEntArray( "script_origin", "classname" ) );
    
    while( !IS_TRUE( e_origin.b_activated ) )
    {
        e_origin waittill( "trigger_activated" );
        // Allow e_origin's own waittill to run first so b_activated is changed
        WAIT_SERVER_FRAME
    }
    
    level notify("ap_castle_dead_again");
}

function _track_music_requiem()
{
    level endon("end_game");

    level waittill("initial_blackscreen_passed");

    gramophones_activated = 0;
    gramophones = getentarray("hs_gramophone", "targetname");
    array::thread_all(gramophones, &_track_trigger_requiem);

    while(gramophones_activated < gramophones.size)
    {
		level waittill("ap_castle_requiem");
        IPrintLn("Gramophone Activated");
        gramophones_activated += 1;
    }

    archi_core::send_location(level.archi.mapString + " Music EE - Requiem");
}

function _track_trigger_requiem()
{
    while( !IS_TRUE( self.b_activated ) )
    {
        self waittill( "trigger_activated" );
        // Allow e_origin's own waittill to run first so b_activated is changed
        WAIT_SERVER_FRAME
    }
    
    level notify("ap_castle_requiem");
}

function setup_weapon_ee_storm_bow()
{
    level thread _elemental_storm_quest_started();
    level thread _elemental_storm_beacons_thread();
    level thread _flag_to_location_thread("elemental_storm_wallrun", level.archi.mapString + " Storm Bow - Wallrun Switches");
    level thread _flag_to_location_thread("elemental_storm_batteries", level.archi.mapString + " Storm Bow - Charge the Batteries");
    level thread _flag_to_location_thread("elemental_storm_beacons_charged", level.archi.mapString + " Storm Bow - Charge the Beacons");
    level thread _flag_to_location_thread("elemental_storm_repaired", level.archi.mapString + " Storm Bow - Repair the Arrow");
    level thread _flag_to_location_thread("elemental_storm_spawned", level.archi.mapString + " Storm Bow - Forge the Bow");
}

function _flag_to_location_thread(flag, location)
{
    level endon("end_game");

    level flag::wait_till(flag);
    archi_core::send_location(location);
}

function _elemental_storm_quest_started()
{
    level endon("end_game");

    level waittill(#"hash_6d0730ef");
    archi_core::send_location(level.archi.mapString + " Storm Bow - Take Broken Arrow");
}

function _elemental_storm_beacons_thread()
{
    level endon("end_game");

    beacons = getentarray("aq_es_beacon_trig", "script_noteworthy");
    array::wait_till(beacons, "beacon_activated");
    archi_core::send_location(level.archi.mapString + " Storm Bow - Light the Beacons");
}

function _all_soul_catchers_filled_thread()
{
    level endon("end_game");

    level flag::wait_till("soul_catchers_charged");
    archi_core::send_location(level.archi.mapString + " Feed the Dragonheads");
}

function _all_landing_pads_activated(pad_count)
{
    level endon("end_game");

    pads_activated = 0;
    while (pads_activated < pad_count)
    {
        level waittill("ap_castle_landing_pad_activated");
        pads_activated += 1;
    }
    archi_core::send_location(level.archi.mapString + " Turn on all Landing Pads");
}


function _landing_pad_notify()
{
    level endon("end_game");

    level flag::wait_till(self.script_noteworthy);
    IPrintLn("Landing Pad Activated");
    level notify("ap_castle_landing_pad_activated");
}


