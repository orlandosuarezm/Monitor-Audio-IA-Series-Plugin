function Device.SetZoneGain(zoneID, step)
	local zone = Device.Zones[zoneID]
	if not zone then return false end
	zone.Gain = math.max(-80, math.min(0, zone.Gain + step))
	return true
end

function Device.SetZoneGainAbsolute(zoneID, value)
	local zone, gain = Device.Zones[zoneID], tonumber(value)
	if not zone or not gain then return false end
	zone.Gain = math.max(-80, math.min(0, gain))
	return true
end

function Device.SetZoneMute(zoneID, state)
	local zone = Device.Zones[zoneID]
	if not zone then return false end
	zone.Mute = state == true
	return true
end
