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

#using scripts\zm\archi_core;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\archi_core.gsh;

function setup_soul_catchers()
{
    // Add listeners for when each soul catcher finishes
    array::thread_all(level.soul_catchers, &_soul_catcher_notify_thread);

    level thread _all_soul_catchers_filled_thread();
}

// Track number of filled soul catchers so we can trigger a location
function _all_soul_catchers_filled_thread()
{
    number_charged = 0;
    while (true) 
    {
        level waittill("ap_castle_soul_catcher_charged");
        number_charged += 1;
        if (number_charged === 3)
        {
            archi_core::send_location(level.archi.mapString + " Feed the Dragonheads");
        }
    }
}

// Wait for the soul catcher to be filled and notify
function _soul_catcher_notify_thread()
{
    while (!self.is_charged) {
        self util::waittill_either("fully_charged", "finished_eating");
    }

    IPrintLn("Soul Catcher Filled");

    level notify("ap_castle_soul_catcher_charged");
}

function setup_landing_pads()
{
    // Add activate listener on each landing pad
    landing_pads = struct::get_array("115_flinger_landing_pad", "targetname");
    array::thread_all(landing_pads, &_landing_pad_notify_thread);

    // Listen for activation events forwarded from landing pad threads
    level thread _all_landing_pads_activated(landing_pads.size);
}

function _all_landing_pads_activated(pad_count)
{
    pads_activated = 0;
    while (pads_activated < pad_count)
    {
        level waittill("ap_castle_landing_pad_activated");
        pads_activated += 1;
    }
    archi_core::send_location(level.archi.mapString + " Turn on all Landing Pads");
}


function _landing_pad_notify_thread()
{
    level flag::wait_till(self.script_noteworthy);
    IPrintLn("Landing Pad Activated");
    level notify("ap_castle_landing_pad_activated");
}