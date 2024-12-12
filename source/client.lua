-- Load core object from ND_Core export
local NDCore = exports["ND_Core"]:GetCoreObject()

-- Initialize flags and timers
local IsDead = false
local IsEMSNotified = false  -- Flag to prevent duplicate notifications
local secondsRemaining = Config.respawnTime
local isBleedingOut = false
local bleedOutTime = 0
local cprInProgress = false
local callPending = false
local currentCall = nil

RegisterCommand("callnhs", function(source, args, rawCommand)
    local playerCoords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('ND_Death:NotifyEMS', playerCoords)
    IsEMSNotified = true
end, false)


-- Main Loop --
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local health = GetEntityHealth(PlayerPedId())
        if health < 2 then
            IsDead = true
            if Config.AutoNotify and not IsEMSNotified then
                -- Trigger the server event to notify EMS
                TriggerServerEvent('ND_Death:NotifyEMS', GetEntityCoords(PlayerPedId()))
                IsEMSNotified = true
            end
        else
            IsDead = false
            IsEMSNotified = false
        end
        if IsDead then
            exports.spawnmanager:setAutoSpawn(false)
            ShowRespawnText()
            if IsControlJustReleased(1, 38) then
                RespawnPlayerAtDownedPosition() -- Use this function to respawn at the downed position
            end
        end
    end
end)


-- Timer Loop --
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        if secondsRemaining > 0 and IsDead then
            secondsRemaining = secondsRemaining - 1
        end
        
        if isBleedingOut and GetGameTimer() > bleedOutTime then
            RespawnPlayer() -- Respawn the player after bleed out time
        end
    end
end)

-- Function to draw custom text on the screen
function DrawCustomText(text, x, y, scale, font)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextOutline()
    SetTextJustification(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- Function to show respawn text
function ShowRespawnText()
    local textToShow
    if secondsRemaining > 0 then
        textToShow = IsDead and Config.respawnTextWithTimer:format(secondsRemaining) or ""
    else
        textToShow = IsDead and Config.respawnText or ""
    end
    DrawCustomText(textToShow, 0.500, 0.900, 0.50, 4) -- Updated position
end

-- Function to respawn the player
function RespawnPlayer()
    local respawnLocation = GetClosestRespawnLocation(GetEntityCoords(PlayerPedId()))
    local playerPed = PlayerPedId()

    if respawnLocation then
        IsDead = false
        DoScreenFadeOut(1500)
        Citizen.Wait(1500) 
        NetworkResurrectLocalPlayer(respawnLocation.x, respawnLocation.y, respawnLocation.z, respawnLocation.h, true, true, false)
        SetEntityCoordsNoOffset(playerPed, respawnLocation.x, respawnLocation.y, respawnLocation.z, true, true, true)
        SetEntityHeading(playerPed, respawnLocation.h)
        SetPlayerInvincible(playerPed, false)
        ClearPedBloodDamage(playerPed)
        DoScreenFadeIn(1500)
        secondsRemaining = Config.respawnTime
    else
        print("No valid respawn location found.")
    end
end

-- Function to get the closest respawn location based on player coordinates
function GetClosestRespawnLocation(playerCoords)
    local closestLocation = nil
    local closestDistance = math.huge

    for _, respawnLocation in pairs(Config.respawnLocations) do
        local distance = #(vector3(respawnLocation.x, respawnLocation.y, respawnLocation.z) - playerCoords)
        if distance < closestDistance then
            closestDistance = distance
            closestLocation = respawnLocation
        end
    end

    return closestLocation
end

-- Function to respawn the player at downed position
function RespawnPlayerAtDownedPosition()
    local playerPos = GetEntityCoords(PlayerPedId())
    local respawnHeading = Config.respawnHeading
    local playerPed = PlayerPedId()
    IsDead = false
    DoScreenFadeOut(1500)
    Citizen.Wait(1500) 
    NetworkResurrectLocalPlayer(playerPos.x, playerPos.y, playerPos.z, respawnHeading, true, true, false)
    SetEntityHeading(playerPed, respawnHeading)
    SetPlayerInvincible(playerPed, false)
    ClearPedBloodDamage(playerPed)
    DoScreenFadeIn(1500)
    secondsRemaining = Config.respawnTime
end



RegisterNetEvent('ND_Death:EMSNotification')
AddEventHandler('ND_Death:EMSNotification', function(callId, playerCoords)
    local location = GetStreetNameFromHashKey(GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z))
    currentCall = {
        id = callId,
        coords = playerCoords,
        location = location
    }
    callPending = true

    -- Display the notification with accept/decline options
    if GetResourceState("ModernHUD") == "started" then
        exports["ModernHUD"]:AndyyyNotify({
            title = "<p style='color: #ff0000;'>EMS Call:</p>",
             message = "<p style='color: #ffffff;'>Player down at:</p><br><p style='color: #ffffff;'>" .. location .. "</p><br><p>Press [E] to accept or [X] to decline.</p>",
            icon = "fa-solid fa-ambulance",
            colorHex = "#ff0000",
            timeout = 30000 -- Display for 30 seconds
        })
    else
        TriggerEvent('chatMessage', '^3EMS Call', {255, 255, 255}, 'Player down at: ' .. location .. '. Press [E] to accept or [X] to decline.')
    end

    -- Create a blip on the map
    currentCall.blip = AddBlipForCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    SetBlipSprite(currentCall.blip, 153) -- EMS blip sprite
    SetBlipDisplay(currentCall.blip, 2)
    SetBlipColour(currentCall.blip, 3) -- Red color
    SetBlipFlashes(currentCall.blip, true)
    SetBlipFlashInterval(currentCall.blip, 500)
    SetBlipAsShortRange(currentCall.blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("EMS Call")
    EndTextCommandSetBlipName(currentCall.blip)

    -- Start a thread to listen for keypresses
    Citizen.CreateThread(function()
        local timeout = GetGameTimer() + 30000 -- 30 seconds
        while callPending and GetGameTimer() < timeout do
            Citizen.Wait(0)
            -- Draw instructions on screen
            DrawTxt('Press [E] to accept or [X] to decline the EMS call.', 0.5, 0.9, 0.4, 4)
            if IsControlJustReleased(0, 38) then -- E key
                AcceptCall()
                break
            elseif IsControlJustReleased(0, 73) then -- X key
                DeclineCall()
                break
            end
        end
        if callPending then
            -- Time ran out, auto-decline
            DeclineCall()
        end
    end)
end)

RegisterNetEvent("ND_Death:AdminRevivePlayerAtPosition")
AddEventHandler("ND_Death:AdminRevivePlayerAtPosition", function(targetPlayerId)
    if GetPlayerServerId(PlayerId()) == targetPlayerId then
        local playerPed = PlayerPedId()
        if IsEntityDead(playerPed) then
            RespawnPlayerAtDownedPosition() -- Revive the player at their downed position
        end
    end
end)


-- Code to start CPR Animation
RegisterNetEvent("startCPRAnimation")
AddEventHandler("startCPRAnimation", function()
    if cprInProgress then
        return
    end
	
    local playerPed = PlayerPedId()
    cprInProgress = true
    TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
    Citizen.Wait(10000) -- Adjust the time as needed for the animation to play
    ClearPedTasks(playerPed)
    cprInProgress = false
end)

RegisterNetEvent("SendMedicalNotifications")
AddEventHandler("SendMedicalNotifications", function(message)
    if GetResourceState("ModernHUD") == "started" then
        exports["ModernHUD"]:AndyyyNotify({
            title = "<p style='color: #34eb52;'>EMS Call:</p>",
            message = "<p style='color: #ffffff;'>" .. message .. "</p>",
            icon = "fa-solid fa-ambulance",
            colorHex = "#34eb52", -- Change to medical green color
            timeout = 8000
        })
    else
        TriggerEvent('chatMessage', '^3[EMS Dispatch]', { 255, 255, 255 }, message)
    end
end)

-- Function to draw text on screen
function DrawTxt(text, x, y, scale, font)
    SetTextFont(font)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - scale / 2, y - scale / 2)
