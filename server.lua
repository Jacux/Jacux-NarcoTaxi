ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent("carism_narcoTaxi:pay")
AddEventHandler('carism_narcoTaxi:pay', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.addMoney(math.random(300, 500))

end)
