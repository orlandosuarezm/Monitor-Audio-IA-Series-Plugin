function UI.TryConnect()
	if not funcValidateIP(Device.Setup.IP) or Device.Setup.Port <= 0 or Device.Setup.Port > 65535 then
		TCP.Disconnect()
		Device.Setup.Connected = false
		Device.ClearInformation()
		UI.UpdateSetup()
		UI.UpdateDevice()
		return
	end

	Device.ClearInformation()
	UI.UpdateSetup()
	UI.UpdateDevice()
	TCP.Connect(Device.Setup.IP, Device.Setup.Port)
end

UI.Setup.IP.EventHandler = function()
	local enteredIP = UI.Setup.IP.String
	Logger.Uci("txtIpAddress", "value changed to " .. tostring(enteredIP))
	if funcValidateIP(enteredIP) then
		Device.Setup.IP = enteredIP
	else
		Device.Setup.IP = ""
		UI.Setup.IP.String = "Invalid IP"
	end
	UI.UpdateSetup()
	UI.TryConnect()
end

UI.Setup.Port.EventHandler = function()
	local port = tonumber(UI.Setup.Port.String)
	Logger.Uci("txtPort", "value changed to " .. tostring(UI.Setup.Port.String))
	Device.Setup.Port = port or 0
	UI.UpdateSetup()
	UI.TryConnect()
end

function UI.SimulateConnection()
	if not funcValidateIP(Device.Setup.IP) or Device.Setup.Port <= 0 then
		return nil
	end

	TCP.Disconnect()
	local deviceID = 3
	Device.Set(deviceID)
	Device.Information.Serial = "MA12345678"
	Device.Information.MAC = "00:11:22:33:44:55"
	Device.Setup.Connected = true
	Device.Setup.Power = false
	UI.UpdateSetup()
	UI.UpdateDevice()
	Logger.Message(tblDebug.Source.Setup, "Device connected (simulation), ID: " .. tostring(deviceID))
	return deviceID
end

for i = 1, kMaxZones do
	local zoneIndex = i
	UI.Zones[zoneIndex].Inputs.EventHandler = function()
		Logger.Uci("listInputs " .. zoneIndex, "value changed to " .. tostring(UI.Zones[zoneIndex].Inputs.String))
		local deviceZone = Device.Zones[zoneIndex]
		if not deviceZone then
			Logger.Error(tblDebug.Source.UCI, "listInputs " .. zoneIndex .. " ignored: zone unavailable")
			return
		end
		local selectedDescription, newInputID = UI.Zones[zoneIndex].Inputs.String, nil
		for _, inputID in ipairs(inputIDs) do
			if tblInputs[inputID].Description == selectedDescription then newInputID = inputID break end
		end
		if not newInputID then
			Logger.Error(tblDebug.Source.UCI, "listInputs " .. zoneIndex .. " ignored: unknown input")
			return
		end
		Device.Channels[deviceZone.Outputs[1]].InputID = newInputID
		Device.RebuildZones()
		UI.UpdateZones()
		UI.EnableAudioControls(UI.Connected, Device.Setup.Power, Device.GetZoneCount())
		Logger.Uci("listInputs " .. zoneIndex, "input applied")
	end

	UI.Zones[zoneIndex].VolUp.EventHandler = function()
		Logger.Uci("btnVolUp " .. zoneIndex, "pressed")
		if not UI.Zones[zoneIndex].VolUp.Boolean then return end
		if Device.SetZoneGain(zoneIndex, 1) then
			Device.SetZoneMute(zoneIndex, false)
			UI.UpdateZones()
			Logger.Uci("btnVolUp " .. zoneIndex, "fader set to " .. tostring(Device.Zones[zoneIndex].Gain) .. " dB")
		else
			Logger.Error(tblDebug.Source.UCI, "btnVolUp " .. zoneIndex .. " ignored: zone unavailable")
		end
	end
	UI.Zones[zoneIndex].VolDown.EventHandler = function()
		Logger.Uci("btnVolDown " .. zoneIndex, "pressed")
		if not UI.Zones[zoneIndex].VolDown.Boolean then return end
		if Device.SetZoneGain(zoneIndex, -1) then
			Device.SetZoneMute(zoneIndex, false)
			UI.UpdateZones()
			Logger.Uci("btnVolDown " .. zoneIndex, "fader set to " .. tostring(Device.Zones[zoneIndex].Gain) .. " dB")
		else
			Logger.Error(tblDebug.Source.UCI, "btnVolDown " .. zoneIndex .. " ignored: zone unavailable")
		end
	end
	UI.Zones[zoneIndex].Mute.EventHandler = function()
		Logger.Uci("btnMute " .. zoneIndex, UI.Zones[zoneIndex].Mute.Boolean and "pressed: mute ON" or "pressed: mute OFF")
		if Device.Zones[zoneIndex] then
			Device.SetZoneMute(zoneIndex, UI.Zones[zoneIndex].Mute.Boolean)
			UI.UpdateZones()
		else
			Logger.Error(tblDebug.Source.UCI, "btnMute " .. zoneIndex .. " ignored: zone unavailable")
		end
	end
	UI.Zones[zoneIndex].Fader.EventHandler = function()
		local value = UI.Zones[zoneIndex].Fader.Value
		Logger.Uci("fader " .. zoneIndex, "changed to " .. tostring(value) .. " dB")
		if Device.SetZoneGainAbsolute(zoneIndex, value) then
			Device.SetZoneMute(zoneIndex, false)
			UI.UpdateZones()
		else
			Logger.Error(tblDebug.Source.UCI, "fader " .. zoneIndex .. " ignored: zone unavailable")
		end
	end
end

UI.Setup.Power.EventHandler = function()
	Logger.Uci("btnPower", UI.Setup.Power.Boolean and "pressed: ON" or "pressed: OFF")
	Device.Setup.Power = UI.Setup.Power.Boolean
	if Device.Setup.Connected then
		Protocol.Send(Device.Setup.Power and "PowerOn" or "PowerOff")
	end
	UI.UpdateDevice()
end

UI.Setup.Identify.EventHandler = function()
	local state = UI.Setup.Identify.Boolean
	Logger.Uci("btnIdentify", state and "pressed: identify ON" or "pressed: identify OFF")
	if Device.Setup.Connected then
		Protocol.Send("Identify", state and 1 or 0)
	end
	Logger.Message(tblDebug.Source.UI, state and "Identify On" or "Identify Off")
end

UI.Setup.Simulate.EventHandler = function()
	Logger.Uci("btnSimulateConnection", "pressed: test connection")
	UI.SimulateConnection()
end
