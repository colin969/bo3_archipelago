require( "ui.uieditor.widgets.StartMenu.ApLocationsTab.StartMenu_ApLocations_ListItem" )
require( "ui.uieditor.widgets.StartMenu.ApLocationsTab.StartMenu_ApLocations_DataSources" )

CoD.StartMenu_ApLocations = InheritFrom( LUI.UIElement )
CoD.StartMenu_ApLocations.new = function( menu, controller )
	local self = LUI.UIElement.new()

	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

	self:setUseStencil( false )
	self:setClass( CoD.StartMenu_ApLocations )
	self.id = "StartMenu_ApLocations"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 1150 )
	self:setTopBottom( true, false, 0, 520 )
	self:makeFocusable()

	self.itemList = LUI.UIList.new( menu, controller, 2, 0, nil, true, false, 0, 0, false, false )
	self.itemList:makeFocusable()
	self.itemList:setLeftRight( true, true, 100, 100 )
	self.itemList:setTopBottom( true, false, 0, 0 )
	self.itemList:setWidgetType( CoD.StartMenu_ApLocations_ListItem )
	self.itemList:setHorizontalCount( 3 )
	self.itemList:setVerticalCount( 28 )
	menu:registerEventHandler( "menu_opened", function()
		self.itemList:updateDataSource()
        return true
    end )
	self:addElement( self.itemList )

	self.itemList.id = "ItemList"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function( element )
		element.itemList:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end

CoD.StartMenu_ApLocations_Zod = InheritFrom( CoD.StartMenu_ApLocations )
CoD.StartMenu_ApLocations_Zod.new = function( menu, controller )
	self = CoD.StartMenu_ApLocations.new( menu, controller )
	self.itemList:setDataSource( "StartMenu_ApLocations_Zod" )
	return self
end

CoD.StartMenu_ApLocations_Castle = InheritFrom( CoD.StartMenu_ApLocations )
CoD.StartMenu_ApLocations_Castle.new = function( menu, controller )
	self = CoD.StartMenu_ApLocations.new( menu, controller )
	self.itemList:setDataSource( "StartMenu_ApLocations_Castle" )
	return self
end

CoD.StartMenu_ApLocations_Island = InheritFrom( CoD.StartMenu_ApLocations )
CoD.StartMenu_ApLocations_Island.new = function( menu, controller )
	self = CoD.StartMenu_ApLocations.new( menu, controller )
	self.itemList:setDataSource( "StartMenu_ApLocations_Island" )
	return self
end

CoD.StartMenu_ApLocations_Stalingrad = InheritFrom( CoD.StartMenu_ApLocations )
CoD.StartMenu_ApLocations_Stalingrad.new = function( menu, controller )
	self = CoD.StartMenu_ApLocations.new( menu, controller )
	self.itemList:setDataSource( "StartMenu_ApLocations_Stalingrad" )
	return self
end

CoD.StartMenu_ApLocations_Genesis = InheritFrom( CoD.StartMenu_ApLocations )
CoD.StartMenu_ApLocations_Genesis.new = function( menu, controller )
	self = CoD.StartMenu_ApLocations.new( menu, controller )
	self.itemList:setDataSource( "StartMenu_ApLocations_Genesis" )
	return self
end