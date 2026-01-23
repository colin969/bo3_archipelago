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

#using scripts\zm\archi_core;

#define AP_DEBUG_COMMANDS true

#namespace archi_commands;

function init_commands()
{
  // Regular commands
  level thread _send_message_response();

  // Development commands
  if (IS_TRUE(AP_DEBUG_COMMANDS))
  {
    level thread _send_location_command_response();
    level thread _trigger_item_response();
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

  level waittill("initial_blackscreen_passed");

  while(true)
  {
    WAIT_SERVER_FRAME

    dvar_value = GetDvarString("ap_trigger_item", "");

    if(isdefined(dvar_value) && dvar_value != "")
    {
      ModVar("ap_trigger_item", "");
      if (isdefined(level.archi.items[dvar_value]))
      {
          level.archi.items[dvar_value].count += 1;
          self [[level.archi.items[dvar_value].getFunc]]();

          if (isdefined(level.archi.items[dvar_value].clientField))
          {
              //TODO: make this safe, so it checks if the clientfield exists first
              level clientfield::set(level.archi.items[dvar_value].clientField, 1);
          }
          //Notif happens a bit too early compared to log messages
          wait .5;
          LUINotifyEvent(&"ap_ui_get", 0);
          IPrintLn("Given Item " + dvar_value);
      }
      else
      {
        IPrintLn("Item not found");
      }
    }
  }
}