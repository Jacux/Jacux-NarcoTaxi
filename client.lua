ESX = exports["es_extended"]:getSharedObject()
local ped = nil
local cam = nil
local inMission = false
local nowyped = nil
local blip = {}
CreateThread(function()
    ESX.Streaming.RequestStreamedTextureDict("DIA_CLIFFORD")

end)

local PlayAnim = function(dict, anim, speed, time, flag)
    ESX.Streaming.RequestAnimDict(dict, function()
        TaskPlayAnim(PlayerPedId(), dict, anim, speed, speed, time, flag, 1,
                     false, false, false)
    end)
end

local PlayAnimOnPed = function(ped, dict, anim, speed, time, flag)
    ESX.Streaming.RequestAnimDict(dict, function()
        TaskPlayAnim(ped, dict, anim, speed, speed, time, flag, 1, false,
                     false, false)
    end)
end

local MakeEntityFaceEntity = function(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading(entity1, heading)
end

local dostarczPake = function()
    CreateThread(function()
        PlayAmbientSpeech1(nowyped, "GENERIC_THANKS", "SPEECH_PARAMS_STANDARD")
        exports.ox_target:removeLocalEntity(nowyped, "narkodostawa")
        MakeEntityFaceEntity(PlayerPedId(), nowyped)
        MakeEntityFaceEntity(nowyped, PlayerPedId())
        SetPedTalk(nowyped)
        PlayAmbientSpeech1(nowyped, "GENERIC_HI", "SPEECH_PARAMS_STANDARD")
        obj = CreateObject(GetHashKey("prop_weed_bottle"), 0, 0, 0, true)
        AttachEntityToEntity(obj, PlayerPedId(),
                             GetPedBoneIndex(PlayerPedId(), 57005), 0.13, 0.02,
                             0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
        obj2 = CreateObject(GetHashKey("hei_prop_heist_cash_pile"), 0, 0, 0,
                            true)
        AttachEntityToEntity(obj2, nowyped, GetPedBoneIndex(nowyped, 57005),
                             0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
        PlayAnim("mp_common", "givetake1_a", 8.0, -1, 0)
        PlayAnimOnPed(nowyped, "mp_common", "givetake1_a", 8.0, -1, 0)
        Wait(1000)
        AttachEntityToEntity(obj2, PlayerPedId(),
                             GetPedBoneIndex(PlayerPedId(), 57005), 0.13, 0.02,
                             0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
        AttachEntityToEntity(obj, nowyped, GetPedBoneIndex(nowyped, 57005),
                             0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
        Wait(1000)
        DeleteEntity(obj)
        DeleteEntity(obj2)
        SetPedAsNoLongerNeeded(nowyped)
        TriggerServerEvent("Jacux_NarcoTaxi:pay")
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
            blip = {}
        end
        inMission = false
        Wait(10000)
        DeleteEntity(nowyped)
        nowyped = nil
    end)
end

local dialog = function(kwestie, ped, koordy, kam, onEnd)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", kam[1], kam[2],
                              kam[3] + 0.5, 0.0, 0.0, kam[4], 90.0)
    CreateThread(function()
        step = 1
        menu = false
        stop = false
        repeat
            SetCamActive(cam, true)
            RenderScriptCams(true, 0, 1, 1, 0)
            FreezeEntityPosition(GetPlayerPed(-1), true)

            ESX.ShowHelpNotification(
                "Naciśnij ~g~[E]~w~, aby pominąć kwestie")
            SetEntityVisible(PlayerPedId(), false)
            if IsControlJustPressed(0, 38) then step = step + 1 end
            for i = 1, #kwestie do
                RequestAnimDict(kwestie[i].animacja.lib)

                if step == i then
                    ESX.ShowFloatingHelpNotification(kwestie[i].tresc, vector3(
                                                         koordy[1], koordy[2],
                                                         koordy[3] + 2))

                    if kwestie[i].animacja.played == nil and kwestie[i].animacja ~=
                        nil then
                        TaskPlayAnim(ped, kwestie[i].animacja.lib,
                                     kwestie[i].animacja.anim, 1.0, -1.0, 5000,
                                     0, 1, true, true, true)
                        kwestie[i].animacja.played = true
                    end
                end
            end
            if step > #kwestie then
                FreezeEntityPosition(GetPlayerPed(-1), false)
                RenderScriptCams(false, true, 0, true, true)
                DestroyCam(cam, false)
                SetEntityVisible(PlayerPedId(), true)
                onEnd()
                cam = nil
                stop = true
            end

            Wait(0)
        until stop
    end)
end

local spawnPed = function()
    local coords = Config.Places[math.random(1, #Config.Places)]
    local model = Config.Pedlist[math.random(1, #Config.Pedlist)]
    RequestModel(GetHashKey(model))

    while not HasModelLoaded(GetHashKey(model)) do Wait(155) end

    nowyped = CreatePed(4, GetHashKey(model), coords, 0.0, true, true)

    if DoesEntityExist(nowyped) then
        blip = AddBlipForEntity(nowyped)
        SetBlipSprite(blip, 280)
        SetBlipColour(blip, 11)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Klient Madiego")
        EndTextCommandSetBlipName(blip)
        TaskWanderStandard(nowyped, 10.0, 10)
    end

    local options = {
        {
            name = "narkodostawa",
            onSelect = function() dostarczPake() end,
            icon = "fas fa-warehouse",
            label = "Dostarcz Paczke"
        }
    }

    exports.ox_target:addLocalEntity(nowyped, options)
    CreateThread(function()
        repeat
            Citizen.Wait(1000)

            if nowyped and DoesEntityExist(nowyped) and
                IsPedDeadOrDying(nowyped, 1) ~= 1 then
                Citizen.Wait(0)
            else
                exports.ox_target:removeLocalEntity(nowyped, "narkodostawa")
                if inMission then
                    exports["dopeNotify"]:MotorekNotify({
                        text = '<b><i class="fa-regular fa-face-angry"></i>&nbsp;&nbsp;Madi</span></b></br>Ktoś zabił twojego klienta. Twoja dostawa została anulowana. Uciekaj z stamtąd póki jeszcze żyjesz!',
                        type = "admin",
                        timeout = 3000,
                        layout = "topRight",
                        sound = {volume = 0.0},
                        frontendSound = {
                            string = {
                                "Out_Of_Bounds_Timer",
                                "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS"
                            },
                            times = 1,
                            wait = 200,
                            volume = 10.0
                        }
                    })
                    inMission = false
                end

                if blip and DoesBlipExist(blip) then
                    RemoveBlip(blip)
                end
                break
            end
        until not inMission
    end)
end

Citizen.CreateThread(function()
    RequestModel(GetHashKey(Config.Model))

    while not HasModelLoaded(GetHashKey(Config.Model)) do Wait(155) end
    while CreatePed == nil do Citizen.Wait(100) end
    ped = CreatePed(4, GetHashKey(Config.Model), Config.Coords, false, true)

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
end)

local startDelivery = function()
    inMission = true
    spawnPed()
end

local startContext = function()
    local elements = {}

    table.insert(elements, {label = "Przyjmij zlecenie", value = "y"})

    table.insert(elements, {label = "Odrzuć zlecenie", value = "n"})

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "przyjmij", {
        title = "Czy chcesz przyjąć propozycje?",
        align = "center",
        elements = elements
    }, function(data, menu)
        if data.current.value == "y" then startDelivery() end

        menu.close()
    end, function(data, menu) menu.close() end)
end

exports.qtarget:AddBoxZone("ped", vector3(Config.Coords.xyz), 2, 2, {
    name = "tablet",
    heading = Config.Coords.w,
    debugPoly = false,
    minZ = Config.Coords.z + 2,
    maxZ = Config.Coords.z - 2
}, {
    options = {
        {
            icon = "fa-solid fa-capsules",
            label = "Porozmawiaj z Madim",
            action = function()
                if not inMission then
                    dialog({
                        {
                            tresc = "Cześć!",
                            animacja = {
                                lib = "friends@frj@ig_1",
                                anim = "wave_c"
                            }
                        }, {tresc = "Potrzebujesz pracy?", animacja = {}},
                        {tresc = "Mam dla ciebie propozycję.", animacja = {}},
                        {
                            tresc = "Chcesz dostarczyć dla mnie jedną rzecz?",
                            animacja = {}
                        }
                    }, ped, {Config.Coords.x, Config.Coords.y, Config.Coords.z},
                           {-1052.8921, -1159.1257, 2.1586, 29.9657},
                           startContext)
                else
                    exports["dopeNotify"]:MotorekNotify({
                        text = '<b><i class="fa-regular fa-face-angry"></i>&nbsp;&nbsp;Co ty tu robisz?</span></b></br>Nie skończyłeś jeszcze dostawy!',
                        type = "admin",
                        timeout = 3000,
                        layout = "topRight",
                        sound = {volume = 0.0},
                        frontendSound = {
                            string = {
                                "Out_Of_Bounds_Timer",
                                "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS"
                            },
                            times = 1,
                            wait = 200,
                            volume = 10.0
                        }
                    })
                end
            end
        }
    },
    distance = 3.5
})
