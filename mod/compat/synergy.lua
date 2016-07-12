---------------------------------------------------------------------------------------------------------------------------------------
-- Synergy IRC Compatibility Library
---------------------------------------------------------------------------------------------------------------------------------------
-- License: GNU GPL 3.0 - see /LICENSE
-- SynIRC (the primary server this bot runs on) has a different set of umodes/chmodes. This module modifies the behvaiour of Elemental
-- so that it may operate sufficiently on this network.
---------------------------------------------------------------------------------------------------------------------------------------
-- Channel modes
---------------------------------------------------------------------------------------------------------------------------------------
-- We declare a table containing all SynergyIRC-Compatible channel and usermodes.
---------------------------------------------------------------------------------------------------------------------------------------

Pid.channel.modes = {
	symbol_letter = {
		["~"] = "qo",
		["+"] = "v",
		["@"] = "o",
		["%"] = "h",
		["&"] = "a",
	},
	chmodes_list = {
		--'0' means it is a mode affecting user status within a channel - voiced, opped,
		--'1' means it is a mode affecting the channel's mechanics and workings - anonymous, auditorium, etc.

		-- Modes pertaining user privilege.
		q=0,a=0,o=0,
		h=0,v=0,b=0,

		-- Modes pertaining channel status.
		A=1,c=1,C=1,
		e=1,f=1,G=1,
		i=1,I=1,j=1,
		k=1,K=1,L=1,
		l=1,m=1,M=1,
		N=1,n=1,O=1,
		p=1,Q=1,R=1,
		r=1,s=1,S=1,
		T=1,t=1,u=1,
		V=1,z=1,Z=1,
	},
	umodes_list = {
		o=true,O=true,
		a=true,A=true,
		N=true,C=true,
		d=true,g=true,
		h=true,i=true,
		p=true,q=true,
		r=true,s=true,
		t=true,v=true,
		w=true,x=true,
		z=true,B=true,
		G=true,H=true,
		I=true,R=true,
		S=true,T=true,
		V=true,W=true,
	},
}

---------------------------------------------------------------------------------------------------------------------------------------
-- Normally, NAMREPLY only has the @ and + prefixes. But, since SynIRC has admin, hop, and owner ranks, it must also parse &,%, and ~.
---------------------------------------------------------------------------------------------------------------------------------------

Pid.handlers["353"] = function (self,parsed)
	for name in parsed.mesg:gmatch("[^%s]+") do
		local rank,user = name:match("^([@%+&%%~]?)(.+)")
		parsed.chan_ptr.names[ user ] = {user,self.channel.modes.symbol_letter[rank] or ""}
	end

	self.send:mode(parsed.chan)
end

---------------------------------------------------------------------------------------------------------------------------------------
