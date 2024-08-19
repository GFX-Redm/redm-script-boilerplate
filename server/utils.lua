local Init = {
    Frameworks  =  { "es_extended", "qb-core" },
    Inventories =  { "qb-inventory", "esx_inventoryhud", "qs-inventory", "codem-inventory", "gfx-inventory", "ox_inventory" },
    SkinScripts =  { "esx_skin", "qb-clothing", "skinchanger", "illenium-appearance", "fivem-appearance" },
    SQLScripts  =  { "mysql-async", "ghmattimysql", "oxmysql" },
}
local initialized = false
local currentResourceName = GetCurrentResourceName()

function RegisterCallback(name, cb)
    RegisterNetEvent(name, function(id, args)
        local src = source
        local eventName = currentResourceName..":triggerCallback:" .. id
        CreateThread(function()
            local result = cb(src, table.unpack(args))
            TriggerClientEvent(eventName, src, result)
        end)
    end)
end

Utils = {
    Framework,
    FrameworkObject,
    FrameworkShared,
    InventoryName,
    SQLScript
}

function GetFramework()
    return Utils.Framework
end

function GetFrameworkObject()
    return Utils.FrameworkObject
end

function GetFrameworkShared()
    return Utils.FrameworkShared
end

function InitalFunc()
    if initialized then return end
    initialized = true
    InitFramework()
    InitInventory()
    InitSkinScript()
    InitSQLScript()

    print("--------------["..currentResourceName.."]-----------------")
    print("Framework: "..(Utils.Framework or "Not found"))
    print("Inventory: "..(Utils.InventoryName or "Not found"))
    print("SkinScript: "..(Utils.SkinScript or "Not found"))
    print("SQLScript: "..(Utils.SQLScript or "Not found"))
    print("-------------- Script has initialized -------------------")
end

function InitFramework()
    if Utils.Framework ~= nil then return end
    for i = 1, #Init.Frameworks do
        if IsDuplicityVersion() then
            if GetResourceState(Init.Frameworks[i]) == "started" then
                Utils.Framework = Init.Frameworks[i]
                Utils.FrameworkObject = InitFrameworkObject()
                Utils.FrameworkShared = InitFrameworkShared()
            end
        else
            if GetResourceState(Init.Frameworks[i]) == "started" then
                Utils.Framework = Init.Frameworks[i]

                Utils.FrameworkObject = InitFrameworkObject()
                Utils.FrameworkShared = InitFrameworkShared()
            end
        end
    end
end

function InitFrameworkObject()
    if Utils.Framework == "es_extended" then
        local ESX = nil
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
        Citizen.Wait(1000)
        if ESX == nil then
            ESX = exports["es_extended"]:getSharedObject()
        end
        return ESX
    elseif Utils.Framework == "qb-core" then
        local QBCore = nil
        TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)
        Citizen.Wait(1000)
        if QBCore == nil then
            QBCore = exports["qb-core"]:GetCoreObject()
        end
        return QBCore
    end
end

function InitFrameworkShared()
    while Utils.FrameworkObject == nil do
        Citizen.Wait(100)
    end
    if Utils.Framework == "qb-core" then
        return Utils.FrameworkObject.Shared
    elseif Utils.Framework == "es_extended" then
        return Utils.FrameworkObject.Config
    end
end

function InitInventory()
    for i = 1, #Init.Inventories do
        if IsDuplicityVersion() then
            if GetResourceState(Init.Inventories[i]) == "started" then
                Utils.InventoryName = Init.Inventories[i]
            end
        else
            if GetResourceState(Init.Inventories[i]) == "started" then
                Utils.InventoryName = Init.Inventories[i]
            end
        end
    end
end

function InitSkinScript()
    for i = 1, #Init.SkinScripts do
        if IsDuplicityVersion() then
            if GetResourceState(Init.SkinScripts[i]) == "started" then
                Utils.SkinScript = Init.SkinScripts[i]
            end
        else
            if GetResourceState(Init.SkinScripts[i]) == "started" then
                Utils.SkinScript = Init.SkinScripts[i]
            end
        end
    end
end

function InitSQLScript()
    for i = 1, #Init.SQLScripts do
        if IsDuplicityVersion() then
            if GetResourceState(Init.SQLScripts[i]) == "started" then
                Utils.SQLScript = Init.SQLScripts[i]
            end
        else
            if GetResourceState(Init.SQLScripts[i]) == "started" then
                Utils.SQLScript = Init.SQLScripts[i]
            end
        end
    end
end

