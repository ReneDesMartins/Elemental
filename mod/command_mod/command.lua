--------------------------------------------------------------------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------------------------------------------------------------------
-- License: GNU GPL 3.0 - see /LICENSE
--
-- Commands are a way for users present in a channel to interact with the bot in various way, through the use of commands.
-- Denoting a command in a file, should be as follows:
---------------------------------------------------------------------------------------------------------------------------------------
-- A Command
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		my_command()				[Command]
-- Description of command here.
--
-- Intended Identifiers:
--	ident1
-- 	synonym1 synonym2 synonym3
--
-- Flags:
--	-1		[single]	Description
--	-2		[single]	Description
--	-3		[single]	Description
--	--flag1		[double]	Description
--	--flag2		[double]	Description
--	--flag3		[double]	Description
---------------------------------------------------------------------------------------------------------------------------------------

local MODPATH = MODPATH
local commands = setmetatable({}, {__mode="k"})
local Command = {}
local parseflags = dofile( MODPATH.."/flag.lua" )

---------------------------------------------------------------------------------------------------------------------------------------
-- Command Evaluation
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		eval_command()				[Regular]
--
-- Parameters:
--	table:   chan_ptr             Refers to the channel this message was sent in.
--	table:   parsed               The parsed message.
--
-- Description:
--	Evaluates and executes a command.
---------------------------------------------------------------------------------------------------------------------------------------

local function eval_command ( self, chan_ptr, parsed )
	local prefix,command,rest = parsed.mesg:match("^(.)([^%s]+)%s*(.*)")

	-- Determine if it is a command to begin with:
	if ( chan_ptr.prefixes[ prefix ] ) then

		-- See if the command exists:
		if ( chan_ptr.commands[ command ] ) then

			-- If it does, parse flags:
			local flags = parseflags( rest )
			-- And execute the command:
			chan_ptr.commands[ command ](self, chan_ptr, flags, parsed, rest)
		end
		
	end

end

---------------------------------------------------------------------------------------------------------------------------------------
-- Channel Sinks
---------------------------------------------------------------------------------------------------------------------------------------
-- Sink:	command
-- Name:	command
-- Type:	whitelist
-- List:	PRIVMSG
-- Desc:	Evaluates a command.
---------------------------------------------------------------------------------------------------------------------------------------

Command.eval_command = {
	name = "command",
	sink = eval_command,
	list = {PRIVMSG=true},
	type = 0,
}

---------------------------------------------------------------------------------------------------------------------------------------
-- Adding/Removing Commands
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		Command.add_command()
-- Adds a new command to the list of commands for this channel.
--
-- Parameters:
-- table:   command   {
--		[1]	ident   string				The identifier of the command to be added; OR
--		[1]	ident   table				A list of identifiers the command should be registered under.
--		[2]	command function			The command to be added.
--	}
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		Command.remove_command()
-- Removes the command from the list.
--
-- Parameters:
-- string:		name                 Name of the command to be executed.
---------------------------------------------------------------------------------------------------------------------------------------

function Command.add_command ( chan_ptr , command )
	local ident,command = unpack( command )
	if ( type( ident )  == "table" ) then
		for _,ident in pairs( ident ) do
			commands[chan_ptr].commands[ ident ] = command
		end
	else
		commands[chan_ptr].commands[ ident ] = command
	end
end

function Command.remove_command ( chan_ptr , name )
	chan_ptr.commands[ name ] = nil
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Adding/Removing Prefixes
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		Command.add_prefix()
-- Adds 'prefix' to the list of valid prefixes.
--
-- Parameters:
--	string:   prefix              The prefix to be added.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		Command.remove_prefix()
-- Removes 'prefix' from the list of valid prefixes.
--
-- Parameters:
--	string:   prefix              The prefix to be removed.
---------------------------------------------------------------------------------------------------------------------------------------

function Command.add_prefix ( chan_ptr , prefix )
	chan_ptr.prefixes[ prefix ] = true
end

function Command.remove_prefix ( chan_ptr , prefix )
	chan_ptr.prefixes[ prefix ] = nil
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Utility functions
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		Command.enable()
-- Enables the usage of commands in a channel by:
--		Adding the add_command, remove_command, add_prefix, and remove_prefix methods.
--		Adding a table to store commands and prefixes in.
--
-- Parameters:
--	table:   chan_ptr             Reference to the channel where commands should be enabled.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:		Command.disable()
-- Disables the usage of commands in a channel by undoing the Command.enable()'s actions.
--
-- Parameters:
--	table:   chan_ptr             Reference to the channel where commands should be disabled.
---------------------------------------------------------------------------------------------------------------------------------------

function Command.plugin ( chan_ptr )

	commands[chan_ptr] = {
		prefixes = {},
		commands = setmetatable({},{__mode="v"})
	}

	for _,command in pairs( (chan_ptr.cfg or {}).commands or {}) do
		Command.add_command( chan_ptr , command )
	end
	
	for _,prefix in pairs( (chan_ptr.cfg or {}).prefixes or {} ) do
		Command.add_prefix( chan_ptr , prefix )
	end
	
	chan_ptr:hook_sink( Command.eval_command )
end

function Command.remove ( chan_ptr )
	commands[chan_ptr] = nil
	collectgarbage()
end
---------------------------------------------------------------------------------------------------------------------------------------
return Command
