require("./lib/polyisofill")

module.exports = exports = root = (options = {}) ->
	
	options.hitch = options?.hitch or global
	options.debug = options?.debug or false

	for classname, classdef of root

		if options.debug then console.info "Loading #{classname}"

		for optionName, value of options
			classdef[optionName] = value

		options.hitch[classname] = classdef
	

[ require("./lib/Tuple"),
	require("./lib/Point"),
	require("./lib/Vector"),
	require("./lib/Arrow"),
	require("./lib/Line")

].forEach (classdef) -> root[classdef.name] = classdef
