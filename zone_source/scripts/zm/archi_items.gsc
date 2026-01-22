#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;

#namespace archi_items;

function RegisterItem(itemName, getFunc,clientField) {
    item = SpawnStruct();
    item.name = itemName;
    item.getFunc = getFunc;
    item.clientfield = clientField;
    item.count = 0;

    level.archi.items[itemName] = item;
}

function RegisterWeapon(itemName, getFunc, consoleName) {
    item = SpawnStruct();
    item.name = itemName;
    item.getFunc = getFunc;
    item.clientfield = "ap_weapon_" + consoleName;

    globalItem = SpawnStruct();
    globalItem.name = level.archi.mapString + " " + itemName;
    globalItem.getFunc = getFunc;
    globalItem.clientfield = "ap_weapon_" + consoleName;

    level.archi.weapons[consoleName] = false;
    level.archi.items[item.name] = item;
    level.archi.items[globalItem.name] = globalItem;
}

function RegisterPerk(itemName, getFunc, specialtyName) {
    item = SpawnStruct();
    item.name = itemName;
    item.getFunc = getFunc;
    item.clientfield = "ap_item_" + specialtyName;

    globalItem = SpawnStruct();
    globalItem.name = level.archi.mapString + " " + itemName;
    globalItem.getFunc = getFunc;
    globalItem.clientfield = "ap_item_" + specialtyName;

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

//Map Region Give Functions

function give_The_Giant_Animal_Testing()
{
    enableBlocker(5);
    if (checkItem("(The Giant) Power Room"))
    {
        //If power room is on, give us the back entrance
        enableBlocker(10);
    }
}
function give_The_Giant_Garage()
{
    enableBlocker(4);
    if (checkItem("(The Giant) Power Room"))
    {
        //If power room is on, give us the back entrance
        enableBlocker(11);
    }
}
function give_The_Giant_Power_Room()
{
    if (checkItem("(The Giant) Animal Testing"))
    {
        //If Animal Testing is On, give us that entrance
        enableBlocker(10);
    }
    if (checkItem("(The Giant) Garage"))
    {
        //If Garage is On, give us that entrance
        enableBlocker(11);
    }
}
function give_The_Giant_Teleporter_1()
{
    enableBlocker(6);
}
function give_The_Giant_Teleporter_2()
{
    enableBlocker(7);
}
function give_The_Giant_Teleporter_3()
{
    enableBlocker(0);
}


//Simple Give Functions notifies
function give_SpeedCola()
{
    level notify( "ap_sleight_on" );
	util::wait_network_frame();
	level notify("ap_specialty_fastreload_power_on");
}
function give_QuickRevive()
{
    level notify( "ap_revive_on" );
    util::wait_network_frame();
	level notify("ap_specialty_quickrevive_power_on");
}
function give_DoubleTap()
{
    level notify( "ap_doubletap_on" );
    util::wait_network_frame();
	level notify("ap_specialty_rof_power_on");
}
function give_Juggernog()
{
    level notify("ap_juggernog_on");
    util::wait_network_frame();
	level notify("ap_specialty_armorvest_power_on");
}
function give_MuleKick()
{
	level notify("ap_additionalprimaryweapon_on");
    util::wait_network_frame();
    level notify("ap_specialty_additionalprimaryweapon_power_on");
}

// Weapons
// Assault Rifles
function give_Weapon_ICR()
{
    enableWeapon("ar_accurate");
}

function give_Weapon_HVK()
{
    enableWeapon("ar_cqb");
}

function give_Weapon_ManOWar()
{
    enableWeapon("ar_damage");
}

function give_Weapon_M8A7()
{
    enableWeapon("ar_longburst");
}

function give_Weapon_Sheiva()
{
    enableWeapon("ar_marksman");
}

function give_Weapon_KN44()
{
    enableWeapon("ar_standard");
}

function give_Weapon_FFAR()
{
    enableWeapon("ar_famas");
}

function give_Weapon_Garand()
{
    enableWeapon("ar_garand");
}

function give_Weapon_Peacekeeper()
{
    enableWeapon("ar_peacekeeper");
}

function give_Weapon_AN94()
{
    enableWeapon("ar_an94");
}

function give_Weapon_Galil()
{
    enableWeapon("ar_galil");
}

function give_Weapon_M14()
{
    enableWeapon("ar_m14");
}

function give_Weapon_M16()
{
    enableWeapon("ar_m16");
}

function give_Weapon_Basilisk()
{
    enableWeapon("ar_pulse");
}

function give_Weapon_XR2()
{
    enableWeapon("ar_fastburst");
}

function give_Weapon_STG44()
{
    enableWeapon("ar_stg44");
}

// Sub Machine Guns
function give_Weapon_Pharo()
{
    enableWeapon("smg_burst");
}

function give_Weapon_Weevil()
{
    enableWeapon("smg_capacity");
}

function give_Weapon_Vesper()
{
    enableWeapon("smg_fastfire");
}

function give_Weapon_Kuda()
{
    enableWeapon("smg_standard");
}

function give_Weapon_VMP()
{
    enableWeapon("smg_versatile");
}

function give_Weapon_Bootlegger()
{
    enableWeapon("smg_sten");
}

function give_Weapon_HG40()
{
    enableWeapon("smg_mp40");
}

function give_Weapon_PPSH()
{
    enableWeapon("smg_ppsh");
}

function give_Weapon_Razorback()
{
    enableWeapon("smg_thompson");
}

function give_Weapon_AK47u()
{
    enableWeapon("smg_ak47u");
}

function give_Weapon_MSMC()
{
    enableWeapon("smg_msmc");
}

function give_Weapon_Nailgun()
{
    enableWeapon("smg_nailgun");
}

function give_Weapon_HLX4()
{
    enableWeapon("smg_rechamber");
}

function give_Weapon_Sten()
{
    enableWeapon("smg_sten2");
}

function give_Weapon_MP40()
{
    enableWeapon("smg_mp40_1940");
}

// Shotguns
function give_Weapon_Haymaker()
{
    enableWeapon("shotgun_fullauto");
}

function give_Weapon_Argus()
{
    enableWeapon("shotgun_precision");
}

function give_Weapon_KRM()
{
    enableWeapon("shotgun_pump");
}

function give_Weapon_Brecci()
{
    enableWeapon("shotgun_semiauto");
}

function give_Weapon_Banshii()
{
    enableWeapon("shotgun_energy");
}

function give_Weapon_Olympia()
{
    enableWeapon("shotgun_olympia");
}

// Pistols
function give_Weapon_Bloodhound()
{
    enableWeapon("pistol_revolver38");
}

function give_Weapon_MR6()
{
    enableWeapon("pistol_standard");
}

function give_Weapon_RK5()
{
    enableWeapon("pistol_burst");
}

function give_Weapon_LCAR()
{
    enableWeapon("pistol_fullauto");
}

function give_Weapon_RiftE9()
{
    enableWeapon("pistol_energy");
}

function give_Weapon_M1911()
{
    enableWeapon("pistol_m1911");
}

function give_Weapon_Marshal()
{
    enableWeapon("pistol_shotgun_dw");
}

function give_Weapon_Mauser()
{
    enableWeapon("pistol_c96");
}

// Melee

function give_Weapon_BowieKnife()
{
    enableWeapon("melee_bowie");
}


// function give_Staminup()
// {
//     level notify ("ap_marathon_on");
//     util::wait_network_frame();
// }

// function give_Deadshot()
// {
//     level notify ("ap_deadshot_on");
//     util::wait_network_frame();
// }


// function give_PackAPunch()
// {
//     level notify ("ap_Pack_A_Punch_on");
//     util::wait_network_frame();
// }

function enableWeapon(itemName)
{
    if (isdefined(level.archi.weapons) && isdefined(level.archi.weapons[itemName]))
    {
        level.archi.weapons[itemName] = true;
    }
}

function enableBlocker(number)
{
    if (isdefined(level.archi.blockers) && isdefined(level.archi.blockers[number]))
    {
        level.archi.blockers[number] = true;
    }
}
function checkItem(itemName)
{
    return (isdefined(level.archi.items[itemName]) && level.archi.items[itemName].count>0);
}