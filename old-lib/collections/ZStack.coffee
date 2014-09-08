
# Z-ordering Stack

@ZStack = class ZStack

	constructor: (value = null) ->

		@value = null
		@top = @
		@bottom = @
		@above = null
		@below = null
		@observers = []
		@cache = []

		if value?
			@add(value)

		return @

	valueOf: -> @value

	toString: -> "#{@value}"

	observe: (fn) -> 
		@stack(); #reset cache
		@observers.push(fn); 
		return @

	notify: (value, z) -> 
		@observers.forEach (fn) -> 
			fn.call(null, value, z)
		return @

	invalidate: ->
		before = @cache
		after = @stack()
		for i, node of after
			if before[i] isnt node
				@notify(node, i)
		return @

	add: (value) ->
		
		unless @value
			@value = value
			return @
		
		@top.above = new ZStack(value)
		@top.above.below = @top
		@top.above.bottom = @bottom
		@top = @top.above
		@shallowWalk (v, n) -> n.top = @top
		@invalidate()
		return @

	remove: (value) ->
		if node = @deepFind(value)
			if node.above? then node.above.below = node.below || null
			if node.below? then node.below.above = node.above || null
			if node is node.top and node is node.bottom
				node.value = null
			else
				if node is node.top
					top = node.below
					node.shallowWalk (v, n) -> n.top = top
				if node.bottom is node
					bottom = node.above
					node.shallowWalk (v, n) -> n.bottom = bottom
			@invalidate()
		return @


	toBottom: (value) ->
		unless node = @deepFind(value)
			throw new Error "Value '#{value}' not found in ZStack"

		if node.above? then node.above.below = node.below || null
		if node.below? then node.below.above = node.above || null

		last = node.bottom
		last.below = node
		node.above = last
		node.below = null
		node.shallowWalk (v, n) -> n.bottom = node
		@invalidate()
		return @
				
	shallowFind: (value) ->
		cursor = @bottom
		while cursor?.value?
			if cursor.value is value
				return cursor
			cursor = cursor.above
		return false

	shallowWalk: (fn, ctx = @) ->
		cursor = @bottom
		while cursor?.value?
			unless cursor.value.shallowWalk?
				fn.call(ctx, cursor.value, cursor)
			cursor = cursor.above
		return ctx

	deepFind: (value) ->
		cursor = @bottom
		while cursor?.value?
			if cursor.value.deepFind?
				if found = cursor.value.deepFind(value)
					return found
			else if cursor.value is value
				return cursor
			cursor = cursor.above
		return false

	deepWalk: (fn, ctx = @) ->
		cursor = @bottom
		while cursor?.value?
			if cursor.value.deepWalk? 
				cursor.value.deepWalk(fn, ctx)
			else 
				fn.call(ctx, cursor.value, cursor)
			cursor = cursor.above
		return ctx

	stack: -> @cache = @deepWalk(((value) -> @push(value)), [])

	zOf: (item) -> @stack().indexOf(item.valueOf())

	test: -> 
		layers = new ZStack()

		layers.add(base = new ZStack())
		layers.add(ground = new ZStack())
		layers.add(features = new ZStack())

		base.add(new Polygon("House"))
		base.add(new Polygon("Garage"))
		base.add(new Polygon("Sidewalk"))
		base.add(new Polygon("Driveway"))

		ground.add(new Polygon("Lawn1"))
		ground.add(new Polygon("Lawn2"))
		ground.add(new Polygon("Gravel1"))
		ground.add(gravel2 = new Point("Gravel2"))
		ground.add(new Polygon("Garden"))


		features.add(new Point("Tree"))
		features.add(new Point("Shrub1"))
		features.add(new Point("Shrub2"))
		features.add(pond = new Polygon("Pond"))
		features.add(fountain = new Point("Fountain"))

		layers.observe (v, z) -> console.info "#{v.id} is now z-index: #{z}" 

		console.info "Removing Gravel2"
		layers.remove(gravel2)

		###
			Removing Gravel2
			Garden is now z-index: 7
			Tree is now z-index: 8
			Shrub1 is now z-index: 9
			Shrub2 is now z-index: 10
			Pond is now z-index: 11
			Fountain is now z-index: 12
		###


		console.info "Moving Pond to bottom"
		layers.toBottom(pond)

		###
			Moving Pond to bottom
			Pond is now z-index: 8
			Tree is now z-index: 9
			Shrub1 is now z-index: 10
			Shrub2 is now z-index: 11
		###

		console.info "stack", layers.stack().map (v) -> v.id

		###
			[ 'House',
			'Garage',
			'Sidewalk',
			'Driveway',
			'Lawn1',
			'Lawn2',
			'Gravel1',
			'Garden',
			'Pond',
			'Tree',
			'Shrub1',
			'Shrub2',
			'Fountain' ]
		###

		console.info "fountain z-index:", layers.zOf(fountain)

		###
			fountain z-index: 12
		###

		console.info "pond z-index:", layers.zOf(pond)

		###
			pond z-index: 8
		###


