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
	graphics["setupBrand"] = {
		Type = "Text",
		Text = "MONITOR AUDIO",
		Color = warmGrey,
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
		Color = beige,
		FontSize = 14,
		Position = { 24, 44 },
		Size = { 260, 20 }
	}
	graphics["setupIpLabel"] = {
		Type = "Text",
		Text = "Amplifier IP address",
		Color = warmGrey,
		FontSize = 12,
		Position = { 24, 72 },
		Size = { 120, 18 }
	}
	graphics["setupPortLabel"] = {
		Type = "Text",
		Text = "TCP port",
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
		Text = "Connection status",
		Color = warmGrey,
		FontSize = 12,
		Position = { 356, 76 },
		Size = { 80, 16 }
	}
	graphics["setupInformationHeader"] = {
		Type = "Text",
		Text = "INFORMATION RECEIVED FROM AMPLIFIER",
		Color = beige,
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
		Position = { 350, 128 },
		Size = { 130, 28 }
	}
	layout["txtDeviceId"] = {
		PrettyName = "Setup~Amplifier information~Device ID",
		Style = "Text",
		Position = { 120, 210 },
		Size = { 390, 24 }
	}
	graphics["setupDeviceIdLabel"] = {
		Type = "Text",
		Text = "Device identifier",
		Color = warmGrey,
		FontSize = 12,
		Position = { 24, 210 },
		Size = { 72, 24 }
	}

	local infoNames = { "Amplifier model", "Serial number", "MAC address", "Description" }
	for index, name in ipairs(infoNames) do
		local y = 248 + (index - 1) * 42
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
			Size = { 390, index == 4 and 48 or 24 }
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
		Legend = "⏻",
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
		Size = { 920, 430 }
	}
	for index = 1, 12 do
		local x = 28 + (index - 1) * 75
		local y = 112
		local suffix = " " .. index
		graphics["zoneLabel" .. index] = {
			Type = "Text",
			Text = "Zone " .. string.char(64 + index),
			Color = beige,
			FontSize = 10,
			HTextAlign = "Center",
			Position = { x, y },
			Size = { 68, 22 }
		}
		layout["txtLabels" .. suffix] = {
			PrettyName = "Audio~Zone " .. index .. "~Label",
			Style = "Text",
			Position = { x, y },
			Size = { 68, 22 }
		}
		layout["btnVolUp" .. suffix] = {
			PrettyName = "Audio~Zone " .. index .. "~Volume Up",
			Style = "Button",
			ButtonStyle = "Trigger",
			Legend = "🔊",
			Color = heritageGreen,
			Position = { x, y + 26 },
			Size = { 68, 42 }
		}
		layout["listInputs" .. suffix] = {
			PrettyName = "Audio~Zone " .. index .. "~Input",
			Style = "Text",
			Position = { x, y + 76 },
			Size = { 68, 28 }
		}
		layout["fader" .. suffix] = {
			PrettyName = "Audio~Zone " .. index .. "~Gain",
			Style = "Fader",
			Color = beige,
			Position = { x + 22, y + 116 },
			Size = { 24, 190 }
		}
		layout["btnVolDown" .. suffix] = {
			PrettyName = "Audio~Zone " .. index .. "~Volume Down",
			Style = "Button",
			ButtonStyle = "Trigger",
			Legend = "🔉",
			Color = heritageGreen,
			Position = { x, y + 318 },
			Size = { 68, 42 }
		}
		layout["btnMute" .. suffix] = {
			PrettyName = "Audio~Zone " .. index .. "~Mute",
			Style = "Button",
			ButtonStyle = "Toggle",
			Legend = "🔇",
			Color = { 204, 94, 61 },
			Position = { x, y + 366 },
			Size = { 68, 42 }
		}
	end
end