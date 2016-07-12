---------------------------------------------------------------------------------------------------------------------------------------
-- IRC Module Channel Engine
---------------------------------------------------------------------------------------------------------------------------------------
-- Abstracts channels into a single object that can easily be interacted with, and can be used to store behvaiour and data specific
-- to that channel.
--
-- License: GNU GPL 3.0 - see /LICENSE
---------------------------------------------------------------------------------------------------------------------------------------
-- We declare the following variables locally:
-- coroutine		Coroutine library
---------------------------------------------------------------------------------------------------------------------------------------

local coroutine = coroutine
local Channel = {
	names = {},
	mode = "",
	sinks = {}
}
Channel.__index = Channel

---------------------------------------------------------------------------------------------------------------------------------------
-- Channel Names Metamethods
---------------------------------------------------------------------------------------------------------------------------------------
-- Essentially makes the 'names' table in any channel object case-insensitive by storing and retrieving the usernames in lowercase.
---------------------------------------------------------------------------------------------------------------------------------------
-- Metamethod:	names_mt.__index()
-- Turns the index lowercase, and then attempts to retrieve again with this index.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	names_mt.__newindex()
-- Turns the index lowercase, and then sets the new value with this index.
---------------------------------------------------------------------------------------------------------------------------------------

local names_mt = {}

function names_mt:__index ( index )
	return rawget( self , tostring( index ):lower() )
end

function names_mt:__newindex ( index , value )
	rawset( self , tostring( index ):lower() , value )
end

setmetatable( Channel.names , names_mt )

---------------------------------------------------------------------------------------------------------------------------------------
-- Channel Flush
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Channel:flush()
-- First calls the channels' thread, handing the parsed message to it. Then, it iterates over all of the channels' attached sinks,
-- checks their associated (white)lists, and calls them accordingly.
--
-- Parameters:
-- string:  type                 The COMMAND reported by the server.
-- table:   parsed               The full, parsed message.
--
-- Returns:
-- any:     returned             Any values returned by the channels' thread.
---------------------------------------------------------------------------------------------------------------------------------------

function Channel:flush ( type, parsed )
	local returned = ( self:run(parsed) or {} )

	for name,sink in pairs( self.sinks ) do
		if ( 
			-- Expression: see if list exists.
			not sink.list
		) or (
			-- Expression: see if list exists, and type is whitelisted.
			(sink.type == 0) and (sink.list[type])
		) or (
			-- Expression: see if list exists, and type is blacklisted.
			(sink.type == 1) and (not sink.list[type])
		) or (
			-- Expression: see if list exists, and type is user whitelisted.
			(sink.type == 2) and (type:lower() == "privmsg") and (sink.list[parsed.user:lower()])
		) then
			pcall( function () sink.sink(self.__parent, self, parsed) end )
		end

	end

	return returned
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Mode Specifications
---------------------------------------------------------------------------------------------------------------------------------------
-- The contents of this table are compliant with the standard described in RFC2811. 
--
-- The symbol_letter table is used to convert the symbols used in NAME replies to letters useable for MODEs.
--
-- The chmodes_list table is a list of channel modes that may be assigned at any given time.
-- The key is the letter specifying which channel mode. And the value is either 0, or 1.
-- If the value is '0', then it is a mode that affects an individual user. Examples include voiced, opped, etc. Generally, anything
-- that doesn't fall under "modes affecting the entire channel"
-- Otherwise, if the value is '1', then it is a mode that affects how a channel works.
--
-- The umodes_list table is a list of usermodes that can be assigned by the server.
--
-- This entire table should be an immutable, descriptive set of data, and should not be altered while an object is in use.
---------------------------------------------------------------------------------------------------------------------------------------
Channel.modes = {
	symbol_letter = {
		["+"] = "v",
		["@"] = "o",
	},
	chmodes_list = {
		-- Modes pertaining users.
		O=0,o=0,v=0,b=0,
	
		-- Modes pertaining channel workings.
		a=1,i=1,m=1,n=1,
		q=1,p=1,s=1,r=1,
		t=1,k=1,l=1,e=1,
		I=1,
	},
	umodes_list = {
		a=true,i=true,
		w=true,r=true,
		o=true,O=true,
		s=true
	},
}

