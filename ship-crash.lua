local ShipCrash = {}
local Commands = require("utility/commands")
local Utils = require("utility/utils")
local Logging = require("utility/logging")
local CrashTypes = require("static-data/crash-types")
local DebrisTypes = require("static-data/debris-types")
local EventScheduler = require("utility/event-scheduler")
local FireTypes = require("static-data/fire-types")

--[[TODO:
    Make the ship collision box be entirely in or out of water.
    Have effects and graphics based on in or out of water.
    Create medium/massive-explosion entity at impact site of ship/debris bits.
]]
ShipCrash.fallingTicks = 60 * 5
ShipCrash.fallingStartHeight = 500
ShipCrash.fallingTickSpeed = ShipCrash.fallingStartHeight / ShipCrash.fallingTicks
ShipCrash.entryAngle = -30
ShipCrash.shipCreateHeight = 300
ShipCrash.shadowGroundOffsetMultiplier = {x = 60 / 100, y = 48 / 100}
ShipCrash.startingImageScale = 0.1
ShipCrash.imageScaleChangePerTick = (1 - ShipCrash.startingImageScale) / ShipCrash.fallingTicks

function ShipCrash.CreateGlobals()
    global.ShipCrash = global.ShipCrash or {}
    global.ShipCrash.fireEntityInstanceId = global.ShipCrash.fireEntityInstanceId or 1
end

function ShipCrash.OnLoad()
    Commands.Register("item_delivery_pod-call_crash_ship", {"api-description.item_delivery_pod-call_crash_ship"}, ShipCrash.CallCrashShipCommand, true)
    EventScheduler.RegisterScheduledEventType("ShipCrash.RenewFireScheduledEvent", ShipCrash.RenewFireScheduledEvent)
    EventScheduler.RegisterScheduledEventType("ShipCrash.UpdateFallingShipScheduledEvent", ShipCrash.UpdateFallingShipScheduledEvent)
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

    local surface = game.surfaces[1]
    local playerForce = game.forces[1]

    if crashType.hasTypeValue == false then
        local crashSitePosition = Utils.RandomLocationInRadius(targetPos, radius)
        ShipCrash.StartCrashShipFalling(crashType, crashSitePosition, surface, playerForce, contents)
    else
        --TODO
        game.print("MODULAR CRASH NOT CODED YET: " .. typeValue)
    end
end

function ShipCrash.StartCrashShipFalling(crashType, crashSitePosition, surface, playerForce, contents)
    local data = {
        targetPos = crashSitePosition,
        surface = surface,
        force = playerForce,
        contents = contents,
        crashType = crashType,
        ticksFallingCount = 0,
        crashTypeShadowScale = crashType.container.shadowSize / 7,
        shipRenderId = nil,
        shadowRenderId = nil,
        shadowScale = 0,
        shipScale = 0
    }
    data = ShipCrash.UpdateShipShadowData(data)
    data.shadowRenderId =
        rendering.draw_sprite {
        sprite = "item_delivery_pod-generic_wreck_sprite",
        target = data.shadowPos,
        surface = data.surface,
        x_scale = data.shadowScale,
        y_scale = data.shadowScale
    }
    EventScheduler.ScheduleEvent(game.tick + 1, "ShipCrash.UpdateFallingShipScheduledEvent", data.shadowRenderId, data)
end

function ShipCrash.UpdateFallingShipScheduledEvent(event)
    local data = event.data
    data.ticksFallingCount = data.ticksFallingCount + 1
    if data.ticksFallingCount > ShipCrash.fallingTicks then
        rendering.destroy(data.shadowRenderId)
        rendering.destroy(data.shipRenderId)
        ShipCrash.SpawnCrashShipOnGround(data.crashType, data.targetPos, data.surface, data.playerForce, data.contents)
        return
    end

    data = ShipCrash.UpdateShipShadowData(data)
    if data.shipRenderId == nil and data.currentHeight <= ShipCrash.shipCreateHeight then
        data.shipRenderId =
            rendering.draw_sprite {
            sprite = data.crashType.container.entityName .. "_falling",
            target = data.shipPos,
            surface = data.surface,
            x_scale = data.shipScale,
            y_scale = data.shipScale
        }
    elseif data.shipRenderId ~= nil then
        rendering.set_target(data.shipRenderId, data.shipPos)
        rendering.set_x_scale(data.shipRenderId, data.shipScale)
        rendering.set_y_scale(data.shipRenderId, data.shipScale)
    end

    rendering.set_target(data.shadowRenderId, data.shadowPos)
    rendering.set_x_scale(data.shadowRenderId, data.shadowScale)
    rendering.set_y_scale(data.shadowRenderId, data.shadowScale)
    EventScheduler.ScheduleEvent(event.tick + 1, "ShipCrash.UpdateFallingShipScheduledEvent", data.shadowRenderId, data)
