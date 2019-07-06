return {
    tiny = {
        name = "tiny",
        hasTypeValue = false,
        container = {
            entityName = "item_delivery_pod-tiny_wrecked_ship_container",
            craterName = "item_delivery_pod-medium_scorchmark",
            explosionName = "item_delivery_pod-tiny_wrecked_ship_container_explosion",
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
            craterName = "item_delivery_pod-large_scorchmark",
            explosionName = "item_delivery_pod-small_wrecked_ship_container_explosion",
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
            craterName = "item_delivery_pod-large_scorchmark",
            explosionName = "item_delivery_pod-medium_wrecked_ship_container_explosion",
            killRadius = 4,
            rocks = {
                medium = 15,
                small = 50,
                tiny = 100
            }
        },
        debris = {small = 3}
    },
    large = {
        name = "large",
        hasTypeValue = false,
        container = {
            entityName = "item_delivery_pod-large_wrecked_ship_container",
            craterName = "item_delivery_pod-massive_scorchmark",
            explosionName = "item_delivery_pod-large_wrecked_ship_container_explosion",
            killRadius = 5,
            rocks = {
                medium = 30,
                small = 100,
                tiny = 200
            }
        },
        debris = {small = 5}
    },
    modular = {
        name = "modular",
        hasTypeValue = true
    }
}