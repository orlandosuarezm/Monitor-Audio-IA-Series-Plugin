-- Gama actual de amplificadores de instalación Monitor Audio, verificada
-- en vivo en monitoraudio.com/en/streamers-and-amplifiers/ (no una
-- búsqueda ni una caché): IA750-4, IA750-2, IA125-4, IA60-12, IA60-4 (más
-- el streamer IMS-4, que no es un amplificador y no está aquí).
--
-- Reemplaza dos listas previas que resultaron ser incorrectas para esta
-- gama: la de 5 modelos "1G" (IA150-2, IA60-12, IA200-2C, IA150-8C,
-- IA800-2C), confirmada como descontinuada en monitoraudio.com/en/support/
-- past-products/amplifiers-1g/; y los nombres "IA800-2"/"IA800-4" que
-- aparecían en docs/MonitorAudio_IA_Series_Control_LAN.docx, que todo
-- apunta a que eran nombres internos/pre-lanzamiento de lo que salió al
-- mercado como IA750-2/IA750-4 (mismas potencias, mismo canal count). El
-- protocolo LAN (ZONE-<letra>, GAIN/MUTE/PRIMARY_SRC) se mantiene igual;
-- solo cambia esta tabla de modelos.
local function zoneModel(id, name, description, zones)
	return { ID = id, Name = name, Description = description, Capabilities = { Zones = zones, Outputs = #zones } }
end

local function letterRange(count)
	local zones = {}
	for i = 1, count do table.insert(zones, string.char(64 + i)) end
	return zones
end

tblModels = {
	zoneModel(1, "IA60-4",
		"Compact 1U half-size 4-channel installation amplifier: 4 channels of 60W or 2 channels of 125W, full DSP matrix configuration, power sharing up to a single 250W channel.",
		letterRange(4)),
	zoneModel(2, "IA125-4",
		"Compact 1U half-size 4-channel DSP amplifier: 4 channels of 125W or 2 channels of 250W, power sharing mode for THX Ultra certified Cinergy 100 speakers.",
		letterRange(4)),
	zoneModel(3, "IA750-2",
		"2U full-size 2-channel DSP amplifier with 750W per channel, for larger installations, outdoor systems, or subwoofers (up to 1500W to a Cinergy Sub15). Full DSP matrix via web app configurator.",
		letterRange(2)),
	zoneModel(4, "IA750-4",
		"2U full-size 4-channel DSP amplifier with 750W per channel (1500W bridged), for large home theatre installations. Full DSP matrix configuration, THX Ultra certified Cinergy partner.",
		letterRange(4)),
	zoneModel(5, "IA60-12",
		"2U 12-channel (6 stereo pairs) multi-room amplifier, configurable to 1, 2, 3, 4, 5, 6 or 12 channels, 60W per channel at 4 ohms (100W bridged at 8 ohms), Hypex amplification, Buss inputs and A/B loop outputs.",
		letterRange(12))
}
