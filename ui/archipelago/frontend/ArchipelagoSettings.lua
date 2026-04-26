require( "ui.uieditor.widgets.StartMenu.StartMenu_Background" )

require( "ui.uieditor.widgets.Lobby.Common.FE_ButtonPanelShaderContainer" )
require( "ui.uieditor.widgets.BackgroundFrames.GenericMenuFrame" )
require( "ui.uieditor.widgets.Groups.GroupsSubTitle" )
require( "ui.uieditor.widgets.Groups.GroupsInputButtonScroll" )
require( "ui.uieditor.Actions" )
require( "ui.archipelago.frontend.Archipelago_Checkbox" )


require("ui.util.T7OverchargedUtil")

EnableGlobals();

local settings_file = require("Archipelago.SettingsFile")
local savedServer
local savedSlot
local savedPassword
local savedUsePassword
local savedEnableDeathlink

local topMenu
local top

ApIsConnected = false

UpdateConnectionStatus = function(update)
	Engine.SetModelValue(Engine.GetModel(Engine.GetModel( Engine.GetGlobalModel(), "archipelago" ), "connectionValidated"),"Connection: "..update)
	ApIsConnected = false
end

SetApConnected = function()
	Engine.SetModelValue(Engine.GetModel(Engine.GetModel( Engine.GetGlobalModel(), "archipelago" ), "connectionValidated"),"Connection: Ready")
	ApIsConnected = true
end

local ConnectArchi = function(savedServer, savedSlot, savedPassword, savedUsePassword)
	if Archipelago == nil then 
		local modname = bo3_archipelago
		local filespath = [[.\mods\bo3_archipelago\]]
		local workshopid = nil
		local dllPath = filespath .. [[zone\]] or [[..\..\workshop\content\311210\]] .. workshopid .. "\\"
		local dll = "Archi-T7Overcharged.dll"

		SafeCall(function()
			EnableGlobals()
			local dllInit = require("package").loadlib(dllPath..dll, "init")
		
			--Check if the dll was properly loaded
			if not dllInit then
				Engine.ComError( Enum.errorCode.ERROR_UI, "Unable to initialize "..dll )
				return
			end
			dllInit()

		end)
	end

	password = savedPassword
	if savedUsePassword ~= 1 then
		password = ""
	end

	Archipelago.CheckConnection(savedServer, savedSlot, password, "zone\\")
	--
	
end

