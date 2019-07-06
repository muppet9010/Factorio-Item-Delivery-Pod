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
script.on_load(OnLoad)

remote.add_interface(
    "item_delivery_pod",
    {
        call_crash_ship = ShipCrash.CallCrashShip
    }
)
