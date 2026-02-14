function map_save_zm_castle(mapData)
  Archi.LogMessage("Saving map data for Der Eisendrache");
  save_zombie_count(mapData)
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)
  save_zm_castle_landingpads(mapData)
  save_zm_castle_boss_ready(mapData)
  save_flag(mapData, "soul_catchers_charged")
  save_flag(mapData, "death_ray_trap_used")
  save_flag(mapData, "ee_fuse_placed")
  save_flag(mapData, "ee_safe_open")
  save_flag(mapData, "switch_to_death_ray")
  save_flag(mapData, "tesla_connector_launch_platform")
  save_flag(mapData, "tesla_connector_lower_tower")
  save_flag(mapData, "demon_gate_upgraded")
  save_flag(mapData, "elemental_storm_upgraded")
  save_flag(mapData, "rune_prison_upgraded")
  save_flag(mapData, "wolf_howl_upgraded")
  save_flag(mapData, "ee_start_done")
  save_flag(mapData, "ee_golden_key")
  save_flag(mapData, "mpd_canister_replacement")
  save_flag(mapData, "channeling_stone_replacement")
  save_flag(mapData, "start_channeling_stone_step")
  save_flag(mapData, "boss_fight_ready")

  save_player_func = function (xuid, playerData)
    save_player_score(xuid, playerData)
    save_player_perks(xuid, playerData)
    save_player_loadout(xuid, playerData)
  end

  save_players(mapData, save_player_func)
end

function map_restore_zm_castle(mapData)
  Archi.LogMessage("Restoring map data for Der Eisendrache");
  restore_zombie_count(mapData);
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)
  restore_zm_castle_landingpads(mapData)
  restore_zm_castle_boss_ready(mapData)
  restore_flag(mapData, "soul_catchers_charged")
  restore_flag(mapData, "death_ray_trap_used")
  restore_flag(mapData, "ee_fuse_placed")
  restore_flag(mapData, "ee_safe_open")
  restore_flag(mapData, "switch_to_death_ray")
  restore_flag(mapData, "tesla_connector_launch_platform")
  restore_flag(mapData, "tesla_connector_lower_tower")
  restore_flag(mapData, "demon_gate_upgraded")
  restore_flag(mapData, "elemental_storm_upgraded")
  restore_flag(mapData, "rune_prison_upgraded")
  restore_flag(mapData, "wolf_howl_upgraded")
  restore_flag(mapData, "ee_start_done")
  restore_flag(mapData, "ee_golden_key")
  restore_flag(mapData, "mpd_canister_replacement")
  restore_flag(mapData, "channeling_stone_replacement")
  restore_flag(mapData, "start_channeling_stone_step")
  restore_flag(mapData, "boss_fight_ready")

  restore_player_func = function (xuid, playerData)
    restore_player_score(xuid, playerData)
    restore_player_perks(xuid, playerData)
    restore_player_loadout(xuid, playerData)
  end

  restore_players(mapData, restore_player_func)
end

function map_save_zm_zod(mapData)
  Archi.LogMessage("Saving map data for Shadows of Evil");
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
  for i = 0, 29 do
    save_flag(mapData, "power_on" .. i)
  end

  save_player_func = function (xuid, playerData)
    save_player_score(xuid, playerData)
    save_player_perks(xuid, playerData)
    save_player_loadout(xuid, playerData)
  end

  save_players(mapData, save_player_func)
end

function map_restore_zm_zod(mapData)
  Archi.LogMessage("Restoring map data for Shadows of Evil");
  restore_zombie_count(mapData);
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
  for i = 0, 29 do
    restore_flag(mapData, "power_on" .. i)
  end

  restore_player_func = function (xuid, playerData)
    restore_player_score(xuid, playerData)
    restore_player_perks(xuid, playerData)
    restore_player_loadout(xuid, playerData)
  end

  restore_players(mapData, restore_player_func)
end

function map_save_zm_island(mapData)
  Archi.LogMessage("Saving map data for Zetsubou No Shima");
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

  save_player_func = function (xuid, playerData)
    save_player_score(xuid, playerData)
    save_player_perks(xuid, playerData)
    save_player_loadout(xuid, playerData)

    save_player_flag(xuid, playerData, "flag_player_completed_challenge_1")
    save_player_flag(xuid, playerData, "flag_player_completed_challenge_2")
    save_player_flag(xuid, playerData, "flag_player_completed_challenge_3")
    save_player_flag(xuid, playerData, "flag_player_collected_reward_1")
    save_player_flag(xuid, playerData, "flag_player_collected_reward_2")
    save_player_flag(xuid, playerData, "flag_player_collected_reward_3")
  end

  save_players(mapData, save_player_func)
