#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\lui_shared;
#using scripts\zm\_zm_score;


#namespace archi_core;


REGISTER_SYSTEM("archipelago_core", &__init__, &__main__)

function __init__()
{

    //Clientfields (Mostly Tracker stuff)
    //TODO Put this in a library?

    clientfield::register("world", "ap_item_juggernog", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_item_double_tap", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_item_quick_revive", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_item_speed_cola", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_item_mule_kick", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_item_wunderfizz", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_item_power_on", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_item_wallbuys", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);


    clientfield::register("world", "ap_item_region_1", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_item_region_2", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_item_region_3", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_item_region_4", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_item_region_5", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_item_region_6", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);

    clientfield::register("world", "ap_weapon_ar_icr", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_hvk", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_manowar", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_m8a7", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_sheiva", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_kn44", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_ffar", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_garand", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_peacekeeper", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_an94", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_galil", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_m14", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_m16", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_basilisk", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_xr2", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
    clientfield::register("world", "ap_weapon_ar_stg44", VERSION_SHIP, 2, "int", &zm_utility::setSharedInventoryUIModels, false, true);
}

function __main__()
{
    
}