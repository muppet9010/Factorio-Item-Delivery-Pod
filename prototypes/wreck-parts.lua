local Constants = require("constants")
local Utils = require("utility/utils")
local Sounds = require("__base__/prototypes/entity/demo-sounds")

data:extend(
    {
        {
            type = "container",
            name = "item_delivery_pod-tiny_wrecked_ship_container",
            subgroup = "item_delivery_pod-wrecks",
            order = "wrecked_ship-1",
            icon = Constants.AssetModName .. "/graphics/icons/tiny_wrecked_ship_container.png",
            icon_size = 32,
            collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"},
            minable = {mining_time = 0.5},
            mined_sound = Sounds.generic_impact,
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
                filename = Constants.AssetModName .. "/graphics/entities/tiny_wrecked_ship_container.png",
                width = 80,
                height = 72
            },
            inventory_size = 999
        },
        {
            type = "sprite",
            name = "item_delivery_pod-tiny_wrecked_ship_container_falling",
            filename = Constants.AssetModName .. "/graphics/entities/tiny_wrecked_ship_container_falling.png",
            width = 132,
            height = 162,
            shift = {-0.1, -1.5}
        },
        {
            type = "container",
            name = "item_delivery_pod-small_wrecked_ship_container",
            subgroup = "item_delivery_pod-wrecks",
            order = "wrecked_ship-2",
            icon = Constants.AssetModName .. "/graphics/icons/small_wrecked_ship_container.png",
            icon_size = 32,
            collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"},
            minable = {mining_time = 1},
            mined_sound = Sounds.generic_impact,
            max_health = 100,
            flags = {"not-flammable", "hide-alt-info", "placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion"},
            resistances = {
                {
                    type = "fire",
                    percent = 100
                }
            },
            collision_box = {{-1.2, -1.1}, {1.2, 1.1}},
            selection_box = {{-2, -1.5}, {2, 1.5}},
            picture = {
                filename = Constants.AssetModName .. "/graphics/entities/small_wrecked_ship_container.png",
                width = 165,
                height = 131,
                shift = {-0.5, -0.8}
            },
            inventory_size = 999
        },
        {
            type = "sprite",
            name = "item_delivery_pod-small_wrecked_ship_container_falling",
            filename = Constants.AssetModName .. "/graphics/entities/small_wrecked_ship_container_falling.png",
            width = 227,
            height = 270,
            shift = {-1.5, -2.5}
        },
        {
            type = "container",
            name = "item_delivery_pod-medium_wrecked_ship_container",
            subgroup = "item_delivery_pod-wrecks",
            order = "wrecked_ship-3",
            icon = Constants.AssetModName .. "/graphics/icons/medium_wrecked_ship_container.png",
            icon_size = 32,
            collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"},
            minable = {mining_time = 1.5},
            mined_sound = Sounds.generic_impact,
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
                filename = Constants.AssetModName .. "/graphics/entities/medium_wrecked_ship_container.png",
                width = 164,
                height = 129,
                shift = {-0.3, 0.6}
            },
            inventory_size = 999
        },
        {
            type = "sprite",
            name = "item_delivery_pod-medium_wrecked_ship_container_falling",
            filename = Constants.AssetModName .. "/graphics/entities/medium_wrecked_ship_container_falling.png",
            width = 279,
            height = 337,
            shift = {-1, -2}
        },
        {
            type = "container",
            name = "item_delivery_pod-large_wrecked_ship_container",
            subgroup = "item_delivery_pod-wrecks",
            order = "wrecked_ship-4",
            icon = Constants.AssetModName .. "/graphics/icons/large_wrecked_ship_container.png",
            icon_size = 32,
            collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"},
            minable = {mining_time = 2},
            mined_sound = Sounds.generic_impact,
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
                filename = Constants.AssetModName .. "/graphics/entities/large_wrecked_ship_container.png",
                width = 256,
                height = 212,
                shift = {0.7, 0}
            },
            inventory_size = 999
        },
        {
            type = "sprite",
            name = "item_delivery_pod-large_wrecked_ship_container_falling",
            filename = Constants.AssetModName .. "/graphics/entities/large_wrecked_ship_container_falling.png",
            width = 376,
            height = 449,
            shift = {-1, -3}
        },
        {
            type = "container",
            name = "item_delivery_pod-modular_bridge_wrecked_ship_container",
            subgroup = "item_delivery_pod-wrecks",
            localised_name = {"entity-name.item_delivery_pod-modular_wrecked_ship_container"},
            order = "wrecked_ship-5",
            icon = Constants.AssetModName .. "/graphics/icons/modular_bridge_wrecked_ship_container.png",
            icon_size = 32,
            collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"},
            minable = {mining_time = 0.5},
            max_health = 50,
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
                filename = Constants.AssetModName .. "/graphics/entities/modular_bridge_wrecked_ship_container.png",
                width = 120,
                height = 85,
                shift = {0.2, -0.2}
            },
            inventory_size = 999
        },
        {
            type = "sprite",
            name = "item_delivery_pod-modular_bridge_wrecked_ship_container_falling",
            filename = Constants.AssetModName .. "/graphics/entities/modular_bridge_wrecked_ship_container_falling.png",
            width = 120,
            height = 85,
            shift = {-1, -2}
        },
        {
            type = "container",
            name = "item_delivery_pod-modular_thruster_wrecked_ship_container",
            subgroup = "item_delivery_pod-wrecks",
            localised_name = {"entity-name.item_delivery_pod-modular_wrecked_ship_container"},
            order = "wrecked_ship-6",
            icon = Constants.AssetModName .. "/graphics/icons/modular_thruster_wrecked_ship_container.png",
            icon_size = 32,
            collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"},
            minable = {mining_time = 0.5},
            mined_sound = Sounds.generic_impact,
            max_health = 50,
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
                filename = Constants.AssetModName .. "/graphics/entities/modular_thruster_wrecked_ship_container.png",
                width = 120,
                height = 85
            },
            inventory_size = 999
        },
        {
            type = "sprite",
            name = "item_delivery_pod-modular_thruster_wrecked_ship_container_falling",
            filename = Constants.AssetModName .. "/graphics/entities/modular_thruster_wrecked_ship_container_falling.png",
            width = 200,
            height = 225,
            shift = {-0.7, -1.7}
        },
        {
            type = "container",
            name = "item_delivery_pod-modular_hull_wrecked_ship_container",
            subgroup = "item_delivery_pod-wrecks",
            localised_name = {"entity-name.item_delivery_pod-modular_wrecked_ship_container"},
            order = "wrecked_ship-7",
            icon = Constants.AssetModName .. "/graphics/icons/modular_hull_wrecked_ship_container.png",
            icon_size = 32,
            collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"},
            minable = {mining_time = 0.5},
            mined_sound = Sounds.generic_impact,
            max_health = 50,
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
                filename = Constants.AssetModName .. "/graphics/entities/modular_hull_wrecked_ship_container.png",
                width = 78,
                height = 75,
                shift = {0.7, -0.3},
                scale = 1.5
            },
            inventory_size = 999
        },
        {
            type = "sprite",
            name = "item_delivery_pod-modular_hull_wrecked_ship_container_falling",
            filename = Constants.AssetModName .. "/graphics/entities/modular_hull_wrecked_ship_container_falling.png",
            width = 147,
            height = 176,
            shift = {-0.5, -1.3}
        },
        {
            type = "simple-entity",
            name = "item_delivery_pod-debris",
            subgroup = "item_delivery_pod-wrecks",
            order = "wrecked_ship-8",
            icon = Constants.AssetModName .. "/graphics/icons/debris.png",
            icon_size = 32,
            collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"},
            minable = {mining_time = 0.2},
            mined_sound = Sounds.generic_impact,
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
                    filename = Constants.AssetModName .. "/graphics/entities/debris_a.png",
                    width = 65,
                    height = 68,
                    shift = {0, 0},
                    scale = 0.8
                },
                {
                    filename = Constants.AssetModName .. "/graphics/entities/debris_b.png",
                    width = 109,
                    height = 67,
                    shift = {0.3, 0},
                    scale = 0.6
                },
                {
                    filename = Constants.AssetModName .. "/graphics/entities/debris_c.png",
                    width = 63,
                    height = 54,
                    shift = {0, 0.3}
                },
                {
                    filename = Constants.AssetModName .. "/graphics/entities/debris_d.png",
                    width = 82,
                    height = 67,
                    scale = 0.75,
                    shift = {0.1, 0.2}
                },
                {
                    filename = Constants.AssetModName .. "/graphics/entities/debris_f.png",
                    width = 58,
                    height = 35,
                    shift = {0.1, 0.25}
                },
                {
                    filename = Constants.AssetModName .. "/graphics/entities/debris_h.png",
                    width = 79,
                    height = 54,
                    shift = {0.25, -0.15}
                },
                {
                    filename = Constants.AssetModName .. "/graphics/entities/debris_i.png",
                    width = 56,
                    height = 55,
                    shift = {0.1, 0}
                }
            },
            render_layer = "object"
        },
        {
            type = "sprite",
            name = "item_delivery_pod-debris_falling",
            filename = Constants.AssetModName .. "/graphics/entities/debris_falling.png",
            width = 111,
            height = 131,
            shift = {-0.5, -0.5}
        }
    }
)

