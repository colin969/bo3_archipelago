local locations = require( "Archipelago.Locations" )

DataSources.StartMenu_ApLocations_Zod = ListHelper_SetupDataSource( "StartMenu_ApLocations_Zod", function( controller )
    local ApLocations = {}

    for code = 3101, 3999 do
        local location = locations.IDToLocation[code]
        local checked = Archi.CheckedLocations[code] == true
        if location then
            if checked then
                location = "^2" .. location
            end
            table.insert( ApLocations, {
                models = { name = location, code = code }
            })
        end
    end

    return ApLocations
end, true )

DataSources.StartMenu_ApLocations_Castle = ListHelper_SetupDataSource( "StartMenu_ApLocations_Castle", function( controller )
    local ApLocations = {}

    for code = 2101, 2999 do
        local location = locations.IDToLocation[code]
        local checked = Archi.CheckedLocations[code] == true
        if location then
            if checked then
                location = "^2" .. location
            end
            table.insert( ApLocations, {
                models = { name = location, code = code }
            })
        end
    end

    return ApLocations
end, true )

DataSources.StartMenu_ApLocations_Island = ListHelper_SetupDataSource( "StartMenu_ApLocations_Island", function( controller )
    local ApLocations = {}

    for code = 5101, 5999 do
        local location = locations.IDToLocation[code]
        local checked = Archi.CheckedLocations[code] == true
        if location then
            if checked then
                location = "^2" .. location
            end
            table.insert( ApLocations, {
                models = { name = location, code = code }
            })
        end
    end

    return ApLocations
end, true )


DataSources.StartMenu_ApLocations_Stalingrad = ListHelper_SetupDataSource( "StartMenu_ApLocations_Stalingrad", function( controller )
    local ApLocations = {}

    for code = 4101, 4999 do
        local location = locations.IDToLocation[code]
        local checked = Archi.CheckedLocations[code] == true
        if location then
            if checked then
                location = "^2" .. location
            end
            table.insert( ApLocations, {
                models = { name = location, code = code }
            })
        end
    end

    return ApLocations
end, true )
