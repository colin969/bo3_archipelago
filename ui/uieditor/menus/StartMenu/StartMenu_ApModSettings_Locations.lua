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
            models = { tabName = "The Giant", tabWidget = "CoD.StartMenu_ApLocations_TheGiant",
			 	tabIcon = "" },
            properties = { tabId = "gameOptions" }
        } )

		table.insert( tabList, {
            models = { tabName = "Der Eisendrache", tabWidget = "CoD.StartMenu_ApLocations_Castle",
				tabIcon = "" },
            properties = { tabId = "gameOptions" }
        } )

		table.insert( tabList, {
            models = { tabName = "Zetsubou No Shima", tabWidget = "CoD.StartMenu_ApLocations_Island",
			 	tabIcon = "" },
            properties = { tabId = "gameOptions" }
        } )
    
        table.insert( tabList, {
            models = { tabName = "Gorod Krovi", tabWidget = "CoD.StartMenu_ApLocations_Stalingrad",
			 	tabIcon = "" },
            properties = { tabId = "gameOptions" }
        } )

		table.insert( tabList, {
            models = { tabName = "Revelations", tabWidget = "CoD.StartMenu_ApLocations_Genesis",
			 	tabIcon = "" },
            properties = { tabId = "gameOptions" }
        } )

		table.insert( tabList, {
            models = { tabName = "Kino der Toten", tabWidget = "CoD.StartMenu_ApLocations_KinoDerToten",
			 	tabIcon = "" },
            properties = { tabId = "gameOptions" }
        } )

		table.insert( tabList, {
            models = { tabName = "Wanted", tabWidget = "CoD.StartMenu_ApLocations_Wanted",
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

CoD.StartMenu_ApModSettings_Locations = InheritFrom( LUI.UIElement )
CoD.StartMenu_ApModSettings_Locations.new = function( menu, controller )
	local self = LUI.UIElement.new()

	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

	self:setUseStencil( false )
	self:setClass( CoD.StartMenu_ApModSettings_Locations )
	self.id = "StartMenu_ApModSettings_Locations"
	self.soundSet = "ChooseDecal"
	self:setLeftRight( true, false, 0, 1150 )
	self:setTopBottom( true, false, 0, 520 )
	self:makeFocusable()
	self.anyChildUsesUpdateState = true
	self.onlyChildrenFocusable = true

	self.TabFrame = LUI.UIFrame.new( menu, controller, 0, 0, false )
	self.TabFrame:setLeftRight( true, false, 80, 400 )
	self.TabFrame:setTopBottom( false, false, 0, 0 )
	self:addElement( self.TabFrame )

	self.TabList = CoD.StartMenu_TabList.new( menu, controller )
	self.TabList:setLeftRight( true, false, 40, 300)
	self.TabList:setTopBottom( true, false, 0, 0 )
	self.TabList.grid:setHorizontalCount( 1 )
	self.TabList.grid:setVerticalCount( 15 )
	self.TabList.grid:setDataSource( "ApModSettingsLocationsTabs" )
	self:addElement( self.TabList )

	self.TabFrame.id = "TabFrame"

	
	self:registerEventHandler( "gain_focus", function( element, event )
		if element.m_focusable and element.TabList:processEvent( event ) then
			return true
		else
			return LUI.UIElement.gainFocus( element, event )
		end
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function( element )
		element.TabFrame:close()
		element.TabList:close()
	end )

	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end