
local w, h = GetActiveScreenResolution()
local flattire = false
local compass = {
    ticksBetweenCardinals = 9.0, -- Ara Çizgiler
    tickColour = {r = 255, g = 255, b = 255, a = 255},
    tickSize = {w = 0.0006, h = 0.003},
    cardinal = {
        textSize = 0.40,
        textOffset = -0.014 ,
        textColour = {255, 255, 255, 255},
        tickSize = {w = 0.013, h = 0.022 },
        tickColour = {r = 0, g = 0, b = 0, a = 100},
    },
    intercardinal = {
        textSize = 0.26,
        textOffset = -0.013,
        textColour = {255, 255, 255, 255},
        tickSize = {w = 0.0005, h = 0.005},
        tickColour = {r = 255, g = 255, b = 255, a = 255},
    }
}

-- SPEEDOMETER PARAMETERS
local speedColorText = {255, 255, 255}      -- Color used to display speed label text
local speedColorUnder = {255, 255, 255}     -- Color used to display speed when under speedLimit
local speedColorOver = {255, 96, 96}        -- Color used to display speed when over speedLimit

-- FUEL PARAMETERS
local fuelColorText = {255, 255, 255}       -- Color used to display fuel text
local seatbeltColorOn = {160, 255, 160}     -- Color used when seatbelt is on
local seatbeltColorOff = {255, 96, 96}      -- Color used when seatbelt is off

-- CRUISE CONTROL PARAMETERS
local cruiseColorOn = {160, 255, 160}       -- Color used when seatbelt is on
local cruiseColorOff = {255, 255, 255}      -- Color used when seatbelt is off
local vehIsMovingFwd = 0

-- LOCATION AND TIME PARAMETERS
local locationColorText = {255, 255, 255}   -- Color used to display location and time
local zones = { ['AIRP'] = "Los Santos International Airport", ['ALAMO'] = "Alamo Sea", ['ALTA'] = "Alta", ['ARMYB'] = "Fort Zancudo", ['BANHAMC'] = "Banham Canyon Dr", ['BANNING'] = "Banning", ['BEACH'] = "Vespucci Beach", ['BHAMCA'] = "Banham Canyon", ['BRADP'] = "Braddock Pass", ['BRADT'] = "Braddock Tunnel", ['BURTON'] = "Burton", ['CALAFB'] = "Calafia Bridge", ['CANNY'] = "Raton Canyon", ['CCREAK'] = "Cassidy Creek", ['CHAMH'] = "Chamberlain Hills", ['CHIL'] = "Vinewood Hills", ['CHU'] = "Chumash", ['CMSW'] = "Chiliad Mountain State Wilderness", ['CYPRE'] = "Cypress Flats", ['DAVIS'] = "Davis", ['DELBE'] = "Del Perro Beach", ['DELPE'] = "Del Perro", ['DELSOL'] = "La Puerta", ['DESRT'] = "Grand Senora Desert", ['DOWNT'] = "Downtown", ['DTVINE'] = "Downtown Vinewood", ['EAST_V'] = "East Vinewood", ['EBURO'] = "El Burro Heights", ['ELGORL'] = "El Gordo Lighthouse", ['ELYSIAN'] = "Elysian Island", ['GALFISH'] = "Galilee", ['GOLF'] = "GWC and Golfing Society", ['GRAPES'] = "Grapeseed", ['GREATC'] = "Great Chaparral", ['HARMO'] = "Harmony", ['HAWICK'] = "Hawick", ['HORS'] = "Vinewood Racetrack", ['HUMLAB'] = "Humane Labs and Research", ['JAIL'] = "Bolingbroke Penitentiary", ['KOREAT'] = "Little Seoul", ['LACT'] = "Land Act Reservoir", ['LAGO'] = "Lago Zancudo", ['LDAM'] = "Land Act Dam", ['LEGSQU'] = "Legion Square", ['LMESA'] = "La Mesa", ['LOSPUER'] = "La Puerta", ['MIRR'] = "Mirror Park", ['MORN'] = "Morningwood", ['MOVIE'] = "Richards Majestic", ['MTCHIL'] = "Mount Chiliad", ['MTGORDO'] = "Mount Gordo", ['MTJOSE'] = "Mount Josiah", ['MURRI'] = "Murrieta Heights", ['NCHU'] = "North Chumash", ['NOOSE'] = "N.O.O.S.E", ['OCEANA'] = "Pacific Ocean", ['PALCOV'] = "Paleto Cove", ['PALETO'] = "Paleto Bay", ['PALFOR'] = "Paleto Forest", ['PALHIGH'] = "Palomino Highlands", ['PALMPOW'] = "Palmer-Taylor Power Station", ['PBLUFF'] = "Pacific Bluffs", ['PBOX'] = "Pillbox Hill", ['PROCOB'] = "Procopio Beach", ['RANCHO'] = "Rancho", ['RGLEN'] = "Richman Glen", ['RICHM'] = "Richman", ['ROCKF'] = "Rockford Hills", ['RTRAK'] = "Redwood Lights Track", ['SANAND'] = "San Andreas", ['SANCHIA'] = "San Chianski Mountain Range", ['SANDY'] = "Sandy Shores", ['SKID'] = "Mission Row", ['SLAB'] = "Stab City", ['STAD'] = "Maze Bank Arena", ['STRAW'] = "Strawberry", ['TATAMO'] = "Tataviam Mountains", ['TERMINA'] = "Terminal", ['TEXTI'] = "Textile City", ['TONGVAH'] = "Tongva Hills", ['TONGVAV'] = "Tongva Valley", ['VCANA'] = "Vespucci Canals", ['VESP'] = "Vespucci", ['VINE'] = "Vinewood", ['WINDF'] = "Ron Alternates Wind Farm", ['WVINE'] = "West Vinewood", ['ZANCUDO'] = "Zancudo River", ['ZP_ORT'] = "Port of South Los Santos", ['ZQ_UAR'] = "Davis Quartz" }

