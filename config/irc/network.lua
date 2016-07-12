-- General IRC configuration.
return {
	server="127.0.0.1",					-- Server to connect to.
	port=6667,								-- Port to use.
	nick="Elementbot",					-- Nick to use.
	user="Elementbot",					-- Username to use.
	rname="Elementbot",					-- Realname to use.
	mode="0",								-- Mode to use.
	umode="*",								-- Unused
	compat_lib="",							-- Some networks differ from the standards described in RFC2812, so compatibility libraries may be required. Specify one.
	login_wait=10,							-- Sometimes, it's best to wait a couple seconds before joining channels (e.g. to give NickServ some time to parse registers.)

	-- If a server supports NickServ registration (and if the bot is registered,) then Elemental will attempt to identify on login.
	ns_wait=5,								-- Amount of time to wait before identifying with NickServ.
	ns_recipient="nickserv",			-- If the servers' NickServ is registered under another name, then specify that here.
	ns_pass="",								-- The nickserv password. Leave empty not to authenticate.
}