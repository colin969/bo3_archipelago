require( "ui.uieditor.widgets.BackgroundFrames.GenericMenuFrame" )
require( "ui.uieditor.widgets.Lobby.Common.FE_Menu_LeftGraphics" )
require( "ui.uieditor.widgets.Lobby.Common.FE_TabBar" )
require( "ui.uieditor.widgets.playercard.SelfIdentityBadge" )

require( "ui.uieditor.menus.StartMenu.StartMenu_ApModSettings_Locations" )
require( "ui.uieditor.widgets.StartMenu.ApItemsTab.StartMenu_ApItems" )
require( "ui.uieditor.widgets.StartMenu.ApStateTab.StartMenu_ApState" )

local PostLoadFunc = function( self, controller )
	self:registerEventHandler( "menu_opened", function()
		return true
	end )
	self.disableLeaderChangePopupShutdown = true
	self.disableDarkenElement = true
	self.disablePopupOpenCloseAnim = true
	SetControllerModelValue( controller, "forceScoreboard", 0 )

	self.TabFrame:linkToElementModel( self.FETabBar.Tabs.grid, "tabWidget", true, function( model )
		local modelValue = Engine.GetModelValue( model )
		if modelValue then
			self.TabFrame:changeFrameWidget( modelValue )
		end
	end )

	self.MenuFrame:linkToElementModel( self.FETabBar.Tabs.grid, "tabName", true, function( model )
        local tabName = Engine.GetModelValue( model )
        if tabName then
            self.MenuFrame.titleLabel:setText( string.upper( tabName ) )
            self.MenuFrame.cac3dTitleIntermediary0.FE3dTitleContainer0.MenuTitle.TextBox1.Label0:setText( string.upper( tabName ) )
        else
            self.MenuFrame.titleLabel:setText( "" )
            self.MenuFrame.cac3dTitleIntermediary0.FE3dTitleContainer0.MenuTitle.TextBox1.Label0:setText( "" )
        end
    end )

    self.selectedText:linkToElementModel( self.FETabBar.Tabs.grid, "tabName", true, function( model )
        local tabName = Engine.GetModelValue( model )
        if tabName then
            local controllerModel = Engine.GetModelForController( controller )
            local modelPath = "Selected" .. tabName
            
            if self.activeTabSelectionSubscription then
                self:removeSubscription( self.activeTabSelectionSubscription )
            end

            self.activeTabSelectionSubscription = self:subscribeToModel( Engine.GetModel( controllerModel, modelPath ), function( selectedModel )
			    local selectedValue = Engine.GetModelValue( selectedModel )
			    
			    if selectedValue and selectedValue ~= "" then
			        self.pendingText = "Equipped: ^9" .. Engine.Localize( selectedValue )
			        self:playClip( "UpdateText" )
			    else
			        self.pendingText = ""
			        self.selectedText:setText("")
			        self:playClip( "DefaultClip" )
			    end
			end )
        end
    end )
end

DataSources.ModSettingsTabs = ListHelper_SetupDataSource( "ModSettingsTabs", function( controller )
	local tabList = {}

	table.insert( tabList, {
		models = { tabIcon = CoD.buttonStrings.shoulderl },
		properties = { m_mouseDisabled = true }
	} )

	table.insert( tabList, {
		models = { tabName = "Checks", tabWidget = "CoD.StartMenu_ApModSettings_Locations" },
		properties = { tabId = "gameOptions" }
	} )

	table.insert( tabList, {
		models = { tabName = "Items", tabWidget = "CoD.StartMenu_ApItems" },
		properties = { tabId = "gameOptions" }
	} )

	table.insert( tabList, {
		models = { tabName = "Map State", tabWidget = "CoD.StartMenu_ApState" },
		properties = { tabId = "gameOptions" }
	} )


	table.insert( tabList, {
		models = { tabIcon = CoD.buttonStrings.shoulderr },
		properties = { m_mouseDisabled = true }
	} )

	return tabList
end, true )