-- Globals
local PlayerPed = nil
local pedInVeh = false
local timeText = ""
local locationText = ""
local currentFuel = 0.0
local currSpeed = 0.0
local cruiseSpeed = 999.0
local prevVelocity = {x = 0.0, y = 0.0, z = 0.0}
local cruiseIsOn = false
local seatbeltIsOn = false
local zorlaMaxHizSiniri = {}
local zorlaHizSabitle = {}

RegisterCommand("cruise", function(source, args)
    local vehicle = GetVehiclePedIsIn(PlayerPed, false)
    if (GetPedInVehicleSeat(vehicle, -1) == PlayerPed) and tonumber(args[1]) > 0 and not zorlaHizSabitle[vehicle] then
        if not IsVehicleTyreBurst(vehicle, 0) and not IsVehicleTyreBurst(vehicle, 1) and not IsVehicleTyreBurst(vehicle, 4) and not IsVehicleTyreBurst(vehicle, 5) then 
            cruiseIsOn = true
            cruiseSpeed = tonumber(args[1]) / speedToKmOrMph
        end
    end
end)

RegisterNetEvent("tgiann-carhud:eject-other-player-car-client")
AddEventHandler("tgiann-carhud:eject-other-player-car-client", function(velocity)
    local position = GetEntityCoords(PlayerPed)
    SetEntityCoords(PlayerPed, position.x, position.y, position.z - 0.47, true, true, true)
    SetEntityVelocity(PlayerPed, velocity.x, velocity.y, velocity.z)
    Citizen.Wait(1)
    SetPedToRagdoll(PlayerPed, 1000, 1000, 0, 0, 0, 0)
    Citizen.Wait(1000)
    if math.random(1, 3) == 1 then SetEntityHealth(PlayerPed, 0) end
    pedInVeh = false
    cruiseIsOn = false
    seatbeltIsOn = false
    EnableControlAction(0, 75)
end)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/hizsabitle', 'Aracın Hızını Sabitle.', {{ name="Sabitlenecek Hız", help="Aracın Hızını Sabitlemek İçin Bir Değer Girin"}})
    if TGIANN.useKm then speedToKmOrMph = 3.6 else speedToKmOrMph = 2.236936 end
    if TGIANN.seatbeltPlayAlarmSound then
        while true do
            Citizen.Wait(1000)
            local vehicle = GetVehiclePedIsIn(PlayerPed, false)
            if vehIsMovingFwd and not seatbeltIsOn and GetPedInVehicleSeat(vehicle, -1) == PlayerPed and GetIsVehicleEngineRunning(vehicle) and GetVehicleClass(vehicle) ~= 13 and GetVehicleClass(vehicle) ~= 8 and GetVehicleClass(vehicle) ~= 21 and GetVehicleClass(vehicle) ~= 14 and GetVehicleClass(vehicle) ~= 16 and GetVehicleClass(vehicle) ~= 15 then
                TriggerEvent('InteractSound_CL:PlayOnOne', 'alarm', 0.5)
                Citizen.Wait(3000)
            end
        end
    end
