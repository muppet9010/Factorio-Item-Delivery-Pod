local ShipCrash = {}
local Commands = require("utility/commands")
local Utils = require("utility/utils")
local Logging = require("utility/logging")
local CrashTypes = require("static-data/crash-types")
local DebrisTypes = require("static-data/debris-types")

function ShipCrash.OnLoad()
    Commands.Register("item_delivery_pod-call_crash_ship", {"api-description.item_delivery_pod-call_crash_ship"}, ShipCrash.CallCrashShipCommand, true)
end

function ShipCrash.CallCrashShipCommand(command)
    local args = Commands.GetArgumentsFromCommand(command.parameter)
    if #args < 3 or #args > 4 then
        Logging.LogPrint("ERROR: item_delivery_pod-call_crash_ship wrong number of arguments: " .. command.parameter)
        return
    end
    ShipCrash.CallCrashShip(args[1], args[2], args[3], args[4])
end

function ShipCrash.CallCrashShip(target, radius, crashTypeName, contents)
    local targetPos, crashType, typeValue = ShipCrash.ValidateCallData(target, radius, crashTypeName, contents)
    if targetPos == nil or crashType == nil then
        return
    end

    local crashSitePosition = Utils.RandomLocationInRadius(targetPos, radius)
    local surface = game.surfaces[1]
    local playerForce = game.forces[1]

    --TODO: do falling effect before doing the ground impact
    ShipCrash.SpawnCrashShipOnGround(crashType, typeValue, crashSitePosition, surface, playerForce, contents)
end

function ShipCrash.SpawnCrashShipOnGround(crashType, typeValue, crashSitePosition, surface, playerForce, contents)
    if crashType.hasTypeValue == false then
        surface.create_entity {name = crashType.container.explosionName, position = crashSitePosition}
        local debrisPieces = ShipCrash.CalculateDebris(crashType, crashSitePosition)
        for _, debrisPiece in ipairs(debrisPieces) do
            surface.create_entity {name = debrisPiece.debrisType.explosionName, position = debrisPiece.position}
        end
        ShipCrash.CreateContainer(crashType.container, surface, crashSitePosition, contents, playerForce)
        for _, debrisPiece in ipairs(debrisPieces) do
            ShipCrash.CreateDebris(debrisPiece.debrisType, surface, debrisPiece.position, playerForce)
        end
    else
        --TODO
        game.print("MODULAR CRASH NOT CODED YET")
    end
end

function ShipCrash.CalculateDebris(parentType, crashSitePosition)
    local debrisPieces = {}
    if parentType.debris == nil then
        return debrisPieces
    end
    local minRadius = parentType.container.killRadius - (parentType.container.killRadius * 0.25)
    local maxRadius = parentType.container.killRadius + (parentType.container.killRadius * 0.25)
    for debrisSize, debrisCount in pairs(parentType.debris) do
        local debrisType = DebrisTypes[debrisSize]
        for i = 1, math.random(debrisCount - 1, debrisCount + 1) do
            table.insert(
                debrisPieces,
                {
                    debrisType = debrisType,
                    position = Utils.RandomLocationInRadius(crashSitePosition, minRadius, maxRadius)
                }
            )
        end
    end
    return debrisPieces
end

function ShipCrash.CreateDebris(debrisType, surface, position, playerForce)
    surface.create_entity {name = debrisType.entityName, position = position, force = playerForce}
    ShipCrash.CreateCraterImpact(debrisType.craterName, debrisType.rocks, debrisType.killRadius, surface, position)
    surface.create_entity {name = "item_delivery_pod-debris_fire_flame", position = position, initial_ground_flame_count = 10}
end

function ShipCrash.CreateContainer(containerDetails, surface, position, contents, playerForce)
    local containerEntity = surface.create_entity {name = containerDetails.entityName, position = position, force = playerForce}
    containerEntity.operable = false
    containerEntity.destructible = false
    if contents ~= nil then
        for itemName, count in pairs(contents) do
            if count > 0 then
                containerEntity.get_inventory(defines.inventory.chest).insert({name = itemName, count = count})
            end
        end
    end
    ShipCrash.CreateCraterImpact(containerDetails.craterName, containerDetails.rocks, containerDetails.killRadius, surface, position)
    --TODO: create some fire around the container
