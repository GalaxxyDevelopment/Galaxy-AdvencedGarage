local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('server:AracVeriKaydet', function(vehicleProps, vehicleModel)
    local src = source
    local oyuncu = QBCore.Functions.GetPlayer(src)
    if not oyuncu then return end

    exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        oyuncu.PlayerData.license,
        oyuncu.PlayerData.citizenid,
        vehicleModel,
        GetHashKey(vehicleModel),
        json.encode(vehicleProps),
        vehicleProps.plate,
        'default',
        0
    })
end)
