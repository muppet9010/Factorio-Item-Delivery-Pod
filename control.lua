local ShipCrash = require("ship-crash")
local EventScheduler = require("utility/event-scheduler")

local function CreateGlobals()
    ShipCrash.CreateGlobals()
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
EventScheduler.RegisterScheduler()

remote.add_interface(
    "item_delivery_pod",
    {
        call_crash_ship = ShipCrash.CallCrashShip
    }
)
