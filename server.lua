RegisterServerEvent('tgiann-carhud:eject-other-player-car')
AddEventHandler('tgiann-carhud:eject-other-player-car', function(table, velocity)
    for i=1, #table do
        TriggerClientEvent("tgiann-carhud:eject-other-player-car-client", table[i], velocity)
    end
end)

