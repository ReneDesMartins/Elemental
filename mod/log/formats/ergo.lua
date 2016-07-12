-- Ergo isn't meant for human consumption. Rather, it's focused on being as concise as possible, making it easy to RegEx parse:
-- ^(..)(..)(..)(.)([^!]*)!?([^@]*)@?([^>]*)>?([^<]*)<?([^;]*);?(.+)
-- Format: [SPECIAL CHARACTER] DESCRIPTION
-- First six digits are timestamp: HHMMSS
-- First letter afterwards is the command used.
-- First, 'victim info' follows:
-- [Begin]	USERNAME
-- [!]		REALNAME
-- [@]		HOST
-- [>]		ON
-- [<]		BY
-- [;]		REST

local ergo = {
	date_format = "%H%M%S",
	privmsg = function (parsed)
		if ( parsed.action ) then
			return ("A%s!@><;%s"):format(
				parsed.user,
				parsed.mesg
			)
		else
			return ("M%s!@><;%s"):format(
				parsed.user,
				parsed.mesg
			)
		end
	end,
	nick = function (parsed)
		return ("N%s!@><;%s"):format(
			parsed.user,
			parsed.mesg
		)
	end,
	join = function (parsed)
		return ("J%s!%s@%s>%s<;"):format(
			parsed.user,
			parsed.realname,
			parsed.host,
			parsed.mesg
		)
	end,
	part = function (parsed)
		return ("P%s!%s@%s>%s<;%s"):format(
			parsed.user,
			parsed.realname,
			parsed.host,
			parsed.flags[1],
			parsed.mesg or ""
		)
	end,
	kick = function (parsed)
		return ("K%s!@>%s<%s;%s"):format(
			parsed.flags[2],
			parsed.flags[1],
			parsed.user,
			parsed.mesg or ""
		)
	end,
	quit  = function (parsed)
		return ("Q%s!%s@%s><;%s"):format(
			parsed.user,
			parsed.realname,
			parsed.host,
			parsed.mesg
		)
	end,
	mode = function (parsed)
		local target_list = ""
		for i = 3,#parsed.flags do
			target_list = target_list..","..parsed.flags[i]
		end

		return ("M%s!@>%s%s<%s;"):format(
			parsed.flags[1],
			parsed.flags[2],
			target_list,
			parsed.user
		)
	end,
	topic = function (parsed)
		return ("T!@>%s<%s;%s"):format(
			parsed.flags[1],
			parsed.user,
			parsed.mesg
		)
	end,
}

return ergo