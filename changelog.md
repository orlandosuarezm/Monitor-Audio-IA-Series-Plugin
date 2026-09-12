# Changelog

All notable changes to this project will be documented in this file.

## [0.0.2] - Real LAN protocol, model list, and connection-flow fixes

### Fixed
- VolUp/VolDown did nothing: btnVolUp/btnVolDown changed from
  ButtonType/ButtonStyle "Trigger" to "Momentary" (Trigger inside a
  Count array never fired its EventHandler on click).
- Editing the IP/Port fields no longer clears the Amplifier information
  fields or attempts a connection on every edit; that now only happens
  via Test Connection (simulation) or the one-time auto-connect at load
  when a valid IP/port was already saved.
- Setup page text was unreadable in the Light UITheme (hardcoded white
  color on brand/header text).

### Changed
- Replaced the entire protocol layer (src/core/protocol.lua,
  src/core/tcp.lua, src/device/device.lua, src/device/zones.lua,
  src/device/channels.lua) to match the real Monitor Audio LAN protocol,
  reverse-engineered from the Crestron/Control4/RTI drivers
  (docs/MonitorAudio_IA_Series_Control_LAN.docx): ZONE-<letter>
  addressing, real GAIN/MUTE/PRIMARY_SRC commands, the documented
  GET/SUBSCRIBE init sequence, and real "+PATH VALUE" / "#error" response
  parsing.
- Replaced tblModels with the 4 confirmed real models (IA60-4, IA125-4,
  IA800-2, IA800-4) and their real device IDs and zone letters.
- Zone count for the Audio page now reconciles live from the
  amplifier's own feedback (dynamic zone discovery), since the protocol
  has no "get model name" command.
- Hardware-side stereo zone pairs (ZONE-A/B, ZONE-C/D) now hide the
  secondary zone in the UI when the amplifier reports that pair as
  stereo.
- Amplifier information fields (Device ID/Model/Description/Serial/MAC)
  only populate once a real or simulated connection is established, not
  from the design-time "Model" property alone.

### Added
- Design-time "Model" property (Q-SYS Designer property), letting the
  integrator preview channel count and a model description on the Setup
  page before ever connecting.
- Dynamic (DYN) metering feedback (signal level, clip) and input STEREO
  status are now captured into Device state, ready for a future meter UI.

## [0.0.1] - Version reset for pre-release testing

### Changed
- Reset version numbering to 0.0.1 for the current test/pre-release
  build cycle.

## [0.2.0] - Monitor Audio visual theme

### Added
- Monitor Audio official palette applied to the Q-SYS layout.
- Heritage green plugin accent and gold identification/mute controls.
- Updated plugin version metadata to 0.2.0.

## [0.1.0] - Initial Development

### Added
- Initial project structure.
- Monitor Audio amplifier models.
- Device simulation.
- Zone management.
- UI framework.