Point = require("./Point")

module.exports = exports = class Vector extends Point
	constructor: (args...) ->
		super(args...)

	norm: -> @dist()

	unit: -> @divide(@norm())

	dot: (v) -> @constructor.dot(@, v)
	
	project: (v) -> @constructor.project(@, v)

	parallel: (v) -> 
		x = (s = @divide(v).deNaN()).max()
		not s.some (t) => t isnt x
		
	perpendicular: (v) -> @dot(v) is 0

	intersects: (v) -> not @parallel(v)

	hyperspace: -> throw new Error("NYI: Surface perpedicular to this vector")

	@dot: (v, u) -> @op(((vn, un) -> vn * un), v, u).reduce(((sum, vu) -> sum + vu), 0)

	#wrong	@cross: (p1, p2) -> @op(((a, p) -> a * p), p1, p2).reduce(((sum, ab) -> sum - ab), 0)

	@project: (a, x) ->
		[a, x] = [new @(a), new @(x)]
		if x.isZero() then return a.zero()
		a.multiply(x.dot(a)/a.dot(a))
		
		
	@standard: (dimensions = 1, axis = 1) ->
		v = @zero(dimensions)
		v[axis-1] = 1
		return v

	@parallel: @arrayify (vectors...) ->
		vectors.every (vector, i) => 
			(new @(vector)).parallel(new @(vectors[i+1]||vector))		


