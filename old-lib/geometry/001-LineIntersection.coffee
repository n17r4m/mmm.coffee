arrayInArray = (needle, haystack) ->
	for x, hay of haystack
		###
		found = true
		found = found and n is hay[y] for y, n of needle
		if found then return true		
		###
		if needle.map((a, i) -> a is hay[i])
			       .reduce(((found,eq)-> found and eq), true)
			return true
	return false


@LineIntersection = class LineIntersection

	""" Line Intersection Class. initiates with lines
		[(x1,y1), (x2, y2)] to be converted to labeled
		endpoints [(x,y), label].  Main test for gen.
		line intersection uses sweep-line algorithm.
	"""

	constructor: (data) ->
		@count    = 0
		@lines    = {}
		@sweeps   = []
		@tested   = []
		@addLines(data)

	################
	#Data Properties
	################

	addLine: (line) ->
		@sweeps.push([line[0], @count.toString()])
		@sweeps.push([line[1], @count.toString()])
		@lines[@count.toString()] = line
		@count += 1


	addLines: (array) ->
		for i, line of array
			@addLine(line)


	sortSweeps: ->
		@sweeps.sort (a,b) -> not a[1] is b[1] and b[0][0] - a[0][0]
		#  key = lambda x: (x[0][0], not x[1]))

	###################
	#Line Intersections
	###################

	intersectTwo: (lineA, lineB) ->
		""" It suffices to check if two points are on
			opposite sides of a line segment.  To do
			this we compute the cross products of
			lineA and the endpoints of lineB and take
			their product.  The product will be negative
			if and only if they intersect.
		"""
		[P, Q] 	  = [lineB[0], lineB[1]]
		xproductP = (1.0*(lineA[1][0] - lineA[0][0])*(-P[1] + lineA[1][1]) -
					 1.0*(lineA[0][1] - lineA[1][1])*(P[0] - lineA[1][0]))
		xproductQ = (1.0*(lineA[1][0] - lineA[0][0])*(-Q[1] + lineA[1][1]) -
					 1.0*(lineA[0][1] - lineA[1][1])*(Q[0] - lineA[1][0]))

		return if xproductP * xproductQ < 0 then true else false


	checkIntersection: ->

		unless @sweeps
			return false

		@sortSweeps()

		@tested = []
		events = []
		i = 0

		while i < @sweeps.length
			newvalue = @sweeps[i][1]

			unless events.length
				events.push(newvalue)
			else if newvalue in events
				events.splice(events.indexOf(newvalue), 1)
			else
				for j, event of events
					if arrayInArray([event, newvalue], @tested)
						continue
					test = @intersectTwo(@lines[event],
					                     @lines[newvalue])
					if test
						return true
					else
						@tested.push([event, newvalue])
			i += 1
		return false


	##############
	#Miscellaneous
	##############

	toString: ->
		return "Line Intersection for lines #{@lines}" 



