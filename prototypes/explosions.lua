local CrashTypes = require("static-data/crash-types")

local function GenerateExplosions(name, radius, impactSmokeName)
    local smokeDeviationRadius = radius * 1.5
    data:extend(
        {
            {
                type = "explosion",
                name = name,
                subgroup = "item_delivery_pod-effects",
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
                                    smoke_name = impactSmokeName,
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
                        radius = radius + (radius * 0.25),
                        action_delivery = {
                            type = "instant",
                            target_effects = {
                                type = "damage",
                                damage = {
                                    amount = 100,
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
                                    amount = 50,
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
        GenerateExplosions(crashType.container.explosionName, crashType.container.killRadius, crashType.container.impactSmokeName)
        GenerateExplosions(crashType.container.explosionName .. "_water", crashType.container.killRadius, crashType.container.impactSmokeName .. "_water")
    elseif crashType.killRadius ~= nil then
        GenerateExplosions(crashType.explosionName, crashType.killRadius, crashType.impactSmokeName)
        GenerateExplosions(crashType.explosionName .. "_water", crashType.killRadius, crashType.impactSmokeName .. "_water")
    end
end
