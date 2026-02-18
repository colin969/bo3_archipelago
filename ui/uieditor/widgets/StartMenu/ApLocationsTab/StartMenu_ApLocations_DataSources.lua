local locations = require( "Archipelago.Locations" )

DataSources.StartMenu_ApLocations_Zod = ListHelper_SetupDataSource( "StartMenu_ApLocations_Zod", function( controller )
    local ApLocations = {}
    local prefixLength = string.len("(Shadows of Evil) ")

    for code = 3100, 3999 do
        local location = locations.IDToLocation[code]
        local checked = Archi.CheckedLocations[code] == true
        if location then
            local trimmedLocation = string.sub(location, prefixLength + 1)
            if checked then
                trimmedLocation = "^2" .. trimmedLocation
            end
            table.insert( ApLocations, {
                models = { name = trimmedLocation, code = code }
            })
        end
    end

    return ApLocations
end, true )

DataSources.StartMenu_ApLocations_Castle = ListHelper_SetupDataSource( "StartMenu_ApLocations_Castle", function( controller )
    local ApLocations = {}
    local prefixLength = string.len("(Castle) ")

    local bow_ranges = {
        storm = {2500, 2509},
        wolf = {2510, 2519},
        fire = {2520, 2529},
        void = {2530, 2539},
    }

    local rolled_bows = {}
    local i = 0
    while true do
        dvar_value = Engine.DvarString(nil,"ARCHIPELAGO_ROLLED_BOW_" .. i)
        if not dvar_value or dvar_value == "" then
            break
        end
        rolled_bows[dvar_value] = true
        i = i + 1
    end

    local function is_rolled_bow_location(code)
        for bow_name, range in pairs(bow_ranges) do
            if code >= range[1] and code <= range[2] then
                return rolled_bows[bow_name] == true
            end
        end
    end

    for code = 2100, 2499 do
        local location = locations.IDToLocation[code]
        local checked = Archi.CheckedLocations[code] == true
        if location then
            local trimmedLocation = string.sub(location, prefixLength + 1)
            if checked then
                trimmedLocation = "^2" .. trimmedLocation
            end
            table.insert( ApLocations, {
                models = { name = trimmedLocation, code = code }
            })
        end
    end

    for code = 2500, 2539 do
        if is_rolled_bow_location(code) then
            local location = locations.IDToLocation[code]
            if location then
                local checked = Archi.CheckedLocations[code] == true
                local trimmedLocation = string.sub(location, prefixLength + 1)
                if checked then
                    trimmedLocation = "^2" .. trimmedLocation
                end
                table.insert(ApLocations, {
                    models = { name = trimmedLocation, code = code }
                })
            end
        end
    end

    for code = 2600, 2999 do
        local location = locations.IDToLocation[code]
        local checked = Archi.CheckedLocations[code] == true
        if location then
            local trimmedLocation = string.sub(location, prefixLength + 1)
            if checked then
                trimmedLocation = "^2" .. trimmedLocation
            end
            table.insert( ApLocations, {
                models = { name = trimmedLocation, code = code }
            })
        end
    end

    return ApLocations
end, true )

DataSources.StartMenu_ApLocations_Island = ListHelper_SetupDataSource( "StartMenu_ApLocations_Island", function( controller )
    local ApLocations = {}
    local prefixLength = string.len("(Zetsubou No Shima) ")

    for code = 5100, 5999 do
        local location = locations.IDToLocation[code]
        local checked = Archi.CheckedLocations[code] == true
        if location then
            local trimmedLocation = string.sub(location, prefixLength + 1)
            if checked then
                trimmedLocation = "^2" .. trimmedLocation
            end
            table.insert( ApLocations, {
                models = { name = trimmedLocation, code = code }
            })
        end
    end

    return ApLocations
end, true )

DataSources.StartMenu_ApLocations_Stalingrad = ListHelper_SetupDataSource( "StartMenu_ApLocations_Stalingrad", function( controller )
    local ApLocations = {}
    local prefixLength = string.len("(Gorod Krovi) ")

    for code = 4100, 4999 do
        local location = locations.IDToLocation[code]
        local checked = Archi.CheckedLocations[code] == true
        if location then
            local trimmedLocation = string.sub(location, prefixLength + 1)
            if checked then
                trimmedLocation = "^2" .. trimmedLocation
            end
            table.insert( ApLocations, {
                models = { name = trimmedLocation, code = code }
            })
        end
    end

    return ApLocations
end, true )

DataSources.StartMenu_ApLocations_Genesis = ListHelper_SetupDataSource( "StartMenu_ApLocations_Genesis", function( controller )
    local ApLocations = {}
    local prefixLength = string.len("(Revelations) ")

    for code = 6100, 6999 do
        local location = locations.IDToLocation[code]
        local checked = Archi.CheckedLocations[code] == true
        if location then
            local trimmedLocation = string.sub(location, prefixLength + 1)
            if checked then
                trimmedLocation = "^2" .. trimmedLocation
            end
            table.insert( ApLocations, {
                models = { name = trimmedLocation, code = code }
            })
        end
    end

    return ApLocations
end, true )
