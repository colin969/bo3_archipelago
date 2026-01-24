EnableGlobals();

require("ui.util.T7OverchargedUtil")
require("Archipelago.Utils")

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


Archi.LocationToID["Repair Windows 5 Times"] = 9001

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