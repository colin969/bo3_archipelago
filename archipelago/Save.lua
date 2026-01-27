function map_save_zm_castle(mapData)
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

function map_restore_zm_castle(mapData)
  Archi.LogMessage("Saving map data for castle");
  restore_round_number(mapData)
  restore_power_on(mapData)
  restore_doors_and_debris(mapData)

  Archi.LogMessage("Saving player data for castle");
  restore_player_func = function (xuid, playerData)
    restore_player_score(xuid, playerData)
    restore_player_perks(xuid, playerData)
    restore_player_loadout(xuid, playerData)
  end

  restore_players(mapData, restore_player_func)
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
    playerData = {}
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

map_saves = {
  zm_castle = map_save_zm_castle
}

map_restores = {
  zm_castle = map_restore_zm_castle
}

return {
  map_saves = map_saves,
  map_restores = map_restores,
}