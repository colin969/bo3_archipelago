require( "ui.uieditor.widgets.Lobby.Common.List1ButtonLarge_PH" )
require( "ui.uieditor.widgets.Utilities.ProgressBar_Rank" )
require( "ui.uieditor.widgets.ZMPromotional.ZM_PromoIconList" )

require( "ui.uieditor.menus.StartMenu.StartMenu_ApModSettings_Locations" )

DataSources.ModStartMenuGameOptions = ListHelper_SetupDataSource( "ModStartMenuGameOptions", function( controller )
	local menuOptions = {}

	if Engine.IsDemoPlaying() then
		local demoSegmentCount = Engine.GetDemoSegmentCount()
		local isHighlightReelMode = Engine.IsDemoHighlightReelMode()
		local isClipPlaying = Engine.IsDemoClipPlaying()

		if not IsDemoRestrictedBasicMode() then
			table.insert( menuOptions, {
				models = { displayText = Engine.ToUpper( Engine.Localize( "MENU_UPLOAD_CLIP", demoSegmentCount ) ), action = StartMenuUploadClip, disabledFunction = IsUploadClipButtonDisabled },
				properties = { hideHelpItemLabel = true }
			} )
		end

		if isHighlightReelMode then
			table.insert( menuOptions, {
				models = { displayText = Engine.ToUpper( Engine.Localize( "MENU_DEMO_CUSTOMIZE_HIGHLIGHT_REEL" ) ), action = StartMenuOpenCustomizeHighlightReel, disabledFunction = IsCustomizeHighlightReelButtonDisabled }
			} )
		end

		table.insert( menuOptions, {
			models = { displayText = Engine.ToUpper( Engine.Localize( "MENU_JUMP_TO_START" ) ), action = StartMenuJumpToStart, disabledFunction = IsJumpToStartButtonDisabled },
			properties = { hideHelpItemLabel = true }
		} )

		local endDemoLabel
		if isClipPlaying then
			endDemoLabel = Engine.Localize( "MENU_END_CLIP" )
		else
			endDemoLabel = Engine.Localize( "MENU_END_FILM" )
		end

		table.insert( menuOptions, {
			models = { displayText = Engine.ToUpper( endDemoLabel ), action = StartMenuEndDemo }
		} )

	elseif CoD.isCampaign then
		table.insert( menuOptions, {
			models = { displayText = "MENU_RESUMEGAME_CAPS", action = StartMenuGoBack_ListElement }
		} )

		local isInTrainingSim = CoD.SafeGetModelValue( Engine.GetModelForController( controller ), "safehouse.inTrainingSim" ) or 0

		if Engine.IsLobbyHost( Enum.LobbyType.LOBBY_TYPE_GAME ) then
			if not CoD.isSafehouse and controller == Engine.GetPrimaryController() then
				table.insert( menuOptions, {
					models = { displayText = "MENU_RESTART_MISSION_CAPS", action = RestartMission }
				} )

				if LUI.DEV ~= nil then
					table.insert( menuOptions, {
						models = { displayText = "MENU_RESTART_CHECKPOINT_CAPS", action = RestartFromCheckpoint }
					} )
				end
			end

			if controller == Engine.GetPrimaryController() then
				table.insert( menuOptions, {
					models = { displayText = "MENU_CHANGE_DIFFICULTY_CAPS", action = OpenDifficultySelect }
				} )
			end

			if CoD.isSafehouse and isInTrainingSim == 1 then
				table.insert( menuOptions, {
					models = { displayText = "MENU_END_TRAINING_SIM", action = EndTrainingSim }
				} )
			elseif controller == Engine.GetPrimaryController() then
				local quitLabel = Engine.DvarBool( 0, "ui_blocksaves" ) and "MENU_EXIT_CAPS" or "MENU_SAVE_AND_QUIT_CAPS"
				table.insert( menuOptions, {
					models = { displayText = quitLabel, action = SaveAndQuitGame }
				} )
			end
		elseif CoD.isSafehouse and isInTrainingSim == 1 then
			table.insert( menuOptions, {
				models = { displayText = "MENU_END_TRAINING_SIM", action = EndTrainingSim }
			} )
		else
			table.insert( menuOptions, {
				models = { displayText = "MENU_LEAVE_PARTY_AND_EXIT_CAPS", action = QuitGame }
			} )
		end

	elseif CoD.isMultiplayer then
		if Engine.Team( controller, "name" ) ~= "TEAM_SPECTATOR"
			and Engine.GetGametypeSetting( "disableClassSelection" ) ~= 1 then

			table.insert( menuOptions, {
				models = { displayText = "MPUI_CHOOSE_CLASS_BUTTON_CAPS", action = ChooseClass }
			} )
		end

		if not Engine.GameModeIsMode( CoD.GAMEMODE_PUBLIC_MATCH )
		and not Engine.GameModeIsMode( CoD.GAMEMODE_LEAGUE_MATCH )
		and not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_ROUND_END_KILLCAM )
		and not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_FINAL_KILLCAM )
		and CoD.IsTeamChangeAllowed() then
			table.insert( menuOptions, {
				models = { displayText = "MPUI_CHANGE_TEAM_BUTTON_CAPS", action = ChooseTeam }
			} )
		end

		if controller == 0 then
			local quitGameLabel = "MENU_QUIT_GAME_CAPS"

			if Engine.IsLobbyHost( Enum.LobbyType.LOBBY_TYPE_GAME ) and not CoD.isOnlineGame() then
				quitGameLabel = "MENU_END_GAME_CAPS"
			end

			table.insert( menuOptions, {
				models = { displayText = quitGameLabel, action = QuitGame_MP }
			} )
		end

	elseif CoD.isZombie then
		table.insert( menuOptions, {
			models = { displayText = "MENU_RESUMEGAME_CAPS", action = StartMenuGoBack_ListElement }
		} )

		if Engine.IsLobbyHost( Enum.LobbyType.LOBBY_TYPE_GAME ) then
			table.insert( menuOptions, {
				models = { displayText = "MENU_RESTART_LEVEL_CAPS", action = RestartGame }
			} )
		end

		if CoD.isHost() then
			table.insert( menuOptions, {
				models = {
					displayText = "AP LOCATIONS",
					action = function( self, element, controller, actionParam, menu )
						NavigateToMenu( menu, "StartMenu_ApModSettings_Locations", true, controller )
					end
				}
			} )
		end

		if Engine.DvarString(nil,"mapname") == "zm_genesis" then
			table.insert( menuOptions, {
				models = {
					displayText = "RESET SUMMONING KEY",
					action = function(...)
						Engine.SetDvar("ARCHIPELAGO_GENESIS_RESET_SUMMONING_KEY", "1")
						StartMenuGoBack_ListElement(...);
					end
				}
			})
		end

		if Engine.IsLobbyHost( Enum.LobbyType.LOBBY_TYPE_GAME ) == true then
			table.insert( menuOptions, {
				models = { displayText = "MENU_END_GAME_CAPS", action = QuitGame_MP }
			} )
		else
			table.insert( menuOptions, {
				models = { displayText = "MENU_QUIT_GAME_CAPS", action = QuitGame_MP }
			} )
		end
	end

	return menuOptions
