local pageName = "Setup"

-- Identidad visual de Monitor Audio, tomada de los manuales oficiales en
-- docs/ (Cinergy Setup with Installation Amplifiers 2G, MA_CI-Amps_Manuals_ES,
-- MA_Installation Amplifiers_QSG): impresión minimalista en blanco y negro,
-- con un único acento naranja reservado para el logotipo, los LEDs del panel
-- frontal y los controles interactivos.
local maBlack = { 17, 17, 17 } -- lienzo/fondo casi negro, como el chasis y las cabeceras de los manuales
local maPanel = { 30, 30, 30 } -- relleno de paneles/GroupBox sobre el lienzo oscuro
local maWhite = { 255, 255, 255 } -- texto principal y cabeceras de sección (blanco sobre negro, como en los manuales)
local maGrey = { 170, 170, 170 } -- texto secundario/descriptor y bordes sutiles
local maOrange = { 240, 90, 40 } -- naranja de marca, muestreado del logotipo/LEDs del panel frontal en docs/MA_CI-Amps_Manuals_ES.pdf
local maCopper = { 196, 102, 66 } -- acento secundario atenuado, para acciones no primarias (Identify)
local maAlertRed = { 196, 58, 58 } -- estado Mute/advertencia, diferenciado del naranja de marca

-- Alias para minimizar el diff con el resto del archivo
local charcoal = maPanel
local warmGrey = maGrey
local beige = maWhite
local heritageGreen = maOrange
local gold = maCopper

if props["page_index"] then
	local pageNames = { "Setup", "Audio" }
	pageName = pageNames[props["page_index"].Value] or pageName
end

-- Color de las etiquetas descriptoras: claro sobre lienzo oscuro, oscuro sobre
-- lienzo claro. Ver la propiedad UITheme en properties.lua.
local uiTheme = "Dark"
if props["UITheme"] then
	uiTheme = props["UITheme"].Value or uiTheme
end
local descriptorColor = uiTheme == "Dark" and warmGrey or { 51, 51, 51 }
-- Antes, la marca y las cabeceras de sección ("ENTER THE AMPLIFIER..." etc.)
-- usaban un color de texto fijo (blanco), ilegible en modo Light sobre un
-- lienzo claro. Ahora dependen también de UITheme, igual que descriptorColor.
local brandColor = uiTheme == "Dark" and maWhite or { 20, 20, 20 }

-- Modelo seleccionado en la propiedad "Model" (ver properties.lua). Se usa
-- para previsualizar en el diseño cuántas zonas tendrá el amplificador antes
-- de conectarlo; es una cota superior (cada salida como zona mono), ya que
-- el agrupamiento real en zonas estéreo depende de la entrada seleccionada
-- en cada canal, algo que solo se conoce en tiempo de ejecución.
local selectedModel = nil
if props["Model"] then
	for _, model in ipairs(tblModels) do
		if model.Name == props["Model"].Value then
			selectedModel = model
			break
		end
	end
end
local designZoneCount = selectedModel and selectedModel.Capabilities.Outputs or 12

