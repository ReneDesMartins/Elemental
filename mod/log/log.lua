---------------------------------------------------------------------------------------------------------------------------------------
-- Logging
---------------------------------------------------------------------------------------------------------------------------------------
-- Facilities used for logging channel occurrences.
-- Logging must be turned on for each channel individually with the 'enable_logging' method.
--
-- License: GNU GPL 3.0 - see /LICENSE
---------------------------------------------------------------------------------------------------------------------------------------
local MODPATH = MODPATH
local Logging = {}
local logs = setmetatable({},{__mode="k"})

---------------------------------------------------------------------------------------------------------------------------------------
-- Channel sinks
---------------------------------------------------------------------------------------------------------------------------------------
-- Sink:	log_occurrence
-- Name:	log_occurrence
-- Type:	whitelist
-- List:	PRIVMSG, JOIN, PART, KICK, MODE, TOPIC, QUIT, NICK
-- Desc:	Writes an occurrence to the proper log file.
---------------------------------------------------------------------------------------------------------------------------------------
Logging.log_occurrence = {
	name = "log_occurrence",
	sink = function (self,chan_ptr,parsed)
		logs[chan_ptr].log_file:write(
			os.date(logs[chan_ptr].log_format.date_format)..logs[chan_ptr].log_format[ parsed.num:lower() ] ( parsed ).."\n"
		)
	end,
	list = {PRIVMSG=true,JOIN=true,PART=true,KICK=true,MODE=true,TOPIC=true,QUIT=true,NICK=true},
	type = 0,
}

---------------------------------------------------------------------------------------------------------------------------------------
-- Flush timer
---------------------------------------------------------------------------------------------------------------------------------------
-- Timer: flush
-- Name : flush
-- Inter: equal to MODINFO.flush_interval
-- Desc : flushes the message buffer to file.
---------------------------------------------------------------------------------------------------------------------------------------
Logging.flushtime = {
	time = MODINFO.flush_interval,
	name = "flush",
	single = false,
	func = function ()
		for _,v in pairs( logs ) do
			v.log_file:flush()
		end
	end,
}

---------------------------------------------------------------------------------------------------------------------------------------
-- Utility functions
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Logging.plugin()
-- Enables the logging of channel occurrences by:
-- 	- Opening a file, and assigning it to the log_file field,
-- 	- Selecting a log format, and assigning a reference to it to the log_format field,
-- 	- Hooking the log_occurrence sink to the channel.
--
-- Parameters:
--	channel:   chan_ptr           Reference to the channel where logging should be enabled.
---------------------------------------------------------------------------------------------------------------------------------------
function Logging.plugin ( chan_ptr )
	if ( not next( logs ) ) then
		chan_ptr.__parent.timer:add_timer( Logging.flushtime.name , Logging.flushtime.time , Logging.flushtime.func , Logging.flushtime.single )
	end

	logs[chan_ptr] = {}
	local log_file = chan_ptr.cfg.log_file
	local log_form = chan_ptr.cfg.log_format
	local log_sink = Logging.log_occurrence

	logs[chan_ptr].log_file = io.open( log_file , "a" )
	logs[chan_ptr].log_format = dofile( MODPATH.."/formats/"..log_form..".lua" )
	chan_ptr:hook_sink( log_sink )
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Logging.plugout()
-- Disables the logging of channel occurrences by:
--    - Closing the log_file,
--    - Removing the log format reference,
--    - Unhooking the log_occurrence sink.
--
-- Parameters:
--	channel:   chan_ptr           Reference to the channel where logging should be disabled.
---------------------------------------------------------------------------------------------------------------------------------------

function Logging.plugout ( chan_ptr )
	logs[chan_ptr].log_file:close()
	logs[chan_ptr] = nil

	chan_ptr:unhook_sink( "log_occurrence" )
	
	if ( not next( logs ) ) then
		chan_ptr.__parent.timer:remove_timer( Logging.flushtime.name )
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
return Logging
