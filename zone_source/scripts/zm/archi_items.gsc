#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\math_shared;
#using scripts\shared\laststand_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\craftables\_zm_craftables;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_perks.gsh;

#insert scripts\zm\archi_core.gsh;

#namespace archi_items;

function RegisterBoxWeapon(itemName, weapon_name, weapon_bit)
{
    item = SpawnStruct();
    item.type = "box_weapon";
    item.name = level.archi.mapString + " " + itemName;
    item.weapon_name = weapon_name;
    item.count = 0;

    weapon = GetWeapon(weapon_name);
    if (isdefined(weapon))
    {
        z_weapon = level.zombie_weapons[weapon];
        if (isdefined(z_weapon))
        {
            z_weapon.is_in_box = 0;
            level.archi.ap_weapon_bits[weapon_name] = weapon_bit;
            level.archi.ap_box_states[weapon_name] = 1;
        }
        else
        {
            IPrintLn("Weapon found but not in zombie_weapons: " + weapon_name);
        }
    }
    else
    {
        IPrintLn("Weapon not found: " + weapon_name);
    }

    globalItem = SpawnStruct();
    globalItem.type = "box_weapon";
    globalItem.name = itemName;
    globalItem.weapon_name = weapon_name;
    globalItem.count = 0;
        
    level.archi.items[globalItem.name] = globalItem;
    level.archi.items[item.name] = item;
}

function RegisterItem(itemName, getFunc, clientField, universal) {
    globalItem = SpawnStruct();
    globalItem.name = level.archi.mapString + " " + itemName;
    globalItem.getFunc = getFunc;
    globalItem.clientfield = clientField;
    globalItem.count = 0;

    if (IS_TRUE(universal)) {
        item = SpawnStruct();
        item.name = itemName;
        item.getFunc = getFunc;
        item.clientfield = clientField;
        item.count = 0;

        level.archi.items[itemName] = item;
    }

    level.archi.items[globalItem.name] = globalItem;
}

function RegisterUniversalItem(itemName, getFunc, clientField) {
    item = SpawnStruct();
    item.name = itemName;
    item.getFunc = getFunc;
    item.clientfield = clientField;
    item.count = 0;

    level.archi.items[itemName] = item;
}


function RegisterWeapon(itemName, getFunc, consoleName) {
    level.archi.wallbuy_mappings[consoleName] = itemName;
    level.archi.wallbuys[consoleName] = false;

    item = SpawnStruct();
    item.name = itemName;
    item.getFunc = getFunc;
    //item.clientfield = "ap_weapon_" + consoleName;
    item.count = 0;

    globalItem = SpawnStruct();
    globalItem.name = level.archi.mapString + " " + itemName;
    globalItem.getFunc = getFunc;
    //globalItem.clientfield = "ap_weapon_" + consoleName;
    globalItem.count = 0;

    level.archi.weapons[consoleName] = false;
    level.archi.items[item.name] = item;
    level.archi.items[globalItem.name] = globalItem;
}

function RegisterPerk(itemName, getFunc, specialtyName) {
    item = SpawnStruct();
    item.name = itemName;
    item.getFunc = getFunc;
    item.clientfield = "ap_item_" + specialtyName;
    item.count = 0;

    globalItem = SpawnStruct();
    globalItem.name = level.archi.mapString + " " + itemName;
    globalItem.getFunc = getFunc;
    globalItem.clientfield = "ap_item_" + specialtyName;
    globalItem.count = 0;

    level.archi.active_perk_machines[specialtyName] = false;
    level.archi.items[item.name] = item;
    level.archi.items[globalItem.name] = globalItem;
}

//General/Universal gives
function give_500Points()
{
    foreach (player in getPlayers())
    {
        player zm_score::add_to_player_score(500);
    }
}

function give_50000Points()
{
    foreach (player in getPlayers())
    {
        player zm_score::add_to_player_score(50000);
    }
}

function give_50Points()
{
    foreach (player in getPlayers())
    {
        player zm_score::add_to_player_score(50);
    }
}

//The Giant Functions