if pageName == "Setup" then
	graphics["setupBrand"] = {
		Type = "Text",
		Text = "MONITOR AUDIO",
		Color = brandColor,
		Font = "Roboto",
		FontStyle = "Bold",
		FontSize = 16,
		HTextAlign = "Right",
		Position = { 390, 8 },
		Size = { 170, 24 }
	}
	graphics["setupConnectionBox"] = {
		Type = "GroupBox",
		Text = "Network settings",
		Position = { 12, 32 },
		Size = { 558, 116 },
		StrokeColor = warmGrey,
		StrokeWidth = 1,
		CornerRadius = 8
	}
	graphics["setupInformationBox"] = {
		Type = "GroupBox",
		Text = "Amplifier information (read-only)",
		Position = { 12, 164 },
		Size = { 558, 278 },
		StrokeColor = warmGrey,
		StrokeWidth = 1,
		CornerRadius = 8
	}
	graphics["setupConnectionHeader"] = {
		Type = "Text",
		Text = "ENTER THE AMPLIFIER NETWORK SETTINGS",
		Color = brandColor,
		FontSize = 14,
		Position = { 24, 44 },
		Size = { 260, 20 }
	}
	graphics["setupIpLabel"] = {
		Type = "Text",
		Text = "Amplifier IP address",
		Color = descriptorColor,
		FontSize = 12,
		Position = { 24, 72 },
		Size = { 120, 18 }
	}
	graphics["setupPortLabel"] = {
		Type = "Text",
		Text = "TCP port",
		Color = descriptorColor,
		FontSize = 12,
		Position = { 220, 72 },
		Size = { 56, 18 }
	}
	layout["txtIpAddress"] = {
		PrettyName = "Setup~Connection~IP Address",
		Style = "TextBox",
		TextBoxStyle = "Text",
		Position = { 24, 92 },
		Size = { 180, 24 }
	}
	layout["txtPort"] = {
		PrettyName = "Setup~Connection~Port",
		Style = "TextBox",
		TextBoxStyle = "Text",
		Position = { 220, 92 },
		Size = { 56, 24 }
	}
	layout["Connected"] = {
		PrettyName = "Setup~Connection~Connected",
		Style = "LED",
		Position = { 320, 72 },
		Size = { 24, 24 }
	}
	graphics["setupConnectedLabel"] = {
		Type = "Text",
		Text = "Connection status",
		Color = descriptorColor,
		FontSize = 12,
		Position = { 356, 76 },
		Size = { 80, 16 }
	}
	graphics["setupInformationHeader"] = {
		Type = "Text",
		Text = "INFORMATION RECEIVED FROM AMPLIFIER",
		Color = brandColor,
		FontSize = 14,
		Position = { 24, 178 },
		Size = { 220, 20 }
	}
	layout["btnIdentify"] = {
		PrettyName = "Setup~Actions~Identify amplifier",
		Style = "Button",
		ButtonStyle = "Toggle",
		Legend = "Identify",
		Color = gold,
		Position = { 474, 72 },
		Size = { 84, 28 }
	}
	layout["btnSimulateConnection"] = {
		PrettyName = "Setup~Actions~Test connection",
		Style = "Button",
		ButtonStyle = "Trigger",
		Legend = "Test Connection",
		Color = heritageGreen,
		Position = { 350, 114 },
		Size = { 130, 28 }
	}
	layout["txtDeviceId"] = {
		PrettyName = "Setup~Amplifier information~Device ID",
		Style = "Text",
		Color = brandColor,
		Position = { 120, 210 },
		Size = { 220, 24 }
	}
	graphics["setupDeviceIdLabel"] = {
		Type = "Text",
		Text = "Device identifier",
		Color = descriptorColor,
		FontSize = 12,
		Position = { 24, 210 },
		Size = { 72, 24 }
	}

	local infoNames = { "Amplifier model", "Serial number", "MAC address", "Description" }
	for index, name in ipairs(infoNames) do
		local y = 248 + (index - 1) * 42
		local isDescription = index == 4
		graphics["setupInfoLabel" .. index] = {
			Type = "Text",
			Text = name,
			Color = descriptorColor,
			FontSize = 12,
			Position = { 24, y },
			Size = { 90, isDescription and 48 or 24 }
		}
		layout["txtInformation " .. index] = {
			PrettyName = "Setup~Device Information~" .. name,
			Style = "Text",
			Color = brandColor,
			WordWrap = isDescription,
			Position = { 120, y },
			Size = isDescription and { 390, 48 } or { 220, 24 }
		}
	end