end, true )


CoD.StartMenu_GameOptions_ZM = InheritFrom( LUI.UIElement )
CoD.StartMenu_GameOptions_ZM.new = function( menu, controller )
	local self = LUI.UIElement.new()

	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

	self:setUseStencil( false )
	self:setClass( CoD.StartMenu_GameOptions_ZM )
	self.id = "StartMenu_GameOptions_ZM"
	self.soundSet = "ChooseDecal"
	self:setLeftRight( true, false, 0, 1150 )
	self:setTopBottom( true, false, 0, 520 )
	self:makeFocusable()
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	self.buttonList = LUI.UIList.new( menu, controller, 2, 0, nil, true, false, 0, 0, false, false )
	self.buttonList:makeFocusable()
	self.buttonList:setLeftRight( true, false, 12, 292 )
	self.buttonList:setTopBottom( true, false, 4.91, 172.91 )
	self.buttonList:setWidgetType( CoD.List1ButtonLarge_PH )
	self.buttonList:setVerticalCount( 5 )
	self.buttonList:setDataSource( "ModStartMenuGameOptions" )
	self.buttonList:registerEventHandler( "gain_focus", function( element, event )
		local retval = nil
		if element.gainFocus then
			retval = element:gainFocus( event )
		elseif element.super.gainFocus then
			retval = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		return retval
	end )
	self.buttonList:registerEventHandler( "lose_focus", function( element, event )
		local retval = nil
		if element.loseFocus then
			retval = element:loseFocus( event )
		elseif element.super.loseFocus then
			retval = element.super:loseFocus( event )
		end
		return retval
	end )
	menu:AddButtonCallbackFunction( self.buttonList, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function( element, menu, controller, model )
		ProcessListAction( self, element, controller )
		return true
	end, function( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	self:addElement( self.buttonList )
	
	self.rankProgress = CoD.ProgressBar_Rank.new( menu, controller )
	self.rankProgress:setLeftRight( true, false, 4.87, 1147.87 )
	self.rankProgress:setTopBottom( true, false, 451, 517 )
	self:addElement( self.rankProgress )
	
	self.Pixel2001 = LUI.UIImage.new()
	self.Pixel2001:setLeftRight( true, false, -36, 0 )
	self.Pixel2001:setTopBottom( true, false, 106, 110 )
	self.Pixel2001:setYRot( -180 )
	self.Pixel2001:setImage( RegisterImage( "uie_t7_menu_frontend_pixelist" ) )
	self.Pixel2001:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( self.Pixel2001 )
	
	self.Pixel20 = LUI.UIImage.new()
	self.Pixel20:setLeftRight( true, false, -36.13, -0.13 )
	self.Pixel20:setTopBottom( true, false, 486, 490 )
	self.Pixel20:setYRot( -180 )
	self.Pixel20:setImage( RegisterImage( "uie_t7_menu_frontend_pixelist" ) )
	self.Pixel20:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( self.Pixel20 )
	
	self.Pixel200 = LUI.UIImage.new()
	self.Pixel200:setLeftRight( true, false, 1146.87, 1182.87 )
	self.Pixel200:setTopBottom( true, false, 486, 490 )
	self.Pixel200:setImage( RegisterImage( "uie_t7_menu_frontend_pixelist" ) )
	self.Pixel200:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( self.Pixel200 )
	
	self.Pixel2000 = LUI.UIImage.new()
	self.Pixel2000:setLeftRight( true, false, 1145.87, 1181.87 )
	self.Pixel2000:setTopBottom( true, false, 34, 38 )
	self.Pixel2000:setImage( RegisterImage( "uie_t7_menu_frontend_pixelist" ) )
	self.Pixel2000:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( self.Pixel2000 )
	
	self.Pixel2002 = LUI.UIImage.new()
	self.Pixel2002:setLeftRight( true, false, 1146.87, 1182.87 )
	self.Pixel2002:setTopBottom( true, false, 386, 390 )
	self.Pixel2002:setImage( RegisterImage( "uie_t7_menu_frontend_pixelist" ) )
	self.Pixel2002:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( self.Pixel2002 )
	
	self.ZMPromoIconList = CoD.ZM_PromoIconList.new( menu, controller )
	self.ZMPromoIconList:setLeftRight( true, false, 12, 214 )
	self.ZMPromoIconList:setTopBottom( true, false, 386, 441 )
	self.ZMPromoIconList:mergeStateConditions( {
		{
			stateName = "ShowLines",
			condition = function( menu, element, event )
				return AlwaysTrue()
			end
		}
	} )
	self:addElement( self.ZMPromoIconList )
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function()
				self:setupElementClipCounter( 1 )

				self.rankProgress:completeAnimation()
				self.rankProgress:setLeftRight( true, false, 4.87, 1147.87 )
				self.rankProgress:setTopBottom( true, false, 451, 517 )
				self.clipFinished( self.rankProgress, {} )
			end
		},
		CP_PauseMenu = {
			DefaultClip = function()
				self:setupElementClipCounter( 1 )

				self.rankProgress:completeAnimation()
				self.rankProgress:setLeftRight( true, false, 12, 307 )
				self.rankProgress:setTopBottom( true, false, 172.91, 238.91 )
				self.clipFinished( self.rankProgress, {} )
			end
		}
	}

	self:mergeStateConditions( {
		{
			stateName = "CP_PauseMenu",
			condition = function( menu, element, event )
				return IsCampaign()
			end
		}
	} )

	self:subscribeToModel( Engine.GetModel( Engine.GetGlobalModel(), "lobbyRoot.lobbyNav" ), function( model )
		menu:updateElementState( self, { name = "model_validation", menu = menu, modelValue = Engine.GetModelValue( model ), modelName = "lobbyRoot.lobbyNav" } )
	end )

	self.buttonList.id = "buttonList"

	self:registerEventHandler( "gain_focus", function( element, event )
		if element.m_focusable and element.buttonList:processEvent( event ) then
			return true
		else
			return LUI.UIElement.gainFocus( element, event )
		end
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function( element )
		element.buttonList:close()
		element.rankProgress:close()
		element.ZMPromoIconList:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end