end

function ShipCrash.CreateCraterImpact(craterName, rocks, radius, surface, craterPosition)
    surface.create_entity {name = craterName, position = craterPosition}
    for rockSize, rockCount in pairs(rocks) do
        if rockSize == "medium" then
            local minRadius = radius / 2
            local maxRadius = radius
            local rockEntityNames = {"rock-medium", "sand-rock-medium"}
            ShipCrash.PlaceRocksRandomlyWithinRadius(rockCount, rockEntityNames, surface, craterPosition, minRadius, maxRadius)
        elseif rockSize == "small" then
            local minRadius = radius - (radius / 2)
            local maxRadius = radius + (radius / 4)
            local rockEntityNames = {"rock-small", "sand-rock-small"}
            ShipCrash.PlaceRocksRandomlyWithinRadius(rockCount, rockEntityNames, surface, craterPosition, minRadius, maxRadius)
        elseif rockSize == "tiny" then
            local minRadius = radius
            local maxRadius = radius + (radius / 2)
            local rockEntityNames = {"rock-tiny"}
            ShipCrash.PlaceRocksRandomlyWithinRadius(rockCount, rockEntityNames, surface, craterPosition, minRadius, maxRadius)
        end
    end
end

function ShipCrash.PlaceRocksRandomlyWithinRadius(rockCount, rockEntityNames, surface, craterPosition, minRadius, maxRadius)
    rockCount = math.random(math.floor(rockCount * 0.75), math.floor(rockCount * 1.25))
    for i = 1, rockCount do
        local pos = Utils.RandomLocationInRadius(craterPosition, minRadius, maxRadius)
        local rockEntityName = rockEntityNames[math.random(#rockEntityNames)]
        surface.create_decoratives {decoratives = {{name = rockEntityName, position = pos, amount = 1}}}
    end
end

function ShipCrash.ValidateCallData(target, radius, crashTypeName, contents)
    local targetPos
    if type(target) == "string" then
        local targetPlayer = game.get_player(target)
        if targetPlayer == nil then
            Logging.LogPrint("Error: call_crash_ship invalid target player: " .. target)
            return
        end
        targetPos = targetPlayer.position
    elseif type(target) == "table" then
        targetPos = Utils.TableToProperPosition(target)
        if targetPos == nil then
            Logging.LogPrint("Error: call_crash_ship invalid target position: " .. serpent.block(target))
            return
        end
    else
        Logging.LogPrint("Error: call_crash_ship invalid target value: " .. tostring(target))
        return
    end
    if type(radius) ~= "number" or radius < 0 then
        Logging.LogPrint("Error: call_crash_ship invalid radius positive number value: " .. tostring(radius))
        return
    end
    local crashType = CrashTypes[crashTypeName]
    if crashType == nil then
        for _, thisCrashType in pairs(CrashTypes) do
            if thisCrashType.hasTypeValue == true then
                if string.find(crashTypeName, thisCrashType.name) ~= nil then
                    crashType = thisCrashType
                    break
                end
            end
        end
    end
    if crashType == nil then
        Logging.LogPrint("Error: call_crash_ship invalid crashTypeName: " .. tostring(crashTypeName))
        return
    end
    local typeValue
    if crashType.hasTypeValue then
        typeValue = string.gsub(crashTypeName, crashType.name, "")
        if typeValue == nil or typeValue == "" or typeValue == " " then
            Logging.LogPrint("Error: call_crash_ship invalid value on this crash type: " .. tostring(crashTypeName))
            return
        end
    end
    if type(contents) == "table" then
        for itemName, quantity in pairs(contents) do
            if game.item_prototypes[itemName] == nil then
                Logging.LogPrint("Error: call_crash_ship invalid content item: " .. tostring(itemName))
                return
            elseif type(quantity) ~= "number" or quantity < 0 then
                Logging.LogPrint("Error: call_crash_ship invalid content item count for '" .. itemName .. "': " .. tostring(quantity))
                return
            end
        end
    elseif type(contents) ~= "nil" then
        Logging.LogPrint("Error: call_crash_ship invalid contents argument: " .. tostring(contents))
        return
    end

    return targetPos, crashType, typeValue
end

return ShipCrash