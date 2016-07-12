-- Global config goes here. For configuration details on specific modules, check the respective module file.
return {
	-- All the 'libraries' to be loaded. Supply (without extension) the libraries located in src/
	lib_load={
		"/src/function",
		"/src/modules",
		"/src/irc/irc",
	},

	-- All modules that have to be loaded before starting.
	-- Just supply the name of the directory in mod/
	mod_load={
	},
}