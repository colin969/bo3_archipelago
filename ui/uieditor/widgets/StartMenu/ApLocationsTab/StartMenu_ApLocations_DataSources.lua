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
    local prefixLength = string.len("(Der Eisendrache) ")

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

    local mask_ranges = {
        wolf = {6600, 6609},
        siegfried = {6610, 6619},
        king = {6620, 6629},
        fury = {6630, 6639},
        keeper = {6640, 6649},
        margwa = {6650, 6659},
        apothigod = {6660, 6669},
    }

    local rolled_masks = {}
    i = 0
    while true do
        dvar_value = Engine.DvarString(nil,"ARCHIPELAGO_ROLLED_MASK_" .. i)
        if not dvar_value or dvar_value == "" then
            break
        end
        rolled_masks[dvar_value] = true
        i = i + 1
    end

    local function is_rolled_mask_location(code)
        for mask_name, range in pairs(mask_ranges) do
            if code >= range[1] and code <= range[2] then
                return rolled_masks[mask_name] == true
            end
        end
    end

    for code = 6100, 6599 do
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

    for code = 6600, 6699 do
        if is_rolled_mask_location(code) then
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

    for code = 6700, 6999 do
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

DataSources.StartMenu_ApLocations_TheGiant = ListHelper_SetupDataSource( "StartMenu_ApLocations_TheGiant", function( controller )
    local ApLocations = {}
    local prefixLength = string.len("(The Giant) ")

    for code = 1100, 1999 do
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

DataSources.StartMenu_ApLocations_KinoDerToten = ListHelper_SetupDataSource( "StartMenu_ApLocations_KinoDerToten", function( controller )
    local ApLocations = {}
    local prefixLength = string.len("(Kino der Toten) ")

    for code = 11100, 11999 do
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

DataSources.StartMenu_ApLocations_Wanted = ListHelper_SetupDataSource( "StartMenu_ApLocations_Wanted", function( controller )
    local ApLocations = {}
    local prefixLength = string.len("(Wanted) ")

    for code = 20100, 20999 do
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