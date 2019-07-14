local Utils = require("utility/utils")
local FireTypes = require("static-data/fire-types")

local fireFlame = data.raw["fire"]["fire-flame"]
local fireFlameOnTree = data.raw["fire"]["fire-flame-on-tree"]
local function GenerateFireType(entityName, initialLifetime, onWater)
    onWater = onWater or false
    local fireEntity = Utils.DeepCopy(fireFlame)
    fireEntity.name = entityName
    fireEntity.subgroup = "item_delivery_pod-effects"
    fireEntity.initial_lifetime = initialLifetime
    fireEntity.spread_delay = initialLifetime
    fireEntity.spread_delay_deviation = 2
    fireEntity.smoke_source_pictures = fireFlameOnTree.smoke_source_pictures
    fireEntity.smoke = fireFlameOnTree.smoke
    fireEntity.smoke[1].name = "item_delivery_pod-debris_fire_smoke"
    fireEntity.smoke[1].frequency = fireEntity.smoke[1].frequency / 2
    fireEntity.smoke_fade_in_duration = fireFlameOnTree.smoke_fade_in_duration
    fireEntity.smoke_fade_out_duration = fireFlameOnTree.smoke_fade_out_duration
    fireEntity.tree_dying_factor = fireFlameOnTree.tree_dying_factor
    if onWater then
        fireEntity.burnt_patch_pictures = nil
    end
    data:extend({fireEntity})
end
for _, fireType in pairs(FireTypes) do
    GenerateFireType(fireType.entityName, fireType.initialLifetime)
    GenerateFireType(fireType.entityName .. "_water", fireType.initialLifetime, true)
end
