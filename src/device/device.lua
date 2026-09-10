Device = {
	Information = { ID = nil, Model = "", Serial = "", MAC = "", Description = "" },
	Setup = { IP = "", Port = 0, Connected = false, Power = false },
	Inputs = {}, Zones = {}, Channels = {}, Outputs = {},
	Capabilities = { MaxInputs = 0, MaxZones = 0, MaxOutputs = 0, StereoPairs = 0 }
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
	Device.Inputs = tblInputs
	Device.Zones = {}
	Device.Channels = {}
	Device.Outputs = {}
	Device.Capabilities = { MaxInputs = 0, MaxZones = 0, MaxOutputs = 0, StereoPairs = 0 }
end

function Device.Set(argIndex)
	local model = tblModels[argIndex]
	if not model then
		Logger.Error(tblDebug.Source.Setup, "Invalid model index: " .. tostring(argIndex))
		return false
	end

	Device.Information.ID = model.ID
	Device.Information.Model = model.Name
	Device.Information.Description = model.Description
	Device.Capabilities.MaxOutputs = model.Capabilities.Outputs
	Device.Capabilities.StereoPairs = model.Capabilities.StereoPairs
	Device.Channels = {}
	Device.Outputs = {}

	for i = 1, model.Capabilities.Outputs do
		Device.Channels[i] = { ID = i, InputID = 100 }
		Device.Outputs[i] = { ID = i, Label = "Output " .. string.char(64 + i) }
	end

	Device.RebuildZones()
	return true
end

-- Preselecciona el modelo indicado en la propiedad de diseño "Model" (ver
-- properties.lua) antes de que haya una conexión real, para que las zonas
-- de la página Audio ya reflejen su número de canales al arrancar el
-- plugin. En cuanto el amplificador real responde, Device.ApplyResponse
-- detecta su modelo verdadero y vuelve a llamar a Device.Set(), que
-- sobrescribe esta preselección con los datos reales del equipo.
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

function Device.ApplyResponse(response)
	local normalized = tostring(response or "")
	local function assign(pattern, field)
		local value = normalized:match(pattern)
		if value and value ~= "" then
			Device.Information[field] = value:gsub("^%s+", ""):gsub("%s+$", "")
		end
	end

	assign("[Dd][Ee][Vv][Ii][Cc][Ee].*[Mm][Oo][Dd][Ee][Ll]%s*[:=]?%s*(.-)%s*$", "Model")
	assign("[Mm][Oo][Dd][Ee][Ll]%s*[:=]?%s*(.-)%s*$", "Model")
	assign("[Dd][Ee][Vv][Ii][Cc][Ee].*[Ss][Ee][Rr][Ii][Aa][Ll]%s*[:=]?%s*(.-)%s*$", "Serial")
	assign("[Ss][Ee][Rr][Ii][Aa][Ll]%s*[Nn]?[Oo]?%s*[:=]?%s*(.-)%s*$", "Serial")
	assign("[Dd][Ee][Vv][Ii][Cc][Ee].*[Mm][Aa][Cc]%s*[:=]?%s*(.-)%s*$", "MAC")
	assign("[Mm][Aa][Cc]%s*[:=]?%s*(.-)%s*$", "MAC")
	assign("[Dd][Ee][Vv][Ii][Cc][Ee].*[Dd][Ee][Ss][Cc][Rr][Ii][Pp][Tt][Ii][Oo][Nn]%s*[:=]?%s*(.-)%s*$", "Description")
	assign("[Dd][Ee][Ss][Cc][Rr][Ii][Pp][Tt][Ii][Oo][Nn]%s*[:=]?%s*(.-)%s*$", "Description")

	if Device.Information.Model ~= "" then
		for index, model in ipairs(tblModels) do
			if model.Name == Device.Information.Model then
				Device.Set(index)
				break
			end
		end
	end
end

function funcValidateIP(argString)
	if argString == nil then return false end
	local a, b, c, d = tostring(argString):match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
	a, b, c, d = tonumber(a), tonumber(b), tonumber(c), tonumber(d)
	return a and b and c and d and a <= 255 and b <= 255 and c <= 255 and d <= 255
end
