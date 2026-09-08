function Device.SetZoneGain(zoneID, step)
	local zone = Device.Zones[zoneID]
	if not zone then return false end
	zone.Gain = math.max(-80, math.min(0, zone.Gain + step))
	if Device.Setup.Connected then
		for _, outputID in ipairs(zone.Outputs) do
			Protocol.Send("SetChannelVolume", outputID, zone.Gain)
		end
	end
	return true
end

function Device.SetZoneGainAbsolute(zoneID, value)
	local zone, gain = Device.Zones[zoneID], tonumber(value)
	if not zone or not gain then return false end
	zone.Gain = math.max(-80, math.min(0, gain))
	if Device.Setup.Connected then
		for _, outputID in ipairs(zone.Outputs) do
			Protocol.Send("SetChannelVolume", outputID, zone.Gain)
		end
	end
	return true
end

function Device.SetZoneMute(zoneID, state)
	local zone = Device.Zones[zoneID]
	if not zone then return false end
	zone.Mute = state == true
	if Device.Setup.Connected then
		for _, outputID in ipairs(zone.Outputs) do
			Protocol.Send("SetChannelMute", outputID, zone.Mute and 1 or 0)
		end
	end
	return true
end