---------------------------------------------------------------------------------------------------------------------------------------
-- Channel threads.
---------------------------------------------------------------------------------------------------------------------------------------
-- Channel threads are a method of modifying the behaviour of an IRC channel.
--
-- A channel 'thread' is a coroutine associated with the channel, that is run every time an event occurs in it.
-- Threads may be used to further customise the behaviour of a channel. As is usual with coroutines, the state is maintained between
-- iterations.
--
-- A function assigned as a channels' thread must conform to the following conditions:
--	The function must accept 'self' as it's sole, first argument.
--	The function make a call to yield immediately,
--	The function must yield using only the self:yield() method.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Channel:setthread()
-- Takes a single function, turns it into a coroutine, and assigns it to the channels' thread. The thread it run once, supplying the
-- channel object as parameter, so that the thread may access it at any time.
--
-- Parameters:
-- function:thread               The function to be turned into a thread (must adhere to aforementioned standards.)
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Channel:run()
-- Takes all supplied arguments, and passes them to the channels' thread, which is then invoked. Inside the thread, these arguments
-- will appear to be returned from the self:yield() call.
--
-- Parameters:
--	any                           See description.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Channel:yield()
-- Takes all the supplied arguments, yields the thread, and passes them back to the main program. Back in the main program, these
-- arguments will appear as if they were returned from the Channel:run() call.
--
-- Parameters:
-- any                           See description.
---------------------------------------------------------------------------------------------------------------------------------------

function Channel:run ( ... )
	if self.thread then
		return coroutine.resume( self.thread, unpack( arg ) )
	end
end

function Channel:yield ( ... )
	if self.thread then
		return coroutine.yield( self, unpack( arg ) )
	end
end

function Channel:setthread( thread )
	self.thread = coroutine.create( thread )
	self:run( self )
	return self.thread
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Channel Sinks
---------------------------------------------------------------------------------------------------------------------------------------
-- Channel sinks are another method of handling data from the server. Whenever a message such as a PRIVMSG is sent to a channel, the
-- channel object will first run it through it's main thread, before passing it to each sink.
-- A sink's anatomy look as follows:
-- The sink itself is a table, has 2-4 fields registered:
-- The 'name' field, which is the administrative name used to refer to this sink in the future.
-- The 'sink' field, which contains the function that is to be executed.
-- The 'list' variable decides on which commands go through. The 'type' variable dictates how the list acts.
-- '0' means the list is a 'whitelist', containing all commands that should send through, and the rest needs be denied.
-- '1' means the list is a 'blacklist', containing all commands that need to be denied, and the rest should be sent through.
-- '2' means the list is a 'user whitelist'. It only allows PRIVMSG commands from any users appearing in the whitelist.
-- If no 'valid' table is supplied, when every command is sent through.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Channel:hook_sink()
-- Hooks the supplied sink to the channel, and registers the whitelisted commands.
--
-- Parameters:
-- table:    sink                The sink to be hooked to the associated channel.
--
-- Returns:
-- table:    sink                A reference to the sink that has just been hooked.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Channel:unhook_sink()
-- Removes a sink from the channels' list of sinks.
--
-- Parameters:
-- string:   name                The name of the sink that needs be unhooked.
--
-- Returns:
-- table:    sink                A reference to the newly unhooked sink.
---------------------------------------------------------------------------------------------------------------------------------------

function Channel:hook_sink ( sink )
	assert( -- Assertion: both sink.name and sink.sink have been specified.
		sink.name and
		sink.sink,
		"Sink name/function missing."
	) ; assert( -- Assertion: no sink with sink.name already exists.
		not self.sinks[ sink.name ],
		("attempt to add duplicate sink %q"):format( sink.name )
	)
	
	self.sinks[ sink.name ] = sink
	return self.sinks[ sink.name ]
end

function Channel:unhook_sink ( name )
	self.sinks[ name ] = nil
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Channel Creation
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Channel:create()
-- Creates a new channel object, and returns it.
--
-- Parameters:
-- string:  name                 Name of the channel to be joined.
-- function:thread               [Optional] A thread that should be assigned to the channel.
---------------------------------------------------------------------------------------------------------------------------------------

function Channel:create ( name, thread )
	assert( -- Assertion: throw an error if the 'name' parameter is missing.
		name,
		"No valid channel name specified."
	)
	
	assert( -- Assertion: throw an error if 'thread' is specified, and not a function.
		( thread == nil ) or ( type(thread) == "function" ),
		("Inappropriate thread parameter passed for channel %q"):format( name )
	)

	local new_chan = {}
	new_chan.name = name
	new_chan.names = setmetatable({},names_mt)
	new_chan.sinks = setmetatable({},{__mode="v"})
	new_chan.modes = self.modes
	setmetatable( new_chan , self )

	if (thread) then
		new_chan:setthread( thread )
	end

	return new_chan
end

---------------------------------------------------------------------------------------------------------------------------------------

return Channel