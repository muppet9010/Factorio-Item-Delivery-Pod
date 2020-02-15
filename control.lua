local ShipCrash = require("ship-crash")
local EventScheduler = require("utility/event-scheduler")

local function CreateGlobals()
    ShipCrash.CreateGlobals()
end

local function OnLoad()
    remote.remove_interface("item_delivery_pod")
    ShipCrash.OnLoad()
end

local function OnSettingChanged(event)
    ShipCrash.OnSettingChanged(event)
end

local function OnStartup()
    CreateGlobals()
    OnLoad()
    OnSettingChanged(nil)
end

script.on_init(OnStartup)
script.on_configuration_changed(OnStartup)
script.on_event(defines.events.on_runtime_mod_setting_changed, OnSettingChanged)
script.on_load(OnLoad)
EventScheduler.RegisterScheduler()
