Point = require("./Point")
Vector = require("./Vector")


class Ray extends Vector
	constructor: (ray) ->
		super(ray.vector or ray)
		@origin = new Point(ray.origin?.splice(0) or Vector.origin(ray.length))
	
	at: (x) -> @constructor.at(@, x)
	@at: (ray, x = 1) -> Point.add(ray.origin, Point.multiply(ray, x))

if typeof define is 'function' and define.amd then define -> Ray
else if typeof module is 'object' and module.exports then module.exports = Ray
else @Ray = Ray
