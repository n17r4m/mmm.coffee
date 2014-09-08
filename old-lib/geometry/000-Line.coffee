###

Line (2D)
see: https://github.com/paperjs/paper.js/blob/master/src/basic/Line.js

new Line((x, y, dx, dy || {x,y}, {dx,dy}), asVector)
	.p .point = Point(x,y) -> this
	.v .vector = Point(dy,dx) -> this
	.l .length = Number(length) -> this
	.clone = new Line(this)
	.intesect(line, isInfinite) -> undefined || Point(x,y)
	.side(point) -> Number(1 || 0 || -1)
	.distance(point) -> Number(length)

Line.intersect(apx, apy, avx, avy, bpx, bpy, bvx, bvy, asVector, isInfinite) -> Point
Line.side(px, py, vx, vy, x, y, asVector) -> Number(1 || 0 || -1)
Line.distance(px, py, vx, vy, x, y, asVector) -> Number(length)

###



@Line = class Line

	constructor: (arg0, arg1, arg2, arg3, arg4) ->

		@observers = []

		asVector = false

		if arguments.length >= 4
			@px = arg0
			@py = arg1
			@vx = arg2
			@vy = arg3
			asVector = arg4
		else
			this.px = arg0.x; this.py = arg0.y;
			this.vx = arg1.x; this.vy = arg1.y;
			asVector = arg2;
		
		unless asVector
			@vx -= @px
			@vy -= @py;

	toString: -> "{px:#{@px},py:#{@py},vx:#{@vx},vy:#{@vy}}"
	toArray: -> [@px, @py, @vx, @vy]
	serialize: -> [@px, @py, @vx, @vy]

	@getter 'clone', -> new Line(@)

	update: -> @observers.forEach (fn) -> fn()

	@property 'point',
		get: -> new Point(@px, @py)
		set: (point) -> 
			@px = point.x
			@py = point.y
			@update()

	@property 'p', {get: (-> @point), set: ((p) -> @point = p)}

	@property 'vector',
		get: -> new Point(@vx, @vy)
		set: (point) -> 
			@vx = point.x
			@vy = point.y
			@update()

	@property 'v', {get: (-> @vector), set: ((v) -> @vector = v)}

	@property 'length',
		get: -> @vector.length
		set: (length) ->
			vector = this.vector
			vector.length = length
			@vector = vector

	@property 'l', {get: (-> @length), set: ((l) -> @length = l)}

	intersects: (line, isInfinite = false) -> 
		Line.intersects(
			@px, @py, @vx, @vy,
			line.px, line.py, line.vx, line.vy,
			true, isInfinite
		)                      

	side: (point) -> Line.side(@px, @py, @vx, @vy, point.x, point.y, true)

	distance: (point) -> Math.abs(Line.distance(@px, @py, @vx, @vy, point.x, point.y, true))



	@intersects: (apx, apy, avx, avy, bpx, bpy, bvx, bvy, asVector, isInfinite) ->

		unless asVector 
			avx -= apx
			avy -= apy
			bvx -= bpx
			bvy -= bpy

		cross = bvy * avx - bvx * avy

		if cross isnt 0
			dx = apx - bpx
			dy = apy - bpy
			ta = (bvx * dy - bvy * dx) / cross
			tb = (avx * dy - avy * dx) / cross
			if (isInfinite || 0 <= ta && ta <= 1) and (isInfinite || 0 <= tb && tb <= 1)
				return new Point( apx + ta * avx, apy + ta * avy )

		return false


	@side: (px, py, vx, vy, x, y, asVector) ->
		unless asVector 
			vx -= px
			vy -= py

		v2x = x - px
		v2y = y - py
		ccw = v2x * vy - v2y * vx
		if ccw is 0
			ccw = v2x * vx + v2y * vy;
			if  ccw > 0
				v2x -= vx
				v2y -= vy
				ccw = v2x * vx + v2y * vy
				if ccw < 0
					ccw = 0;

		return if ccw < 0 then -1 
		else if ccw > 0 then 1 
		else 0
	
	@distance = (px, py, vx, vy, x, y, asVector) ->
		unless asVector 
			vx -= px
			vy -= py
		m = vy / vx 
		b = py - m * px
		return (y - (m * x) - b) / Math.sqrt(m * m + 1)



