UI = {
	Connected = false,
	DeviceID = Controls.txtDeviceId,
	Information = { Model = Controls.txtInformation[1], Serial = Controls.txtInformation[2], MAC = Controls.txtInformation[3], Description = Controls.txtInformation[4] },
	Setup = { IP = Controls.txtIpAddress, Port = Controls.txtPort, Connected = Controls.Connected, Power = Controls.btnPower, Identify = Controls.btnIdentify, Simulate = Controls.btnSimulateConnection },
	Zones = {}
}

for i = 1, kMaxZones do
	UI.Zones[i] = { Label = Controls.txtLabels[i], Inputs = Controls.listInputs[i], VolUp = Controls.btnVolUp[i], VolDown = Controls.btnVolDown[i], Fader = Controls.fader[i], Mute = Controls.btnMute[i] }
end

local inputIDs = { 100, 101, 102, 103, 200 }
local inputChoices = {}
for _, inputID in ipairs(inputIDs) do
	table.insert(inputChoices, tblInputs[inputID].Description)
end
for i = 1, kMaxZones do UI.Zones[i].Inputs.Choices = inputChoices end

function UI.EnableAudioControls(visible, powerOn, zoneCount)
	for i = 1, kMaxZones do
		local zone = UI.Zones[i]
		local isVisible = visible and i <= (tonumber(zoneCount) or 0)
		zone.Label.IsInvisible, zone.Inputs.IsInvisible = not isVisible, not isVisible
		zone.VolUp.IsInvisible, zone.VolDown.IsInvisible = not isVisible, not isVisible
		zone.Fader.IsInvisible, zone.Mute.IsInvisible = not isVisible, not isVisible
		zone.Inputs.IsDisabled, zone.VolUp.IsDisabled = not powerOn, not powerOn
		zone.VolDown.IsDisabled, zone.Fader.IsDisabled = not powerOn, not powerOn
		zone.Mute.IsDisabled = not powerOn
	end
end

function UI.UpdateZones()
	for i = 1, kMaxZones do
		local uiZone, deviceZone = UI.Zones[i], Device.Zones[i]
		if deviceZone then
			uiZone.Label.String = deviceZone.Label
			uiZone.Inputs.String = Device.Inputs[deviceZone.InputID].Description
			uiZone.Fader.Value, uiZone.Mute.Boolean = deviceZone.Gain, deviceZone.Mute
		else
			uiZone.Label.String, uiZone.Inputs.String = "Zone " .. string.char(64 + i), ""
			uiZone.Fader.Value, uiZone.Mute.Boolean = 0, false
		end
	end
end

-- Device Identifier / Modelo / Descripción / Serial / MAC deben reflejar
-- únicamente datos reales del amplificador: permanecen en blanco hasta que
-- se establece una conexión (Test Connection en simulación, o una conexión
-- TCP real -- ver UI.TryConnect/UI.SimulateConnection en events.lua). La
-- propiedad "Model" solo determina el número de canales que se
-- previsualiza en el diseño (Device.ApplyPropertyModel, main.lua) y el
-- panel gráfico "Selected model (design-time preview...)" en Setup
-- (layout.lua) -- ninguno de los dos depende de estos Controls.
function UI.UpdateDevice()
	local connected = Device.Setup.Connected
	UI.Connected = connected

	UI.DeviceID.String = connected and tostring(Device.Information.ID or "") or ""
	UI.DeviceID.IsDisabled = not connected

	for name, control in pairs(UI.Information) do
		control.String = connected and (Device.Information[name] or "") or ""
		control.IsDisabled = not connected
	end

	UI.UpdateZones()
	-- Las zonas de la página Audio sí se muestran en cuanto se conoce un
	-- número de canales (por la propiedad "Model" o por el amplificador
	-- real), independientemente de esto: ver Device.GetZoneCount() abajo.
	UI.EnableAudioControls(Device.GetZoneCount() > 0, Device.Setup.Power, Device.GetZoneCount())
	UI.Setup.Power.IsDisabled, UI.Setup.Identify.IsDisabled = not connected, not connected
	UI.Setup.Power.Boolean = Device.Setup.Power
end

function UI.UpdateSetup()
	local validIP = funcValidateIP(UI.Setup.IP.String)
	local validPort = Device.Setup.Port > 0 and Device.Setup.Port <= 65535
	UI.Setup.IP.IsDisabled = false
	UI.Setup.Port.IsDisabled = not validIP
	UI.Setup.Connected.Boolean = Device.Setup.Connected
	UI.Setup.Power.Boolean = Device.Setup.Power
	UI.Setup.Identify.Boolean = false
	UI.Setup.Simulate.IsDisabled = not (validIP and validPort)
end

function UI.Init()
	-- Los controles txtIpAddress/txtPort son UserPin con PinStyle "Output",
	-- así que Q-SYS conserva su valor String entre cargas del diseño. Antes,
	-- Device.Init() los reiniciaba a "" y esta función copiaba ese valor
	-- vacío de vuelta al control, borrando la última IP/puerto buenos en
	-- cada carga. Ahora se lee primero lo que el control ya trae guardado.
	local savedIP = UI.Setup.IP.String
	local savedPort = tonumber(UI.Setup.Port.String)

	if funcValidateIP(savedIP) then
		Device.Setup.IP = savedIP
	else
		UI.Setup.IP.String = ""
	end

	if savedPort and savedPort > 0 and savedPort <= 65535 then
		Device.Setup.Port = savedPort
		UI.Setup.Port.String = tostring(savedPort)
	end

	UI.DeviceID.IsDisabled = true
	UI.UpdateSetup()
	UI.UpdateZones()

	-- Con IP y puerto ya válidos no hace falta tocar los campos para
	-- disparar el EventHandler: se intenta conectar directamente.
	if funcValidateIP(Device.Setup.IP) and Device.Setup.Port > 0 then
		UI.TryConnect()
	end
end
