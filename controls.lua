table.insert(ctrls, 
{ Name = "txtIpAddress", 
  ControlType = "Text", 
  PinStyle = "Output", 
  UserPin = true })

table.insert(ctrls, 
{ Name = "txtPort", 
  ControlType = "Text", 
  PinStyle = "Output", 
  UserPin = true })

table.insert(ctrls, 
{ Name = "Connected", 
  ControlType = "Indicator", 
  IndicatorType = "LED", 
  PinStyle = "Output", 
  UserPin = true })

table.insert(ctrls, 
 { Name = "btnPower",
  ControlType = "Button", 
  ButtonType = "Toggle", 
  PinStyle = "Both", 
  UserPin = true })

table.insert(ctrls, 
{ Name = "btnIdentify", 
  ControlType = "Button", 
  ButtonType = "Toggle", 
  PinStyle = "Both", 
  UserPin = true })

table.insert(ctrls, 
{ Name = "btnSimulateConnection", 
  ControlType = "Button", 
  ButtonType = "Trigger", 
  PinStyle = "Both", 
  UserPin = true })

table.insert(ctrls, 
{ Name = "txtDeviceId", 
  ControlType = "Text",
 PinStyle = "Output", 
 UserPin = true })

table.insert(ctrls, 
{ Name = "txtInformation", 
  ControlType = "Text", 
  PinStyle = "Output", 
  UserPin = true, 
  Count = 4 })

table.insert(ctrls, 
{ Name = "lblSetupLogo", 
  ControlType = "Text", 
  PinStyle = "None", 
  UserPin = false })

table.insert(ctrls, 
{ Name = "lblConnection", 
  ControlType = "Text", 
  PinStyle = "None", 
  UserPin = false })

table.insert(ctrls, 
{ Name = "lblIpAddress", 
  ControlType = "Text", 
  PinStyle = "None", 
  UserPin = false })

table.insert(ctrls, 
{ Name = "lblPort", 
  ControlType = "Text", 
  PinStyle = "None", 
  UserPin = false })

table.insert(ctrls, 
{ Name = "lblConnected", 
  ControlType = "Text", 
  PinStyle = "None", 
  UserPin = false })

table.insert(ctrls, 
{ Name = "lblInformation", 
  ControlType = "Text", 
  PinStyle = "None", 
  UserPin = false })

table.insert(ctrls, 
{ Name = "lblDeviceId", 
  ControlType = "Text", 
  PinStyle = "None", 
  UserPin = false })

table.insert(ctrls, 
{ Name = "txtLabels", 
 ControlType = "Text", 
 PinStyle = "Output", 
 UserPin = true, 
Count = 12 })

table.insert(ctrls, 
{ Name = "listInputs", 
  ControlType = "ComboBox",
  Choices = { "Analog 1", "Analog 2", "Analog 3", "Analog 4", "S/PDIF" },
  PinStyle = "Both", 
  UserPin = true, 
  Count = 12 })

table.insert(ctrls, 
{ Name = "btnVolUp",
  ControlType = "Button", 
  ButtonType = "Trigger", 
  PinStyle = "Both", 
  UserPin = true, 
  Count = 12 })

table.insert(ctrls, 
{ Name = "btnVolDown", 
  ControlType = "Button", 
  ButtonType = "Trigger", 
  PinStyle = "Both", 
  UserPin = true, 
  Count = 12 })

table.insert(ctrls, 
{ Name = "fader", 
  ControlType = "Knob", 
  ControlUnit = "dB", 
  Min = -80, 
  Max = 0, 
  PinStyle = "Both",
  UserPin = true, 
  Count = 12 })

table.insert(ctrls, 
{ Name = "btnMute", 
  ControlType = "Button", 
  ButtonType = "Toggle", 
  PinStyle = "Both", 
  UserPin = true, 
  Count = 12 })