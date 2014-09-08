
@Polygon = class Polygon extends Vertex

	constructor: (vertex = Vertex.rect(), y = 0, init = true) ->

		if Array.isArray(vertex)
			if Array.isArray(vertex[0])
				vertex = Vertex.link(vertex.map((p) -> new Vertex(p[0], p[1])))
			else
				if vertex[0]?.x?
					vertex = Vertex.link(vertex.map((p) -> new Vertex(p)))
				else if typeof vertex[0] is 'number'
					vs = []
					for i in vertex by 2
						vs.push(new Vertex(vertex[i], vertex[i+1]))
					vertex = Vertex.link(vs)

		super(vertex, y, vertex.prev, vertex.next)
		if(init)
			@ring = vertex.ring
			@ring = @toArray().map (v) -> new Polygon(v, null, false)
			return Polygon.link(@ring)

	triangulate: ->
		@triangulation = new Triangulate(@)
		@triangulation.triangulate()

	@getter 'clone', -> new Polygon(@)
	###
		return @ring
			.map( (v) -> new Polygon(v) )
			.reduce(((vs, v) -> 
				vs.link(v); v), @ring[@ring.length-1])
	###

	@getter 'ngon', -> @length

	###
	@getter 'area', ->
		px = py = 0
		@circumnavigateCW (vertex) ->
			px += vertex.x * vertex.next.y
			py += vertex.y * vertex.next.x
		return Math.abs (px-py) / 2
	###


	@getter 'space', -> 
		[first, second] = [@, @next]
		sentinel = first
		area = first._sa(second)
		[first, second] = [second, first.next]
		while first isnt sentinel
			area += first._sa(second)
			[first, second] = [second, first.next]
		return (1/2) * area		

	@getter 'area', -> Math.abs(@space)


	@getter 'lines', ->
		lines = []
		@forEach (vertex) -> 
			lines.push(new Line(vertex, vertex.next))
		return lines

	@getter 'perimeter', -> 
		@lines.reduce(((sum, line) -> 
			sum + line.length), 0)

	@getter 'border', ->
		[first, second] = [@, @next]
		sentinel = first
		border = [first.slopeTo(second)]

		[first, second] = [second, first.next]
		while first isnt sentinel
			border.push first.slopeTo(second)
			[first, second] = [second, first.next]
		
		return border

	@getter 'convexes', -> @toArray().filter (v) -> v.convex

	@getter 'concaves', -> @toArray().filter (v) -> v.concave

	@getter 'edges', ->
		first    	= 	@first()
		second   	= 	first.next
		sentinel 	= 	first
		lines       =	[]
		push = (f, s) -> lines.push([f.point.toArray(), s.point.toArray()])		

		push(first, second)

		[first, second] = [second, first.next]
		while first isnt sentinel
			push(first, second)
			[first, second] = [second, first.next]
		return lines

	isSimple: ->
		not (new LineIntersection(@edges)).checkIntersection()

	search: (point, ccw = true) ->
		point = new Point(point)
		return @first (v) -> 
			if point.equals(v) then return v

	remove: (point, ccw = true) ->
		if v = @search(point, ccw)
			v.unlink()

	_sa: (v) -> @x*-v.y - v.x*-@y


	@getter 'centroid', ->
		[first, second] = [@, @next]
		sentinel = first
		space = @space

		sa = first._sa(second)
		cx = (first.x + second.x) * sa
		cy = (first.y + second.y) * sa

		@cw (v) ->
			sa = v._sa(v.next)
			cx += (v.x + v.next.x) * sa
			cy += (v.y + v.next.y) * sa

		return new Point(
			(1/(6*space))*cx, 
			(1/(6*space))*cy
		)

	

	@rect: (rect = new Rect()) -> 
		new Polygon(Vertex.rect(rect))

