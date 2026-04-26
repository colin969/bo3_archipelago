require("ui.t6.lobby.lobbymenubuttons_og")
require("ui.archipelago.frontend.ArchipelagoSettings")

require( "lua.Shared.LobbyData" )
require( "ui_mp.T6.Menus.CACUtility" )

Engine.GetRank = function()
    return 1000
end

Engine.GetRankDisplayLevel = function()
	local roll = math.random()
	if roll > 0.99 then
		return 67
	elseif roll > 0.98 then
		return 69
	elseif roll > 0.97 then
		return 420
	end
    return 1
end

Engine.IsItemLocked = function()
    return false
end

Engine.IsItemLockedForAll = function()
    return false
end

Engine.IsItemLockedForRank = function()
    return false
end

CoD.LobbyButtons.ZM_AP_BUTTON =
{
	stringRef = "ARCHIPELAGO",
	action =
	function(arg0, arg1, arg2, arg3, arg4)
		CoD.LobbyBase.SetLeaderActivity(arg2, CoD.LobbyBase.LeaderActivity.EDITING_GAME_RULES)
		LUI.OverrideFunction_CallOriginalFirst(OpenOverlay(arg0, "ArchipelagoSettings", arg2), "close",
		function()
			CoD.LobbyBase.ResetLeaderActivity(arg2)
		end)
	end,
	customId = "btnArchipelago",
	starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
}

CoD.LobbyButtons.AP_ZM_START_LAN_GAME = 
{
	stringRef = "MENU_START_GAME_CAPS",
	action = LobbyLANLaunchGame,
	customId = "btnStartLanGame",
	disabledFunc = MapVoteTimerActive,
	starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
}

APStartButtonDisabled = function()
	if MapVoteTimerActive() then
		return true
	end
	--TODO: enable this once i figure out how to re-run this check.
	-- local APStatus = Engine.DvarString(nil,"ARCHIPELAGO_CONNECTION_VALIDATED")
	-- Console.Print("Test")
	-- Console.Print(APStatus)
	-- if APStatus ~= "Connection: Validated" then
	-- 	return true
	-- end
	-- return false
end
	
CoD.LobbyButtons.ZM_BUILD_KITS = {
	stringRef = "MENU_WEAPON_BUILD_KITS_CAPS",
	action = OpenWeaponBuildKits,
	customId = "btnWeaponBuildKits",
	newBreadcrumbFunc = Gunsmith_AnyNewWeaponsOrAttachments,
	starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
}

CoD.LobbyButtons.ZM_ARCHIPELAGO = {
	stringRef = "JOIN ARCHIPELAGO",
	action =
	function(self, element, controller, param, menu)
		CoD.LobbyBase.SetLeaderActivity(controller, CoD.LobbyBase.LeaderActivity.EDITING_GAME_RULES)
		LUI.OverrideFunction_CallOriginalFirst(OpenOverlay(self, "ArchipelagoSettings", controller), "close",
		function()
			CoD.LobbyBase.ResetLeaderActivity(controller)
			if ApIsConnected == true then
				NavigateToLobby( menu, "ZMLobbyOnline", false, controller )
			end
		end)
	end,
	customId = "btnZM_ARCHIPELAGO",
	starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
}

CoD.LobbyButtons.ZM_ARCHIPELAGO_LAN = {
	stringRef = "JOIN ARCHIPELAGO",
	action =
	function(self, element, controller, param, menu)
		CoD.LobbyBase.SetLeaderActivity(controller, CoD.LobbyBase.LeaderActivity.EDITING_GAME_RULES)
		LUI.OverrideFunction_CallOriginalFirst(OpenOverlay(self, "ArchipelagoSettings", controller), "close",
		function()
			CoD.LobbyBase.ResetLeaderActivity(controller)
			if ApIsConnected == true then
				NavigateToLobby( menu, "ZMLobbyLANGame", false, controller )
			end
		end)
	end,
	customId = "btnZM_ARCHIPELAGO_LAN",
	starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
}