ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent("Jacux_NarcoTaxi:pay")
AddEventHandler('Jacux_NarcoTaxi:pay', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.addMoney(math.random(300, 500))

end)
