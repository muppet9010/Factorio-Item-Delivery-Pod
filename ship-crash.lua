local ShipCrash = {}
local Commands = require("utility/commands")
local Utils = require("utility/utils")
local Logging = require("utility/logging")

ShipCrash.crashTypes = {
    tiny = {
        name = "tiny",
        hasTypeValue = false,
        container = {
            entityName = "item_delivery_pod-tiny_wrecked_ship_container",
            craterName = "medium-scorchmark",
            killRadius = 1.5,
            rocks = {
                small = 10,
                tiny = 20
            }
        },
        debris = nil
    },
    small = {
        name = "small",
        hasTypeValue = false,
        container = {
            entityName = "item_delivery_pod-small_wrecked_ship_container",
            craterName = "large-scorchmark",
            killRadius = 3,
            rocks = {
                medium = 7,
                small = 30,
                tiny = 50
            }
        },
        debris = nil
    },
    medium = {
        name = "medium",
        hasTypeValue = false,
        container = {
            entityName = "item_delivery_pod-medium_wrecked_ship_container",
            craterName = "large-scorchmark",
            killRadius = 4.5,
            rocks = {
                medium = 15,
                small = 50,
                tiny = 100
            }
        },
        debris = nil
    },
    large = {
        name = "large",
        hasTypeValue = false,
        container = {
            entityName = "item_delivery_pod-large_wrecked_ship_container",
            craterName = "large-scorchmark",
            killRadius = 6,
            rocks = {
                medium = 30,
                small = 100,
                tiny = 200
            }
        },
        debris = nil
    },
    modular = {
        name = "modular",
        hasTypeValue = true
    }
}

--[[
ShipCrash.craterTypes = {
    small = {
        name = "small",
        entityName = "small-scorchmark",
        killRadius = 0.6 + 0.5,
        rocks = {
            small = 5,
            tiny = 10
        }
    }
}
]]
function ShipCrash.OnLoad()
    remote.add_interface(
        "item_delivery_pod",
        {
            call_crash_ship = ShipCrash.CallCrashShip
        }
    )
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

    if crashType.hasTypeValue == false then
        ShipCrash.CreateContainer(crashType.container, surface, crashSitePosition, contents, playerForce)
    else
        --TODO
        game.print("MODULAR CRASH NOT CODED YET")
    end
end

function ShipCrash.CreateContainer(containerDetails, surface, crashSitePosition, contents, playerForce)
    ShipCrash.KillAllInCraterImpact(containerDetails.killRadius, surface, crashSitePosition)
    local container = surface.create_entity {name = containerDetails.entityName, position = crashSitePosition, force = playerForce}
    if container == nil then
        Logging.LogPrint("Error: create '" .. containerDetails.entityName .. "' failed at position: " .. Utils.FormatPositionTableToString(crashSitePosition))
        return
    end
    container.operable = false
    if contents ~= nil then
        for itemName, count in pairs(contents) do
            if count > 0 then
                container.get_inventory(defines.inventory.chest).insert({name = itemName, count = count})
            end
        end
    end
    ShipCrash.CreateCraterImpact(containerDetails.craterName, containerDetails.rocks, containerDetails.killRadius, surface, crashSitePosition)
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

function ShipCrash.KillAllInCraterImpact(radius, surface, position)
    for _, entity in pairs(surface.find_entities_filtered {position = position, radius = radius}) do
        entity.die()
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
    local crashType = ShipCrash.crashTypes[crashTypeName]
    if crashType == nil then
        for _, thisCrashType in pairs(ShipCrash.crashTypes) do
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
