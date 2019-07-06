local Utils = require("utility/utils")

local mediumScorchMark = Utils.DeepCopy(data.raw["corpse"]["small-scorchmark"])
mediumScorchMark.selection_box = {{-2, -2}, {2, 2}}
mediumScorchMark.animation.scale = 2
mediumScorchMark.ground_patch.sheet.scale = 2
mediumScorchMark.ground_patch_higher.sheet.scale = 2
mediumScorchMark.name = "item_delivery_pod-medium_scorchmark"
data:extend({mediumScorchMark})

local largeScorchMark = Utils.DeepCopy(data.raw["corpse"]["small-scorchmark"])
largeScorchMark.selection_box = {{-3, -3}, {3, 3}}
largeScorchMark.animation.scale = 3
largeScorchMark.ground_patch.sheet.scale = 3
largeScorchMark.ground_patch_higher.sheet.scale = 3
largeScorchMark.name = "item_delivery_pod-large_scorchmark"
data:extend({largeScorchMark})

local massiveScorchMark = Utils.DeepCopy(data.raw["corpse"]["small-scorchmark"])
massiveScorchMark.selection_box = {{-4, -4}, {4, 4}}
massiveScorchMark.animation.scale = 4
massiveScorchMark.ground_patch.sheet.scale = 4
massiveScorchMark.ground_patch_higher.sheet.scale = 4
massiveScorchMark.name = "item_delivery_pod-massive_scorchmark"
data:extend({massiveScorchMark})