end)

-- Main thread
Citizen.CreateThread(function()
    if w == 1920 and h == 1080 then
        screenPosX = 0.165                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882                    -- Y coordinate (top left corner of HUD)
    elseif w == 1680 and h == 1050 then
        screenPosX = 0.195                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882                    -- Y coordinate (top left corner of HUD)
    elseif w == 1600 and h == 1200 then
        screenPosX = 0.190                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882                    -- Y coordinate (top left corner of HUD)
    elseif w == 1600 and h == 1024 then
        screenPosX = 0.190                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882 
    elseif w == 1600 and h == 900 then
        screenPosX = 0.190                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882 
    elseif w == 1440 and h == 900 then
        screenPosX = 0.190                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882                    -- Y coordinate (top left corner of HUD)
    elseif w == 1366 and h == 768 then
        screenPosX = 0.175                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882                    -- Y coordinate (top left corner of HUD)
    elseif w == 1360 and h == 768 then
        screenPosX = 0.170                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882                    -- Y coordinate (top left corner of HUD)
    elseif w == 1280 and h == 1024 then
        screenPosX = 0.240                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882                    -- Y coordinate (top left corner of HUD)
    elseif w == 1280 and h == 960 then
        screenPosX = 0.220                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882                    -- Y coordinate (top left corner of HUD)
    elseif w == 1280 and h == 800 then
        screenPosX = 0.190                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882                    -- Y coordinate (top left corner of HUD)
    elseif w == 1280 and h == 768 then
        screenPosX = 0.185                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882                    -- Y coordinate (top left corner of HUD)
    elseif w == 1280 and h == 720 or w == 1176 and h == 664 then
        screenPosX = 0.175                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882                    -- Y coordinate (top left corner of HUD)
    elseif w == 1152 and h == 864 or w == 1024 and h == 768  then
        screenPosX = 0.215                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882                    -- Y coordinate (top left corner of HUD)
    elseif w == 800 and h == 600 then
        screenPosX = 0.220                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.852      
    else
        screenPosX = 0.165                    -- X coordinate (top left corner of HUD)
        screenPosY = 0.882                    -- Y coordinate (top left corner of HUD) 
    end  

    while true do
        Citizen.Wait(1)
        PlayerPed = PlayerPedId()
        local position = GetEntityCoords(PlayerPed)
        local vehicle = GetVehiclePedIsIn(PlayerPed, false)
        -- Set vehicle states
        if IsPedInAnyVehicle(PlayerPed, false) then
            pedInVeh = true
        else
            pedInVeh = false
            cruiseIsOn = false
            seatbeltIsOn = false
        end

        -- Get time and display
        local pxDegree = 0.06 / 180
        local playerHeadingDegrees = 0
        local playerHeadingDegrees = 360.0 - GetEntityHeading(PlayerPed)
        local tickDegree = playerHeadingDegrees - 180 / 2
        local tickDegreeRemainder = compass.ticksBetweenCardinals - (tickDegree % compass.ticksBetweenCardinals)
        local tickPosition = screenPosX + 0.005 + tickDegreeRemainder * pxDegree
        tickDegree = tickDegree + tickDegreeRemainder
        --[[
        Draw2DText(.5, .3, "~r~The tickDegree is: ~b~" .. tostring(tickDegree), 1.0, 1);
        Draw2DText(.5, .5, "~r~The tickDegree % 90.0 is: ~b~" .. tostring((tickDegree % 90)), 1.0, 1);
        Draw2DText(.5, .7, "~r~The tickDegree % 45.0 is: ~b~" .. tostring((tickDegree % 45)), 1.0, 1);
        ]]--

        while tickPosition < screenPosX + 0.0325 do
            if (tickDegree % 90.0) == 0 then
                -- OLD:
                --DrawRect(tickPosition + TGIANN.positionx, screenPosY + 0.095 + TGIANN.positiony, compass.cardinal.tickSize.w, compass.cardinal.tickSize.h, compass.cardinal.tickColour.r, compass.cardinal.tickColour.g, compass.cardinal.tickColour.b, compass.cardinal.tickColour.a )
                --drawText(degreesToIntercardinalDirection(tickDegree), 4, compass.cardinal.textColour, 0.4, tickPosition, screenPosY + 0.095 + compass.cardinal.textOffset, true, true)
            
                DrawRect(tickPosition + TGIANN.positionx, screenPosY + 0.1025 + TGIANN.positiony, compass.intercardinal.tickSize.w, compass.intercardinal.tickSize.h, compass.intercardinal.tickColour.r, compass.intercardinal.tickColour.g, compass.intercardinal.tickColour.b, compass.intercardinal.tickColour.a )
                drawText(degreesToIntercardinalDirection(tickDegree), 4, compass.cardinal.textColour, 0.26, tickPosition, screenPosY + 0.095 + compass.intercardinal.textOffset, true, true)
            elseif (tickDegree % 45.0) == 0 then
                -- OLD:
                --DrawRect(tickPosition + TGIANN.positionx, screenPosY + 0.1025 + TGIANN.positiony, compass.intercardinal.tickSize.w, compass.intercardinal.tickSize.h, compass.intercardinal.tickColour.r, compass.intercardinal.tickColour.g, compass.intercardinal.tickColour.b, compass.intercardinal.tickColour.a )
                --drawText(degreesToIntercardinalDirection(tickDegree), 4, compass.cardinal.textColour, 0.26, tickPosition, screenPosY + 0.095 + compass.intercardinal.textOffset, true, true)
                
                DrawRect(tickPosition + TGIANN.positionx, screenPosY + 0.095 + TGIANN.positiony, compass.cardinal.tickSize.w, compass.cardinal.tickSize.h, compass.cardinal.tickColour.r, compass.cardinal.tickColour.g, compass.cardinal.tickColour.b, compass.cardinal.tickColour.a )
                drawText(degreesToIntercardinalDirection(tickDegree), 4, compass.cardinal.textColour, 0.4, tickPosition, screenPosY + 0.095 + compass.cardinal.textOffset, true, true)
            elseif  (tickDegree % 90.0) == 81.0 or (tickDegree % 90.0) == 72.0 or (tickDegree % 90.0) == 9.0 or (tickDegree % 90.0) == 18.0 then
                DrawRect(tickPosition + TGIANN.positionx, screenPosY + 0.104 + TGIANN.positiony, compass.tickSize.w, compass.tickSize.h, compass.tickColour.r, compass.tickColour.g, compass.tickColour.b, compass.tickColour.a )
            end

            tickDegree = tickDegree + compass.ticksBetweenCardinals
            tickPosition = tickPosition + pxDegree * compass.ticksBetweenCardinals        
        end
           
        if pedInVeh then
            drawText(locationText, 4, locationColorText, 0.36, screenPosX + 0.040, screenPosY + 0.0823, true)
        
            -- Display remainder of HUD when engine is on and vehicle is not a bicycle
            local vehicleClass = GetVehicleClass(vehicle)
            local keepDoorOpen = true
            if pedInVeh and GetIsVehicleEngineRunning(vehicle) and vehicleClass ~= 13 then
                local prevSpeed = currSpeed
                currSpeed = GetEntitySpeed(vehicle)
                local vehIsMovingFwd = GetEntitySpeedVector(vehicle, true).y > 1.0
                local vehAcc = (prevSpeed - currSpeed) / GetFrameTime()

                SetPedConfigFlag(PlayerPed, 32, true)
                
                if IsControlJustReleased(0, TGIANN.seatbeltInput) and vehicleClass ~= 8 then
                    seatbeltIsOn = not seatbeltIsOn
                    if TGIANN.seatbeltPlaySound then
                        if seatbeltIsOn then
                            TriggerEvent('InteractSound_CL:PlayOnOne', 'tak', 0.5)
                            PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1)
                        else
                            PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1)
                            TriggerEvent('InteractSound_CL:PlayOnOne', 'cikar', 0.5)
                        end
                    end
                end

                if not seatbeltIsOn then
                    if vehIsMovingFwd and (prevSpeed > TGIANN.seatbeltEjectSpeed/2.237) and vehAcc > 981 then
                        SetEntityCoords(PlayerPed, position.x, position.y, position.z - 0.47, true, true, true)
                        SetEntityVelocity(PlayerPed, prevVelocity.x, prevVelocity.y, prevVelocity.z)
                        Citizen.Wait(1)
                        SetPedToRagdoll(PlayerPed, 1000, 1000, 0, 0, 0, 0)
                    else
                        prevVelocity = GetEntityVelocity(vehicle)
                    end
                end

                if TGIANN.seatbeltDisableExit and seatbeltIsOn then DisableControlAction(0, 75) end
			  
                -- When player in driver seat, handle cruise control
                if (GetPedInVehicleSeat(vehicle, -1) == PlayerPed) then
                    if IsControlJustReleased(0, TGIANN.cruiseInput) then
                        cruiseIsOn = not cruiseIsOn
                        cruiseSpeed = currSpeed
                    end

                    local flatTireSeatbeltEjectSpeed = 10.0
                    local maxSpeed = cruiseIsOn and cruiseSpeed or flattire and flatTireSeatbeltEjectSpeed or zorlaHizSabitle[vehicle] and zorlaMaxHizSiniri[vehicle] or GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel")
                    SetEntityMaxSpeed(vehicle, maxSpeed)
                else
                    cruiseIsOn = false
                end

                if GetPedInVehicleSeat(vehicle, -1) == PlayerPed and GetIsVehicleEngineRunning(vehicle) then
                    if vehIsMovingFwd and (prevSpeed > TGIANN.crashSeatbeltEjectSpeed/speedToKmOrMph) and vehAcc > 784.8 then
                        SetVehicleEngineHealth(vehicle, 10.0)

                        local seatPlayerId = {}
                        for i=1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) do
                            if i ~= 1 then
                                if not IsVehicleSeatFree(vehicle, i-2) then 
                                    local otherPlayerId = GetPedInVehicleSeat(vehicle, i-2) 
                                    local playerHandle = NetworkGetPlayerIndexFromPed(otherPlayerId)
                                    local playerServerId = GetPlayerServerId(playerHandle)
                                    table.insert(seatPlayerId, playerServerId)
                                end
                            end
                        end
                        
                        if #seatPlayerId > 0 then TriggerServerEvent("tgiann-carhud:eject-other-player-car", seatPlayerId, prevVelocity) end

                        SetEntityCoords(PlayerPed, position.x, position.y, position.z - 0.47, true, true, true)
                        SetEntityVelocity(PlayerPed, prevVelocity.x, prevVelocity.y, prevVelocity.z)
                        Citizen.Wait(1)
                        SetPedToRagdoll(PlayerPed, 1000, 1000, 0, 0, 0, 0)
                        Citizen.Wait(1000)
                        if math.random(1, 3) == 1 then SetEntityHealth(PlayerPed, 0) end
                        pedInVeh = false
                        cruiseIsOn = false
                        seatbeltIsOn = false
                        EnableControlAction(0, 75)
                    else
                        prevVelocity = GetEntityVelocity(vehicle)
                    end
                end

                if GetPedInVehicleSeat(vehicle, -1) == PlayerPed and GetIsVehicleEngineRunning(vehicle) then
                    if vehIsMovingFwd and prevSpeed > TGIANN.crashFlatTire/speedToKmOrMph and vehAcc > 576 then
                        local vehicle = GetPlayersLastVehicle()
                        local randomTire = math.random(1,4)
                        if randomTire == 1 then
                            SetVehicleTyreBurst(vehicle, 0, 1, 100.0)
                        elseif randomTire == 2 then
                            SetVehicleTyreBurst(vehicle, 0, 1, 100.0)
                            SetVehicleTyreBurst(vehicle, 4, 1, 100.0)
                        elseif randomTire == 3 then
                            SetVehicleTyreBurst(vehicle, 0, 1, 100.0)
                            SetVehicleTyreBurst(vehicle, 1, 1, 100.0)
                            SetVehicleTyreBurst(vehicle, 4, 1, 100.0)
                            SetVehicleEngineHealth(vehicle, 10.0)
                        elseif randomTire == 4 then
                            SetVehicleTyreBurst(vehicle, 0, 1, 100.0)
                            SetVehicleTyreBurst(vehicle, 1, 1, 100.0)
                            SetVehicleTyreBurst(vehicle, 4, 1, 100.0)
                            SetVehicleTyreBurst(vehicle, 5, 1, 100.0)
                            SetVehicleEngineHealth(vehicle, 10.0)
                        end
                    end
                end

                if IsVehicleTyreBurst(vehicle, 0) or IsVehicleTyreBurst(vehicle, 1) or IsVehicleTyreBurst(vehicle, 4) or IsVehicleTyreBurst(vehicle, 5) then 
                    flattire = true
                else
                    flattire = false
                end

                -- Speed
                local speed = currSpeed * speedToKmOrMph
                local speedColor = (speed >= TGIANN.speedLimit) and speedColorOver or speedColorUnder
               
                -- Draw fuel gauge
                if GetPedInVehicleSeat(vehicle, -1) == PlayerPed then
                    drawText(("%.3d"):format(math.ceil(speed)), 2, speedColor, 0.5, screenPosX+ 0.045, screenPosY + 0.048, true)
                    local speedColorText = cruiseIsOn and cruiseColorOn or cruiseColorOff
                    if TGIANN.useKm then
                        drawText("KM", 2, speedColorText, 0.25, screenPosX + 0.065, screenPosY + 0.051, true)
                    else
                        drawText("MPH", 2, speedColorText, 0.25, screenPosX + 0.065, screenPosY + 0.051, true)
                    end

                    drawText(("%.3d"):format(math.ceil(currentFuel)), 2, {255, 255, 255}, 0.5, screenPosX, screenPosY + 0.048, true)
                    drawText("FUEL", 2, fuelColorText, 0.25, screenPosX + 0.020, screenPosY + 0.051, true)

                    -- Draw seatbelt status if not a motorcyle
                    if vehicleClass ~= 8 and vehicleClass ~= 21 and vehicleClass ~= 14 and vehicleClass ~= 13 then
                        local seatbeltColor = seatbeltIsOn and seatbeltColorOn or seatbeltColorOff
                        drawText("BELT", 2, seatbeltColor, 0.3, screenPosX + 0.083, screenPosY + 0.051, true)
                    end

                else
                    drawText(("%.3d"):format(math.ceil(speed)), 2, speedColor, 0.5, screenPosX, screenPosY + 0.048, true)
                    local speedColorText = cruiseIsOn and cruiseColorOn or cruiseColorOff
                    drawText("KM", 2, speedColorText, 0.25, screenPosX + 0.020, screenPosY + 0.051, true)

                    -- Draw seatbelt status if not a motorcyle
                    if vehicleClass ~= 8 and vehicleClass ~= 21 and vehicleClass ~= 14 and vehicleClass ~= 13 then
                        local seatbeltColor = seatbeltIsOn and seatbeltColorOn or seatbeltColorOff
                        drawText("BELT", 2, seatbeltColor, 0.3, screenPosX + 0.041, screenPosY + 0.051, true)
                    end

                end
                drawText(timeText, 4, locationColorText, 0.3, screenPosX, screenPosY + 0.028, true)
            end
        else
            drawText(timeText, 4, locationColorText, 0.3, screenPosX, screenPosY+0.055, true)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local time = 2000
        local hour = GetClockHours()
        local minute = GetClockMinutes()
        timeText = hour .. ":" .. minute
        if pedInVeh then
            time = 1000
            local position = GetEntityCoords(PlayerPed)
            local vehicle = GetVehiclePedIsIn(PlayerPed, false)

            local zoneName = zones[GetNameOfZone(position.x, position.y, position.z)]
            if zoneName ~= nil then
                zoneNameFull = "[".. zoneName .. "]" 
            else
                zoneNameFull = "[Unknown]"
            end
            
            local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(position.x, position.y, position.z))
            locationText = (streetName == "" or streetName == nil) and (locationText) or (streetName)
            locationText = (zoneNameFull == "" or zoneNameFull == nil) and (locationText) or (locationText .. " | " .. zoneNameFull)
            if vehicle ~= 0 then currentFuel = GetVehicleFuelLevel(vehicle) end
        end
        Citizen.Wait(time)
    end
