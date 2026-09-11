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
		local deviceZone = Device.Zones[zoneIndex]
		if not deviceZone then return end
		local selectedDescription, newInputID = UI.Zones[zoneIndex].Inputs.String, nil
		for _, inputID in ipairs(inputIDs) do
			if tblInputs[inputID].Description == selectedDescription then newInputID = inputID break end
		end
		if not newInputID then return end
		Device.Channels[deviceZone.Outputs[1]].InputID = newInputID
		Device.RebuildZones()
		UI.UpdateZones()
		UI.EnableAudioControls(UI.Connected, Device.Setup.Power, Device.GetZoneCount())
	end

	-- btnVolUp/btnVolDown son ButtonStyle = "Trigger" (momentáneos), no
	-- "Toggle". Antes, el EventHandler exigía además `.Boolean == true` para
	-- actuar, pero un botón Trigger solo pulsa Boolean a true durante un
	-- instante y luego Q-SYS lo repone a false automáticamente; en el
	-- emulador ese reset puede ya haber ocurrido para cuando corre este
	-- EventHandler, así que la condición fallaba y el fader nunca se movía.
	-- Que el EventHandler se dispare ya es el evento del trigger: no hace
	-- falta comprobar además su estado Boolean.
	UI.Zones[zoneIndex].VolUp.EventHandler = function()
		if Device.SetZoneGain(zoneIndex, 1) then
			Device.SetZoneMute(zoneIndex, false)
			UI.UpdateZones()
		end
	end
	UI.Zones[zoneIndex].VolDown.EventHandler = function()
		if Device.SetZoneGain(zoneIndex, -1) then
			Device.SetZoneMute(zoneIndex, false)
			UI.UpdateZones()
		end
	end
	UI.Zones[zoneIndex].Mute.EventHandler = function()
		if Device.Zones[zoneIndex] then Device.SetZoneMute(zoneIndex, UI.Zones[zoneIndex].Mute.Boolean); UI.UpdateZones() end
	end
	UI.Zones[zoneIndex].Fader.EventHandler = function()
		if Device.SetZoneGainAbsolute(zoneIndex, UI.Zones[zoneIndex].Fader.Value) then Device.SetZoneMute(zoneIndex, false); UI.UpdateZones() end
	end
end

UI.Setup.Power.EventHandler = function()
	Device.Setup.Power = UI.Setup.Power.Boolean
	if Device.Setup.Connected then
		Protocol.Send(Device.Setup.Power and "PowerOn" or "PowerOff")
	end
	UI.UpdateDevice()
end

UI.Setup.Identify.EventHandler = function()
	local state = UI.Setup.Identify.Boolean
	if Device.Setup.Connected then
		Protocol.Send("Identify", state and 1 or 0)
	end
	Logger.Message(tblDebug.Source.UI, state and "Identify On" or "Identify Off")
end

UI.Setup.Simulate.EventHandler = function()
	UI.SimulateConnection()
end
