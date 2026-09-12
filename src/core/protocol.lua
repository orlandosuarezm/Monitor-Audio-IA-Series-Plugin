Protocol = {}

-- Comandos confirmados por ingeniería inversa de los drivers Crestron
-- 1.0.1, Control4 v100 y RTI 1.0 del amplificador Monitor Audio IA Series
-- (ver docs/MonitorAudio_IA_Series_Control_LAN.docx). El equipo no expone,
-- en este protocolo, un comando para consultar el modelo, número de serie
-- o MAC -- solo el propio nombre del modelo lo aporta la propiedad de
-- diseño "Model" (ver properties.lua/device.lua).
Protocol.Commands = {
	PowerOn = "POWER_ON",
	PowerOff = "POWER_OFF",
	Identify = "SET SETUP.SYSTEM.LOCATING %d",
	SubscribeReg = "SUBSCRIBE REG",
	SubscribeDyn = "SUBSCRIBE DYN %.1f",
	SetZoneGain = "SET ZONE-%s.GAIN %d",
	SetZoneMute = "SET ZONE-%s.MUTE %d",
	SetZoneSource = "SET ZONE-%s.PRIMARY_SRC %d",
	GetAllZoneGain = "GET ZONE-*.GAIN",
	GetAllZoneMute = "GET ZONE-*.MUTE",
	GetAllZoneSource = "GET ZONE-*.PRIMARY_SRC",
	GetAllZoneStereo = "GET ZONE-*.STEREO",
	GetAllInputStereo = "GET IN-*.STEREO"
}

function Protocol.Build(name, ...)
	local command = Protocol.Commands[name]

	if not command then
		Logger.Error(tblDebug.Source.TCP, "Unknown command: " .. tostring(name))
		return nil
	end

	if select("#", ...) > 0 then
		command = string.format(command, ...)
	end

	return command
end

function Protocol.Send(name, ...)
	local command = Protocol.Build(name, ...)

	if command then
		TCP.Send(command)
	end
end

-- Secuencia de sincronización recomendada al abrir la conexión TCP (ver
-- docs/MonitorAudio_IA_Series_Control_LAN.docx, sección 7). SUBSCRIBE REG
-- y SUBSCRIBE DYN dejan al equipo enviando feedback asíncrono el resto de
-- la sesión; no hace falta un poll propio adicional.
function Protocol.RunInitSequence()
	Protocol.Send("GetAllZoneGain")
	Protocol.Send("GetAllZoneMute")
	Protocol.Send("GetAllZoneSource")
	Protocol.Send("GetAllInputStereo")
	Protocol.Send("GetAllZoneStereo")
	Protocol.Send("SubscribeReg")
	Protocol.Send("SubscribeDyn", 0.2)
end

-- TCP.lua divide el buffer recibido por línea y llama a esto una vez por
-- cada línea de feedback ("una por línea terminada en kAnswerEnd", según
-- el documento de protocolo), no una vez por buffer completo.
function Protocol.HandleResponse(line)
	Device.ApplyResponse(line)
	UI.UpdateDevice()
end
