local ShipCrash = require("ship-crash")

local function CreateGlobals()
end

local function OnLoad()
    ShipCrash.OnLoad()
end

local function OnStartup()
    CreateGlobals()

    OnLoad()
end

script.on_init(OnStartup)
script.on_configuration_changed(OnStartup)
