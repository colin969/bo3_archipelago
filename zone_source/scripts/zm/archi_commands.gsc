#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\hud_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;
#using scripts\zm\gametypes\_globallogic_score;

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
    level thread _basic_trigger("ap_grand_tour", &_start_grand_tour);
    level thread _basic_trigger("ap_sv_cheats", &_enable_cheats);
    level thread _basic_trigger("ap_set_flag", &_set_flag);
    level thread _basic_trigger("ap_set_player_flag", &_set_player_flag);
    level thread _basic_trigger("ap_testkit", &_give_testkit);
    level thread _basic_trigger("ap_debug_dragonheads", &_dragonhead_debug);
    level thread _basic_trigger("ap_debug_stats", &_test_scoreboard);
    level thread _basic_trigger("ap_gum", &_test_general);
    level thread _basic_trigger("ap_stats", &_test_scoreboard);
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
      wait(3);
      IPrintLn("Gorod - Instant Egg Cooldown: " + level.archi.difficulty_gorod_egg_cooldown);
      IPrintLn("Gorod - Starting Dragon Wings: " + level.archi.difficulty_gorod_dragon_wings);

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
        if (isdefined(level.limited_weapons[keys[i]]))
        {
          limit = level.limited_weapons[keys[i]];
          SetDvar("ARCHIPELAGO_DEBUG_MAGICBOX_" + i + "_LIMITED", "true");
          SetDvar("ARCHIPELAGO_DEBUG_MAGICBOX_" + i + "_QUOTA", limit);
        }
        else
        {
          SetDvar("ARCHIPELAGO_DEBUG_MAGICBOX_" + i + "_LIMITED", "false");
        }
      }
      LUINotifyEvent(&"ap_debug_magicbox", 0);
      IPrintLn("Saved to magicbox.csv");
    }
  }
}

function _basic_trigger(name, cb)
{
  level endon("end_game");

  ModVar(name, "");

  while(true)
  {
    WAIT_SERVER_FRAME

    dvar_value = GetDvarString(name, "");

    if(isdefined(dvar_value) && dvar_value != "")
    {
      ModVar(name, "");
      [[cb]](dvar_value);
    }
  }
}

function _start_grand_tour(val)
{
  level.var_62552381 = 1;
  level flag::set("character_stones_done");
  wait(1);
  level flag::set("phased_sophia_start");
  wait(1);
  level flag::set("grand_tour");
  wait(1);
  level.var_62552381 = 0;
}

function _enable_cheats(val)
{
  SetDvar("sv_cheats", 1);
}

function _set_player_flag(val)
{
  if (val != "")
  {
    foreach(player in level.players)
    {
      player flag::set(val);
    }
  }
}

function _set_flag(val)
{
  if (val != "")
  {
    level flag::set(val);
  }
}

function _give_testkit(val)
{
  if (val != "")
  { 
    player = level.players[0];
    player zm_utility::give_player_all_perks();
    player zm_score::add_to_player_score(100000);
    SetDvar("player_SprintUnlimited", 1);
  }
}

function _dragonhead_debug(val)
{
  if (val != "")
  { 
    foreach (dh in level.soul_catchers)
    {
      IPrintLn("Soul Catcher Fill: " + dh.var_98730ffa);
    }  
  }
}

function _test_scoreboard()
{
  foreach (player in level.players)
  {
    player.pers["headshots"] += 20;
    player.headshots = player.pers["headshots"];
    IPrintLn(player.pers["headshots"]);
  }
}

function _test_general()
{
  foreach (player in level.players)
  {
    bgb_keys = GetArrayKeys(level.bgb);
    selected_bgb = array::random(bgb_keys);
    gun = player bgb_anim_start(selected_bgb, 0);
    evt = player util::waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete", "disconnect");
    if(evt == "weapon_change_complete")
	  {
        player thread bgb::give(selected_bgb);
        player notify("bgb_gumball_anim_give", selected_bgb);
    }
    player bgb_anim_end(gun, selected_bgb, 0);
  }
}

function bgb_anim_start(bgb, activating)
{
  self zm_utility::increment_is_drinking();
	self zm_utility::disable_player_move_states(1);
	w_original = self getcurrentweapon();
	weapon = bgb_get_gumball_anim_weapon(bgb, activating);
	self giveweapon(weapon, self calcweaponoptions(level.bgb[bgb].camo_index, 0, 0));
	self switchtoweapon(weapon);
	if(weapon == level.weaponbgbgrab)
	{
		self playsound("zmb_bgb_powerup_default");
	}
	if(weapon == level.weaponbgbuse)
	{
		self clientfield::increment_to_player("bgb_blow_bubble");
	}
	return w_original;
}

function bgb_anim_end(w_original, bgb, activating)
{
  self zm_utility::enable_player_move_states();
  weapon = bgb_get_gumball_anim_weapon(bgb, activating);
	if(self laststand::player_is_in_laststand() || (isdefined(self.intermission) && self.intermission))
	{
		self takeweapon(weapon);
		return;
	}
	self takeweapon(weapon);
	if(self zm_utility::is_multiple_drinking())
	{
		self zm_utility::decrement_is_drinking();
		return;
	}
	if(w_original != level.weaponnone && !zm_utility::is_placeable_mine(w_original) && !zm_equipment::is_equipment_that_blocks_purchase(w_original))
	{
		self zm_weapons::switch_back_primary_weapon(w_original);
		if(zm_utility::is_melee_weapon(w_original))
		{
			self zm_utility::decrement_is_drinking();
			return;
		}
	}
	else
	{
		self zm_weapons::switch_back_primary_weapon();
	}
	self util::waittill_any_timeout(1, "weapon_change_complete");
	if(!self laststand::player_is_in_laststand() && (!(isdefined(self.intermission) && self.intermission)))
	{
		self zm_utility::decrement_is_drinking();
	}
}

function bgb_get_gumball_anim_weapon(bgb, activating)
{
	if(activating)
	{
		return level.weaponbgbuse;
	}
	return level.weaponbgbgrab;
}

// function _test_scoreboard()
// {
//   foreach (player in level.players)
//   {
//     player incrementplayerstat("headshots", 1);
//   }
// }

function jiggle_bodies()
{
  flip = true;
  while(true)
  {
    if (flip) 
    {
      SetDvar("phys_gravity_dir", (0, 0, -1));
      flip = false;
    }
    else
    {
      SetDvar("phys_gravity_dir", (0, 0, 1));
    }
    wait(0.2);
  }
}