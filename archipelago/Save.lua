-- Der Eisendrache
function map_save_zm_castle(mapData)
  Archi.LogMessage("Saving map data for Der Eisendrache");
  save_spent_tokens(mapData)
  save_zombie_count(mapData)
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)
  save_zm_castle_landingpads(mapData)
  save_flag(mapData, "soul_catchers_charged")
  save_flag(mapData, "death_ray_trap_used")
  save_flag(mapData, "ee_fuse_placed")
  save_flag(mapData, "ee_safe_open")
  save_flag(mapData, "switch_to_death_ray")
  save_flag(mapData, "tesla_connector_launch_platform")
  save_flag(mapData, "tesla_connector_lower_tower")
  save_flag(mapData, "ee_start_done")
  save_flag(mapData, "ee_golden_key")
  save_flag(mapData, "mpd_canister_replacement")
  save_flag(mapData, "channeling_stone_replacement")
  save_flag(mapData, "start_channeling_stone_step")
  save_flag(mapData, "boss_fight_ready")

  save_val(mapData, "elemental_storm_beacons_lit")
  save_flag(mapData, "elemental_storm_wallrun")
  save_flag(mapData, "elemental_storm_batteries")
  save_val(mapData, "elemental_storm_beacons_charged")
  save_val(mapData, "elemental_storm_repaired")
  save_flag(mapData, "elementa_storm_upgraded")

  save_flag(mapData, "wolf_howl_paintings")
  save_val(mapData, "wolf_howl_skull_collected")
  save_flag(mapData, "wolf_howl_escort")
  save_val(mapData, "wolf_howl_repaired")
  save_flag(mapData, "wolf_howl_upgraded")

  save_flag(mapData, "demon_gate_seal")
  save_flag(mapData, "demon_gate_crawlers")
  save_flag(mapData, "demon_gate_runes")
  save_flag(mapData, "demon_gate_repaired")

  save_val(mapData, "storm_owner")
  save_val(mapData, "wolf_owner")
  save_val(mapData, "fire_owner")
  save_val(mapData, "void_owner")

  save_val(mapData, "vo_round_counter")

  save_players(mapData, player_save_zm_castle)
end

function player_save_zm_castle(xuid, playerData)
  save_player_score(xuid, playerData)
  save_player_perks(xuid, playerData)
  save_player_loadout(xuid, playerData)
end

function map_restore_zm_castle(mapData)
  Archi.LogMessage("Restoring map data for Der Eisendrache")
  restore_spent_tokens(mapData)
  restore_zombie_count(mapData)
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)
  restore_zm_castle_landingpads(mapData)
  restore_flag(mapData, "soul_catchers_charged")
  restore_flag(mapData, "death_ray_trap_used")
  restore_flag(mapData, "ee_fuse_placed")
  restore_flag(mapData, "ee_safe_open")
  restore_flag(mapData, "switch_to_death_ray")
  restore_flag(mapData, "tesla_connector_launch_platform")
  restore_flag(mapData, "tesla_connector_lower_tower")
  restore_flag(mapData, "ee_start_done")
  restore_flag(mapData, "ee_golden_key")
  restore_flag(mapData, "mpd_canister_replacement")
  restore_flag(mapData, "channeling_stone_replacement")
  restore_flag(mapData, "start_channeling_stone_step")
  restore_flag(mapData, "boss_fight_ready")

  restore_val(mapData, "elemental_storm_beacons_lit")
  restore_flag(mapData, "elemental_storm_wallrun")
  restore_flag(mapData, "elemental_storm_batteries")
  restore_val(mapData, "elemental_storm_beacons_charged")
  restore_val(mapData, "elemental_storm_repaired")
  restore_flag(mapData, "elemental_storm_upgraded")

  restore_flag(mapData, "wolf_howl_paintings")
  restore_val(mapData, "wolf_howl_skull_collected")
  restore_flag(mapData, "wolf_howl_escort")
  restore_val(mapData, "wolf_howl_repaired")
  restore_flag(mapData, "wolf_howl_upgraded");

  restore_flag(mapData, "demon_gate_seal")
  restore_flag(mapData, "demon_gate_crawlers")
  restore_flag(mapData, "demon_gate_runes")
  restore_flag(mapData, "demon_gate_repaired")

  restore_val(mapData, "storm_owner")
  restore_val(mapData, "wolf_owner")
  restore_val(mapData, "fire_owner")
  restore_val(mapData, "void_owner")

  restore_val(mapData, "vo_round_counter")
end

function player_restore_zm_castle(xuid, playerData)
  restore_player_score(xuid, playerData)
  restore_player_perks(xuid, playerData)
  restore_player_loadout(xuid, playerData)
end

-- Shadows of Evil
function map_save_zm_zod(mapData)
  Archi.LogMessage("Saving map data for Shadows of Evil");
  save_spent_tokens(mapData)
  save_zombie_count(mapData)
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)
  save_flag(mapData, "ap_got_summoning_key")
  save_flag(mapData, "ritual_boxer_complete")
  save_flag(mapData, "ritual_magician_complete")
  save_flag(mapData, "ritual_detective_complete")
  save_flag(mapData, "ritual_femme_complete")
  save_flag(mapData, "ritual_pap_complete")
  save_flag(mapData, "pap_door_open")
  save_flag(mapData, "keeper_sword_locker")
  save_flag(mapData, "ee_book")
  save_flag(mapData, "ee_keeper_detective_resurrected")
  save_flag(mapData, "ee_keeper_boxer_resurrected")
  save_flag(mapData, "ee_keeper_femme_resurrected")
  save_flag(mapData, "ee_keeper_magician_resurrected")

  for i = 0, 29 do
    save_flag(mapData, "power_on" .. i)
  end

  save_val(mapData, "smashed")

  save_players(mapData, player_save_zm_zod)
end

function player_save_zm_zod(xuid, playerData)
  save_player_score(xuid, playerData)
  save_player_perks(xuid, playerData)
  save_player_loadout(xuid, playerData)
  save_player_val(xuid, playerData, "fumigator")
  save_player_val(xuid, playerData, "sword_upgrade_stage")
end

function map_restore_zm_zod(mapData)
  Archi.LogMessage("Restoring map data for Shadows of Evil")
  restore_spent_tokens(mapData)
  restore_zombie_count(mapData)
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)
  restore_flag(mapData, "ap_got_summoning_key")
  restore_flag(mapData, "ritual_boxer_complete")
  restore_flag(mapData, "ritual_magician_complete")
  restore_flag(mapData, "ritual_detective_complete")
  restore_flag(mapData, "ritual_femme_complete")
  restore_flag(mapData, "ritual_pap_complete")
  restore_flag(mapData, "pap_door_open")
  restore_flag(mapData, "keeper_sword_locker")
  restore_flag(mapData, "ee_book")
  restore_flag(mapData, "ee_keeper_detective_resurrected")
  restore_flag(mapData, "ee_keeper_boxer_resurrected")
  restore_flag(mapData, "ee_keeper_femme_resurrected")
  restore_flag(mapData, "ee_keeper_magician_resurrected")

  for i = 0, 29 do
    restore_flag(mapData, "power_on" .. i)
  end

  restore_val(mapData, "smashed")
