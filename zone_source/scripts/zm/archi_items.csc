#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\archi_weapon_mappings.gsh;

// UPDATE CONTENT FROM GSC SO WE CAN MAKE SURE THESE MATCH!


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
