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