end

function player_restore_zm_zod(xuid, playerData)
  restore_player_score(xuid, playerData)
  restore_player_perks(xuid, playerData)
  restore_player_loadout(xuid, playerData)
  restore_player_val(xuid, playerData, "fumigator")
  restore_player_val(xuid, playerData, "sword_upgrade_stage")
end

-- Zetsubou No Shima
function map_save_zm_island(mapData)
  Archi.LogMessage("Saving map data for Zetsubou No Shima");
  save_spent_tokens(mapData)
  save_zombie_count(mapData)
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)
  save_flag(mapData, "ww1_found")
  save_flag(mapData, "ww2_found")
  save_flag(mapData, "ww3_found")
  save_flag(mapData, "ww_obtained")
  save_flag(mapData, "wwup1_found")
  save_flag(mapData, "wwup2_found")
  save_flag(mapData, "wwup3_found")
  save_flag(mapData, "trilogy_released")
  save_flag(mapData, "elevator_part_gear1_found")
  save_flag(mapData, "elevator_part_gear2_found")
  save_flag(mapData, "elevator_part_gear3_found")
  save_flag(mapData, "all_challenges_completed")
  save_flag(mapData, "valve1_found")
  save_flag(mapData, "valve2_found")
  save_flag(mapData, "valve3_found")
  save_flag(mapData, "a_player_got_skullgun")

  save_players(mapData, player_save_zm_island)
end

function player_save_zm_island(xuid, playerData)
  save_player_score(xuid, playerData)
  save_player_perks(xuid, playerData)
  save_player_loadout(xuid, playerData)
  save_player_flag(xuid, playerData, "flag_player_completed_challenge_1")
  save_player_flag(xuid, playerData, "flag_player_completed_challenge_2")
  save_player_flag(xuid, playerData, "flag_player_completed_challenge_3")
  save_player_flag(xuid, playerData, "flag_player_collected_reward_1")
  save_player_flag(xuid, playerData, "flag_player_collected_reward_2")
  save_player_flag(xuid, playerData, "flag_player_collected_reward_3")

  save_player_val(xuid, playerData, "bucket_held")
  save_player_val(xuid, playerData, "has_island_seed")
  save_player_val(xuid, playerData, "bucket_bucket_water_type")
  save_player_val(xuid, playerData, "bucket_bucket_water_level")
end

function map_restore_zm_island(mapData)
  Archi.LogMessage("Restoring map data for Zetsubou No Shima")
  restore_spent_tokens(mapData)
  restore_zombie_count(mapData)
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)
  restore_flag(mapData, "ww1_found")
  restore_flag(mapData, "ww2_found")
  restore_flag(mapData, "ww3_found")
  restore_flag(mapData, "ww_obtained")
  restore_flag(mapData, "wwup1_found")
  restore_flag(mapData, "wwup2_found")
  restore_flag(mapData, "wwup3_found")
  restore_flag(mapData, "trilogy_released")
  restore_flag(mapData, "elevator_part_gear1_found")
  restore_flag(mapData, "elevator_part_gear2_found")
  restore_flag(mapData, "elevator_part_gear3_found")
  restore_flag(mapData, "all_challenges_completed")
  restore_flag(mapData, "valve1_found")
  restore_flag(mapData, "valve2_found")
  restore_flag(mapData, "valve3_found")
  restore_flag(mapData, "a_player_got_skullgun")
end

function player_restore_zm_island(xuid, playerData)
  restore_player_score(xuid, playerData)
  restore_player_perks(xuid, playerData)
  restore_player_loadout(xuid, playerData)
  restore_player_flag(xuid, playerData, "flag_player_completed_challenge_1")
  restore_player_flag(xuid, playerData, "flag_player_completed_challenge_2")
  restore_player_flag(xuid, playerData, "flag_player_completed_challenge_3")
  restore_player_flag(xuid, playerData, "flag_player_collected_reward_1")
  restore_player_flag(xuid, playerData, "flag_player_collected_reward_2")
  restore_player_flag(xuid, playerData, "flag_player_collected_reward_3")

  restore_player_val(xuid, playerData, "bucket_held")
  restore_player_val(xuid, playerData, "has_island_seed")
  restore_player_val(xuid, playerData, "bucket_bucket_water_type")
  restore_player_val(xuid, playerData, "bucket_bucket_water_level")
end

-- Gorod Krovi
function map_save_zm_stalingrad(mapData)
  Archi.LogMessage("Saving map data for Gorod Krovi")
  save_spent_tokens(mapData)
  save_zombie_count(mapData)
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)
  save_flag(mapData, "dragonride_crafted");
  save_flag(mapData, "dragon_strike_quest_complete");
  save_flag(mapData, "generator_charged");
  save_flag(mapData, "key_placement");
  save_flag(mapData, "keys_placed");
  save_flag(mapData, "scenarios_complete");
  save_flag(mapData, "dragon_egg_acquired");
  save_flag(mapData, "egg_awakened");
  save_flag(mapData, "gauntlet_step_2_complete");
  save_flag(mapData, "gauntlet_step_3_complete");
  save_flag(mapData, "gauntlet_step_4_complete");
  save_flag(mapData, "gauntlet_quest_complete");
  save_flag(mapData, "dragon_wings_items_aquired");
  save_flag(mapData, "dragon_platforms_all_used");
  save_flag(mapData, "wearables_raz_mask_complete");
  save_flag(mapData, "wearables_raz_arms_complete");
  save_flag(mapData, "wearables_sentinel_arms_complete");
  save_flag(mapData, "wearables_sentinel_camera_complete");
  save_flag(mapData, "drshup_step_1_done");
  save_flag(mapData, "drshup_bathed_in_flame");
  save_flag(mapData, "drshup_factory_rune_hit");
  save_flag(mapData, "drshup_judicial_rune_hit");
  save_flag(mapData, "drshup_factory_rune_hit");
  save_flag(mapData, "drshup_rune_step_done");

  save_players(mapData, player_save_zm_stalingrad)
end

function player_save_zm_stalingrad(xuid, playerData)
  save_player_score(xuid, playerData)
  save_player_perks(xuid, playerData)
  save_player_loadout(xuid, playerData)
  save_player_flag(xuid, playerData, "flag_player_completed_challenge_1")
  save_player_flag(xuid, playerData, "flag_player_completed_challenge_2")
  save_player_flag(xuid, playerData, "flag_player_completed_challenge_3")
  save_player_flag(xuid, playerData, "flag_player_completed_challenge_4")
  save_player_flag(xuid, playerData, "flag_player_collected_reward_1")
  save_player_flag(xuid, playerData, "flag_player_collected_reward_2")
  save_player_flag(xuid, playerData, "flag_player_collected_reward_3")
  save_player_flag(xuid, playerData, "flag_player_collected_reward_4")
  save_player_flag(xuid, playerData, "flag_player_collected_reward_5")
end

