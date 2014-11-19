Point = require("./Point")
axis = require("./helpers/axis")

class Vector extends Point

	standard: (term) -> @constructor.standard(@length, term)
	@standard: (dimensions = 1, term = 0) ->
		unless term.constructor is Number then term = axis(term)
		v = @zero(dimensions)
		v[term] = 1
		v

	norm: @distance()
	@norm: (vector) -> @distance(vector)

	unit: -> @normalize()
	@unit: (vector) -> @normalize(vector)
	
	cross: -> "NYI"
	@cross: -> "NYI"

	project: (x) -> @constructor.project(@, x)
	@project: (a, x) ->
		if @isZero(x) then return @zero(a)
		else @multiply(a, @dot(x, a)/@dot(a, a))

	angle: (vector) -> @constructor.angle(@, vector)
	@angle: (v, u = @standard(v.length)) -> Math.acos(@dot(v, u) / (@norm(v) * @norm(u)))

	perpedicular: (vector) -> @constructor.perpedicular(@, vector)
	@perpedicular: (v1, v2) ->
		if v2? then @dot(v1, v2) is 0
		else "NYI"

	parallel: (vectors...) -> @constructor.parallel(@, vectors...)
	@parallel: (vectors...) -> 
		parallel = true
		v2 = vectors.shift()
		while (v1 = v2) and (v2 = vectors.shift())
			parallel = parallel and @equals(@divide(v1, v2))
		parallel

if typeof define is 'function' and define.amd then define -> Vector
else if typeof module is 'object' and module.exports then module.exports = Vector
else @Vector = Vector