function give_TheGiantRandomPerk()
{
    //TODO: This doesnt work yet. just setting the flag doesnt do it
    
    //Just set the EE to complete, which auto turns on the machine.
    //level flag::set("snow_ee_completed");
}

// Progressive Perk Limits
function give_ProgressivePerkLimit()
{
    level.archi.progressive_perk_limit += 1;
}

function give_ProgressivePap()
{
    item = level.archi.items["Progressive - Pack-A-Punch Machine"];
    if (isdefined(item))
    {
        if (item.count == 1)
        {
            // Unlock pap
            level.archi.pap_active = true;
            level notify("Pack_A_Punch_on");
        }
        if (item.count == 2)
        {
            level notify("ap_aats_enabled");
            wait(0.1);
            vending_weapon_upgrade_trigger = zm_pap_util::get_triggers();
            foreach (trigger in vending_weapon_upgrade_trigger)
            {
                trigger.aat_cost = 2500;
            }
        }
    }
}

function give_Pap()
{
    level.archi.pap_active = true;
    level notify("Pack_A_Punch_on");
}

function give_Perk(perk)
{
    if (isdefined(level._custom_perks[perk]))
    {
        s_custom_perk = level._custom_perks[perk];
        level.archi.active_perk_machines[perk] = true;
        level notify(s_custom_perk.alias + "_on");
        level notify("ap_update_wunderfizz");
    }

}

//Simple Give Functions notifies
function give_Juggernog()
{
    give_Perk(PERK_JUGGERNOG);
}
function give_QuickRevive()
{
    give_Perk(PERK_QUICK_REVIVE);
}
function give_SpeedCola()
{
    give_Perk(PERK_SLEIGHT_OF_HAND);
}
function give_DoubleTap()
{
    give_Perk(PERK_DOUBLETAP2);
}
function give_StaminUp()
{
    give_Perk(PERK_STAMINUP);
}
function give_MuleKick()
{
    give_Perk(PERK_ADDITIONAL_PRIMARY_WEAPON);
}
function give_DeadShot()
{
    give_Perk(PERK_DEAD_SHOT);
}
function give_WidowsWine()
{
    give_Perk(PERK_WIDOWS_WINE);
}
function give_ElectricCherry()
{
    give_Perk(PERK_ELECTRIC_CHERRY);
}

// Weapons
// Assault Rifles
function give_Weapon_ICR()
{
    enableWallbuy("ar_accurate");
}

function give_Weapon_HVK()
{
    enableWallbuy("ar_cqb");
}

function give_Weapon_ManOWar()
{
    enableWallbuy("ar_damage");
}

function give_Weapon_M8A7()
{
    enableWallbuy("ar_longburst");
}

function give_Weapon_Sheiva()
{
    enableWallbuy("ar_marksman");
}

function give_Weapon_KN44()
{
    enableWallbuy("ar_standard");
}

function give_Weapon_FFAR()
{
    enableWallbuy("ar_famas");
}

function give_Weapon_Garand()
{
    enableWallbuy("ar_garand");
}

function give_Weapon_Peacekeeper()
{
    enableWallbuy("ar_peacekeeper");
}

function give_Weapon_AN94()
{
    enableWallbuy("ar_an94");
}

function give_Weapon_Galil()
{
    enableWallbuy("ar_galil");
}

function give_Weapon_M14()
{
    enableWallbuy("ar_m14");
}

function give_Weapon_M16()
{
    enableWallbuy("ar_m16");
}

function give_Weapon_Basilisk()
{
    enableWallbuy("ar_pulse");
}

function give_Weapon_XR2()
{
    enableWallbuy("ar_fastburst");
}

function give_Weapon_STG44()
{
    enableWallbuy("ar_stg44");
}

// Light Machine Guns
function give_Weapon_Dingo()
{
    enableWallbuy("lmg_cqb");
}

function give_Weapon_Dredge()
{
    enableWallbuy("lmg_heavy");
}

function give_Weapon_BRM()
{
    enableWallbuy("lmg_light");
}

function give_Weapon_Gorgon()
{
    enableWallbuy("lmg_slowfire");
}

