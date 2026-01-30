#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_powerups;
#using scripts\zm\craftables\_zm_craftables;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_perks.gsh;

#insert scripts\zm\archi_core.gsh;

#namespace archi_items;

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
    item.clientfield = "ap_weapon_" + consoleName;
    item.count = 0;

    globalItem = SpawnStruct();
    globalItem.name = level.archi.mapString + " " + itemName;
    globalItem.getFunc = getFunc;
    globalItem.clientfield = "ap_weapon_" + consoleName;
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

    level.archi.items[item.name] = item;
    level.archi.items[globalItem.name] = globalItem;
}

function RegisterPap()
{
    item = SpawnStruct();
    item.name = "Pack-A-Punch Machine";
    item.getFunc = &give_Pap;
    item.clientfield = "ap_item_pap";
    item.count = 0;

    level.archi.items[item.name] = item;
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

function give_Victory()
{
    iPrintln("Giving Victory");
    //if in game, end game
    level notify("end_game");
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

function give_Pap()
{
    level.archi.pap_active = true;
    level notify("Pack_A_Punch_on");
}

function give_Perk(perk)
{
    s_custom_perk = level._custom_perks[perk];
    level.archi.active_perk_machines[perk] = true;
    level notify(s_custom_perk.alias + "_on");
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

function _give_Trap_ThirdPerson()
{
    SetDvar("cg_thirdPerson", 1);
    wait(30);
    SetDvar("cg_thirdPerson", 0);
}

// Gifts

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

function give_Gift_NukePowerup()
{
    _drop_powerup("nuke");
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
