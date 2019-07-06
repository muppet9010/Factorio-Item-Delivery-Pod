local Utils = require("utility/utils")
local FireTypes = require("static-data/fire-types")

local function GenerateFireType(entityName, initialLifetime)
    local fireEntity = Utils.DeepCopy(data.raw["fire"]["fire-flame"])
    fireEntity.name = entityName
    fireEntity.initial_lifetime = initialLifetime
    data:extend({fireEntity})
end
for _, fireType in pairs(FireTypes) do
    GenerateFireType(fireType.entityName, fireType.initialLifetime)
end
