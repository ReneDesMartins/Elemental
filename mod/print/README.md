# Print Module
## Module Info
**Identifier**: print
**Author**: Fiesta
**Description**: Channel sink that prints messages on the screen.
**Version**: v1.0

Provides two sinks: *global*, and *channel*.
The *global* sink may be hooked to the *global* channel, while the *channel* sink may be attached to any individual channel.
The only difference between these two sinks, is the messages they permit:
*channel* whitelists the following messages: **PRIVMSG**,**JOIN**,**PART**,**KICK**,**MODE**,**TOPIC**
*global* blacklists these, to prevent repetition.

To add the global sink, add the following line to your channel configuration:
```lua
	global.sinks.print	= Modules.print.global
```

To add the channel sink, add it to your channels' sinks list:
```lua
	my_channel.sinks.print	= Modules.print.channel
```
