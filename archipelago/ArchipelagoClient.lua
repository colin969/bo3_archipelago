EnableGlobals();

require("ui.util.T7OverchargedUtil")
require("Archipelago.Utils")

local json = require("Archipelago.Json")

local save_system = require("Archipelago.Save")
local settings_file = require("Archipelago.SettingsFile")

--
ItemQueue = List.new()
LogQueue = List.new()
Archi = {}
Archi.Debug = true
--

Archi.LocationToID = {}

for i = 1, 99 do
  local roundName = string.format("(Shadows of Evil) Round %02d", i)
  Archi.LocationToID[roundName] = i + 3000
end

for i = 1, 99 do
  local roundName = string.format("(The Giant) Round %02d", i)
  Archi.LocationToID[roundName] = i + 1000
end

for i = 1, 99 do
  local roundName = string.format("(Castle) Round %02d", i)
  Archi.LocationToID[roundName] = i + 2000
end

Archi.LocationToID["(Castle) Shield Part Pickup - Dolly"] = 2200
Archi.LocationToID["(Castle) Shield Part Pickup - Door"] = 2201
Archi.LocationToID["(Castle) Shield Part Pickup - Clamp"] = 2202

Archi.LocationToID["(Castle) Ragnarok DG-4 Part Pickup - Body"] = 2210
Archi.LocationToID["(Castle) Ragnarok DG-4 Part Pickup - Guards"] = 2211
Archi.LocationToID["(Castle) Ragnarok DG-4 Part Pickup - Handle"] = 2212

Archi.LocationToID["(Castle) All Spare Change Collected"] = 2300
Archi.LocationToID["(Castle) Feed the Dragonheads"] = 2301
Archi.LocationToID["(Castle) Turn on all Landing Pads"] = 2302

Archi.LocationToID["(Castle) Music EE - Dead Again"] = 2400
Archi.LocationToID["(Castle) Music EE - Requiem"] = 2400

Archi.LocationToID["(Castle) Storm Bow - Take Broken Arrow"] = 2500
Archi.LocationToID["(Castle) Storm Bow - Light the Beacons"] = 2501
Archi.LocationToID["(Castle) Storm Bow - Wallrun Switches"] = 2502
Archi.LocationToID["(Castle) Storm Bow - Charge the Batteries"] = 2503
Archi.LocationToID["(Castle) Storm Bow - Charge the Beacons"] = 2504
Archi.LocationToID["(Castle) Storm Bow - Repair the Arrow"] = 2505
Archi.LocationToID["(Castle) Storm Bow - Forge the Bow"] = 2506

Archi.LocationToID["(Castle) Wolf Howl - Painting Puzzle"] = 2510
Archi.LocationToID["(Castle) Wolf Howl - Take Broken Arrow"] = 2511
Archi.LocationToID["(Castle) Wolf Howl - Collect the Skull"] = 2512
Archi.LocationToID["(Castle) Wolf Howl - Follow the Wolf"] = 2513
Archi.LocationToID["(Castle) Wolf Howl - Repair the Arrow"] = 2514
Archi.LocationToID["(Castle) Wolf Howl - Forge the Bow"] = 2515

Archi.LocationToID["(Castle) Rune Prison - Take the Arrow"] = 2520
Archi.LocationToID["(Castle) Rune Prison - Shoot the Orb"] = 2521
Archi.LocationToID["(Castle) Rune Prison - Charge the Runic Circles"] = 2522
Archi.LocationToID["(Castle) Rune Prison - Magma Ball Golf"] = 2523
Archi.LocationToID["(Castle) Rune Prison - Repair the Arrow"] = 2524
Archi.LocationToID["(Castle) Rune Prison - Forge the Bow"] = 2525

Archi.LocationToID["(Castle) Demon Gate - Take the Arrow"] = 2530
Archi.LocationToID["(Castle) Demon Gate - Ritual Sacrifice on the Seal"] = 2531
Archi.LocationToID["(Castle) Demon Gate - Collect the Skulls"] = 2532
Archi.LocationToID["(Castle) Demon Gate - Sacrifice Crawlers"] = 2533
Archi.LocationToID["(Castle) Demon Gate - Solve the Rune Puzzle"] = 2534
Archi.LocationToID["(Castle) Demon Gate - Repair the Arrow"] = 2535
Archi.LocationToID["(Castle) Demon Gate - Forge the Bow"] = 2536

Archi.LocationToID["(Castle) Main Easter Egg - Activate Time Travel Teleporter"] = 2600
Archi.LocationToID["(Castle) Main Easter Egg - Unlock the Safe"] = 2601
Archi.LocationToID["(Castle) Main Easter Egg - Recover the Rocket"] = 2602
Archi.LocationToID["(Castle) Main Easter Egg - Open the MPD"] = 2603
Archi.LocationToID["(Castle) Main Easter Egg - Win the Boss Fight"] = 2604
Archi.LocationToID["(Castle) Main Easter Egg - Blow up the Moon"] = 2605
Archi.LocationToID["(Castle) Main Easter Egg - Victory"] = 2606

