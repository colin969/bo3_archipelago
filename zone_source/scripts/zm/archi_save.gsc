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
#using scripts\shared\math_shared;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;

#using scripts\zm\archi_core;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\archi_core.gsh;

// Common functions for save states, use them in individual map support

// Wait for the restore to be ready
function wait_restore_ready(mapName)
{
    level flag::wait_till("initial_blackscreen_passed");

    SetDvar("ARCHIPELAGO_LOAD_DATA", mapName);
    LUINotifyEvent(&"ap_load_data", 0);

    while(true)
    {
        WAIT_SERVER_FRAME
        dvar_value = GetDvarString("ARCHIPELAGO_LOAD_DATA", "");
        if (dvar_value == "NONE")
        {
            break;
        }
    }
}

function restore_round_number()
{
    round_number = GetDvarInt("ARCHIPELAGO_LOAD_DATA_ROUND", 0);
    if (round_number > 1) {
        level thread archi_core::change_to_round(round_number);
        SetDvar("ARCHIPELAGO_LOAD_DATA_ROUND", 0);
    }
}

function restore_power_on()
{
    power_on = GetDvarInt("ARCHIPELAGO_LOAD_DATA_POWER_ON", 0);
    if (power_on > 0)
    {
        trig = getent("use_power_switch", "targetname");
        if (isdefined(trig))
        {
            trig notify("trigger");
            SetDvar("ARCHIPELAGO_LOAD_DATA_POWER_ON", 0);
        }
        trig = getent("use_master_switch", "targetname");
        if (isdefined(trig))
        {
            trig notify("trigger");
            SetDvar("ARCHIPELAGO_LOAD_DATA_POWER_ON", 0);
        }
        trig = getent("use_elec_switch", "targetname");
        if (isdefined(trig))
        {
            trig notify("trigger");
            SetDvar("ARCHIPELAGO_LOAD_DATA_POWER_ON", 0);
        }
    }
}

function restore_players(restore_player_data)
{
    for(i = 0; i < level.players.size; i++)
    {
        xuid = level.players[i] GetXuid();
        level.players[i] [[restore_player_data]]();   
        IPrintLn("Restored player " + xuid);
    }

    // When a new player connects, read in their saved state
    callback::on_connect(restore_player_data);
}

function restore_doors_and_debris()
{
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
        SetDvar("ARCHIPELAGO_LOAD_DATA_OPENED_DOORS", "");
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
                    zombie_debris[i] notify("trigger", level.players[0], true);
                    break;
                }
            }
        }
        SetDvar("ARCHIPELAGO_LOAD_DATA_OPENED_DEBRIS", "");
    }
    level thread _unset_unlock_all();
}

// Check if a player can be restored
function can_restore_player(xuid)
{
    can_restore = GetDvarString("ARCHIPELAGO_LOAD_DATA_XUID_READY_" + xuid, "");
    if (can_restore != "") {
        return true;
        SetDvar("ARCHIPELAGO_LOAD_DATA_XUID_READY_" + xuid, "");
    }
    return false;
}

// self is player
function restore_player_score(xuid)
{
    score = GetDvarInt("ARCHIPELAGO_LOAD_DATA_XUID_SCORE_" + xuid, 0);
    SetDvar("ARCHIPELAGO_LOAD_DATA_XUID_SCORE_" + xuid, 0);
    score_diff = score - self.score;
    if (score_diff > 0)
    {
        self zm_score::add_to_player_score(score_diff);
    }
}

function restore_player_perks(xuid)
{
    i = 0;
    while (true) {
        perk = GetDvarString("ARCHIPELAGO_LOAD_DATA_XUID_PERK_" + xuid + "_" + i, "");
        if (perk != "") {
            SetDvar("ARCHIPELAGO_LOAD_DATA_XUID_PERK_" + xuid, "");
            self zm_perks::give_perk(perk);
        } else {
            break;
        }
        i++;
    }
}

