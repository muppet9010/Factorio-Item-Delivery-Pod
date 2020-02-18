local ShipCrash = {}
local Commands = require("utility/commands")
local Utils = require("utility/utils")
local Logging = require("utility/logging")
local CrashTypes = require("static-data/crash-types")
local EventScheduler = require("utility/event-scheduler")
local FireTypes = require("static-data/fire-types")

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
    global.ShipCrash.modularShipPartWeight = global.ShipCrash.modularShipPartWeight or 0
end

function ShipCrash.OnLoad()
    Commands.Register("item_delivery_pod-call_crash_ship", {"api-description.item_delivery_pod-call_crash_ship"}, ShipCrash.CallCrashShipCommand, true)
    EventScheduler.RegisterScheduledEventType("ShipCrash.RenewFireScheduledEvent", ShipCrash.RenewFireScheduledEvent)
    EventScheduler.RegisterScheduledEventType("ShipCrash.UpdateFallingShipScheduledEvent", ShipCrash.UpdateFallingShipScheduledEvent)
    remote.add_interface("item_delivery_pod", {call_crash_ship = ShipCrash.CallCrashShip})
end

ShipCrash.OnSettingChanged = function(event)
    local settingName
    if event ~= nil then
        settingName = event.setting
    end
    if settingName == nil or settingName == "item_delivery_pod-modular_ship_part_weight" then
        global.ShipCrash.modularShipPartWeight = settings.global["item_delivery_pod-modular_ship_part_weight"].value
    end
end

function ShipCrash.CallCrashShipCommand(command)
    local args = Commands.GetArgumentsFromCommand(command.parameter)
    if #args <= 2 or #args >= 5 then
        Logging.LogPrint("ERROR: item_delivery_pod-call_crash_ship wrong number of arguments: " .. command.parameter)
        return
    end
    ShipCrash.CallCrashShip(args[1], args[2], args[3], args[4])
end

