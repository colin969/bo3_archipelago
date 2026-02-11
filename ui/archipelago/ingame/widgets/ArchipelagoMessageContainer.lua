require("Archipelago.Utils")

CoD.ArchipelagoMessageContainer = InheritFrom( LUI.UIElement )
CoD.ArchipelagoMessageContainer.MessagesQueue = List.new()
CoD.ArchipelagoMessageContainer.new = function (menu, controller)
    local self = LUI.UIElement.new()

    self:setClass(CoD.ArchipelagoMessageContainer)
    self.id = "ArchipelagoMessageContainer"
    self.soundSet = "default"
    self:setLeftRight(true, true, 0, 0)
    self:setTopBottom(true, true, 0, 0)

    --AP Get Image
    
    local ApGetImage = LUI.UIImage.new()
    ApGetImage:setLeftRight(true, false, 30, 70)
    ApGetImage:setTopBottom(true, false, 30, 78)
    ApGetImage:setImage(RegisterImage("archipelago_logo_down"))
    ApGetImage:setAlpha(0)
    self:addElement(ApGetImage)
    self.ApGetImage = ApGetImage

    local ApGetTextSender = LUI.UIText.new()
    ApGetTextSender:setLeftRight(true, true, 95, 85)
    ApGetTextSender:setTopBottom(true, false, 30, 46)
    ApGetTextSender:setAlpha(0)
    ApGetTextSender:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
    ApGetTextSender:setText("TEST VALUE LONG STRING YUPPERS")
    self:addElement(ApGetTextSender)
    self.ApGetTextSender = ApGetTextSender

    local ApGetText = LUI.UIText.new()
    ApGetText:setLeftRight(true, true, 85, 85)
    ApGetText:setTopBottom(true, false, 48, 78)
    ApGetText:setAlpha(0)
    ApGetText:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
    ApGetText:setText("TEST VALUE LONG STRING YUPPERS")
    self:addElement(ApGetText)
    self.ApGetText = ApGetText

    --AP Send Image
    
    local ApSendImage = LUI.UIImage.new()
    ApSendImage:setLeftRight(true, false, 30, 70)
    ApSendImage:setTopBottom(true, false, 93, 133)
    ApSendImage:setImage(RegisterImage("archipelago_logo_up"))
    ApSendImage:setAlpha(0)
    self:addElement(ApSendImage)
    self.ApSendImage = ApSendImage

    local ApSendText = LUI.UIText.new()
    ApSendText:setLeftRight(true, true, 85, 85)
    ApSendText:setTopBottom(true, false, 103, 133)
    ApSendText:setAlpha(0)
    ApSendText:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
    ApSendText:setText("TEST VALUE LONG STRING YUPPERS")
    self:addElement(ApSendText)
    self.ApSendText = ApSendText

    local FlashNotif = function(Element, Event)
      Element:setAlpha(1)
      Element:beginAnimation("keyframe", 4000, false, false, CoD.TweenType.Linear)
      Element:setAlpha(0)
      Element:registerEventHandler("transition_complete_keyframe", nil)
    end

    local FlashNotifWrap = function(event, networkItem)
      if event == "GET" then
        self.ApGetText:setText( Engine.Localize(networkItem.name) )
        self.ApGetTextSender:setText( Engine.Localize(networkItem.location .. " in " .. networkItem.sender .. "'s world") )
        FlashNotif(self.ApGetImage,{})
        FlashNotif(self.ApGetText,{})
        FlashNotif(self.ApGetTextSender,{})
      else
        self.ApSendText:setText( Engine.Localize(networkItem.location) )
        FlashNotif(self.ApSendImage,{})
        FlashNotif(self.ApSendText,{})
      end
    end

    if Archi then
      Archi.RegisterNotifyFunc(FlashNotifWrap)
    end
    
    --Close callback (Close all the children stuff)
    LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
        element.ApGetImage:close()
        element.ApGetText:close()
        element.ApGetTextSender:close()
        element.ApSendImage:close()
        element.ApSendText:close()
        if Archi then
          Archi.UnregisterNotifyFunc()
        end
	  end )

    return self
end

