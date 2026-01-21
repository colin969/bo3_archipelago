local APItemList = {
    [1] ={[1] = "ap_item_power_on",[2] = "archipelago_power_switch_perk"},
    [2] ={[1] = "ap_item_wallbuys" ,[2] ="archipelago_wallbuys_perk"},
    [3] ={[1] = "ap_item_quick_revive" ,[2] = "specialty_giant_quickrevive_zombies"},
    [4] ={[1] = "ap_item_juggernog" , [2] ="specialty_giant_juggernaut_zombies"},
    [5] ={[1] = "ap_item_double_tap" ,[2] = "specialty_giant_doubletap_zombies"},
    [6] ={[1] = "ap_item_speed_cola" ,[2] ="specialty_giant_fastreload_zombies"},
    [7] ={[1] = "ap_item_mule_kick" , [2] ="specialty_giant_three_guns_zombies"},
    [8] ={[1] = "ap_item_wunderfizz" , [2] ="archipelago_wunderfizz_perk"},
    --ap_item_stamin_up = "specialty_giant_marathon_zombies",
    --ap_item_dead_shot = "specialty_giant_ads_zombies",
    --ap_item_phd_flopper = "specialty_giant_divetonuke_zombies",
	--ap_item_tombstone = "specialty_giant_tombstone_zombies",
	--ap_item_widows_wine = "specialty_giant_widows_wine_zombies"
}

local APWeaponList = {
    [1] = {[1] = "ap_weapon_ar_icr", [2] = "archipelago_weapon_ar_icr"},
    [2] = {[1] = "ap_weapon_ar_hvk", [2] = "archipelago_weapon_ar_hvk"},
    [3] = {[1] = "ap_weapon_ar_manowar", [2] = "archipelago_weapon_ar_manowar"},
    [4] = {[1] = "ap_weapon_ar_m8a7", [2] = "archipelago_weapon_ar_m8a7"},
    [5] = {[1] = "ap_weapon_ar_sheiva", [2] = "archipelago_weapon_ar_sheiva"},
    [6] = {[1] = "ap_weapon_ar_kn44", [2] = "archipelago_weapon_ar_kn44"},
    [7] = {[1] = "ap_weapon_ar_ffar", [2] = "archipelago_weapon_ar_ffar"},
    [8] = {[1] = "ap_weapon_ar_garand", [2] = "archipelago_weapon_ar_garand"},
    [9] = {[1] = "ap_weapon_ar_peacekeeper", [2] = "archipelago_weapon_ar_peacekeeper"},
    [10] = {[1] = "ap_weapon_ar_an94", [2] = "archipelago_weapon_ar_an94"},
    [11] = {[1] = "ap_weapon_ar_galil", [2] = "archipelago_weapon_ar_galil"},
    [12] = {[1] = "ap_weapon_ar_m14", [2] = "archipelago_weapon_ar_m14"},
    [13] = {[1] = "ap_weapon_ar_m16", [2] = "archipelago_weapon_ar_m16"},
    [14] = {[1] = "ap_weapon_ar_basilisk", [2] = "archipelago_weapon_ar_basilisk"},
    [15] = {[1] = "ap_weapon_ar_xr2", [2] = "archipelago_weapon_ar_xr2"},
    [16] = {[1] = "ap_weapon_ar_stg44", [2] = "archipelago_weapon_ar_stg44"}
}

local TheGiantRegionList = {
    [1] ={[1] = "ap_item_region_0",[2] = "archipelago_the_giant_courtyard"},
    [2] ={[1] = "ap_item_region_1",[2] = "archipelago_the_giant_animal_testing"},
    [3] ={[1] = "ap_item_region_2",[2] = "archipelago_the_giant_garage"},
    [4] ={[1] = "ap_item_region_3",[2] = "archipelago_the_giant_power_room"},
    [5] ={[1] = "ap_item_region_4",[2] = "archipelago_the_giant_teleporter_1"},
    [6] ={[1] = "ap_item_region_5",[2] = "archipelago_the_giant_teleporter_2"},
    [7] ={[1] = "ap_item_region_6",[2] = "archipelago_the_giant_teleporter_3"},
}

