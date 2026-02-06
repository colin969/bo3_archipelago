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

    for code = 2100, 2999 do
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
