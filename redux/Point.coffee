Tuple = require("./Tuple")
axis = require("./helpers/axis")

class Point extends Tuple

	origin: -> @zero()
	@origin: (point = []) -> 
		unless point instanceof Array
			if point.constructor is Number then n = point
			else if point.constructor is String then n = axis(point, 3) + 1
			else throw new RangeError("Don't know # of dimensions")
		else n = point.length
		@zero(n)
	
	distance: (points...) -> @constructor.distance(@, points...)
	@distance: (points...) ->
		if points.length is 0 then return 0
		if points.length is 1 then points.unshift(@origin(points[0]))
		dist = 0
		p2 = points.shift()
		while (p1 = p2) and (p2 = points.shift())
			dist += Math.sqrt(@subtract(p2, p1).square().sum())
		return dist

	normalize: (norm = 1) -> @mutate @constructor.normalize(@, norm)
	@normalize: (point, norm = 1) -> @multiply(point, norm / @distance(point))

	rotate: (radians = 0, around) -> 
		@mutate @constructor.rotate(@, radians, around = @origin())
	@rotate: (point, radians = 0, around = @origin(point)) ->
		switch point.length
			when 0 then new @ point
			when 1 then new @ point
			when 2 
				[x, y] = [point[0] - around[0], point[1] - around[1]]
				xRotated = Math.cos(radians)*x - Math.sin(radians)*y
				yRotated = Math.sin(radians)*x + Math.cos(radians)*y
				(new @(xRotated + around[0], yRotated + around[1]))
			when 3 then throw new TypeError("NYI: >= 3D rotations")
			else throw new TypeError("NYI: >= 4D rotations")

if typeof define is 'function' and define.amd then define -> Point
else if typeof module is 'object' and module.exports then module.exports = Point
else @Point = Point
