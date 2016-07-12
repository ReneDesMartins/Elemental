---------------------------------------------------------------------------------------------------------------------------------------
-- Mathematical Evaluation Command
---------------------------------------------------------------------------------------------------------------------------------------
-- Takes a mathematical problem, and attempts to solve it.
--
-- License: GNU GPL 3.0 - see /LICENSE
---------------------------------------------------------------------------------------------------------------------------------------
local MODPATH = MODPATH
local Math = {}
local extmath = dofile( MODPATH.."/extmath.lua" )

---------------------------------------------------------------------------------------------------------------------------------------
-- Calculate Function
---------------------------------------------------------------------------------------------------------------------------------------
-- This function's job is to take a mathematical problem, and solve it. This is done by slightly modifing the string, and then running
-- it as raw lua code, prepended by a 'return' statement.
--
-- Several keywords, such as 'function', 'do', 'while', etc. have been removed, to prevent abuse like:
--	[return] ( function () while true do end end ) ()
--
-- Furthermore, some extra functionality is added, such as the '**' operator as another way of denoting ^^, etc.
---------------------------------------------------------------------------------------------------------------------------------------
local function calculate (self, chan_ptr, flags, parsed, rest)
	local str 	= rest:gsub                         (
			"%*%*","^"                                ):gsub( -- Makes '**' valid as power operator.
			"[\"']",""                                ):gsub( -- Remove quotes to prevent strings.
			"function",""                             ):gsub( -- Remove the 'function' keyword.
			"do",""                                   ):gsub( -- Remove the 'do' keyword.
			"while",""                                ):gsub( -- Remove the 'while' keyword.
			"for",""                                  ):gsub( -- Remove the 'for' keyword.
			"([a-zA-Z]+)%s([^%(%)%s]+)","%1( %2 )"    ):gsub( -- Allow for function calls without parentheses.
			"([0-9%)]+)%s*!","fact( %1 )"             ):gsub( -- Add support for the '!' operator as factorial.
			"%-%-.+$",""										):gsub( -- Remove comments.
			"huge",""                                 )       -- Remove infinities.

	local err,result = pcall(loadstring("setfenv(1,extmath) ; return "..str)) -- Run the equation in a sandboxed environment.

	if (not err) or (not result) then
		parsed.reply("Syntax Error.")
	else
		parsed.reply(str.." = "..result)
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Math Command
---------------------------------------------------------------------------------------------------------------------------------------

Math.eval = {"calc",calculate}

---------------------------------------------------------------------------------------------------------------------------------------
return Math