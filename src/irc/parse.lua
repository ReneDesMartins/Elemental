---------------------------------------------------------------------------------------------------------------------------------------
-- Message parsing library
---------------------------------------------------------------------------------------------------------------------------------------
-- A library used for parsing IRC messages.
-- Messages are handed to the 'parse' function, which creates a table which contains every separate part of the message.
-- To allow proper handling of each type of message, all messages are parsed separately, in different ways.
--
-- Strings parsed to the parse() function are first separated into it's primary components - fields such as user (person who sent
-- the message), num (command/numerical response), mesg (message), etc. For more info, see the parse() function.
--
-- Dependent on the command/numerical response, the message might need further parsing (adding fields such as 'channel', 'victim',
-- etc.) For this, the 'Packers' table contains a list of functions, each specialised for a different handler.
--
-- License: GNU GPL 3.0 - see /LICENSE
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	spawn_reply()
-- Returns a wrapper function that, when called, sends a PRIVMSG to the respective channel. The purpose of such a system is that
-- anything can simply submit a reply, without having to manually call the 'send' function.
--
-- The spawn_reply method memoizes it's newly created functions into a weak table. This is so that, when large amounts of
-- messages are sent in quick succession, the same, identical reply function needn't be created repeatedly.
--
-- The memoize table itself stores the functions using channel names as key, and the reply functions as values. Since the table
-- is weak, the reply functions will be deleted by the garbage collector when not used for a while, clearing up room.
--
-- Parameters:
-- table:   net                  IRC object that the reply function should respond to.
-- string:  chan                 Name of the channel that the wrapper should reply to.
--
-- Returns:
-- function:reply                The reply wrapper itself.
---------------------------------------------------------------------------------------------------------------------------------------

local memoize = setmetatable( {}, {__mode="v"} )


local function spawn_reply (net,chan)
	return (memoize[chan]) or (
		rawset( memoize, chan, 
			function (mesg,...)
				net.send:privmsg(chan, (mesg):format( unpack(arg) ) )
			end
		)[chan]
	)
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Packers
---------------------------------------------------------------------------------------------------------------------------------------
-- The 'Packers' table contains a list of functions, each specialised in packing the message in accordance with the command used.
-- If a Packer does not exist, then __index will kick in, and return a function, which returns all supplied arguments.
--
-- It should be noted that due to how common the creation of a reply-function, and the assignment of a channel pointer is, that the
-- parse() function does these two steps, using the channel name stored in parsed.chan. If parsed.chan is not assigned/valid, then
-- no reply wrapper/channel pointer is assigned.
--
-- The format for Packing methods is:
---------------------------------------------------------------------------------------------------------------------------------------
-- Packer:	Command
--
-- Fields:
--	field1		type		description
--	field2		type		description
--
-- Notes:
--	Additional notes go here.
---------------------------------------------------------------------------------------------------------------------------------------

local Packers = setmetatable({},
	{__index = function ()
		-- Return the parsed message, untouched.
		return (function (self,parsed)  return parsed end)
	end}
)

---------------------------------------------------------------------------------------------------------------------------------------
-- Packer:	PRIVMSG
--
-- Fields:
--	chan       string          Channel to which the private message was sent.
--	public     bool            Whether the message was sent to a public channel, or in private.
--	reply      function        Reply function (see: spawn_reply())
--	action     bool            Whether the message was an 'action' (commonly referred to as a '/me')
--
-- Notes:
--	The 'chan' field is changed to the nickname of the sender, if the message was received in private.
--	If action is true, then the ASCII \001 and 'ACTION' will be stripped from the message.
---------------------------------------------------------------------------------------------------------------------------------------