end

function map_restore_zm_island(mapData)
  Archi.LogMessage("Restoring map data for Zetsubou No Shima");
  restore_zombie_count(mapData);
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

  restore_player_func = function (xuid, playerData)
    restore_player_score(xuid, playerData)
    restore_player_perks(xuid, playerData)
    restore_player_loadout(xuid, playerData)
    restore_player_flag(xuid, playerData, "flag_player_completed_challenge_1")
    restore_player_flag(xuid, playerData, "flag_player_completed_challenge_2")
    restore_player_flag(xuid, playerData, "flag_player_completed_challenge_3")
    restore_player_flag(xuid, playerData, "flag_player_collected_reward_1")
    restore_player_flag(xuid, playerData, "flag_player_collected_reward_2")
    restore_player_flag(xuid, playerData, "flag_player_collected_reward_3")
  end

  restore_players(mapData, restore_player_func)
end

function map_save_zm_stalingrad(mapData)
  Archi.LogMessage("Saving map data for Gorod Krovi")
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

  save_player_func = function (xuid, playerData)
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

  save_players(mapData, save_player_func)
end

function map_restore_zm_stalingrad(mapData)
  Archi.LogMessage("Restoring map data for Gorod Krovi")
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


  restore_player_func = function (xuid, playerData)
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

  restore_players(mapData, restore_player_func)
end

function map_save_zm_genesis(mapData)
  Archi.LogMessage("Saving map data for Revelations")
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
  save_flag(mapData, "electricity_rq_done");
  save_flag(mapData, "fire_rq_done");
  save_flag(mapData, "light_rq_done");
  save_flag(mapData, "shadow_rq_done");



  save_player_func = function (xuid, playerData)
    save_player_score(xuid, playerData)
    save_player_perks(xuid, playerData)
    save_player_loadout(xuid, playerData)
    save_player_flag(xuid, playerData, "flag_player_completed_challenge_1")
    save_player_flag(xuid, playerData, "flag_player_completed_challenge_2")
    save_player_flag(xuid, playerData, "flag_player_completed_challenge_3")
    save_player_flag(xuid, playerData, "flag_player_collected_reward_1")
    save_player_flag(xuid, playerData, "flag_player_collected_reward_2")
    save_player_flag(xuid, playerData, "flag_player_collected_reward_3")
  end

  save_players(mapData, save_player_func)
end

function map_restore_zm_genesis(mapData)
  Archi.LogMessage("Restoring map data for Revelations")
  restore_zombie_count(mapData);
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
  restore_flag(mapData, "electricity_rq_done");
  restore_flag(mapData, "fire_rq_done");
  restore_flag(mapData, "light_rq_done");
  restore_flag(mapData, "shadow_rq_done");


  restore_player_func = function (xuid, playerData)
    restore_player_score(xuid, playerData)
    restore_player_perks(xuid, playerData)
    restore_player_loadout(xuid, playerData)
    restore_player_flag(xuid, playerData, "flag_player_completed_challenge_1")
    restore_player_flag(xuid, playerData, "flag_player_completed_challenge_2")
    restore_player_flag(xuid, playerData, "flag_player_completed_challenge_3")
    restore_player_flag(xuid, playerData, "flag_player_collected_reward_1")
    restore_player_flag(xuid, playerData, "flag_player_collected_reward_2")
    restore_player_flag(xuid, playerData, "flag_player_collected_reward_3")
  end

  restore_players(mapData, restore_player_func)
end

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

