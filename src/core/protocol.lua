Protocol = {}

Protocol.Commands = {
	PowerOn = "POWER_ON",
	PowerOff = "POWER_OFF",
	SubscribeReg = "SUBSCRIBE REG",
	SubscribeDyn = "SUBSCRIBE DYN %.1f",
	Identify = "SET SETUP.SYSTEM.LOCATING %d",
	Get = "GET",
	Set = "SET",
	DeviceInfo = "GET DEVICE",
	SystemState = "GET SYSTEM.STATUS.STATE",
	ChannelVolume = "GET CHANNEL.%d.VOLUME",
	ChannelMute = "GET CHANNEL.%d.MUTE",
	SetChannelVolume = "SET CHANNEL.%d.VOLUME %.1f",
	SetChannelMute = "SET CHANNEL.%d.MUTE %d",
	VolumeStepUp = "SET CHANNEL.%d.VOLUME +1",
	VolumeStepDown = "SET CHANNEL.%d.VOLUME -1"
}

function Protocol.Build(name, ...)
	local command = Protocol.Commands[name]

	if not command then
		Logger.Error(tblDebug.Source.TCP, "Unknown command: " .. tostring(name))
		return nil
	end

	if select("#", ...) > 0 then
		command = string.format(command, ...)
	end

	return command
end

function Protocol.Send(name, ...)
	local command = Protocol.Build(name, ...)

	if command then
		TCP.Send(command)
	end
end

function Protocol.HandleResponse(response)
	Device.ApplyResponse(response)
	UI.UpdateDevice()
end
