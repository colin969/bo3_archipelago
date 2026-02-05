EnableGlobals();

require("ui.util.T7OverchargedUtil")
require("Archipelago.Utils")

local json = require("Archipelago.Json")

local save_system = require("Archipelago.Save")
local settings_file = require("Archipelago.SettingsFile")
local locations = require("Archipelago.Locations")

--
ItemQueue = List.new()
LogQueue = List.new()
Archi = {}
Archi.Debug = true
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

    Archi.LogMessage("Initializing DLL...")

    InitializeArchipelago({
      modname  = "bo3_archipelago",
      filespath = [[.\mods\bo3_archipelago\]],
      workshopid = nil
    })
  end
  if IsParamModelEqualToString(model, "ap_debug_magicbox") then
    save_magicbox_list()
  end
  if IsParamModelEqualToString(model, "ap_init_state") then
    seed = Engine.DvarString("","ARCHIPELAGO_SEED")
    Archi.LogMessage("Seed: " .. seed)

    Archi.LoadData()

    --When we recieve an Item, give it to the GSC
    Archi.GiveItemsLoop()

    Archi.LogMessage("LUA side ready")

    Engine.SetDvar( "ARCHIPELAGO_LOAD_READY", 1 )
  end
  if IsParamModelEqualToString(model, "ap_clear_data") then
    local mapName = Engine.DvarString(nil,"ARCHIPELAGO_CLEAR_DATA")
    if mapName ~= "NONE" then
      if saveData[mapName] then
        saveData[mapName] = {
          players = {}
        }
        local saveDataStr = json.encode(saveData, { indent = true })
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

      local saveDataStr = json.encode(saveData, { indent = true })
      Archipelago.StoreSaveData(saveDataStr)

      -- We're done saving, let gsc know
      Engine.SetDvar( "ARCHIPELAGO_SAVE_DATA", "NONE" )
    end
  end
  if IsParamModelEqualToString(model, "ap_load_data") then
    local mapName = Engine.DvarString(nil,"ARCHIPELAGO_LOAD_DATA")
    if mapName ~= "NONE" then
      local mapRestore = save_system.map_restores[mapName]
      if mapRestore and saveData[mapName] then
        mapRestore(saveData[mapName])
      else
        if not mapRestore then
          Archi.LogMessage("No restore func found for " .. mapName)
        else
          Archi.LogMessage("Restore function found for " .. mapName)
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
      locationID = locations.LocationToID[location]
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

Archi.LocationCheckedEvent = function (code)
  
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
	UIRootFull.HUDRefreshTimer = LUI.UITimer.newElementTimer(500, false, function()
    local item = Engine.DvarString(nil,"ARCHIPELAGO_ITEM_GET")
    if (not List.isEmpty(ItemQueue)) and (item == "NONE") then --if we are free to give an item, and there is one to give
      local toSend = List.popleft(ItemQueue)

      -- How many times awarded this map
      instanceItemState[toSend] = instanceItemState[toSend] or 0
      -- How many times given on this AP connection (resets if disconnected)
      connectionItemState[toSend] = connectionItemState[toSend] or 0

      -- Add item to connection counter
      connectionItemState[toSend] = connectionItemState[toSend] + 1

      if instanceItemState[toSend] < connectionItemState[toSend] then
        -- Instance is lagging behind connection, catch up
        instanceItemState[toSend] = connectionItemState[toSend]

        -- One time use items need to check the saved data, not just the instance state
        if oneTimeItems[toSend] then
          local spentItems = saveData["universal"]["oneTimeItems"][toSend] or 0
          if instanceItemState[toSend] > spentItems then
            -- Save state is behind instance state, award powerup to catch up
            saveData["universal"]["oneTimeItems"][toSend] = instanceItemState[toSend]
            Engine.SetDvar( "ARCHIPELAGO_ITEM_GET", toSend )
            -- Store updated save data
            local saveDataStr = json.encode(saveData, { indent = true })
            Archipelago.StoreSaveData(saveDataStr)
          end
        else
          -- Regular item, award
          Engine.SetDvar( "ARCHIPELAGO_ITEM_GET", toSend )
        end
      end
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

Archi.LoadData = function ()
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

  if not saveData["universal"] then
    saveData["universal"] = {}
  end
  if not saveData["universal"]["oneTimeItems"] then
    saveData["universal"]["oneTimeItems"] = {}
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
