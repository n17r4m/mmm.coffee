Util = require("./Util")

module.exports = exports = class Point extends require("./Tuple")
	constructor: (args...) -> 
		super(args...)
		
	origin: -> @nil()
	negate: -> new @constructor(@map (p) -> -p)

	distance: (point) -> @constructor.distance(@, point)

	normalize: (distance = 1) ->
		current = @distance()
		scale = if current isnt 0 then distance/current else 0
		new @constructor(@map (p) -> scale * p)

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

	@normalizer: (distance = 1) -> Util.arrayify(
		(points...) -> points.map (point) -> point.normalize(distance)
	)



[ "add", "subtract", "multiply", "divide", "modulus"
].forEach((method) -> 
	Point[method] = Util.arrayify(Point[method])
	Point.prototype[method] = (points...) -> @constructor[method](@, points...)
)

