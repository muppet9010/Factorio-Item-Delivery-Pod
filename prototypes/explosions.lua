local CrashTypes = require("static-data/crash-types")
local DebrisTypes = require("static-data/debris-types")

local function GenerateExplosions(name, radius, explosionSmokeName)
    local smokeDeviationRadius = radius * 1.5
    data:extend(
        {
            {
                type = "explosion",
                name = name,
                animations = {
                    filename = "__core__/graphics/empty.png",
                    width = 1,
                    height = 1,
                    frame_count = 1
                },
                created_effect = {
                    {
                        type = "direct",
                        repeat_count = 10,
                        action_delivery = {
                            type = "instant",
                            target_effects = {
                                {
                                    type = "create-trivial-smoke",
                                    smoke_name = explosionSmokeName,
                                    offset_deviation = {{-smokeDeviationRadius, -smokeDeviationRadius}, {smokeDeviationRadius, smokeDeviationRadius}}
                                }
                            }
                        }
                    },
                    {
                        type = "area",
                        radius = radius,
                        action_delivery = {
                            type = "instant",
                            target_effects = {
                                type = "damage",
                                damage = {
                                    amount = 100000,
                                    type = "explosion"
                                }
                            }
                        }
                    },
                    {
                        type = "area",
                        radius = radius + (radius * 0.5),
                        action_delivery = {
                            type = "instant",
                            target_effects = {
                                type = "damage",
                                damage = {
                                    amount = 199,
                                    type = "explosion"
                                }
                            }
                        }
                    }
                }
            }
        }
    )
end
for _, crashType in pairs(CrashTypes) do
    if crashType.container ~= nil and crashType.container.killRadius ~= nil then
        GenerateExplosions(crashType.container.explosionName, crashType.container.killRadius, crashType.container.explosionSmokeName)
    end
end
for _, debrisType in pairs(DebrisTypes) do
    if debrisType.killRadius ~= nil then
        GenerateExplosions(debrisType.explosionName, debrisType.killRadius, debrisType.explosionSmokeName)
    end
end
