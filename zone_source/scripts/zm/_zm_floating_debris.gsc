#using scripts\codescripts\struct;
#using scripts\shared\_burnplayer;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_shared;
#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#namespace floating_debris;

// Modified template script which will work with Archipelago

function autoexec __init__sytem__()
{
	system::register("floating_debris", &__init__, &__main__, undefined);
}

function __init__()
{
}

function __main__()
{
	level waittill("prematch_over");
	Debris = GetEntArray("floating_debris", "targetname");
	Array::thread_all(Debris, &debris_think);
}

function debris_think()
{
	// self useanimtree(-1);
	// self AnimScripted("optionalNotify", self.origin, self.angles, %idle_debris_anim);
	origin = self.origin;
	trig = GetEnt(self.target, "targetname");
	clip = GetEnt(trig.target, "targetname");
	clip disconnectpaths();
	trig setcursorhint("HINT_NOICON");
	trig setHintString("");
	while(1)
	{
		trig setHintString("Hold ^3[{+activate}]^7 to open [Cost: &&1]", trig.zombie_cost);
		trig waittill("trigger", player);
		if(zm_utility::is_player_valid(player) && player zm_score::can_player_purchase(trig.zombie_cost))
		{
            player zm_score::minus_to_player_score(trig.zombie_cost);
			if(isdefined(trig.script_sound))
			{
				playsoundatposition(trig.script_sound, origin);
			}
			//self AnimScripted("optionalNotify", self.origin, self.angles, %rise_debris_anim);
            level notify("ap_modded_floating_debris_opened", self.id);
			trig delete();
			clip connectpaths();
			clip delete();
			if(isdefined(trig.script_flag))
			{
				level flag::set(trig.script_flag);
			}
			wait(2);
			self delete();
			break;
		}
		else
		{
			zm_utility::play_sound_at_pos("no_purchase", trig.origin);
			player zm_audio::create_and_play_dialog("general", "outofmoney");
		}
	}
}