end)

-- Helper function to draw text to screen
function drawText(text, font, colour, scale, x, y, outline, centered)
    if font == nil then font = 4 end
    if scale == nil then scale = 1.0 end
	SetTextFont(font)
	SetTextScale(0.0, scale)
	SetTextProportional(1)
    if colour then
        SetTextColour(colour[1], colour[2], colour[3], colour[4] ~= nil and colour[4] or 255)
    else 
        SetTextColour(255, 255, 255, 255)
    end
    SetTextDropShadow(0, 0, 0, 0, 255)
	if centered then SetTextCentre(true) end
    --if outline then SetTextOutline() end
    SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x + TGIANN.positionx, y + TGIANN.positiony)
end

function Draw2DText(x, y, text, scale, center)
    -- Draw text on screen
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    if center then 
    	SetTextJustification(0)
    end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function degreesToIntercardinalDirection( dgr )
	dgr = dgr % 360.0
	
	if (dgr >= 0.0 and dgr < 22.5) or dgr >= 337.5 then
		return "NE" -- Originally E
	elseif dgr >= 22.5 and dgr < 67.5 then
		return "E" -- Originally SE
	elseif dgr >= 67.5 and dgr < 112.5 then
		return "SE" -- Originally S
	elseif dgr >= 112.5 and dgr < 157.5 then
		return "S" -- Originally SW
	elseif dgr >= 157.5 and dgr < 202.5 then
		return "SW" -- Originally W
	elseif dgr >= 202.5 and dgr < 247.5 then
		return "W" -- Originally NW
	elseif dgr >= 247.5 and dgr < 292.5 then
		return "NW" -- Originally N
	elseif dgr >= 292.5 and dgr < 337.5 then
		return "N" -- Originally NE
	end
end