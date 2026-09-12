TCP = {}
TCP.Socket = TcpSocket.New()
TCP.Socket.ReadTimeout = 0
TCP.Socket.WriteTimeout = 0
TCP.Socket.ReconnectTimeout = 2

function TCP.Connect(ip, port)
	TCP.Disconnect()
	TCP.Socket:Connect(ip, port)
	Logger.Message(tblDebug.Source.TCP, string.format("Connecting to %s:%d", ip, port))
end

function TCP.Disconnect()
	TCP.Socket:Disconnect()
	Device.Setup.Connected = false
	Device.Setup.Power = false
	Device.ClearInformation()
	UI.UpdateDevice()
	UI.UpdateSetup()
	Logger.Message(tblDebug.Source.TCP, "Disconnect")
end

function TCP.Send(command)
	if not TCP.Socket.IsConnected then
		Logger.Error(tblDebug.Source.TCP, "Socket not connected")
		return false
	end

	TCP.Socket:Write(command .. kCommandEnd)
	Logger.Tx(command)
	return true
end

-- El equipo puede acumular varias líneas de feedback en un mismo evento de
-- socket (p. ej. tras SUBSCRIBE REG o la secuencia de inicialización), y
-- cada línea es una respuesta independiente terminada en kAnswerEnd (ver
-- docs/MonitorAudio_IA_Series_Control_LAN.docx, sección 3). Se divide el
-- buffer y se procesa una línea a la vez, en vez de tratar todo el buffer
-- como una única respuesta.
function TCP.SplitLines(data)
	local lines = {}
	if not data or data == "" then return lines end

	for line in (data .. kAnswerEnd):gmatch("(.-)" .. kAnswerEnd) do
		if line ~= "" then table.insert(lines, line) end
	end

	return lines
end

TCP.Socket.EventHandler = function(sock, evt, err)
	if evt == TcpSocket.Events.Connected then
		Device.Setup.Connected = true
		UI.UpdateDevice()
		Protocol.RunInitSequence()
	elseif evt == TcpSocket.Events.Reconnect then
		Device.Setup.Connected = false
		UI.UpdateDevice()
	elseif evt == TcpSocket.Events.Data then
		local data = sock:Read(sock.BufferLength)
		if data then
			for _, line in ipairs(TCP.SplitLines(data)) do
				Logger.Rx(line)
				Protocol.HandleResponse(line)
			end
		end
	elseif evt == TcpSocket.Events.Closed then
		Device.Setup.Connected = false
		UI.UpdateDevice()
	elseif evt == TcpSocket.Events.Error then
		Device.Setup.Connected = false
		Device.ClearInformation()
		UI.UpdateDevice()
		UI.UpdateSetup()
		Logger.Error(tblDebug.Source.TCP, tostring(err))
	elseif evt == TcpSocket.Events.Timeout then
		Device.Setup.Connected = false
		Device.ClearInformation()
		UI.UpdateDevice()
		UI.UpdateSetup()
		Logger.Error(tblDebug.Source.TCP, "TCP timeout")
	end
end
