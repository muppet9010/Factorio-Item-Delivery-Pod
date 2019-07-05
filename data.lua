local Constants = require("constants")
local Utils = require("utility/utils")

data:extend(
    {
        {
            type = "container",
            name = "item_delivery_pod-tiny_wrecked_ship_container",
            order = "zzz-wrecked_ship-1",
            icon = Constants.AssetModName .. "/graphics/icons/tiny_wrecked_ship_container.png",
            icon_size = 32,
            minable = {mining_time = 0.5},
            max_health = 50,
            flags = {"not-flammable", "hide-alt-info", "placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion"},
            resistances = {
                {
                    type = "fire",
                    percent = 100
                }
            },
            collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
            selection_box = {{-1.3, -1.1}, {1.3, 1.1}},
            picture = {
                filename = "__base__/graphics/entity/ship-wreck/small-ship-wreck-g.png",
                width = 80,
                height = 72
            },
            inventory_size = 999
        },
        {
            type = "container",
            name = "item_delivery_pod-small_wrecked_ship_container",
            order = "zzz-wrecked_ship-2",
            icon = Constants.AssetModName .. "/graphics/icons/small_wrecked_ship_container.png",
            icon_size = 32,
            minable = {mining_time = 1},
            max_health = 100,
            flags = {"not-flammable", "hide-alt-info", "placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion"},
            resistances = {
                {
                    type = "fire",
                    percent = 100
                }
            },
            collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
            selection_box = {{-2, -1.5}, {2, 1.5}},
            picture = {
                filename = "__base__/graphics/entity/ship-wreck/big-ship-wreck-3.png",
                width = 165,
                height = 131,
                shift = {-0.8, -0.8}
            },
            inventory_size = 999
        },
        {
            type = "container",
            name = "item_delivery_pod-medium_wrecked_ship_container",
            order = "zzz-wrecked_ship-3",
            icon = Constants.AssetModName .. "/graphics/icons/medium_wrecked_ship_container.png",
            icon_size = 32,
            minable = {mining_time = 2},
            max_health = 200,
            flags = {"not-flammable", "hide-alt-info", "placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion"},
            resistances = {
                {
                    type = "fire",
                    percent = 100
                }
            },
            collision_box = {{-1.4, -1.2}, {1.4, 1.2}},
            selection_box = {{-2, -1.5}, {2, 1.5}},
            picture = {
                filename = "__base__/graphics/entity/ship-wreck/big-ship-wreck-2.png",
                width = 164,
                height = 129,
                shift = {-0.3, 0.6}
            },
            inventory_size = 999
        },
        {
            type = "container",
            name = "item_delivery_pod-large_wrecked_ship_container",
            order = "zzz-wrecked_ship-4",
            icon = Constants.AssetModName .. "/graphics/icons/large_wrecked_ship_container.png",
            icon_size = 32,
            minable = {mining_time = 4},
            max_health = 400,
            flags = {"not-flammable", "hide-alt-info", "placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion"},
            resistances = {
                {
                    type = "fire",
                    percent = 100
                }
            },
            collision_box = {{-2.2, -1.5}, {2.2, 1.5}},
            selection_box = {{-2.7, -1.5}, {2.7, 1.5}},
            picture = {
                filename = "__base__/graphics/entity/ship-wreck/big-ship-wreck-1.png",
                width = 256,
                height = 212,
                shift = {0.7, 0}
            },
            inventory_size = 999
        },
        {
            type = "container",
            name = "item_delivery_pod-modular_bridge_wrecked_ship_container",
            localised_name = "item_delivery_pod-modular_wrecked_ship_container",
            order = "zzz-wrecked_ship-5",
            icon = Constants.AssetModName .. "/graphics/icons/modular_bridge_wrecked_ship_container.png",
            icon_size = 32,
            minable = {mining_time = 1},
            max_health = 100,
            flags = {"not-flammable", "hide-alt-info", "placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion"},
            resistances = {
                {
                    type = "fire",
                    percent = 100
                }
            },
            collision_box = {{-1.2, -0.9}, {1.2, 0.9}},
            selection_box = {{-1.5, -1.2}, {1.5, 1.2}},
            picture = {
                filename = "__base__/graphics/entity/ship-wreck/medium-ship-wreck-2.png",
                width = 120,
                height = 85,
                shift = {0.2, -0.2}
            },
            inventory_size = 999
        },
        {
            type = "container",
            name = "item_delivery_pod-modular_thruster_wrecked_ship_container",
            localised_name = "item_delivery_pod-modular_wrecked_ship_container",
            order = "zzz-wrecked_ship-6",
            icon = Constants.AssetModName .. "/graphics/icons/modular_thruster_wrecked_ship_container.png",
            icon_size = 32,
            minable = {mining_time = 1},
            max_health = 100,
            flags = {"not-flammable", "hide-alt-info", "placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion"},
            resistances = {
                {
                    type = "fire",
                    percent = 100
                }
            },
            collision_box = {{-1.2, -0.9}, {1.2, 0.9}},
            selection_box = {{-1.5, -1.2}, {1.5, 1.2}},
            picture = {
                filename = "__base__/graphics/entity/ship-wreck/medium-ship-wreck-1.png",
                width = 120,
                height = 85
            },
            inventory_size = 999
        },
        {
            type = "simple-entity",
            name = "item_delivery_pod-small_debris",
            order = "zzz-wrecked_ship-7",
            icon = Constants.AssetModName .. "/graphics/icons/small_debris.png",
            icon_size = 32,
            minable = {mining_time = 0.1},
            max_health = 20,
            flags = {"not-flammable", "hide-alt-info", "placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion"},
            resistances = {
                {
                    type = "fire",
                    percent = 100
                }
            },
            collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
            selection_box = {{-1.3, -1.1}, {1.3, 1.1}},
            pictures = {
                {
                    filename = "__base__/graphics/entity/ship-wreck/small-ship-wreck-c.png",
                    width = 63,
                    height = 54,
                    shift = {0, 0.3}
                },
                {
                    filename = "__base__/graphics/entity/ship-wreck/small-ship-wreck-f.png",
                    width = 58,
                    height = 35,
                    shift = {0.1, 0.25}
                },
                {
                    filename = "__base__/graphics/entity/ship-wreck/small-ship-wreck-h.png",
                    width = 79,
                    height = 54,
                    shift = {0.25, -0.15}
                }
            },
            render_layer = "object"
        },
        {
            type = "simple-entity",
            name = "item_delivery_pod-medium_debris",
            order = "zzz-wrecked_ship-8",
            icon = Constants.AssetModName .. "/graphics/icons/medium_debris.png",
            icon_size = 32,
            minable = {mining_time = 0.5},
            max_health = 50,
            flags = {"not-flammable", "hide-alt-info", "placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion"},
            resistances = {
                {
                    type = "fire",
                    percent = 100
                }
            },
            collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
            selection_box = {{-1.3, -1.1}, {1.3, 1.1}},
            pictures = {
                {
                    filename = "__base__/graphics/entity/ship-wreck/small-ship-wreck-a.png",
                    width = 65,
                    height = 68,
                    shift = {0, 0}
                },
                {
                    filename = "__base__/graphics/entity/ship-wreck/small-ship-wreck-b.png",
                    width = 109,
                    height = 67,
                    shift = {0.5, 0}
                },
                {
                    filename = "__base__/graphics/entity/ship-wreck/small-ship-wreck-d.png",
                    width = 82,
                    height = 67,
                    shift = {0.1, 0.25}
                },
                {
                    filename = "__base__/graphics/entity/ship-wreck/small-ship-wreck-e.png",
                    width = 78,
                    height = 75,
                    shift = {0.4, -0.2}
                },
                {
                    filename = "__base__/graphics/entity/ship-wreck/small-ship-wreck-i.png",
                    width = 56,
                    height = 55,
                    shift = {0.1, 0}
                }
            },
            render_layer = "object"
        }
    }
)

