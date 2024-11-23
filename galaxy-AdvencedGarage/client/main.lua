local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    for _, konum in ipairs(Config.konumlar) do
        NPCKur(konum)
    end
end)

function NPCKur(konum)
    RequestModel('u_m_m_aldinapoli')
    while not HasModelLoaded('u_m_m_aldinapoli') do Wait(100) end

    local npc = CreatePed(4, 'u_m_m_aldinapoli', konum.npcKonumu.x, konum.npcKonumu.y, konum.npcKonumu.z - 1, konum.npcKonumu.w, false, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)

    if Config.Target == 'qb' then
        exports['qb-target']:AddTargetEntity(npc, {
            options = {
                {
                    label = konum.data and "Araç Al" or "Araç Kirala",
                    icon = "fas fa-car",
                    action = function()
                        AracMenuAc(konum)
                    end
                }
            },
            distance = 2.0
        })
    elseif Config.Target == 'ox' then
        exports.ox_target:addLocalEntity(npc, {
            {
                name = (konum.data and "arac_al_" or "arac_kirala_") .. npc,
                label = konum.data and "Araç Al" or "Araç Kirala",
                icon = "fas fa-car",
                distance = 2.0,
                onSelect = function()
                    AracMenuAc(konum)
                end
            }
        })
    end
end

function AracMenuAc(konum)
    local oyuncuVerisi = QBCore.Functions.GetPlayerData()
    
    if konum.jobGereksinimi and oyuncuVerisi.job.name ~= konum.meslek then
        notifygonder("Bu alandan işlem yapmak için uygun bir mesleğiniz yok.", 'error')
        return
    end

    if Config.Menu == 'qb' then
        QBMenyusuAc(konum)
    elseif Config.Menu == 'ox' then
        OXMenyusuAc(konum)
    end
end

function QBMenyusuAc(konum)
    local menuSecenekleri = {}

    for _, arac in ipairs(konum.araclar) do
        table.insert(menuSecenekleri, {
            header = string.format("%s: %s", konum.data and "Al" or "Kirala", arac),
            txt = konum.data and "Bu aracı al" or "Bu aracı kirala",
            params = {
                event = 'client:AracIslem',
                args = {arac = arac, spawnKonum = konum.AracKonum, veriKaydet = konum.data}
            }
        })
    end

    table.insert(menuSecenekleri, {header = "Menüyü Kapat", params = {event = 'qb-menu:client:closeMenu'}})

    exports['qb-menu']:openMenu(menuSecenekleri)
end

function OXMenyusuAc(konum)
    local menuSecenekleri = {}

    for _, arac in ipairs(konum.araclar) do
        table.insert(menuSecenekleri, {
            title = string.format("%s: %s", konum.data and "Al" or "Kirala", arac),
            description = konum.data and "Bu aracı al" or "Bu aracı kirala",
            event = 'client:AracIslem',
            args = {arac = arac, spawnKonum = konum.AracKonum, veriKaydet = konum.data}
        })
    end

    lib.registerContext({
        id = 'arac_menu',
        title = konum.data and 'Araç Alımı' or 'Araç Kiralama',
        options = menuSecenekleri
    })
    lib.showContext('arac_menu')
end

RegisterNetEvent('client:AracIslem', function(data)
    local aracModel = data.arac
    local koordinatlar = data.spawnKonum

    Progress({
        name = data.veriKaydet and "arac_al" or "arac_kirala",
        duration = 5000,
        label = data.veriKaydet and "Araç Alınıyor..." or "Araç Kiralanıyor...",
        anim = {
            dict = "amb@world_human_clipboard@male@idle_a",
            clip = "idle_c"
        }
    }, function(status)
        if status == 100 then
            QBCore.Functions.SpawnVehicle(aracModel, function(arac)
                AracAyarla(arac, koordinatlar, data.veriKaydet, aracModel)
            end, koordinatlar, true)
        else
            notifygonder(data.veriKaydet and "Araç alımı iptal edildi." or "Araç kiralama işlemi iptal edildi.", 'error')
        end
    end)
end)

function Progress(data, cb)
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, true)

    if Config.Progressbar == 'standalone' then
        exports['progressbar']:Progress({
            name = data.name,
            duration = data.duration,
            label = data.label,
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true
            },
            animation = data.anim
        }, function(cancelled)
            FreezeEntityPosition(playerPed, false)
            cb(cancelled and 0 or 100)
        end)
    elseif Config.Progressbar == 'ox' then
        local completed = lib.progressBar({
            duration = data.duration,
            label = data.label,
            anim = data.anim,
            disable = { move = true, combat = true, car = true }
        })
        FreezeEntityPosition(playerPed, false)
        cb(completed and 100 or 0)
    end
end

function notifygonder(mesaj, tip)
    if Config.Notify == 'qb' then
        QBCore.Functions.Notify(mesaj, tip)
    elseif Config.Notify == 'ox' then
        lib.notify({description = mesaj, type = tip, position = Config.NotifyKonum})
    end
end

function AracAyarla(arac, koordinatlar, veriKaydet, aracModel)
    local plaka = GetVehicleNumberPlateText(arac)
    SetEntityHeading(arac, koordinatlar.w)
    TaskWarpPedIntoVehicle(PlayerPedId(), arac, -1)
    SetVehicleHasBeenOwnedByPlayer(arac, true)
    SetVehicleFuelLevel(arac, 100.0)
    DecorSetFloat(arac, "_FUEL_LEVEL", 100.0)
    TriggerEvent("vehiclekeys:client:SetOwner", plaka)
    notifygonder(string.format("%s %s ve anahtar verildi!", aracModel, veriKaydet and "alındı" or "kiralandı"), 'success')

    if veriKaydet then
        TriggerServerEvent('server:AracVeriKaydet', QBCore.Functions.GetVehicleProperties(arac), aracModel)
    end
end
