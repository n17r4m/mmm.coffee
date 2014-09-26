
Point = require("./Point")
Vector = require("./Vector")
Arrow = require("./Arrow")

module.exports = exports = class Line extends Point
	constructor: (A = new Point(), B = new Point()) ->
		if Line.isLine(A)
			@vector = new Vector(A.vector)
			super(A)
		else if Arrow.isArrow(A)
			@vector = new Vector(A)
			super(A.point)			
		else if Vector.isVector(A)
			@vector = new Vector(A)
			super(new Point())
		else if Point.isPoint(A)
			super(A)
			if Vector.isVector(B)
				@vector = new Vector(B)
			else if Point.isPoint(B)
				@vector = new Vector(B.subtract(A))
		else if Array.isArray(A)
			if Array.isArray(B)
				super(A)
				@vector = (new Vector(A)).subtract(@)
			else
				@vector = new Vector(A)
				super(@vector.zero())

		else 
			throw new Error("Unsupported Argument type(s)")
		
		@point = new Point(point)
		super(vector)
	
	translate: (point) -> @point.add(point)
	
	@isLine: (a) -> a instanceof Line
	
	@intersection: (lines...) ->
		throw new Error("Line intersection tests.. NYI")
	
	
	
