Util = require("./Util")
Tuple = require("./Tuple")

module.exports = exports = class Point extends Tuple
	constructor: (args...) -> 
		super(args...)
		
	origin: -> @nil()
	negate: -> new @constructor(@map (p) -> -p)

	distance: (point) -> @constructor.distance(@, point)

	normalize: (distance = 1) ->
		current = @distance()
		scale = if current isnt 0 then distance/current else 0
		new @constructor(@map (p) -> scale * p)

	dot: (p) -> @constructor.dot(@, p)
	cross: (p) -> @constructor.cross(@, p)
		
	@debug: false
	@strict: false
	
	@isPoint: (p) -> p instanceof @

	@distance: (p1, p2 = p1.origin()) ->
		Math.sqrt([p1, p2].zip().reduce(((sum, zip) ->
			sum + Math.pow(zip[1] - zip[0], 2)), 0))

	@add: (points...) -> @op(((a, p) -> a + p), points...)
	@subtract: (points...) -> @op(((a, p) -> a - p), points...)
	@multiply: (points...) -> @op(((a, p) -> a * p), points...)
	@divide: (points...) -> @op(((a, p) -> a / p), points...)
	@modulus: (points...) -> @op(((a, p) -> a % p), points...)

	@dot: (p1, p2) -> 
		@op(((a, p) -> a * p), p1, p2).reduce(((sum, ab) -> sum + ab), 0)
		
	@cross: (p1, p2) -> 
		@op(((a, p) -> a * p), p1, p2).reduce(((sum, ab) -> sum - ab), 0)
		
	@normalizer: (distance = 1) -> Util.arrayify(
		(points...) -> points.map (point) -> point.normalize(distance)
	)



[ "add", "subtract", "multiply", "divide", "modulus",
	# "dot", "cross"
].forEach(((method) -> 
	@[method] = Tuple.arrayify(@[method])
	@::[method] = (points...) -> @constructor[method](@, points...)
), Point)

