-- Manager does the strategic oversight of the mod crashing ship actions.

local ShipCrashManager = {}
local Commands = require("utility/commands")
local Utils = require("utility/utils")
local Logging = require("utility/logging")
local CrashTypes = require("static-data/crash-types")
local ShipCrashController = require("scripts/ship-crash-controller")

ShipCrashManager.CreateGlobals = function()
    global.shipCrashManager = global.shipCrashManager or {}
    global.shipCrashManager.fireEntityInstanceId = global.shipCrashManager.fireEntityInstanceId or 1
    global.shipCrashManager.modularShipPartWeight = global.shipCrashManager.modularShipPartWeight or 0
end

ShipCrashManager.OnLoad = function()
    Commands.Register("item_delivery_pod-call_crash_ship", {"api-description.item_delivery_pod-call_crash_ship"}, ShipCrashManager.CallCrashShipCommand, true)
    remote.add_interface("item_delivery_pod", {call_crash_ship = ShipCrashManager.CallCrashShip})
end

ShipCrashManager.OnSettingChanged = function(event)
    local settingName
    if event ~= nil then
        settingName = event.setting
    end
    if settingName == nil or settingName == "item_delivery_pod-modular_ship_part_weight" then
        global.shipCrashManager.modularShipPartWeight = settings.global["item_delivery_pod-modular_ship_part_weight"].value
    end
end

ShipCrashManager.CallCrashShipCommand = function(command)
    local args = Commands.GetArgumentsFromCommand(command.parameter)
    if #args <= 2 or #args >= 5 then
        Logging.LogPrint("ERROR: item_delivery_pod-call_crash_ship wrong number of arguments: " .. command.parameter)
        return
    end
    ShipCrashManager.CallCrashShip(args[1], args[2], args[3], args[4])
end

ShipCrashManager.CallCrashShip = function(targetIn, radiusIn, crashTypeNameIn, contentsIn)
    local validated, targetPos, crashType, typeValue, radiusMin, radiusMax, contents = ShipCrashManager.ValidateCallData(targetIn, radiusIn, crashTypeNameIn, contentsIn)
    if not validated or targetPos == nil or crashType == nil then
        return
    end

    local surface = game.surfaces[1]
    local force = game.forces[1]

    ShipCrashController.BeginShipCrashProcess(targetPos, crashType, typeValue, radiusMin, radiusMax, contents, surface, force)
end

ShipCrashManager.ValidateCallData = function(targetIn, radiusIn, crashTypeNameIn, contentsIn)
    local targetPos
    if type(targetIn) == "string" then
        local targetPlayer = game.get_player(targetIn)
        if targetPlayer == nil then
            Logging.LogPrint("Error: call_crash_ship invalid target player: " .. targetIn)
            return false
        end
        targetPos = targetPlayer.position
    elseif type(targetIn) == "table" then
        targetPos = Utils.TableToProperPosition(targetIn)
        if targetPos == nil then
            Logging.LogPrint("Error: call_crash_ship invalid target position: " .. serpent.block(targetIn))
            return false
        end
    else
        Logging.LogPrint("Error: call_crash_ship invalid target value: " .. tostring(targetIn))
        return false
    end

    local radiusMin, radiusMax = 0
    if type(radiusIn) == "number" then
        radiusMax = radiusIn
    elseif type(radiusIn) == "table" then
        if type(radiusIn[1]) == "number" then
            radiusMin = radiusIn[1]
        else
            Logging.LogPrint("Error: call_crash_ship invalid radius minimum value: " .. tostring(radiusIn[1]))
            return false
        end
        if type(radiusIn[2]) == "number" then
            radiusMax = radiusIn[2]
        else
            Logging.LogPrint("Error: call_crash_ship invalid radius maximum value: " .. tostring(radiusIn[2]))
            return false
        end
    else
        Logging.LogPrint("Error: call_crash_ship invalid radius value: " .. tostring(radiusIn))
        return false
    end
    if radiusMin < 0 then
        Logging.LogPrint("Error: call_crash_ship invalid radius minimum, must be a positive number value: " .. tostring(radiusMin))
        return false
    end
    if radiusMax < 0 then
        Logging.LogPrint("Error: call_crash_ship invalid radius maximum, must be a positive number value: " .. tostring(radiusMax))
        return false
    end

    if type(crashTypeNameIn) ~= "string" then
        Logging.LogPrint("Error: call_crash_ship invalid ship value type: " .. tostring(crashTypeNameIn))
        return false
    end
    local crashType = CrashTypes[crashTypeNameIn]
    if crashType == nil then
        for _, thisCrashType in pairs(CrashTypes) do
            if thisCrashType.hasTypeValue == true then
                if string.find(crashTypeNameIn, thisCrashType.name) ~= nil then
                    crashType = thisCrashType
                    break
                end
            end
        end
    end
    if crashType == nil then
        Logging.LogPrint("Error: call_crash_ship invalid crashTypeName: " .. tostring(crashTypeNameIn))
        return false
    end
    local typeValueString, typeValue
    if crashType.hasTypeValue then
        typeValueString = string.gsub(crashTypeNameIn, crashType.name, "")
        if typeValueString == nil or typeValueString == "" or typeValueString == " " then
            Logging.LogPrint("Error: call_crash_ship invalid value on this crash type: " .. tostring(crashTypeNameIn))
            return false
        end
        typeValue = tonumber(typeValueString)
        if typeValue == nil then
            if string.find(typeValueString, "%-auto%-") ~= nil then
                local weightString = string.gsub(typeValueString, "%-auto%-", "")
                local weight = tonumber(weightString)
                if weight == nil then
                    Logging.LogPrint("Error: call_crash_ship invalid value on this crash type auto weight: " .. tostring(crashTypeNameIn))
                    return false
                end
                typeValue = math.floor(weight / global.shipCrashManager.modularShipPartWeight)
            else
                Logging.LogPrint("Error: call_crash_ship no value on this crash type supplied: " .. tostring(crashTypeNameIn))
                return false
            end
        end
    end

    local contents
    if type(contentsIn) == "table" then
        for itemName, quantity in pairs(contentsIn) do
            if game.item_prototypes[itemName] == nil then
                Logging.LogPrint("Error: call_crash_ship invalid content item: " .. tostring(itemName))
                return false
            elseif type(quantity) ~= "number" or quantity < 0 then
                Logging.LogPrint("Error: call_crash_ship invalid content item count for '" .. itemName .. "': " .. tostring(quantity))
                return false
            end
        end
        contents = contentsIn
    elseif type(contentsIn) == "nil" then
        contents = {}
    else
        Logging.LogPrint("Error: call_crash_ship invalid contents argument: " .. tostring(contentsIn))
        return false
    end

    return true, targetPos, crashType, typeValue, radiusMin, radiusMax, contents
end

return ShipCrashManager
