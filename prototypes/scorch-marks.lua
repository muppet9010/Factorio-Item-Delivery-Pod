local Utils = require("utility/utils")

local mediumScorchMark = Utils.DeepCopy(data.raw["corpse"]["medium-scorchmark"])
mediumScorchMark.selection_box = {{-2, -2}, {2, 2}}
mediumScorchMark.name = "item_delivery_pod-medium_scorchmark"
data:extend({mediumScorchMark})

local largeScorchMark = Utils.DeepCopy(data.raw["corpse"]["medium-scorchmark"])
largeScorchMark.selection_box = {{-3, -3}, {3, 3}}
largeScorchMark.ground_patch.sheet.scale = 1.5
largeScorchMark.ground_patch.sheet.hr_version.scale = 0.75
largeScorchMark.ground_patch_higher.sheet.scale = 1.5
largeScorchMark.ground_patch_higher.sheet.hr_version.scale = 0.75
largeScorchMark.name = "item_delivery_pod-large_scorchmark"
data:extend({largeScorchMark})

local massiveScorchMark = Utils.DeepCopy(data.raw["corpse"]["medium-scorchmark"])
massiveScorchMark.selection_box = {{-4, -4}, {4, 4}}
massiveScorchMark.ground_patch.sheet.scale = 2
massiveScorchMark.ground_patch.sheet.hr_version.scale = 1
massiveScorchMark.ground_patch_higher.sheet.scale = 2
massiveScorchMark.ground_patch.sheet.hr_version.scale = 1
massiveScorchMark.name = "item_delivery_pod-massive_scorchmark"
data:extend({massiveScorchMark})