else
graphics["audioBrand"] = {
	Type = "Text",
	Text = "MONITOR AUDIO  /  IA SERIES",
	Color = warmGrey,
	Font = "Roboto",
	FontStyle = "Bold",
	FontSize = 14,
	HTextAlign = "Right",
	Position = { 690, 12 },
	Size = { 230, 22 }
}
	graphics["audioPowerBox"] = {
		Type = "GroupBox",
		Text = "Power",
		HTextAlign = "Left",
		Fill = charcoal,
		StrokeColor = warmGrey,
		StrokeWidth = 1,
		CornerRadius = 8,
		Position = { 12, 10 },
		Size = { 170, 62 }
	}
	layout["btnPower"] = {
		PrettyName = "Audio~Amplifier Power",
		Style = "Button",
		ButtonStyle = "Toggle",
		Legend = "POWER",
		Color = heritageGreen,
		Position = { 30, 30 },
		Size = { 54, 32 }
	}
	graphics["audioChannelsBox"] = {
		Type = "GroupBox",
		Text = "Channels",
		HTextAlign = "Left",
		Fill = charcoal,
		StrokeColor = warmGrey,
		StrokeWidth = 1,
		CornerRadius = 8,
		Position = { 12, 86 },
		Size = { 920, 460 }
	}
	for index = 1, 12 do
		local x = 28 + (index - 1) * 75
		local y = 112
		local suffix = " " .. index
		-- Además de ocultarse/mostrarse en tiempo de ejecución según el
		-- amplificador realmente conectado (ver UI.EnableAudioControls en
		-- src/ui/ui.lua), aquí se ocultan ya en el propio diseño las zonas
		-- que excedan el número de canales del modelo elegido en la
		-- propiedad "Model", para previsualizar el layout sin necesidad de
		-- desplegar el plugin.
		local isBeyondModel = index > designZoneCount
		-- Nota: la etiqueta "Zona X" ya no se dibuja como gráfico estático aquí
		-- (duplicaba a layout["txtLabels"], y al ser un gráfico de diseño no
		-- puede ocultarse en tiempo de ejecución, por lo que "Zona C".."Zona L"
		-- quedaban visibles siempre aunque el amplificador solo tuviera 2
		-- canales). El texto de la zona lo muestra únicamente el control
		-- dinámico txtLabels, que sí se oculta/muestra según el modelo conectado.
		layout["txtLabels" .. suffix] = {
			PrettyName = "Audio~Zone " .. index .. "~Label",
			Style = "Text",
			IsInvisible = isBeyondModel,
			Position = { x, y },
			Size = { 68, 22 }
		}
		layout["btnVolUp" .. suffix] = {
			PrettyName = "Audio~Zone " .. index .. "~Volume Up",
			Style = "Button",
			ButtonStyle = "Trigger",
			Legend = "VOL+",
			Color = heritageGreen,
			IsInvisible = isBeyondModel,
			Position = { x, y + 26 },
			Size = { 68, 42 }
		}
		layout["listInputs" .. suffix] = {
			PrettyName = "Audio~Zone " .. index .. "~Input",
			Style = "ComboBox",
			IsInvisible = isBeyondModel,
			Position = { x, y + 76 },
			Size = { 68, 28 }
		}
		layout["fader" .. suffix] = {
			PrettyName = "Audio~Zone " .. index .. "~Gain",
			Style = "Fader",
			Color = beige,
			IsInvisible = isBeyondModel,
			Position = { x + 14, y + 116 },
			Size = { 40, 190 }
		}
		layout["btnVolDown" .. suffix] = {
			PrettyName = "Audio~Zone " .. index .. "~Volume Down",
			Style = "Button",
			ButtonStyle = "Trigger",
			Legend = "VOL-",
			Color = heritageGreen,
			IsInvisible = isBeyondModel,
			Position = { x, y + 318 },
			Size = { 68, 42 }
		}
		layout["btnMute" .. suffix] = {
			PrettyName = "Audio~Zone " .. index .. "~Mute",
			Style = "Button",
			ButtonStyle = "Toggle",
			Legend = "MUTE",
			Color = maAlertRed,
			IsInvisible = isBeyondModel,
			Position = { x, y + 366 },
			Size = { 68, 42 }
		}
	end
end