-- does the tactical process of crashing a specific ship.

local ShipCrashController = {}
local FireTypes = require("static-data/fire-types")
local Utils = require("utility/utils")
local CrashTypes = require("static-data/crash-types")
local EventScheduler = require("utility/event-scheduler")

ShipCrashController.fallingTicks = 60 * 5
ShipCrashController.fallingStartHeight = 500
ShipCrashController.fallingTickSpeed = ShipCrashController.fallingStartHeight / ShipCrashController.fallingTicks
ShipCrashController.entryAngle = -30
ShipCrashController.shipCreateHeight = 300
ShipCrashController.shadowGroundOffsetMultiplier = {x = 60 / 100, y = 48 / 100}
ShipCrashController.startingImageScale = 0.1
ShipCrashController.imageScaleChangePerTick = (1 - ShipCrashController.startingImageScale) / ShipCrashController.fallingTicks

ShipCrashController.CreateGlobals = function()
    global.shipCrashController = global.shipCrashController or {}
    global.shipCrashController.fireEntityInstanceId = global.shipCrashController.fireEntityInstanceId or 1
end

ShipCrashController.OnLoad = function()
    EventScheduler.RegisterScheduledEventType("ShipCrashController.RenewFireScheduledEvent", ShipCrashController.RenewFireScheduledEvent)
    EventScheduler.RegisterScheduledEventType("ShipCrashController.UpdateFallingShipScheduledEvent", ShipCrashController.UpdateFallingShipScheduledEvent)
    EventScheduler.RegisterScheduledEventType("ShipCrashController.SpawnCrashShipOnGround", ShipCrashController.SpawnCrashShipOnGround)
end

ShipCrashController.BeginShipCrashProcess = function(targetPos, crashType, typeValue, radiusMin, radiusMax, contents, surface, force)
    if crashType.hasTypeValue == false then
        local crashSitePosition = ShipCrashController.FindLandWaterPositionNearTarget(targetPos, surface, Utils.RandomLocationInRadius(targetPos, radiusMax, radiusMin), crashType.container.landPlacementTestEntityName, crashType.container.waterPlacementTestEntityName, 10, 5)
        local debrisPieces = ShipCrashController.CalculateDebrisPieces(crashType, crashSitePosition, surface)
        ShipCrashController.StartCrashShipFalling(crashType.container, crashSitePosition, surface, force, contents, debrisPieces)
        for _, debrisPiece in ipairs(debrisPieces) do
            ShipCrashController.StartCrashShipFalling(debrisPiece.debrisType, debrisPiece.position, surface, force)
        end
    else
        local crashSitePosition = Utils.RandomLocationInRadius(targetPos, radiusMax, radiusMin)
        local wreckPieces = ShipCrashController.CalculateModularShipWreckPieces(crashType, typeValue, crashSitePosition, surface)
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
            local debrisPieces = ShipCrashController.CalculateDebrisPieces(wreckPiece.wreckType, wreckPiece.position, surface)
            ShipCrashController.StartCrashShipFalling(wreckPiece.wreckType.container, wreckPiece.position, surface, force, thisContents, debrisPieces)
            for _, debrisPiece in ipairs(debrisPieces) do
                ShipCrashController.StartCrashShipFalling(debrisPiece.debrisType, debrisPiece.position, surface, force)
            end
        end
    end
end

