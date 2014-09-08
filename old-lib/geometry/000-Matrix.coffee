###
Matrix (2d transform) // TODO: rename (More than one type of 'Matrix', et al) Matrix2dt
see: https://github.com/paperjs/paper.js/blob/master/src/basic/Matrix.js 
	
new Matrix(Matrix || {a,c,b,d,tx,ty} || [a,c,b,d,tx,ty] || undefined)
	.set(a, c, b, d, tx, ty, silent) -> this
	.array = [a,c,b,d,tx,ty] -> this
	.clone = new Matrix(this)
	.equals(mx) -> Boolean(doesEqual(this.tolerance))
	.serialize() -> '[a,c,b,d,tx,ty]'
	.toString() -> 'matrix(a,c,b,d,tx,ty)'
	.reset(silent) -> this // sets identity matrix
	.translate(point, silent) -> this
	.scale(scale, point, silent) -> this
	.rotate(angle, point, silent) -> this
	.shear(shear, point, silent) -> this
	.skew(skew, point, silent) -> this
	.add(mx, silent) -> this // addition  
	.subtract(mx, silent) -> this // difference
	.push(mx, silent) -> this // multiply/concatenate
	.unshift(mx, silent) -> this // multiply/pre-concatenate
	.isIdentity() -> Boolean()
	.determinant -> null || Number(a*d - b*c)
	.invertable -> Boolean() (has determinate)
	.singular -> Boolean() (no determinate)
	.point(p) -> Point(transformed)
	.coords(c=[x,y, x,y, ...], 0, c.length) -> [x2,y2, x2,y2, ... ]
	.inverseTransform(point) -> Point() // reverse transforms a point
	.decompose() -> {scale, rotation, translation, shear}
	.translation -> Point()
	.scaling -> Number()
	.rotation -> Number()
	.origin -> Point()
	.inverted -> Matrix() // reverse transformation 

###



