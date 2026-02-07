function map_save_zm_castle(mapData)
  Archi.LogMessage("Saving map data for Der Eisendrache");
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)
  save_zm_castle_dragonheads(mapData)
  save_zm_castle_landingpads(mapData)
  save_zm_castle_boss_ready(mapData)

  save_player_func = function (xuid, playerData)
    save_player_score(xuid, playerData)
    save_player_perks(xuid, playerData)
    save_player_loadout(xuid, playerData)
  end

  save_players(mapData, save_player_func)
end

function map_restore_zm_castle(mapData)
  Archi.LogMessage("Restoring map data for Der Eisendrache");
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)
  restore_zm_castle_dragonheads(mapData)
  restore_zm_castle_landingpads(mapData)
  restore_zm_castle_boss_ready(mapData)

  restore_player_func = function (xuid, playerData)
    restore_player_score(xuid, playerData)
    restore_player_perks(xuid, playerData)
    restore_player_loadout(xuid, playerData)
  end

  restore_players(mapData, restore_player_func)
end

function map_save_zm_zod(mapData)
  Archi.LogMessage("Saving map data for Shadows of Evil");
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)

  save_player_func = function (xuid, playerData)
    save_player_score(xuid, playerData)
    save_player_perks(xuid, playerData)
    save_player_loadout(xuid, playerData)
  end

  save_players(mapData, save_player_func)
end

function map_restore_zm_zod(mapData)
  Archi.LogMessage("Restoring map data for Shadows of Evil");
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)

  restore_player_func = function (xuid, playerData)
    restore_player_score(xuid, playerData)
    restore_player_perks(xuid, playerData)
    restore_player_loadout(xuid, playerData)
  end

  restore_players(mapData, restore_player_func)
end

function map_save_zm_island(mapData)
  Archi.LogMessage("Saving map data for Zetsubou No Shima");
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
  Archi.LogMessage("Saving map data for Gorod Krovi");
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)

  save_player_func = function (xuid, playerData)
    save_player_score(xuid, playerData)
    save_player_perks(xuid, playerData)
    save_player_loadout(xuid, playerData)
  end

  save_players(mapData, save_player_func)
end

function map_restore_zm_stalingrad(mapData)
  Archi.LogMessage("Restoring map data for Gorod Krovi");
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)

  restore_player_func = function (xuid, playerData)
    restore_player_score(xuid, playerData)
    restore_player_perks(xuid, playerData)
    restore_player_loadout(xuid, playerData)
  end

  restore_players(mapData, restore_player_func)
end

function map_save_zm_genesis(mapData)
  Archi.LogMessage("Saving map data for Revelations");
  save_round_number(mapData)
  save_power_on(mapData)
  save_doors_and_debris(mapData)

  save_player_func = function (xuid, playerData)
    save_player_score(xuid, playerData)
    save_player_perks(xuid, playerData)
    save_player_loadout(xuid, playerData)
  end

  save_players(mapData, save_player_func)
end

function map_restore_zm_genesis(mapData)
  Archi.LogMessage("Restoring map data for Revelations");
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)

  restore_player_func = function (xuid, playerData)
    restore_player_score(xuid, playerData)
    restore_player_perks(xuid, playerData)
    restore_player_loadout(xuid, playerData)
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
    Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_XUID_" .. xuid .. "_" .. string.upper(flag), 1)
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
  local val = Engine.DvarInt(0, "ARCHIPELAGO_SAVE_DATA_XUID_" .. xuid .. "_" .. string.upper(flag))
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