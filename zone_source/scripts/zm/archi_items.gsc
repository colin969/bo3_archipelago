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