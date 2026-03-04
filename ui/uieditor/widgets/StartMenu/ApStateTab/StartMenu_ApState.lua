DataSources.StartMenu_ApState = ListHelper_SetupDataSource( "StartMenu_ApState", function( controller )
    local rows = {}

    -- Get set of strings to display from the gsc
    i = 0
    while true do
        local val = Engine.DvarString(nil, "ARCHIPELAGO_MONITOR_" .. i)
        if val ~= "" then
            if string.sub(val, -1) == "1" then
                val = "^2" .. val
            end
            table.insert( rows, {
                models = { item = val }
            })    
        else
            break
        end
        i = i + 1
    end

    return rows
end, true )

CoD.StartMenu_ApState_Item = InheritFrom( LUI.UIElement )
CoD.StartMenu_ApState_Item.new = function( menu, controller )
	local self = LUI.UIElement.new()

	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

	self:setUseStencil( false )
	self:setClass( CoD.StartMenu_ApState_Item )
	self.id = "StartMenu_ApState_Item"
	self.soundSet = "default"
	self:setLeftRight( true, false, 10, 350 )
	self:setTopBottom( true, false, 0, 30 )
	self:makeFocusable()
	self:setHandleMouse( true )

	self.ItemName = LUI.UIText.new()
	self.ItemName:setLeftRight( true, false, 20, 320 )
	self.ItemName:setTopBottom( false, false, 5, 25 )
	self.ItemName:setTTF( "fonts/default.TTF" )
	self.ItemName:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
	self.ItemName:linkToElementModel( self, "item", true, function( model )
		local item = Engine.GetModelValue( model )
		if item then
			self.ItemName:setText( item )
		end
	end )
	self:addElement( self.ItemName )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function( element )
		element.ItemName:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end

CoD.StartMenu_ApState = InheritFrom( LUI.UIElement )
CoD.StartMenu_ApState.new = function ( menu, controller )
    local self = LUI.UIElement.new()

    if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

    self:setUseStencil( false )
	self:setClass( CoD.StartMenu_ApState )
	self.id = "StartMenu_ApState"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 1150 )
	self:setTopBottom( true, false, 0, 520 )
	self:makeFocusable()
	self.onlyChildrenFocusable = true

	self.itemList = LUI.UIList.new( menu, controller, 2, 0, nil, true, false, 0, 0, false, false )
	self.itemList:makeFocusable()
	self.itemList:setLeftRight( true, true, 100, 100 )
	self.itemList:setTopBottom( true, false, 0, 0 )
	self.itemList:setWidgetType( CoD.StartMenu_ApState_Item )
	self.itemList:setHorizontalCount( 3 )
	self.itemList:setVerticalCount( 28 )
    self.itemList:setDataSource( "StartMenu_ApState" )
	self.itemList:updateDataSource()
	self:addElement( self.itemList )

    LUI.OverrideFunction_CallOriginalSecond( self, "close", function( element )
		element.itemList:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end