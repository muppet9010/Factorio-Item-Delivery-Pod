local Constants = require("constants")
local Utils = require("utility/utils")

local function CreateImpactSmoke(name, scale, tint)
    local shift = {-(scale / 3), -(scale / 3)}
    data:extend(
        {
            {
                type = "trivial-smoke",
                name = name,
                subgroup = "item_delivery_pod-effects",
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
                    tint = tint,
                    shift = shift,
                    scale = scale
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
end

local landImpactSmokeTint = {r = 0.74, g = 0.67, b = 0.52, a = 1}
local waterImpactSmoke = {r = 0.62, g = 0.72, b = 0.80, a = 1}
CreateImpactSmoke("item_delivery_pod-small_crash_smoke", 1.5, landImpactSmokeTint)
CreateImpactSmoke("item_delivery_pod-small_crash_smoke_water", 1.5, waterImpactSmoke)
CreateImpactSmoke("item_delivery_pod-medium_crash_smoke", 3, landImpactSmokeTint)
CreateImpactSmoke("item_delivery_pod-medium_crash_smoke_water", 3, waterImpactSmoke)
CreateImpactSmoke("item_delivery_pod-large_crash_smoke", 6, landImpactSmokeTint)
CreateImpactSmoke("item_delivery_pod-large_crash_smoke_water", 6, waterImpactSmoke)
CreateImpactSmoke("item_delivery_pod-massive_crash_smoke", 9, landImpactSmokeTint)
CreateImpactSmoke("item_delivery_pod-massive_crash_smoke_water", 9, waterImpactSmoke)

local debrisFireSmoke = Utils.DeepCopy(data.raw["trivial-smoke"]["fire-smoke-without-glow"])
debrisFireSmoke.name = "item_delivery_pod-debris_fire_smoke"
debrisFireSmoke.show_when_smoke_off = true
data:extend({debrisFireSmoke})
