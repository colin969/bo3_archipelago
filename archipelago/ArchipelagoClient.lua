EnableGlobals();

require("ui.util.T7OverchargedUtil")
require("Archipelago.Utils")

--
ItemQueue = List.new()
LogQueue = List.new()
Archi = {}
Archi.Debug = true
--

Archi.LocationToID = {
  -- Round locations (IDs 1-99)
  ["(The Giant) Round 01"] = 1,
  ["(The Giant) Round 02"] = 2,
  ["(The Giant) Round 03"] = 3,
  ["(The Giant) Round 04"] = 4,
  ["(The Giant) Round 05"] = 5,
  ["(The Giant) Round 06"] = 6,
  ["(The Giant) Round 07"] = 7,
  ["(The Giant) Round 08"] = 8,
  ["(The Giant) Round 09"] = 9,
  ["(The Giant) Round 10"] = 10,
  ["(The Giant) Round 11"] = 11,
  ["(The Giant) Round 12"] = 12,
  ["(The Giant) Round 13"] = 13,
  ["(The Giant) Round 14"] = 14,
  ["(The Giant) Round 15"] = 15,
  ["(The Giant) Round 16"] = 16,
  ["(The Giant) Round 17"] = 17,
  ["(The Giant) Round 18"] = 18,
  ["(The Giant) Round 19"] = 19,
  ["(The Giant) Round 20"] = 20,
  ["(The Giant) Round 21"] = 21,
  ["(The Giant) Round 22"] = 22,
  ["(The Giant) Round 23"] = 23,
  ["(The Giant) Round 24"] = 24,
  ["(The Giant) Round 25"] = 25,
  ["(The Giant) Round 26"] = 26,
  ["(The Giant) Round 27"] = 27,
  ["(The Giant) Round 28"] = 28,
  ["(The Giant) Round 29"] = 29,
  ["(The Giant) Round 30"] = 30,
  ["(The Giant) Round 31"] = 31,
  ["(The Giant) Round 32"] = 32,
  ["(The Giant) Round 33"] = 33,
  ["(The Giant) Round 34"] = 34,
  ["(The Giant) Round 35"] = 35,
  ["(The Giant) Round 36"] = 36,
  ["(The Giant) Round 37"] = 37,
  ["(The Giant) Round 38"] = 38,
  ["(The Giant) Round 39"] = 39,
  ["(The Giant) Round 40"] = 40,
  ["(The Giant) Round 41"] = 41,
  ["(The Giant) Round 42"] = 42,
  ["(The Giant) Round 43"] = 43,
  ["(The Giant) Round 44"] = 44,
  ["(The Giant) Round 45"] = 45,
  ["(The Giant) Round 46"] = 46,
  ["(The Giant) Round 47"] = 47,
  ["(The Giant) Round 48"] = 48,
  ["(The Giant) Round 49"] = 49,
  ["(The Giant) Round 50"] = 50,
  ["(The Giant) Round 51"] = 51,
  ["(The Giant) Round 52"] = 52,
  ["(The Giant) Round 53"] = 53,
  ["(The Giant) Round 54"] = 54,
  ["(The Giant) Round 55"] = 55,
  ["(The Giant) Round 56"] = 56,
  ["(The Giant) Round 57"] = 57,
  ["(The Giant) Round 58"] = 58,
  ["(The Giant) Round 59"] = 59,
  ["(The Giant) Round 60"] = 60,
  ["(The Giant) Round 61"] = 61,
  ["(The Giant) Round 62"] = 62,
  ["(The Giant) Round 63"] = 63,
  ["(The Giant) Round 64"] = 64,
  ["(The Giant) Round 65"] = 65,
  ["(The Giant) Round 66"] = 66,
  ["(The Giant) Round 67"] = 67,
  ["(The Giant) Round 68"] = 68,
  ["(The Giant) Round 69"] = 69,
  ["(The Giant) Round 70"] = 70,
  ["(The Giant) Round 71"] = 71,
  ["(The Giant) Round 72"] = 72,
  ["(The Giant) Round 73"] = 73,
  ["(The Giant) Round 74"] = 74,
  ["(The Giant) Round 75"] = 75,
  ["(The Giant) Round 76"] = 76,
  ["(The Giant) Round 77"] = 77,
  ["(The Giant) Round 78"] = 78,
  ["(The Giant) Round 79"] = 79,
  ["(The Giant) Round 80"] = 80,
  ["(The Giant) Round 81"] = 81,
  ["(The Giant) Round 82"] = 82,
  ["(The Giant) Round 83"] = 83,
  ["(The Giant) Round 84"] = 84,
  ["(The Giant) Round 85"] = 85,
  ["(The Giant) Round 86"] = 86,
  ["(The Giant) Round 87"] = 87,
  ["(The Giant) Round 88"] = 88,
  ["(The Giant) Round 89"] = 89,
  ["(The Giant) Round 90"] = 90,
  ["(The Giant) Round 91"] = 91,
  ["(The Giant) Round 92"] = 92,
  ["(The Giant) Round 93"] = 93,
  ["(The Giant) Round 94"] = 94,
  ["(The Giant) Round 95"] = 95,
  ["(The Giant) Round 96"] = 96,
  ["(The Giant) Round 97"] = 97,
  ["(The Giant) Round 98"] = 98,
  ["(The Giant) Round 99"] = 99,
  
  -- Misc location
  ["Repair Windows 5 Times"] = 9001
}

Archi.FromGSC = function (model)
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