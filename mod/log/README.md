# Log Module
## Module Info
**Identifier**: log
**Author**: Fiesta
**Description**: Logging facilities for Elemental.
**Version**: v1.0

Provides facilities to log individual channels to Elemental.
To add functionality for logging, add the following lines to your channel configuration:
```lua
	my_channel.install.log = Modules.log.enable
```
Specify the log format, and output file:
```lua
	my_channel.log = {}
	my_channel.log.format = "format"
	my_channel.log.file = PATH.."/logs/my_channel.txt"
```
The log format is the name of a file in the mod/log/formats/ folder without the .lua extension.