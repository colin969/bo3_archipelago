function load_settings()
    local f = require("io").open("archipelago.json", "r")
    if f then
        local content = f:read("*all")
        f:close()

        local json = require("Archipelago.Json")
        local settings = json.decode(content)
        if settings then
            local server = settings.server or "archipelago.gg"
            local slot = settings.slot or "Player"
            
            return server, slot
        end 
    end

	return "archipelago.gg", "Player"
end

function save_settings(server, slot)
	local json = require("Archipelago.Json")
	
	local settings = {
		server = server or "archipelago.gg",
		slot = slot or "Player"
	}
	
	local content = json.encode(settings)
	
	local f = require("io").open("archipelago.json", "w")
	if f then
		f:write(content)
		f:close()
		
		return true
	end
	
	return false
end

return {
	load_settings = load_settings,
	save_settings = save_settings,
}