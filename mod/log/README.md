# Log Module
## Module Info
**Identifier**: log
**Author**: Fiesta
**Description**: Logging facilities for Elemental.
**Version**: v1.0

Provides facilities to log individual channels to Elemental.
To add functionality for logging, add the "log" entry to your plugin list:
```lua
	my_channel.plugins = "log"
```
Specify the log format, and output file:
```lua
	my_channel.log_format = "format"
	my_channel.log_file = PATH.."/logs/my_channel.txt"
```
The log format is the name of a file in the mod/log/formats/ folder without the .lua extension.