local TheGiantItemList = {2,3,4,5,6,7}

CoD.ArchipelagoTracker = InheritFrom( LUI.UIElement )
CoD.ArchipelagoTracker.new = function (menu, controller)

    local self = LUI.UIElement.new()

    self:setClass(CoD.ArchipelagoTracker)
    self.id = "ArchipelagoTracker"
    self.soundSet = "default"


    --Background Image
    local bkgImg = LUI.UIImage.new()
    bkgImg:setLeftRight(true, false,-400,350)
    bkgImg:setTopBottom(true, false,-90,100)
    bkgImg:setRGB( 0, 0, 0 )
    bkgImg:setAlpha(0.5)
    self:addElement(bkgImg)
    self.bkgImg = bkgImg

    --Item List
    local itemHeight = 80
    local itemWidth = 80
    local startLeft = -360
    local startTop = -80
    local padding = 20
    local imageCount = 1
    self.itemImages = {}

    --RegionList
    self.regionImages = {}
    --

    --TODO: Set this based on map name
    local CurrentMapItemList = TheGiantItemList
    local CurrentMapRegionList = TheGiantRegionList
    --
    --Item Tracker
    for _,i in ipairs(CurrentMapItemList) do
        v = APItemList[i]
        local imageFile = v[2]
        local clientFieldName = v[1]
        local itemImage = LUI.UIImage.new()
        local leftPos = startLeft + ((imageCount-1)*(itemWidth+padding))
        local rightPos = leftPos + itemWidth
        local topPos = startTop
        local bottomPos = topPos+itemHeight
        itemImage:setLeftRight(true, false,leftPos,rightPos)
        itemImage:setTopBottom(true, false,topPos,bottomPos)
        itemImage:setImage(RegisterImage(imageFile))
        itemImage:setAlpha(.5)

        itemImage:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "zmInventory."..clientFieldName ), function( modelRef  )
            local val = Engine.GetModelValue( modelRef )
            if val then
                if val == 1 then
                    itemImage:setAlpha(1)
                else
                    itemImage:setAlpha(0.5)
                end
            end
        end )
        self:addElement(itemImage)
        table.insert(self.itemImages,itemImage)
        imageCount = imageCount +1
        if imageCount >8 then
            imageCount = 1
            startTop = startTop + itemHeight + padding
        end
    end
    --Map Tracker
    for _,v in ipairs(CurrentMapRegionList) do
        local imageFile = v[2]
        local clientFieldName = v[1]
        local regionImage = LUI.UIImage.new()

        local mapWidth = 473/2
        local mapHeight = 576/2

        local leftPos = -125
        local rightPos = leftPos + mapWidth
        local topPos = 300
        local bottomPos = topPos+mapHeight
        regionImage:setLeftRight(true, false,leftPos,rightPos)
        regionImage:setTopBottom(true, false,topPos,bottomPos)
        regionImage:setImage(RegisterImage(imageFile))
        if clientFieldName == "ap_item_region_0" then
            regionImage:setAlpha(1)
        else
            regionImage:setAlpha(.5)
            regionImage:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "zmInventory."..clientFieldName ), function( modelRef  )
                local val = Engine.GetModelValue( modelRef )
                if val then
                    if val == 1 then
                        regionImage:setAlpha(1)
                    else
                        regionImage:setAlpha(0.5)
                    end
                end
            end )
        end

        self:addElement(regionImage)
        table.insert(self.regionImages,regionImage)
    end
    --
    self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setAlpha( 0 )
			end
		},
		Visible = {
			DefaultClip = function ()
				self:setAlpha( 1 )
			end
		}
	}
    self:mergeStateConditions( {
		{
			stateName = "Visible",
			condition = function ( menu, element, event )
				return Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN )
			end
		}
	} )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN ), function ( model )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( model ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN
		} )
	end )
	
    --Close callback (Close all the children stuff)
    LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
        element.bkgImg:close()
        for i,v in ipairs(element.itemImages) do
            v:close()
        end
        for i,v in ipairs(element.regionImages) do
            v:close()
        end
	end )
    return self
end