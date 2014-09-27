Point = require("./Point")

module.exports = exports = class Vector extends Point
	constructor: (args...) ->
		super(args...)

	norm: -> @dist()

	unit: -> @divide(@norm())

	angle: (v = @constructor.standard(@length)) -> @constructor.angle(@, v)

	cross: (v = @) -> @constructor.cross(@, v)

	project: (v) -> @constructor.project(@, v)

	parallel: (v) -> 
		x = (s = @divide(v).deNaN()).max()
		not s.some (t) => Math.abs(t) - Math.abs(x) > @constructor.tolerance

	intersects: (v) -> not @parallel(v)

	perpendicular: (v) -> -@constructor.tolerance < @dot(v) < @constructor.tolerance 

	perpendicularTo: (v) -> @constructor.perpendicularTo(@, v)

	hyperspace: -> throw new Error("NYI: Surface perpedicular to this vector")

	@isVector: (v) -> v instanceof Vector

	@norm: (v) -> @dist(v)

	@unit: (v) -> (new @(v)).unit()

	@angle: (v, u) -> Math.acos(@dot(v, u) / (@norm(v) * @norm(u)))


	@cross: (v, u) -> 
		@perpendicularTo(v, u).multiply(
			@norm(v) * @norm(u) * Math.sin(@angle(v, u))
		)

	@perpendicularTo: (u, v) ->
		[u, v] = [new Tuple(u), new Tuple(v)]
		[u, v].forEach (x) -> x.push(0)
		p = new Vector(
			Matrix.rref([u, v]).map (row, i) -> 
				row.reduce(((sum, col) -> sum - col), 1)
		)
		
		while p.length < u.length - 1
			p.push(1)	
		return p.unit()

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


