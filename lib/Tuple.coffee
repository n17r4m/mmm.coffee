Util = require("./Util")

module.exports = exports = class Tuple extends Array
	constructor: (array) ->
		if @constructor.isTuple(array)
			@push.apply @, array.toArray()
		if @constructor.isArray(array)
			@push.apply @, array
		else
			@push.apply @, arguments
		return @

	nil: -> @map -> 0

	toArray: -> @slice()
	toString: -> @toArray().toString()
	valueOf: -> @toArray()

	@isArray: (a) -> a instanceof Array
	@isTuple: (t) -> t instanceof @

	@op: (fn, tuples...) -> 
		new @(tuples.zip(if @strict then NaN else null).map((elements) -> 
			elements.reduce(((acc, e) -> fn(acc, e)), elements.shift())
		))

	@equals: (tuples...) -> 
		@op(((a, el) -> a is el), tuples...).every (b) -> b is true
		
	@max: (points...) -> @op(((a, p) -> Math.max(a, p)), points...)
	@min: (points...) -> @op(((a, p) -> Math.min(a, p)), points...)
	@average: (points...) -> new @(@add(points...).map((p) -> p / points.length))

[
	"equals", "max", "min", "average"
].forEach(((method) -> 
	@[method] = Util.arrayify(@[method])
	@::[method] = (points...) -> @constructor[method](@, points...)
), Tuple)

