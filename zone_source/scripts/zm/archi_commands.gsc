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

#namespace archi_commands;

function init_commands()
{
  level thread _send_location_command_response();
}

function private _send_location_command_response(command_args)
{
  level endon("end_game");

  ModVar("ap_send_location", "");

  while ( 1 )
  {
    WAIT_SERVER_FRAME

    dvar_value = GetDvarString("ap_send_location", "");

    if(isdefined(dvar_value) && dvar_value != "")
    {
      IPrintLn("Reading Send Location Command...");
      ModVar("ap_send_location", "");

      archi_core::send_location(dvar_value);
    }
  }
}