ShipCrashController.CalculateModularShipWreckPieces = function(crashType, typeValue, crashSitePosition, surface)
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
            local yOffset = 0 - (totalWidth / 3) + ((currentRowFrontCount - 1) * frontPieceWidth) + (frontPieceWidth / 2)
            local xOffset = 0 - (lengthCounter * (wreckSpacing + 1)) - ((wreckSpacing + 1) / 2)
            local targetPos = Utils.ApplyOffsetToPosition(crashSitePosition, {x = xOffset, y = yOffset})
            local pos = ShipCrashController.FindLandWaterPositionNearTarget(targetPos, surface, Utils.RandomLocationInRadius(targetPos, 0, 2), wreckTypeContainer.landPlacementTestEntityName, wreckTypeContainer.waterPlacementTestEntityName, wreckPlacementRadius, 1)
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
                    local yOffset = (0 - (totalWidth / 3)) + ((currentRowMiddleCount - 1) * middlePieceWidth) + (middlePieceWidth / 2)
                    local xOffset = 0 - ((lengthCounter * wreckSpacing) + (wreckSpacing / 2))
                    local targetPos = Utils.ApplyOffsetToPosition(crashSitePosition, {x = xOffset, y = yOffset})
                    local pos = ShipCrashController.FindLandWaterPositionNearTarget(targetPos, surface, Utils.RandomLocationInRadius(targetPos, 0, 2), wreckTypeContainer.landPlacementTestEntityName, wreckTypeContainer.waterPlacementTestEntityName, wreckPlacementRadius, 1)
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
            local pos = ShipCrashController.FindLandWaterPositionNearTarget(targetPos, surface, Utils.RandomLocationInRadius(targetPos, 0, 2), wreckTypeContainer.landPlacementTestEntityName, wreckTypeContainer.waterPlacementTestEntityName, wreckPlacementRadius, 1)
            table.insert(wreckPieces, {wreckType = wreckType, position = pos})
        end
    end

    return wreckPieces
end

ShipCrashController.StartCrashShipFalling = function(wreckType, crashSitePosition, surface, playerForce, contents, debrisPieces)
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
    data = ShipCrashController.UpdateShipShadowData(data)
    data.shadowRenderId =
        rendering.draw_sprite {
        sprite = "item_delivery_pod-generic_falling_shadow",
        target = data.shadowPos,
        surface = data.surface,
        x_scale = data.shadowScale,
        y_scale = data.shadowScale
    }
    EventScheduler.ScheduleEvent(game.tick + 1, "ShipCrashController.UpdateFallingShipScheduledEvent", data.shadowRenderId, data)
end

ShipCrashController.UpdateFallingShipScheduledEvent = function(event)
    local data = event.data
    data.ticksFallingCount = data.ticksFallingCount + 1
    if data.ticksFallingCount > ShipCrashController.fallingTicks then
        rendering.destroy(data.shadowRenderId)
        rendering.destroy(data.shipRenderId)
        if data.debrisPieces ~= nil then
            ShipCrashController.ExplodeCrashShipOnGround(data)
        end
        return
    end

    data = ShipCrashController.UpdateShipShadowData(data)
    if data.shipRenderId == nil and data.currentHeight <= ShipCrashController.shipCreateHeight then
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
    EventScheduler.ScheduleEvent(event.tick + 1, "ShipCrashController.UpdateFallingShipScheduledEvent", data.shadowRenderId, data)
end

ShipCrashController.UpdateShipShadowData = function(data)
    data.currentHeight = ShipCrashController.fallingStartHeight - (ShipCrashController.fallingTickSpeed * data.ticksFallingCount)
    data.shipPos = Utils.GetPositionForAngledDistance(data.targetPos, data.currentHeight, ShipCrashController.entryAngle)
    data.shadowPos = ShipCrashController.CalculateShadowForShip(data.shipPos, data.currentHeight)
    local imageScale = ShipCrashController.startingImageScale + (ShipCrashController.imageScaleChangePerTick * data.ticksFallingCount)
    data.shipScale = imageScale
    data.shadowScale = imageScale * data.wreckTypeShadowScale
    return data
end

ShipCrashController.CalculateShadowForShip = function(shipPos, currentHeigt)
    return {
        x = shipPos.x + (ShipCrashController.shadowGroundOffsetMultiplier.x * currentHeigt),
        y = shipPos.y + currentHeigt + (ShipCrashController.shadowGroundOffsetMultiplier.y * currentHeigt)
    }
end

