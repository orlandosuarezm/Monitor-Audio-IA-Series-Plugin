-- El fader (ControlType = "Knob") es continuo -- se puede arrastrar a
-- valores como -45.7, no solo enteros -- pero el protocolo real solo
-- acepta dB enteros ("SET ZONE-A.GAIN -20") y Lua 5.4 exige que %d reciba
-- un entero exacto: un Gain fraccionario hacía fallar Protocol.Send con
-- "number has no integer representation", abortando el EventHandler antes
-- de refrescar la UI -- por eso VOL+/VOL- dejaban de responder en cuanto
-- el fader se arrastraba una sola vez a un valor no entero (el decimal se
-- quedaba en zone.Gain y arruinaba también los pasos siguientes).
local function roundToInteger(value)
	return math.floor(value + 0.5)
end

function Device.SetZoneGain(zoneID, step)
	local zone = Device.Zones[zoneID]
	if not zone then return false end
	zone.Gain = roundToInteger(math.max(-80, math.min(0, zone.Gain + step)))
	if Device.Setup.Connected then
		Protocol.Send("SetZoneGain", zone.ZoneLetter, zone.Gain)
	end
	return true
end

function Device.SetZoneGainAbsolute(zoneID, value)
	local zone, gain = Device.Zones[zoneID], tonumber(value)
	if not zone or not gain then return false end
	zone.Gain = roundToInteger(math.max(-80, math.min(0, gain)))
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
