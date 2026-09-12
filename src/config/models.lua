-- Modelos y zonas de salida confirmados por ingeniería inversa de los
-- drivers de control Crestron 1.0.1, Control4 v100 y RTI 1.0 (ver
-- docs/MonitorAudio_IA_Series_Control_LAN.docx). Sustituye a una lista de
-- modelos anterior que no correspondía a ningún producto real de Monitor
-- Audio.
local function zoneModel(id, name, description, zones)
	return { ID = id, Name = name, Description = description, Capabilities = { Zones = zones, Outputs = #zones } }
end

tblModels = {
	zoneModel(13, "IA60-4", "4-zone installation amplifier, 60W per channel", { "A", "B", "C", "D" }),
	zoneModel(14, "IA125-4", "4-zone installation amplifier, 125W per channel", { "A", "B", "C", "D" }),
	zoneModel(15, "IA800-2", "2-zone installation amplifier, 800W per channel (bridgeable)", { "A", "B" }),
	zoneModel(16, "IA800-4", "4-zone installation amplifier, 800W per channel", { "A", "B", "C", "D" })
}
