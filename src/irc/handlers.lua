---------------------------------------------------------------------------------------------------------------------------------------
-- List of IRC protocol handlers.
---------------------------------------------------------------------------------------------------------------------------------------
-- License: GNU GPL 3.0 - see /LICENSE
--
-- These are the default, necessary IRC protocol handlers. They are called by the main object, and these shall do the necessary
-- bookkeeping to keep the protocol working. The format shall be slightly different for this file: individual functions shall not be
-- described separately, simply because:
--	Every function accepts the same arguments,
--	No function returns any values.
--
-- We shall elaborate on the two recurring arguments here:
--	self is a reference to the IRC object that called the handler.
--	parsed is a table containing all the separate parts of a parsed message (see: src/irc/parse.lua)
--
-- All of these functions have been designed, keeping in mind, that no presumptions should ever be made. For example, when sending a
-- call to JOIN a channel, the local channel variable will not be altered as soon as we send the message. We may get an error code,
-- and not join the channel at all, resulting in faulty bookkeeping. Hence why, things such as registers are only updated when the
-- server sends a clear message of what has occurred.
---------------------------------------------------------------------------------------------------------------------------------------

local Handlers = {}
setmetatable(Handlers,Handlers)

---------------------------------------------------------------------------------------------------------------------------------------
-- Handlers Metamethods
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Handlers:__index()
-- Returns an empty function whenever a non-existent handler is called.
--
-- Parameters:
-- string:	index					The index that is being accessed.
---------------------------------------------------------------------------------------------------------------------------------------

function Handlers:__index ( index )
	return function () end
end

---------------------------------------------------------------------------------------------------------------------------------------
-- RPL_WELCOME - sent whenever the user has sucessfully connected to IRC.
---------------------------------------------------------------------------------------------------------------------------------------
-- The RPL_WELCOME message supplies the client's nickname, user, and hostname with it. We store this locally.
---------------------------------------------------------------------------------------------------------------------------------------

Handlers["001"] = function (self,parsed)
	local nick,user,host = parsed.mesg:match("^.+ ([^!]+)!([^@]+)@(.+)$")
	self.info.my_nick = nick
	self.info.my_user = user
	self.info.my_host = host
end

---------------------------------------------------------------------------------------------------------------------------------------
-- RPL_YOURHOST - sent whenever the user has successfully connected to IRC.
---------------------------------------------------------------------------------------------------------------------------------------
-- Contains the host of the server the bot has connected to.
---------------------------------------------------------------------------------------------------------------------------------------

Handlers["002"] = function (self,parsed)
	self.info.server = parsed.mesg:match("Your host is (.+), running version .+")
end

---------------------------------------------------------------------------------------------------------------------------------------
-- PRIVMSG - indicates a message has been sent to a private, or public channel.
---------------------------------------------------------------------------------------------------------------------------------------

Handlers["PRIVMSG"] = function (self,parsed)
	if (not parsed.public) then
		self.private:flush ("PRIVMSG",parsed)
	elseif (parsed.chan_ptr) then
		parsed.chan_ptr:flush ("PRIVMSG",parsed)
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
-- NICK - indicates that either the client, or another person has altered their nickname.
---------------------------------------------------------------------------------------------------------------------------------------
-- When another person calls to NICK, the message is broadcasted to everyone who shares their presence in a channel. The broadcasted
-- message does not specify which of the channels this person resides in. This means, that the client must iterate over every
-- channels' register of users, and change it accordingly.
---------------------------------------------------------------------------------------------------------------------------------------

