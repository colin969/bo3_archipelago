local GetTextWidthManual = function( textElement, message )
    local charCount = string.len( message )
    return charCount * 6
end

local PreLoadFunc = function( self, controller )
	local controllerModel = Engine.GetModelForController( controller )
	local luaPrintModel = Engine.CreateModel( controllerModel, "luaprint" )
	Engine.SetModelValue( luaPrintModel, "" )
end

CoD.LuaPrint = InheritFrom( LUI.UIElement )
CoD.LuaPrint.new = function( menu, controller )
    local self = LUI.UIElement.new()

    if PreLoadFunc then
    	PreLoadFunc( self, controller )
    end
    
    self.notificationList = {}
    self.messageQueue = {} 
    local maxSlots = 5
    local rowHeight = 25 

    self.ProcessQueue = function( self )
        if #self.notificationList < maxSlots and #self.messageQueue > 0 then
            local nextMessage = table.remove( self.messageQueue, 1 )
            self:CreateNotificationElement( nextMessage )
        end
    end

    self.CreateNotificationElement = function( self, message )
        local container = LUI.UIElement.new()
        local currentSlot = #self.notificationList
        
        container:setLeftRight( false, false, -140, 140 )
        container:setTopBottom( true, false, 200 + (currentSlot * rowHeight), 220 + (currentSlot * rowHeight) )
        self:addElement( container )

        local background = LUI.UIImage.new()
        background:setLeftRight( true, true, 0, 0 )
        background:setTopBottom( true, true, 0, 0 )
        background:setImage( RegisterImage( "$white" ) )
        background:setRGB( 0, 0, 0 )
        background:setAlpha( 0.5 )
        container:addElement( background )

        local glow = LUI.UIImage.new()
        glow:setLeftRight( true, true, -20, 20 )
        glow:setTopBottom( true, true, -10, 10 )
        glow:setImage( RegisterImage( "uie_t7_cp_hud_enemytarget_glow" ) )
        glow:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
        glow:setAlpha( 0.66 )
        container:addElement( glow )

        local text = LUI.UIText.new()
        text:setLeftRight( false, false, 0, 0 )
        text:setTopBottom( true, true, 0, 0 )
        text:setTTF( "fonts/default.ttf" )
        text:setText( message )
        container:addElement( text )

        local width = GetTextWidthManual( text, message )
        container:setLeftRight( false, false, -(width/2), (width/2) )
        
        container:setAlpha( 0 )
        container:beginAnimation( "fade_in", 500 )
        container:setAlpha( 1 )

        local ghostTimer = LUI.UIElement.new()
        container:addElement( ghostTimer )
        
        ghostTimer:beginAnimation( "wait_time", 3000 ) 
        ghostTimer:registerEventHandler( "transition_complete_wait_time", function( element, event )
            container:beginAnimation( "fade_out", 500 )
            container:setAlpha( 0 )
            
            container:registerEventHandler( "transition_complete_fade_out", function( container )
                for i, val in ipairs( self.notificationList ) do
                    if val == container then table.remove( self.notificationList, i ) break end
                end

                for i, remaining in ipairs( self.notificationList ) do
                    remaining:beginAnimation( "shift_up", 300 )
                    remaining:setTopBottom( true, false, 200 + ((i-1) * rowHeight), 220 + ((i-1) * rowHeight) )
                end

                container:close()
                self:ProcessQueue()
            end )
        end )

        table.insert( self.notificationList, container )
    end

    self.AddLuiNotificationToQueue = function( self, message )
        table.insert( self.messageQueue, message )
        self:ProcessQueue()
    end

    self:subscribeToGlobalModel( controller, "PerController", "luaprint", function( model )
        local message = Engine.GetModelValue( model )
        if message and message ~= "" then
            self:AddLuiNotificationToQueue( message )
        end
    end )

    if PostLoadFunc then
    	PostLoadFunc( self, controller )
    end

    return self
end