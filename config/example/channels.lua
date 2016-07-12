---------------------------------------------------------------------------------------------------------------------------------------
-- Example channel configuration.
---------------------------------------------------------------------------------------------------------------------------------------
-- Channel configuration.
---------------------------------------------------------------------------------------------------------------------------------------

local global 			= {}
local private 			= {}
local channels 		= {}

---------------------------------------------------------------------------------------------------------------------------------------
-- Global Channel Configuration
---------------------------------------------------------------------------------------------------------------------------------------

global.sinks			= {}
global.sinks.print	= Modules.print.global

---------------------------------------------------------------------------------------------------------------------------------------
-- Private Channel Configuration
---------------------------------------------------------------------------------------------------------------------------------------

private.install		= {}
private.install.cmd	= Modules.command.enable

private.prefixes		= {
	"!","."
}

private.commands		= {}
private.commands[1]	= Modules.eval.eval
private.commands[2]	= Modules.bhw.syn

private.sinks			= {}

---------------------------------------------------------------------------------------------------------------------------------------
-- Individual Channels
---------------------------------------------------------------------------------------------------------------------------------------
-- Put configuration on individual channels here. Example:
---------------------------------------------------------------------------------------------------------------------------------------
--
-- channels["#sample_channel"] = {}
-- sample = channels["#sample_channel"]
--
-- sample.sinks			= {}
-- sample.sinks[1]		= Modules.print.channel
--
---------------------------------------------------------------------------------------------------------------------------------------

channels["#main"]		= {}
local main				= channels["#main"]

main.install      = {}
main.install.cmd  = Modules.command.enable
main.install.log	= Modules.log.enable

main.log				= {}
main.log.format	= "irssi"
main.log.file		= PATH.."/logs/main"

main.prefixes     = {
   "!","."
}

main.commands     = {}
main.commands[1]  = Modules.eval.eval
main.commands[2]  = Modules.bhw.syn

main.sinks        = {}


return {private=private,global=global,channels=channels}