function give_Weapon_R70Ajax()
{
    enableWallbuy("lmg_infinite");
}

function give_Weapon_RPK()
{
    enableWallbuy("lmg_rpk");
}

function give_Weapon_MG08()
{
    enableWallbuy("lmg_mg08");
}

// Sub Machine Guns
function give_Weapon_Pharo()
{
    enableWallbuy("smg_burst");
}

function give_Weapon_Weevil()
{
    enableWallbuy("smg_capacity");
}

function give_Weapon_Vesper()
{
    enableWallbuy("smg_fastfire");
}

function give_Weapon_Kuda()
{
    enableWallbuy("smg_standard");
}

function give_Weapon_VMP()
{
    enableWallbuy("smg_versatile");
}

function give_Weapon_Bootlegger()
{
    enableWallbuy("smg_sten");
}

function give_Weapon_HG40()
{
    enableWallbuy("smg_mp40");
}

function give_Weapon_PPSH()
{
    enableWallbuy("smg_ppsh");
}

function give_Weapon_Razorback()
{
    enableWallbuy("smg_thompson");
}

function give_Weapon_AK47u()
{
    enableWallbuy("smg_ak47u");
}

function give_Weapon_MSMC()
{
    enableWallbuy("smg_msmc");
}

function give_Weapon_Nailgun()
{
    enableWallbuy("smg_nailgun");
}

function give_Weapon_HLX4()
{
    enableWallbuy("smg_rechamber");
}

function give_Weapon_Sten()
{
    enableWallbuy("smg_sten2");
}

function give_Weapon_MP40()
{
    enableWallbuy("smg_mp40_1940");
}

// Shotguns
function give_Weapon_Haymaker()
{
    enableWallbuy("shotgun_fullauto");
}

function give_Weapon_Argus()
{
    enableWallbuy("shotgun_precision");
}

function give_Weapon_KRM()
{
    enableWallbuy("shotgun_pump");
}

function give_Weapon_Brecci()
{
    enableWallbuy("shotgun_semiauto");
}

function give_Weapon_Banshii()
{
    enableWallbuy("shotgun_energy");
}

function give_Weapon_Olympia()
{
    enableWallbuy("shotgun_olympia");
}

// Pistols
function give_Weapon_Bloodhound()
{
    enableWallbuy("pistol_revolver38");
}

function give_Weapon_MR6()
{
    enableWallbuy("pistol_standard");
}

function give_Weapon_RK5()
{
    enableWallbuy("pistol_burst");
}

function give_Weapon_LCAR()
{
    enableWallbuy("pistol_fullauto");
}

function give_Weapon_RiftE9()
{
    enableWallbuy("pistol_energy");
}

function give_Weapon_M1911()
{
    enableWallbuy("pistol_m1911");
}

function give_Weapon_Marshal()
{
    enableWallbuy("pistol_shotgun_dw");
}

function give_Weapon_Mauser()
{
    enableWallbuy("pistol_c96");
}

// Melee

function give_Weapon_BowieKnife()
{
    enableWallbuy("melee_bowie");
}

// Shield Parts

function give_ShieldPart_Dolly()
{
    give_piece("craft_shield_zm", "dolly");
}

function give_ShieldPart_Door()
{
    give_piece("craft_shield_zm", "door");
}

function give_ShieldPart_Clamp()
{
    give_piece("craft_shield_zm", "clamp");
}

function give_piece(craftableName, pieceName)
{
    level.archi.craftable_parts[craftableName + "_" + pieceName] = true;
    zm_craftables::player_get_craftable_piece(craftableName, pieceName);
}

// function give_PackAPunch()
// {
//     level notify ("ap_Pack_A_Punch_on");
//     util::wait_network_frame();
// }

// Traps

function give_Trap_ThirdPerson()
{
    level thread _give_Trap_ThirdPerson();
}

function give_Trap_NukePowerup()
{
    _drop_powerup("nuke");
}

function give_Trap_GrenadeParty()
{
    foreach (player in level.players)
    {
        if (IsAlive(player))
        {
            player thread _grenadeparty();
        }
    }
}

