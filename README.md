# Elemental IRC Bot
Elemental is a general-purpose Lua IRC Bot.
Focus is put on having Elemental (largely) modular: by allowing as much parts of the program to be as interchangeable as possible.
To achieve this, multiple features shall be provided:
Facilities to load external functions and modules (during run-time) [DONE]
Introspective debugging and error-handling facilities [to be done]
The ability to replace even the most integral parts of the program during run-time [to be done]

## "Installation"
Edit the 'elemental' executable to have it use the proper Lua5.1 interpreter.

Note: since all configuration files are Lua scripts, they should adhere to the Lua syntax, or an error will be raised.

```lua
	table = {
		field = value,
		field = "value",
		field = "value\"",
		field = 1141113,
		field = "concatenate".."strings",
	}
```
The 'PATH' variable may be used in any configuration file, to retrieve the relative path to where Elemental was executed:
```lua
	PATH.."/logs/my_logfile",
```

Edit the cfg/global.lua configuration file. Double-check the loadlists lib_load and mod_load.
Conventionally, lib_load needn't be modified. The mod_load table must contain strings that correspond with the names of the directories in the mod/ folder belonging to the modules
you wish to load. Elemental will look for a module.lua file in the specified directory, and continue from there. Modules are loaded in order of which string was specified first in
the table. Because of this, do note that modules must be loaded in order with every modules' dependencies; if a module depends on another module, then that dependency must be loaded first.

Edit the cfg/irc/network.lua configuration file, and enter the proper server, port, etc.
As is stated, the 'compat_lib' variable is to specify which 'compatibility library' is to be loaded.
Elemental remains (mostly) RFC2812 compliant. This means that channel modes such as +h (halfop) and +a (admin) may not be present on every server, among other differences.
The 'compat_lib' variable is a string to the file name (EXCLUDING .lua extension) in the mod/compat/ directory.

Edit the cfg/irc/channels.lua configuration file, and configure the behaviour of every channel. The 'private' channel corresponds to messages sent in private (not
through a channel), while the 'global' channel handles each and every message received from the server.

To add a channel, declare a new table in the 'channels' register, with the channel's name (including prefix) as the index:
```lua
	channels["#my_channel"]	= {}
```
Next, we may add fields to this channel's table, to further elaborate on it's behaviour.
The default fields are 'sinks' and 'install'. Some modules may require you to specify additional configuration, such as log file locations, commands, etc.
These additional fields are elaborated upon by that modules' documentation.

Since the configuration files are raw lua code, we can circumvent the need to write out 'channels["#my_channel"]' time and time again, by creating a reference to it:
```lua
	local my_chan = channels["#my_channel"]

	my_chan.sinks = {}
	my_chan.install = {}
```
Note the presence of the 'local' keyword. If this keyword is omitted, then 'my_chan' will be assigned globally, which is not desireable.
To add entries to the specified fields, one may do the following:
```lua
	my_chan.sinks = {}
	my_chan.sinks[1] = Modules.print.channel
	my_chan.sinks[2] = Modules.some_sink.etc
```
One may also use the following notation:
```lua
	my_chan.sinks = {
		Modules.print.channel,
		Modules.some_sink.etc,
	}
```
All sinks specified in the 'sinks' table will be hooked to the channel.
Sometimes, for a module to work, a channel object may need to be directly modified (by the adding of fields, etc.)
For this, some modules have a function that modifies the channel in this way. These functions shall be called 'installers' for convenience.
The 'install' table must contain references to an installer. Elemental will run each installer, passing the respective channel object to it.
```lua
	my_chan.install = {
		Modules.command.enable,
		Modules.log.enable,
	}
```
Commonly, the install function is named 'install', 'enable', or something similar.
It is not an uncommon occurrence that installers hook one or more sinks to the channel by themselves. This shall be noted in the modules' respective documentation.

One needn't specify numbers as table indices. One can also specify strings for readability:
```lua
	my_chan.install = {}
	my_chan.install.command = Modules.command.enable
	my_chan.install.log = Modules.log.enable
```

Now, run Elemental:
```
	./elemental
```