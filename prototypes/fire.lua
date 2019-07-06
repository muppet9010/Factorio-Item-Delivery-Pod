local Utils = require("utility/utils")

local debrisFire = Utils.DeepCopy(data.raw["fire"]["fire-flame-on-tree"])
debrisFire.name = "item_delivery_pod-debris_fire_flame"
debrisFire.initial_lifetime = 600
data:extend({debrisFire})
