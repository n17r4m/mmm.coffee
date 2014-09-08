###

Point (2d x,y)
see: https://github.com/paperjs/paper.js/blob/master/src/basic/Point.js 

new Point(x || {x,y} || [x,y] || {width,height} || {left,top} , y)
	.clone -> new Point(this)
	.set(x, y, silent) -> this
	.equals(new Point(x), y) -> Boolean()
	.toString()  -> '{x:x,y:y}'
	.serialize() -> [x,y],
	.add(Point p)      -> new Point(this + p)
	.subtract(Point p) -> new Point(this - p)
	.multiply(Point p) -> new Point(this * p)
	.divide(Point p)   -> new Point(this / p)
	.modulo(Point p)   -> new Point(this % p)
	.negate() -> new Point(-x, -y)
	.transform(Matrix) -> new Point()
	.distance(point) -> Number()
	.quandrant -> 1 || 2 || 3 || 4
	.length = sqrt(x^2 + y^2) 
	.normalize(length)
	.angle -> Number(radians)
	.angle = Point(x,y)
	.slope = Number
	.radians(point) -> Number(radians)
	.degrees(point) -> Number(degrees)
	.angleTo(point) -> Number(degrees)
	.slopeTo(point) -> Number(-Infinity-Infinity)
	.rotate(Number(degrees), Point(center)) -> new Point()
	.insideOf(Rect) -> Boolean()
	.closeTo   (Point, Number(tolerance)) -> Boolean()
	.colinear  (Point, Number(tolerance)) -> Boolean()
	.orthogonal(Point, Number(tolerance)) -> Boolean()
	.isZero() -> Boolean()
	.isNaN()  -> Boolean()
	.scale(Point p)   -> Number(.dot(p) / .dot(p))
	.dot(Point p)     -> Number(x*p.x + y*p.y)
	.cross(Point p)   -> Number(x*p.x - y*p.y)
	.project(Point p) -> new Point(this * .scale(p))
	.round[X|Y] -> round(Number) || [X|Y] round(Point)
	.floor[X|Y] -> round(Number) || [X|Y] floor(Point)
	.ceil[X|Y]  -> ceil(Number)  || [X|Y] ceil(Point)
	.abs[X|Y]   -> abs(Number)   || [X|Y] abs(Point)

Point.min(p1, p2) -> .min(p.x, p.y)
Point.max(p1, p2) -> .max(p.x, p.y)
Point.random -> new Point()

###


