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

#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_perks.gsh;

#precache( "menu", "ApShop_Main" );
#precache( "model", "archipelago_shop" );

REGISTER_SYSTEM_EX( "archi_shop", &__init__, &__main__, undefined )

function __init__()
{
	structs = struct::get_array( "archi_shop", "targetname" );

	if( structs.size < 1 )
		return;

	array::thread_all( structs, &shop_spawn_init );


}

function __main__()
{
	setup_bgb_bags();

	callback::on_connect( &on_player_connect );
	callback::on_laststand( &on_player_laststand );
}

function on_player_connect()
{
	util::registerClientSys("PerkTokens");
	util::registerClientSys("GumTokens");
	util::registerClientSys("RareGumTokens");
	util::registerClientSys("LegendaryGumTokens");
	util::registerClientSys("CheckpointTokens");

	self thread shop_menu_handler();
}

function on_player_laststand()
{
	self shop_close_menu();
}

function setup_bgb_bags()
{
	if(!isdefined(level.archi_shop_bgb_bags))
    {
        level.archi_shop_bgb_bags = [];
        level.archi_shop_bgb_bags[0] = []; // Normal
        level.archi_shop_bgb_bags[1] = []; // Mega
        level.archi_shop_bgb_bags[2] = []; // Rare Mega
        level.archi_shop_bgb_bags[3] = []; // Legendary Mega
        level.archi_shop_bgb_bags[4] = []; // Whimsical
    }
}

function refill_bgb_bag(rarity)
{
    level.archi_shop_bgb_bags[rarity] = [];
    
    keys = getarraykeys(level.bgb);
    for(i = 0; i < keys.size; i++)
    {
        if(level.bgb[keys[i]].rarity == rarity)
        {
            level.archi_shop_bgb_bags[rarity][level.archi_shop_bgb_bags[rarity].size] = keys[i];
        }
    }
    
    level.archi_shop_bgb_bags[rarity] = array::randomize(level.archi_shop_bgb_bags[rarity]);
}

// Create a new shop
function shop_spawn_init()
{
	if( !isdefined( self.model ) )
		return;

	self.machine = Spawn( "script_model", self.origin );
	self.machine.angles = self.angles;
	self.machine SetModel( self.model );

	// self.collision = Spawn("script_model", self.origin, 1);
	// self.collision.angles = angles;
	// self.collision SetModel("zm_collision_perks1");
	// self.collision.script_noteworthy = "clip";
	// self.collision DisconnectPaths();

    self.origin = self.origin + (0, 0, 20);
	self.script_unitrigger_type = "unitrigger_box_use";
	self.cursor_hint = "HINT_NOICON";
	self.require_look_at = true;
    self.radius = 82;
	zm_unitrigger::unitrigger_force_per_player_triggers( self, true );
	self.prompt_and_visibility_func = &shop_update_prompt;
	zm_unitrigger::register_static_unitrigger( self, &shop_trigger_think );

	playfx(level._effect["teleport_splash"], self.origin);
}

function shop_update_prompt( player )
{
	self SetHintString( "Open the Archipelago Shop" );
	return true;
}

function shop_close_menu()
{
	self closeInGameMenu();
	self CloseMenu( "ApShop_Main" );
}

function shop_open_menu()
{
	self shop_close_menu();

	util::setClientSysState("PerkTokens", level.archi.perk_tokens - self.ap_spent_perk_tokens, self);
	util::setClientSysState("GumTokens", level.archi.gum_tokens - self.ap_spent_gum_tokens, self);
	util::setClientSysState("RareGumTokens", level.archi.rare_gum_tokens - self.ap_spent_rare_gum_tokens, self);
	util::setClientSysState("LegendaryGumTokens", level.archi.legendary_gum_tokens - self.ap_spent_legendary_gum_tokens, self);
	util::setClientSysState("CheckpointTokens", level.archi.checkpoint_tokens - level.archi.spent_checkpoint_tokens);

    self OpenMenu( "ApShop_Main" );
}

