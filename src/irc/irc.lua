---------------------------------------------------------------------------------------------------------------------------------------
-- Pid IRC Library
---------------------------------------------------------------------------------------------------------------------------------------
-- The main IRC library.
-- Components:
--	Channel objects           - channel.lua
--	Protocol handlers         - handle.lua
--	Message parser facilities - parse.lua
--	Message sending wrapper   - send.lua
-- Global timers             - timers.lua
--
-- License: GNU GPL 3.0 - see /LICENSE
---------------------------------------------------------------------------------------------------------------------------------------
-- Initialisation
---------------------------------------------------------------------------------------------------------------------------------------
-- Luasocket by Diego Nehab
-- http://w3.impa.br/~diego/software/luasocket/
---------------------------------------------------------------------------------------------------------------------------------------
require("socket")

---------------------------------------------------------------------------------------------------------------------------------------
-- Table: Pid
-- Fields:
-- socket          Main socket object used for communicating to the server.
-- channels        Table containing all of the loaded channels.
-- info            Table containing multiple variables with information on the connection.
-- 	server          The IRC server that is handling the connection.
-- 	my_mode         The usermode that is assigned to the client connection.
-- 	my_nick         The client's nickname.
-- 	logged_in       Whether the 'login process' has been finished or not.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Pid:__newindex()
--	This metamethod makes it so that any table assigned to self will automatically be given a '__parent' field, containing a
--	reference to it's owner.
---------------------------------------------------------------------------------------------------------------------------------------

Pid = {
	socket = socket.tcp(),
	channels = {},
	info = {
		server = "",
		my_mode = "",
		my_nick = "",
		logged_in = false,
	},
}
setmetatable(Pid,Pid)

function Pid:__newindex (index,value)
	if ( type(value) == "table" ) then
		value.__parent = self
	end

	rawset( self, index, value )
end

Pid.parse = require("/src/irc/parse")
Pid.send = require("/src/irc/send")
Pid.handlers = require("/src/irc/handlers")
Pid.channel = require("/src/irc/channel")
Pid.timer = require("/src/irc/timers")

---------------------------------------------------------------------------------------------------------------------------------------
-- 'Global' Channel
---------------------------------------------------------------------------------------------------------------------------------------
-- The so-called 'global channel', where all messages are sent through.
-- Hook sinks to here if you want them to apply globally.
---------------------------------------------------------------------------------------------------------------------------------------

Pid.global = Pid.channel:create("global")
Pid.global:setthread( function (self)
	self:yield()
	while true do
		self:yield()
	end
end )

---------------------------------------------------------------------------------------------------------------------------------------
-- 'Private' Channel
---------------------------------------------------------------------------------------------------------------------------------------
-- The so-called 'private channel', where all messages sent in private are sent through.
-- Hook sinks to here if you want them to apply to private messages.
---------------------------------------------------------------------------------------------------------------------------------------

Pid.private = Pid.channel:create("private")
Pid.private:setthread( function (self)
	self:yield()
	while true do
		self:yield()
	end
end )

---------------------------------------------------------------------------------------------------------------------------------------
-- Channels Metamethod
---------------------------------------------------------------------------------------------------------------------------------------
-- Essentially makes the 'names' table case-insensitive by storing and retrieving the usernames in lowercase.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	channels_mt.__index()
-- Turns the index lowercase, and attempts to retrieve again. Use rawget to avoid loops.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	channels_mt.__newindex()
-- Turns the index lowercase, and then stores the value. Use rawset to avoid loops.
--------------------------------------------------------------------------------------------------------------------------------------

local channels_mt = {}

function channels_mt:__index ( index )
	return rawget( self , tostring( index ):lower() )
end

function channels_mt:__newindex ( index , value )
	rawset( self , tostring( index ):lower() , value )
end

setmetatable( Pid.channel , channels_mt )

---------------------------------------------------------------------------------------------------------------------------------------
-- Login
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Pid:log_in()
-- Called by the login timer after a certain amount of seconds.
---------------------------------------------------------------------------------------------------------------------------------------

function Pid:log_in ()
	for _,channel in pairs( self.channels ) do
		self.send:join(channel.name)
	end

	self.info.logged_in = true
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Timeouts
---------------------------------------------------------------------------------------------------------------------------------------
-- This function - settimeout is used for setting the socket's timeout period.
-- Do not manually change the socket objects' timeout, since that will mess up the register.
---------------------------------------------------------------------------------------------------------------------------------------

function Pid:settimeout ( timeout )
	self.info.timeout = timeout
	self.socket:settimeout( timeout )
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Server interaction
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Pid:connect()
-- A wrapper function for Pid.socket:connect()
--
-- Parameters:
-- string:  server               address of the server to connect to.
-- number:  port                 the port that should be used to connect (defaults to 6667)
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Pid:receive()
-- A wrapper function for Pid.socket:receive(). Usage of Pid:listen() is advised.
--
-- Returns:
-- string:  message              raw message received by the server.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Pid:rawsend()
-- A wrapper function for self.socket:send(). Usage of Pid:send() is strongly advised.
--
-- Parameters:
-- string:  string               string to be sent to the server (excluding trailing CR-LF)
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Pid:listen()
-- Iterator that continuously listens for messages from the server, and handles and parses them when received.
-- Continually returns parsed messages.
--
-- Returns:
-- table:   parsed               table containing all separate parts of the sent message (returned from 
---------------------------------------------------------------------------------------------------------------------------------------

function Pid:connect(server,port)
	self.socket:connect( server, (port or 6667) )
end

function Pid:receive()
	return self.socket:receive()
end

function Pid:rawsend(string)
	self.socket:send( string )
end

function Pid:listen()

	-- Local variables are quicker to access.
	local match = string.match
	local find = string.find

	-- Return our iterator function.
	return function ()
		repeat
		
			-- Receive a string from the server, and print it once received.
			local rec = self:receive() or ""
			self.timer:evaluate()

			-- If it's a ping, then handle it manually.
			if (rec or ""):find("^PING :.+$") then
				self.send:pong(rec:match("^PING :(.+)$"))
			elseif (rec) and (rec ~= "") then
				-- If not a ping, then parse the message, and send them to the handlers.
				local parsed = self:parse(rec)
				self.handlers[ parsed.num ](self, parsed)
				self.global:flush (parsed.num, parsed)

				-- Return the parsed message to the main loop.
				return parsed
			end

		until (not rec)
		-- Return nil once, signalling the main loop to stop.
		return nil
	end
end
