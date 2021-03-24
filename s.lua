ESX = nil
TriggerEvent('esx:getShared0bject', function(obj) ESX = obj end)

TriggerEvent('es:addGroupCommand', 'seuranta', "superadmin", function(source, args, user)
    if tonumber(args[1]) then
        if GetPlayerName(args[1]) then
            local syy = {}
            local amount = 0
            local xPlayer = ESX.GetPlayerFromId(args[1])
            if xPlayer then
                MySQL.Async.fetchAll('SELECT syy FROM seuranta WHERE hex = @hex', {['@hex'] = xPlayer.identifier }, function(res)
                    for _,v in ipairs(res) do
                        table.insert(syy, v['syy'])
                        amount = _
                        print(_)
                    end
                    if amount >= 1 then
                        TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {"SEURANTA", "\nNimi: "..xPlayer.name.."\nHex: "..xPlayer.identifier..'\nSyy: '..table.concat(syy, ", ")}})
                    else
                        TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {"SEURANTA", "Pelaajalla ei ole seurattavien pelaajien listassa..."}})
                    end
                end)
            end
        else
            TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {"SEURANTA", "Kyseinen pelaaja ei näyttäisi olevan palvelimella..."}})
        end
    else
        TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {"SEURANTA", "Pelaajan ID täytyy olla numero..."}})
    end 
end)

TriggerEvent('es:addGroupCommand', 'removeseuranta', "superadmin", function(source, args, user)
    if tonumber(args[1]) then
        if GetPlayerName(args[1]) then
            if args[2] then
                txPlayer = ESX.GetPlayerFromId(args[1])
                sxPlayer = ESX.GetPlayerFromId(source)
                if txPlayer and sxPlayer then
                    local syy = args[2]
                    MySQL.Async.execute('DELETE FROM seuranta WHERE hex = @hex AND syy = @syy AND submitter = @submitter',
                    {
                        ['@hex'] = txPlayer.identifier,
                        ['@syy'] = syy,
                        ['@submitter'] = sxPlayer.identifier,
                    }, function(aff)
                        TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {"SEURANTA", "Poistettu "..aff.." rivi(ä) tietokannasta pelaajan "..txPlayer.name..' '..txPlayer.identifier}})
                    end)
                end
            end
        end
    end
end)

TriggerEvent('es:addGroupCommand', 'addseuranta', "superadmin", function(source, args, user)
    if tonumber(args[1]) then
        if GetPlayerName(args[1]) then
            if args[2] then
                local txPlayer = ESX.GetPlayerFromId(args[1])
                local sxPlayer = ESX.GetPlayerFromId(source)
                if txPlayer and sxPlayer then
                    if args[2] then
                        MySQL.Async.insert('INSERT INTO seuranta (hex, syy, submitter) VALUES (@hex, @syy, @submitter)',
                        {
                            ['@hex'] = txPlayer.identifier,
                            ['@syy'] = args[2],
                            ['@submitter'] = sxPlayer.identifier,
                        })
                        TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {"SEURANTA", "Pelaajalle ["..args[1]..'] '..txPlayer.name..' lisätty seuranta syystä '.. args[2]}})
                    else
                        TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {"SEURANTA", "Et voi asettaa pelaajaa seurantaan ilman syytä.."}})
                    end
                end
            else
                TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {"SEURANTA", "Et voi asettaa pelaajaa seurantaan ilman syytä.."}})
            end
        else
            TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {"SEURANTA", "Kyseinen pelaaja ei näyttäisi olevan palvelimella..."}})
        end
    else
        TriggerClientEvent("chat:addMessage", source, {color = {255,0,0}, multiline = true, args = {"SEURANTA", "Pelaajan ID täytyy olla numero..."}})
    end
end)

AddEventHandler("playerConnecting", function(name, setReason, deferrals)
    local hex = GetPlayerIdentifier(source)
    local nimi = GetPlayerName(source)
    local syy = {}
    local amount = 0
    if hex and nimi then
        MySQL.Async.fetchAll('SELECT syy FROM seuranta WHERE hex = @hex', {['@hex'] = hex }, function(res)
            for _,v in ipairs(res) do
                table.insert(syy, v['syy'])
                amount = _
            end
            TriggerEvent("es:getPlayers", function(pl)
                for k,v in pairs(pl) do
                    TriggerEvent("es:getPlayerFromId", k, function(user)
                        if(user.getPermissions() > 0)then
                            if amount >= 1 then
                                TriggerClientEvent("chat:addMessage", k, {color = {255,0,0}, multiline = true, args = {"SEURANTA", "\nNimi: "..xPlayer.name.."\nHex: "..xPlayer.identifier..'\nSyy: '..table.concat(syy, ", ")}})
                            end
                        end
                    end)
                end
            end)
        end)
    end
end)
