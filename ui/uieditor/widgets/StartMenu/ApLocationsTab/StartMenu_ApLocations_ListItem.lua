CoD.StartMenu_ApLocations_ListItem = InheritFrom( LUI.UIElement )
CoD.StartMenu_ApLocations_ListItem.new = function( menu, controller )
	local self = LUI.UIElement.new()

	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

	self:setUseStencil( false )
	self:setClass( CoD.StartMenu_ApLocations_ListItem )
	self.id = "StartMenu_ApLocations_ListItem"
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
	self.ItemName:linkToElementModel( self, "name", true, function( model )
		local name = Engine.GetModelValue( model )
		if name then
			self.ItemName:setText( Engine.Localize( name ) )
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