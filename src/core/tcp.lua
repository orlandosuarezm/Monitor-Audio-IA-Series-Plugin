TCP = {}
TCP.Socket = TcpSocket.New()
TCP.Socket.ReadTimeout = 0
TCP.Socket.WriteTimeout = 0
TCP.Socket.ReconnectTimeout = 2
TCP.WaitingResponse = false
TCP.PollTimer = Timer.New()

tblPolling = { Enabled = false, Interval = 2, Index = 1, Commands = {} }

function TCP.Connect(ip, port)
	TCP.Disconnect()
	TCP.Socket:Connect(ip, port)
	Logger.Message(tblDebug.Source.TCP, string.format("Connecting to %s:%d", ip, port))
end

function TCP.Disconnect()
	TCP.Socket:Disconnect()
	TCP.WaitingResponse = false
	TCP.StopPolling()
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

	if TCP.WaitingResponse then
		Logger.Error(tblDebug.Source.TCP, "Previous command still pending")
		return false
	end

	TCP.WaitingResponse = true
	TCP.Socket:Write(command .. kCommandEnd)
	Logger.Tx(command)
	return true
end

function TCP.StartPolling()
	tblPolling.Enabled = true
	tblPolling.Index = 1
	TCP.PollTimer:Start(tblPolling.Interval)
end

function TCP.StopPolling()
	tblPolling.Enabled = false
	TCP.PollTimer:Stop()
end

function TCP.Polling()
	if not tblPolling.Enabled or not Device.Setup.Connected or #tblPolling.Commands == 0 then
		return
	end

	TCP.Send(tblPolling.Commands[tblPolling.Index])
	tblPolling.Index = tblPolling.Index % #tblPolling.Commands + 1
end

function TCP.FormatResponse(data)
	if not data then
		return ""
	end

	if data:sub(-#kAnswerEnd) == kAnswerEnd then
		data = data:sub(1, -#kAnswerEnd - 1)
	end

	return data
end

TCP.PollTimer.EventHandler = function()
	TCP.Polling()
end

TCP.Socket.EventHandler = function(sock, evt, err)
	if evt == TcpSocket.Events.Connected then
		Device.Setup.Connected = true
		UI.UpdateDevice()
		Protocol.Send("DeviceInfo")
		TCP.StartPolling()
	elseif evt == TcpSocket.Events.Reconnect then
		Device.Setup.Connected = false
		UI.UpdateDevice()
	elseif evt == TcpSocket.Events.Data then
		local data = sock:Read(sock.BufferLength)
		if data then
			TCP.WaitingResponse = false
			local response = TCP.FormatResponse(data)
			Logger.Rx(response)
			Protocol.HandleResponse(response)
		end
	elseif evt == TcpSocket.Events.Closed then
		Device.Setup.Connected = false
		TCP.WaitingResponse = false
		TCP.StopPolling()
		UI.UpdateDevice()
	elseif evt == TcpSocket.Events.Error then
		Device.Setup.Connected = false
		TCP.WaitingResponse = false
		TCP.StopPolling()
		Device.ClearInformation()
		UI.UpdateDevice()
		UI.UpdateSetup()
		Logger.Error(tblDebug.Source.TCP, tostring(err))
	elseif evt == TcpSocket.Events.Timeout then
		Device.Setup.Connected = false
		TCP.WaitingResponse = false
		TCP.StopPolling()
		Device.ClearInformation()
		UI.UpdateDevice()
		UI.UpdateSetup()
		Logger.Error(tblDebug.Source.TCP, "TCP timeout")
	end
end
