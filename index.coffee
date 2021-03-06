require("./lib/polyisofill")

module.exports = exports = root = (options = {}) ->
	
	options.hitch = options?.hitch or global
	options.debug = options?.debug or false

	for classname, classdef of root

		if options.debug then console.info "Loading #{classname}"

		for optionName, value of options
			classdef[optionName] = value

		options.hitch[classname] = classdef
	

[
	require("./lib/Tuple"),
	require("./lib/Can"),	
	require("./lib/Point"),
	require("./lib/Vector"),
	require("./lib/Line"),
	require("./lib/Matrix"),
	require("./lib/Vertex"),
	require("./lib/Polygon"),
	require("./lib/Grid"),
	require("./lib/Pack"),
	require("./lib/Unpack")
].forEach (classdef) -> root[classdef.name] = classdef
