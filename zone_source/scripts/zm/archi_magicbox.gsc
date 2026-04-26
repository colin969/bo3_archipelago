#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_unitrigger;

#using scripts\zm\archi_core;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

function init()
{
    if(!isdefined(level.chests))
    {
        return;
    }
    if(level.chests.size == 0)
	{
		return;
	}

    for(i = 0; i < level.chests.size; i++)
	{
       level.chests[i] patch_chest_triggers();
    }
}

function patch_chest_triggers()
{
    if (isdefined(self.unitrigger_stub) && !(isdefined(self.ap_original_data)))
    {
        if (isdefined(self.unitrigger_stub.prompt_and_visibility_func))
        {
            self.unitrigger_stub.ap_original_prompt_and_visibility_func = self.unitrigger_stub.prompt_and_visibility_func;
            self.unitrigger_stub.prompt_and_visibility_func = &magicbox_visibility_func;
        }
    }
}

function magicbox_visibility_func(player)
{
    can_use = self [[self.stub.ap_original_prompt_and_visibility_func]](player);
    if (can_use)
    {
        // The map thinks the trigger is visible, let's make sure there's a weapon they can actually get
        keys = GetArrayKeys(level.zombie_weapons);
        pap_triggers = zm_pap_util::get_triggers();
        weapon_found = 0;
        for(i = 0; i < keys.size; i++)
        {
            if(zm_magicbox::treasure_chest_canplayerreceiveweapon(player, keys[i], pap_triggers))
            {
                weapon_found = 1;
                break;
            }
        }
        // Did not find a valid weapon in the box, hide the trigger
        if (weapon_found == 0)
        {
            self SetHintString("No unlocked weapons available");
            return false;
        }
    }
    return can_use;
}