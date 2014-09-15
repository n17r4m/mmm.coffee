Tuple = require("./Tuple")

module.exports = exports = class Point extends Tuple
	constructor: (args...) -> 
		super(args...)
		
	origin: -> @nil()
	negate: -> new @constructor(@map (p) -> -p)

	distance: (points...) -> 
		cls = @constructor
		unless points.length > 0 then points.unshift(new Point())
		points.unshift(@)
		points.reduce(((sum, p, i) -> sum + cls.distance(p, points[i+1]||p)), 0)

	normalize: (distance = 1) ->
		current = @distance()
		scale = if current isnt 0 then distance/current else 0
		new @constructor(@map (p) -> scale * p)

	@debug: false
	@strict: false
	
	@isPoint: (p) -> p instanceof @




	@distance: (points...) ->
		# TODO: fixeme for length > 2
		console.info "length", points.length
		points = points.map (p) => new @(p)
		if points.length is 0 then return 0
		if points.length is 1 then points.push(points[0])
		Math.sqrt(points.zip().reduce(((sum, zip) ->
			sum + Math.pow(zip[1] - zip[0], 2)), 0))


	@dot: (p1, p2) -> @op(((a, p) -> a * p), p1, p2).reduce(((sum, ab) -> sum + ab), 0)
	@cross: (p1, p2) -> @op(((a, p) -> a * p), p1, p2).reduce(((sum, ab) -> sum - ab), 0)
		
	@scale: (p1, p2) ->  @dot(p1, p2) / @dot(p1, p2)
	
	@project: (p1, p2) ->
		if (p2 = new @(p2)).isZero() then return p2.zero()
		@multiply(p2, @scale(p1, p2))
		
	@Normalizer: (distance = 1) -> 
		#TODO: this is presently broken for 1arg inputs.
		@arrayify (points...) =>
			console.info @name 
			points.map (point) =>
				console.info point 
				(new @(point)).normalize(distance)



[ "add", "subtract", "multiply", "divide", "modulus", "dot", "cross"
].forEach(((method) -> 
	# copy in as instance methods
	@::[method] = (points...) -> @constructor[method](@, points...)
), Point)