function shop_menu_handler()
{
	self endon( "disconnect" );
	self notify( "shop_menu_handler" );
	self endon( "shop_menu_handler" );

	while( true )
	{
		self waittill( "menuresponse", menu, response );

		if( !IS_EQUAL( menu, "ApShop_Main" ) )
		{
			continue;
		}

		if( IS_EQUAL( response, "close" ) )
		{
			self shop_close_menu();
			continue;
		}

		split = strtok( response, "," );
		item_type = split[0];
		item_value = split[1];

		if (item_type == "checkpoint")
		{
			self shop_close_menu();
			if (level.archi.spent_checkpoint_tokens >= 0)
			{
				if (level.archi.spent_checkpoint_tokens < level.archi.checkpoint_tokens)
				{
					if (isdefined(level.archi.save_state)) {
						level.archi.spent_checkpoint_tokens++;
						level.archi.save_checkpoint = true;
						[[level.archi.save_state]]();
						level.archi.save_checkpoint = false;
					}
					else
					{
						IPrintLnBold("Saving not available for this map");
					}

				}
				else
				{
					self playsound( "zmb_no_cha_ching" );
				}
			}
			else
			{
				IPrintLnBold("Checkpoint token count not loaded yet");
			}
		}

        if (item_type == "gum")
        {
			self shop_close_menu();
			rarity = int(item_value);
			if (rarity == 1)
			{
				if (self.ap_spent_gum_tokens < level.archi.gum_tokens)
				{
					selected_bgb = get_random_gum(1);
					self playsound( "zmb_cha_ching" );
					succeeded = self shop_gum_give(selected_bgb);
					if (succeeded == 1)
					{
						self.ap_spent_gum_tokens++;
					}
				}
				else
				{
					self playsound( "zmb_no_cha_ching" );
				}
			}
			if (rarity == 2)
			{
				if (self.ap_spent_rare_gum_tokens < level.archi.rare_gum_tokens)
				{
					selected_bgb = get_random_gum(2);
					self playsound( "zmb_cha_ching" );
					succeeded = self shop_gum_give(selected_bgb);
					if (succeeded == 1)
					{
						self.ap_spent_rare_gum_tokens++;
					}
				}
				else
				{
					self playsound( "zmb_no_cha_ching" );
				}
			}
			if (rarity == 3)
			{
				if (self.ap_spent_legendary_gum_tokens < level.archi.legendary_gum_tokens)
				{
					selected_bgb = get_random_gum(3);
					self playsound( "zmb_cha_ching" );
					succeeded = self shop_gum_give(selected_bgb);
					if (succeeded == 1)
					{
						self.ap_spent_legendary_gum_tokens++;
					}
				}
				else
				{
					self playsound( "zmb_no_cha_ching" );
				}
			}
        }
	}
}

function get_random_gum(rarity)
{
	bag = get_gum_bag(rarity);
	return array::pop(level.archi_shop_bgb_bags[rarity]);
}

function get_gum_bag(rarity)
{
	bag = level.archi_shop_bgb_bags[rarity];
	if (isdefined(bag))
	{
		if (bag.size == 0)
		{
			refill_bgb_bag(rarity);
		}
	}
	return bag;
}

function shop_trigger_think()
{
	self endon( "kill_trigger" );
	
	while( true )
	{
		self waittill( "trigger", player );

		player shop_open_menu();
        // player shop_test_give();
	}
}

function shop_test_give()
{
    bgb_keys = GetArrayKeys(level.bgb);
    selected_bgb = array::random(bgb_keys);
    self thread shop_gum_give(selected_bgb);
}

function shop_gum_give( selected_bgb )
{
    self endon( "disconnect" );

    if (isdefined(selected_bgb))
    {
        gun = self bgb_anim_start(selected_bgb, 0);
		evt = self util::waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete", "disconnect");
		succeeded = 0;
		if(evt == "weapon_change_complete")
		{
			succeeded = 1;
			self thread bgb::give(selected_bgb);
			self notify("bgb_gumball_anim_give", selected_bgb);
		}
		self bgb_anim_end(gun, selected_bgb, 0);

		return succeeded;
    }

	return 0;
}

function bgb_anim_start(bgb, activating)
{
  	self zm_utility::increment_is_drinking();
	self zm_utility::disable_player_move_states(1);
	w_original = self getcurrentweapon();
	weapon = bgb_get_gumball_anim_weapon(activating);
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
  weapon = bgb_get_gumball_anim_weapon(activating);
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

function bgb_get_gumball_anim_weapon(activating)
{
	if(activating)
	{
		return level.weaponbgbuse;
	}
	return level.weaponbgbgrab;
}