function map_restore_zm_stalingrad(mapData)
  Archi.LogMessage("Restoring map data for Gorod Krovi")
  restore_spent_tokens(mapData)
  restore_zombie_count(mapData)
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)
  restore_flag(mapData, "dragonride_crafted");
  restore_flag(mapData, "dragon_strike_quest_complete");
  restore_flag(mapData, "generator_charged");
  restore_flag(mapData, "key_placement");
  restore_flag(mapData, "keys_placed");
  restore_flag(mapData, "scenarios_complete");
  restore_flag(mapData, "dragon_egg_acquired");
  restore_flag(mapData, "egg_awakened");
  restore_flag(mapData, "gauntlet_step_2_complete");
  restore_flag(mapData, "gauntlet_step_3_complete");
  restore_flag(mapData, "gauntlet_step_4_complete");
  restore_flag(mapData, "gauntlet_quest_complete");
  restore_flag(mapData, "dragon_wings_items_aquired");
  restore_flag(mapData, "dragon_platforms_all_used");
  restore_flag(mapData, "wearables_raz_mask_complete");
  restore_flag(mapData, "wearables_raz_arms_complete");
  restore_flag(mapData, "wearables_sentinel_arms_complete");
  restore_flag(mapData, "wearables_sentinel_camera_complete");
  restore_flag(mapData, "drshup_step_1_done");
  restore_flag(mapData, "drshup_bathed_in_flame");
  restore_flag(mapData, "drshup_factory_rune_hit");
  restore_flag(mapData, "drshup_judicial_rune_hit");
  restore_flag(mapData, "drshup_factory_rune_hit");
  restore_flag(mapData, "drshup_rune_step_done");
end

function player_restore_zm_stalingrad(xuid, playerData)
  restore_player_score(xuid, playerData)
  restore_player_perks(xuid, playerData)
  restore_player_loadout(xuid, playerData)
  restore_player_flag(xuid, playerData, "flag_player_completed_challenge_1")
  restore_player_flag(xuid, playerData, "flag_player_completed_challenge_2")
  restore_player_flag(xuid, playerData, "flag_player_completed_challenge_3")
  restore_player_flag(xuid, playerData, "flag_player_completed_challenge_4")
  restore_player_flag(xuid, playerData, "flag_player_collected_reward_1")
  restore_player_flag(xuid, playerData, "flag_player_collected_reward_2")
  restore_player_flag(xuid, playerData, "flag_player_collected_reward_3")
  restore_player_flag(xuid, playerData, "flag_player_collected_reward_4")
  restore_player_flag(xuid, playerData, "flag_player_collected_reward_5")
end

-- Revelations
function map_save_zm_genesis(mapData)
  Archi.LogMessage("Saving map data for Revelations")
  save_spent_tokens(mapData)
  save_zombie_count(mapData)
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)
  save_flag(mapData, "all_power_on")
  save_flag(mapData, "character_stones_done")
  save_flag(mapData, "got_audio1")
  save_flag(mapData, "got_audio2")
  save_flag(mapData, "got_audio3")
  save_flag(mapData, "sophia_beam_locked")
  save_flag(mapData, "book_picked_up")
  save_flag(mapData, "book_placed")
  save_flag(mapData, "grand_tour")
  save_flag(mapData, "toys_collected")
  save_flag(mapData, "acm_done")
  save_flag(mapData, "electricity_rq_done")
  save_flag(mapData, "fire_rq_done")
  save_flag(mapData, "light_rq_done")
  save_flag(mapData, "shadow_rq_done")
  save_flag(mapData, "shards_done")
  save_flag(mapData, "writing_on_the_wall_complete")

  -- Fury Head
  save_flag(mapData, "fury_head_sniper_kill")
  -- Apothicon God
  save_flag(mapData, "apothicon_mask_all_zombies_killed")
  save_flag(mapData, "apothicon_mask_all_wasps_killed")
  save_flag(mapData, "apothicon_mask_all_spiders_killed")
  save_flag(mapData, "apothicon_mask_all_margwas_killed")
  save_flag(mapData, "apothicon_mask_all_fury_killed")
  save_flag(mapData, "apothicon_mask_all_keepers_killed")
  -- Margwa Head
  save_flag(mapData, "margwa_head_wasps_flag")
  save_flag(mapData, "margwa_head_fire_flag")
  save_flag(mapData, "margwa_head_shadow_flag")
  -- Keeper Skull
  save_flag(mapData, "keeper_skull_turret_flag")
  -- Wolf Head
  save_flag(mapData, "keeper_skull_dg4_flag")
  save_flag(mapData, "keeper_skull_zombie_flag")
  -- Helm of the King
  save_flag(mapData, "mechz_gun_flag")
  save_flag(mapData, "mechz_mask_flag")
  save_flag(mapData, "mechz_trap_flag")
  -- Siegfried
  save_val(mapData, "helm_of_siegfried")

  save_players(mapData, player_save_zm_genesis)
end

function player_save_zm_genesis(xuid, playerData)
  save_player_score(xuid, playerData)
  save_player_perks(xuid, playerData)
  save_player_loadout(xuid, playerData)
  save_player_flag(xuid, playerData, "flag_player_completed_challenge_1")
  save_player_flag(xuid, playerData, "flag_player_completed_challenge_2")
  save_player_flag(xuid, playerData, "flag_player_completed_challenge_3")
  save_player_flag(xuid, playerData, "flag_player_collected_reward_1")
  save_player_flag(xuid, playerData, "flag_player_collected_reward_2")
  save_player_flag(xuid, playerData, "flag_player_collected_reward_3")
  save_player_val(xuid, playerData, "wearable")
end

function map_restore_zm_genesis(mapData)
  Archi.LogMessage("Restoring map data for Revelations")
  restore_spent_tokens(mapData)
  restore_zombie_count(mapData)
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)
  restore_flag(mapData, "all_power_on")
  restore_flag(mapData, "character_stones_done")
  restore_flag(mapData, "got_audio1")
  restore_flag(mapData, "got_audio2")
  restore_flag(mapData, "got_audio3")
  restore_flag(mapData, "sophia_beam_locked")
  restore_flag(mapData, "book_picked_up")
  restore_flag(mapData, "book_placed")
  restore_flag(mapData, "grand_tour")
  restore_flag(mapData, "toys_collected")
  restore_flag(mapData, "acm_done")
  restore_flag(mapData, "electricity_rq_done")
  restore_flag(mapData, "fire_rq_done")
  restore_flag(mapData, "light_rq_done")
  restore_flag(mapData, "shadow_rq_done")
  restore_flag(mapData, "shards_done")
  restore_flag(mapData, "writing_on_the_wall_complete")

  -- Fury Head
  restore_flag(mapData, "fury_head_sniper_kill")
  -- Apothicon God
  restore_flag(mapData, "apothicon_mask_all_zombies_killed")
  restore_flag(mapData, "apothicon_mask_all_wasps_killed")
  restore_flag(mapData, "apothicon_mask_all_spiders_killed")
  restore_flag(mapData, "apothicon_mask_all_margwas_killed")
  restore_flag(mapData, "apothicon_mask_all_fury_killed")
  restore_flag(mapData, "apothicon_mask_all_keepers_killed")
  -- Margwa Head
  restore_flag(mapData, "margwa_head_wasps_flag")
  restore_flag(mapData, "margwa_head_fire_flag")
  restore_flag(mapData, "margwa_head_shadow_flag")
  -- Keeper Skull
  restore_flag(mapData, "keeper_skull_turret_flag")
  -- Wolf Head
  restore_flag(mapData, "keeper_skull_dg4_flag")
  restore_flag(mapData, "keeper_skull_zombie_flag")
  -- Helm of the King
  restore_flag(mapData, "mechz_gun_flag")
  restore_flag(mapData, "mechz_mask_flag")
  restore_flag(mapData, "mechz_trap_flag")
  -- Siegfried
  restore_val(mapData, "helm_of_siegfried")
