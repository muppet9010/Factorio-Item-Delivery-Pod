local Utils = require("utility/utils")
local FireTypes = require("static-data/fire-types")

local fireFlame = data.raw["fire"]["fire-flame"]
local fireFlameOnTree = data.raw["fire"]["fire-flame-on-tree"]
local function GenerateFireType(entityName, initialLifetime)
    local fireEntity = Utils.DeepCopy(fireFlame)
    fireEntity.name = entityName
    fireEntity.initial_lifetime = initialLifetime
    fireEntity.spread_delay = initialLifetime
    fireEntity.spread_delay_deviation = 2
    fireEntity.smoke = fireFlameOnTree.smoke
    fireEntity.tree_dying_factor = fireFlameOnTree.tree_dying_factor
    data:extend({fireEntity})
end
for _, fireType in pairs(FireTypes) do
    GenerateFireType(fireType.entityName, fireType.initialLifetime)
end
