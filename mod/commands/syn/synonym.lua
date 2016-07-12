---------------------------------------------------------------------------------------------------------------------------------------
-- Bighugewords Lookup
---------------------------------------------------------------------------------------------------------------------------------------
-- License: GNU GPL 3.0 - see /LICENSE
---------------------------------------------------------------------------------------------------------------------------------------
local MODPATH = MODPATH
local MODINFO = MODINFO

local Syn = {}
local http = require("socket.http")
local json = require("json")

local verbal	= {
		syn = "synonyms",
		ant = "antonyms",
		rel = "related",
		sim = "similar",
}

local function syn (self, chan_ptr, flags, parsed, rest, typ)
	if (MODINFO.api_key == "") or (not MODINFO.api_key) then
		parsed.reply("Missing API Key.")
		return
	end
	
	local wordtype
	local looktype = (typ or "syn")
	local amount_per = 5
	local decoded
	local out = ""
	local word = flags[1]
		
	if (not word) or (type(word) == "number") then
		parsed.reply("Please specify a word to look up!")
		return
	end

	local def,err = http.request("http://words.bighugelabs.com/api/2/"..MODINFO.api_key.."/"..word.."/json")

	if flags.verb then
		wordtype = "verb"
	elseif flags.noun then
		wordtype = "noun"
	elseif flags.adverb then
		wordtype = "adverb"
	elseif flags.adjective then
		wordtype = "adjective"
	else
		wordtype = "anything"
	end

	if flags.n then
		if (not flags.n[1]) or (type(flags.n[1]) ~= "number") then
			parsed.reply("Please specify a number for flag 'n'")
			return
		elseif (flags.n[1] > 10) then
			parsed.reply("A maximum of 10 words may be requested at a time.")
			return
		else
			amount_per = flags.n[1]
		end
	end

	if (err~=200) then
		parsed.reply("Didn't find anything.")
		return
	else
		decoded = json.decode(def)
		if (wordtype == "anything") then
			decoded = {anything=table.merge( (decoded.noun or {}) , (decoded.verb or {}) , (decoded.adverb or {}) , (decoded.adjective or {}) )}
		end
	end

	if (not decoded[wordtype]) or not (decoded[wordtype] or {})[looktype] then
		parsed.reply("No "..verbal[looktype].." found for "..wordtype.."s.") 
		return
	end

	local words = {}
	for i = 1,amount_per do
		words[i] = decoded[wordtype][looktype][i]
	end
	out = out..wordtype..": "..verbal[looktype]..": "..table.concat(words,", ").."; "
	
	parsed.reply(out)
end
local function ant (self, chan_ptr, flags, parsed, rest)
	syn(self, chan_ptr, flags, parsed, rest, "ant")
end
	
local function sim (self, chan_ptr, flags, parsed, rest)
	syn(self, chan_ptr, flags, parsed, rest, "sim")
end

local function rel (self, chan_ptr, flags, parsed, rest)
	syn(self, chan_ptr, flags, parsed, rest, "rel")
end

local function genplot (self, chan_ptr, flags, parsed, rest)
	parsed.reply( ( http.request( "https://words.bighugelabs.com/plot.php" ) ):match("<ul class=\"loglines\"><li>(.-)</li>" ) )
end
	
return {
	syn = {{"syn","synonym","thesaurus","thes"},syn},
	ant = {{"ant","antonym"},ant},
	sim = {{"sim","similar"},sim},
	rel = {{"rel","related"},rel},
	plotgen = {{"genplot","plotgen"},genplot},
}