CoD.ArchipelagoLoadSpinner = InheritFrom( LUI.UIElement )
CoD.ArchipelagoLoadSpinner.new = function ( menu, controller )
	local self = LUI.UIElement.new()

    self:setClass(CoD.ArchipelagoLoadSpinner)
    self.id = "ArchipelagoLoadSpinner"
    self.soundSet = "default"
    self:setLeftRight(true, true, 0, 0)
    self:setTopBottom(true, true, 0, 0)

	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

    self.image = LUI.UIImage.new()
    self.image:setLeftRight( false, false, -20, 20 )
    self.image:setTopBottom( true, false, 40, 80 )
    self.image:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
    self.image:setImage( RegisterImage( "archipelago_logo_down" ))
    self.image:setAlpha(0)
    self:addElement( self.image )

    self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "ApLoading" ), function ( model )
		local loading = Engine.GetModelValue(model)
        if loading then
            self.image:setAlpha(1);
        else
            self.image:setAlpha(0);
        end
	end )

    LUI.OverrideFunction_CallOriginalSecond( self, "close", function( element )
		element.image:close()
	end )

	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end