function Packers.PRIVMSG (self,parsed)
	-- Assign 'flags[1]' as 'chan'.
	parsed.chan = parsed.flags[1]

	-- Determine whether the message was sent publically, or privately.
	if (parsed.chan:lower() == self.info.my_nick:lower()) then
		parsed.chan = parsed.user
		parsed.public = false
	else
		parsed.public = true
	end

	-- Determine whether the message was an action or not.
	if parsed.mesg:match("^\001ACTION .+\001") then
		parsed.action = true
		parsed.mesg = ( parsed.mesg:gsub("\001ACTION","") ):gsub("\001","")
	else
		parsed.action = false
	end

	return parsed
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Packer:	NICK
--
-- Fields:
--	new_nick    string            The new nickname.
--	old_nick    string            The users' previous nickname.
---------------------------------------------------------------------------------------------------------------------------------------

function Packers.NICK (self,parsed)
	parsed.old_nick = parsed.user:lower()
	parsed.new_nick = parsed.mesg:lower()
	return parsed
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Packer:	353
--
-- Fields:
--	chan        string            Name of the channel.
---------------------------------------------------------------------------------------------------------------------------------------

Packers["353"] = function (self,parsed)
	parsed.chan = parsed.flags[3]
	return parsed
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Packer:	JOIN
--
-- Fields:
--	chan        string            Name of the channel.
---------------------------------------------------------------------------------------------------------------------------------------

function Packers.JOIN (self,parsed)
	parsed.chan = parsed.mesg
	return parsed
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Packer:	PART
--
-- Fields:
--	chan        string            Name of the channel.
---------------------------------------------------------------------------------------------------------------------------------------

function Packers.PART (self,parsed)
	parsed.chan = parsed.flags[1]
	return parsed
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Packer:	KICK
--
-- Fields:
--	chan        string            Name of the channel.
--	victim      string            Name of the kicked user.
---------------------------------------------------------------------------------------------------------------------------------------

function Packers.KICK (self,parsed)
	parsed.chan = parsed.flags[1]
	parsed.victim = parsed.flags[2]
	return parsed
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Packer:	324
--
-- Fields:
--	chan			string				Name of the channel.
---------------------------------------------------------------------------------------------------------------------------------------	

Packers["324"] = function (self,parsed)
	parsed.chan = parsed.flags[2]
	return parsed
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Packer:	TOPIC
--
-- Fields:
--	chan        string            Name of the channel.
--	topic       string            The newly set topic.
---------------------------------------------------------------------------------------------------------------------------------------

function Packers.TOPIC (self,parsed)
	parsed.topic = parsed.mesg
	parsed.chan = parsed.flags[1]
	return parsed
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Packers:	332, 331
--
-- Fields:
--	chan       string             Name of the channel.
--	topic      string             The newly set topic.
---------------------------------------------------------------------------------------------------------------------------------------

Packers["332"] = function (self,parsed)
	parsed.topic	  = parsed.mesg
	parsed.chan		= parsed.flags[2]
	return parsed
end

Packers["331"] = Packers["332"]

---------------------------------------------------------------------------------------------------------------------------------------
-- MODE is absent since... ech.
---------------------------------------------------------------------------------------------------------------------------------------

-- Any fields which were not found/not properly parsed, shall return an empty string.
local parse_mt = {__index=function () return "" end}

local function parse (self,message)
	local parsed = setmetatable(
		{
		flags = {},
		str = message,
		own = self,
	}, parse_mt )
	local flags

	-- Parse the message. This RegEx seems to work for anything except a call to PING (due to the absence of a host)
	parsed.user,parsed.realname,parsed.host,parsed.num,flags,parsed.mesg = message:match("^:([^%s!]+)!?([^%s@]*)@?([^%s]*) ([A-Z0-9a-z]+) ?([^:]*) ?:?(.*)$")

	-- The "flags" signify anything between NUM and MESG.
	for flag in (flags or ""):gmatch("[^%s]+") do
		parsed.flags[#parsed.flags+1] = flag
	end
	
	parsed = Packers[ parsed.num ] ( self, parsed )
	parsed.chan_ptr = self.channels[ parsed.chan ]
	parsed.reply = spawn_reply( self, parsed.chan )
	
	return parsed
end

return parse