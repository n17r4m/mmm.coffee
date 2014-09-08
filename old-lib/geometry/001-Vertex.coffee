
@Vertex = class Vertex extends Point

	constructor: (p = new Point(0,0), y = 0, @prev = null, @next = null) ->
		@ring = [@]
		super(p, y)

	link: (vertex, next = true) ->

		vertex.ring = @ring

		if @ring.indexOf(vertex) is -1 
			@ring.push vertex

		if next
			@next = vertex
			vertex.prev = @

		else
			@prev = vertex
			vertex.next = @

		return vertex


	unlink: (relink = null) ->

		if @ngon is 3 
			throw new Error("Cannot remove, need at least 3 points")
		else
			@ring.splice(@ring.indexOf(@), 1)
			@prev.next = @next
			@next.prev = @prev
				
	@getter 'clone', ->
		clones = []; @forEach (v) -> clones.push new Vertex(v)
		return Vertex.link(clones)

	@getter 'length', -> @ring.length

	@getter 'convex', ->

		[p, n] = [@prev, @next]
		signed_area = p.x*-@y + @x*-n.y + n.x*-p.y - @x*-p.y - n.x*-@y - p.x*-n.y

		return signed_area < 0

	@getter 'concave', -> !@convex


	first: (fn, ctx = @, ccw = false) ->
		cursor = initial = @ring[0]
		unless fn then return cursor
		fn.call(ctx, cursor)
		while (cursor = (
			if ccw then cursor.prev else cursor.next
		)) and cursor isnt initial
			if (ret = fn.call(ctx, cursor))?
				return ret
		

	forEach: (fn, ctx = @, ccw = false) -> 
		cursor = initial = @ring[0]
		fn.call(ctx, cursor)
		while (cursor = (
			if ccw then cursor.prev else cursor.next
		)) and cursor isnt initial
			fn.call(ctx, cursor)

	cw: (fn, ctx = @) -> @forEach(fn, ctx, false)

	circumnavigateCW: (fn, ctx) -> @cw(fn, ctx); fn.call(ctx, @)

	ccw: (fn, ctx = @) -> @forEach(fn, ctx, true)

	circumnavigateCCW: (fn, ctx) -> @ccw(fn, ctx); fn.call(ctx, @)

	toString: -> @toArray().map((v)->"{x:#{v.x},y:#{v.y}}").join(" -> ")

	toArray: (looped = false) -> 
		a = []
		if looped then @cw (vertex) -> a.push(vertex)
		else @forEach (vertex) -> a.push(vertex)
		return a

	toPoint: -> new Point(@)

	@property 'point', {
		get: -> @toPoint()
		set: (p) -> @set(p.x, p.y)		
	}




	@link: (vertexArray) ->
		vertexArray.forEach (v, i, vs) -> v.link(vs[(i+1) % vs.length])
		return vertexArray[0]

	@coords: (coords = [[0,0], [1,0], [1,1]]) -> @link(coords.map (c) -> new Vertex(c))

	@rect: (r = new Rect(0, 0, 1, 1)) -> @link([new Vertex(r.tl), new Vertex(r.tr), new Vertex(r.br), new Vertex(r.bl)])