end

function AcceptCall()
    callPending = false
    TriggerServerEvent('ND_Death:AcceptCall', currentCall.id)
    if GetResourceState("ModernHUD") == "started" then
        exports["ModernHUD"]:AndyyyNotify({
            title = "<p style='color: #34eb52;'>Call Accepted</p>",
            message = "<p style='color: #ffffff;'>You have accepted the EMS call.</p>",
            icon = "fa-solid fa-check",
            colorHex = "#34eb52",
            timeout = 5000
        })
    else
        TriggerEvent('chatMessage', '^2[EMS]', {255, 255, 255}, 'You have accepted the EMS call.')
    end
    -- Set a waypoint to the call location
    SetNewWaypoint(currentCall.coords.x, currentCall.coords.y)
end

function DeclineCall()
    callPending = false
    -- Remove the blip
    if currentCall and currentCall.blip then
        RemoveBlip(currentCall.blip)
        currentCall.blip = nil
    end
end

RegisterNetEvent('ND_Death:CallAccepted')
AddEventHandler('ND_Death:CallAccepted', function(callId, emsPlayerId)
    if callPending and currentCall and currentCall.id == callId then
        callPending = false
        -- Remove the blip
        if currentCall.blip then
            RemoveBlip(currentCall.blip)
            currentCall.blip = nil
        end
        -- Notify that another EMS accepted the call
        if GetResourceState("ModernHUD") == "started" then
            exports["ModernHUD"]:AndyyyNotify({
                title = "<p style='color: #ff0000;'>Call Taken</p>",
                message = "<p style='color: #ffffff;'>Another EMS has accepted the call.</p>",
                icon = "fa-solid fa-info-circle",
                colorHex = "#ff0000",
                timeout = 5000
            })
        else
            TriggerEvent('chatMessage', '^3[EMS]', {255, 255, 255}, 'Another EMS has accepted the call.')
        end
    end
end)

RegisterNetEvent('ND_Death:CallAlreadyAccepted')
AddEventHandler('ND_Death:CallAlreadyAccepted', function(callId)
    if currentCall and currentCall.id == callId then
        callPending = false
        -- Remove the blip
        if currentCall.blip then
            RemoveBlip(currentCall.blip)
            currentCall.blip = nil
        end
        -- Notify that the call has already been accepted
        if GetResourceState("ModernHUD") == "started" then
            exports["ModernHUD"]:AndyyyNotify({
                title = "<p style='color: #ff0000;'>Call Already Taken</p>",
                message = "<p style='color: #ffffff;'>The call has already been accepted by another EMS.</p>",
                icon = "fa-solid fa-info-circle",
                colorHex = "#ff0000",
                timeout = 5000
            })
        else
            TriggerEvent('chatMessage', '^3[EMS]', {255, 255, 255}, 'The call has already been accepted by another EMS.')
        end
    end
end)