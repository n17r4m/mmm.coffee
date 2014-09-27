
Point = require("./Point")
Vector = require("./Vector")

module.exports = exports = class Arrow extends Vector
	constructor: (A = new Point(), B = new Point()) ->
	
		###
		@point = new Point(point)
		super(vector)
		###
	
		if Arrow.isArrow(A)
			@point = new Point(A.point)
			super(A.vector)
		else if Vector.isVector(A)
			@point = new Point()
			super(A)
		else if Point.isPoint(A)
			@point = new Point(A.point)
			if Vector.isVector(B)
				super(B)
			else if Point.isPoint(B)
				super(B.subtract(A))
		else if Array.isArray(A)
			if Array.isArray(B)
				@point = new Point(A)
				super(B)
			else
				super(A)
		else 
			throw new Error("Unsupported Argument type(s)")
		
	
	translate: (point) -> @point.add(point)
	
	@isArrow: (a) -> a instanceof Arrow
	
