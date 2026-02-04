require( "ui.uieditor.widgets.StartMenu.ApLocationsTab.StartMenu_ApLocations_ListItem" )
local LocationToID =  require( "Archipelago.Locations" )

-- local mapName = Engine.GetCurrentMap()

DataSources.StartMenu_ApLocations = ListHelper_SetupDataSource( "StartMenu_ApLocations", function( controller )
    local ApLocations = {}

	for location, code in pairs(LocationToID) do
		if code >= 2100 and code < 3000 then
			table.insert( ApLocations, {
				models = { name = location }
			})
		end
	end

    return ApLocations
end, true )

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
	self.itemList:setDataSource( "StartMenu_ApLocations" )
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