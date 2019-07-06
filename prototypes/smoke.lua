local Constants = require("constants")

data:extend(
    {
        {
            type = "trivial-smoke",
            name = "item_delivery_pod-small_crash_smoke",
            animation = {
                filename = Constants.AssetModName .. "/graphics/entities/large-smoke-white.png",
                width = 152,
                height = 120,
                line_length = 5,
                frame_count = 60,
                direction_count = 1,
                priority = "high",
                animation_speed = 0.25,
                flags = {"smoke"},
                shift = {-0.5, -0.5},
                scale = 1.5
            },
            duration = 180,
            fade_in_duration = 5,
            fade_away_duration = 120,
            affected_by_wind = false,
            show_when_smoke_off = true,
            movement_slow_down_factor = 1,
            render_layer = "air-entity-info-icon",
            cyclic = true
        },
        {
            type = "trivial-smoke",
            name = "item_delivery_pod-medium_crash_smoke",
            animation = {
                filename = Constants.AssetModName .. "/graphics/entities/large-smoke-white.png",
                width = 152,
                height = 120,
                line_length = 5,
                frame_count = 60,
                direction_count = 1,
                priority = "high",
                animation_speed = 0.25,
                flags = {"smoke"},
                shift = {-1, -1},
                scale = 3
            },
            duration = 180,
            fade_in_duration = 5,
            fade_away_duration = 120,
            affected_by_wind = false,
            show_when_smoke_off = true,
            movement_slow_down_factor = 1,
            render_layer = "air-entity-info-icon",
            cyclic = true
        },
        {
            type = "trivial-smoke",
            name = "item_delivery_pod-large_crash_smoke",
            animation = {
                filename = Constants.AssetModName .. "/graphics/entities/large-smoke-white.png",
                width = 152,
                height = 120,
                line_length = 5,
                frame_count = 60,
                direction_count = 1,
                priority = "high",
                animation_speed = 0.25,
                flags = {"smoke"},
                shift = {-2, -2},
                scale = 6
            },
            duration = 180,
            fade_in_duration = 5,
            fade_away_duration = 120,
            affected_by_wind = false,
            show_when_smoke_off = true,
            movement_slow_down_factor = 1,
            render_layer = "air-entity-info-icon",
            cyclic = true
        },
        {
            type = "trivial-smoke",
            name = "item_delivery_pod-massive_crash_smoke",
            animation = {
                filename = Constants.AssetModName .. "/graphics/entities/large-smoke-white.png",
                width = 152,
                height = 120,
                line_length = 5,
                frame_count = 60,
                direction_count = 1,
                priority = "high",
                animation_speed = 0.25,
                flags = {"smoke"},
                shift = {-3, -3},
                scale = 9
            },
            duration = 180,
            fade_in_duration = 5,
            fade_away_duration = 120,
            affected_by_wind = false,
            show_when_smoke_off = true,
            movement_slow_down_factor = 1,
            render_layer = "air-entity-info-icon",
            cyclic = true
        }
    }
)
