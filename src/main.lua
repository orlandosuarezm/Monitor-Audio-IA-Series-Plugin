-- Load these files in this order in the Q-SYS Text Controller:
-- config/constants.lua, config/models.lua, config/inputs.lua,
-- core/logger.lua, core/protocol.lua, core/tcp.lua,
-- device/device.lua, device/zones.lua, device/channels.lua,
-- ui/ui.lua, ui/events.lua, main.lua.

function funcInit()
    Device.Init()
    UI.Init()
    UI.UpdateSetup()
    UI.UpdateDevice()
    if funcValidateIP(Device.Setup.IP) and Device.Setup.Port > 0 and Device.Setup.Port <= 65535 then
        UI.TryConnect()
    end
    Logger.Message(tblDebug.Source.Init, "Monitor Audio IA Series plugin")
end

funcInit()