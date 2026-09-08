local pageName = "Setup"
local charcoal = { 31, 31, 32 }
local black = { 29, 31, 30 }
local warmGrey = { 211, 209, 199 }
local beige = { 227, 226, 221 }
local heritageGreen = { 88, 98, 80 }
local gold = { 157, 127, 94 }

if props["page_index"] then
	local pageNames = { "Setup", "Audio" }
	pageName = pageNames[props["page_index"].Value] or pageName
end

if pageName == "Setup" then
	layout["lblSetupLogo"] = {
		PrettyName = "Setup~Logo",
		Style = "Text",
		Text = "MONITOR AUDIO",
		Position = { 390, 12 },
		Size = { 180, 24 }
	}
	layout["lblConnection"] = {
		PrettyName = "Setup~Connection~Header",
		Style = "Text",
		Text = "Connection",
		Position = { 24, 44 },
		Size = { 260, 20 }
	}
	layout["lblIpAddress"] = {
		PrettyName = "Setup~Connection~IP Address Label",
		Style = "Text",
		Text = "IP Address",
		Position = { 24, 72 },
		Size = { 120, 18 }
	}
	layout["lblPort"] = {
		PrettyName = "Setup~Connection~Port Label",
		Style = "Text",
		Text = "Port",
		Position = { 220, 72 },
		Size = { 56, 18 }
	}
	layout["lblConnected"] = {
		PrettyName = "Setup~Connection~Connected Label",
		Style = "Text",
		Text = "Connected",
		Position = { 356, 76 },
		Size = { 80, 16 }
	}
	layout["lblInformation"] = {
		PrettyName = "Setup~Information~Header",
		Style = "Text",
		Text = "Information",
		Position = { 24, 178 },
		Size = { 180, 20 }
	}
	layout["lblDeviceId"] = {
		PrettyName = "Setup~Device~ID Label",
		Style = "Text",
		Text = "Device ID",
		Position = { 24, 210 },
		Size = { 72, 24 }
	}
	graphics["setupLogo"] = {
		Type = "Text",
		Text = "MONITOR AUDIO",
		Color = warmGrey,
		FontSize = 14,
		HAlign = "Right",
		Position = { 390, 12 },
		Size = { 180, 24 }
	}
	graphics["setupConnectionHeader"] = {
		Type = "Text",
		Text = "Connection",
		Color = beige,
		FontSize = 14,
		Position = { 24, 44 },
		Size = { 260, 20 }
	}
	graphics["setupIpLabel"] = {
		Type = "Text",
		Text = "IP Address",
		Color = warmGrey,
		FontSize = 12,
		Position = { 24, 72 },
		Size = { 120, 18 }
	}
	graphics["setupPortLabel"] = {
		Type = "Text",
		Text = "Port",
		Color = warmGrey,
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
		Text = "Connected",
		Color = warmGrey,
		FontSize = 12,
		Position = { 356, 76 },
		Size = { 80, 16 }
	}
	layout["btnIdentify"] = {
		PrettyName = "Setup~Connection~Identify (ID)",
		Style = "Button",
		ButtonStyle = "Toggle",
		Legend = "ID",
		Color = gold,
		Position = { 474, 72 },
		Size = { 80, 28 }
	}
	layout["btnSimulateConnection"] = {
		PrettyName = "Setup~Connection~Test Connection",
		Style = "Button",
		ButtonStyle = "Trigger",
		Legend = "Test Connection",
		Color = heritageGreen,
		Position = { 24, 128 },
		Size = { 130, 28 }
	}
	graphics["setupInformationHeader"] = {
		Type = "Text",
		Text = "Information",
		Color = beige,
		FontSize = 14,
		Position = { 24, 178 },
		Size = { 180, 20 }
	}
	layout["txtDeviceId"] = {
		PrettyName = "Setup~Device~ID",
		Style = "Text",
		Position = { 120, 210 },
		Size = { 176, 24 }
	}
	graphics["setupDeviceIdLabel"] = {
		Type = "Text",
		Text = "Device ID",
		Color = warmGrey,
		FontSize = 12,
		Position = { 24, 210 },
		Size = { 72, 24 }
	}

	local infoNames = { "Model", "Serial Number", "MAC Address", "Description" }
	for index, name in ipairs(infoNames) do
		local y = 248 + (index - 1) * 46
		graphics["setupInfoLabel" .. index] = {
			Type = "Text",
			Text = name,
			Color = warmGrey,
			FontSize = 12,
			Position = { 24, y },
			Size = { 90, index == 4 and 48 or 24 }
		}
		layout["txtInformation " .. index] = {
			PrettyName = "Setup~Device Information~" .. name,
			Style = "Text",
			Position = { 120, y },
			Size = { 176, index == 4 and 48 or 24 }
		}
	end
else
	layout["btnPower"] = {
		PrettyName = "Audio~Amplifier Power",
		Style = "Button",
		ButtonStyle = "Toggle",
		Legend = "Power",
		Color = heritageGreen,
		Position = { 20, 8 },
		Size = { 80, 28 }
	}
	for index = 1, 12 do
		local x = 20 + ((index - 1) % 4) * 72
		local y = 48 + math.floor((index - 1) / 4) * 112
		local suffix = " " .. index
		layout["txtLabels" .. suffix] = { PrettyName = "Audio~Zone " .. index .. "~Label", Style = "Text", Position = { x, y }, Size = { 64, 18 } }
		layout["listInputs" .. suffix] = { PrettyName = "Audio~Zone " .. index .. "~Input", Style = "Text", Position = { x, y + 20 }, Size = { 64, 18 } }
		layout["fader" .. suffix] = { PrettyName = "Audio~Zone " .. index .. "~Gain", Style = "Fader", Color = beige, Position = { x, y + 42 }, Size = { 24, 52 } }
		layout["btnMute" .. suffix] = { PrettyName = "Audio~Zone " .. index .. "~Mute", Style = "Button", ButtonStyle = "Toggle", Legend = "M", Color = gold, Position = { x + 30, y + 42 }, Size = { 28, 20 } }
	end
end