require( "ui.uieditor.widgets.StartMenu.ApLocationsTab.StartMenu_ApLocations" )
require( "ui.uieditor.widgets.StartMenu.TabWidgets.StartMenu_TabList" )

local PostLoadFunc = function( self, controller )
	self:registerEventHandler( "menu_opened", function()
		return true
	end )
	self.disableDarkenElement = true
	SetControllerModelValue( controller, "forceScoreboard", 0 )
	self.TabFrame:linkToElementModel( self.TabList.grid, "tabWidget", true, function( model )
		local modelValue = Engine.GetModelValue( model )
		if modelValue then
			self.TabFrame:changeFrameWidget( modelValue )
		end
	end )
end

DataSources.ApModSettingsLocationsTabs = ListHelper_SetupDataSource( "ApModSettingsLocationsTabs", function( controller )
	local tabList = {}

    if Engine.IsZombiesGame() then
        
        table.insert( tabList, {
            models = { tabIcon = CoD.buttonStrings.shoulderl },
            properties = { m_mouseDisabled = true }
        } )

		table.insert( tabList, {
            models = { tabName = "Shadows of Evil", tabWidget = "CoD.StartMenu_ApLocations_Zod", 
				tabIcon = "" },
            properties = { tabId = "gameOptions" }
        } )

		table.insert( tabList, {
            models = { tabName = "Der Eisendrache", tabWidget = "CoD.StartMenu_ApLocations_Castle",
				tabIcon = "" },
            properties = { tabId = "gameOptions" }
        } )
    
        table.insert( tabList, {
            models = { tabName = "Gorod Krovi", tabWidget = "CoD.StartMenu_ApLocations_Stalingrad",
			 	tabIcon = "" },
            properties = { tabId = "gameOptions" }
        } )
        
        table.insert( tabList, {
            models = { tabIcon = CoD.buttonStrings.shoulderr },
            properties = { m_mouseDisabled = true }
        } )
    end

	return tabList
end, true )

LUI.createMenu.StartMenu_ApModSettings_Locations = function( controller )
	local self = CoD.Menu.NewForUIEditor( "StartMenu_ApModSettings_Locations" )

	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

	self.soundSet = "ChooseDecal"
	self:setOwner( controller )
	self:setLeftRight( true, false, 0, 1280 )
	self:setTopBottom( true, false, 0, 720 )
	self:playSound( "menu_open", controller )
	self.buttonModel = Engine.CreateModel( Engine.GetModelForController( controller ), "StartMenu_ApModSettings_Locations.buttonPrompts" )
	self.anyChildUsesUpdateState = true

	self.Background = CoD.StartMenu_Background.new( self, controller )
	self.Background:setLeftRight( true, true, 0, 0 )
	self.Background:setTopBottom( true, true, 0, 0 )
	self.Background:setAlpha( 0.75 )
	self:addElement( self.Background )

	self.TabFrame = LUI.UIFrame.new( self, controller, 0, 0, false )
	self.TabFrame:setLeftRight( true, false, 80, 400 )
	self.TabFrame:setTopBottom( false, false, 0, 0 )
	self:addElement( self.TabFrame )

	self.TabList = CoD.StartMenu_TabList.new( self, controller )
	self.TabList:setLeftRight( true, false, 40, 300)
	self.TabList:setTopBottom( true, false, 0, 0 )
	self.TabList.grid:setHorizontalCount( 1 )
	self.TabList.grid:setVerticalCount( 15 )
	self.TabList.grid:setDataSource( "ApModSettingsLocationsTabs" )
	self:addElement( self.TabList )

	self:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, nil, function ( element, event, controller, menu )
	    GoBack( event, controller )
	    return true
	end, function ( element, menu, controller )
	    CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, "MENU_BACK" )
	    return true
	end, false )

	self:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_START, "M", function ( element, event, controller, menu )
	    GoBack( event, controller )
	    return true
	end, function ( element, menu, controller )
	    CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_START, "MENU_DISMISS_MENU" )
	    return true
	end, false )

	self:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, nil, function ( element, event, controller, menu )
	    PlaySoundSetSound( self, "list_action" )
	    return true
	end, function ( element, menu, controller )
	    CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
	    return true
	end, false )

	self:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "S", function ( element, event, controller, menu )
	    if IsInGame() and not IsLobbyNetworkModeLAN() and not IsDemoPlaying() then
	        OpenPopup( self, "Social_Main", controller, "", "" )
	        return true
	    end
	end, function ( element, menu, controller )
	    if IsInGame() and not IsLobbyNetworkModeLAN() and not IsDemoPlaying() then
	        CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "MENU_SOCIAL" )
	        return true
	    else
	        return false
	    end
	end, false )

	self:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_NONE, "ESCAPE", function ( element, event, controller, menu )
	    GoBack( event, controller )
	    return true
	end, function ( element, menu, controller )
	    CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_NONE, "" )
	    return true
	end, false, true )


	self.TabFrame.id = "TabFrame"

	self:processEvent( { name = "menu_loaded", controller = controller } )
	self:processEvent( { name = "update_state", menu = self } )

	if not self:restoreState() then
		self.TabFrame:processEvent( { name = "gain_focus", controller = controller } )
	end

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function( element )
		element.Background:close()
		element.TabFrame:close()
		element.TabList:close()
		Engine.UnsubscribeAndFreeModel( Engine.GetModel( Engine.GetModelForController( controller ), "StartMenu_ApModSettings_Locations.buttonPrompts" ) )
	end )

	if PostLoadFunc then
		PostLoadFunc( self, controller )
	end
	
	return self
end