local PostLoadFunc = function ( menu, controller )
	local apModel = Engine.GetModel( Engine.GetGlobalModel(), "archipelago" )
	menu.serverInput.subscription = menu.serverInput:subscribeToModel( Engine.GetModel( apModel, "serverName" ), function ( model )
		local modelValue = Engine.GetModelValue( model )
		if modelValue then
			menu.serverInput.verticalScrollingTextBox.textBox:setText( modelValue )
			Engine.SetDvar( "ARCHIPELAGO_SERVER", modelValue)
		end
	end )
	menu.slotInput.subscription = menu.slotInput:subscribeToModel( Engine.GetModel( apModel, "slotName" ), function ( model )
		local modelValue = Engine.GetModelValue( model )
		if modelValue then
			menu.slotInput.verticalScrollingTextBox.textBox:setText( modelValue )
			Engine.SetDvar( "ARCHIPELAGO_SLOT", modelValue )
		end
	end )
	menu.passwordInput.subscription = menu.passwordInput:subscribeToModel( Engine.GetModel( apModel, "password" ), function ( model )
		local modelValue = Engine.GetModelValue( model )
		if modelValue then
			Engine.SetDvar( "ARCHIPELAGO_PASSWORD" , modelValue )
		end
	end )
	local usePasswordModel = Engine.GetModel( Engine.GetModel( Engine.GetGlobalModel(), "archipelago" ), "usePasswordCheckbox" )
	menu.usePasswordCheckbox.subscription = menu.usePasswordCheckbox:subscribeToModel( Engine.GetModel( usePasswordModel, "checked" ), function ( model )
		local modelValue = Engine.GetModelValue( model )
		if modelValue ~= nil then
			local apModel = Engine.GetModel( Engine.GetGlobalModel(), "archipelago" )
			Engine.SetModelValue( Engine.GetModel( apModel, "usePassword" ), modelValue )
			savedUsePassword = modelValue
			Engine.SetDvar( "ARCHIPELAGO_USE_PASSWORD", modelValue == 1 and "1" or "0" )
		end
	end )	
	local deathlinkModel = Engine.GetModel( Engine.GetModel( Engine.GetGlobalModel(), "archipelago" ), "deathlinkCheckbox" )
	menu.deathlinkCheckbox.subscription = menu.deathlinkCheckbox:subscribeToModel( Engine.GetModel( deathlinkModel, "checked" ), function ( model )
		local modelValue = Engine.GetModelValue( model )
		if modelValue ~= nil then
			local apModel = Engine.GetModel( Engine.GetGlobalModel(), "archipelago" )
			Engine.SetModelValue( Engine.GetModel( apModel, "enableDeathlink" ), modelValue )
			savedEnableDeathlink = modelValue
			Engine.SetDvar( "ARCHIPELAGO_ENABLE_DEATHLINK", modelValue == 1 and "1" or "0" )
		end
	end )
	menu.ConnectionText.subscription = menu.ConnectionText:subscribeToModel(Engine.GetModel( apModel, "connectionValidated" ), function ( model )
		local modelValue = Engine.GetModelValue( model )
		if modelValue then
			if modelValue == "" then
				menu.ConnectionText.weaponNameLabel:setText( "Connection: Not Validated" )
			else
				menu.ConnectionText.weaponNameLabel:setText( modelValue )
				Engine.SetDvar( "ARCHIPELAGO_CONNECTION_VALIDATED", modelValue )
			end
		end
	end )
end

local PreLoadFunc = function ( self, controller )
	local apModel = Engine.CreateModel( Engine.GetGlobalModel(), "archipelago" )
	Engine.SetModelValue( Engine.CreateModel( apModel, "serverName" ), savedServer)
	Engine.SetModelValue( Engine.CreateModel( apModel, "slotName" ), savedSlot)
	Engine.SetModelValue( Engine.CreateModel( apModel, "usePassword" ), savedUsePassword)
    Engine.SetModelValue( Engine.CreateModel( apModel, "enableDeathlink" ), savedEnableDeathlink)
	Engine.SetModelValue( Engine.CreateModel( apModel, "connectionValidated" ), Engine.DvarString(nil,"ARCHIPELAGO_CONNECTION_VALIDATED"))
end

APActiveField = 1

