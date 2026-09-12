function Device.ClearZones()
	for i = 1, kMaxZones do Device.Zones[i] = nil end
end

-- Cada Device.Channels[i] es una zona de salida real del amplificador
-- (letra ZONE-A/B/C/D), no un canal que haya que emparejar en estéreo por
-- software: el propio equipo decide si una pareja de zonas (A-B o C-D)
-- está en modo estéreo, y eso se consulta con GET ZONE-<zona>.STEREO, no
-- se configura desde aquí (ver docs/MonitorAudio_IA_Series_Control_LAN.docx,
-- sección 4.3). Device.Zones se mantiene indexado numéricamente (1..N)
-- para encajar con los controles de la UI (ver src/ui/ui.lua).
function Device.RebuildZones()
	Device.ClearZones()
	for i, channel in ipairs(Device.Channels) do
		Device.Zones[i] = {
			ID = i,
			ZoneLetter = channel.ZoneLetter,
			Label = "Zone " .. channel.ZoneLetter,
			InputID = channel.InputID,
			Gain = 0,
			Mute = false,
			Stereo = false
		}
	end
end

-- Busca la zona por su letra real (tal como la reporta el amplificador);
-- si todavía no existe (por ejemplo, porque el modelo elegido en la
-- propiedad de diseño tiene menos zonas de las que el equipo real resulta
-- tener), la crea sobre la marcha. Así, el número de zonas visible en la
-- página Audio se reconcilia automáticamente con el amplificador real en
-- cuanto contesta, sin depender de un comando de "modelo" que el protocolo
-- LAN no expone -- ver Device.ApplyResponse en device.lua.
function Device.EnsureZoneForLetter(zoneLetter)
	for i, zone in ipairs(Device.Zones) do
		if zone.ZoneLetter == zoneLetter then return i end
	end

	local index = #Device.Zones + 1
	Device.Zones[index] = {
		ID = index,
		ZoneLetter = zoneLetter,
		Label = "Zone " .. zoneLetter,
		InputID = 100,
		Gain = 0,
		Mute = false,
		Stereo = false
	}
	Device.Channels[index] = Device.Channels[index] or { ZoneLetter = zoneLetter, InputID = 100 }
	return index
end

-- Pareja de zonas que el propio amplificador puede agrupar en modo
-- estéreo (consultable con GET ZONE-<zona>.STEREO, no configurable por
-- LAN): cuando la primaria (A o C) reporta STEREO = 1, la secundaria (B o
-- D) queda fusionada en ella y no debe controlarse por separado -- ver
-- docs/MonitorAudio_IA_Series_Control_LAN.docx, sección 4.3.
local kStereoPairs = { A = "B", C = "D" }

function Device.GetZoneByLetter(zoneLetter)
	for _, zone in ipairs(Device.Zones) do
		if zone.ZoneLetter == zoneLetter then return zone end
	end
	return nil
end

-- true si esta zona es la mitad "secundaria" (B o D) de un par que el
-- amplificador tiene configurado en modo estéreo, y por tanto debe
-- ocultarse en la UI porque la zona primaria (A o C) ya la controla.
function Device.IsZoneHiddenByStereoPair(zoneIndex)
	local zone = Device.Zones[zoneIndex]
	if not zone then return false end
	for primaryLetter, secondaryLetter in pairs(kStereoPairs) do
		if zone.ZoneLetter == secondaryLetter then
			local primaryZone = Device.GetZoneByLetter(primaryLetter)
			return primaryZone ~= nil and primaryZone.Stereo == true
		end
	end
	return false
end

-- Etiqueta a mostrar en la UI: si esta zona es la primaria de un par en
-- modo estéreo, refleja que controla ambas letras (p. ej. "Zone A/B
-- (Stereo)") ya que la secundaria queda oculta por Device.IsZoneHiddenByStereoPair.
function Device.GetZoneDisplayLabel(zone)
	local secondaryLetter = zone.Stereo and kStereoPairs[zone.ZoneLetter]
	if secondaryLetter then
		return "Zone " .. zone.ZoneLetter .. "/" .. secondaryLetter .. " (Stereo)"
	end
	return zone.Label
end
