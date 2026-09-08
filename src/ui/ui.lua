UI = {
	Connected = false,
	DeviceID = Controls.txtDeviceId,
	Information = { Model = Controls.txtInformation[1], Serial = Controls.txtInformation[2], MAC = Controls.txtInformation[3], Description = Controls.txtInformation[4] },
	Setup = { IP = Controls.txtIpAddress, Port = Controls.txtPort, Connected = Controls.Connected, Power = Controls.btnPower, Identify = Controls.btnIdentify, Simulate = Controls.btnSimulateConnection },
	Zones = {}
}

for i = 1, kMaxZones do
	UI.Zones[i] = { Label = Controls.txtLabels[i], Inputs = Controls.listInputs[i], VolUp = Controls.btnVolUp[i], VolDown = Controls.btnVolDown[i], Fader = Controls.fader[i], Mute = Controls.btnMute[i] }
end

local inputIDs = { 100, 101, 102, 103, 200 }
function UI.EnableInformation(enabled)
	for _, control in ipairs(Controls.txtInformation) do control.IsDisabled = not enabled end
end

function UI.EnableAudioControls(visible, powerOn, zoneCount)
	for i = 1, kMaxZones do
		local zone = UI.Zones[i]
		local isVisible = visible and i <= (tonumber(zoneCount) or 0)
		zone.Label.IsInvisible, zone.Inputs.IsInvisible = not isVisible, not isVisible
		zone.VolUp.IsInvisible, zone.VolDown.IsInvisible = not isVisible, not isVisible
		zone.Fader.IsInvisible, zone.Mute.IsInvisible = not isVisible, not isVisible
		zone.Inputs.IsDisabled, zone.VolUp.IsDisabled = not powerOn, not powerOn
		zone.VolDown.IsDisabled, zone.Fader.IsDisabled = not powerOn, not powerOn
		zone.Mute.IsDisabled = not powerOn
	end
end

function UI.UpdateZones()
	for i = 1, kMaxZones do
		local uiZone, deviceZone = UI.Zones[i], Device.Zones[i]
		if deviceZone then
			uiZone.Label.String = deviceZone.Label
			uiZone.Inputs.String = Device.Inputs[deviceZone.InputID].Description
			uiZone.Fader.Value, uiZone.Mute.Boolean = deviceZone.Gain, deviceZone.Mute
		else
			uiZone.Label.String, uiZone.Inputs.String = "Zone " .. string.char(64 + i), ""
			uiZone.Fader.Value, uiZone.Mute.Boolean = 0, false
		end
	end
end

function UI.UpdateDevice()
	local connected = Device.Setup.Connected
	UI.Connected = connected
	UI.DeviceID.String = connected and tostring(Device.Information.ID or "") or ""
	UI.EnableInformation(connected)
	for name, control in pairs(UI.Information) do control.String = connected and (Device.Information[name] or "") or "" end
	UI.UpdateZones()
	UI.EnableAudioControls(connected, Device.Setup.Power, Device.GetZoneCount())
	UI.Setup.Power.IsDisabled, UI.Setup.Identify.IsDisabled = not connected, not connected
	UI.Setup.Power.Boolean = Device.Setup.Power
end

function UI.UpdateSetup()
	local validIP = funcValidateIP(UI.Setup.IP.String)
	local validPort = Device.Setup.Port > 0 and Device.Setup.Port <= 65535
	UI.Setup.IP.IsDisabled = false
	UI.Setup.Port.IsDisabled = not validIP
	UI.Setup.Connected.Boolean = Device.Setup.Connected
	UI.Setup.Power.Boolean = Device.Setup.Power
	UI.Setup.Identify.Boolean = false
	UI.Setup.Simulate.IsDisabled = not (validIP and validPort)
end

function UI.Init()
	UI.Setup.IP.String = Device.Setup.IP
	UI.UpdateSetup()
	UI.UpdateZones()
end
