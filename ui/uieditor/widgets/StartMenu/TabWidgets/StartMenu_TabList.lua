require( "ui.uieditor.widgets.StartMenu.TabWidgets.StartMenu_TabWidget" )

local PostLoadFunc = function( self, controller, menu )
	menu:AddButtonCallbackFunction( menu, controller, Enum.LUIButton.LUI_KEY_LB, nil, function( element, event, controller, menu )
		if not PropertyIsTrue( self, "m_disableNavigation" ) then
			self.grid:navigateItemLeft()
		end
	end, AlwaysFalse, false )
	menu:AddButtonCallbackFunction( menu, controller, Enum.LUIButton.LUI_KEY_RB, nil, function( element, event, controller, menu )
		if not PropertyIsTrue( self, "m_disableNavigation" ) then
			self.grid:navigateItemRight()
		end
	end, AlwaysFalse, false )

	self:setForceMouseEventDispatch( true )
end

CoD.StartMenu_TabList = InheritFrom( LUI.UIElement )
CoD.StartMenu_TabList.new = function( menu, controller )
	local self = LUI.UIElement.new()

	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

	self:setUseStencil( false )
	self:setClass( CoD.StartMenu_TabList )
	self.id = "StartMenu_TabList"
	self.soundSet = "none"
	self:setLeftRight( true, false, 0, 1090 )
	self:setTopBottom( true, false, 0, 40 )
	self.anyChildUsesUpdateState = true

	self.grid = LUI.GridLayout.new( menu, controller, false, 0, 0, 2, 0, nil, nil, false, false, 0, 0, false, false )
	self.grid:setLeftRight( true, false, 0, 1090 )
	self.grid:setTopBottom( true, false, 0, 40 )
	self.grid:setWidgetType( CoD.StartMenu_TabWidget )
	self.grid:setHorizontalCount( 10 )
	self.grid:registerEventHandler( "menu_loaded", function( element, event )
		local retval = nil
		UpdateDataSource( self, element, controller )
		if not retval then
			retval = element:dispatchEventToChildren( event )
		end
		return retval
	end )
	self.grid:registerEventHandler( "mouse_left_click", function( element, event )
		local retval = nil
		SelectItemIfPossible( self, element, controller, event )
		PlaySoundSetSound( self, "list_right" )
		if not retval then
			retval = element:dispatchEventToChildren( event )
		end
		return retval
	end )
	LUI.OverrideFunction_CallOriginalFirst( self.grid, "setWidth", function( element, controller )
		ScaleToElementWidth( self, element )
	end )
	self:addElement( self.grid )

	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function()
				self:setupElementClipCounter( 1 )

				self.grid:completeAnimation()
				self.grid:setAlpha( 1 )
				self.clipFinished( self.grid, {} )
			end
		},
		Hidden = {
			DefaultClip = function()
				self:setupElementClipCounter( 1 )

				self.grid:completeAnimation()
				self.grid:setAlpha( 0 )
				self.clipFinished( self.grid, {} )
			end
		}
	}

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function( element )
		element.grid:close()
	end )

	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end

	return self
end