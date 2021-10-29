ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local chatname = "Player tracking"

TriggerEvent('es:addGroupCommand', 'lookup', "superadmin", function(source, args, user) -- usage /lookup [id]
    if tonumber(args[1]) then -- Valid number
        if GetPlayerName(args[1]) then -- Valid player
            local reason = {}
            local xPlayer = ESX.GetPlayerFromId(args[1])
            if xPlayer then
                MySQL.Async.fetchAll('SELECT syy FROM seuranta WHERE hex = @hex', {['@hex'] = xPlayer.identifier }, function(result)
                    if result then
                        for index,res in ipairs(result) do
                            table.insert(reason, res("reason"))
                        end
                        if #reason <= 0 then
                            TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {chatname, string.format("Name: %s\nHex: %s\n This player does not have any valid tracking entries.", tostring(xPlayer.name),tostring(xPlayer.identifier))}})
                        else
                            TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {chatname, string.format("Name: %s\nHex: %s\nReason: %s",tostring(xPlayer.name), tostring(xPlayer.identifier), tostring(table.concat(reason,", ")))}})
                        end
                    end
                end)
            else
                TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {chatname, string.format("Name: %s\nID: %d\nCannot fetch xPlayer.", tostring(GetPlayerName(args[1]), tonumber(args[1])))}})
            end
        end
    end
end)

TriggerEvent('es:addGroupCommand', 'removetracking', "superadmin", function(source, args, user) -- Usage /removetracking [id] NOTE: Removes whole tracking history. 
    if tonumber(args[1]) then -- Valid number
        if GetPlayerName(args[1]) then -- Valid player
            xPlayer = ESX.GetPlayerFromId(args[1])
            if xPlayer then
                MySQL.Async.execute('DELETE FROM seuranta WHERE hex = @hex',
                {
                    ['@hex'] = xPlayer.identifier
                }, function(aff)
                    TriggerClientEvent("chat:addMessage", source, {control = {255,0,0}, multiline = true, args = {chatname, string.format("Removed data from %s\n%i rows affected on database.", tostring(xPlayer.name), tonumber(aff))}})
                end)
            end
        end
    end
end)

TriggerEvent('es:addGroupCommand', 'addtracking', "superadmin", function(source, args, user) -- Usage /addtracking [id] [reason] NOTE: Rewrite allows now to add spaces on your reason ex. Default danny, FailRP. 
    if tonumber(args[1]) then -- Valid number
        if GetPlayerName(args[1]) then -- Valid player
            local id = args[1]
            local txPlayer = ESX.GetPlayerFromId(id)
            local sxPlayer = ESX.GetPlayerFromId(source)
            local newargs = {}
            newargs = args
            table.remove(newargs, 1) -- remove id from arguments
            if txPlayer and sxPlayer then
                if #newargs ~= 0 then
                    local unpacked = table.concat(newargs," ")
                    MySQL.Async.insert('INSERT INTO player_tracking (hex, reason, submitter) VALUES (@hex, @reason, @submitter)',
                    {
                        ['@hex'] = txPlayer.identifier,
                        ['@reason'] = unpacked,
                        ['@submitter'] = sxPlayer.identifier,
                    })
                    TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {chatname, string.format("%s added succesfully to tracking. Information:\nID: %i\nHex: %s\nReason: %s",txPlayer.name,id,txPlayer.identifier,unpacked)}})
                else
                    TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {chatname, "You can not track a player with out valid reason"}})
                end
            end
        end
    end
end)

AddEventHandler("playerConnecting", function(name, setReason, deferrals)
    local hex = GetPlayerIdentifier(source)
    local name = GetPlayerName(source)
    local reason = {}
    deferrals.defer()
    if hex ~= nil and name ~= nil then
        MySQL.Async.fetchAll('SELECT * FROM player_tracking WHERE hex = @hex', {['@hex'] = hex }, function(res)
            if #res ~= 0 then
                for k, v in ipairs(res) do
                    table.insert(reason, v["reason"])
                end
                TriggerEvent("es:getPlayers", function(pl)
                    for k,v in pairs(pl) do
                        TriggerEvent("es:getPlayerFromId", k, function(user)
                            if(user.getGroup() == superadmin)then
                                if #reason >= 1 then
                                    TriggerClientEvent("chat:addMessage", k, {color = {255,0,0}, multiline = true, args = {chatname, string.format("Player connecting:\nName: %s\nHex: %s\nTracking Reason: %s", tostring(name),tostring(hex),table.concat(reason, ", "))}})
                                end
                            end
                        end)
                    end
                end)
                deferrals.done()
                return
            else
                deferrals.done() 
                return
            end
        end)
    else
        deferrals.done("Error...")
        return
    end
end)
