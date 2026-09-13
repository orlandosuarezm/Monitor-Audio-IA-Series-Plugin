Logger = {}
tblDebug = {
	Enabled = true,
	Name = "Monitor Audio",
	Type = { Message = "Message", Error = "Error" },
	Source = { Init = "Init", Setup = "Setup", UI = "UI", TCP = "TCP", TX = "TX", RX = "RX" },
	Filter = { Init = true, Setup = true, UI = true, TCP = true, TX = true, RX = true }
}

-- Niveles de la propiedad "DebugLevel" (properties.lua), de menos a más
-- detalle:
--   Off      -- nada.
--   Errors   -- solo errores.
--   Commands -- errores + tráfico real hacia/desde el amplificador (TX/RX:
--               comandos SET/GET enviados y líneas de feedback recibidas),
--               sin el ruido de cada evento de UI.
--   All      -- todo, incluyendo qué botón/control de la UI disparó cada
--               acción (Source.UI) y mensajes de Setup/Init/TCP.
-- Antes solo había "Off"/"Errors"/"All": no había forma de ver el tráfico
-- de comandos sin también ver cada clic de la UI.
local kLevelRank = { Off = 0, Errors = 1, Commands = 2, All = 3 }
local kSourceRank = { [tblDebug.Source.TX] = kLevelRank.Commands, [tblDebug.Source.RX] = kLevelRank.Commands }

local function WriteLog(argSource, argType, argMessage)
	argSource = tostring(argSource)
	argMessage = tostring(argMessage)

	if tblDebug.Filter[argSource] == false then
		return
	end

	local debugLevel = "All"
	local debugProperty = Properties and Properties["DebugLevel"]
	if debugProperty then debugLevel = debugProperty.Value or debugProperty.String or debugLevel end
	local levelRank = kLevelRank[debugLevel] or kLevelRank.All

	if levelRank == kLevelRank.Off then
		return
	end
	if argType ~= tblDebug.Type.Error then
		local requiredRank = kSourceRank[argSource] or kLevelRank.All
		if levelRank < requiredRank then
			return
		end
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
