-- Normally, a fancy header and explanation would go here detailing the workings of this function.
-- Fuck this function though. It's witchcraft produced out of a drunken haze.
-- The cryptic comments on the right are all we'll ever get.
-- To the poor sod that needs to debug this: good luck to you, pal.
-- License: GNU GPL 3.0 - see /LICENSE

local function parseflags ( str )
	local out				= {}										-- Output table - where flags and such shall be stored.
	local current_flag	= out										-- A pointer to the table where all flags are going to be put to.
	local position			= 0										-- The current location in the string.
	local char				= ""										-- The current character.
	local final_flag		= ""										-- The last selected flag.
	local ignore_next		= false									-- Whether the next special character ( -, ", ' ) should be ignored.

	repeat
		position	= position + 1										-- Progress the position in the string.
		char		= str:match( "." , position )					-- Retrieve the character at the current location.
		
		if ( char == "\\" ) then									-- If the character is a backslash, then turn 'ignore mode' on.
			ignore_next = true
		end
																			-- If this 'else' is reached, then ignore mode is off, and hasn't been turned on.
		if ( char == "-" ) and (not ignore_next) then		-- Is it any kind of flag?
																			-- We not start seeing whether the 'char' matches any special characters:

																			-- Determine if it's a doubledash flag, by checking whether the following character is a dash.
			
			if str:sub( position+1 , position+1 ) == "-" then				-- It's a doubledash flag.

				flag_name = str:sub(													-- This call to string:sub() shall retrieve the full name of the flag - from right after the doubledash, to the end.
					position + 2,														-- The 'start position' - where the name of the flag starts.
					( str:find( "%s", position + 2 ) or str:len() ) - 1	-- The 'end position' - where the name of the flag ends.
				)

				out[ flag_name ]	= {}
				current_flag		= out[ flag_name ]							-- Set the 'current' pointer to the newly created table.
				position		= position + flag_name:len()						-- Offset the current position, so that the search resumes from there.


			else																			-- It's a singledash flag.

				local flags = str:sub(												-- This call to string:sub() shall retrieve the full list of flags - from right after the singledash, to the end.
					position + 1,														-- The 'start position' - where the list of flags starts.
					(str:find( "%s", position + 1 ) or str:len() ) -1		-- The 'end position' - where the list of flags ends.
				)

				for flag in flags:gmatch(".") do									-- Iterate over the list of flags.
					out[ flag ]	= {}													-- Add new entries for each flag.
					current_flag	= out[ flag ]
				end

				position		= position + flags:len()							-- Offset the current position, so that the search resumes from there.
			end

		elseif ( ( char == '"' ) or ( char == "'" ) ) and (not ignore_next) then		-- Then... is it a string?
			local string_contents = str:sub(										-- Retrieve the contents of the string.
				position + 1,
				( str:find( "[^\\]"..char, position+1 ) or str:len() )
			):gsub(
				"\\"..char,
				char
			)
				
			current_flag[ #current_flag+1 ] = string_contents
			position		= position + string_contents:len() + 1
		elseif ( char or "" ):find( "%d" ) then							-- Something like a range or number.
			if ( str:find( "%d+%.%.%d+" , position ) ) == position then			-- See if if it's a range.
				local start_position,end_position,lower_bound,upper_bound = str:find(
					"(%d+)%.%.(%d+)",
					position
				)
				current_flag[ #current_flag+1 ] = { tonumber( lower_bound ) , tonumber( upper_bound ) }
				position			= position + ( end_position - start_position )
			else										-- Just a number, then.
				local num_str = str:sub(
					position,
					str:find( "%s" , position )
				)
				current_flag[ #current_flag+1 ] = tonumber( num_str )
				position			= position + num_str:len() - 1
			end

		elseif ( not (char or " "):find("%s") ) then							-- DO DRY PARSING HERE
			local string_contents = str:sub(
			position,
				( str:find( "[^\\][%s'\"]" , position ) or str:len() )
			)

			current_flag[ #current_flag+1 ] = string_contents:gsub(
				"\\%s",
				function (str) return ( str:gsub( "\\" , "" ) ) end
			)

			position		= position + string_contents:len() - 1
		end

		if (ignore_next) then
			ignore_next = false
		end


	until ( not char )

	
	return out
end

return parseflags