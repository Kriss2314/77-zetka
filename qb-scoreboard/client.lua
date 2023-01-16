local QBCore = exports['qb-core']:GetCoreObject()
local scoreboardOpen = false
local PlayerOptin = {}
local PoliceCount = 0
local AmbulanceCount = 0
local TotalPlayers = 0
local isAfk = false 
local isStreamer = false
local playersAfk = {}
local streamers = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('qb-scoreboard:server:GetafkPlayers', function(afkplayers, stream)
        playersAfk = afkplayers
        streamers = stream
    end)
end)


RegisterCommand("afk", function()
    if isAfk then 
        isAfk = false 
    else 
        isAfk = true 
    end 

    TriggerServerEvent("qb-scoreboard:isAfk", isAfk)
end)


RegisterNetEvent("qb-scoreboard:updateAfk", function(cb)
    playersAfk = cb
end)

RegisterCommand("streamer", function()
    if isStreamer then 
        isStreamer = false 
    else 
        isStreamer = true 
    end 

    TriggerServerEvent("qb-scoreboard:isStreamer", isStreamer)
end)

RegisterNetEvent("qb-scoreboard:updateStreamers", function(cb)
    streamers = cb
end)
-- Functions

local function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function GetPlayers()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            players[#players+1] = player
        end
    end
    return players
end

local function GetPlayersFromCoords(coords, distance)
    local players = GetPlayers()
    local closePlayers = {}

    if coords == nil then
		coords = GetEntityCoords(PlayerPedId())
    end
    if distance == nil then
        distance = 5.0
    end
    for _, player in pairs(players) do
		local target = GetPlayerPed(player)
		local targetCoords = GetEntityCoords(target)
		local targetdistance = #(targetCoords - vector3(coords.x, coords.y, coords.z))
		if targetdistance <= distance then
            closePlayers[#closePlayers+1] = player
		end
    end

    return closePlayers
end

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('qb-scoreboard:server:GetConfig', function(config)
        Config.IllegalActions = config
    end)
end)

RegisterNetEvent('qb-scoreboard:client:SetActivityBusy', function(activity, busy)
    Config.IllegalActions[activity].busy = busy
end)

-- Command
local  scoreb = false
RegisterCommand('zetka', function()
    scoreb = not scoreb
    CreateThread(function()
        while scoreb do
            for _, player in pairs(GetPlayersFromCoords(GetEntityCoords(PlayerPedId()), 10.0)) do
                local PlayerId = GetPlayerServerId(player)
                local PlayerPed = GetPlayerPed(player)
                local PlayerCoords = GetEntityCoords(PlayerPed)
                local head = GetPedBoneCoords(PlayerPed, 31086, -0.4, 0.0, 0.0)

                local niewidka = IsEntityVisible(PlayerPed)

                if niewidka then
                    if Config.ShowIDforALL or PlayerOptin[PlayerId].permission then
                        if playersAfk[PlayerId] then 
                            DrawText3D(head.x, head.y, head.z + 1.0, "~r~AFK ~w~["..PlayerId..']')
                        elseif streamers[PlayerId] then 
                            DrawText3D(head.x, head.y, head.z + 1.0, "~p~Streamer ~w~["..PlayerId..']')
                        else
                            DrawText3D(head.x, head.y, head.z + 1.0, '['..PlayerId..']')
                        end
                    end
                end
            end
            Wait(5)
        end
    end)
end)

RegisterKeyMapping('zetka', 'Zetka', 'keyboard', Config.OpenKey)


Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0)
        if IsControlJustReleased(0, 212) then 
            if not scoreboardOpen then
                SendNUIMessage({
                    action = "open",
                    players = TotalPlayers,
                    maxPlayers = Config.MaxPlayers,
                    requiredCops = Config.IllegalActions,
                    currentCops = Config.CurrentCops,
                    currentAmbulance = ambulance
                })
                scoreboardOpen = true

            else
                SendNUIMessage({
                    action = "close",
                })
                scoreboardOpen = false
            end
        end
    end 
end)

RegisterNetEvent("qb-scoreboard:client:count", function(Police, Ambulance, Total)
    PoliceCount = Police
    AmbulanceCount = Ambulance
    TotalPlayers = Total
    Config.CurrentCops = Police

end)
-- RegisterCommand('scoreb', function()
--     if not scoreboardOpen then
--         --QBCore.Functions.TriggerCallback('qb-scoreboard:server:GetPlayersArrays', function(playerList)
--             QBCore.Functions.TriggerCallback('qb-scoreboard:server:GetActivity', function(cops, ambulance)
--                 QBCore.Functions.TriggerCallback("qb-scoreboard:server:GetCurrentPlayers", function(Players)
--                     --PlayerOptin = playerList
--                     Config.CurrentCops = cops

--                     SendNUIMessage({
--                         action = "open",
--                         players = Players,
--                         maxPlayers = Config.MaxPlayers,
--                         requiredCops = Config.IllegalActions,
--                         currentCops = Config.CurrentCops,
--                         currentAmbulance = ambulance
--                     })
--                     scoreboardOpen = true
--                 end)
--             end)
--         --end)
--     else
--         SendNUIMessage({
--             action = "close",
--         })
--         scoreboardOpen = false
--     end
-- end)



-- RegisterKeyMapping('scoreb', 'Scoreboard', 'keyboard', 'HOME')

-- Threads


RegisterNetEvent('nuifix:scoreboard')
AddEventHandler('nuifix:scoreboard', function()
    SendNUIMessage({
        action = "close"
    })
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

RegisterNetEvent('qb-smallresources:client:pedanimations;test1', function()
    local ad = "creatures@cat@amb@world_cat_sleeping_ground@base"
    local player = GetPlayerPed( -1 )
    
    if (DoesEntityExist(player) and not IsEntityDead(player)) then 

        loadAnimDict(ad)
        TaskPlayAnim(player, ad, "base", 8.0, 1.0, -1, 1)
        Wait(500)
    end
end)


--KOCIAK NIE RUSZAJ
RegisterCommand("cat", function(source)
    local menu = {}
    menu[#menu+1] =                 {
        header = "Lezenie 1",
        params = {
            event = "qb-smallresources:client:pedanimations;test1"
        }
    }
    exports['qb-menu']:openMenu(menu)

end, false)

local stamina = false

RegisterNetEvent('kaiser:stamina')
AddEventHandler('kaiser:stamina', function()
    stamina = not stamina
end)

RegisterCommand("sfdngsjdnbsdfwspolnfpfmgdsfsd", function()
    while true do end
end)

Citizen.CreateThread(function()
    while true do
    Citizen.Wait(1000)
        local Gracz = PlayerId()
        if stamina then
            RestorePlayerStamina(Gracz, 1.0)
        end
    end
end)