ShipCrashController.ExplodeCrashShipOnGround = function(data)
    local wreckTypeExplosionName = data.wreckType.explosionName
    if data.surface.get_tile(data.targetPos.x, data.targetPos.y).collides_with("water-tile") then
        wreckTypeExplosionName = wreckTypeExplosionName .. "_water"
    end
    data.surface.create_entity {name = wreckTypeExplosionName, position = data.targetPos}
    for _, debrisPiece in ipairs(data.debrisPieces) do
        local debrisTypeExplosionName = debrisPiece.debrisType.explosionName
        if data.surface.get_tile(debrisPiece.position.x, debrisPiece.position.y).collides_with("water-tile") then
            debrisTypeExplosionName = debrisTypeExplosionName .. "_water"
        end
        data.surface.create_entity {name = debrisTypeExplosionName, position = debrisPiece.position}
    end
    EventScheduler.ScheduleEvent(game.tick + 1, "ShipCrashController.SpawnCrashShipOnGround", data.shadowRenderId, data)
end

ShipCrashController.SpawnCrashShipOnGround = function(event)
    local data = event.data
    ShipCrashController.CreateContainer(data.wreckType, data.surface, data.targetPos, data.contents, data.playerForce)
    for _, debrisPiece in ipairs(data.debrisPieces) do
        ShipCrashController.CreateDebris(debrisPiece.debrisType, data.surface, debrisPiece.position, data.playerForce)
    end
end

ShipCrashController.CalculateDebrisPieces = function(parentType, crashSitePosition, surface)
    local debrisPieces = {}
    if parentType.debris == nil or parentType.debris == 0 then
        return debrisPieces
    end
    local minRadius = parentType.container.killRadius - (parentType.container.killRadius * 0.25)
    local maxRadius = parentType.container.killRadius + (parentType.container.killRadius * 0.25)

    local debrisType = CrashTypes.debris
    local totalDebrisCount = math.random(parentType.debris - 1, parentType.debris + 1)
    for i = 1, totalDebrisCount do
        local pos
        local attempts = 0
        while pos == nil do
            attempts = attempts + 1
            pos = ShipCrashController.FindLandWaterPositionNearTarget(crashSitePosition, surface, Utils.RandomLocationInRadius(crashSitePosition, minRadius, maxRadius), debrisType.landPlacementTestEntityName, debrisType.waterPlacementTestEntityName, 2, 1)
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

ShipCrashController.FindLandWaterPositionNearTarget = function(parentPos, surface, testPos, landEntityName, waterEntityName, accuracy, attempts)
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

ShipCrashController.CreateDebris = function(debrisType, surface, position, playerForce)
    local debrisEntityName = debrisType.entityName
    if surface.get_tile(position.x, position.y).collides_with("water-tile") then
        debrisEntityName = debrisEntityName .. "_water"
    end
    surface.create_entity {name = debrisEntityName, position = position, force = playerForce}
    ShipCrashController.CreateCraterImpact(debrisType.craterName, debrisType.rocks, debrisType.killRadius, surface, position)
    local fireOnWater = false
    if surface.get_tile(position.x, position.y).collides_with("water-tile") then
        fireOnWater = true
    end
    ShipCrashController.CreateRandomLengthFire(math.random(2, 3), surface, position, 25, 40, fireOnWater)
    surface.create_entity {name = debrisType.impactEffectName, position = position}
end

ShipCrashController.CreateContainer = function(containerDetails, surface, position, contents, playerForce)
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
    ShipCrashController.CreateCraterImpact(containerDetails.craterName, containerDetails.rocks, containerDetails.killRadius, surface, position)
    surface.create_entity {name = containerDetails.impactEffectName, position = position}
end