function restore_round_number(mapData)
  if mapData["round_number"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_ROUND", mapData["round_number"])
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

function restore_players(mapData, cb)
  if mapData["players"] then
    for xuid, playerData in pairs(mapData.players) do
      Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_READY_" .. xuid, "true" )
      cb(xuid, playerData)
    end
  end
end

function restore_player_ready(xuid)
  Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_READY_" .. xuid, "true" )
end

function save_players(mapData, cb)
  if not mapData["players"] then
    mapData["players"] = {}
  end
  local xuidList = Engine.DvarString(nil,"ARCHIPELAGO_SAVE_DATA_XUIDS")
  for xuid in string.gmatch(xuidList, "[^;]+") do
    playerData = {
      flags = {},
    }
    cb(xuid, playerData)
    mapData["players"][xuid] = playerData
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
      local j = 0
      if weapon["attachments"] then
        for _, attachment in ipairs(weapon["attachments"]) do
          Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_ATTACHMENT_" .. j, attachment)
          j = j + 1
        end
      end
      i = i + 1
    end
  end
end

function save_flag(mapData, flag)
  local val = Engine.DvarInt(0, "ARCHIPELAGO_SAVE_DATA_MAP_" .. string.upper(flag))
  if val ~= 0 then
    mapData["flags"][flag] = 1
  end
end

function save_player_flag(xuid, playerData, flag)
  local val = Engine.DvarInt(0, "ARCHIPELAGO_SAVE_DATA_XUID_" .. xuid .. "_MAP_" .. string.upper(flag))
  if val ~= 0 then
    playerData["flags"][flag] = 1
  end
end

function save_round_number(mapData)
  local roundNumber = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_ROUND")
  if roundNumber and roundNumber > 1 then
    mapData.round_number = roundNumber
  end
end

function save_doors_and_debris(mapData)
  local doorStr = Engine.DvarString(nil, "ARCHIPELAGO_SAVE_DATA_OPENED_DOORS");
  local debrisStr = Engine.DvarString(nil, "ARCHIPELAGO_SAVE_DATA_OPENED_DEBRIS");
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

function save_power_on(mapData)
  local powerOn = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_POWER_ON")
  if powerOn and powerOn > 0 then
    mapData.power_on = 1
  else
    mapData.power_on = 0
  end
end

function save_zombie_count(mapData)
  local zombieCount = Engine.DvarInt(-1, "ARCHIPELAGO_SAVE_DATA_ZOMBIE_COUNT")
  mapData.zombie_count = zombieCount
end

function save_player_score(xuid, playerData)
  local score = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_XUID_SCORE_" .. xuid)
  if score and score > 0 then
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
    table.insert(playerData.perks, perk)
    i = i + 1
  end
end

function save_player_loadout(xuid, playerData)
  local heroWeaponName = Engine.DvarString(nil, "ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" .. xuid .. "_HEROWEAPON")
  if heroWeaponName and heroWeaponName ~= "" then
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
    local attachments = {}
    local j = 0
    while true do
      local attachment = Engine.DvarString(nil, "ARCHIPELAGO_SAVE_DATA_XUID_WEAPON_" .. xuid .. "_" .. i .. "_ATTACHMENT_" .. j)
      if attachment and attachment ~= "" then
        table.insert(attachments, attachment)
        j = j + 1
      else
        break
      end
    end

    if not weaponName or weaponName == "" then
      break
    end
    table.insert(playerData.weapons, {
      weapon = weaponName,
      clip = weaponClip,
      lh_clip = weaponLhClip,
      stock = weaponStock,
      alt_clip = weaponAltClip,
      alt_stock = weaponAltStock,
      attachments = attachments,
    })
    i = i + 1
  end
end

function save_zm_castle_dragonheads(mapData)
  local dragonheads = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_CASTLE_DRAGONHEADS")
  if dragonheads and dragonheads > 0 then
    mapData.dragonheads = 1
  else 
    mapData.dragonheads = 0
  end
end

function save_zm_castle_landingpads(mapData)
  local landingpads = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_CASTLE_LANDINGPADS")
  if landingpads and landingpads > 0 then
    mapData.landingpads = 1
  else 
    mapData.landingpads = 0
  end
end

function save_zm_castle_boss_ready(mapData)
  local boss_ready = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_CASTLE_BOSS_READY")
  if boss_ready and boss_ready > 0 then
    mapData.boss_ready = 1
  else 
    mapData.boss_ready = 0
  end
end

function restore_zm_castle_dragonheads(mapData)
  if mapData["dragonheads"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_CASTLE_DRAGONHEADS", mapData["dragonheads"])
  end
end

function restore_zm_castle_landingpads(mapData)
  if mapData["landingpads"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_CASTLE_LANDINGPADS", mapData["landingpads"])
  end
end

function restore_zm_castle_boss_ready(mapData)
  if mapData["boss_ready"] then
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_CASTLE_BOSS_READY", mapData["boss_ready"])
  end
end

map_saves = {
  zm_zod = map_save_zm_zod,
  zm_castle = map_save_zm_castle,
  zm_island = map_save_zm_island,
  zm_stalingrad = map_save_zm_stalingrad,
  zm_genesis = map_save_zm_genesis,
}

map_restores = {
  zm_zod = map_restore_zm_zod,
  zm_castle = map_restore_zm_castle,
  zm_island = map_restore_zm_island,
  zm_stalingrad = map_restore_zm_stalingrad,
  zm_genesis = map_restore_zm_genesis,
}

return {
  map_saves = map_saves,
  map_restores = map_restores,
}