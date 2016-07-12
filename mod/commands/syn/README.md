# Command Module
## Module Info
**Identifier**: syn
**Author**: Fiesta
**Description**: Synonym lookup for Elemental.
**Version**: v1.0

This command allows users to find synonyms, antonyms, related, or similar words using Elemental. It also includes a plot generator.
This relies on the luajson and luasocket.http libraries for Lua 5.1.
Every command except the plot generator also requires an API key from words.bighugelabs.com, which should be added into the module.lua file.
To enable these commands, add the following lines to your channel configuration:
```lua
	my_channel.syn	= Modules.bhw.syn -- Synonym lookup.
	my_channel.ant	= Modules.bhw.ant -- Antonym lookup.
	my_channel.sim	= Modules.bhw.sim -- Similarity lookup.
	my_channel.rel	= Modules.bhw.rel -- Relation lookup.
	my_channel.plot = Modules.bhw.plotgen -- Plot generation tool.