function Device.ClearZones()
	for i = 1, kMaxZones do Device.Zones[i] = nil end
end

function Device.CreateMonoZone(zoneID, label, inputID, outputID)
	Device.Zones[zoneID] = { ID = zoneID, Label = label, Type = "Mono", InputID = inputID, Gain = 0, Mute = false, Outputs = { outputID } }
end

function Device.CreateStereoZone(zoneID, label, inputID, output1, output2)
	Device.Zones[zoneID] = { ID = zoneID, Label = label, Type = "Stereo", InputID = inputID, Gain = 0, Mute = false, Outputs = { output1, output2 } }
end

function Device.RebuildZones()
	Device.ClearZones()
	local zoneIndex, channel = 1, 1

	while channel <= Device.Capabilities.MaxOutputs do
		local ch1, ch2 = Device.Channels[channel], Device.Channels[channel + 1]
		local input1 = ch1 and Device.Inputs[ch1.InputID]
		local input2 = ch2 and Device.Inputs[ch2.InputID]
		local stereoInputID = nil

		if input1 and input1.Type == "Stereo" then
			stereoInputID = ch1.InputID
		elseif input2 and input2.Type == "Stereo" then
			stereoInputID = ch2.InputID
		end

		if stereoInputID and ch2 then
			Device.CreateStereoZone(zoneIndex, "Zone " .. string.char(64 + zoneIndex), stereoInputID, channel, channel + 1)
			channel = channel + 2
		else
			Device.CreateMonoZone(zoneIndex, "Zone " .. string.char(64 + zoneIndex), ch1.InputID, channel)
			channel = channel + 1
		end
		zoneIndex = zoneIndex + 1
	end

	Device.Capabilities.MaxZones = zoneIndex - 1
end
