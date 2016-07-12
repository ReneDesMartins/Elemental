---------------------------------------------------------------------------------------------------------------------------------------
-- Print
---------------------------------------------------------------------------------------------------------------------------------------
-- A small collection of sinks used for printing messages to stdout.
--
-- License: GNU GPL 3.0 - see /LICENSE
---------------------------------------------------------------------------------------------------------------------------------------
-- Channel sinks
---------------------------------------------------------------------------------------------------------------------------------------
-- Sink:	global
-- Name:	print
-- Type:	blacklist
-- List:	PRIVMSG, JOIN, PART, KICK, MODE, TOPIC
-- Desc:	Prints the message as a global message,
---------------------------------------------------------------------------------------------------------------------------------------
-- Channel sinks
---------------------------------------------------------------------------------------------------------------------------------------
-- Sink:	channel
-- Name:	print
-- Type:	whitelist
-- List:	PRIVMSG, JOIN, PART, KICK, MODE, TOPIC
-- Desc:	Prints the message as a channel message,
---------------------------------------------------------------------------------------------------------------------------------------
local global = {
	name = "print",
	sink = function (self,chan_ptr,parsed)
		print("[<][Global] "..parsed.str)
	end,
	list = {PRIVMSG=true,JOIN=true,PART=true,KICK=true,MODE=true,TOPIC=true},
	type = 1,
}

local channel = {
	name = "print",
	sink = function (self,chan_ptr,parsed)
		print("[<]["..chan_ptr.name.."] "..parsed.str)
	end,
	list = {PRIVMSG=true,JOIN=true,PART=true,KICK=true,MODE=true,TOPIC=true},
	type = 0,
}

---------------------------------------------------------------------------------------------------------------------------------------
return {
	channel = channel,
	global = global,
}