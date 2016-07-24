---------------------------------------------------------------------------------------------------------------------------------------
-- Channel configuration.
---------------------------------------------------------------------------------------------------------------------------------------

local global 			= {}
local private 			= {}
local channels 		= {}

---------------------------------------------------------------------------------------------------------------------------------------
-- Global Channel Configuration
---------------------------------------------------------------------------------------------------------------------------------------

global.plugins = ""

---------------------------------------------------------------------------------------------------------------------------------------
-- Private Channel Configuration
---------------------------------------------------------------------------------------------------------------------------------------

private.plugins = ""

---------------------------------------------------------------------------------------------------------------------------------------
-- Individual Channels
---------------------------------------------------------------------------------------------------------------------------------------
-- Put configuration on individual channels here. Example:
---------------------------------------------------------------------------------------------------------------------------------------
--
-- channels["#sample_channel"] = {}
-- sample = channels["#sample_channel"]
--
-- sample.plugins			= "print.channel"
---------------------------------------------------------------------------------------------------------------------------------------

return {private=private,global=global,channels=channels}