Tuple = require("./Tuple")

module.exports = exports = class Point extends Tuple
	constructor: (args...) -> 
		super(args...)
		
	origin: -> @zero()
	negate: -> @multiply(-1)

	dist: (points...) -> 
		points.unshift(@)
		@constructor.dist(points)

	normalize: (norm = 1) -> @multiply(norm / @dist())

	@debug: false
	@strict: false
	
	@isPoint: (p) -> p instanceof @

	@dist: @arrayify (points...) ->
		if points.length is 0 then return 0
		if points.length is 1 then points.unshift(points[0].map (p) -> 0)
		sum = 0
		p2 = points.shift()
		console.info p1, p2
		while (p1 = p2) and (p2 = points.shift())
			sum += @dist2(p1, p2)
		return sum
		
	@dist2: (p1, p2) ->
		Math.sqrt([p1, p2].zip().reduce(((sum, pair) ->
			sum + Math.pow(pair[1] - pair[0], 2)), 0))

	@Normalizer: (norm = 1, multi = true) -> 
		if typeof norm is 'boolean' then [multi = norm, norm = 1]
		@arrayify (points...) =>
			normalized = points.map (point) => (new @(point)).normalize(norm)
			if multi then normalized else normalized[0]