end

function player_restore_zm_genesis(xuid, playerData)
  restore_player_score(xuid, playerData)
  restore_player_perks(xuid, playerData)
  restore_player_loadout(xuid, playerData)
  restore_player_flag(xuid, playerData, "flag_player_completed_challenge_1")
  restore_player_flag(xuid, playerData, "flag_player_completed_challenge_2")
  restore_player_flag(xuid, playerData, "flag_player_completed_challenge_3")
  restore_player_flag(xuid, playerData, "flag_player_collected_reward_1")
  restore_player_flag(xuid, playerData, "flag_player_collected_reward_2")
  restore_player_flag(xuid, playerData, "flag_player_collected_reward_3")
  restore_player_val(xuid, playerData, "wearable")
end

-- The Giant
function map_save_zm_factory(mapData)
  Archi.LogMessage("Saving map data for The Giant")
  save_spent_tokens(mapData)
  save_zombie_count(mapData)
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)
  save_flag(mapData, "teleporter_pad_link_1")
  save_flag(mapData, "teleporter_pad_link_2")
  save_flag(mapData, "teleporter_pad_link_3")

  save_players(mapData, player_save_zm_factory)
end

function player_save_zm_factory(xuid, playerData)
  save_player_score(xuid, playerData)
  save_player_perks(xuid, playerData)
  save_player_loadout(xuid, playerData)
end

function map_restore_zm_factory(mapData)
  Archi.LogMessage("Restoring map data for The Giant")
  restore_spent_tokens(mapData)
  restore_zombie_count(mapData)
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)
  restore_flag(mapData, "teleporter_pad_link_1")
  restore_flag(mapData, "teleporter_pad_link_2")
  restore_flag(mapData, "teleporter_pad_link_3")
end

function player_restore_zm_factory(xuid, playerData)
  restore_player_score(xuid, playerData)
  restore_player_perks(xuid, playerData)
  restore_player_loadout(xuid, playerData)
end

-- Kino der Toten
function map_save_zm_theater(mapData)
  Archi.LogMessage("Saving map data for Kino der Toten")
  save_spent_tokens(mapData)
  save_zombie_count(mapData)
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)

  save_players(mapData, player_save_zm_theater)
end

function player_save_zm_theater(xuid, playerData)
  save_player_score(xuid, playerData)
  save_player_perks(xuid, playerData)
  save_player_loadout(xuid, playerData)
end

function map_restore_zm_theater(mapData)
  Archi.LogMessage("Restoring map data for Kino der Toten")
  restore_spent_tokens(mapData)
  restore_zombie_count(mapData)
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)
end

function player_restore_zm_theater(xuid, playerData)
  restore_player_score(xuid, playerData)
  restore_player_perks(xuid, playerData)
  restore_player_loadout(xuid, playerData)
end

-- Moon
function map_save_zm_moon(mapData)
  Archi.LogMessage("Saving map data for Moon")
  save_spent_tokens(mapData)
  save_zombie_count(mapData)
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)
  save_airlocks(mapData)

  save_val(mapData, "sq_ss1_completed")
  save_val(mapData, "release_complete")
  save_val(mapData, "teleporter_breached")
  save_val(mapData, "complete_be_1")
  save_val(mapData, "sam_switch_thrown")
  save_val(mapData, "c_built")
  save_val(mapData, "w_placed")
  save_val(mapData, "vg_placed")
  save_val(mapData, "ctvg_tp_done")
  save_val(mapData, "kill_press_monitor")

  save_val(mapData, "sd_hound")
  save_val(mapData, "sd_bear")
  save_val(mapData, "sd_bone")

  save_players(mapData, player_save_zm_theater)
end

function player_save_zm_moon(xuid, playerData)
  save_player_score(xuid, playerData)
  save_player_perks(xuid, playerData)
  save_player_loadout(xuid, playerData)
end

function map_restore_zm_moon(mapData)
  Archi.LogMessage("Restoring map data for Moon")
  restore_spent_tokens(mapData)
  restore_zombie_count(mapData)
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)
  restore_airlocks(mapData)

  restore_val(mapData, "sq_ss1_completed")
  restore_val(mapData, "release_complete")
  restore_val(mapData, "teleporter_breached")
  restore_val(mapData, "complete_be_1")
  restore_val(mapData, "sam_switch_thrown")
  restore_val(mapData, "c_built")
  restore_val(mapData, "w_placed")
  restore_val(mapData, "vg_placed")
  restore_val(mapData, "ctvg_tp_done")
  restore_val(mapData, "kill_press_monitor")

  restore_val(mapData, "sd_hound")
  restore_val(mapData, "sd_bear")
  restore_val(mapData, "sd_bone")
end

function player_restore_zm_moon(xuid, playerData)
  restore_player_score(xuid, playerData)
  restore_player_perks(xuid, playerData)
  restore_player_loadout(xuid, playerData)
end