function restore_player_loadout(xuid)
{
    // Restore Hero Weapon
    hero_weapon_name = GetDvarString("ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" + xuid + "_HEROWEAPON", "");
    if (hero_weapon_name != "")
    {  
        weapon = GetWeapon(hero_weapon_name);
        self zm_weapons::weapon_give(weapon, 0, 0, 1, 0);
        hero_power = GetDvarInt("ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" + xuid + "_HEROWEAPON_POWER" , -1);
        if (hero_power >= 0)
        {
            WAIT_SERVER_FRAME
            IPrintLn("Setting power to " + hero_power);
            self GadgetPowerSet(0, hero_power);
        }
    }

    // Restore Weapons
    i = 0;
    while (true)
    {
        weapon_name = GetDvarString("ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" + xuid + "_" + i + "_WEAPON", "");
        SetDvar("ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" + xuid + "_" + i + "_WEAPON", "");
        if (weapon_name != "")
        {
            if (i == 0) {
                // We're restoring, so remove the starting weapon
                self zm_weapons::weapon_take(level.start_weapon);
            }
            weapon = GetWeapon(weapon_name);
            self zm_weapons::weapon_give(weapon, 0, 0, 1);
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

function send_save_data(mapName)
{
    SetDvar("ARCHIPELAGO_SAVE_DATA", mapName);
    LUINotifyEvent(&"ap_save_data", 0);
}

function save_round_number()
{
    SetDvar("ARCHIPELAGO_SAVE_DATA_ROUND", level.round_number);
}

function save_power_on()
{
    if (level flag::get("power_on"))
    {
        SetDvar("ARCHIPELAGO_SAVE_DATA_POWER_ON", 1);
    } else {
        SetDvar("ARCHIPELAGO_SAVE_DATA_POWER_ON", 0);
    }
}

function save_doors_and_debris()
{
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
}

function save_players(save_player_data)
{
    xuidString = "";
    for(i = 0; i < level.players.size; i++)
    {
        e_player = level.players[i];
        xuid = e_player GetXuid();
        xuidString += xuid + ";";
        e_player [[save_player_data]](xuid);
        IPrintLn("Saved player " + xuid);
    }
    SetDvar("ARCHIPELAGO_SAVE_DATA_XUIDS", xuidString);
}

function save_player_score(xuid)
{
    SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_SCORE_" + xuid, self.score);
}

function save_player_perks(xuid)
{
    perks = self GetPerks();
    for (i = 0; i < perks.size; i++)
    {
        SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_PERK_" + xuid + "_" + i, perks[i]);
    }
}

function save_player_loadout(xuid)
{
    hero_weapon = self zm_utility::get_player_hero_weapon();
    if (hero_weapon != level.weaponnone) 
    {
        SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_HEROWEAPON", hero_weapon.name);
        SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_HEROWEAPON_POWER", math::clamp(self.hero_power, 0, 100));
    }

    loadout = self zm_weapons::player_get_loadout();
    i = 0;
    foreach ( weapon in loadout.weapons ) 
    {
        // Don't save the hero weapon
        if (weapon["weapon"].name == hero_weapon.name)
        {
            continue;
        }
        SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_" + i + "_WEAPON", weapon["weapon"].name);
        SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_" + i + "_CLIP", weapon["clip"]);
        SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_" + i + "_STOCK", weapon["stock"]);
        SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_" + i + "_LHCLIP", weapon["lh_clip"]);
        SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_" + i + "_ALTCLIP", weapon["alt_clip"]);
        SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" + xuid + "_" + i + "_ALTSTOCK", weapon["alt_stock"]);
        i++;
    }
}

function _unset_unlock_all()
{
    wait(0.5);
    SetDvar("zombie_unlock_all", 0);
}

function save_flag(flag)
{
    if (level flag::get(flag))
    {
        SetDvar("ARCHIPELAGO_SAVE_DATA_MAP_" + ToUpper(flag), 1);
    }
    else
    {
        SetDvar("ARCHIPELAGO_SAVE_DATA_MAP_" + ToUpper(flag), 0);
    }
}

function restore_flag(flag)
{
    dvar_value = GetDvarInt("ARCHIPELAGO_LOAD_DATA_MAP_" + ToUpper(flag), 0);
    if (dvar_value > 0)
    {
        level flag::set(flag);
    }
}

// Self is player
function save_player_flag(flag, xuid)
{
    if (self flag::get(flag))
    {
        SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_" + xuid + "_MAP_" + ToUpper(flag), 1);
    }
    else
    {
        SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_" + xuid + "_MAP_" + ToUpper(flag), 0);
    }
}

// Self is player
function restore_player_flag(flag, xuid)
{
    dvar_value = GetDvarInt("ARCHIPELAGO_LOAD_DATA_XUID_" + xuid + "_" + ToUpper(flag), 0);
    if (dvar_value > 0)
    {
        self flag::set(flag);
    }
}