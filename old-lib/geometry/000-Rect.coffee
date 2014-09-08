###

	Rect (2d)
	see: https://github.com/paperjs/paper.js/blob/master/src/basic/Matrix.js  
	
	new Rect(x, y, w, h || {x,y}, {w,h} || {from{x,y}, to{x,y}})
	.tolerance = Number 
	.set(x, y, w, h, silent)
	.clone -> new Rect(this)
	.equals(rect) -> Boolean()
	.toString() -> '[x,y,w,h]'
	.serialize() -> [x,y,w,h]
	.point = Point()
	.size = Point()
	.left = Number // not observed
	.top = Number // not observed
	.right = Number
	.bottom = Number
	.centerX = Number
	.centerY = Number
	.center = Point
	.tl -> Point
	.tr -> Point
	.bl -> Point
	.br -> Point
	.lc -> Point
	.rc -> Point
	.tc -> Point
	.bc -> Point
	.area -> Number
	.empty -> Boolean
	.containsPoint(Point) -> Boolean
	.containsRect(Rect) -> Boolean
	.contains(Rect||Point) -> Boolean
	.intersects(Rect) -> Boolean
	.touches(Rect) -> Boolean
	.intersect(Rect) -> new Rect()
	.unite(Rect) -> new Rect()
	.include(Point) -> new Rect()
	.expand(Point(size)) -> new Rect()
	.scale(x[, y]) -> new Rect()

###

@Rect = class Rect

	constructor: (x, y, w, h) ->

		@observers = []
		@tolerance = 0.1

		t = typeof x

		if t is 'number'
			@x = x
			@y = y
			@w = w
			@h = h
		else if t is 'undefined' or x is null
			@x = @y = @w = @h = 0
		else if arguments.length is 1
			if Array.isArray(x)
				@x = x[0]
				@y = x[1]
				@w = x[2]
				@h = x[3]
			else if x.x? or x.w?
				@x = x.x || 0
				@y = x.y || 0
				@w = x.w || 0
				@h = x.h || 0
			else if x.from?.x? and x.to?.x?
				@x = Math.min(x.from.x, x.to.x) 
				@y = Math.min(x.from.y, x.to.y)
				@w = Math.abs(x.from.x - x.to.x)
				@h = Math.abs(x.from.y - x.to.y)
		return @

	toString: -> "[#{@x}, #{@y}, #{@w}, #{@h}]"
	serialize: -> [@x, @y, @w, @h]
	toArray: -> [@x, @y, @w, @h]

	@getter 'clone', -> new Rect(@x, @y, @w, @h)

	set: (x, y, w, h, silent) ->
		@x = x 
		@y = y
		@w = w
		@h = h
		unless silent then @update()
		return @

	update: -> @observers.forEach (fn) -> fn()

	equals: (rect) -> 
		if rect.x - this.x < this.tolerance 
			if rect.y - this.y < this.tolerance
				if rect.w - this.w < this.tolerance 
					if rect.h - this.h < this.tolerance
						return true
		return false

	@property 'point',
		get: -> new Point(@x, @y)
		set: (point) -> @set(point.x, point.y, @w, @h)

	@property 'size',
		get: -> new Point(@w, @h)
		set: (size) ->
			if @fixH then @x += (@w - size.x) * @fixX
			if @fixY then @y += (@h - size.y) * @fixY
			@w = size.x
			@h = size.y
			@fixW = true
			@fixH = true

	@property 'left',
		get: -> @x
		set: (x) -> 
			unless @fixW then @w -= x - @x
			@x = x
			@fixW = false

	@property 'top',
		get: -> @y
		set: (y) ->
			unless @fixH then @h -= y - @y
			@y = y
			@fixY = false

	@property 'right',
		get: -> @x + @w
		set: (x) ->
			unless @fixX then @fixW = false
			if @fixW then @x = x - @w
			else @w = x - @x
			@fixX = true

	@property 'bottom',
		get: -> @y + @h
		set: (y) ->
			unless @fixY then @fixH = false
			if @fixH then @y = y - @h
			else @h = y - @y
			@fixY = true

	@property 'centerX',
		get: -> @x + @w/2
		set: (x) -> @x = x - @w/2

	@property 'centerY',
		get: -> @y + @h/2
		set: (y) -> @y = y - @h/2

	@property 'center',
		get: -> new Point(@centerX, @centerY)
		set: (point) ->
			@centerX = point.x
			@centerY = point.y

	@getter 'tl', -> new Point(@left, @top)
	@getter 'tr', -> new Point(@right, @top)
	@getter 'bl', -> new Point(@left, @bottom)
	@getter 'br', -> new Point(@right, @bottom)

	@getter 'lc', -> new Point(@left, @centerY)
	@getter 'rc', -> new Point(@right, @centerY)
	@getter 'tc', -> new Point(@centerX, @top)
	@getter 'bc', -> new Point(@centerX, @bottom)

	@getter 'area', -> @w * @h

	@getter 'empty', -> @w is 0 or @h is 0

	@property 'perimeter', ->
		get: -> 2*(@w + @h)
		set: -> throw new Error("Rect::perimeter [NYI]")

	@property 'area', 
		get: -> @w * @h
		set: (area) -> 
			r = @expand(new Point(area))
			@set(r.x, r.y, r.w, r.h)

	@getter 'quadrants', ->
		quarter = new Point(@w/2, @h/2)
		return [ new Rect(@tl, quarter), new Rect(@tc, quarter), 
		         new Rect(@lc, quarter), new Rect(@center, quarter) ]

	@getter 'vertex', -> 
		(tl = new Vertex(@tl))
			.link(new Vertex(@tr))
			.link(new Vertex(@br))
			.link(new Vertex(@bl)).link(tl)
		

	containsPoint: (point) ->
		if point.x >= @left and point.y >= @top
			if point.x <= @right and point.y <= @bottom
				return true
		return false

	containsRect: (rect) ->
		if rect.left >= @left and rect.top >= @top
			if rect.right <= @right and rect.bottom <= @bottom
				return true
		return false

	contains: (arg) -> if arg?.w? then @containsRect(arg) else @containsPoint(arg)

	intersects: (rect) -> 
		if rect.right > @left and rect.bottom > @top
			if rect.left < @right and rect.top < @bottom
				return true
		return false

	touches: (rect) ->
		if rect.right >= @left and rect.bottom >= @top
			if rect.left <= @right and rect.top <= @bottom
				return true
		return false

	intersect: (rect) ->
		left = Math.max(@left, rect.left)
		top = Math.max(@top, rect.top)
		right = Math.min(@right, rect.right)
		bottom = Math.min(@bottom, rect.bottom)
		return new Rect({from: {x: left, y: top}, to: {x: left, y: bottom}})

	unite: (rect) ->
		left = Math.min(@left, rect.left)
		top = Math.min(@top, rect.left)
		right = Math.max(@right, rect.right)
		bottom = Math.max(@bottom, rect.bottom)
		return new Rect({from: {x:left, y: top}, to: {x: right, y: bottom}})

	include: (point) ->
		left = Math.min(@left, point.x)
		top = Math.min(@top, point.y)
		right = Math.max(@right, point.x)
		bottom = Math.max(@bottom, point.y)
		return new Rect({from: {x: left, y: top}, to: {x: right, y: bottom}})


	expand: (size) -> 
		new Rect(@x - size.x/2, @y - size.y/2, @w + size.y, @h + size.y) 
	
	scale: (x, y = x) -> 
		@expand(new Point(@w*x - @w, @h*y - @h))





