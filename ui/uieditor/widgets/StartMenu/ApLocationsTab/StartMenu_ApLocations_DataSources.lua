local locations = require( "Archipelago.Locations" )

DataSources.StartMenu_ApLocations_Zod = ListHelper_SetupDataSource( "StartMenu_ApLocations_Zod", function( controller )
    local ApLocations = {}

    for code = 3101, 3999 do
        local location = locations.IDToLocation[code]
        if location then
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
        if location then
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
        if location then
            table.insert( ApLocations, {
                models = { name = location, code = code }
            })
        end
    end

    return ApLocations
end, true )