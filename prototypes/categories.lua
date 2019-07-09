local Constants = require("constants")

data:extend(
    {
        {
            type = "item-group",
            name = "item_delivery_pod",
            icon = Constants.AssetModName .. "/graphics/icons/item_delivery_pod_item_group.png",
            icon_size = 64,
            order = "y"
        },
        {
            type = "item-subgroup",
            name = "item_delivery_pod-wrecks",
            group = "item_delivery_pod",
            order = "a"
        },
        {
            type = "item-subgroup",
            name = "item_delivery_pod-effects",
            group = "item_delivery_pod",
            order = "b"
        }
    }
)