-- Origins
function map_save_zm_tomb(mapData)
  Archi.LogMessage("Saving map data for Origins")
  save_spent_tokens(mapData)
  save_zombie_count(mapData)
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)

  save_val(mapData, "ee_all_staffs_placed")
  save_val(mapData, "ee_mech_zombie_fight_completed")
  save_val(mapData, "ee_maxis_drone_retrieved")
  save_val(mapData, "ee_all_players_upgraded_punch")
  save_val(mapData, "ee_souls_absorbed")

  save_val(mapData, "generator_start_bunker")
  save_val(mapData, "generator_tank_trench")
  save_val(mapData, "generator_mid_trench")
  save_val(mapData, "generator_nml_right")
  save_val(mapData, "generator_nml_left")
  save_val(mapData, "generator_church")

  save_val(mapData, "_craftable_gramophone_vinyl_player")
  save_val(mapData, "_craftable_gramophone_vinyl_master")

  -- Teleporter usage (reveals gems)
  save_val(mapData, "teleporter_used_1")
  save_val(mapData, "teleporter_used_2")
  save_val(mapData, "teleporter_used_3")
  save_val(mapData, "teleporter_used_4")
  save_val(mapData, "crypt_opened")

  save_val(mapData, "_craftable_elemental_staff_water_upper_staff")
  save_val(mapData, "_craftable_elemental_staff_water_middle_staff")
  save_val(mapData, "_craftable_elemental_staff_water_lower_staff")
  save_val(mapData, "elemental_staff_water_crafted")
  save_val(mapData, "ice_puzzle_1_complete")
  save_val(mapData, "ice_puzzle_2_complete")
  save_val(mapData, "staff_water_upgrade_unlocked")
  save_val(mapData, "staff_water_upgrade_charges")
  
  save_val(mapData, "_craftable_elemental_staff_fire_upper_staff")
  save_val(mapData, "_craftable_elemental_staff_fire_middle_staff")
  save_val(mapData, "_craftable_elemental_staff_fire_lower_staff")
  save_val(mapData, "elemental_staff_fire_crafted")
  save_val(mapData, "fire_puzzle_1_complete")
  save_val(mapData, "fire_puzzle_2_complete")
  save_val(mapData, "staff_fire_upgrade_unlocked")
  save_val(mapData, "staff_fire_upgrade_charges")
  
  save_val(mapData, "_craftable_elemental_staff_air_upper_staff")
  save_val(mapData, "_craftable_elemental_staff_air_middle_staff")
  save_val(mapData, "_craftable_elemental_staff_air_lower_staff")
  save_val(mapData, "elemental_staff_air_crafted")
  save_val(mapData, "air_puzzle_1_complete")
  save_val(mapData, "air_puzzle_2_complete")
  save_val(mapData, "staff_air_upgrade_unlocked")
  save_val(mapData, "staff_air_upgrade_charges")
  
  save_val(mapData, "_craftable_elemental_staff_lightning_upper_staff")
  save_val(mapData, "_craftable_elemental_staff_lightning_middle_staff")
  save_val(mapData, "_craftable_elemental_staff_lightning_lower_staff")
  save_val(mapData, "elemental_staff_lightning_crafted")
  save_val(mapData, "electric_puzzle_1_complete")
  save_val(mapData, "electric_puzzle_2_complete")
  save_val(mapData, "staff_lightning_upgrade_unlocked")
  save_val(mapData, "staff_lightning_upgrade_charges")

  save_val(mapData, "box_souls0")
  save_val(mapData, "box_souls1")
  save_val(mapData, "box_souls2")
  save_val(mapData, "box_souls3")

  save_players(mapData, player_save_zm_theater)
end

function player_save_zm_tomb(xuid, playerData)
  save_player_score(xuid, playerData)
  save_player_perks(xuid, playerData)
  save_player_loadout(xuid, playerData)
end

function map_restore_zm_tomb(mapData)
  Archi.LogMessage("Restoring map data for Origins")
  restore_spent_tokens(mapData)
  restore_zombie_count(mapData)
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)

  restore_val(mapData, "ee_all_staffs_placed")
  restore_val(mapData, "ee_mech_zombie_fight_completed")
  restore_val(mapData, "ee_maxis_drone_retrieved")
  restore_val(mapData, "ee_all_players_upgraded_punch")
  restore_val(mapData, "ee_souls_absorbed")

  restore_val(mapData, "generator_start_bunker")
  restore_val(mapData, "generator_tank_trench")
  restore_val(mapData, "generator_mid_trench")
  restore_val(mapData, "generator_nml_right")
  restore_val(mapData, "generator_nml_left")
  restore_val(mapData, "generator_church")

  restore_val(mapData, "_craftable_gramophone_vinyl_player")
  restore_val(mapData, "_craftable_gramophone_vinyl_master")

  -- Teleporter usage (reveals gems)
  restore_val(mapData, "teleporter_used_1")
  restore_val(mapData, "teleporter_used_2")
  restore_val(mapData, "teleporter_used_3")
  restore_val(mapData, "teleporter_used_4")
  restore_val(mapData, "crypt_opened")

  restore_val(mapData, "_craftable_elemental_staff_water_upper_staff")
  restore_val(mapData, "_craftable_elemental_staff_water_middle_staff")
  restore_val(mapData, "_craftable_elemental_staff_water_lower_staff")
  restore_val(mapData, "elemental_staff_water_crafted")
  restore_val(mapData, "ice_puzzle_1_complete")
  restore_val(mapData, "ice_puzzle_2_complete")
  restore_val(mapData, "staff_water_upgrade_unlocked")
  restore_val(mapData, "staff_water_upgrade_charges")
  
  restore_val(mapData, "_craftable_elemental_staff_fire_upper_staff")
  restore_val(mapData, "_craftable_elemental_staff_fire_middle_staff")
  restore_val(mapData, "_craftable_elemental_staff_fire_lower_staff")
  restore_val(mapData, "elemental_staff_fire_crafted")
  restore_val(mapData, "fire_puzzle_1_complete")
  restore_val(mapData, "fire_puzzle_2_complete")
  restore_val(mapData, "staff_fire_upgrade_unlocked")
  restore_val(mapData, "staff_fire_upgrade_charges")
  
  restore_val(mapData, "_craftable_elemental_staff_air_upper_staff")
  restore_val(mapData, "_craftable_elemental_staff_air_middle_staff")
  restore_val(mapData, "_craftable_elemental_staff_air_lower_staff")
  restore_val(mapData, "elemental_staff_air_crafted")
  restore_val(mapData, "air_puzzle_1_complete")
  restore_val(mapData, "air_puzzle_2_complete")
  restore_val(mapData, "staff_air_upgrade_unlocked")
  restore_val(mapData, "staff_air_upgrade_charges")
  
  restore_val(mapData, "_craftable_elemental_staff_lightning_upper_staff")
  restore_val(mapData, "_craftable_elemental_staff_lightning_middle_staff")
  restore_val(mapData, "_craftable_elemental_staff_lightning_lower_staff")
  restore_val(mapData, "elemental_staff_lightning_crafted")
  restore_val(mapData, "electric_puzzle_1_complete")
  restore_val(mapData, "electric_puzzle_2_complete")
  restore_val(mapData, "staff_lightning_upgrade_unlocked")
  restore_val(mapData, "staff_lightning_upgrade_charges")

  restore_val(mapData, "box_souls0")
  restore_val(mapData, "box_souls1")
  restore_val(mapData, "box_souls2")
  restore_val(mapData, "box_souls3")
end

function player_restore_zm_tomb(xuid, playerData)
  restore_player_score(xuid, playerData)
  restore_player_perks(xuid, playerData)
  restore_player_loadout(xuid, playerData)
end

-- Wanted
function map_save_zm_westernz(mapData, uniData)
  Archi.LogMessage("Saving map data for Wanted");
  save_spent_tokens(mapData)
  save_zombie_count(mapData)
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)
  save_modded_floating_debris(mapData)
  
  save_val(mapData, "skulls_collected")
  save_val(mapData, "barn_open")

  save_players(mapData, player_save_zm_westernz)
end

function player_save_zm_westernz(xuid, playerData)
  save_player_score(xuid, playerData)
  save_player_perks(xuid, playerData)
  save_player_loadout(xuid, playerData)
end

function map_restore_zm_westernz(mapData)
  Archi.LogMessage("Restoring map data for Wanted")
  restore_spent_tokens(mapData)
  restore_zombie_count(mapData)
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)
  restore_modded_floating_debris(mapData)

  restore_val(mapData, "skulls_collected")
  restore_val(mapData, "barn_open")
end

function player_restore_zm_westernz(xuid, playerData)
  restore_player_score(xuid, playerData)
  restore_player_perks(xuid, playerData)
  restore_player_loadout(xuid, playerData)
