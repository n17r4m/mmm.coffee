Tuple = require("./Tuple")
Point = require("./Point")
Vector = require("./Vector")
Intersection2 = require("./Intersection2")

module.exports = exports = class Line extends Point
	constructor: (A = new Point(), B = new Point()) ->
		if Line.isLine(A)
			if B? and Line.isLine(B)
				return new @constructor(
					Point.min(A.A, A.B, B.A, B.B), 
					Point.max(A.A, A.B, B.A, B.B)
				)
			else if B?
				return new @constructor(
					Point.min(A.A, A.B, B), 
					Point.max(A.A, A.B, B)
				)
			else
				@vector = new Vector(A.vector)
				super(A)
		else if Vector.isVector(A)
			@vector = new Vector(A)
			super(@vector.zero())
		else if Point.isPoint(A)
			if Vector.isVector(B)
				super(A)
				@vector = new Vector(B)
			else if Point.isPoint(B)
				super(A)
				@vector = new Vector(B.subtract(A))
			else if Array.isArray(B)
				super(A)
				@vector = new Vector(B)
			else 
				super(A.zero())
				@vector = new Vector(A)
		else if Array.isArray(A)
			if Vector.isVector(B)
				super(A)
				@vector = new Vector(B)
			if Array.isArray(B)
				super(A)
				@vector = (new Vector(B)).subtract(@)
			else
				@vector = new Vector(A)
				super(@vector.zero())

		else 
			throw new Error("Unsupported Argument type(s)")

	intersects: (line) -> @constructor.intersection([@, line])

	@getter 'A', -> new Point(@)
	@getter 'B', -> @A.add(@vector)
	
	dist: -> @vector.dist()
	angle: -> @vector.angle()
	
	@isLine: (a) -> a instanceof Line
	
	@op: (fn, lines...) -> 
		if lines.length is 2 and Number.isNumber(lines[1])
			lines[1] = new Point(lines[0].zero().map (n) -> lines[1])
		result = new @(new Point(lines.zip(if @strict then NaN else null).map((linePoints) -> 
			linePoints.reduce(((acc, e) -> fn(acc, e)), linePoints.shift())
		)), new Vector(lines[0].vector))
		return result
	
	@rotate: (line, radians = 0, around = line.zero()) ->
		(new Line(
			line.A.rotate(radians, around).fix(), 
			line.B.rotate(radians, around).fix()
		))
	
	@intersection: (lines...) ->
		unless lines[0].length = 2
			throw new RangeError("Only 2d line intersections are presently supported")
		(new Intersection2(lines)).generalIntersection()
		

["multiply", "divide"]
.forEach(((method) ->
	fn = @[method]
	@[method] = (args...) -> 
		res = fn.apply(@, args)
		res.vector = res.vector[method](args.slice(1)...)
		return res
), Line)

