EnableGlobals();

require("ui.util.T7OverchargedUtil")
require("Archipelago.Utils")

local json = require("Archipelago.Json")

local save_system = require("Archipelago.Save")
local settings_file = require("Archipelago.SettingsFile")
local locations = require("Archipelago.Locations")

local notifyFunc = nil
local goalCondInitialized = false
local goalItems = {}
local goalItemsRequired = 0
local saveLoaded = false

--
ItemQueue = List.new()
LogQueue = List.new()
LocationQueue = List.new()
Archi = {}
Archi.Debug = true
Archi.CheckedLocations = {}
--

oneTimeItems = {
  ["50 Points"] = true,
  ["500 Points"] = true,
  ["Gift - Carpenter Powerup"] = true,
  ["Gift - Double Points Powerup"] = true,
  ["Gift - InstaKill Powerup"] = true,
  ["Gift - Fire Sale Powerup"] = true,
  ["Gift - Max Ammo Powerup"] = true,
  ["Gift - Nuke Powerup"] = true,
  ["Gift - Free Perk Powerup"] = true,
  ["Trap - Third Person Mode"] = true,
}
instanceItemState = {}
connectionItemState = {}

saveData = nil
seed = nil

Archi.SocketDisconnected = function ()
  ItemQueue = List.new()
  connectionItemState = {}
end