local mediumScorchMark = Utils.DeepCopy(data.raw["corpse"]["small-scorchmark"])
mediumScorchMark.selection_box = {{-2, -2}, {2, 2}}
mediumScorchMark.animation.scale = 2
mediumScorchMark.ground_patch.sheet.scale = 2
mediumScorchMark.ground_patch_higher.sheet.scale = 2
mediumScorchMark.name = "medium-scorchmark"
data:extend({mediumScorchMark})

local largeScorchMark = Utils.DeepCopy(data.raw["corpse"]["small-scorchmark"])
largeScorchMark.selection_box = {{-3, -3}, {3, 3}}
largeScorchMark.animation.scale = 3
largeScorchMark.ground_patch.sheet.scale = 3
largeScorchMark.ground_patch_higher.sheet.scale = 3
largeScorchMark.name = "large-scorchmark"
data:extend({largeScorchMark})

local massiveScorchMark = Utils.DeepCopy(data.raw["corpse"]["small-scorchmark"])
massiveScorchMark.selection_box = {{-4, -4}, {4, 4}}
massiveScorchMark.animation.scale = 4
massiveScorchMark.ground_patch.sheet.scale = 4
massiveScorchMark.ground_patch_higher.sheet.scale = 4
massiveScorchMark.name = "large-scorchmark"
data:extend({massiveScorchMark})