Handlers["NICK"] = function (self,parsed)
	if (parsed.old_nick:lower() == parsed.own.info.my_nick:lower()) then
		parsed.own.info.my_nick = parsed.new_nick

	else

		for _,chan_ptr in pairs(self.channels) do
			if chan_ptr.names[parsed.old_nick] then
				chan_ptr.names[parsed.new_nick] = chan_ptr.names[parsed.old_nick]
				chan_ptr.names[parsed.new_nick][1] = parsed.new_nick
				chan_ptr.names[parsed.old_nick] = nil
				chan_ptr:flush ("NICK",parsed)
			end	--if (channel...
		end	-- for _,chan_ptr...
	end	-- if (user...
end

---------------------------------------------------------------------------------------------------------------------------------------
-- RPL_NAMREPLY - commonly sent when joining a channel (or when doing a NAMES request).
---------------------------------------------------------------------------------------------------------------------------------------
-- RPL_NAMREPLY contains a list of all 
-- There is one limitation to this - however - and that is that a user with two or more modes assigned to it (e.g +vo) only has the 
-- prefix of the highest mode supplied with the names message (e.g +o only supplying the '@' icon)
-- To circumvent this, every call to handler MODE ends with a NAMES request to the server.
---------------------------------------------------------------------------------------------------------------------------------------

Handlers["353"] = function (self,parsed)
	for name in parsed.mesg:gmatch("[^%s]+") do
		local rank, user = name:match( "^([@+]?)(.+)" )
		parsed.chan_ptr.names[ user ] = { user , (self.channel.modes.symbol_letter[rank] or "") }
	end

	self.send:mode( parsed.chan )
end

---------------------------------------------------------------------------------------------------------------------------------------
-- JOIN - sent when either another user, or the client joins a channel successfully.
---------------------------------------------------------------------------------------------------------------------------------------
-- JOIN is sent by the client when they attempt to gain access to a channel. It is also sent back to the client by the server as
-- confirmation of a successful JOIN. Once a channel has been joined, we shall set the 'joined' variable to true.
-- If another person joins the channel, we add an entry for them in the names register.
---------------------------------------------------------------------------------------------------------------------------------------

Handlers["JOIN"] = function (self,parsed)
	if ( parsed.user:lower() == self.info.my_nick:lower() ) then
		self.channels[ parsed.chan ].joined = true

	else

		self.channels[ parsed.chan ].names[ parsed.user ] = {parsed.user,""}
		self.channels[ parsed.chan ]:flush ("JOIN",parsed)
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
-- PART - sent when either another user, or the client leaves a channel successfully.
---------------------------------------------------------------------------------------------------------------------------------------
-- Functionally identical to JOIN, except that we do the exact opposite: set the 'joined' variable to false if the client leaves, and
-- remove another users' entry in the names register when they leave.
---------------------------------------------------------------------------------------------------------------------------------------

Handlers["PART"] = function (self,parsed)
	if (parsed.user:lower() == self.info.my_nick:lower() ) then
		parsed.chan_ptr.joined = false
	else
		parsed.chan_ptr.names[parsed.user] = nil
		parsed.chan_ptr:flush ("PART",parsed)
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
-- KICK - sent when either another user, or the client has been forcefully evicted from a channel.
---------------------------------------------------------------------------------------------------------------------------------------
-- Functionally identical to PART, apart from the different arrangement of flags.
---------------------------------------------------------------------------------------------------------------------------------------

Handlers["KICK"] = function (self,parsed)
	if (parsed.victim:lower() == self.info.my_nick:lower()) then
		parsed.chan_ptr.joined = false
	else

		parsed.chan_ptr.names[ parsed.victim ] = nil
		parsed.chan_ptr:flush ("KICK",parsed)
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
-- QUIT - sent whenever another user disconnects from the network.
---------------------------------------------------------------------------------------------------------------------------------------
-- Just like NICK, we shall need to iterate over all our channels, and remove the user from the register.
---------------------------------------------------------------------------------------------------------------------------------------

Handlers["QUIT"] = function (self,parsed)
	for _,chan_ptr in pairs( self.channels ) do

		if chan_ptr.names[ parsed.user ] then
			chan_ptr.names[ parsed.user ] = nil
			chan_ptr:flush ("QUIT",parsed)
		end

	end
end

---------------------------------------------------------------------------------------------------------------------------------------
-- MODE - sent whenever another user, channel, or client's mode gets modified.
---------------------------------------------------------------------------------------------------------------------------------------
-- This is magic. Just... don't touch it.
---------------------------------------------------------------------------------------------------------------------------------------

Handlers["MODE"] = function (self,parsed)
	local location = parsed.flags[1]:lower() or ""
	local umode_amount = 0
	local target, tab, key

	--Deduce if the set mode is a chanmode.
	if location:match( "^[&#%+!]" ) then

		for ttype, set in parsed.flags[2]:gmatch("([%+%-])([^%s%+%-]+)") do

			for mode in set:gmatch(".") do
				if (self.channel.modes.chmodes_list[mode] == 0) then
					umode_amount = umode_amount+1
					tab = self.channels[location].names[ parsed.flags[umode_amount+2]:lower() ]
					key = 2

					if ( type(key) == "string" ) and key:find("[^!]+![^@]+@.+") then
						key = key:match("([^!]+)![^@]@.+")
					end

				elseif (self.channel.modes.chmodes_list[mode] == 1) then
					tab = self.channels[location]
					key = "mode"
				end -- if (self.channel...

				if ( tab[key] ) then
					if (ttype == "+") then
						tab[key] = tab[key]..mode
					elseif (ttype == "-") then
						tab[key] = tab[key]:gsub(mode,"")
					end --if (type...)
				end -- if tab[key]...
			end -- for mode in...
		end
		
		self.channels[location]:flush ("MODE",parsed)

	else
		if (location:lower() == self.info.my_nick:lower() ) then
			self.info.my_mode = parsed.mesg:match("[%+%-](.+)")
		end -- if (location...
	end
	
	-- Inquire about NAMES (see handler 353 for info)
	self.send:names(location)
end

-- The current CHANNELMODE, assign it:
Handlers["324"] = function (self,parsed)
	for mode in parsed.flags[3]:gmatch("[a-zA-Z9-0]") do
		if (not parsed.chan_ptr.mode:find(mode)) then
			parsed.chan_ptr.mode = parsed.chan_ptr["mode"]..mode
		end
	end

end

-- The topic is being changed, update it.
Handlers["TOPIC"] = function (self,parsed)
	parsed.chan_ptr.topic = parsed.topic
	parsed.chan_ptr:flush ("TOPIC",parsed)
end

-- RPL_TOPIC - different from TOPIC, because it is supplied when joining.
Handlers["332"] = function (self,parsed)
	parsed.chan_ptr.topic = parsed.topic
end

-- RPL_NOTOPIC - there's no topic, so empty the topic var.
Handlers["331"] = function (self,parsed)
	parsed.chan_ptr.topic = ""
end

---------------------------------------------------------------------------------------------------------------------------------------

return Handlers