Archi.FromGSC = function (model)
  if IsParamModelEqualToString(model, "ap_init_dll") then
    --Send Log messages to GSC
    Archi.LogMessageLoop()

    InitializeArchipelago({
      modname  = "bo3_archipelago",
      filespath = [[.\mods\bo3_archipelago\]],
      workshopid = nil
    })
  end
  if IsParamModelEqualToString(model, "ap_init_goal_cond") then
    Archi.LogMessage("Setting goal cond")
    goalItemsRequired = Engine.DvarInt(-1,"ARCHIPELAGO_GOAL_ITEMS_REQUIRED")

    i = 0
    while true do
      local val = Engine.DvarString("","ARCHIPELAGO_GOAL_ITEM_" .. i)
      if val ~= "" then
        table.insert(goalItems, val)
      else
        break
      end
      i = i + 1
    end

    goalCondInitialized = true
    Archi.LogMessage("Goal cond initialized - Available: " .. #goalItems .. " - Required: " .. goalItemsRequired)
  end
  if IsParamModelEqualToString(model, "ap_debug_magicbox") then
    save_magicbox_list()
  end
  if IsParamModelEqualToString(model, "ap_init_state") then
    seed = Engine.DvarString("","ARCHIPELAGO_SEED")

    Archi.LoadData()

    --When we recieve an Item, give it to the GSC
    Archi.GiveItemsLoop()
    Archi.LocationNotifyLoop()

    Archi.LogMessage("Lua apclient ready")

    Engine.SetDvar( "ARCHIPELAGO_LOAD_READY", 1 )
  end
  if IsParamModelEqualToString(model, "ap_clear_data") then
    local mapName = Engine.DvarString(nil,"ARCHIPELAGO_CLEAR_DATA")
    if mapName ~= "NONE" then
      if saveData[mapName] then
        saveData[mapName] = nil
    
        -- We're done saving, let gsc know
        Engine.SetDvar( "ARCHIPELAGO_CLEAR_DATA", "NONE" )
      end

      local saveDataStr = json.encode(saveData, { indent = true })
      Archipelago.StoreSaveData(saveDataStr)
    end
  end
  if IsParamModelEqualToString(model, "ap_save_checkpoint_data") then
    local mapName = Engine.DvarString(nil,"ARCHIPELAGO_SAVE_DATA")
    if mapName ~= "NONE" then
      Archi.LogMessage("Saving checkpoint map data " .. mapName);
      local checkpointName = "_checkpoint_" .. mapName

      if saveData == nil then
        saveData = {}
      end

      local mapSave = save_system.map_saves[mapName]
      if mapSave then
        saveData[checkpointName] = {
          players = {},
          flags = {},
        }
        mapSave(saveData[checkpointName])
      end

      local saveDataStr = json.encode(saveData, { indent = true })
      Archipelago.StoreSaveData(saveDataStr)

      -- We're done saving, let gsc know
      Engine.SetDvar( "ARCHIPELAGO_SAVE_DATA", "NONE" )
    end
  end
  if IsParamModelEqualToString(model, "ap_save_data") then
    local mapName = Engine.DvarString(nil,"ARCHIPELAGO_SAVE_DATA")
    if mapName ~= "NONE" then
      if saveData == nil then
        saveData = {}
      end

      local mapSave = save_system.map_saves[mapName]
      if mapSave then
        saveData[mapName] = {
          players = {},
          flags = {},
        }
        mapSave(saveData[mapName])
      end

      local saveDataStr = json.encode(saveData, { indent = true })
      Archipelago.StoreSaveData(saveDataStr)

      -- We're done saving, let gsc know
      Engine.SetDvar( "ARCHIPELAGO_SAVE_DATA", "NONE" )
    end
  end
  if IsParamModelEqualToString(model, "ap_load_data") then
    local mapName = Engine.DvarString(nil,"ARCHIPELAGO_LOAD_DATA")
    if mapName ~= "NONE" then
      local checkpointName = "_checkpoint_" .. mapName
      local mapRestore = save_system.map_restores[mapName]
      if mapRestore then
        if saveData[mapName] then
          mapRestore(saveData[mapName])
        elseif saveData[checkpointName] then
          mapRestore(saveData[checkpointName])
        end
      else
        if not mapRestore then
          Archi.LogMessage("No restore func found for " .. mapName)
        end
      end

      -- saveData[mapName] = {
      --   players = {}
      -- } -- Clear map save data and save the file back
      -- local saveDataStr = json.encode(saveData)
      -- Archipelago.StoreSaveData(saveDataStr)
  
      -- Pass values over expected dvars
      Engine.SetDvar( "ARCHIPELAGO_LOAD_DATA", "NONE" )
      saveLoaded = true
    end
  end
  if IsParamModelEqualToString(model, "ap_notification") then
    --local notifyData = CoD.GetScriptNotifyData(model)
    --TODO add a type to this notification, for now its all loc checks
    local location = Engine.DvarString(nil,"ARCHIPELAGO_LOCATION_SEND")
    if location ~= "NONE" then
      locationID = locations.LocationToID[location]
      if locationID then
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

Archi.ItemGetEvent = function (name, sender, location)
  List.pushright(ItemQueue, {name = name, sender = sender, location = location})
end

Archi.LocationCheckedEvent = function (code)
  if code then
    List.pushright(LocationQueue,code)
    Archi.CheckedLocations[code] = true
  end
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

Archi.CheckGoalCond = function()
  if not goalItems or #goalItems == 0 then
    return
  end

  if goalItemsRequired < 0 then
    return
  end

  if not Archipelago then
    return
  end

  local goalItemsCount = 0

  for _, itemName in ipairs(goalItems) do
    local itemCount = saveData["universal"]["itemsReceived"][itemName]
    if itemCount and itemCount > 0 then
      goalItemsCount = goalItemsCount + 1
    end
  end
  
  if goalItemsCount >= goalItemsRequired then
    Archipelago.GoalReached()
  end
end

Archi.LocationNotifyLoop = function()
  local UIRootFull = LUI.roots.UIRootFull;
	UIRootFull.LocHUDRefreshTimer = LUI.UITimer.newElementTimer(100, false, function()
    if not List.isEmpty(LocationQueue) and goalCondInitialized and saveLoaded then
      local code = List.popleft(LocationQueue)
      if not saveData["universal"]["locationsFound"][code] then
        saveData["universal"]["locationsFound"][code] = true
        local name = locations.IDToLocation[code] or "Unknown Location"
        if notifyFunc then
          notifyFunc("SEND", { location = name })
        end
      end
    end
  end)
  UIRootFull:addElement(UIRootFull.LocHUDRefreshTimer);
end

Archi.GiveItemsLoop = function()
  local UIRootFull = LUI.roots.UIRootFull;
	UIRootFull.HUDRefreshTimer = LUI.UITimer.newElementTimer(100, false, function()
    local item = Engine.DvarString(nil,"ARCHIPELAGO_ITEM_GET")
    if (not List.isEmpty(ItemQueue)) and item == "NONE" and goalCondInitialized and saveLoaded then
      local networkItem = List.popleft(ItemQueue)
      local toSend = networkItem.name

      -- How many times awarded this current game
      instanceItemState[toSend] = instanceItemState[toSend] or 0
      -- How many times given on this AP connection (resets if disconnected and all items are reprocessed)
      connectionItemState[toSend] = connectionItemState[toSend] or 0
      -- How many times given on this AP seed
      saveData["universal"]["itemsReceived"][toSend] = saveData["universal"]["itemsReceived"][toSend] or 0

      -- Add item to connection counter
      connectionItemState[toSend] = connectionItemState[toSend] + 1

      local shouldAward = connectionItemState[toSend] > instanceItemState[toSend]
      local isNewItem = connectionItemState[toSend] > saveData["universal"]["itemsReceived"][toSend]

      -- Don't send one time items to GSC if not new
      if oneTimeItems[toSend] then
        if not isNewItem then
          shouldAward = false
        end
      end

      if connectionItemState[toSend] > instanceItemState[toSend] then
        instanceItemState[toSend] = connectionItemState[toSend]
      end
      if connectionItemState[toSend] > saveData["universal"]["itemsReceived"][toSend] then
        saveData["universal"]["itemsReceived"][toSend] = connectionItemState[toSend]
      end

      -- GSC award item
      if shouldAward then
        Engine.SetDvar( "ARCHIPELAGO_ITEM_GET", toSend )
      end

      -- UI notification
      if isNewItem and notifyFunc then
        notifyFunc("GET", networkItem)
      end

      -- Check goal cond
      Archi.CheckGoalCond()

      -- Let the one time items just save whenever we actually save
    end
	end);
	UIRootFull:addElement(UIRootFull.HUDRefreshTimer);
end

Archi.RegisterNotifyFunc = function(func)
  notifyFunc = func
end

Archi.UnregisterNotifyFunc = function()
  notifyFunc = nil
end

Archi.LogMessageLoop = function()
  local UIRootFull = LUI.roots.UIRootFull;
	UIRootFull.HUDRefreshTimer = LUI.UITimer.newElementTimer(400, false, function()
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

Archi.LoadData = function ()
  local saveDataStr = Archipelago.LoadSaveData()
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

  if not saveData["universal"] then
    saveData["universal"] = {}
  end

  if not saveData["universal"]["itemsReceived"] then
    saveData["universal"]["itemsReceived"] = {}
  end

  if not saveData["universal"]["locationsFound"] then
    saveData["universal"]["locationsFound"] = {}
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
end

function save_magicbox_list()
  local i = 0
  local content = "weapon,is_in_box,limited,quota\n"
  while true do
    local key = Engine.DvarString(nil, "ARCHIPELAGO_DEBUG_MAGICBOX_" .. i)
    local key_in_box = Engine.DvarString(nil, "ARCHIPELAGO_DEBUG_MAGICBOX_" .. i .. "_INSIDE")
    local key_limited = Engine.DvarString(nil, "ARCHIPELAGO_DEBUG_MAGICBOX_" .. i .. "_LIMITED")
    local key_quota = Engine.DvarString(nil, "ARCHIPELAGO_DEBUG_MAGICBOX_" .. i .. "_QUOTA") or "0"
    if not key or key == "" then
      break
    end
    content = content .. key .. "," .. key_in_box .. "," .. key_limited .. "," .. key_quota .. "\n"
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