function ExecuteSql(query, parameters, cb)
    local promise = promise:new()

    if Utils.SQLScript == "oxmysql" then
        exports.oxmysql:execute(query, parameters, function(data)
            promise:resolve(data)
            if cb then
                cb(data)
            end
        end)
    elseif Utils.SQLScript == "ghmattimysql" then
        exports.ghmattimysql:execute(query, parameters, function(data)
            promise:resolve(data)
            if cb then
                cb(data)
            end
        end)
    elseif Utils.SQLScript == "mysql-async" then
        MySQL.Async.fetchAll(query, parameters, function(data)
            promise:resolve(data)
            if cb then
                cb(data)
            end
        end)
    end
    return Citizen.Await(promise)
end

function GetPlayer(source)
    if Utils.Framework == "es_extended" then
        return Utils.FrameworkObject.GetPlayerFromId(source)
    elseif Utils.Framework == "qb-core" then
        return Utils.FrameworkObject.Functions.GetPlayer(source)
    end
end

function GetPlayerFromIdentifier(identifier)
    if Utils.Framework == "es_extended" then
        return Utils.FrameworkObject.GetPlayerFromIdentifier(identifier)
    elseif Utils.Framework == "qb-core" then
        return Utils.FrameworkObject.Functions.GetPlayerByCitizenId(identifier)
    end
end

function GetPlayerFromCharacterId(charId)
    if Utils.Framework == "es_extended" then
        return Utils.FrameworkObject.GetPlayerFromCharacterId(charId)
    elseif Utils.Framework == "qb-core" then
        return Utils.FrameworkObject.Functions.GetPlayerByCitizenId(charId)
    end
end

function GetIdentifier(source)
    if Utils.Framework == "es_extended" then
        local player = GetPlayer(source)
        return player.identifier
    elseif Utils.Framework == "qb-core" then
        local player = GetPlayer(source)
        return player.PlayerData.citizenid
    end
end

function GetPlayerSkinData(id)
    id = type(id) == "number" and GetIdentifier(id) or id
    local p = promise:new()
    if Utils.SkinScript == "qb-clothes" then
        ExecuteSql('SELECT * FROM playerskins WHERE citizenid = @citizenid AND active = @active', {
            ['@citizenid'] = id,
            ['@active'] = 1
        }, function(result)
            if result[1] ~= nil then
                p:resolve({tonumber(result[1].model), json.decode(result[1].skin)})
            else
                return p:resolve(nil)
            end
        end)
    elseif Utils.SkinScript == "skinchanger" then
        ExecuteSql('SELECT skin FROM users WHERE identifier = @identifier', {
            ['@identifier'] = id
        }, function(result)
            if result[1] ~= nil then
                p:resolve({GetHashKey(result[1].skin), json.decode(result[1].skin)})
            else
                return p:resolve(nil)
            end
        end)
    elseif Utils.SkinScript == "fivem-appearance" then
        if Config.Framework == "es_extended" then
            ExecuteSql('SELECT skin FROM users WHERE identifier = @identifier', {
                ['@identifier'] = id
            }, function(result)
                if result[1] ~= nil then
                    local resSkin = json.decode(result[1].skin).model
                    p:resolve({resSkin, json.decode(result[1].skin)})
                else
                    return p:resolve(nil)
                end
            end)
        elseif Config.Framework == "qb-core" then
            ExecuteSql('SELECT skin FROM playerskins WHERE citizenid = @citizenid', {
                ['@citizenid'] = id
            }, function(result)
                if result[1] ~= nil then
                    local resSkin = json.decode(result[1].skin).model
                    p:resolve({resSkin, json.decode(result[1].skin)})
                else
                    return p:resolve(nil)
                end
            end)
        end
    elseif Utils.SkinScript == "illenium-appearance" then
        if Utils.Framework == "es_extended" then
            ExecuteSql('SELECT skin FROM users WHERE identifier = @identifier', {
                ['@identifier'] = id
            }, function(result)
                if result[1] ~= nil then
                    local resSkin = json.decode(result[1].skin).model
                    p:resolve({resSkin, json.decode(result[1].skin)})
                else
                    return p:resolve(nil)
                end
            end)
        elseif Utils.Framework == "qb-core" then
            ExecuteSql('SELECT skin FROM playerskins WHERE citizenid = @citizenid', {
                ['@citizenid'] = id
            }, function(result)
                if result[1] ~= nil then
                    local resSkin = json.decode(result[1].skin).model
                    p:resolve({resSkin, json.decode(result[1].skin)})
                else
                    return p:resolve(nil)
                end
            end)
        end
    elseif Utils.SkinScript == "esx_skin" then
        ExecuteSql('SELECT skin FROM users WHERE identifier = @identifier', {
            ['@identifier'] = id
        }, function(result)
            if result[1] ~= nil then
                local resSkin = json.decode(result[1].skin).model
                p:resolve({resSkin, json.decode(result[1].skin)})
            else
                return p:resolve(nil)
            end
        end)
    end
    return Citizen.Await(p)
end

Citizen.CreateThread(function()
    InitalFunc()
end)