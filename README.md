mmm.coffee
==========

Math, Matricies, and More


Under construction.


Static methods for immutability

p1 = new Point(0, 1)       // or new Point([0, 1])
p2 = Point.add(p1, [2, 3]) // it's a new point (2,4)
p3 = Point.add(p1, p2)     // also a new point (2,5)


Member functions for mutability

p1 = new Point(0, 1)
p2 = p.add([2, 3]) // p2 === p1 (2,4)
p3 = p2.add(p1) // p3 === p2 === p1 (4,6)


API

Generally, all listed functions are available in both mutable (member functions) 
and  immutable (static functions) forms. Any exceptions to this are noted 
explicitly. The static functions accept either an instance of a particular 
object type, or a descendant type, or vanilla JS arrays. 

All functions accepts arbitrary # of dimensions unless otherwise specified.

The member-function versions always pass itself in as the operand, for example
	Tuple.negate([1, 1]).equals(  (new Tuple([1, 1])).negate()  )

When an astrisk is appended to a return type, that means it will be that type, 
or a descendant type, depending on how it was called.

Many of the APIs will be given in the form of examples, hopefully it will 
be self-evident what the function of the function is.

	.add() is defined on Tuple
	
	Static/Immutable: 
		Tuple.add([1,1], [1,1]) -> return new Tuple([2,2])
		Point.add([2,2], [2,2]) -> return new Point([4,4])
	
	Member/Mutable:
		p = new Point([1,1])
		p.add([1,1])
		p.equals([2,2]) // true; p still instanceof Point.
	

Tuple
	
	constructor: (terms) 
	
		terms may be an array of numbers: new Tuple([1,2,3])
		or a list of parameters: new Tuple(1, 2, 3)
			[ NOTE: this is unique for constructors, for now, all other tuple-esq 
			  methods take only array-like inputs and not parameter lists ]
		or an instance of a Tuple or a descendant: new Tuple(new Vector(1, 2, 3))
		
		A Tuple instance is very array-like and has all the built-in array methods
		such as .forEach(), .map(), .every(), .some(), .splice(), .reduce(), etc..
		Worth mentioning, is that, in fact, Tuple extends Arrays, which means..
			(new Tuple([1,1])) instanceof Array === true

	[member function] valueOf() -> []
		return an array representation, e.g. [1, 2, 3]
	[member function] toString() -> ""
		return a string representation, e.g. "(1,2,3)"

	zero(length) -> [0, 0, ..., 0]
		return a 0-tuple of given length
	
	isZero(tuples...): -> [bool] 
		check if the tuple(s) are 0-tuples
	
	equals(tuples...): -> [bool] 
		check if the given tuples are equivilant
	
	negate(tuple): -> [tuple*] 
		Negation of a tuple: [1, 2, 3] -> [-1, -2, -3]
	
	add(tuples...): -> [tuple*]
		Adds the given tuples: [1,2] + [1,-2] + [1,2] = [3,4]
		Also accepts scalar values: [1,2] + 1 = [2,3]
	
	subtract(tuples...): -> [tuple*]
		Finds the difference: [6,6] - [2,2] - [1,1] = [3,3]
		Also accepts scalar values: [6,2] - 1 = [5,1]
	
	multiply(tuples...): -> [tuple*]
		Computes the product: [2,2] * [3,2] = [6,4]
		Also accepts scalar values: [2,2] * 3 = [6,6]
	
	divide(tuples...): -> [tuple*]
		Gets a quotient: [4,4] / [1,2] = [4,2]
		Also accepts scalar values: [4,4,10] / 2 = [2,2,5]
		
	modulo(tuples...): -> [tuple*]
		Gets a remainder: [4,4] % [3,2] = [1,0]
		Also accepts scalar values: [4,4] % 3 = [1,1]
	
	dot(tuples...): -> Number
		The dot product: [2,2] ⋅ [3,3] = 2⋅3 + 2⋅3 = 12
	
	pow(tuple, x): -> [Tuple*]
		Power function: [2,2]^3 = multiply([2,2],[2,2],[2,2]) = [8,8]

	square(tuple): -> [Tuple*]
		Short-hand for ^2, or pow(tuple, 2)
	
	sqrt(tuple): -> [Tuple*]
		Short-hand for square root, or pow(tuple, 1/2)
	
	sum(tuple): -> Number
		The sum of the tuple: [2,3,4] = 9
	
	product(tuple): -> Number
		The product sum of the tuple: [2,3,4] = 24
	
	round(tuple): -> [Tuple*]
		Round the terms in the tuple: [1.2, 2.8] = [1,3]
	
	ceil(tuple): -> [Tuple*]
		Rounds-up the tuple: [1.2, 2.8] = [2, 3]
	
	floor(tuple): -> [Tuple*]
		Rounds-down the tuple: [1.2, 2.8] = [1, 2]
	
	abs(tuple): -> [Tuple*] 
		Makes the tuple positive: [-3,4] = [3,4]
	
	max(tuples...): -> [Tuple*]
		Of the given tuples, maximize: [8,3], [5,5], [6,9] = [8,9]
	
	min(tuples...): -> [Tuple*]
		Of the given tuples, minimize: [8,3], [5,5], [6,9] = [5,3]
		
	average(tuples...): -> [Tuple*]
		Of the given tuples, find each terms average: [2,6], [4,0] = [3,3]




Point extends Tuple

	origin(point): -> [0, 0, ..., 0]
		returns the origin for a given point
		Also accepts a number-of-dimensions: origin(3) = [0,0,0]
		{Easter Egg} Accepts a string "x", "y", or "z", equivilant to 1, 2 or 3
	
	distance: (points...) -> Number
		Computes the distance between the given points: [2,3] -> [4,3] = 2
	
	normalize: (point, norm = 1) -> [Point*]
		Normalizes to a given length: [4,0], 1 -> [1,0]
	
	rotate: (point, radians [, around]) -> [Point*]
		[2D only, TODO: arbitrary dimensions]
		Rotates a point by 'radians', about the point 'around'
			'around' defaults to the origin
			[1,0], Math.PI, [0,0] = [-1, 0]


Vector extends Point
	
	standard(dimensions, term): -> [Vector*]
		The standard basis vector: 4, 1 = [0,1,0,0]
	
	norm(vector): -> Number
		The length of the vector: [3,4] = 5
	
	unit(vector): -> [Vector*]
		The vector normalized to a length of 1: [3,4] = [3/5, 4/5]
	
	cross() UNDER CONSTRUCTION
	
	project(vector, x): -> [Vector*]
		The tuple x, projected onto the vector: [3,4], [4,5] = [3.84, 5.12]
	
	angle(vector, vector2): -> NumberRadians
		The angle between the two vectors: [-1, 0], [1, 0] = Math.PI
		
	perpedicular(vector, vector2): -> bool
		check if the vectors are perpedicular: [0,1], [1,0] = true
	
	parallel(vectors...): -> bool
		check if the vectors are parallel: [2,3], [4,6] = true

		
		
		
		