end

function ShipCrash.UpdateShipShadowData(data)
    data.currentHeight = ShipCrash.fallingStartHeight - (ShipCrash.fallingTickSpeed * data.ticksFallingCount)
    data.shipPos = Utils.GetPositionForAngledDistance(data.targetPos, data.currentHeight, ShipCrash.entryAngle)
    data.shadowPos = ShipCrash.CalculateShadowForShip(data.shipPos, data.currentHeight)
    --[[Logging.Log("currentHeight: " .. data.currentHeight)
    Logging.Log("shipPos: " .. Logging.PositionToString(data.shipPos))
    Logging.Log("shadowPos: " .. Logging.PositionToString(data.shadowPos))
    Logging.Log("")]]
    local imageScale = ShipCrash.startingImageScale + (ShipCrash.imageScaleChangePerTick * data.ticksFallingCount)
    data.shipScale = imageScale
    data.shadowScale = imageScale * data.crashTypeShadowScale
    return data
end

function ShipCrash.CalculateShadowForShip(shipPos, currentHeigt)
    return {
        x = shipPos.x + (ShipCrash.shadowGroundOffsetMultiplier.x * currentHeigt),
        y = shipPos.y + currentHeigt + (ShipCrash.shadowGroundOffsetMultiplier.y * currentHeigt)
    }
end

function ShipCrash.SpawnCrashShipOnGround(crashType, crashSitePosition, surface, playerForce, contents)
    surface.create_entity {name = crashType.container.explosionName, position = crashSitePosition}
    local debrisPieces = ShipCrash.CalculateDebris(crashType, crashSitePosition)
    for _, debrisPiece in ipairs(debrisPieces) do
        surface.create_entity {name = debrisPiece.debrisType.explosionName, position = debrisPiece.position}
    end
    ShipCrash.CreateContainer(crashType.container, surface, crashSitePosition, contents, playerForce)
    for _, debrisPiece in ipairs(debrisPieces) do
        ShipCrash.CreateDebris(debrisPiece.debrisType, surface, debrisPiece.position, playerForce)
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
    ShipCrash.CreateRandomLengthFire(math.random(2, 3), surface, position, 5, 10)
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

    local fireMinRadius = radius * 0.25
    local fireMaxRadius = radius * 1.25
    local fireCount = math.ceil(math.sqrt(rocks["small"]) * 1.5)
    ShipCrash.PlaceFireRandomlyWithinRadius(fireCount, surface, craterPosition, fireMinRadius, fireMaxRadius)
end

function ShipCrash.PlaceFireRandomlyWithinRadius(fireCount, surface, craterPosition, minRadius, maxRadius)
    fireCount = math.random(math.floor(fireCount * 0.75), math.floor(fireCount * 1.5))
    for i = 1, fireCount do
        local pos = Utils.RandomLocationInRadius(craterPosition, minRadius, maxRadius)
        ShipCrash.CreateRandomLengthFire(math.random(1, 2), surface, pos, 4, 7)
    end
end

function ShipCrash.CreateRandomLengthFire(fireCount, surface, position, minSecondsPerFlame, maxSecondsPerFlame)
    surface.create_entity {name = "item_delivery_pod-debris_fire_flame", position = position, initial_ground_flame_count = fireCount}
    local secondsPerFlame = math.random(minSecondsPerFlame, maxSecondsPerFlame)
    local flameInstanceId = global.ShipCrash.fireEntityInstanceId
    global.ShipCrash.fireEntityInstanceId = global.ShipCrash.fireEntityInstanceId + 1
    EventScheduler.ScheduleEvent(game.tick + FireTypes["debris"].initialLifetime, "ShipCrash.RenewFireScheduledEvent", flameInstanceId, {fireCount = fireCount, surface = surface, position = position, secondsPerFlame = secondsPerFlame, currentBurnTime = 1})
end

function ShipCrash.RenewFireScheduledEvent(event)
    local data = event.data
    if data.currentBurnTime >= data.secondsPerFlame then
        data.fireCount = data.fireCount - 1
        data.currentBurnTime = 1
    else
        data.currentBurnTime = data.currentBurnTime + 1
    end
    if data.fireCount <= 0 then
        return
    end
    data.surface.create_entity {name = "item_delivery_pod-debris_fire_flame", position = data.position, initial_ground_flame_count = data.fireCount}
    EventScheduler.ScheduleEvent(event.tick + FireTypes["debris"].initialLifetime, "ShipCrash.RenewFireScheduledEvent", event.instanceId, data)
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
