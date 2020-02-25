local ShipCrashManger = require("scripts/ship-crash-manager")
local ShipCrashController = require("scripts/ship-crash-controller")
local EventScheduler = require("utility/event-scheduler")

local function CreateGlobals()
    ShipCrashManger.CreateGlobals()
    ShipCrashController.CreateGlobals()
end

local function OnLoad()
    remote.remove_interface("item_delivery_pod")
    ShipCrashManger.OnLoad()
    ShipCrashController.OnLoad()
end

local function OnSettingChanged(event)
    ShipCrashManger.OnSettingChanged(event)
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
