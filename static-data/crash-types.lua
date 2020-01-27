local crashTypes = {
    tiny = {
        name = "tiny",
        hasTypeValue = false,
        container = {
            entityName = "item_delivery_pod-tiny_wrecked_ship_container",
            craterName = "item_delivery_pod-medium_scorchmark",
            explosionName = "item_delivery_pod-tiny_wrecked_ship_container_explosion",
            killRadius = 0.75,
            rocks = {
                small = 10,
                tiny = 20
            },
            shadowSize = 2,
            impactSmokeName = "item_delivery_pod-medium_crash_smoke",
            impactEffectName = "medium-explosion",
            landPlacementTestEntityName = "item_delivery_pod-tiny_wrecked_ship_container_land_placement_test",
            waterPlacementTestEntityName = "item_delivery_pod-tiny_wrecked_ship_container_water_placement_test"
        },
        debris = 0
    },
    small = {
        name = "small",
        hasTypeValue = false,
        container = {
            entityName = "item_delivery_pod-small_wrecked_ship_container",
            craterName = "item_delivery_pod-large_scorchmark",
            explosionName = "item_delivery_pod-small_wrecked_ship_container_explosion",
            killRadius = 2.5,
            rocks = {
                medium = 7,
                small = 30,
                tiny = 50
            },
            shadowSize = 4,
            impactSmokeName = "item_delivery_pod-large_crash_smoke",
            impactEffectName = "massive-explosion",
            landPlacementTestEntityName = "item_delivery_pod-medium_wrecked_ship_container_land_placement_test",
            waterPlacementTestEntityName = "item_delivery_pod-medium_wrecked_ship_container_water_placement_test"
        },
        debris = 0
    },
    medium = {
        name = "medium",
        hasTypeValue = false,
        container = {
            entityName = "item_delivery_pod-medium_wrecked_ship_container",
            craterName = "item_delivery_pod-large_scorchmark",
            explosionName = "item_delivery_pod-medium_wrecked_ship_container_explosion",
            killRadius = 3,
            rocks = {
                medium = 15,
                small = 50,
                tiny = 100
            },
            shadowSize = 5,
            impactSmokeName = "item_delivery_pod-large_crash_smoke",
            impactEffectName = "massive-explosion",
            landPlacementTestEntityName = "item_delivery_pod-medium_wrecked_ship_container_land_placement_test",
            waterPlacementTestEntityName = "item_delivery_pod-medium_wrecked_ship_container_water_placement_test"
        },
        debris = 3
    },
    large = {
        name = "large",
        hasTypeValue = false,
        container = {
            entityName = "item_delivery_pod-large_wrecked_ship_container",
            craterName = "item_delivery_pod-massive_scorchmark",
            explosionName = "item_delivery_pod-large_wrecked_ship_container_explosion",
            killRadius = 4,
            rocks = {
                medium = 30,
                small = 100,
                tiny = 200
            },
            shadowSize = 6,
            impactSmokeName = "item_delivery_pod-massive_crash_smoke",
            impactEffectName = "massive-explosion",
            landPlacementTestEntityName = "item_delivery_pod-large_wrecked_ship_container_land_placement_test",
            waterPlacementTestEntityName = "item_delivery_pod-large_wrecked_ship_container_water_placement_test"
        },
        debris = 5
    },
    debris = {
        name = "debris",
        entityName = "item_delivery_pod-debris",
        craterName = "small-scorchmark",
        explosionName = "item_delivery_pod-debris_explosion",
        killRadius = 1,
        rocks = {
            small = 3,
            tiny = 10
        },
        shadowSize = 1.5,
        impactSmokeName = "item_delivery_pod-small_crash_smoke",
        impactEffectName = "medium-explosion",
        landPlacementTestEntityName = "item_delivery_pod-tiny_wrecked_ship_container_land_placement_test",
        waterPlacementTestEntityName = "item_delivery_pod-tiny_wrecked_ship_container_water_placement_test",
        debris = 0
    },
    modular = {
        name = "modular",
        hasTypeValue = true,
        parts = {
            {name = "modular_bridge", placementGroup = "front", count = 1},
            {name = "modular_thruster", placementGroup = "back", ratio = 1 / 6},
            {name = "modular_hull", placementGroup = "middle", allRemaining = true}
        },
        partSpacing = 5
    }
}

local function CreateModularParts(name, entityName)
    crashTypes[name] = {
        name = name,
        hasTypeValue = false,
        container = {
            entityName = entityName,
            craterName = "item_delivery_pod-medium_scorchmark",
            explosionName = entityName .. "_explosion",
            killRadius = 2.5,
            rocks = {
                medium = 7,
                small = 30,
                tiny = 50
            },
            shadowSize = 3,
            impactSmokeName = "item_delivery_pod-medium_crash_smoke",
            impactEffectName = "massive-explosion",
            landPlacementTestEntityName = "item_delivery_pod-medium_wrecked_ship_container_land_placement_test",
            waterPlacementTestEntityName = "item_delivery_pod-medium_wrecked_ship_container_water_placement_test"
        },
        debris = 2
    }
end
CreateModularParts("modular_bridge", "item_delivery_pod-modular_bridge_wrecked_ship_container")
crashTypes["modular_bridge"].container.killRadius = 3
crashTypes["modular_bridge"].debris = 5
CreateModularParts("modular_thruster", "item_delivery_pod-modular_thruster_wrecked_ship_container")
CreateModularParts("modular_hull", "item_delivery_pod-modular_hull_wrecked_ship_container")

return crashTypes
