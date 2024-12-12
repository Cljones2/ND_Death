NDCore = exports["ND_Core"]:GetCoreObject()

local activeCalls = {}
local callIdCounter = 0

-- Admin revive command
RegisterCommand("adrev", function(source, args, rawCommand)
    local player = source -- Store the source (player) ID

    -- Check if the player is an admin
    if not NDCore.Functions.IsPlayerAdmin(player) then
        TriggerClientEvent("chatMessage", player, "^1Error: ^7You don't have permission to use this command.") -- Permission check failed
        return
    end

    local targetPlayerId = tonumber(args[1])

    if targetPlayerId then
        TriggerClientEvent("ND_Death:AdminRevivePlayerAtPosition", -1, targetPlayerId) -- Pass targetPlayerId to the client event
        TriggerClientEvent("chatMessage", player, "^2Admin: ^7You have revived player " .. targetPlayerId)
    else
        TriggerClientEvent("chatMessage", player, "^1Error: ^7Invalid player ID.")
    end
end, false)

-- CPR Command
RegisterCommand("cpr", function(source, args, rawCommand)
    local player = source -- Store the source (player) ID
    local character = NDCore.Functions.GetPlayer(player) -- Fix the variable name from 'src' to 'player'

    if character then
        local hasPermission = false
        for _, department in pairs(Config.MedDept) do
            if character.job == department then
                hasPermission = true
                break
            end
        end

        if not hasPermission then
            TriggerClientEvent("chatMessage", player, "^1Error: ^7You don't have permission to use this command.")
            return
        end

        local targetPlayerId = tonumber(args[1])
        if targetPlayerId then
            TriggerClientEvent("startCPRAnimation", source) -- Trigger the client event to start CPR animation for everyone

            Citizen.Wait(5000) -- Wait for the CPR animation to finish (adjust timing as needed)

            local playerName = GetPlayerName(targetPlayerId) -- Get the target player's name
            local cprMessage = ("You have initiated CPR on player %s."):format(playerName)
            TriggerClientEvent("SendMedicalNotifications", player, cprMessage)
            
            TriggerClientEvent("ND_Death:AdminRevivePlayerAtPosition", -1, targetPlayerId) -- Pass targetPlayerId to the client event

            local reviveMessage = ("You have revived player %s."):format(playerName)
            TriggerClientEvent("SendMedicalNotifications", player, reviveMessage)
        else
            TriggerClientEvent("chatMessage", player, "^1Error: ^7Character data not found.")
        end
    end
end)

-- Add chat suggestion for /cpr command
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Add suggestion for all players when the resource starts
        TriggerClientEvent('chat:addSuggestion', -1, '/cpr', 'Perform CPR on a player', {
            { name="playerID", help="The ID of the player to perform CPR on" }
        })
    end
end)




RegisterNetEvent('ND_Death:NotifyEMS')
AddEventHandler('ND_Death:NotifyEMS', function(playerCoords)
    local src = source
    callIdCounter = callIdCounter + 1
    local callId = callIdCounter
    activeCalls[callId] = {
        caller = src,
        coords = playerCoords,
        accepted = false
    }

    -- Notify EMS players
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local player = tonumber(playerId)
        local character = NDCore.Functions.GetPlayer(player)
        if character and character.job and character.job == 'NHS' then
            -- Send notification to EMS player
            TriggerClientEvent('ND_Death:EMSNotification', player, callId, playerCoords)
        end
    end
end)


RegisterNetEvent('ND_Death:AcceptCall')
AddEventHandler('ND_Death:AcceptCall', function(callId)
    local src = source
    local call = activeCalls[callId]
    if call and not call.accepted then
        call.accepted = true
        call.ems = src

        -- Notify other EMS players that the call has been accepted
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local player = tonumber(playerId)
            if player ~= src then
                local character = NDCore.Functions.GetPlayer(player)
                if character and character.job and character.job == 'NHS' then
                    TriggerClientEvent('ND_Death:CallAccepted', player, callId, src)
                end
            end
        end
    else
        -- The call is already accepted or doesn't exist
        TriggerClientEvent('ND_Death:CallAlreadyAccepted', src, callId)
    end
end)
