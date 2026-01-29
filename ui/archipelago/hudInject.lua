require( "ui.archipelago.ingame.widgets.ArchipelagoDisplay")
require( "ui.archipelago.ingame.widgets.ArchipelagoDisplayClient")
require( "ui.archipelago.ingame.widgets.ArchipelagoMessageContainer")

local hudList = {
    "T7Hud_zm_factory",
    "T7Hud_zm_castle",
    "T7Hud_zm_island",
    "T7Hud_zm_stalingrad",
    "T7Hud_zm_genesis",
    "T7Hud_zm_dlc5",
    "T7Hud_zm_tomb",
    "T7Hud_ZM",
}

for _, hudName in ipairs(hudList) do
    local CallOriginal = LUI.createMenu[hudName]
    if CallOriginal and type(CallOriginal) == "function" then
        LUI.createMenu[hudName] = function(controller)
            local self = CallOriginal(controller)

            -- The little beep booper
            local ArchiMessages = CoD.ArchipelagoMessageContainer.new(self, controller)
            self:addElement(ArchiMessages)

            -- Only run the server communication scripts on host
            local ArchiDisp
            if CoD.isHost() then
                ArchiDisp = CoD.ArchipelagoDisplay.new(self, controller)
            else
                ArchiDisp = CoD.ArchipelagoDisplayClient.new(self, controller)
            end
            self:addElement(ArchiDisp)

            LUI.OverrideFunction_CallOriginalSecond(self, "close", function(element)
            end)

            return self
        end
    end
end