@Point = class Point
	constructor: (x, y) ->	
		this.tolorance = 2
		this.observers = []
		type = typeof x
		if type is 'number'
			@x = x
			@y = if typeof y is 'number' then y else x
		else
			if Array.isArray(x)
				@x = x[0]; 
				@y = if x.length > 1 then x[1] else x[0]
			else if x?.x?
				@x = x.x 
				@y = if x.y? then x.y else x.x 
			else if x?.width? 
				@x = x.width
				@y = if x.height? then x.height else x.width
			else if x?.left?
				@x = x.left;
				@y = if x.top? then x.top else (if x.bottom? then x.bottom else x.left)
			else if x?.right?
				@x = x.right;
				@y = if x.top? then x.top else (if x.bottom? then x.bottom else x.left)
			else if x?.angle?
				@x = if x.length? then x.length else 0
				@y = 0
				@angle = x.angle
			else
				@x = 0
				@y = 0
		return @

	toString: -> "{ x: #{@x}, y: #{@y} }"
	toArray: -> [@x, @y]
	serialize: -> [@x, @y]

	set: (x = 0, y = 0) -> 
		@x = x
		@y = y
		return @

	@getter 'clone', -> new Point(@)

	@property 'length', 
		get: -> Math.sqrt(@x*@x + @y*@y)
		set: (length) ->
			if @isZero()
				angle = @_angle || 0
				@set( Math.cos(angle) * length, Math.sin(angle) * length )
			else
				scale = length / @length
				@set(scale*@x, scale*@y)
			return length

	@property 'angle',
		get: -> @radians()
		set: (point) ->
			@_angle = if point.angle then point.angle else point
			unless @isZero()
				length = @length
				@set(Math.cos(@angle) * length, Math.sin(@angle) * length )

	@getter 'slope', -> @y / @x

	@property 'quandrant',
		get: -> 
			if this.x >= 0 
				return if this.y >= 0 then 1 else 4
			else
				return if this.y >= 0 then 2 else 3
		set: (x, y, silent) ->
			@x = x
			@y = y
			unless silent then @update()
			return @

	update: -> @observers.forEach (fn) -> fn()

	equals: (point) ->
		if point is @ 
			return true
		else if (point and (Array.isArray(point) and @x is point[0] and @y is point[1]))
			return true
		else if (@x is point and @y is point)
			return true
		else if ((p = new Point(point)) and (@x is p.x and @y is p.y))
			return true
		else
			return false

	add: (point) -> new Point(@x + point.x, @y + point.y)

	subtract: (point) -> new Point(@x - point.x, @y - point.y)

	multiply: (point) -> new Point(@x * point.x, @y * point.y)

	divide: (point) -> new Point(@x / point.x, @y / point.y)

	modulo: (point) -> new Point(@x % point.x, @y % point.y)

	negate: -> new Point(-@x, -@y)

	transform: (matrix) -> matrix.point(@)

	distance: (point, squared = true) ->
		d = Math.pow(point.x - @x, 2) + Math.pow(point.y - @y, 2)
		return if squared then d else Math.sqrt(d)

	normalize: (length) ->
		unless length? then length = 1
		current = @length
		scale = if current isnt 0 then length/current else 0
		point = new Point(scale*@x, scale*@y)
		if scale >= 0 then point._angle = @_angle
		return point

	radians: (point) ->
		unless point
			if @isZero()
				return (@_angle || 0)
			else
				return this._angle = Math.atan2(this.y, this.x);
		else
			div = @length * point.length
			if (div == 0) then return NaN
			return Math.acos(@dot(point) / div)

	degrees: (point) -> @radians(point) * 180 / Math.PI

	angleTo: (point) -> Math.atan2(@cross(point), @dot(point)) * 180 / Math.PI

	slopeTo: (point) -> (point.y - @y)/(point.x - @x)

	rotate: (angle, center) ->
		if (not angle or angle is 0) then return @clone
		angle = angle * Math.PI / 180;
		point = if center? then @subtract(center) else @
		[s, c] = [Math.sin(angle), Math.cos(angle)]
		point = new Point( point.x * c - point.y * s,	point.x * s + point.y * c	)
		return if center? then point.add(center) else point

	insideOf: (rect) -> rect.contains(@)

	closeTo: (point, tolerance = @tolerance) -> @distance(point) < tolerance

	colinear: (point, tolerance = @tolerance) -> Math.abs(@cross(point)) < tolerance

	orthogonal: (point, tolerance = @tolerance) -> Math.abs(@dot(point)) < tolerance

	isZero: -> (@x is 0 or isNaN(@x)) and (@y is 0 or isNaN(@y))
	
	isNaN: -> isNaN(@x) or isNaN(@y)

	scale: (point) -> this.dot(point) / point.dot(point)

	dot: (point) -> @x * point.x + @y * point.y

	cross: (point) -> @x * point.x - @y * point.y

	project: (point) ->
		if point.isZero()
 			return new Point(0,0);
		return point.multiply(new Point(this.scale(point)))

	@getter 'roundX', -> Math.round(@x)
	@getter 'roundY', -> Math.round(@y)
	@getter 'round', -> new Point(@roundX, @roundY)

	@getter 'ceilX', -> Math.ceil(@x)
	@getter 'ceilY', -> Math.ceil(@y)
	@getter 'ceil', -> new Point(@ceilX, @ceilY)

	@getter 'floorX', -> Math.floor(@x)
	@getter 'floorY', -> Math.floor(@y)
	@getter 'floor', -> new Point(@floorX, @floorY)

	@getter 'absX', -> Math.abs(@x)
	@getter 'absY', -> Math.abs(@y)
	@getter 'abs', -> new Point(@absX, @absY)


	@min: (p1, p2) -> new Point(Math.min(p1.x, p2.x), Math.min(p1.y, p2.y))

	@max: (p1, p2) -> new Point(Math.max(p1.x, p2.x), Math.max(p1.y, p2.y))

	@random: -> new Point(Math.random(), Math.random()) 

