EnableGlobals();

require("ui.util.T7OverchargedUtil")
require("Archipelago.Utils")

local json = require("Archipelago.Json")

--
ItemQueue = List.new()
LogQueue = List.new()
Archi = {}
Archi.Debug = true
--

Archi.LocationToID = {}

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

saveData = nil
seed = nil

Archi.LocationToID["Repair Windows 5 Times"] = 9001

Archi.FromGSC = function (model)
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

      if not saveData[mapName] then
        saveData[mapName] = {
          players = {}
        }
      end

      -- Save round number
      local roundNumber = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_ROUND")
      if roundNumber and roundNumber > 1 then
        saveData[mapName].round_number = roundNumber
      end

      -- Save power state
      local powerOn = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_POWER_ON")
      if powerOn and powerOn > 0 then
        saveData[mapName].power_on = 1
      else
        saveData[mapName].power_on = 0
      end

      -- Save opened blockers
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

      saveData[mapName].doors_opened = doorsOpened
      saveData[mapName].debris_opened = debrisOpened
      
      -- Read semi-colon seperated list of player xuids to save
      local xuidList = Engine.DvarString(nil,"ARCHIPELAGO_SAVE_DATA_XUIDS")
      Archi.LogMessage("Saving player ids " .. xuidList);

      for xuid in string.gmatch(xuidList, "[^;]+") do
        local score = Engine.DvarInt(nil, "ARCHIPELAGO_SAVE_DATA_XUID_SCORE_" .. xuid)
        local weapons = {}
        local perks = {}

        -- Save Perks
        local i = 0
        while true do
          local perk = Engine.DvarString(nil, "ARCHIPELAGO_SAVE_DATA_XUID_PERK_" .. xuid .. "_" .. i)
          if not perk or perk == "" then
            break
          end
          table.insert(perks, perk)
          i = i + 1
        end

        -- Save Weapons
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
          table.insert(weapons, {
            weapon = weaponName,
            clip = weaponClip,
            lh_clip = weaponLhClip,
            stock = weaponStock,
            alt_clip = weaponAltClip,
            alt_stock = weaponAltStock,
          })
          i = i + 1
        end
        Archi.LogMessage("Saving player score - '" .. xuid .. "' - " .. score);
        saveData[mapName].players[xuid] = {
          score = score,
          weapons = weapons,
          perks = perks,
        }
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

      Archi.LogMessage("Current mapName: '" .. tostring(mapName) .. "'")
      Archi.LogMessage("Available maps in saveData:")
      for key, _ in pairs(saveData) do
        Archi.LogMessage("  - " .. key)
      end

      -- Load the json and set dvars
      Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_SEED", seed )

      if saveData[mapName] then
        local mapData = saveData[mapName]

        -- Load power state
        if mapData["power_on"] and mapData["power_on"] == 1 then
          Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_POWER_ON", 1)
        else
          Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_POWER_ON", 0)
        end

        -- Load doors and debris
        if mapData["doors_opened"] then
          local doorsOpened = mapData["doors_opened"]
          Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_OPENED_DOORS", table.concat(doorsOpened, ";"))
        end

        if mapData["debris_opened"] then
          local debrisOpened = mapData["debris_opened"]
          Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_OPENED_DEBRIS", table.concat(debrisOpened, ";"))
        end

        -- Load round number
        if mapData["round_number"] then
          Engine.SetDvar("ARCHIPELAGO_LOAD_DATA_ROUND", mapData["round_number"])
        end

        for xuid, playerData in pairs(mapData.players) do
          Archi.LogMessage("Setting Player Dvar " .. "ARCHIPELAGO_LOAD_DATA_XUID_READY_" .. xuid)
          Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_READY_" .. xuid, "true" )
          Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_SCORE_" .. xuid, playerData.score )
          
          -- Load Perks
          if playerData["perks"] then
            local i = 0
            for _, perk in ipairs(playerData["perks"]) do
              Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA_XUID_PERK_" .. xuid .. "_" .. i, perk )
              i = i + 1
            end
          end
          
          -- Load Weapons
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
  
  if Archipelago then
    local server = Engine.DvarString(nil,"ARCHIPELAGO_SERVER")
    if server == "" then
      server = "localhost"
    end
    local port = Engine.DvarString(nil,"ARCHIPELAGO_PORT")
    if port == "" then
      port = "38281"
    end
    local slot = Engine.DvarString(nil,"ARCHIPELAGO_SLOT")
    if slot == "" then
      slot = "Player"
    end
    --TODO: error out if any of these are null

    --TODO: change the \zone (base path) when its workshop
    Archipelago.Connect(server..":"..port,slot,"zone\\")
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