Archi.LocationToID["(Shadows of Evil) Main Quest - Magician's Ritual"] = 3100
Archi.LocationToID["(Shadows of Evil) Main Quest - Boxer's Ritual"] = 3101
Archi.LocationToID["(Shadows of Evil) Main Quest - Detectives's Ritual"] = 3102
Archi.LocationToID["(Shadows of Evil) Main Quest - Femme Fatale's Ritual"] = 3103
Archi.LocationToID["(Shadows of Evil) Main Quest - Open the Portal"] = 3104

Archi.LocationToID["(Shadows of Evil) Apothicon Sword - Enter the Code"] = 3110
Archi.LocationToID["(Shadows of Evil) Apothicon Sword - Collect your Sword"] = 3111
Archi.LocationToID["(Shadows of Evil) Apothicon Sword - Collect your upgraded Sword"] = 3112

Archi.LocationToID["(Shadows of Evil) Main Easter Egg - Find Nero's Book"] = 3200
Archi.LocationToID["(Shadows of Evil) Main Easter Egg - Defeat the Shadowman"] = 3201
Archi.LocationToID["(Shadows of Evil) Main Easter Egg - Defeat the Giant Space Squid"] = 3202
Archi.LocationToID["(Shadows of Evil) Main Easter Egg - Victory"] = 3203

Archi.LocationToID["(Shadows of Evil) Apothicon Servant Part Pickup - Margwa Heart"] = 3300
Archi.LocationToID["(Shadows of Evil) Apothicon Servant Part Pickup - Margwa Tentacle"] = 3301
Archi.LocationToID["(Shadows of Evil) Apothicon Servant Part Pickup - Xenomatter"] = 3302

Archi.LocationToID["(Shadows of Evil) Civil Protector Part Pickup - Waterfront Fuse"] = 3310
Archi.LocationToID["(Shadows of Evil) Civil Protector Part Pickup - Canals Fuse"] = 3311
Archi.LocationToID["(Shadows of Evil) Civil Protector Part Pickup - Footlight Fuse"] = 3312

Archi.LocationToID["(Shadows of Evil) All Spare Change Collected"] = 3500
Archi.LocationToID["(Shadows of Evil) Laundry Ticket"] = 3501

saveData = nil
seed = nil

Archi.LocationToID["Repair Windows 5 Times"] = 9001

Archi.FromGSC = function (model)
  if IsParamModelEqualToString(model, "ap_debug_magicbox") then
    save_magicbox_list()
  end
  if IsParamModelEqualToString(model, "ap_clear_data") then
    local mapName = Engine.DvarString(nil,"ARCHIPELAGO_CLEAR_DATA")
    if mapName ~= "NONE" then
      if saveData[mapName] then
        saveData[mapName] = {
          players = {}
        }
        local saveDataStr = json.encode(saveData)
        Archipelago.StoreSaveData(saveDataStr)
    
        -- We're done saving, let gsc know
        Engine.SetDvar( "ARCHIPELAGO_CLEAR_DATA", "NONE" )
      end
    end

  end
  if IsParamModelEqualToString(model, "ap_save_data") then
    local mapName = Engine.DvarString(nil,"ARCHIPELAGO_SAVE_DATA")
    if mapName ~= "NONE" then
      Archi.LogMessage("Saving map data " .. mapName);

      if saveData == nil then
        saveData = {}
      end

      local mapSave = save_system.map_saves[mapName]
      if mapSave then
        if not saveData[mapName] then
          saveData[mapName] = {
            players = {}
          }
        end
        mapSave(saveData[mapName])
      end

      local saveDataStr = json.encode(saveData)
      Archipelago.StoreSaveData(saveDataStr)

      -- We're done saving, let gsc know
      Engine.SetDvar( "ARCHIPELAGO_SAVE_DATA", "NONE" )
    end
  end
  if IsParamModelEqualToString(model, "ap_load_data") then
    local mapName = Engine.DvarString(nil,"ARCHIPELAGO_LOAD_DATA")
    if mapName ~= "NONE" then
      -- Get data from AP client
      if saveData == nil then
        seed = Archipelago.GetSeed()
        local saveDataStr = Archipelago.LoadSaveData()
        Archi.LogMessage("Data size: " .. string.len(saveDataStr))
        if saveDataStr and saveDataStr ~= "" then
          local obj, pos, err = json.decode(saveDataStr, 1, nil)
          if err then
            Archi.LogMessage("Failed to decode JSON")
            saveData = {}
          else
            Archi.LogMessage("Loaded save data successfully")
            saveData = obj
          end
        else
          saveData = {}
        end
      end

      -- Give the gsc the seed if they don't already have it
      Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_SEED", seed )

      local mapRestore = save_system.map_restores[mapName]
      if mapRestore and saveData[mapName] then
        mapRestore(saveData[mapName])
      else
        if not mapRestore then
          Archi.LogMessage("No restore func found for " .. mapName)
        else
          Archi.LogMessage("No save data found for " .. mapName)
        end
      end

      -- saveData[mapName] = {
      --   players = {}
      -- } -- Clear map save data and save the file back
      -- local saveDataStr = json.encode(saveData)
      -- Archipelago.StoreSaveData(saveDataStr)
  
      -- Pass values over expected dvars
      Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA", "NONE" )
    end
  end
  if IsParamModelEqualToString(model, "ap_notification") then
    --local notifyData = CoD.GetScriptNotifyData(model)
    --TODO add a type to this notification, for now its all loc checks
    local location = Engine.DvarString(nil,"ARCHIPELAGO_LOCATION_SEND")
    if location ~= "NONE" then
      locationID = Archi.LocationToID[location]
      if locationID then
        Archi.LogMessage("Sending Location ID " .. locationID)
        Archipelago.CheckLocation(locationID)
      else
        Archi.LogMessage("Failed to convert location name to id")
      end
      Engine.SetDvar( "ARCHIPELAGO_LOCATION_SEND", "NONE" )
    end

    local message = Engine.DvarString(nil,"ARCHIPELAGO_SAY_SEND")
    if message ~= "NONE" then
      Archipelago.Say(message)
      Engine.SetDvar( "ARCHIPELAGO_SAY_SEND", "NONE" )
    end
  end
