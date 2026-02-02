#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\hud_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\clientfield_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\archi_core.gsh;

#using scripts\zm\archi_core;

#namespace archi_commands;

function init_commands()
{
  // Regular commands
  level thread _send_message_response();

  // Development commands
  if (IS_TRUE(ARCHIPELAGO_DEV_MODE))
  {
    level thread _send_location_command_response();
    level thread _trigger_item_response();
    level thread _print_debug_craftableStubs_response();
    level thread _print_debug_settings();
    level thread _force_save_response();
    level thread _godmode_response();
    level thread _debug_magicbox_response();
  }
}

function private _send_location_command_response(command_args)
{
  level endon("end_game");

  // Set intiial empty value
  ModVar("ap_send_location", "");

  while(true)
  {
    WAIT_SERVER_FRAME

    // Each frame, check if ap_send_location has been changed
    dvar_value = GetDvarString("ap_send_location", "");

    if(isdefined(dvar_value) && dvar_value != "")
    {
      // ap_send_location has changed, clear it and pass the value to send_location
      ModVar("ap_send_location", "");

      archi_core::send_location(dvar_value);
    }
  }
}

function private _send_message_response(command_args)
{
  level endon("end_game");

  ModVar("ap", "");

  while(true)
  {
    WAIT_SERVER_FRAME

    dvar_value = GetDvarString("ap", "");

    if(isdefined(dvar_value) && dvar_value != "")
    {
      ModVar("ap", "");
      SetDvar("ARCHIPELAGO_SAY_SEND", dvar_value);
      LUINotifyEvent(&"ap_notification", 0);

      //Send notification for Send UI Image
      LUINotifyEvent(&"ap_ui_send", 0);
    }
  }
}

function private _trigger_item_response(command_args)
{
  level endon("end_game");

  ModVar("ap_trigger_item", "");

  level flag::wait_till("initial_blackscreen_passed");

  while(true)
  {
    WAIT_SERVER_FRAME

    dvar_value = GetDvarString("ap_trigger_item", "");

    if(isdefined(dvar_value) && dvar_value != "")
    {
      ModVar("ap_trigger_item", "");
      if (isdefined(level.archi.items[dvar_value]))
      {
          archi_core::award_item(dvar_value);
          IPrintLn("Given Item " + dvar_value);
      }
      else
      {
        IPrintLn("Item not found");
      }
    }
  }
}

function private _print_debug_settings()
{
  level endon("end_game");

  ModVar("ap_debug_settings", "");

  while(true)
  {
    WAIT_SERVER_FRAME

    dvar_value = GetDvarString("ap_debug_settings", "");

    if (isdefined(dvar_value) && dvar_value != "") {
      ModVar("ap_debug_settings", "");

      IPrintLn("Settings Ready: " + level flag::get("ap_settings_ready"));
      IPrintLn("Perk Limit Modifier: " + level.archi.perk_limit_default_modifier);
      IPrintLn("Perk Limit Increase: " + level.archi.progressive_perk_limit);
      IPrintLn("Randomized Shield Parts: " + level.archi.randomized_shield_parts);
      IPrintLn("Randomized Box WW: " + level.archi.randomized_box_wonder_weapons);
    }
  }
}

function private _force_save_response()
{
  level endon("end_game");

  ModVar("ap_save", "");

  while(true)
  {
    WAIT_SERVER_FRAME

    dvar_value = GetDvarString("ap_save", "");

    if(isdefined(dvar_value) && dvar_value != "")
    {
      ModVar("ap_save", "");

      if (isdefined(level.archi.save_state))
      {
        [[level.archi.save_state]]();
      }
    }
  }
}

function private _print_debug_craftableStubs_response()
{
  level endon("end_game");

  ModVar("ap_debug_craftables", "");

  while(true)
  {
    WAIT_SERVER_FRAME

    dvar_value = GetDvarString("ap_debug_craftables", "");

    if(isdefined(dvar_value) && dvar_value != "")
    {
      ModVar("ap_debug_craftables", "");
      foreach (name, struct in level.zombie_include_craftables)
      {
        wait(5);
        IPrintLn("Name: " + name);
        if ( isdefined (struct.weaponname))
        {
          IPrintLn("Weapon Name: " + struct.weaponname);
        }
        if ( isdefined (struct.a_pieceStubs) )
        {
          for (i = 0; i < struct.a_pieceStubs.size; i++)
          {
            piece = struct.a_pieceStubs[i];
            if ( isdefined (piece.pieceName) ) {
              IPrintLn("Piece Name: " + piece.pieceName);
            }
          }
        } else {
          IPrintLn("No Piece Structs Found");
        }
      }
    }
  }
}

function _godmode_response()
{
  level endon("end_game");

  ModVar("ap_godmode", "");

  while(true)
  {
    WAIT_SERVER_FRAME

    dvar_value = GetDvarString("ap_godmode", "");

    if(isdefined(dvar_value) && dvar_value != "")
    {
      ModVar("ap_godmode", "");
      if (dvar_value == "0") 
      {
        foreach (player in level.players)
        {
          player DisableInvulnerability();
          IPrintLn("Disable invuln for " + player.name);
        }
      }
      else
      {
        foreach (player in level.players)
        {
          player EnableInvulnerability();
          IPrintLn("Invuln for " + player.name);
        }
      }
    }
  }
}


// treasure_chest_chooseweightedrandomweapon
function _debug_magicbox_response()
{
  level endon("end_game");

  ModVar("ap_debug_magicbox", "");

  while(true)
  {
    WAIT_SERVER_FRAME

    dvar_value = GetDvarString("ap_debug_magicbox", "");

    if(isdefined(dvar_value) && dvar_value != "")
    {
      ModVar("ap_debug_magicbox", "");
      keys = getarraykeys(level.zombie_weapons);
      IPrintLn("Writing data for " + keys.size + " weapons");
      for (i = 0; i < keys.size; i++)
      {
        SetDvar("ARCHIPELAGO_DEBUG_MAGICBOX_" + i, keys[i].name);
        if (level.zombie_weapons[keys[i]].is_in_box)
        {
          SetDvar("ARCHIPELAGO_DEBUG_MAGICBOX_" + i + "_INSIDE", "true");
        } else
        {
          SetDvar("ARCHIPELAGO_DEBUG_MAGICBOX_" + i + "_INSIDE", "false");
        }
      }
      LUINotifyEvent(&"ap_debug_magicbox", 0);
      IPrintLn("Saved to magicbox.csv");
    }
  }
}