local PostLoadFunc = function( self, controller )
	self.getWidthInList = function( element, event )
		local textWidth = nil
		local spacing = 50
		if element.currentState == "NavButton" then
			textWidth = element.buttonText:getTextWidth()
		else
			textWidth = element.text:getTextWidth()
		end
		return textWidth + spacing
	end
	
	self:setHandleMouse( true )
end

CoD.StartMenu_TabWidget = InheritFrom( LUI.UIElement )
CoD.StartMenu_TabWidget.new = function( menu, controller )
	local self = LUI.UIElement.new()

	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

	self:setUseStencil( false )
	self:setClass( CoD.StartMenu_TabWidget )
	self.id = "StartMenu_TabWidget"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 200 )
	self:setTopBottom( true, false, 0, 38 )
	self.anyChildUsesUpdateState = true

	self.background = LUI.UIImage.new()
	self.background:setLeftRight( true, true, 4, -4 )
	self.background:setTopBottom( true, true, 4, -4 )
	self.background:setImage( RegisterImage( "$white" ) )
	self.background:setRGB( 0, 0, 0 )
	self:addElement( self.background )

	self.focus = LUI.UIImage.new()
	self.focus:setLeftRight( true, true, 0, 0 )
	self.focus:setTopBottom( true, true, 0, 0 )
	self.focus:setImage( RegisterImage( "uie_t7_menu_frontend_buttonpanelfull" ) )
	self:addElement( self.focus )

	self.text = LUI.UIText.new()
	self.text:setLeftRight( true, true, 0, 0 )
	self.text:setTopBottom( false, false, -9, 12 )
	self.text:setTTF( "fonts/default.TTF" )
	self.text:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	self.text:linkToElementModel( self, "tabName", true, function( model )
		local tabName = Engine.GetModelValue( model )
		if tabName then
			self.text:setText( Engine.Localize( tabName ) )
		end
	end )
	self:addElement( self.text )

	self.buttonText = LUI.UIText.new()
	self.buttonText:setLeftRight( true, true, 4, -4 )
	self.buttonText:setTopBottom( false, false, -14, 15 )
	self.buttonText:setTTF( "fonts/default.TTF" )
	self.buttonText:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	self.buttonText:linkToElementModel( self, "tabIcon", true, function( model )
		local tabIcon = Engine.GetModelValue( model )
		if tabIcon then
			self.buttonText:setText( Engine.Localize( tabIcon ) )
		end
	end )
	self:addElement( self.buttonText )

	-- this image is in kyle's bo2 hud if you want the brackets

	--[[self.Brackets1 = LUI.UIImage.new()
	self.Brackets1:setLeftRight( true, false, -6, 69 )
	self.Brackets1:setTopBottom( true, true, 0, 0 )
	self.Brackets1:setImage( RegisterImage( "menu_vis_bracket_small_zm" ) )
	self.Brackets1:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( self.Brackets1 )

	self.Brackets2 = LUI.UIImage.new()
	self.Brackets2:setLeftRight( false, true, -69, 6 )
	self.Brackets2:setTopBottom( true, true, 2, -2 )
	self.Brackets2:setImage( RegisterImage( "menu_vis_bracket_small_zm" ) )
	self.Brackets2:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self.Brackets2:setZRot( 180 )
	self:addElement( self.Brackets2 )--]]

	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function()
				self:setupElementClipCounter( 2 )

				--[[self.Brackets1:completeAnimation()
				self.Brackets1:setAlpha( 0 )
				self.clipFinished( self.Brackets1, {} )

				self.Brackets2:completeAnimation()
				self.Brackets2:setAlpha( 0 )
				self.clipFinished( self.Brackets2, {} )--]]

				self.focus:completeAnimation()
				self.focus:setRGB( 0, 0, 0 )
				self.focus:setAlpha(0)
				self.clipFinished( self.focus, {} )

				self.text:completeAnimation()
				self.text:setRGB( 1, 1, 1 )
				self.clipFinished( self.text, {} )
			end,

			Active = function()
				self:setupElementClipCounter( 2 )

				--[[self.Brackets1:completeAnimation()
				self.Brackets1:setAlpha( 1 )
				self.clipFinished( self.Brackets1, {} )

				self.Brackets2:completeAnimation()
				self.Brackets2:setAlpha( 1 )
				self.clipFinished( self.Brackets2, {} )--]]

				self.focus:completeAnimation()
				self.focus:setRGB( 1, 1, 1 )
				self.focus:setAlpha(1)
				self.clipFinished( self.focus, {} )

				self.text:completeAnimation()
				self.text:setRGB( 0, 0, 0 )
				self.clipFinished( self.text, {} )
			end,

			Over = function()
				self:setupElementClipCounter( 2 )

				self.focus:completeAnimation()
				self.focus:setRGB( 1, 1, 1 )
				self.focus:setAlpha( 0.5 )
				self.clipFinished( self.focus, {} )

				self.text:completeAnimation()
				self.text:setRGB( 0.98, 0.52, 0.05 )
				self.clipFinished( self.text, {} )
			end
		},

		NavButton = {
			DefaultClip = function()
				self:setupElementClipCounter( 3 )

				self.background:completeAnimation()
				self.background:setAlpha( 1 )
				self.clipFinished( self.background, {} )

				self.focus:completeAnimation()
				self.focus:setAlpha( 0.75 )
				self.clipFinished( self.focus, {} )

				self.buttonText:completeAnimation()
				self.buttonText:setAlpha( 1 )
				self.clipFinished( self.buttonText, {} )
			end
		},

		NavButtonHiddenPrompt = {
			DefaultClip = function()
				self:setupElementClipCounter( 3 )
				self.background:completeAnimation()
				self.background:setAlpha( 0 )
				self.clipFinished( self.background, {} )

				self.focus:completeAnimation()
				self.focus:setAlpha( 0 )
				self.clipFinished( self.focus, {} )

				self.buttonText:completeAnimation()
				self.buttonText:setAlpha( 0 )
				self.clipFinished( self.buttonText, {} )
			end
		}
	}

	self:mergeStateConditions( {
		{
			stateName = "NavButton",
			condition = function( menu, element, event )
				return ShouldDisplayButton( element, controller ) and IsGamepad( controller )
			end
		},
		{
			stateName = "NavButtonHiddenPrompt",
			condition = function( menu, element, event )
				return ShouldDisplayButton( element, controller ) and not IsGamepad( controller )
			end
		}
	} )

	self:linkToElementModel( self, "tabIcon", true, function( model )
		menu:updateElementState( self, { name = "model_validation", menu = menu, modelValue = Engine.GetModelValue( model ), modelName = "tabIcon" } )
	end )

	if self.m_eventHandlers.input_source_changed then
		local currentEvent = self.m_eventHandlers.input_source_changed
		self:registerEventHandler( "input_source_changed", function( element, event )
			event.menu = event.menu or menu
			element:updateState( event )
			return currentEvent( element, event )
		end )
	else
		self:registerEventHandler( "input_source_changed", LUI.UIElement.updateState )
	end
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "LastInput" ), function( model )
		menu:updateElementState( self, { name = "model_validation", menu = menu, modelValue = Engine.GetModelValue( model ), modelName = "LastInput" } )
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function( element )
		--element.Brackets1:close()
		--element.Brackets2:close()
		element.background:close()
		element.focus:close()
		element.text:close()
		element.buttonText:close()
	end )

	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end