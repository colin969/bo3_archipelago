#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

// UPDATE CONTENT FROM GSC SO WE CAN MAKE SURE THESE MATCH!


function get_map_weapon_lists(map_name)
{
    lists = SpawnStruct();
    
    switch(map_name)
    {
        case "zm_zod":
            lists.vanilla = array(
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_semiauto",
                "launcher_standard",
                "smg_burst",
                "smg_capacity",
                "smg_sten",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "sniper_powerbolt"
            );
            lists.expanded = array(
                "pistol_revolver38",
                "bouncingbetty",
                "bowie_knife",
                "ar_longburst",
                "ar_marksman",
                "ar_standard",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_pump",
                "smg_fastfire",
                "smg_standard",
                "smg_versatile"
            );
            lists.special = array(
                "octobomb",
                "ray_gun"
            );
            break;
            
        case "zm_castle":
            lists.vanilla = array(
                "bouncingbetty",
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_marksman",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_semiauto",
                "launcher_standard",
                "smg_burst",
                "smg_capacity",
                "smg_versatile",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "sniper_powerbolt",
                "lmg_rpk"
            );
            lists.expanded = array(
                "pistol_standard",
                "bowie_knife",
                "ar_longburst",
                "ar_standard",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_pump",
                "smg_fastfire",
                "smg_standard"
            );
            lists.special = array(
                "ray_gun",
                "cymbal_monkey"
            );
            break;
            
        case "zm_island":
            lists.vanilla = array(
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_garand",
                "ar_longburst",
                "ar_marksman",
                "ar_standard",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "pistol_shotgun_dw",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_semiauto",
                "launcher_standard",
                "smg_capacity",
                "smg_fastfire",
                "smg_longrange",
                "smg_mp40",
                "smg_standard",
                "smg_versatile",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "sniper_powerbolt"
            );
            lists.expanded = array(
                "pistol_standard",
                "bouncingbetty",
                "bowie_knife",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_pump",
                "smg_burst"
            );
            lists.special = array(
                "cymbal_monkey",
                "ray_gun"
            );
            break;
            
        case "zm_stalingrad":
            lists.vanilla = array(
                "ar_damage",
                "ar_famas",
                "ar_garand",
                "ar_marksman",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "shotgun_fullauto",
                "shotgun_semiauto",
                "launcher_multi",
                "launcher_standard",
                "smg_capacity",
                "smg_mp40",
                "smg_ppsh",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "sniper_powerbolt",
                "special_crossbow_dw",
                "lmg_rpk"
            );
            lists.expanded = array(
                "bouncingbetty",
                "bowie_knife",
                "ar_accurate",
                "ar_cqb",
                "ar_longburst",
                "ar_standard",
                "pistol_standard",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_precision",
                "shotgun_pump",
                "smg_burst",
                "smg_fastfire",
                "smg_standard",
                "smg_versatile",
                "melee_dagger",
                "melee_fireaxe",
                "melee_sword",
                "melee_wrench"
            );
            lists.special = array(
                "cymbal_monkey",
                "ray_gun",
                "raygun_mark3"
            );
            break;
            
        case "zm_genesis":
            lists.vanilla = array(
                "bouncingbetty",
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_longburst",
                "ar_marksman",
                "ar_standard",
                "ar_peacekeeper",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "pistol_energy",
                "shotgun_energy",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_semiauto",
                "launcher_standard",
                "smg_capacity",
                "smg_fastfire",
                "smg_standard",
                "smg_thompson",
                "smg_versatile",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "sniper_powerbolt"
            );
            lists.expanded = array(
                "pistol_standard",
                "bowie_knife",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_pump",
                "smg_burst",
                "melee_boneglass",
                "melee_improvise",
                "melee_nunchuks",
                "melee_mace",
                "melee_katana"
            );
            lists.special = array(
                "ray_gun",
                "thundergun",
                "hero_gravityspikes_melee",
                "octobomb",
                "idgun_genesis_0"
            );
            break;
            
        case "zm_factory":
            lists.vanilla = array(
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_marksman",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_semiauto",
                "launcher_standard",
                "smg_burst",
                "smg_capacity",
                "smg_versatile",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "sniper_powerbolt",
                "lmg_rpk"
            );
            lists.expanded = array(
                "pistol_standard",
                "bouncingbetty",
                "bowie_knife",
                "ar_longburst",
                "ar_standard",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_pump",
                "smg_fastfire",
                "smg_standard"
            );
            lists.special = array(
                "cymbal_monkey",
                "ray_gun",
                "tesla_gun"
            );
            break;
            
        case "zm_theater":
            lists.vanilla = array(
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_famas",
                "ar_galil",
                "ar_longburst",
                "ar_m16",
                "ar_marksman",
                "ar_standard",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "pistol_fullauto",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_pump",
                "shotgun_semiauto",
                "launcher_standard",
                "smg_burst",
                "smg_capacity",
                "smg_fastfire",
                "smg_standard",
                "smg_versatile",
                "smg_mp40_1940",
                "smg_ak74u",
                "sniper_fastsemi",
                "sniper_powerbolt",
                "lmg_rpk",
                "ar_m14"
            );
            lists.expanded = array(
                "pistol_standard",
                "pistol_m1911",
                "bouncingbetty",
                "bowie_knife",
                "pistol_burst"
            );
            lists.special = array(
                "cymbal_monkey",
                "thundergun",
                "ray_gun",
                "raygun_mark2",
                "tesla_gun",
                "hero_annihilator"
            );
            break;

        case "zm_moon":
            lists.vanilla = array(
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_famas",
                "ar_galil",
                "ar_longburst",
                "ar_m16",
                "ar_marksman",
                "ar_standard",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_slowfire",
                "pistol_fullauto",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_pump",
                "shotgun_semiauto",
                "launcher_multi",
                "launcher_standard",
                "smg_burst",
                "smg_capacity",
                "smg_fastfire",
                "smg_standard",
                "smg_versatile",
                "smg_ak74u",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "lmg_rpk",
                "ar_m14"
            );
            lists.expanded = array(
                "pistol_standard",
                "pistol_m1911",
                "bouncingbetty",
                "bowie_knife",
                "pistol_burst"
            );
            lists.special = array(
                "hero_annihilator",
                "raygun_mark2",
                "quantum_bomb",
                "black_hole_bomb",
                "ray_gun",
                "microwavegundw"
            );
            break;
        case "zm_tomb":
            lists.vanilla = array(
                "ar_accurate",
                "ar_cqb",
                "ar_damage",
                "ar_longburst",
                "ar_marksman",
                "ar_standard",
                "ar_stg44",
                "lmg_cqb",
                "lmg_heavy",
                "lmg_light",
                "lmg_mg08",
                "lmg_slowfire",
                "pistol_burst",
                "pistol_fullauto",
                "shotgun_fullauto",
                "shotgun_precision",
                "shotgun_pump",
                "shotgun_semiauto",
                "launcher_multi",
                "launcher_standard",
                "smg_burst",
                "smg_capacity",
                "smg_fastfire",
                "smg_mp40_1940",
                "smg_standard",
                "smg_thompson",
                "smg_versatile",
                "smg_ak74u",
                "sniper_fastbolt",
                "sniper_fastsemi",
                "lmg_rpk",
                "ar_m14"
            );
            lists.expanded = array(
                "bouncingbetty",
                "bowie_knife",
                "pistol_c96"
            );
            lists.wallbuys = array(
                "pistol_burst",
                "ar_marksman",
                "shotgun_pump",
                "ar_standard",
                "smg_standard",
                "pistol_fullauto",
                "smg_fastfire",
                "ar_accurate",
                "ar_cqb",
                "smg_versatile",
                "shotgun_precision",
                "ar_longburst",
                "smg_mp40_1940",
                "ar_stg44",
                "smg_thompson"
            );
            lists.special = array(
                "cymbal_monkey",
                "ray_gun",
                "raygun_mark2",
                "hero_annihilator"
            );
            break;
        case "zm_westernz":
            lists.vanilla = array(
                "t8_crossbow",
                "bo3_boneglass",
                "t8_allistair_annihalator",
                "m1831",
                "bo3_olympia",
                "henry_m1840",
                "w1887",
                "t8_m1897",
                "ww2_model21",
                "ww2_winchester94",
                "w1892",
                "fc4_m1887_long",
                "lebel_m1811",
                "ww2_lewis",
                "ww2_fliegerfaust",
                "wes_jag42",
                "m1827_exp"
            );
            lists.expanded = array(
                "frag_ww2_dynamite",
                "frag_ww2_molotov",
                "ww2_raven",
                "ww2_iceaxe",
                "bowie_knife",
                "t8_welling",
                "ww2_reichsrevolver",
                "ww2_colt45saa",
                "ww2_enfield2",
                "ww2_enfield2_gold",
                "ww2_m712",
                "m1889",
                "mwr_ranger",
                "m1903_epic",
                "ww2_mosin",
                "m1896_essex",
                "doc_w1866",
                "aw_winchester",
                "ww2_crossbow",
                "ww2_ribeyrolles",
                "bo4_escargot"
            );
            lists.special = array(
                "grenade_homunculus",
                "thundergun",
                "t8_shotgun_blundergat",
                "t8_raygun",
                "tesla_gun"
            );
            break;
        default:
            return undefined;
    }
    
    return lists;
}

function get_box_bit_table(map_name, basic, special, expanded)
{
    ap_weapon_bits = [];
    bit_index = 0;
    lists = get_map_weapon_lists(map_name);

    if(!isdefined(lists))
    {
        return ap_weapon_bits;
    }
    
    if(special && isdefined(lists.special))
    {
        foreach(weapon in lists.special)
        {
            ap_weapon_bits[weapon] = bit_index;
            bit_index++;
        }
    }

    if(expanded && isdefined(lists.expanded))
    {
        foreach(weapon in lists.expanded)
        {
            ap_weapon_bits[weapon] = bit_index;
            bit_index++;
        }
    }
    
    if(basic && isdefined(lists.vanilla))
    {
        foreach(weapon in lists.vanilla)
        {
            ap_weapon_bits[weapon] = bit_index;
            bit_index++;
        }
    }
    
    return ap_weapon_bits;
}