end

-- General Purpose
function restore_flag(mapData, flag)
  if mapData["flags"] and mapData["flags"][flag] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_MAP_" .. string.upper(flag), 1)
  end
end

function restore_player_flag(xuid, playerData, flag)
  if playerData["flags"] and playerData["flags"][flag] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_XUID_" .. xuid .. "_MAP_" .. string.upper(flag), 1)
  end
end

function restore_player_val(xuid, playerData, kval)
  if playerData["kvals"] then
    local val = playerData["kvals"][kval]
    if val ~= nil then
      Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_XUID_" .. xuid .. "_KVAL_" .. string.upper(kval), val)
    end
  end
end

function restore_round_number(mapData)
  if mapData["round_number"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_ROUND", mapData["round_number"])
  end

  if mapData["next_dog_round"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_NEXT_DOG_ROUND", mapData["next_dog_round"])
  end

  if mapData["next_spider_round"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_NEXT_SPIDER_ROUND", mapData["next_spider_round"])
  end

  if mapData["next_drone_round"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_NEXT_DRONE_ROUND", mapData["next_drone_round"])
  end

  if mapData["next_raz_round"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_NEXT_RAZ_ROUND", mapData["next_raz_round"])
  end

  if mapData["next_miniboss_round"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_NEXT_MINIBOSS_ROUND", mapData["next_miniboss_round"])
  end

  if mapData["next_chaos_round"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_NEXT_CHAOS_ROUND", mapData["next_chaos_round"])
  end
  
  if mapData["next_wasp_round"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_NEXT_WASP_ROUND", mapData["next_wasp_round"])
  end
  
  if mapData["next_mechz_round"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_NEXT_MECHZ_ROUND", mapData["next_mechz_round"])
  end
  
  if mapData["next_monkey_round"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_NEXT_MONKEY_ROUND", mapData["next_monkey_round"])
  end
  
  if mapData["next_astro_round"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_NEXT_ASTRO_ROUND", mapData["next_astro_round"])
  end

  if mapData["last_rain_round"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_LAST_RAIN_ROUND", mapData["last_rain_round"])
  end

  if mapData["last_snow_round"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_LAST_SNOW_ROUND", mapData["last_snow_round"])
  end
end

function restore_doors_and_debris(mapData)
  if mapData["doors_opened"] then
    local doorsOpened = mapData["doors_opened"]
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_OPENED_DOORS", table.concat(doorsOpened, ";"))
  end

  if mapData["debris_opened"] then
    local debrisOpened = mapData["debris_opened"]
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_OPENED_DEBRIS", table.concat(debrisOpened, ";"))
  end
end

function restore_airlocks(mapData)
  if mapData["airlocks_opened"] then
    local airlocksOpened = mapData["airlocks_opened"]
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_OPENED_AIRLOCKS", table.concat(airlocksOpened, ";"))
  end
end

function restore_modded_floating_debris(mapData)
  if mapData["modded_floating_debris_opened"] then
    local debrisOpened = mapData["modded_floating_debris_opened"]
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_OPENED_MODDED_FLOATING_DEBRIS", table.concat(debrisOpened, ";"))
  end
end

function restore_power_on(mapData)
  if mapData["power_on"] and mapData["power_on"] == 1 then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_POWER_ON", 1)
  else
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_POWER_ON", 0)
  end
end

function restore_zombie_count(mapData)
  if mapData["zombie_count"] and mapData["zombie_count"] > 0 then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_ZOMBIE_COUNT", mapData["zombie_count"])
  end
end

function save_players(mapData, cb)
  if not mapData["players"] then
    mapData["players"] = {}
  end
  local xuidList = Engine.DvarString("","ARCHIPELAGO_SAVE_DATA_XUIDS")
  for xuid in string.gmatch(xuidList, "[^;]+") do
    playerData = {
      flags = {},
      kvals = {},
    }
    cb(xuid, playerData)
    save_map_player(xuid, playerData)
    mapData["players"][xuid] = playerData
  end
end

function save_universal_players(mapName, uniData)
  local xuidList = Engine.DvarString("","ARCHIPELAGO_SAVE_DATA_XUIDS")
  for xuid in string.gmatch(xuidList, "[^;]+") do
    save_universal_player(mapName, xuid, uniData)
  end
end

function restore_player_score(xuid, playerData)
  if playerData["score"] then
    Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_SCORE_" .. xuid, playerData["score"] )
  end
end

function restore_player_perks(xuid, playerData)
  if playerData["perks"] then
    local i = 0
    for _, perk in ipairs(playerData["perks"]) do
      Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_PERK_" .. xuid .. "_" .. i, perk )
      i = i + 1
    end
  end
end

function restore_player_loadout(xuid, playerData)
  if playerData["bgb"] then
    Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_BGB_" .. xuid, playerData["bgb"])
  end
  if playerData["heroWeapon"] then
    Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" .. xuid .. "_HEROWEAPON", playerData["heroWeapon"] )
    if playerData["heroPower"] then
      Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" .. xuid .. "_HEROWEAPON_POWER", playerData["heroPower"] )
    end
  end
  if playerData["weapons"] then
    local i = 0
    for _, weapon in ipairs(playerData["weapons"]) do
      Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_WEAPON", weapon.weapon )
      Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_CLIP", weapon.clip )
      Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_LHCLIP", weapon.lh_clip or 0)
      Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_STOCK", weapon.stock )
      Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_ALTCLIP", weapon.alt_clip or 0)
      Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_ALTSTOCK", weapon.alt_stock or 0)
      i = i + 1
    end
  end
end

function save_val(mapData, key)
  local val = Engine.DvarString("", "ARCHIPELAGO_SAVE_DATA_MAP_KVAL_" .. string.upper(key))
  Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_MAP_KVAL_" .. string.upper(key), "")
  
  if val and val ~= "" then
    mapData["kvals"][key] = val
  end
end

function restore_val(mapData, key)
  if mapData["kvals"] and mapData["kvals"][key] then
    local val = mapData["kvals"][key]
    if val ~= nil then
      Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_MAP_KVAL_" .. string.upper(key), tostring(val))
    end
  end
end

function save_flag(mapData, flag)
  local val = Engine.DvarInt(0, "ARCHIPELAGO_SAVE_DATA_MAP_" .. string.upper(flag))
  Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_MAP_" .. string.upper(flag), "")
  if val ~= 0 then
    mapData["flags"][flag] = 1
  end
end

function save_player_flag(xuid, playerData, flag)
  local val = Engine.DvarInt(0, "ARCHIPELAGO_SAVE_DATA_XUID_" .. xuid .. "_MAP_" .. string.upper(flag))
  Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_" .. xuid .. "_MAP_" .. string.upper(flag), 0)
  if val ~= 0 then
    playerData["flags"][flag] = 1
  end
end

function save_player_val(xuid, playerData, kval)
  local val = Engine.DvarString("", "ARCHIPELAGO_SAVE_DATA_XUID_" .. xuid .. "_KVAL_" .. string.upper(kval))
  Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_" .. xuid .. "_KVAL_" .. string.upper(kval), "")
  if val and val ~= "" then
    playerData["kvals"][kval] = val
  end
end

function save_round_number(mapData)
  local roundNumber = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_ROUND")
  if roundNumber and roundNumber > 1 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_ROUND", "")
    mapData.round_number = roundNumber
  end

  local dogRound = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_NEXT_DOG_ROUND")
  if dogRound and dogRound > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_NEXT_DOG_ROUND", "")
    mapData.next_dog_round = dogRound
  end

  local spiderRound = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_NEXT_SPIDER_ROUND")
  if spiderRound and spiderRound > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_NEXT_SPIDER_ROUND", "")
    mapData.next_spider_round = spiderRound
  end

  local razRound = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_NEXT_RAZ_ROUND")
  if razRound and razRound > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_NEXT_RAZ_ROUND", "")
    mapData.next_raz_round = razRound
  end

  local droneRound = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_NEXT_DRONE_ROUND")
  if droneRound and droneRound > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_NEXT_DRONE_ROUND", "")
    mapData.next_drone_round = droneRound
  end

  local minibossRound = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_NEXT_MINIBOSS_ROUND")
  if minibossRound and minibossRound > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_NEXT_MINIBOSS_ROUND", "")
    mapData.next_miniboss_round = minibossRound
  end

  local chaosRound = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_NEXT_CHAOS_ROUND")
  if chaosRound and chaosRound > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_NEXT_CHAOS_ROUND", "")
    mapData.next_chaos_round = chaosRound
  end
  
  local waspRound = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_NEXT_WASP_ROUND")
  if waspRound and waspRound > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_NEXT_WASP_ROUND", "")
    mapData.next_wasp_round = waspRound
  end
  
  local mechzRound = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_NEXT_MECHZ_ROUND")
  if mechzRound and mechzRound > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_NEXT_MECHZ_ROUND", "")
    mapData.next_mechz_round = mechzRound
  end
  
  local monkeyRound = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_NEXT_MONKEY_ROUND")
  if monkeyRound and monkeyRound > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_NEXT_MONKEY_ROUND", "")
    mapData.next_monkey_round = monkeyRound
  end
  
  local astroRound = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_NEXT_ASTRO_ROUND")
  if astroRound and astroRound > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_NEXT_ASTRO_ROUND", "")
    mapData.next_astro_round = astroRound
  end

  local last_rain_round = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_LAST_RAIN_ROUND")
  if last_rain_round and last_rain_round > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_LAST_RAIN_ROUND", "")
    mapData.last_rain_round = last_rain_round
  end

  local last_snow_round = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_LAST_SNOW_ROUND")
  if last_snow_round and last_snow_round > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_LAST_SNOW_ROUND", "")
    mapData.last_snow_round = last_snow_round
  end
end

function save_doors_and_debris(mapData)
  local doorStr = Engine.DvarString(nil, "ARCHIPELAGO_SAVE_DATA_OPENED_DOORS");
  local debrisStr = Engine.DvarString(nil, "ARCHIPELAGO_SAVE_DATA_OPENED_DEBRIS");
  if doorStr then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_OPENED_DOORS", "");
  end
  if debrisStr then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_OPENED_DEBRIS", "");
  end
  local doorsOpened = {}
  local debrisOpened = {}

  for doorId in string.gmatch(doorStr, "[^;]+") do
    table.insert(doorsOpened, doorId);
  end
  for debrisId in string.gmatch(debrisStr, "[^;]+") do
    table.insert(debrisOpened, debrisId);
  end

  mapData.doors_opened = doorsOpened
  mapData.debris_opened = debrisOpened
end

function save_airlocks(mapData)
  local airlockStr = Engine.DvarString(nil, "ARCHIPELAGO_SAVE_DATA_OPENED_AIRLOCKS");
  if airlockStr then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_OPENED_AIRLOCKS", "");
  end
  local airlocksOpened = {}

  for airlockId in string.gmatch(airlockStr, "[^;]+") do
    table.insert(airlocksOpened, airlockId);
  end

  mapData.airlocks_opened = airlocksOpened
end

function save_modded_floating_debris(mapData)
  local debrisStr = Engine.DvarString(nil, "ARCHIPELAGO_SAVE_DATA_OPENED_MODDED_FLOATING_DEBRIS");
  if debrisStr then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_OPENED_MODDED_FLOATING_DEBRIS", "");
  end
  local debrisOpened = {}

  for debrisId in string.gmatch(debrisStr, "[^;]+") do
    table.insert(debrisOpened, debrisId);
  end

  mapData.modded_floating_debris_opened = debrisOpened
end

function save_power_on(mapData)
  local powerOn = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_POWER_ON")
  if powerOn and powerOn > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_POWER_ON", "")
    mapData.power_on = 1
  else
    mapData.power_on = 0
  end
end

function save_zombie_count(mapData)
  local zombieCount = Engine.DvarInt(-1, "ARCHIPELAGO_SAVE_DATA_ZOMBIE_COUNT")
  Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_ZOMBIE_COUNT", "")
  mapData.zombie_count = zombieCount
end

function save_player_score(xuid, playerData)
  local score = Engine.DvarInt(0, "ARCHIPELAGO_SAVE_DATA_XUID_SCORE_" .. xuid)
  if score and score > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_SCORE_" .. xuid, "")
    playerData.score = score
  end
end

function save_player_perks(xuid, playerData)
  playerData.perks = {}
  local i = 0
  while true do
    local perk = Engine.DvarString(nil, "ARCHIPELAGO_SAVE_DATA_XUID_PERK_" .. xuid .. "_" .. i)
    if not perk or perk == "" then
      break
    end
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_PERK_" .. xuid .. "_" .. i, "")
    table.insert(playerData.perks, perk)
    i = i + 1
  end
end

function save_player_loadout(xuid, playerData)
  local bgb = Engine.DvarString("", "ARCHIPELAGO_SAVE_DATA_XUID_BGB_" .. xuid)
  if bgb ~= "" then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_BGB_" .. xuid, "")
    playerData.bgb = bgb
  end

  local heroWeaponName = Engine.DvarString("", "ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" .. xuid .. "_HEROWEAPON")
  if heroWeaponName ~= "" then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" .. xuid .. "_HEROWEAPON", "")
    playerData.heroWeapon = heroWeaponName
    local heroPower = Engine.DvarInt(-1, "ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" .. xuid .. "_HEROWEAPON_POWER")
    playerData.heroPower = heroPower
  end

  playerData.weapons = {}
  i = 0
  while true do
    local weaponName = Engine.DvarString(nil, "ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_WEAPON")
    local weaponClip = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_CLIP")
    local weaponLhClip = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_LHCLIP")
    local weaponStock = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_STOCK")
    local weaponAltClip = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_ALTCLIP")
    local weaponAltStock = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_ALTSTOCK")

    if not weaponName or weaponName == "" then
      break
    end
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_WEAPON", "")
    table.insert(playerData.weapons, {
      weapon = weaponName,
      clip = weaponClip,
      lh_clip = weaponLhClip,
      stock = weaponStock,
      alt_clip = weaponAltClip,
      alt_stock = weaponAltStock,
    })
    i = i + 1
  end
end

function save_zm_castle_landingpads(mapData)
  local landingpads = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_CASTLE_LANDINGPADS")
  if landingpads and landingpads > 0 then
    Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_CASTLE_LANDINGPADS","")
    mapData.landingpads = 1
  else 
    mapData.landingpads = 0
  end
end

function restore_zm_castle_landingpads(mapData)
  if mapData["landingpads"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_CASTLE_LANDINGPADS", mapData["landingpads"])
  end
end

function save_universal(uniData)

end

function save_universal_player(mapName, xuid, uniData)
  uniData["player_stats"][mapName][xuid] = {}

  local kills = Engine.DvarInt(-1,"ARCHIPELAGO_SAVE_DATA_UNIVERSAL_XUID_KILLS_" .. xuid)
  Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_UNIVERSAL_XUID_KILLS_" .. xuid, -1)
  if kills and kills >= 0 then
    uniData["player_stats"][mapName][xuid]["kills"] = kills
  end
  
  local headshots = Engine.DvarInt(-1,"ARCHIPELAGO_SAVE_DATA_UNIVERSAL_XUID_HEADSHOTS_" .. xuid)
  Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_UNIVERSAL_XUID_HEADSHOTS_" .. xuid, -1)
  if headshots and headshots >= 0 then
    uniData["player_stats"][mapName][xuid]["headshots"] = headshots
  end
  
  local revives = Engine.DvarInt(-1,"ARCHIPELAGO_SAVE_DATA_UNIVERSAL_XUID_REVIVES_" .. xuid)
  Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_UNIVERSAL_XUID_REVIVES_" .. xuid, -1)
  if revives and revives >= 0 then
    uniData["player_stats"][mapName][xuid]["revives"] = revives
  end
  
  local downs = Engine.DvarInt(-1,"ARCHIPELAGO_SAVE_DATA_UNIVERSAL_XUID_DOWNS_" .. xuid)
  Engine.SetDvar("ARCHIPELAGO_SAVE_DATA_UNIVERSAL_XUID_DOWNS_" .. xuid, -1)
  if downs and downs >= 0 then
    uniData["player_stats"][mapName][xuid]["downs"] = downs
  end
end

function restore_universal(uniData)
  if uniData["mapItems"] then
    Engine.SetDvar("ARCHIPELAGO_INIT_MAP_ITEMS", table.concat(uniData["mapItems"], ";"))
  end
end

function restore_universal_player(mapName, xuid, uniData)
  playerStats = uniData["player_stats"][mapName][xuid]
  
  if playerStats then
    Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_UNIVERSAL_XUID_READY_" .. xuid, "true" )

    if playerStats["kills"] then
      Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_UNIVERSAL_XUID_KILLS_" .. xuid, playerStats["kills"])
    end
    if playerStats["headshots"] then
      Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_UNIVERSAL_XUID_HEADSHOTS_" .. xuid, playerStats["headshots"])
    end
    if playerStats["revives"] then
      Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_UNIVERSAL_XUID_REVIVES_" .. xuid, playerStats["revives"])
    end
    if playerStats["downs"] then
      Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_UNIVERSAL_XUID_DOWNS_" .. xuid, playerStats["downs"])
    end
  end
end

function save_map_player(xuid, playerData)
  save_player_val(xuid, playerData, "progressive_starting_points")
  save_player_val(xuid, playerData, "spent_perk_tokens")
  save_player_val(xuid, playerData, "spent_gum_tokens")
  save_player_val(xuid, playerData, "spent_rare_gum_tokens")
  save_player_val(xuid, playerData, "spent_legendary_gum_tokens")
end

function restore_map_player(mapName, xuid, playerData)
  restore_player_val(xuid, playerData, "progressive_starting_points")
  restore_player_val(xuid, playerData, "spent_perk_tokens")
  restore_player_val(xuid, playerData, "spent_gum_tokens")
  restore_player_val(xuid, playerData, "spent_rare_gum_tokens")
  restore_player_val(xuid, playerData, "spent_legendary_gum_tokens")
end

function save_spent_tokens(mapData)
  local checkpoints = Engine.DvarInt(0, "ARCHIPELAGO_SAVE_SPENT_CHECKPOINT_TOKENS")
  if checkpoints < 0 then
    checkpoints = 0
  end
  mapData["spent_checkpoint_tokens"] = checkpoints
end

function restore_spent_tokens(mapData)
  if mapData["spent_checkpoint_tokens"] then
    Engine.SetDvar( "ARCHIPELAGO_LOAD_SPENT_CHECKPOINT_TOKENS", mapData["spent_checkpoint_tokens"] )
  end
end

map_saves = {
  zm_zod = map_save_zm_zod,
  zm_castle = map_save_zm_castle,
  zm_island = map_save_zm_island,
  zm_stalingrad = map_save_zm_stalingrad,
  zm_genesis = map_save_zm_genesis,
  zm_factory = map_save_zm_factory,
  zm_theater = map_save_zm_theater,
  zm_westernz = map_save_zm_westernz,
  zm_moon = map_save_zm_moon,
  zm_tomb = map_save_zm_tomb,
}

player_saves = {
  zm_zod = player_save_zm_zod,
  zm_castle = player_save_zm_castle,
  zm_island = player_save_zm_island,
  zm_stalingrad = player_save_zm_stalingrad,
  zm_genesis = player_save_zm_genesis,
  zm_factory = player_save_zm_factory,
  zm_theater = player_save_zm_theater,
  zm_westernz = player_save_zm_westernz,
  zm_moon = player_save_zm_moon,
  zm_tomb = player_save_zm_tomb,
}

map_restores = {
  zm_zod = map_restore_zm_zod,
  zm_castle = map_restore_zm_castle,
  zm_island = map_restore_zm_island,
  zm_stalingrad = map_restore_zm_stalingrad,
  zm_genesis = map_restore_zm_genesis,
  zm_factory = map_restore_zm_factory,
  zm_theater = map_restore_zm_theater,
  zm_westernz = map_restore_zm_westernz,
  zm_moon = map_restore_zm_moon,
  zm_tomb = map_restore_zm_tomb,
}

player_restores = {
  zm_zod = player_restore_zm_zod,
  zm_castle = player_restore_zm_castle,
  zm_island = player_restore_zm_island,
  zm_stalingrad = player_restore_zm_stalingrad,
  zm_genesis = player_restore_zm_genesis,
  zm_factory = player_restore_zm_factory,
  zm_theater = player_restore_zm_theater,
  zm_westernz = player_restore_zm_westernz,
  zm_moon = player_restore_zm_moon,
  zm_tomb = player_restore_zm_tomb,
}

return {
  map_saves = map_saves,
  map_restores = map_restores,
  player_saves = player_saves,
  player_restores = player_restores,
  save_universal = save_universal,
  restore_universal = restore_universal,
  save_universal_player = save_universal_player,
  save_universal_players = save_universal_players,
  restore_universal_player = restore_universal_player,
  save_map_player = save_map_player,
  restore_map_player = restore_map_player,
}

-- Rough template for a map
---- add map_save_mapname to map_saves
---- add player_save_mapname to player_saves
---- add player_restore_mapname to player_restores
---- add map_restore_mapname to map_restores