function _grenadeparty()
{
    self endon("disconnect");

    spawn_point = (self.origin[0], self.origin[1], self.origin[2] + 1);
    g_weapon = GetWeapon("frag_grenade");
    g_count = RandomIntRange(3, 5);
    for (i = 0; i < g_count; i++)
    {
        wait(0.3);
        x_dir = RandomIntRange(30, 60);
        y_dir = RandomIntRange(30, 60);
        if (math::cointoss())
        {
            x_dir = -x_dir;
        }
        if (math::cointoss())
        {
            y_dir = -y_dir;
        }
        self MagicGrenadeType(g_weapon, spawn_point, (x_dir, y_dir, 300), 5);
    }
}

function _give_Trap_ThirdPerson()
{
    SetDvar("cg_thirdPerson", 1);
    wait(30);
    SetDvar("cg_thirdPerson", 0);
}

function give_Trap_KnuckleCrack()
{
    foreach (player in level.players)
    {
        if (IsAlive(player))
        {
            p_weapon = player GetCurrentWeapon();
            if (p_weapon.name != "zombie_knuckle_crack")
            {
                player thread _Trap_KnuckleCrack();
            }
        }
    }
}

// See _zm_pack_a_punch.gsc
function _Trap_KnuckleCrack()
{
    self endon(#"disconnect");
	self knuckle_crack_start();
	self util::waittill_any("fake_death", "death", "player_downed", "weapon_change_complete");
	self knuckle_crack_end();
}

function knuckle_crack_start()
{
    self zm_utility::increment_is_drinking();
	self zm_utility::disable_player_move_states(1);
	primaries = self getweaponslistprimaries();
	original_weapon = self getcurrentweapon();
	weapon = getweapon("zombie_knuckle_crack");
	if(original_weapon != level.weaponnone && !zm_utility::is_placeable_mine(original_weapon) && !zm_equipment::is_equipment(original_weapon))
	{
		self notify(#"zmb_lost_knife");
		// self takeweapon(original_weapon);
	}
	else
	{
		return;
	}
	self giveweapon(weapon);
	self switchtoweapon(weapon);
    self DisableWeaponCycling();
}

function knuckle_crack_end()
{
    self zm_utility::enable_player_move_states();
	weapon = getweapon("zombie_knuckle_crack");
    self EnableWeaponCycling();
	if(self laststand::player_is_in_laststand() || (isdefined(self.intermission) && self.intermission))
	{
		self takeweapon(weapon);
		return;
	}
	self zm_utility::decrement_is_drinking();
	self takeweapon(weapon);
	primaries = self getweaponslistprimaries();
	if(self.is_drinking > 0)
	{
		return;
	}
	self zm_weapons::switch_back_primary_weapon();
}

// Gifts

function give_Gift_UnlimitedSprint()
{
    level thread _Gift_UnlimitedSprint();
}

function _Gift_UnlimitedSprint()
{
    SetDvar("player_sprintUnlimited", 1);
    wait(120);
    SetDvar("player_sprintUnlimited", 0);
}

function give_Gift_CarpenterPowerup()
{
    _drop_powerup("carpenter");
}

function give_Gift_DoublePointsPowerup()
{
    _drop_powerup("double_points");
}

function give_Gift_InstaKillPowerup()
{
    _drop_powerup("insta_kill");
}

function give_Gift_FireSalePowerup()
{
    _drop_powerup("fire_sale");
}

function give_Gift_FreePerkPowerup()
{    
    _drop_powerup("free_perk");
}

function give_Gift_MaxAmmoPowerup()
{
    _drop_powerup("full_ammo");
}

function _drop_powerup(powerup)
{
    players = GetPlayers();
    if (players.size > 0) 
    {
        powerup_drop = level zm_powerups::specific_powerup_drop(powerup, players[0].origin);
    }
}

// Utils

function enableWallbuy(itemName)
{
    if (isdefined(level.archi.wallbuys))
    {
        level.archi.wallbuys[itemName] = true;
    }
}

function checkItem(itemName)
{
    return (isdefined(level.archi.items[itemName]) && level.archi.items[itemName].count>0);
}
