Device = {
	-- El protocolo LAN real (ver docs/MonitorAudio_IA_Series_Control_LAN.docx)
	-- no expone un comando para consultar número de serie o MAC -- los
	-- campos se conservan para la UI existente, pero solo los rellena
	-- Device.SetSimulatedIdentity() en modo simulación, nunca una conexión
	-- real.
	Information = { ID = nil, Model = "", Serial = "", MAC = "", Description = "" },
	Setup = { IP = "", Port = 0, Connected = false, Power = false },
	-- SystemStatus/InputStatus guardan feedback informativo (metering,
	-- estado de entradas) que hoy no tiene un control de UI propio: se
	-- capturan igualmente para no perder datos, listos para cablearse a
	-- una UI de medidores más adelante.
	SystemStatus = { SignalIn = "", SignalOut = "" },
	InputStatus = {},
	Inputs = {}, Zones = {}, Channels = {}
}

function Device.GetZoneCount()
	local count = 0
	for i = 1, kMaxZones do
		if Device.Zones[i] then count = count + 1 end
	end
	return count
end

function Device.Init()
	Device.Information = { ID = nil, Model = "", Serial = "", MAC = "", Description = "" }
	Device.Setup = { IP = "", Port = 0, Connected = false, Power = false }
	Device.SystemStatus = { SignalIn = "", SignalOut = "" }
	Device.InputStatus = {}
	Device.Inputs = tblInputs
	Device.Zones = {}
	Device.Channels = {}
end

-- Configura el modelo elegido (índice en tblModels, no el ID real de
-- producto): crea un canal por cada letra de zona del modelo
-- (Capabilities.Zones) y reconstruye Device.Zones. Esta es la única fuente
-- de la que se conoce el NOMBRE del modelo -- el protocolo LAN no permite
-- consultarlo desde el propio equipo -- pero el NÚMERO de zonas real se
-- reconcilia después con lo que el amplificador realmente reporte (ver
-- Device.EnsureZoneForLetter en zones.lua, usado por Device.ApplyResponse).
function Device.Set(argIndex)
	local model = tblModels[argIndex]
	if not model then
		Logger.Error(tblDebug.Source.Setup, "Invalid model index: " .. tostring(argIndex))
		return false
	end

	Device.Information.ID = model.ID
	Device.Information.Model = model.Name
	Device.Information.Description = model.Description
	Device.Channels = {}

	for i, zoneLetter in ipairs(model.Capabilities.Zones) do
		Device.Channels[i] = { ZoneLetter = zoneLetter, InputID = 100 }
	end

	Device.RebuildZones()
	return true
end

-- Preselecciona el modelo indicado en la propiedad de diseño "Model" (ver
-- properties.lua) antes de que haya una conexión real, para que las zonas
-- de la página Audio ya reflejen su número de canales al arrancar el
-- plugin. Al conectar con un amplificador real, cada línea de feedback de
-- zona (+ZONE-<letra>...) reconcilia esto con las zonas que el propio
-- equipo realmente reporta -- ver Device.ApplyResponse.
function Device.ApplyPropertyModel()
	local propertyValue = Properties and Properties["Model"] and Properties["Model"].Value
	if not propertyValue then return false end
	for index, model in ipairs(tblModels) do
		if model.Name == propertyValue then
			return Device.Set(index)
		end
	end
	Logger.Error(tblDebug.Source.Setup, "Unknown Model property value: " .. tostring(propertyValue))
	return false
end

function Device.ClearInformation()
	Device.Information.ID = nil
	Device.Information.Model = ""
	Device.Information.Serial = ""
	Device.Information.MAC = ""
	Device.Information.Description = ""
end

-- El equipo reporta feedback como líneas de texto independientes con el
-- formato "+RUTA VALOR" (p. ej. "+ZONE-A.GAIN -20"), y errores como líneas
-- que contienen "#" (ver docs/MonitorAudio_IA_Series_Control_LAN.docx,
-- secciones 3 y 6). TCP.lua divide el buffer recibido por línea y llama a
-- esta función una vez por cada una.
function Device.ApplyResponse(line)
	local text = tostring(line or "")
	if text == "" then return end

	if text:find("#") then
		Logger.Error(tblDebug.Source.TCP, "Amplifier reported an error: " .. text)
		return
	end

	local path, value = text:match("^%+?(%S+)%s+(.-)%s*$")
	if not path then return end
	value = value:gsub('^"(.*)"$', "%1") -- SIGNAL_IN/SIGNAL_OUT llegan entre comillas

	if path == "SYSTEM.STATUS.STATE" then
		Device.Setup.Power = value:upper() == "ON"
		return
	elseif path == "SYSTEM.STATUS.SIGNAL_IN" then
		Device.SystemStatus.SignalIn = value
		return
	elseif path == "SYSTEM.STATUS.SIGNAL_OUT" then
		Device.SystemStatus.SignalOut = value
		return
	end

	local zoneLetter, zoneProperty = path:match("^ZONE%-(%a+)%.(.+)$")
	if zoneLetter then
		local zoneIndex = Device.EnsureZoneForLetter(zoneLetter)
		local zone = Device.Zones[zoneIndex]
		if zoneProperty == "GAIN" then
			zone.Gain = tonumber(value) or zone.Gain
		elseif zoneProperty == "MUTE" then
			zone.Mute = value == "1"
		elseif zoneProperty == "PRIMARY_SRC" then
			zone.InputID = tonumber(value) or zone.InputID
		elseif zoneProperty == "STEREO" then
			zone.Stereo = value == "1"
		elseif zoneProperty == "DYN.SIGNAL" then
			-- Metering en vivo; todavía sin control de UI propio (ver
			-- docs/MonitorAudio_IA_Series_Control_LAN.docx, sección 5).
			zone.SignalLevel = tonumber(value)
		end
		return
	end

	local inputID, inputProperty = path:match("^IN%-(%d+)%.(.+)$")
	if inputID then
		inputID = tonumber(inputID)
		Device.InputStatus[inputID] = Device.InputStatus[inputID] or {}
		local status = Device.InputStatus[inputID]
		if inputProperty == "STEREO" then
			status.Stereo = value == "1"
		elseif inputProperty == "DYN.SIGNAL" then
			status.SignalLevel = tonumber(value)
		elseif inputProperty == "DYN.CLIP" then
			status.Clip = value == "1"
		end
		return
	end
end

-- Solo para Test Connection (simulación): el protocolo real no expone
-- número de serie ni MAC, así que estos valores son de muestra, nunca
-- datos de un amplificador real.
function Device.SetSimulatedIdentity()
	Device.Information.Serial = "MA12345678"
	Device.Information.MAC = "00:11:22:33:44:55"
end

function funcValidateIP(argString)
	if argString == nil then return false end
	local a, b, c, d = tostring(argString):match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
	a, b, c, d = tonumber(a), tonumber(b), tonumber(c), tonumber(d)
	return a and b and c and d and a <= 255 and b <= 255 and c <= 255 and d <= 255
end
