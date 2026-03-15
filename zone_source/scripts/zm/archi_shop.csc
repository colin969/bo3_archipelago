#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

REGISTER_SYSTEM_EX( "archi_shop", &__init__, &__main__, undefined )

function __init__()
{
    if(!isdefined(level.ap_models))
    {
        level.ap_models = [];
    }

    callback::on_localclient_connect(&on_player_connected);

    LuiLoad( "ui.uieditor.menus.ApShop.ApShop_Main" );
}

function __main__()
{
}

function on_player_connected(localClientNum)
{
    level.ap_models["PerkTokens"] = createModel(localClientNum, "PerkTokens");
    level.ap_models["GumTokens"] = createModel(localClientNum, "GumTokens");
    level.ap_models["RareGumTokens"] = createModel(localClientNum, "RareGumTokens");
    level.ap_models["LegendaryGumTokens"] = createModel(localClientNum, "LegendaryGumTokens");

    util::register_system("PerkTokens", &updatePerkTokens);
    util::register_system("GumTokens", &updateGumTokens);
    util::register_system("RareGumTokens", &updateRareGumTokens);
    util::register_system("LegendaryGumTokens", &updateLegendaryGumTokens);
}

function createModel(localClientNum, fieldName)
{ 
    model = CreateUIModel(GetUIModelForController(localClientNum), fieldName);
    SetUIModelValue(model, 5);
    return model;
}

function updatePerkTokens(localClientNum, newVal, oldVal)
{
    if (isdefined(level.ap_models["PerkTokens"]))
    {
        SetUIModelValue(level.ap_models["PerkTokens"], newVal);
    }
}

function updateGumTokens(localClientNum, newVal, oldVal)
{
    if (isdefined(level.ap_models["GumTokens"]))
    {
        SetUIModelValue(level.ap_models["GumTokens"], newVal);
    }
}

function updateRareGumTokens(localClientNum, newVal, oldVal)
{
    if (isdefined(level.ap_models["RareGumTokens"]))
    {
        SetUIModelValue(level.ap_models["RareGumTokens"], newVal);
    }
}

function updateLegendaryGumTokens(localClientNum, newVal, oldVal)
{
    if (isdefined(level.ap_models["LegendaryGumTokens"]))
    {
        SetUIModelValue(level.ap_models["LegendaryGumTokens"], newVal);
    }
}
