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
		chan_ptr.log_file:write(
			os.date(chan_ptr.log_format.date_format)..chan_ptr.log_format[ parsed.num:lower() ] ( parsed ).."\n"
		)

		chan_ptr.log_file:flush()
	end,
	list = {PRIVMSG=true,JOIN=true,PART=true,KICK=true,MODE=true,TOPIC=true,QUIT=true,NICK=true},
	type = 0,
}

---------------------------------------------------------------------------------------------------------------------------------------
-- Utility functions
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Logging.enable()
-- Enables the logging of channel occurrences by:
-- 	- Opening a file, and assigning it to the log_file field,
-- 	- Selecting a log format, and assigning a reference to it to the log_format field,
-- 	- Hooking the log_occurrence sink to the channel.
--
-- Parameters:
--	channel:   chan_ptr           Reference to the channel where logging should be enabled.
---------------------------------------------------------------------------------------------------------------------------------------
function Logging.enable ( chan_ptr )
	local log_file = chan_ptr.cfg.log.file
	local log_form = chan_ptr.cfg.log.format
	local log_sink = Logging.log_occurrence

	chan_ptr.log_file = io.open( log_file , "a" )
	chan_ptr.log_format  dofile( MODPATH.."/formats/"..log_form..".lua" )
	chan_ptr:hook_sink( log_sink )
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Logging.disable()
-- Disables the logging of channel occurrences by:
--    - Closing the log_file,
--    - Removing the log format reference,
--    - Unhooking the log_occurrence sink.
--
-- Parameters:
--	channel:   chan_ptr           Reference to the channel where logging should be disabled.
---------------------------------------------------------------------------------------------------------------------------------------

function Logging.disable ( chan_ptr )
	chan_ptr.log_file:close()
	chan_ptr.log_file = nil
	chan_ptr.log_format = nil
	chan_ptr:unhook_sink( "log_occurrence" )
end

---------------------------------------------------------------------------------------------------------------------------------------
return Logging