data:extend(
    {
        {
            type = "sprite",
            name = "item_delivery_pod-generic_falling_shadow",
            filename = Constants.AssetModName .. "/graphics/entities/generic_falling_shadow.png",
            width = 256,
            height = 256,
            draw_as_shadow = true
        }
    }
)

data:extend(
    {
        Utils.CreateLandPlacementTestEntityPrototype(data.raw["container"]["item_delivery_pod-tiny_wrecked_ship_container"], "item_delivery_pod-tiny_wrecked_ship_container_land_placement_test", "item_delivery_pod-wrecks"),
        Utils.CreateLandPlacementTestEntityPrototype(data.raw["container"]["item_delivery_pod-medium_wrecked_ship_container"], "item_delivery_pod-medium_wrecked_ship_container_land_placement_test", "item_delivery_pod-wrecks"),
        Utils.CreateLandPlacementTestEntityPrototype(data.raw["container"]["item_delivery_pod-large_wrecked_ship_container"], "item_delivery_pod-large_wrecked_ship_container_land_placement_test", "item_delivery_pod-wrecks"),
        Utils.CreateWaterPlacementTestEntityPrototype(data.raw["container"]["item_delivery_pod-tiny_wrecked_ship_container"], "item_delivery_pod-tiny_wrecked_ship_container_water_placement_test", "item_delivery_pod-wrecks"),
        Utils.CreateWaterPlacementTestEntityPrototype(data.raw["container"]["item_delivery_pod-medium_wrecked_ship_container"], "item_delivery_pod-medium_wrecked_ship_container_water_placement_test", "item_delivery_pod-wrecks"),
        Utils.CreateWaterPlacementTestEntityPrototype(data.raw["container"]["item_delivery_pod-large_wrecked_ship_container"], "item_delivery_pod-large_wrecked_ship_container_water_placement_test", "item_delivery_pod-wrecks")
    }
)