LUI.createMenu.StartMenu_ApMod_Main = function( controller )
	local self = CoD.Menu.NewForUIEditor( "StartMenu_ApMod_Main" )

	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

	self.soundSet = "ChooseDecal"
	self:setOwner( controller )
	self:setLeftRight( true, true, 0, 0 )
	self:setTopBottom( true, true, 0, 0 )
	self:playSound( "menu_open", controller )
	self.buttonModel = Engine.CreateModel( Engine.GetModelForController( controller ), "StartMenu_ApMod_Main.buttonPrompts" )
	self.anyChildUsesUpdateState = true

	self.Background = CoD.StartMenu_Background.new( self, controller )
	self.Background:setLeftRight( true, true, 0, 0 )
	self.Background:setTopBottom( true, true, 0, 0 )
	self.Background:mergeStateConditions( {
		{
			stateName = "InGame",
			condition = function( menu, element, event )
				return IsInGame()
			end
		}
	} )
	self:addElement( self.Background )

	self.BlackBG = LUI.UIImage.new()
	self.BlackBG:setLeftRight( true, true, 0, 0 )
	self.BlackBG:setTopBottom( true, true, 0, 0 )
	self.BlackBG:setAlpha( 0.6 )
	self.BlackBG:setImage( RegisterImage( "uie_fe_cp_background" ) )
	self:addElement( self.BlackBG )

	self.FEMenuLeftGraphics = CoD.FE_Menu_LeftGraphics.new( self, controller )
	self.FEMenuLeftGraphics:setLeftRight( true, false, 19, 71 )
	self.FEMenuLeftGraphics:setTopBottom( true, false, 86, 703.25 )
	self:addElement( self.FEMenuLeftGraphics )

	self.TabFrame = LUI.UIFrame.new( self, controller, 0, 0, false )
	self.TabFrame:setLeftRight( false, false, -575, 575 )
	self.TabFrame:setTopBottom( false, false, -221, 299 )
	self:addElement( self.TabFrame )

	self.CategoryListPanel = LUI.UIImage.new()
	self.CategoryListPanel:setLeftRight( false, false, -640, 640 )
	self.CategoryListPanel:setTopBottom( false, false, -276, -237 )
	self.CategoryListPanel:setRGB( 0, 0, 0 )
	self:addElement( self.CategoryListPanel )

	self.MenuFrame = CoD.GenericMenuFrame.new( self, controller )
	self.MenuFrame:setLeftRight( true, true, 0, 0 )
	self.MenuFrame:setTopBottom( true, true, 0, 0 )
	self:addElement( self.MenuFrame )

	self.SelfIdentityBadge = CoD.SelfIdentityBadge.new( self, controller )
	self.SelfIdentityBadge:setLeftRight( false, true, -435, -92 )
	self.SelfIdentityBadge:setTopBottom( true, false, 24, 84 )
	self.SelfIdentityBadge:subscribeToGlobalModel( controller, "PerController", "identityBadge", function( model )
		self.SelfIdentityBadge:setModel( model, controller )
	end )
	self.SelfIdentityBadge:subscribeToGlobalModel( controller, "PerController", nil, function( model )
		self.SelfIdentityBadge.CallingCard.CallingCardsFrameWidget:setModel( model, controller )
	end )
	self:addElement( self.SelfIdentityBadge )

	self.FETabBar = CoD.FE_TabBar.new( self, controller )
	self.FETabBar:setLeftRight( true, true, 0, 1217 )
	self.FETabBar:setTopBottom( true, false, 85, 126 )
	self.FETabBar.Tabs.grid:setHorizontalCount( 8 )
	self.FETabBar.Tabs.grid:setDataSource( "ModSettingsTabs" )
	self:addElement( self.FETabBar )

	self.selectedText = LUI.UIText.new()
	self.selectedText:setLeftRight( true, false, -86, 450 )
	self.selectedText:setTopBottom( true, false, 62, 92 )
	self.selectedText:setTTF( "fonts/default.TTF" )
	self.selectedText:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
	self.selectedText:setScale( 0.35 )
	self.selectedText:setZRot( 0.5 )
	self:addElement( self.selectedText )

	self.clipsPerState = {
	    DefaultState = {
	        DefaultClip = function()
	            self:setupElementClipCounter( 1 )

	            self.selectedText:completeAnimation()
	            self.selectedText:setAlpha( 1 ) 
	            self.clipFinished( self.selectedText, {} )
	        end,
	        
	        UpdateText = function()
	            self:setupElementClipCounter( 1 )

	            local FadeIn = function( element, event )
	                element:beginAnimation( "keyframe", 150, false, false, CoD.TweenType.Linear )
	                element:setAlpha( 1 )
	                
	                if event.interrupted then
	                    self.clipFinished( element, event )
	                else
	                    element:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
	                end
	            end

	            self.selectedText:completeAnimation()
	            self.selectedText:beginAnimation( "keyframe", 150, false, false, CoD.TweenType.Linear )
	            self.selectedText:setAlpha( 0 ) 
	            
	            self.selectedText:registerEventHandler( "transition_complete_keyframe", function( sender, event )
	                if self.pendingText then
	                    self.selectedText:setText( self.pendingText )
	                end
	                FadeIn( sender, event )
	            end )
	        end
	    }
	}

	self:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, nil, function( element, event, controller, menu )
	    GoBack( event, controller )
	    return true
	end, function( element, menu, controller )
	    CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, "MENU_BACK" )
	    return true
	end, false )

	self:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_START, "M", function( element, event, controller, menu )
	    GoBack( event, controller )
	    return true
	end, function( element, menu, controller )
	    CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_START, "MENU_DISMISS_MENU" )
	    return true
	end, false )

	self:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, nil, function( element, event, controller, menu )
	    PlaySoundSetSound( self, "list_action" )
	    return true
	end, function( element, menu, controller )
	    CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
	    return true
	end, false )

	self:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "S", function( element, event, controller, menu )
	    if IsInGame() and not IsLobbyNetworkModeLAN() and not IsDemoPlaying() then
	        OpenPopup( self, "Social_Main", controller, "", "" )
	        return true
	    end
	end, function( element, menu, controller )
	    if IsInGame() and not IsLobbyNetworkModeLAN() and not IsDemoPlaying() then
	        CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "MENU_SOCIAL" )
	        return true
	    else
	        return false
	    end
	end, false )

	self:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_NONE, "ESCAPE", function( element, event, controller, menu )
	    GoBack( event, controller )
	    return true
	end, function( element, menu, controller )
	    CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_NONE, "" )
	    return true
	end, false, true )

	self.TabFrame.id = "TabFrame"

	self.MenuFrame:setModel( self.buttonModel, controller )

	self:processEvent( { name = "menu_loaded", controller = controller } )
	self:processEvent( { name = "update_state", menu = self } )

	if not self:restoreState() then
		self.TabFrame:processEvent( { name = "gain_focus", controller = controller } )
	end

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function( element )
		element.Background:close()
		element.BlackBG:close()
		element.FEMenuLeftGraphics:close()
		element.TabFrame:close()
		element.CategoryListPanel:close()
		element.MenuFrame:close()
		element.SelfIdentityBadge:close()
		element.FETabBar:close()
		element.selectedText:close()
		Engine.UnsubscribeAndFreeModel( Engine.GetModel( Engine.GetModelForController( controller ), "StartMenu_ApMod_Main.buttonPrompts" ) )
	end )

	if PostLoadFunc then
		PostLoadFunc( self, controller )
	end
	
	return self
end