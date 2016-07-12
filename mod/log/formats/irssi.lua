local irssi = {
	date_format = "%H:%M ",
	privmsg = function (parsed)
		if ( parsed.action ) then
			return (" * %s%s"):format(
				parsed.user,
				parsed.mesg
			)
		else
			return ("<%s> %s"):format(
				parsed.user,
				parsed.mesg
			)
		end
	end,
	nick = function (parsed)
		return ("-!- %s is now known as %s"):format(
			parsed.user,
			parsed.mesg
		)
	end,
	join = function (parsed)
		return ("-!- %s [%s@%s] has joined %s"):format(
			parsed.user,
			parsed.realname,
			parsed.host,
			parsed.mesg
		)
	end,
	part = function (parsed)
		return ("-!- %s [%s@%s] has left %s [%s]"):format(
			parsed.user,
			parsed.realname,
			parsed.host,
			parsed.flags[1],
			parsed.mesg or ""
		)
	end,
	kick = function (parsed)
		return ("-!- %s was kicked from %s by %s [%s]"):format(
			parsed.flags[2],
			parsed.flags[1],
			parsed.user,
			parsed.mesg or ""
		)
	end,
	quit  = function (parsed)
		return ("-!- %s [%s@%s] has quit [%s]"):format(
			parsed.user,
			parsed.realname,
			parsed.host,
			parsed.mesg
		)
	end,
	mode = function (parsed)
		local target_list = ""
		for i = 3,#parsed.flags do
			target_list = target_list.." "..parsed.flags[i]
		end

		return ("-!- mode/%s [%s%s] by %s"):format(
			parsed.flags[1],
			parsed.flags[2],
			target_list,
			parsed.user
		)
	end,
	topic = function (parsed)
		return ("-!- %s changed the topic of %s to: %s"):format(
			parsed.user,
			parsed.flags[1],
			parsed.mesg
		)
	end,
}

return irssi