local function MakeWaterVersion(entityPrototype)
    local waterEntity = Utils.DeepCopy(entityPrototype)
    waterEntity.name = waterEntity.name .. "_water"
    waterEntity.subgroup = "item_delivery_pod-wrecks_water"
    waterEntity.icon = string.gsub(waterEntity.icon, ".png", "_water.png")
    waterEntity.collision_mask = {"ground-tile", "object-layer"}
    if waterEntity.picture ~= nil then
        waterEntity.picture.filename = string.gsub(waterEntity.picture.filename, ".png", "_water.png")
    else
        for _, picture in ipairs(waterEntity.pictures) do
            picture.filename = string.gsub(picture.filename, ".png", "_water.png")
        end
    end
    data:extend({waterEntity})
end

MakeWaterVersion(data.raw["container"]["item_delivery_pod-tiny_wrecked_ship_container"])
MakeWaterVersion(data.raw["container"]["item_delivery_pod-small_wrecked_ship_container"])
MakeWaterVersion(data.raw["container"]["item_delivery_pod-medium_wrecked_ship_container"])
MakeWaterVersion(data.raw["container"]["item_delivery_pod-large_wrecked_ship_container"])
MakeWaterVersion(data.raw["container"]["item_delivery_pod-modular_bridge_wrecked_ship_container"])
MakeWaterVersion(data.raw["container"]["item_delivery_pod-modular_thruster_wrecked_ship_container"])
MakeWaterVersion(data.raw["container"]["item_delivery_pod-modular_hull_wrecked_ship_container"])
MakeWaterVersion(data.raw["simple-entity"]["item_delivery_pod-debris"])