end

Archi.ItemGetEvent = function (name)
  List.pushright(ItemQueue,name)
end

Archi.LogMessage = function (message)
  if message then
    List.pushright(LogQueue,message)
  end
end

Archi.LogDebugMessage = function (message)
  if Archi.Debug and message then
    List.pushright(LogQueue,"Debug: "..message)
  end
end


Archi.GiveItemsLoop = function()
  local UIRootFull = LUI.roots.UIRootFull;
	UIRootFull.HUDRefreshTimer = LUI.UITimer.newElementTimer(1000, false, function()
    local item = Engine.DvarString(nil,"ARCHIPELAGO_ITEM_GET")
    if (not List.isEmpty(ItemQueue)) and (item == "NONE") then --if we are free to give an item, and there is one to give
      local toSend = List.popleft(ItemQueue)
      Engine.SetDvar( "ARCHIPELAGO_ITEM_GET", toSend )
    end
	end);
	UIRootFull:addElement(UIRootFull.HUDRefreshTimer);
end


Archi.LogMessageLoop = function()
  local UIRootFull = LUI.roots.UIRootFull;
	UIRootFull.HUDRefreshTimer = LUI.UITimer.newElementTimer(1000, false, function()
    local item = Engine.DvarString(nil,"ARCHIPELAGO_LOG_MESSAGE")
    if (not List.isEmpty(LogQueue)) and (item == "NONE") then --if we are free to give an item, and there is one to give
      local toSend = List.popleft(LogQueue)
      Engine.SetDvar( "ARCHIPELAGO_LOG_MESSAGE", toSend )
    end
	end);
	UIRootFull:addElement(UIRootFull.HUDRefreshTimer);
end

Archi.KeepConnected = function ()
  local server, slot = settings_file.load_settings();
  if Archipelago then
    --TODO: change the \zone (base path) when its workshop
    Archipelago.Connect(server, slot, "zone\\")
    --TODO: only do this on an actual connect
    Engine.SetDvar( "ARCHIPELAGO_CONNECTED", "TRUE" )
  end
end


function InitializeArchipelago(options)
    if Archipelago then 
      return false 
    end

    --Load DLL?
    local dllPath = options.filespath .. [[zone\]] or [[..\..\workshop\content\311210\]] .. options.workshopid .. "\\"
    local dll = "Archi-T7Overcharged.dll"

    SafeCall(function()
        EnableGlobals()
        local dllInit = require("package").loadlib(dllPath..dll, "init")
  
        --Check if the dll was properly loaded
        if not dllInit then
          Engine.ComError( Enum.errorCode.ERROR_UI, "Unable to initialize "..dll )
          return
        end
        -- Execute the dll
        dllInit()
    
      end)

      --Make sure we are connected to Archipelago
      --Turning off for now
      Archi.KeepConnected()

      --Start Polling
      local UIRootFull = LUI.roots.UIRootFull;
			UIRootFull.HUDRefreshTimer = LUI.UITimer.newElementTimer(1000, false, function()
        Archipelago.Poll();
      end);
      UIRootFull:addElement(UIRootFull.HUDRefreshTimer);
      --

      --When we recieve an Item, give it to the GSC
      Archi.GiveItemsLoop()

      --Send Log messages to GSC
      Archi.LogMessageLoop()

end

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

function save_magicbox_list()
  local i = 0
  local content = "weapon,is_in_box\n"
  while true do
    local key = Engine.DvarString(nil, "ARCHIPELAGO_DEBUG_MAGICBOX_" .. i)
    local key_in_box = Engine.DvarString(nil, "ARCHIPELAGO_DEBUG_MAGICBOX_" .. i .. "_INSIDE")
    if not key or key == "" then
      break
    end
    content = content .. key .. "," .. key_in_box .. "\n"
    i = i + 1
  end
  local f = require("io").open("mods/bo3_archipelago/magicbox.csv", "w+")
  if not f then
    Archi.LogMessage("Failed to open file: " .. (err or "unknown error"))
    return
  end
  f:write(content)
  f:close()
end