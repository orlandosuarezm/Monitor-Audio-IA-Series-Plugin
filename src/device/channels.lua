function Device.SetZoneGain(zoneID, step)
	local zone = Device.Zones[zoneID]
	if not zone then return false end
	zone.Gain = math.max(-80, math.min(0, zone.Gain + step))
	if Device.Setup.Connected then
		Protocol.Send("SetZoneGain", zone.ZoneLetter, zone.Gain)
	end
	return true
end

function Device.SetZoneGainAbsolute(zoneID, value)
	local zone, gain = Device.Zones[zoneID], tonumber(value)
	if not zone or not gain then return false end
	zone.Gain = math.max(-80, math.min(0, gain))
	if Device.Setup.Connected then
		Protocol.Send("SetZoneGain", zone.ZoneLetter, zone.Gain)
	end
	return true
end

function Device.SetZoneMute(zoneID, state)
	local zone = Device.Zones[zoneID]
	if not zone then return false end
	zone.Mute = state == true
	if Device.Setup.Connected then
		Protocol.Send("SetZoneMute", zone.ZoneLetter, zone.Mute and 1 or 0)
	end
	return true
end

function Device.SetZoneSource(zoneID, inputID)
	local zone = Device.Zones[zoneID]
	if not zone or not tblInputs[inputID] then return false end
	zone.InputID = inputID
	if Device.Setup.Connected then
		Protocol.Send("SetZoneSource", zone.ZoneLetter, inputID)
	end
	return true
end
