Logger = {}
tblDebug = {
	Enabled = true,
	Name = "Monitor Audio",
	Type = { Message = "Message", Error = "Error" },
	Source = { Init = "Init", Setup = "Setup", UCI = "UCI", UI = "UI", TCP = "TCP", TX = "TX", RX = "RX" },
	Filter = { Init = true, Setup = true, UCI = true, UI = true, TCP = true, TX = true, RX = true }
}

local function WriteLog(argSource, argType, argMessage)
	argSource = tostring(argSource)
	argMessage = tostring(argMessage)
	local debugLevel = "All"
	local debugProperty = Properties and Properties["DebugLevel"]
	if debugProperty then debugLevel = debugProperty.Value or debugProperty.String or debugLevel end

	if tblDebug.Filter[argSource] == false then
		return
	end
	if debugLevel == "Off" or (debugLevel == "Errors" and argType ~= tblDebug.Type.Error) then
		return
	end

	local log = string.format("%s [%s] [%-7s] %s", os.date("%H:%M:%S"), tblDebug.Name, argSource, argMessage)
	print(log)

	if tblDebug.Enabled then
		if argType == tblDebug.Type.Error then
			Log.Error(log)
		else
			Log.Message(log)
		end
	end

	return log
end

function Logger.Message(source, message, ...)
	WriteLog(source, tblDebug.Type.Message, message)
end

function Logger.Error(source, message, ...)
	WriteLog(source, tblDebug.Type.Error, message)
end

function Logger.Tx(command)
	WriteLog(tblDebug.Source.TX, tblDebug.Type.Message, command)
end

function Logger.Rx(response)
	WriteLog(tblDebug.Source.RX, tblDebug.Type.Message, response)
end

function Logger.Uci(controlName, message)
	local detail = tostring(controlName)
	if message and message ~= "" then detail = detail .. " - " .. tostring(message) end
	WriteLog(tblDebug.Source.UCI, tblDebug.Type.Message, detail)
end
