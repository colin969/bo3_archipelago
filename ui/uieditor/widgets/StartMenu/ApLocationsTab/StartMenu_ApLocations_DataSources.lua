local locations = require( "Archipelago.Locations" )

local function createLocationDataSource(name, prefix, startCode, endCode)
    return ListHelper_SetupDataSource(name, function(controller)
        local ApLocations = {}
        local prefixLength = string.len(prefix)
        
        for code = startCode, endCode do
            if Archi.LocationList[code] ~= nil then
                local location = locations.IDToLocation[code]
                if location then
                    local checked = Archi.LocationList[code] == true
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
        
        return ApLocations
    end, true)
end

DataSources.StartMenu_ApLocations_Zod = createLocationDataSource(
    "StartMenu_ApLocations_Zod", "(Shadows of Evil) ", 3100, 3999)

DataSources.StartMenu_ApLocations_Castle = createLocationDataSource(
    "StartMenu_ApLocations_Castle", "(Der Eisendrache) ", 2100, 2999)

DataSources.StartMenu_ApLocations_Island = createLocationDataSource(
    "StartMenu_ApLocations_Island", "(Zetsubou No Shima) ", 5100, 5999)

DataSources.StartMenu_ApLocations_Stalingrad = createLocationDataSource(
    "StartMenu_ApLocations_Stalingrad", "(Gorod Krovi) ", 4100, 4999)

DataSources.StartMenu_ApLocations_Genesis = createLocationDataSource(
    "StartMenu_ApLocations_Genesis", "(Revelations) ", 6100, 6999)

DataSources.StartMenu_ApLocations_TheGiant = createLocationDataSource(
    "StartMenu_ApLocations_TheGiant", "(The Giant) ", 1100, 1999)

DataSources.StartMenu_ApLocations_KinoDerToten = createLocationDataSource(
    "StartMenu_ApLocations_KinoDerToten", "(Kino der Toten) ", 11100, 11999)

DataSources.StartMenu_ApLocations_Moon = createLocationDataSource(
    "StartMenu_ApLocations_Moon", "(Moon) ", 12100, 12999)

DataSources.StartMenu_ApLocations_Origins = createLocationDataSource(
    "StartMenu_ApLocations_Origins", "(Origins) ", 13100, 13999)

DataSources.StartMenu_ApLocations_Wanted = createLocationDataSource(
    "StartMenu_ApLocations_Wanted", "(Wanted) ", 20100, 20999)