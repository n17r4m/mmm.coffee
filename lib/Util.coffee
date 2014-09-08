Tuple = require("./Tuple")
exports.arrayify = (fn) -> 
	if typeof fn is 'function' then return (args...) ->
		if args.length is 1 and Array.isArray(args[0]) and not Tuple.isTuple(args[0])
			args = arguments[0]
		return fn.apply(@, args)
	else return fn
