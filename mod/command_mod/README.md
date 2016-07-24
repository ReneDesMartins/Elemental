# Command Module
## Module Info
**Identifier**: command
**Author**: Fiesta
**Description**: Command parsing and execution system for Elemental.
**Version**: v1.0

Adds the functionality for the parsing of commands.
A command consists out of three parts:
The Prefix, which is the first character in a message.
The Handle, which immediately follows the prefix.
The Arguments, which follow the handle.

To add functionality for commands, add the following lines to your channel configuration:
```lua
	my_channel.commands = ""
	my_channel.prefixes = ""
```
Also, add "command" to your plugin list:
```lua
	my_channel.plugins = "command"
```
One may add any number of prefixes or commands:
```lua
	my_channel.commands = "bhw.syn bhw.genplot eval.eval"
	my_channel.prefixes = "!.&"
```
The synonym command supports the handles 'syn', 'synyonym', 'thes', and 'thesaurus'.
The prefixes enabled are '!', '.', and "&". Thus, the following messages are valid command calls:
```
!syn die
.thes apple
```
The following, are not:
```
^syn die
.command thes apple
```