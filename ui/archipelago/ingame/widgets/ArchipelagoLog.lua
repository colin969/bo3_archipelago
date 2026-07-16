require("Archipelago.Utils")

CoD.ArchipelagoLog = InheritFrom(LUI.UIElement)
CoD.ArchipelagoLog.new = function(menu, controller)
    local self = LUI.UIElement.new()
    self:setClass(CoD.ArchipelagoLog)
    self.id = "ArchipelagoLog"
    self.soundSet = "default"
    self:setLeftRight(true, true, 0, 0)
    self:setTopBottom(true, true, 0, 0)

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


    local MAX_LOGS = 8
    local LOG_HEIGHT = 20
    local TITLE_HEIGHT = 24
    local LEFT_MARGIN = 20
    local TOP_OFFSET = 400

    local newLogs = 0
    local logQueue = {}
    local logLabels = {}

    local LogTitle = LUI.UIText.new()
    LogTitle:setLeftRight(true, false, LEFT_MARGIN, LEFT_MARGIN + (1280 - LEFT_MARGIN))
    LogTitle:setTopBottom(true, false, TOP_OFFSET - TITLE_HEIGHT, TOP_OFFSET)
    LogTitle:setText("Archipelago Log")
    self:addElement(LogTitle)
    self.LogTitle = LogTitle

    for i = 1, MAX_LOGS do
        local label = LUI.UIText.new()
        local yTop = TOP_OFFSET + (i - 1) * LOG_HEIGHT
        local yBottom = yTop + LOG_HEIGHT
        label:setLeftRight(true, false, LEFT_MARGIN, LEFT_MARGIN + (1280 - LEFT_MARGIN))
        label:setTopBottom(true, false, yTop, yBottom)
        label:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
        label:setText("")
        self:addElement(label)
        logLabels[i] = label
    end

    local function refreshDisplay()
        local qLen = #logQueue
        for i = 1, MAX_LOGS do
            local qIndex = qLen - (MAX_LOGS - i)
            if qIndex >= 1 and logQueue[qIndex] then
                logLabels[i]:setText(logQueue[qIndex])
            else
                logLabels[i]:setText("")
            end
        end
    end

    local UIRootFull = LUI.roots.UIRootFull;
    UIRootFull.HUDRefreshTimer = LUI.UITimer.newElementTimer(500, false, function()
        if newLogs == 1 then
            refreshDisplay()
            newLogs = 0
        end
    end)
    UIRootFull:addElement(UIRootFull.HUDRefreshTimer)

    local function pushLog(str)
        table.insert(logQueue, str)
        if #logQueue > MAX_LOGS then
            table.remove(logQueue, 1)
        end
        -- Allow refresher to know to update
        newLogs = 1
    end

    if Archi then
        Archi.RegisterLogFunc(pushLog)
    end

    LUI.OverrideFunction_CallOriginalSecond(self, "close", function(element)
        for i = 1, MAX_LOGS do
            logLabels[i]:close()
        end
        if Archi then
            Archi.UnregisterLogFunc()
        end
        self.LogTitle:close()
    end)

    return self
end
