#using scripts\shared\array_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;

#namespace zm_weapon_attachments;

REGISTER_SYSTEM_EX( "zm_weapon_attachments", undefined, &__main__, undefined )

function __main__()
{
    register_weapon_attachment_data();
}

function register_weapon_attachment_data()
{
    foreach( weapon in GetArrayKeys( level.zombie_weapons ) )
    {
        level.zombie_weapons[weapon] register_weapon_attachments( weapon.name );
    }
}

function register_weapon_attachments( weapon_name )
{
    switch( weapon_name )
    {
        case "ar_garand":
        case "ar_galil":
        case "ar_famas":
        case "ar_m16":
        case "ar_standard":
        case "ar_marksman":
        case "ar_longburst":
        case "ar_damage":
        case "ar_cqb":
        case "ar_accurate":
            self.ap_sights = array( "none", "acog", "dualoptic", "holo", "ir", "reddot", "reflex" );
            self.ap_attachments = array( "damage", "extbarrel", "extclip", "fastreload", "fmj", "grip", "quickdraw", "rf", "stalker", "steadyaim", "suppressed" );
            if( weapon_name == "ar_m16" || weapon_name == "ar_famas" )
            {
                ArrayRemoveValue( self.sights, "dualoptic" );
            }
            break;

        case "lmg_rpk":
        case "lmg_slowfire":
        case "lmg_light":
        case "lmg_heavy":
        case "lmg_cqb":
            self.ap_sights = array( "none", "acog", "dualoptic", "holo", "ir", "reddot", "reflex" );
            self.ap_attachments = array( "extclip", "fastreload", "fmj", "grip", "quickdraw", "rf", "stalker", "steadyaim", "suppressed" );
            if( weapon_name == "lmg_rpk" )
            {
                ArrayRemoveValue( self.sights, "dualoptic" );
            }
            break;

        case "smg_ak74u":
        case "smg_versatile":
        case "smg_standard":
        case "smg_ppsh":
        case "smg_fastfire":
        case "smg_capacity":
        case "smg_burst":
            self.ap_sights = array( "none", "acog", "dualoptic", "holo", "reddot", "reflex" );
            self.ap_attachments = array( "extbarrel", "extclip", "fastreload", "fmj", "grip", "quickdraw", "rf", "stalker", "steadyaim", "suppressed" );
            if( weapon_name == "smg_ak74u" )
            {
                ArrayRemoveValue( self.sights, "dualoptic" );
            }
            break;

        case "shotgun_semiauto":
        case "shotgun_pump":
        case "shotgun_precision":
        case "shotgun_fullauto":
        case "shotgun_energy":
            self.ap_sights = array( "none", "holo", "reddot", "reflex" );
            self.ap_attachments = array( "extbarrel", "extclip", "fastreload", "quickdraw", "rf", "stalker", "steadyaim", "suppressed" );
            break;

        case "pistol_fullauto":
        case "pistol_burst":
        case "pistol_energy":
        case "pistol_m1911":
        case "pistol_standard":
            self.ap_sights = array( "none", "reddot", "reflex" );
            self.ap_attachments = array( "damage", "extbarrel", "extclip", "fastreload", "fmj", "quickdraw", "steadyaim", "suppressed" );
            break;

        case "sniper_fastsemi":
        case "sniper_powerbolt":
        case "sniper_fastbolt":
            self.ap_sights = array( "none", "acog", "dualoptic", "ir", "reddot" );
            self.ap_attachments = array( "extclip", "fastreload", "fmj", "rf", "stalker", "suppressed", "swayreduc" );
            break;
    }
}

function give_weapon_with_attachments( weapon_name = "none", sight, &attachments, camo_index = 0, reticle_index = 0, num_attachments = 3, give_sight = true )
{
    self endon( "disconnect" );

    base_weapon = zm_weapons::get_base_weapon( GetWeapon( weapon_name ).rootweapon );
    weapon_data = level.zombie_weapons[ base_weapon ];  
    upgrade = StrEndsWith( weapon_name, "_upgraded" );
    weapon_options = undefined;

    if( !isdefined( weapon_data ) || !isdefined( weapon_data.attachments ) )
    {
        IPrintLn( "^1weapon data is not registered" );
        return;
    }

    valid_attachments = [];

    if( isdefined( weapon_data.sights ) && weapon_data.sights.size )
    {
        if( !isdefined( sight ) || !IsInArray( weapon_data.sights, sight ) )
        {
            sight = array::random( weapon_data.sights );
        }
        
        if( IS_TRUE( give_sight ) && sight != "none" )
        {
            valid_attachments[valid_attachments.size] = sight;
        }
    }

    if( isdefined( num_attachments ) && num_attachments > 0 )
    {
        if( isdefined( weapon_data.attachments ) && weapon_data.attachments.size )
        {
            num_attachments = Min( Min( ( isdefined( attachments ) ? attachments.size : num_attachments ), weapon_data.attachments.size ), 6 );

            if( !isdefined( attachments ) )
            {
                attachments = array::randomize( weapon_data.attachments );
            }

            for( i = 0; i < num_attachments; i++ )
            {
                valid_attachments[valid_attachments.size] = attachments[i];
            }

            if( upgrade && ( StrStartsWith( weapon_name, "pistol_standard" ) || StrStartsWith( weapon_name, "pistol_m1911" ) ) )
            {
                ArrayInsert( valid_attachments, "dw", 0 );
            }

            if( isdefined( sight ) && IsInArray( valid_attachments, "swayreduc" ) )
            {
                ArrayRemoveValue( valid_attachments, ( RandomInt(2) ? sight : "swayreduc" ) );
            }

            if( valid_attachments.size )
            {
                if( upgrade )
                {
                    weapon = GetWeapon( weapon_data.upgrade.rootweapon.name, valid_attachments );
                }

                else
                {
                    weapon = GetWeapon( weapon_name, valid_attachments );
                }
            }
        }
    }

    if( !isdefined( weapon ) )
    {
        weapon = ( upgrade ? weapon_data.upgrade.rootweapon : base_weapon );
    }

    weapon_options = self CalcWeaponOptions( camo_index, 0, reticle_index );

    weapon_limit = zm_utility::get_player_weapon_limit( self );
    weapons = self GetWeaponsListPrimaries();
    if( weapons.size >= weapon_limit )
    {
        self TakeWeapon( self GetCurrentWeapon() );
    }

    self GiveWeapon( weapon, weapon_options );
    self GiveMaxAmmo( weapon );

    if( weapon.altweapon.name != "none" )
    {
        self GiveMaxAmmo( weapon.altweapon );
    }

    self SwitchToWeapon( weapon );

    return weapon;
}