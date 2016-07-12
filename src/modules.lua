---------------------------------------------------------------------------------------------------------------------------------------
-- Module loading library.
---------------------------------------------------------------------------------------------------------------------------------------
-- Loads objects such as data and functions from external files (modules), and indexes these (sorted by type) in a globally accessible
-- register.
--
-- License: GNU GPL 3.0 - see /LICENSE
---------------------------------------------------------------------------------------------------------------------------------------
-- Modules is a register for all loaded modules.
-- The register contains two sub-registers:
-- 'by_type', where data is sorted by type (e.g. command, handler, etc.)
-- 'by_module', where data is sorted by which module they belong to.
---------------------------------------------------------------------------------------------------------------------------------------

Modules = {}
Modules_info = {}
Module = {}

---------------------------------------------------------------------------------------------------------------------------------------
-- Add/Remove modules
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Module:add()
-- Registers an external module by adding it to the Modules and Modules_info table.
--
-- Parameters:
--	string:  owner                Name of the module being added.
--	table:   contents             Table, whose key-value pairs consists out of a string, indicating the object's type, and an array containing these objects.
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Module:remove()
-- Removes modules associated with 'owner'
--
-- Parameters:
--	string:  owner                Name of the module being removed.
---------------------------------------------------------------------------------------------------------------------------------------

function Module:add ( info , objects )
	assert( -- Assertion: both parameters, 'info' and 'objects' are present.
		info and objects,
		("Missing info/objects table in loading module.")
	)

	Modules_info[ info.name ] = info
	Modules[ info.name ] = objects
end

function Module:remove ( owner )
	assert( -- Assertion: the module being removed exists.
		Modules_info[ owner ],
		("No such module loaded: %q"):format( owner )
	)

	Modules_info[ owner ] = nil
	Modules[ owner ] = nil
	collectgarbage()
end

---------------------------------------------------------------------------------------------------------------------------------------
-- Load modules
---------------------------------------------------------------------------------------------------------------------------------------
-- Method:	Module:load()
-- Receives a mod_info table returned from the module.lua file in path/mod/mod_name/, and executes the file specified in the mod_info
-- tables' 'file' field. Calls Module:add() afterwards.
--
-- Parameters:
-- string:  mod_name             Name of the desired modules' folder in the mod/ directory.
-- string:  path                 [Optional] (Alternative) path to the 'mod' directory.
---------------------------------------------------------------------------------------------------------------------------------------

function Module:load ( mod_name , path )
	path = path or _G.PATH.."mod/"

	MODPATH=path..mod_name.."/"
	local mod_info = dofile( MODPATH.."/module.lua" )
	assert( -- Assertion: all necessary fields for module_info exist.
		mod_info.name         and
		mod_info.description  and
		mod_info.version      and
		mod_info.owner        and
		mod_info.file,
		"One or more missing fields in module info."
	)
	
	assert( -- Assertion: the module's name does not containg anything other than lowercase characters, or an underscore.
		not mod_info.name:match("[^a-z_]"),
		("Illegal character in module name %q"):format( mod_info.name )
	)
	
	for dependency in (mod_info.dependencies or ""):gmatch("([^%s]+)") do
		assert( -- Assertion: all the prerequisite dependencies specified exist.
			Modules[ dependency ],
			("Module %q is missing dependency %q"):format( mod_info.name , dependency )
		)
	end

	MODINFO=mod_info
	local mod_contents = dofile( mod_info.file )

	assert( -- Assertion: the module being loaded is not empty.
		mod_contents,
		("Contents of module %s empty."):format( mod_info.name )
	)

	MODPATH=nil
	MODINFO=nil
	
	Module:add( mod_info , mod_contents )
end

---------------------------------------------------------------------------------------------------------------------------------------