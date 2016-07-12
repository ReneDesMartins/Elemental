---------------------------------------------------------------------------------------------------------------------------------------
-- Send
---------------------------------------------------------------------------------------------------------------------------------------
-- The 'send' table is a special metatable that handles the sending of messages to the IRC server.
--
-- License: GNU GPL 3.0 - see /LICENSE
---------------------------------------------------------------------------------------------------------------------------------------
-- We declare the Send table, and set it's metatable to itself.
---------------------------------------------------------------------------------------------------------------------------------------
local Send = {}
setmetatable(Send,Send)

---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Send:__call()
-- Parses the message, and sends it to the IRC server, appending a trailing CR-LF.
-- The 'command' must be a string, specifying the command to be sent.
-- All other arguments must be a string. In case of multiple strings, they will be concatenated with a single space as separator.
-- The very last string will be treated as being the 'message', and will be preceded with a colon.
--
-- Parameters:
--	string:	command              The command to be sent to the IRC server (e.g. PRIVMSG, NOTICE, JOIN, etc.)
--	string:	arg[...]             The message to be sent (can be any number of strings)
---------------------------------------------------------------------------------------------------------------------------------------

function Send:__call (command,...)
	local msg = arg[ arg.n ]
	arg[arg.n] = nil

	local sendmsg = ( "%s %s" ):format(
		command,
		table.concat(arg," ")
	)

	if (msg ~= 0) and (msg) then
		sendmsg = ( "%s :%s" ):format(
			sendmsg,
			msg
		)
	end
	
	if #sendmsg > 510 then
		print("WARNING: erroneous message length - over 512 characters!")
	end
	
	self.__parent:rawsend(sendmsg.."\r\n")
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Send:__index()
-- Creates, and returns a wrapper function that invokes Send:__call(), using 'index' as a command, and the rest as the message.
--	This makes: 
--		Send:privmsg("#channel","Message!") 
--	synonymous to:
--		Send("PRIVMSG","#channel","Message!")
---------------------------------------------------------------------------------------------------------------------------------------

function Send:__index (index)
	return function (self,...)
		self(string.upper(index), unpack(arg))
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
return Send