@Matrix = class Matrix
	
	constructor: (mx) ->

		@observers = []
		@tolerance = 0.1

		ok = true
		switch(arguments.length)
			when 6 then @set.apply(@, arguments)
			when 0 then @reset(true) 
			when 1
				if mx.a? and mx.c? then @set(mx.a, mx.c, mx.b, mx.d, mx.tx, mx.ty)
				else if Array.isArray(mx) then @set.apply(@, mx)
				else ok = false
			else ok = false

		if not ok then throw new Error("Unsupported matrix parameters")
		else return @

	set: (a, c, b, d, tx, ty, silent = false) ->
		@a = a
		@c = c
		@b = b
		@d = d
		@tx = tx
		@ty = ty
		unless silent then @update()
		return @

	update: -> @observers.forEach (fn) -> fn()

	@getter 'clone', -> new Matrix(@array)

	@property 'array',
		get: -> [@a, @c, @b, @d, @tx, @ty]
		set: (a) -> @set.apply(@, a)

	equals: (mx) ->
		if mx is this then return true
		if Math.abs(mx.a - @a) < @tolerance and Math.abs(mx.c - @c) < @tolerance
			if Math.abs(mx.b - @b) < @tolerance and Math.abs(mx.d - @d) < @tolerance
				if Math.abs(mx.tx - @tx) < @tolerance and Math.abs(mx.ty - @ty) < @tolerance
					return true
		return false

	toString: -> "matrix(#{@a},#{@c},#{@b},#{@d},#{@tx},#{@ty})"
	serialize: -> @array

	reset: (silent = false) -> @set(1,0,0,1,0,0,silent)

	translate: (point, silent) ->
		@set(
			@a, @c, @b, @d, 
			@tx + @a*point.x + @b*point.y,
			@ty + @c*point.x + @d*point.y,
			silent
		)

	scale: (scale, point, silent) ->
		scale = new Point(scale)
		if point? then @translate(point, true)		
		@set(@a*scale.x, @c*scale.x, @b*scale.y, @d*scale.y, @tx, @ty, true)
		if point? then @translate(point.negate(), true)
		unless silent then @update()
		return @

	rotate: (angle, point, silent) ->
		angle *= MathPI / 180
		x = point?.x || 0
		y = point?.y || 0
		c = Math.cos(angle)
		s = Math.sin(angle)
		tx = x - c*x + s*y
		ty = y - s*x + c*y
		@set(
			c*@a + s*@b, c*@c + s*@d, -s*@a + -s*@c, c*@c + c*@d, 
			@tx + @a*tx + @b*ty, @ty + @c*tx + @d*ty
		)

	shear: (shear, point, silent = false) ->
		if point? then @translate(point, true)
		@set(@a + @b*shear.y, @c + @d*shear.y, @b + @a*shear.x, @d + @c*shear.x, @tx, @ty)
		if point? then @translate(point.negate())
		unless silent then @update()
		return @

	skew: (skew, point, silent) -> 
		@shear( 
			new Point(Math.tan(skew.x * Math.PI / 180), Math.tan(skew.y * Math.PI / 180)),
			point, silent
		)

	add: (mx, silent) ->
		@set(@a+mx.a, @c+mx.c, @b+mx.b, @d+mx.d, @tx+mx.tx, @ty+mx.ty, silent)
		
	subtract: (mx, silent) -> 
		@set(@a-mx.a, @c-mx.c, @b-mx.b, @d-mx.d, @tx-mx.tx, @ty-mx.ty, silent)

	push: (mx, silent) -> 
		@set(
			@a*mx.a + @b*mx.c, @c*mx.a + @d*mx.c,
			@a*mx.b + @b*mx.d, @c*mx.b + @d*mx.d,
			@tx + (@a*mx.tx + @b*mx.ty), @ty + (@c*mx.tx + @d*mx.ty), 
			silent 
		)

	unshift: (mx, silent) ->
		@set( 
			@a*mx.a + @c*mx.b, @a*mx.c + @c*mx.d,	@b*mx.a + @d*mx.b, @b*mx.c + @d*mx.d,
			mx.tx + @tx*mx.a + @ty*mx.b, mx.tx + @tx*mx.c + @ty*mx.d,
			silent
		)

	isIdentity: -> (@a is 1 and @c is 0 and @b is 0 and @d is 1 and @tx is 0 and @ty is 0)

	@getter 'determinant', ->
		det = @a * @d - @b * @c;
		if ( isFinite(det) && det != 0 && isFinite(this.tx) && isFinite(this.ty) ) 
			return det;
		else return null

	@getter 'invertable', -> !!this.determinant
	
	@getter 'singular', -> !this.determinant

	point: (point = new Point()) -> 
		new Point(@a*point.x + @b*point.y + @tx,	@c*point.x + @d*point.y + @ty)

	coords: (coords, start = 0, count = coords.length - start) ->
		out = []
		while (start < count)
			transformed = @transform(new Point([coords[start++], coords[start++]]))
			out.push(transformed.x) 
			out.push(transformed.y)
		return out

	rect: (rect) -> throw new Error("TODO")

	inverseTransform: (point) ->
			det = @determinant
			unless det then return null
			x = point.x - @tx
			y = point.y - @ty

			return new Point( (x * this.d - y * this.b) / det, 
												(y * this.a - x * this.c) / det)

	decompose: ->
		{a, b, c, d, tx, ty} = {@a, @b, @c, @d, @tx, @ty}
		if (a * d - b * c) is 0 then return null
		scaleX = Math.sqrt(a*a + b*b)
		a /= scaleX
		b /= scaleX
		shear = a * c + b * d
		c -= a * shear
		d -= b * shear
		scaleY = Math.sqrt(c*c + d*d)
		c /= scaleY
		d /= scaleY
		shear /= scaleY
		if a*d < b*c
			a = -a
			b = -b
			shear = -shear
			scaleX = -scaleX
		return {
			scale: new Point(scaleX, scaleY)
			rotation: -Math.atan2(b, a) * 180 / Math.PI
			translation: new Point(tx, ty)
			shear: shear
		}


	@getter 'translation', -> new Point(@tx, @ty)
	@getter 'scaling', -> (this.decompose() || {}).scale || 1
	@getter 'rotation', -> (this.decompose() || {}).rotation || 0
	@getter 'origin', -> new Matrix(this.a, this.c, this.b, this.d, 0, 0)
	@getter 'inverted', -> 
		if det = this.determinant then return new Matrix(
			@d/det, -@c/det,	-@b/det, @a/det, 
			(@b*@ty - @d*@tx)/det, (@c*@tx - @a*@ty)/det )


