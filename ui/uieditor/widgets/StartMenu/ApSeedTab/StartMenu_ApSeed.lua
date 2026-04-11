DataSources.StartMenu_ApSeed_Maps = ListHelper_SetupDataSource( "StartMenu_ApSeed_Maps", function( controller )
    local rows = {}

    -- Get set of strings to display from the gsc
    for val, _ in pairs(Archi.MapUnlocks) do
        val = string.sub(val, 13)
        table.insert( rows, {
            models = { item = val }
        })    
    end

    return rows
end, true )

DataSources.StartMenu_ApSeed_Settings = ListHelper_SetupDataSource( "StartMenu_ApSeed_Settings", function( controller )
    local rows = {}

    roundCheckpoints = Engine.DvarInt(-1,"ARCHIPELAGO_DIFFICULTY_ROUND_CHECKPOINTS")
    if roundCheckpoints > 0 then
        table.insert( rows, {
            models = { item = "Round Checkpoints: Every " .. roundCheckpoints .. " Rounds" }
        })
    else
        table.insert( rows, {
            models = { item = "Round Checkpoints: Disabled" }
        })
    end

    attachmentRando = Engine.DvarInt(0,"ARCHIPELAGO_ATTACHMENT_RANDO_ENABLED")
    if attachmentRando > 0 then
        table.insert( rows, {
            models = { item = "Attachment Randomizer: Enabled" }
        })
    else
        table.insert( rows, {
            models = { item = "Attachment Randomizer: Disabled" }
        })
    end

    perkLimit = Engine.DvarInt(-1,"ARCHIPELAGO_MSTATE_PERK_LIMIT")
    if perkLimit > -1 then
        table.insert( rows, {
            models = { item = "Current Perk Limit: " .. perkLimit }
        })
    else
        table.insert( rows, {
            models = { item = "Current Perk Limit: Unknown" }
        })
    end

    goalItemsRequired = Engine.DvarInt(-1,"ARCHIPELAGO_GOAL_ITEMS_REQUIRED")
    table.insert( rows, {
        models = { item = "Goal Items Required: " .. goalItemsRequired }
    })
    
    goalItems = Archi.GetGoalItems()
    if goalItemsRequired > #goalItems then
        goalItemsRequired = #goalItems
    end
    for _, val in pairs(goalItems) do
        owned = Archi.CheckGoalItemExists(val)
        if owned then
            table.insert( rows, {
                models = { item = " ^2- " .. val }
            })
        else
            table.insert( rows, {
                models = { item = " - " .. val }
            })
        end
    end

    return rows
end, true )

CoD.StartMenu_ApSeed_Item = InheritFrom( LUI.UIElement )
CoD.StartMenu_ApSeed_Item.new = function( menu, controller )
	local self = LUI.UIElement.new()

	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

	self:setUseStencil( false )
	self:setClass( CoD.StartMenu_ApSeed_Item )
	self.id = "StartMenu_ApSeed_Item"
	self.soundSet = "default"
	self:setLeftRight( true, false, 10, 350 )
	self:setTopBottom( true, false, 0, 30 )
	self:makeFocusable()
	self:setHandleMouse( true )

	self.ItemName = LUI.UIText.new()
	self.ItemName:setLeftRight( true, false, 20, 320 )
	self.ItemName:setTopBottom( false, false, 5, 30 )
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

CoD.StartMenu_ApSeed = InheritFrom( LUI.UIElement )
CoD.StartMenu_ApSeed.new = function ( menu, controller )
    local self = LUI.UIElement.new()

    if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

    self:setUseStencil( false )
	self:setClass( CoD.StartMenu_ApSeed )
	self.id = "StartMenu_ApSeed"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 1150 )
	self:setTopBottom( true, false, 0, 520 )
	self:makeFocusable()
	self.onlyChildrenFocusable = true

    seed = Engine.DvarString("unknown", "ARCHIPELAGO_SEED")

    self.seed = LUI.UIText.new()
    self.seed:setLeftRight( true, false, 100, 350 )
	self.seed:setTopBottom( true, false, 0, 15 )
	self.seed:setTTF( "fonts/default.TTF" )
	self.seed:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
    self.seed:setText("Seed: " .. seed)
    self:addElement( self.seed )

    self.mapListTitle = LUI.UIText.new()
    self.mapListTitle:setLeftRight( true, false, 100, 350 )
	self.mapListTitle:setTopBottom( true, false, 20, 50 )
	self.mapListTitle:setTTF( "fonts/default.TTF" )
	self.mapListTitle:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
    self.mapListTitle:setText("Unlocked Maps")
    self:addElement( self.mapListTitle )

	self.mapList = LUI.UIList.new( menu, controller, 2, 0, nil, true, false, 0, 0, false, false )
	self.mapList:setLeftRight( true, false, 100, 350 )
	self.mapList:setTopBottom( true, false, 30, 0 )
	self.mapList:setWidgetType( CoD.StartMenu_ApSeed_Item )
	self.mapList:setHorizontalCount( 1 )
	self.mapList:setVerticalCount( 16 )
    self.mapList:setDataSource( "StartMenu_ApSeed_Maps" )
	self.mapList:updateDataSource()
	self:addElement( self.mapList )

    self.settingsTitle = LUI.UIText.new()
    self.settingsTitle:setLeftRight( true, false, 400, 700 )
	self.settingsTitle:setTopBottom( true, false, 20, 50 )
	self.settingsTitle:setTTF( "fonts/default.TTF" )
	self.settingsTitle:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
    self.settingsTitle:setText("Seed Settings")
    self:addElement( self.settingsTitle )

    self.settingsList = LUI.UIList.new( menu, controller, 2, 0, nil, true, false, 0, 0, false, false )
	self.settingsList:setLeftRight( true, true, 400, 700 )
	self.settingsList:setTopBottom( true, false, 30, 0 )
	self.settingsList:setWidgetType( CoD.StartMenu_ApSeed_Item )
	self.settingsList:setHorizontalCount( 1 )
	self.settingsList:setVerticalCount( 16 )
    self.settingsList:setDataSource( "StartMenu_ApSeed_Settings" )
	self.settingsList:updateDataSource()
	self:addElement( self.settingsList )


    LUI.OverrideFunction_CallOriginalSecond( self, "close", function( element )
        element.seed:close()
        element.mapListTitle:close()
		element.mapList:close()
        element.settingsTitle:close()
        element.settingsList:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end