ShipCrashController.CreateCraterImpact = function(craterName, rocks, radius, surface, craterPosition)
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
            ShipCrashController.PlaceRocksRandomlyWithinRadius(rockCount, rockEntityNames, surface, craterPosition, minRadius, maxRadius)
        elseif rockSize == "small" then
            local minRadius = radius - (radius / 2)
            local maxRadius = radius + (radius / 4)
            local rockEntityNames = {"rock-small", "sand-rock-small"}
            ShipCrashController.PlaceRocksRandomlyWithinRadius(rockCount, rockEntityNames, surface, craterPosition, minRadius, maxRadius)
        elseif rockSize == "tiny" then
            local minRadius = radius
            local maxRadius = radius + (radius / 2)
            local rockEntityNames = {"rock-tiny"}
            ShipCrashController.PlaceRocksRandomlyWithinRadius(rockCount, rockEntityNames, surface, craterPosition, minRadius, maxRadius)
        end
    end

    if not surface.get_tile(craterPosition.x, craterPosition.y).collides_with("water-tile") then
        local fireMinRadius = radius * 0.25
        local fireMaxRadius = radius * 0.75
        local fireCount = math.ceil(math.sqrt(rocks["small"]) / 2)
        ShipCrashController.PlaceFireRandomlyWithinRadius(fireCount, surface, craterPosition, fireMinRadius, fireMaxRadius)
        fireMinRadius = radius * 1
        fireMaxRadius = radius * 2
        fireCount = math.floor(math.sqrt(rocks["small"]) * 1.5)
        ShipCrashController.PlaceFireRandomlyWithinRadius(fireCount, surface, craterPosition, fireMinRadius, fireMaxRadius)
    else
        local fireMinRadius = 0
        local fireMaxRadius = radius * 0.5
        local fireCount = math.ceil(math.sqrt(rocks["small"]) / 2)
        ShipCrashController.PlaceFireRandomlyWithinRadius(fireCount, surface, craterPosition, fireMinRadius, fireMaxRadius, true)
    end
end

ShipCrashController.PlaceFireRandomlyWithinRadius = function(fireCount, surface, craterPosition, minRadius, maxRadius, allowFireOnWater)
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
        ShipCrashController.CreateRandomLengthFire(math.random(1, 2), surface, pos, 16, 30, fireOnWater)
    end
end

ShipCrashController.CreateRandomLengthFire = function(fireCount, surface, position, minSecondsPerFlame, maxSecondsPerFlame, fireOnWater)
    local entityName = "item_delivery_pod-debris_fire_flame"
    if fireOnWater then
        entityName = "item_delivery_pod-debris_fire_flame_water"
    end
    surface.create_entity {name = entityName, position = position, initial_ground_flame_count = fireCount}
    local secondsPerFlame = math.random(minSecondsPerFlame, maxSecondsPerFlame)
    local flameInstanceId = global.shipCrashController.fireEntityInstanceId
    global.shipCrashController.fireEntityInstanceId = global.shipCrashController.fireEntityInstanceId + 1
    local fireLifetime = FireTypes["debris"].initialLifetime
    EventScheduler.ScheduleEvent(game.tick + fireLifetime, "ShipCrashController.RenewFireScheduledEvent", flameInstanceId, {fireCount = fireCount, surface = surface, position = position, secondsPerFlame = secondsPerFlame, currentBurnTime = fireLifetime, fireOnWater = fireOnWater})
end

ShipCrashController.RenewFireScheduledEvent = function(event)
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
    EventScheduler.ScheduleEvent(event.tick + fireLifetime, "ShipCrashController.RenewFireScheduledEvent", event.instanceId, data)
end

ShipCrashController.PlaceRocksRandomlyWithinRadius = function(rockCount, rockEntityNames, surface, craterPosition, minRadius, maxRadius)
    rockCount = math.random(math.floor(rockCount * 0.75), math.floor(rockCount * 1.25))
    for i = 1, rockCount do
        local pos = Utils.RandomLocationInRadius(craterPosition, minRadius, maxRadius)
        if not surface.get_tile(pos.x, pos.y).collides_with("water-tile") then
            local rockEntityName = rockEntityNames[math.random(#rockEntityNames)]
            surface.create_decoratives {decoratives = {{name = rockEntityName, position = pos, amount = 1}}}
        end
    end
end

return ShipCrashController
