# Print Module
## Module Info
**Identifier**: print
**Author**: Fiesta
**Description**: Channel sink that prints messages on the screen.
**Version**: v1.0

Provides two plugins: *global*, and *channel*.
The *global* plugin may be applied to the *global* channel, while the *channel* plugin may be applied to any individual channel.
The only difference between these two sinks, is the messages they permit:
*channel* whitelists the following messages: **PRIVMSG**,**JOIN**,**PART**,**KICK**,**MODE**,**TOPIC**
*global* blacklists these, to prevent repetition.

To add the global or channel sinks, add the following entry to your respective plugin specifications:
```lua
	global.plugins = "print.global"
	my_channel.plugins = "print.channel"
```
