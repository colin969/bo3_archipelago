--Archipelago Client
require("Archipelago.ArchipelagoClient")
--

CoD.ArchipelagoDisplay = InheritFrom( LUI.UIElement )
CoD.ArchipelagoDisplay.new = function (menu, controller)

    local self = LUI.UIElement.new()


    self:setClass(CoD.ArchipelagoDisplay)
    self.id = "ArchipelagoDisplay"
    self.soundSet = "default"

    --Title + VersionText
    local TitleText = LUI.UIText.new(menu, controller)
    local version = Engine.DvarString( nil, "MOD_VERSION" ) 
    TitleText:setLeftRight(false, false,-25,25 )
    TitleText:setTopBottom(false, false, -120, -100)
    TitleText:setText("(Host) Archipelago Mod v" .. version)
    self:addElement(TitleText)
    self.TitleText = TitleText

    --Only visible when score is open, but still run/do things
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

	--Handle Archipelago Events from the GSC (via LUINotifyEvent)
	self:subscribeToGlobalModel(controller, "PerController", "scriptNotify", Archi.FromGSC)
	
    --Close callback (Close all the children stuff)
    LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.TitleText:close()
	end )

    return self
end