function ShipCrash.CallCrashShip(targetIn, radiusIn, crashTypeNameIn, contentsIn)
    local validated, targetPos, crashType, typeValue, radiusMin, radiusMax, contents = ShipCrash.ValidateCallData(targetIn, radiusIn, crashTypeNameIn, contentsIn)
    if not validated or targetPos == nil or crashType == nil then
        return
    end

    local surface = game.surfaces[1]
    local playerForce = game.forces[1]

    if crashType.hasTypeValue == false then
        local crashSitePosition = ShipCrash.FindLandWaterPositionNearTarget(targetPos, surface, Utils.RandomLocationInRadius(targetPos, radiusMax, radiusMin), crashType.container.landPlacementTestEntityName, crashType.container.waterPlacementTestEntityName, 10, 5)
        local debrisPieces = ShipCrash.CalculateDebrisPieces(crashType, crashSitePosition, surface)
        ShipCrash.StartCrashShipFalling(crashType.container, crashSitePosition, surface, playerForce, contents, debrisPieces)
        for _, debrisPiece in ipairs(debrisPieces) do
            ShipCrash.StartCrashShipFalling(debrisPiece.debrisType, debrisPiece.position, surface, playerForce)
        end
    else
        local crashSitePosition = Utils.RandomLocationInRadius(targetPos, radiusMax, radiusMin)
        local wreckPieces = ShipCrash.CalculateModularShipWreckPieces(crashType, typeValue, crashSitePosition, surface)
        local contentsPerWreck = {}
        for itemName, count in pairs(contents) do
            contentsPerWreck[itemName] = math.ceil(count / #wreckPieces)
        end
        for _, wreckPiece in ipairs(wreckPieces) do
            local thisContents = {}
            for itemName, count in pairs(contentsPerWreck) do
                thisContents[itemName] = math.min(count, contents[itemName])
                contents[itemName] = contents[itemName] - thisContents[itemName]
            end
            local debrisPieces = ShipCrash.CalculateDebrisPieces(wreckPiece.wreckType, wreckPiece.position, surface)
            ShipCrash.StartCrashShipFalling(wreckPiece.wreckType.container, wreckPiece.position, surface, playerForce, thisContents, debrisPieces)
            for _, debrisPiece in ipairs(debrisPieces) do
                ShipCrash.StartCrashShipFalling(debrisPiece.debrisType, debrisPiece.position, surface, playerForce)
            end
        end
    end
end

function ShipCrash.CalculateModularShipWreckPieces(crashType, typeValue, crashSitePosition, surface)
    local wrecksLeftToAdd = typeValue
    local wreckPlacementGroups = {front = {}, middle = {}, back = {}}
    local wreckPieces = {}
    for _, partSpec in ipairs(crashType.parts) do
        local count = 0
        if partSpec.exactCount ~= nil then
            count = math.min(partSpec.exactCount, wrecksLeftToAdd)
        elseif partSpec.ratioWithMinMax ~= nil then
            count = math.min(math.max(partSpec.ratioWithMinMax.min, math.floor(typeValue * partSpec.ratioWithMinMax.ratio)), partSpec.ratioWithMinMax.max, wrecksLeftToAdd)
        elseif partSpec.ratio ~= nil then
            count = math.min(math.floor(typeValue * partSpec.ratio), wrecksLeftToAdd)
        elseif partSpec.allRemaining ~= nil then
            count = wrecksLeftToAdd
        end
        wrecksLeftToAdd = wrecksLeftToAdd - count
        for i = 1, count do
            table.insert(wreckPlacementGroups[partSpec.placementGroup], partSpec.name)
        end
    end

    local wreckSpacing = crashType.partSpacing
    local maxTotalFrontCount = #wreckPlacementGroups.front
    local maxTotalMiddleCount = #wreckPlacementGroups.middle
    local middleWidthCount = math.max(math.floor(math.sqrt(maxTotalMiddleCount) * 0.9), 1)
    local maxTotalBackCount = #wreckPlacementGroups.back
    local totalWidth = middleWidthCount * wreckSpacing
    local middleRows = math.ceil(maxTotalMiddleCount / middleWidthCount)
    local totalRows = 0
    if maxTotalFrontCount > 0 then
        totalRows = totalRows + 1
    end
    if middleRows > 0 then
        totalRows = totalRows + middleRows
    end
    if maxTotalBackCount > 0 then
        totalRows = totalRows + 1
    end
    crashSitePosition = Utils.ApplyOffsetToPosition(crashSitePosition, {x = 0 + ((totalRows * wreckSpacing) / 2), y = 0})
    local lengthCounter = 0
    local wreckPlacementRadius = 3

    if maxTotalFrontCount > 0 then
        local frontPieceWidth = (totalWidth / maxTotalFrontCount)
        for currentRowFrontCount, wreckTypeName in ipairs(wreckPlacementGroups.front) do
            local wreckType = CrashTypes[wreckTypeName]
            local wreckTypeContainer = wreckType.container
            local yOffset = 0 - (totalWidth / 2) + ((currentRowFrontCount - 1) * frontPieceWidth) + (frontPieceWidth / 2)
            local xOffset = 0 - (lengthCounter * (wreckSpacing + 1)) - ((wreckSpacing + 1) / 2)
            local targetPos = Utils.ApplyOffsetToPosition(crashSitePosition, {x = xOffset, y = yOffset})
            local pos = ShipCrash.FindLandWaterPositionNearTarget(targetPos, surface, Utils.RandomLocationInRadius(targetPos, 0, 2), wreckTypeContainer.landPlacementTestEntityName, wreckTypeContainer.waterPlacementTestEntityName, wreckPlacementRadius, 1)
            table.insert(wreckPieces, {wreckType = wreckType, position = pos})
        end
        lengthCounter = lengthCounter + 1
    end

    if maxTotalMiddleCount > 0 then
        local currentTotalMiddleToDo = maxTotalMiddleCount
        for i = 1, middleRows do
            local maxRowMiddleCount = math.min(math.ceil(maxTotalMiddleCount / middleRows), currentTotalMiddleToDo)
            if currentTotalMiddleToDo - maxRowMiddleCount == 1 then
                maxRowMiddleCount = maxRowMiddleCount + 1
            end
            if maxRowMiddleCount > 0 then
                local middlePieceWidth = (totalWidth / maxRowMiddleCount)
                for currentRowMiddleCount = 1, maxRowMiddleCount do
                    local wreckTypeName = wreckPlacementGroups.middle[currentTotalMiddleToDo]
                    local wreckType = CrashTypes[wreckTypeName]
                    local wreckTypeContainer = wreckType.container
                    local yOffset = (0 - (totalWidth / 2)) + ((currentRowMiddleCount - 1) * middlePieceWidth) + (middlePieceWidth / 2)
                    local xOffset = 0 - ((lengthCounter * wreckSpacing) + (wreckSpacing / 2))
                    local targetPos = Utils.ApplyOffsetToPosition(crashSitePosition, {x = xOffset, y = yOffset})
                    local pos = ShipCrash.FindLandWaterPositionNearTarget(targetPos, surface, Utils.RandomLocationInRadius(targetPos, 0, 2), wreckTypeContainer.landPlacementTestEntityName, wreckTypeContainer.waterPlacementTestEntityName, wreckPlacementRadius, 1)
                    table.insert(wreckPieces, {wreckType = wreckType, position = pos})
                    currentTotalMiddleToDo = currentTotalMiddleToDo - 1
                end
                lengthCounter = lengthCounter + 1
            end
        end
    end

    if maxTotalBackCount > 0 then
        local backPieceWidth = (totalWidth / maxTotalBackCount)
        for currentRowBackCount, wreckTypeName in ipairs(wreckPlacementGroups.back) do
            local wreckType = CrashTypes[wreckTypeName]
            local wreckTypeContainer = wreckType.container
            local yOffset = 0 - (totalWidth / 2) + ((currentRowBackCount - 1) * backPieceWidth) + (backPieceWidth / 2)
            local xOffset = 0 - (lengthCounter * wreckSpacing) - (wreckSpacing / 2)
            local targetPos = Utils.ApplyOffsetToPosition(crashSitePosition, {x = xOffset, y = yOffset})
            local pos = ShipCrash.FindLandWaterPositionNearTarget(targetPos, surface, Utils.RandomLocationInRadius(targetPos, 0, 2), wreckTypeContainer.landPlacementTestEntityName, wreckTypeContainer.waterPlacementTestEntityName, wreckPlacementRadius, 1)
            table.insert(wreckPieces, {wreckType = wreckType, position = pos})
        end
    end

    return wreckPieces
end

function ShipCrash.StartCrashShipFalling(wreckType, crashSitePosition, surface, playerForce, contents, debrisPieces)
    local data = {
        targetPos = crashSitePosition,
        surface = surface,
        playerForce = playerForce,
        contents = contents,
        wreckType = wreckType,
        ticksFallingCount = 0,
        wreckTypeShadowScale = wreckType.shadowSize / 7,
        shipRenderId = nil,
        shadowRenderId = nil,
        shadowScale = 0,
        shipScale = 0,
        debrisPieces = debrisPieces
    }
    data = ShipCrash.UpdateShipShadowData(data)
    data.shadowRenderId =
        rendering.draw_sprite {
        sprite = "item_delivery_pod-generic_falling_shadow",
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
        if data.debrisPieces ~= nil then
            ShipCrash.SpawnCrashShipOnGround(data.wreckType, data.targetPos, data.surface, data.playerForce, data.contents, data.debrisPieces)
        end
        return
    end

    data = ShipCrash.UpdateShipShadowData(data)
    if data.shipRenderId == nil and data.currentHeight <= ShipCrash.shipCreateHeight then
        data.shipRenderId =
            rendering.draw_sprite {
            sprite = data.wreckType.entityName .. "_falling",
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
    local imageScale = ShipCrash.startingImageScale + (ShipCrash.imageScaleChangePerTick * data.ticksFallingCount)
    data.shipScale = imageScale
    data.shadowScale = imageScale * data.wreckTypeShadowScale
    return data
end

function ShipCrash.CalculateShadowForShip(shipPos, currentHeigt)
    return {
        x = shipPos.x + (ShipCrash.shadowGroundOffsetMultiplier.x * currentHeigt),
        y = shipPos.y + currentHeigt + (ShipCrash.shadowGroundOffsetMultiplier.y * currentHeigt)
    }
end

function ShipCrash.SpawnCrashShipOnGround(wreckType, crashSitePosition, surface, playerForce, contents, debrisPieces)
    local wreckTypeExplosionName = wreckType.explosionName
    if surface.get_tile(crashSitePosition.x, crashSitePosition.y).collides_with("water-tile") then
        wreckTypeExplosionName = wreckTypeExplosionName .. "_water"
    end
    surface.create_entity {name = wreckTypeExplosionName, position = crashSitePosition}
    for _, debrisPiece in ipairs(debrisPieces) do
        local debrisTypeExplosionName = debrisPiece.debrisType.explosionName
        if surface.get_tile(debrisPiece.position.x, debrisPiece.position.y).collides_with("water-tile") then
            debrisTypeExplosionName = debrisTypeExplosionName .. "_water"
        end
        surface.create_entity {name = debrisTypeExplosionName, position = debrisPiece.position}
    end
    ShipCrash.CreateContainer(wreckType, surface, crashSitePosition, contents, playerForce)
    for _, debrisPiece in ipairs(debrisPieces) do
        ShipCrash.CreateDebris(debrisPiece.debrisType, surface, debrisPiece.position, playerForce)
    end
end

function ShipCrash.CalculateDebrisPieces(parentType, crashSitePosition, surface)
    local debrisPieces = {}
    if parentType.debris == nil or parentType.debris == 0 then
        return debrisPieces
    end
    local minRadius = parentType.container.killRadius
    local maxRadius = parentType.container.killRadius + (parentType.container.killRadius * 0.5)

    local debrisType = CrashTypes.debris
    local totalDebrisCount = math.random(parentType.debris - 1, parentType.debris + 1)
    for i = 1, totalDebrisCount do
        local pos
        local attempts = 0
        while pos == nil do
            attempts = attempts + 1
            pos = ShipCrash.FindLandWaterPositionNearTarget(crashSitePosition, surface, Utils.RandomLocationInRadius(crashSitePosition, minRadius, maxRadius), debrisType.landPlacementTestEntityName, debrisType.waterPlacementTestEntityName, 2, 1)
            if pos ~= nil then
                if attempts > 100 then
                    break
                end
                for _, otherDebrisPiece in ipairs(debrisPieces) do
                    if Utils.GetDistance(pos, otherDebrisPiece.position) < 3 then
                        pos = nil
                        break
                    end
                end
            end
        end
        table.insert(debrisPieces, {debrisType = debrisType, position = pos})
    end
    return debrisPieces
end

function ShipCrash.FindLandWaterPositionNearTarget(parentPos, surface, testPos, landEntityName, waterEntityName, accuracy, attempts)
    local landPos = Utils.GetValidPositionForEntityNearPosition(landEntityName, surface, testPos, accuracy, attempts, 0.2, true)
    local waterPos = Utils.GetValidPositionForEntityNearPosition(waterEntityName, surface, testPos, accuracy, attempts, 0.2, true)
    if landPos ~= nil and waterPos ~= nil then
        if Utils.GetDistance(landPos, parentPos) <= Utils.GetDistance(waterPos, parentPos) then
            return landPos
        else
            return waterPos
        end
    elseif landPos ~= nil then
        return landPos
    elseif waterPos ~= nil then
        return waterPos
    else
        return nil
    end
end

function ShipCrash.CreateDebris(debrisType, surface, position, playerForce)
    local debrisEntityName = debrisType.entityName
    if surface.get_tile(position.x, position.y).collides_with("water-tile") then
        debrisEntityName = debrisEntityName .. "_water"
    end
    surface.create_entity {name = debrisEntityName, position = position, force = playerForce}
    ShipCrash.CreateCraterImpact(debrisType.craterName, debrisType.rocks, debrisType.killRadius, surface, position)
    local fireOnWater = false
    if surface.get_tile(position.x, position.y).collides_with("water-tile") then
        fireOnWater = true
    end
    ShipCrash.CreateRandomLengthFire(math.random(2, 3), surface, position, 25, 40, fireOnWater)
    surface.create_entity {name = debrisType.impactEffectName, position = position}
end

function ShipCrash.CreateContainer(containerDetails, surface, position, contents, playerForce)
    local containerEntityName = containerDetails.entityName
    if surface.get_tile(position.x, position.y).collides_with("water-tile") then
        containerEntityName = containerEntityName .. "_water"
    end
    local containerEntity = surface.create_entity {name = containerEntityName, position = position, force = playerForce}
    containerEntity.operable = false
    containerEntity.destructible = false
    for itemName, count in pairs(contents) do
        if count > 0 then
            containerEntity.get_inventory(defines.inventory.chest).insert({name = itemName, count = count})
        end
    end
    ShipCrash.CreateCraterImpact(containerDetails.craterName, containerDetails.rocks, containerDetails.killRadius, surface, position)
    surface.create_entity {name = containerDetails.impactEffectName, position = position}
end

function ShipCrash.CreateCraterImpact(craterName, rocks, radius, surface, craterPosition)
    local rockDecoratives = {"rock-medium", "rock-small", "rock-tiny", "sand-rock-medium", "sand-rock-small"}
    local killDecorativesArea = Utils.CalculateBoundingBoxFromPositionAndRange(craterPosition, radius)
    surface.destroy_decoratives {area = killDecorativesArea, name = rockDecoratives, invert = true}
    if not surface.get_tile(craterPosition.x, craterPosition.y).collides_with("water-tile") then
        surface.create_entity {name = craterName, position = craterPosition}
    end
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

    if not surface.get_tile(craterPosition.x, craterPosition.y).collides_with("water-tile") then
        local fireMinRadius = radius * 0.25
        local fireMaxRadius = radius * 0.75
        local fireCount = math.ceil(math.sqrt(rocks["small"]) / 2)
        ShipCrash.PlaceFireRandomlyWithinRadius(fireCount, surface, craterPosition, fireMinRadius, fireMaxRadius)
        fireMinRadius = radius * 1
        fireMaxRadius = radius * 2
        fireCount = math.floor(math.sqrt(rocks["small"]) * 1.5)
        ShipCrash.PlaceFireRandomlyWithinRadius(fireCount, surface, craterPosition, fireMinRadius, fireMaxRadius)
    else
        local fireMinRadius = 0
        local fireMaxRadius = radius * 0.5
        local fireCount = math.ceil(math.sqrt(rocks["small"]) / 2)
        ShipCrash.PlaceFireRandomlyWithinRadius(fireCount, surface, craterPosition, fireMinRadius, fireMaxRadius, true)
    end
end

function ShipCrash.PlaceFireRandomlyWithinRadius(fireCount, surface, craterPosition, minRadius, maxRadius, allowFireOnWater)
    fireCount = math.random(math.floor(fireCount * 0.75), math.floor(fireCount * 1.25))
    for i = 1, fireCount do
        local pos = Utils.RandomLocationInRadius(craterPosition, minRadius, maxRadius)
        local fireOnWater
        if not surface.get_tile(pos.x, pos.y).collides_with("water-tile") then
            fireOnWater = false
        elseif allowFireOnWater then
            fireOnWater = true
        else
            return
        end
        ShipCrash.CreateRandomLengthFire(math.random(1, 2), surface, pos, 16, 30, fireOnWater)
    end
end

function ShipCrash.CreateRandomLengthFire(fireCount, surface, position, minSecondsPerFlame, maxSecondsPerFlame, fireOnWater)
    local entityName = "item_delivery_pod-debris_fire_flame"
    if fireOnWater then
        entityName = "item_delivery_pod-debris_fire_flame_water"
    end
    surface.create_entity {name = entityName, position = position, initial_ground_flame_count = fireCount}
    local secondsPerFlame = math.random(minSecondsPerFlame, maxSecondsPerFlame)
    local flameInstanceId = global.ShipCrash.fireEntityInstanceId
    global.ShipCrash.fireEntityInstanceId = global.ShipCrash.fireEntityInstanceId + 1
    local fireLifetime = FireTypes["debris"].initialLifetime
    EventScheduler.ScheduleEvent(game.tick + fireLifetime, "ShipCrash.RenewFireScheduledEvent", flameInstanceId, {fireCount = fireCount, surface = surface, position = position, secondsPerFlame = secondsPerFlame, currentBurnTime = fireLifetime, fireOnWater = fireOnWater})
end

function ShipCrash.RenewFireScheduledEvent(event)
    local fireLifetime = FireTypes["debris"].initialLifetime
    local data = event.data
    if data.currentBurnTime >= data.secondsPerFlame then
        data.fireCount = data.fireCount - 1
        data.currentBurnTime = fireLifetime
    else
        data.currentBurnTime = data.currentBurnTime + fireLifetime
    end
    if data.fireCount <= 0 then
        return
    end
    local entityName = "item_delivery_pod-debris_fire_flame"
    if data.fireOnWater then
        entityName = "item_delivery_pod-debris_fire_flame_water"
    end
    data.surface.create_entity {name = entityName, position = data.position, initial_ground_flame_count = data.fireCount}
    EventScheduler.ScheduleEvent(event.tick + fireLifetime, "ShipCrash.RenewFireScheduledEvent", event.instanceId, data)
end

function ShipCrash.PlaceRocksRandomlyWithinRadius(rockCount, rockEntityNames, surface, craterPosition, minRadius, maxRadius)
    rockCount = math.random(math.floor(rockCount * 0.75), math.floor(rockCount * 1.25))
    for i = 1, rockCount do
        local pos = Utils.RandomLocationInRadius(craterPosition, minRadius, maxRadius)
        if not surface.get_tile(pos.x, pos.y).collides_with("water-tile") then
            local rockEntityName = rockEntityNames[math.random(#rockEntityNames)]
            surface.create_decoratives {decoratives = {{name = rockEntityName, position = pos, amount = 1}}}
        end
    end
end

function ShipCrash.ValidateCallData(targetIn, radiusIn, crashTypeNameIn, contentsIn)
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
                typeValue = math.floor(weight / global.ShipCrash.modularShipPartWeight)
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

return ShipCrash
