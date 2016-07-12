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
	my_channel.commands = {}
	my_channel.prefixes = {}
	my_channel.install.command = Modules.command.enable
```
One may add any number of prefixes or commands:
```lua
	my_channel.commands.synonym = Modules.bhw.syn,
	my_channel.prefixes[1] = "!"
	my_channel.prefixes[2] = "."
```
The synonym command supports the handles 'syn', 'synyonym', 'thes', and 'thesaurus'.
The prefixes enabled are '!' and '.' Thus, the following messages are valid command calls:
!syn die
.thes apple
The following, are not:
&syn die
.command thes apple