LUI.createMenu.ArchipelagoSettings = function ( controller )
    local self = CoD.Menu.NewForUIEditor( "ArchipelagoSettings" )
	savedServer, savedSlot, savedPassword, savedUsePassword, savedEnableDeathlink = settings_file.load_settings()
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
    self.soundSet = "default"
	self:setOwner( controller )
	self:setLeftRight( true, true, 0, 0 )
	self:setTopBottom( true, true, 0, 0 )
	self:playSound( "menu_open", controller )
	self.buttonModel = Engine.CreateModel( Engine.GetModelForController( controller ), "ArchipelagoSettings.buttonPrompts" )
	local Menu = self
	self.anyChildUsesUpdateState = true

    local StartMenuBackground0 = CoD.StartMenu_Background.new( Menu, controller )
	StartMenuBackground0:setLeftRight( true, true, 0, 0 )
	StartMenuBackground0:setTopBottom( true, true, 0, 0 )
	self:addElement( StartMenuBackground0 )
	self.StartMenuBackground0 = StartMenuBackground0

    local FEButtonPanelShaderContainer0 = CoD.FE_ButtonPanelShaderContainer.new( Menu, controller )
	FEButtonPanelShaderContainer0:setLeftRight( true, true, 0, 0 )
	FEButtonPanelShaderContainer0:setTopBottom( true, true, 0, 0 )
	FEButtonPanelShaderContainer0:setRGB( 0.31, 0.31, 0.31 )
	self:addElement( FEButtonPanelShaderContainer0 )
	self.FEButtonPanelShaderContainer0 = FEButtonPanelShaderContainer0
    
    local MenuFrame = CoD.GenericMenuFrame.new( Menu, controller )
	MenuFrame:setLeftRight( true, true, 0, 0 )
	MenuFrame:setTopBottom( true, true, 0, 0 )
	MenuFrame.titleLabel:setText( "ARCHIPELAGO SETTINGS" )
	MenuFrame.cac3dTitleIntermediary0.FE3dTitleContainer0.MenuTitle.TextBox1.Label0:setText( "ARCHIPELAGO SETTINGS" )
	self:addElement( MenuFrame )
	self.MenuFrame = MenuFrame

    local serverTitle = CoD.GroupsSubTitle.new( Menu, controller )
	serverTitle:setLeftRight( true, false, 93, 261 )
	serverTitle:setTopBottom( true, false, 112, 144 )
	serverTitle.weaponNameLabel:setText( "Server Name" )
	self:addElement( serverTitle )
	self.serverTitle = serverTitle

    local serverInput = CoD.GroupsInputButtonScroll.new( Menu, controller )
	serverInput:setLeftRight( true, false, 93, 478 )
	serverInput:setTopBottom( true, false, 150, 182 )
	serverInput.verticalScrollingTextBox.textBox:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
    serverInput:registerEventHandler( "gain_focus", function ( element, event )
		local f7_local0 = nil
		--
		EnableGlobals()
		APActiveField = 1
		--
		if element.gainFocus then
			f7_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f7_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, Menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		return f7_local0
	end )
    serverInput:registerEventHandler( "lose_focus", function ( element, event )
		local f8_local0 = nil
		if element.loseFocus then
			f8_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f8_local0 = element.super:loseFocus( event )
		end
		return f8_local0
	end )
	Menu:AddButtonCallbackFunction( serverInput, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f9_arg0, f9_arg1, f9_arg2, f9_arg3 )
		Engine.Exec(0, "ui_keyboard_new 17 \"Enter Server Name\" \"" .. savedServer .. "\" 128"); 
		return true
	end, function ( f10_arg0, f10_arg1, f10_arg2 )
		CoD.Menu.SetButtonLabel( f10_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	self:addElement( serverInput )
	self.serverInput = serverInput

    local slotTitle = CoD.GroupsSubTitle.new( Menu, controller )
	slotTitle:setLeftRight( true, false, 93, 261 )
	slotTitle:setTopBottom( true, false, 200, 232 )
	slotTitle.weaponNameLabel:setText("Slot Name")
	self:addElement( slotTitle )
	self.slotTitle = slotTitle
	
	local slotInput = CoD.GroupsInputButtonScroll.new( Menu, controller )
	slotInput:setLeftRight( true, false, 93, 478 )
	slotInput:setTopBottom( true, false, 238, 270 )
	slotInput.verticalScrollingTextBox.textBox:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
	slotInput:registerEventHandler( "gain_focus", function ( element, event )
		local f15_local0 = nil
		--
		EnableGlobals()
		APActiveField = 2
		--
		if element.gainFocus then
			f15_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f15_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, Menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		return f15_local0
	end )
	slotInput:registerEventHandler( "lose_focus", function ( element, event )
		local f16_local0 = nil
		if element.loseFocus then
			f16_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f16_local0 = element.super:loseFocus( event )
		end
		return f16_local0
	end )
	Menu:AddButtonCallbackFunction( slotInput, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f17_arg0, f17_arg1, f17_arg2, f17_arg3 )
		Engine.Exec(0, "ui_keyboard_new 17 \"Enter Slot Name\" \"" .. savedSlot .. "\" 128"); 
		return true
	end, function ( f18_arg0, f18_arg1, f18_arg2 )
		CoD.Menu.SetButtonLabel( f18_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	self:addElement( slotInput )
	self.slotInput = slotInput

	local passwordTitle = CoD.GroupsSubTitle.new( Menu, controller )
	passwordTitle:setLeftRight( true, false, 93, 261 )
	passwordTitle:setTopBottom( true, false, 288, 320 )
	passwordTitle.weaponNameLabel:setText("Password")
	self:addElement( passwordTitle )
	self.passwordTitle = passwordTitle

	local passwordInput = CoD.GroupsInputButtonScroll.new( Menu, controller )
	passwordInput:setLeftRight( true, false, 93, 478 )
	passwordInput:setTopBottom( true, false, 326, 358 )
	passwordInput.verticalScrollingTextBox.textBox:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
	passwordInput.verticalScrollingTextBox.textBox:setText("Click to Reveal")
	passwordInput:registerEventHandler( "gain_focus", function ( element, event )
		local f21_local0 = nil
		--
		EnableGlobals()
		APActiveField = 3
		--
		if element.gainFocus then
			f21_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f21_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, Menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		return f21_local0
	end )
	passwordInput:registerEventHandler( "lose_focus", function ( element, event )
		local f22_local0 = nil
		if element.loseFocus then
			f22_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f22_local0 = element.super:loseFocus( event )
		end
		return f22_local0
	end )
	Menu:AddButtonCallbackFunction( passwordInput, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f23_arg0, f23_arg1, f23_arg2, f23_arg3 )
		Engine.Exec(0, "ui_keyboard_new 17 \"Enter Password\" \"" .. savedPassword .. "\" 128"); 
		return true
	end, function ( f24_arg0, f24_arg1, f24_arg2 )
		CoD.Menu.SetButtonLabel( f24_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	self:addElement( passwordInput )
	self.passwordInput = passwordInput

	-- Use Password Checkbox
	local usePasswordCheckbox = CoD.Archipelago_CheckBox.new( Menu, controller )
	usePasswordCheckbox:setLeftRight( true, false, 93, 478 )
	usePasswordCheckbox:setTopBottom( true, false, 376, 410 )

	usePasswordCheckbox.checkboxAction = function(controller, element)
		local checkboxModel = element:getModel()
		local checkedModel = Engine.GetModel( checkboxModel, "checked" )
		local currentValue = Engine.GetModelValue( checkedModel )
		
		local newValue = currentValue == 1 and 0 or 1
		Engine.SetModelValue( checkedModel, newValue )
	end

	local checkboxModel = Engine.CreateModel( Engine.GetModel( Engine.GetGlobalModel(), "archipelago" ), "usePasswordCheckbox" )
	Engine.SetModelValue( Engine.CreateModel( checkboxModel, "label" ), "Use Password" )
	Engine.SetModelValue( Engine.CreateModel( checkboxModel, "checked" ), savedUsePassword )
	usePasswordCheckbox:setModel( checkboxModel, controller )
	self:addElement( usePasswordCheckbox )
	self.usePasswordCheckbox = usePasswordCheckbox

	-- Enable Deathlink Checkbox
	local deathlinkCheckbox = CoD.Archipelago_CheckBox.new( Menu, controller )
	deathlinkCheckbox:setLeftRight( true, false, 93, 478 )
	deathlinkCheckbox:setTopBottom( true, false, 420, 454 )
	deathlinkCheckbox.checkboxAction = function(controller, element)
		local checkboxModel = element:getModel()
		local checkedModel = Engine.GetModel( checkboxModel, "checked" )
		local currentValue = Engine.GetModelValue( checkedModel )
		
		local newValue = currentValue == 1 and 0 or 1
		Engine.SetModelValue( checkedModel, newValue )
	end
	
	local deathlinkModel = Engine.CreateModel( Engine.GetModel( Engine.GetGlobalModel(), "archipelago" ), "deathlinkCheckbox" )
	Engine.SetModelValue( Engine.CreateModel( deathlinkModel, "label" ), "Enable Deathlink" )
	Engine.SetModelValue( Engine.CreateModel( deathlinkModel, "checked" ), savedEnableDeathlink )
	deathlinkCheckbox:setModel( deathlinkModel, controller )
	self:addElement( deathlinkCheckbox )
	self.deathlinkCheckbox = deathlinkCheckbox

	--Connection Status Indicator
    local ConnectionText = CoD.GroupsSubTitle.new( Menu, controller )
    ConnectionText:setLeftRight( true, false, 593, 661 )
    ConnectionText:setTopBottom( true, false, 112, 144 )
    self:addElement(ConnectionText)
    self.ConnectionText = ConnectionText
	
    serverInput.navigation = {
		down = slotInput
	}
	slotInput.navigation = {
		up = serverInput,
		down = passwordInput
	}
	passwordInput.navigation = {
		up = slotInput,
		down = usePasswordCheckbox
	}
	usePasswordCheckbox.navigation = {
		up = passwordInput,
		down = deathlinkCheckbox
	}
	deathlinkCheckbox.navigation = {
		up = usePasswordCheckbox
	}

    CoD.Menu.AddNavigationHandler( Menu, self, controller )
	self:registerEventHandler( "ui_keyboard_input", function ( element, event )
		EnableGlobals()
		if event.type ~= 17 then return end
			local apModel = Engine.GetModel( Engine.GetGlobalModel(), "archipelago" )
		if APActiveField == 1 then
			Engine.SetModelValue( Engine.GetModel( apModel, "serverName" ), event.input )
			savedServer = event.input
		elseif APActiveField == 2 then
			Engine.SetModelValue( Engine.GetModel( apModel, "slotName" ), event.input )
			savedSlot = event.input
		elseif APActiveField == 3 then
			Engine.SetModelValue( Engine.GetModel( apModel, "password" ), event.input )
			savedPassword = event.input
		end
	end )
    Menu:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, nil, function ( f20_arg0, f20_arg1, f20_arg2, f20_arg3 )
		GoBack( self, f20_arg2 )
		return true
	end, function ( f21_arg0, f21_arg1, f21_arg2 )
		CoD.Menu.SetButtonLabel( f21_arg1, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, "MP_BACK" )
		return true
	end, false )

    Menu:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, nil, function ( f20_arg0, f20_arg1, f20_arg2, f20_arg3 )
		ConnectArchi(savedServer, savedSlot, savedPassword, savedUsePassword)
		return true
	end, function ( f21_arg0, f21_arg1, f21_arg2 )
		CoD.Menu.SetButtonLabel( f21_arg1, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "Connect" )
		return true
	end, false )

    MenuFrame:setModel( self.buttonModel, controller )
	serverInput.id = "serverInput"
	slotInput.id = "slotInput"
	passwordInput.id = "passwordInput"
	usePasswordCheckbox.id = "usePasswordCheckbox"
	deathlinkCheckbox.id = "deathlinkCheckbox"

	self:processEvent( {
		name = "menu_loaded",
		controller = controller
	} )
	self:processEvent( {
		name = "update_state",
		menu = Menu
	} )
	if not self:restoreState() then
		self.serverInput:processEvent( {
			name = "gain_focus",
			controller = controller
		} )
	end
    LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		settings_file.save_settings(savedServer, savedSlot, savedPassword, savedUsePassword, savedEnableDeathlink)
		element.StartMenuBackground0:close()
		element.FEButtonPanelShaderContainer0:close()
		element.MenuFrame:close()
		element.serverTitle:close()
		element.serverInput:close()
		element.slotTitle:close()
		element.slotInput:close()
		element.passwordTitle:close()
		element.passwordInput:close()
		element.usePasswordCheckbox:close()
		element.deathlinkCheckbox:close()
		element.ConnectionText:close()
		Engine.UnsubscribeAndFreeModel( Engine.GetModel( Engine.GetModelForController( controller ), "ArchipelagoSettings.buttonPrompts" ) )

	end )
	if PostLoadFunc then
		PostLoadFunc( self, controller )
	end
	
	return self
end
