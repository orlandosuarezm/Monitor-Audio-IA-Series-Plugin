-- Los 5 amplificadores reales de la serie Monitor Audio IA, según páginas
-- de producto oficiales y de distribuidores (kevro.com, new-age-
-- electronics.com, Crutchfield, houseofstereo.com, monitoraudio.com).
--
-- AVISO IMPORTANTE: esta lista de 5 modelos NO coincide con los 4 modelos
-- (IA60-4, IA125-4, IA800-2, IA800-4) documentados en
-- docs/MonitorAudio_IA_Series_Control_LAN.docx -- parecen pertenecer a una
-- generación o línea de producto distinta, con su propio protocolo LAN ya
-- confirmado por ingeniería inversa (ZONE-A/B/C/D, comandos GAIN/MUTE/
-- PRIMARY_SRC, etc. -- ver src/core/protocol.lua). Para ESTOS 5 modelos:
-- los ID numéricos y las letras de zona de abajo son una extrapolación
-- razonable a partir del número de canales de cada uno, NO están
-- confirmados contra ningún documento de protocolo real. En particular,
-- IA500-S es un amplificador DSP dedicado a subwoofers in-wall: no está
-- claro que use el mismo esquema de "zonas" que el resto, ni que hable el
-- mismo protocolo LAN documentado. Verificar contra el equipo real o un
-- documento de protocolo específico de esta línea antes de dar por buena
-- la comunicación con hardware real.
local function zoneModel(id, name, description, zones)
	return { ID = id, Name = name, Description = description, Capabilities = { Zones = zones, Outputs = #zones } }
end

local function letterRange(count)
	local zones = {}
	for i = 1, count do table.insert(zones, string.char(64 + i)) end
	return zones
end

tblModels = {
	zoneModel(1, "IA150-2",
		"2-channel amplifier delivering 150W per channel at 4 ohms, ideal for powering a stereo pair. Rear-panel volume adjustment, compact 1U rack design, Hypex amplification.",
		letterRange(2)),
	zoneModel(2, "IA150-8C",
		"8-channel amplifier (4 stereo pairs) providing 150W per channel at 4 ohms, with IP control via RJ-45, DSP configuration, and removable block connectors.",
		letterRange(8)),
	zoneModel(3, "IA60-12",
		"12-channel, 6-zone multi-room amplifier delivering 60W per channel at 4 ohms (bridged 100W at 8 ohms), independent volume controls, Hypex modules, ultra-low THD+N, flexible Buss inputs.",
		letterRange(12)),
	zoneModel(4, "IA750-2",
		"High-power 2-channel amplifier delivering 750W per channel, suitable for subwoofers, large multi-room, or outdoor installations. DSP matrix configuration, web app control, BluOS integration.",
		letterRange(2)),
	zoneModel(5, "IA500-S",
		"500W DSP amplifier dedicated to Monitor Audio Creator Series in-wall subwoofers (WS1-W10 and WS2-W12). Intelligent DSP tuning, precise bass management.",
		letterRange(1))
}
