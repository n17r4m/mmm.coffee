Vertex = require("./Vertex")
Line = require("./Line")

module.exports = exports = class Polygon	
	###
	Sniped from http://github.com/jmelcher86/Geometry/
	Thanks Jonathan! 
	--------------------------------------------------
	
	Initialization of Polygon instance
	
	Warning:    all coordinates are assumed to be (x,y)
		          Cartesian tuples.  (0,0) is taken to be
		          the origin, so coordinates are NOT in
		          line with computer coordinate standards
		          of starting at the top left of the screen
		          
		          If you need to manipulate the Polygon into
		          n-space or change the coordinate system, 
		          please wrao it in a Transformation
	"""
	###
	constructor: (coordinates, orientation = true) ->
		###
		!!! orientation is true for clockwise, false for ccw. !!!
		
		coordinates is a list of tuples denoting coordinates in
		the cartesian plane.
		The coordinates need to be listed in order of connection.
		Also, coordinates[i+1] is clockwise from coordinates[i].

		@orientation/@head require methods for init as
		seen below.  Note that @head will become a vertice
		with data from coordinates[0].

		@convex/concaveVertices are populated after some
		later methods, as with lineSegments.
		###
		@coordinates     = coordinates
		@vertexNumber    = @countVertices()
		@orientation     = null
		@lineSegments    = null
		@convexVertices  = []
		@concaveVertices = []

		# Orientation initialization
		@head = @orientate(coordinates, orientation)

	###
	The following are methods for working with the vertices of
	the polygon object.
	###

	orientate: (coordinates, clockwise = false) ->
		###
		This method creates a list of vertices with data from
		coordinates.  It then iterates over the list assigning
		pointers to the appropriate vertices (clockwise = next),
		finally returning the head of the polygon linked list.
		This is the meat behind initializing the Polygon Class.
		Note: you can also re-orientate the polygon using this.
		###
		# Some Exception handling for initialization is done here. """
		if coordinates.length < 3
			throw new TypeError('Polygons require at least 3 vertices.')

		for coord, i of coordinates
			if coordinates.lastIndexOf(coord) != i
				throw new TypeError('Multiple vertices at same location')

		vertices = new Vertex(coord) for coord of coordinates
		polySides = vertices.length
		orientVar = if clockwise then -1 else 1

		for i in [0...polySides]
			vertices[i % polySides].prev = vertices[(i+orientVar) % polySides]
			vertices[i % polySides].next = vertices[(i-orientVar) % polySides]

		# @orientation is set to clockwise argument and this.head
		# becomes the first vertice in the list.
		@orientation = clockwise
		return vertices[0]

	countVertices: -> @coordinates.length

	coordinateInPolygon: (coord) -> 
		@coordinates.some (vertex) -> 
			vertex.equals(coord)
	
	findVertex: (coord, mustExist = true) ->
		unless @coordinateInPolygon(oldCoord)
			if mustExist then throw new ReferenceError('Vertex not in polygon')	
			else return false
		cursor = @head
		while not cursor.equals(coord)
			cursor = cursor.next
		return cursor

	removeVertex: (coord) ->
		###
		Conditions where removing is impossible:
		- vertice coordinate is not in Polygon
		- polygon has 3 sides (2 sides is not a polygon)
		###
		
		if @vertexNumber is 3
			throw new RangeError('Polygons must have at least three vertices')

		###
		We change the vertices adjacent to connect with
		each other, and remove coordinate from @coordinates, updating
		@vertice_number as well.
		###
		vertex = @findVertex(coord)
		vertex.prev.next = vertex.next
		vertex.next.prev = vertex.prev
		# Dealing with case where removed vertex was @head 
		if vertex is @head
			@head = vertex.next
		# Tidying up and updating polygon attributes
		@coordinates.splice(@coordinates.indexOf(vertex), 1)
		@vertexNumber-= 1



	insertVertex: (insertionPoint, coord) ->
		###
		Similar method to removeVertex.  Locates insertion_point and
		initializes a new vertice with vertice_coord data.  We change
		the appropriate vertice connections so that the new vertice
		comes before the insertionPoint in the polygon.  Updates
		polygon, and then checks if it remains simple.  If not, applies
		@removeVertex immediately.
		###

		# Updating vertice connections
		cursor                           = @findVertex(insertionPoint)
		newVertex                        = new Vertex(coord)
		[newVertex.prev, newVertex.next] = [cursor.prev, cursor]
		[cursor.prev.next, cursor.prev]  = [newVertex, newVertex]
		
		# Updating polygon data
		cursorIndex = @coordinates.indexOf(cursor)
		@coordinates.splice(cursorIndex, 0, newVertex)
		@verticeNumber+= 1
		
		# Checking if polygon remains simple
		unless @simple
			@remove(coord)
			throw new RangeError('Resultant polygon is not simple')
		
		# Addressing case where cursor was @head 
		if cursorIndex is 0
			@head = newVertex
		@

	moveVertice: (oldCoord, newCoord) ->
		###
		Identical traversal as insert/remove_vertice.  Locates vertex,
		and updates its coordinate and @coordinates.  It then checks
		if new polygon is simple, and will revert if not and throw an Error
		###

		# ensure we are working with copys and are of Vertex types
		[oldCoord, newCoord] = [new Vertex(oldCoord), new Vertex(newCoord)]		
		# Updating coordinates		
		cursor = @findVertex(oldCoord)
		cursor.splice.apply(cursor, [0, cursor.length].concat(newCoord.toArray()))
		# Checking if polygon remains simple """
		unless @simple
			cursor.splice.apply(cursor, [0, cursor.length].concat(oldCoord.toArray()))
			throw new RangeError('Resultant polygon is not simple')
		@


	updateVertex: (oldCoord, newCoord) ->
		###
		Search for vertice in polygon, then updates it, checks if
		resultant polygon is still simple.  If not, reverts and
		throws an error ValueError.
		###
		@moveVertex(oldCoord, newCoord)


	scaleVertexFromPoint:(vertex, point = [0,0], scale = 1) ->
		###
		Returns cartesian coordinate tuple resulting from scaling
		a vertice away from a point given a scale.  This is useful
		when the polygon centroid is not 0, as the vertice will need
		to scale away from the centroid instead of (0,0).  This is
		ultimately used in scaling an entire polygon.  This will be
		done by moving the point over so that the centroid would be
		(0,0), scaling, then bringing it back.
		###
		x = vertex[0] - point[0]
		y = vertex[1] - point[1]
		return new Point(x*scale + point[0], y*scale + point[1])

	rotateVertexAboutPoint: (vertex, point, radians) -> 
		vertex.rotate(radians, point)

	translateVertex: (vertex, vector) -> vertex.add(vector)
	
	###
	The following methods are for changing the polygon as a whole.
	###

	rotatePolygon: (angle, radians = false, clockwise = @orientation) ->
		###
		Rotates polygon by angle argument.  Should make it possible
		to input radians instead.  This works by applying the rotation
		to each coordinate and initializing a new polygon class to return.
		###
		firstVertex  = @head
		newCoords    = [@rotateVerticeAboutPoint(firstVertex, centroid, angle)]
		centroid     = @centroid()
		angle        = if radians then angle else Math.radians(angle)
		sentinel     = firstVertex
		# Traversal
		firstVertex = firstVertex.next
		while firstVertex isnt sentinel
			###
			If oriented CCW then add in before previous coordinate.
			Initialization list must be in clockwise order.
			###
			if @orientation # clockwise
				  newCoords.push(@rotateVertexAboutPoint(firstVertex, centroid, angle))
			else # counter-clockwise
				  newCoords.shift(@rotateVerticeAboutPoint(firstVertex, centroid, angle))
			firstVertex = firstVertex.next
		new @constructor(newCoords, clockwise)


	translatePolygon: (translation, clockwise = @orientation) ->
		###
		Follows similar form to rotatePolygon.  Traverses polygon
		and creates new initialization list by translating each
		coordinate.  It then uses this list to return a new polygon.
		###
		firstVertex = @head
		newCoords   = [@translateVertex(firstVertex, translation)]
		sentinel    = firstVertex

		# Traversal
		firstVertex = firstVertex.next
		while firestVertex isnt sentinel
			###
			If oriented CCW then add in before previous coordinate.
			Initialization list must be in clockwise order.
			###		
			if @orientation
		    newCoords.push(@translateVertex(firstVertex, translation))
			else
		    newCoords.shift(@translateVertex(firstVertex, translation))
			firstVertex = firstVertex.next
		new @constructor(newCoords, clockwise)


	scalePolygon: (scale, clockwise = @orientation) ->
		###
		Similar to translate_polygon, traverses polygon creating a
		new coordinate list to initialize a scaled polygon.

		We are not allowing degenerate polygons.  Due to computer
		restrictions, may have to change this to limit lower size.
		Could use largest distance between two vertices as a judge.
		###
		if scale <= 0
			throw new RangeError('Resultant polygon would be too small')

		firstVertex = @head
		newCoords   = [@scaleVerticeFromPoint(firstVertex, centroid, scale)]
		centroid    = @centroid()
		sentinel    = firstVertex

		# Traversal
		firstVertex = firstVertex.next
		while firstVertex isnt sentinel
			if @orientation
				newCoords.push(@scaleVertexFromPoint(firstVertex, centroid, scale))
			else
				new_coords.shift(@scaleVertexFromPoint(firstVertex, centroid, scale))
			firstVertex = firstVertex.next
		new @constructor(new_coords, clockwise)

	###
	The following methods have to do with treating the edges of the
	polygon as line segments.
	###

	@getter 'edges', ->
		###
		Returns list of line segments
		Traverses through linked list, adding line segments until
		reaching sentinel vertice.
		###
		[firstVertex, secondCertex] = [@head, @head.next]
		sentinel      = firstVertex
		@lineSegments = [new Line(firstVertex, secondVertex)]

		[firstVertex, secondVertex] = [second_vertice, secondVertex.next]
		# Traversal
		while firstVertex isnt sentinel
			@lineSegments.push(new Line(firstVertex, secondVertex))
			[firstVertex, secondVertex]  = [secondVertex, secondVertex.next]
		# Assigning list of line segments to polygon attributes
		@lineSegments = lineSegments
		###
		List is used later for determining if any lines intersect
		and so is returned.
		###
		@lineSegments


	@getter 'perimeter', ->
		@edges.reduce(((perimeter, line) -> perimeter + line.dist()), 0)

	sharesEdgeWith: (polygon) ->
		###
		Method for determining whether two polygons share
		a particular edge.  Brute force, need to look up
		a nicer way to do this.
		###
		@edges.some (edge1) -> polygon.edges.some (edge2) -> edge1.equals(edge2)


	@getter 'simple', -> not Line.intersection(@edges)

	###
	The following methods have to do with the area of the
	simple polygon.
	###

	xVertex: (x) -> 
		# Formula to calculate each partial area as mentioned below
		(x[0][0]*x[1][1] - x[1][0]*x[0][1])
	

	@getter 'signedArea', ->
		###
		Calculates total signed area of polygon.
		Will be negative if oriented clockwise, and positive if ccw.
		Traverses polygon as in get_edges, calculating what it needs
		from each vertice.  For details on the algorithm, see
		http://www.mathopenref.com/coordpolygonarea2.html.  The area
		found to the left of the line-sigment is calculated and working
		around the polygon, we end up with the total area.  It is very
		important that you cycle in one direction(say cyclically) and
		that it is a simple closed polygon in order for this to work.
		###
		[firstVertex, secondVertex] = [@head, @head.next]
		sentinel                    = firstVertex

		area                        = @xVertex([firstVertex, secondVertex])
		[firstVertex, secondVertex] = [secondVertex, secondVertex.next]

		while firstVertex isnt sentinel
		  area += @xVertex([firstVertex, secondVertex])
			[firstVertex, secondVertex] = [secondVertex, secondVertex.next]

		area/2


	@getter 'area', ->
		# Calculates total absolute area of polygon. 
		# It is the invariant from the signed area.
		return Math.abs(@signedArea)


	###
	The following methods have to do with the
	properties of the simple polygon.
	###

	@getter 'centroid', ->
		###
		Calculates centroid based on formulae found at
		http://en.wikipedia.org/wiki/Centroid
		Again, we traverse through the polygon as before
		with a sentinel, and make calculations at each
		point in order to combine them to find the centroid,
		which ends up being a sort of weighted average of each
		of the calculations (see the wiki).
		###
		signedArea                  = @signedArea
		[firstVertex, secondVertex] = [@head, @head.next]
		sentinel                    = firstVertex

		# First calculations:
		centroidX = (firstVertex[0] + secondVertex[0]) * @xVertex([firstVertex, secondVertex])
		centroidY = (firstVertex[1] + secondVertex[1]) * @xVertex([firstVertex, secondVertex])

		[firstVertex, secondVertex] = [secondVertex, secondVertex.next]

		# Traversal
		while firstVertex isnt sentinel
			centroidX += (firstVertex[0] + secondVertex[0]) * @xVertex([firstVertex, secondVertex])
			centroidY += (firstVertex[1] + secondVertex[1]) * @xVertex([firstVertex, secondVertex])
			[firstVertex, secondVertex] = [secondVertex, secondVertex.next]

		new Point((1/(6*signedArea))*centroidX, (1/(6*signedArea))*centroidY)

	verticeIsConvex: (vertex) ->
		###
		Checks if angle made by vertex.prev - vertex - vertex.next
		is convex relative to polygon.  Uses sign of triple product
		of vectors which gives orientation.  CCW = +, CW = -.
		If same orientation as cycling then convex, else concave.
		eg. If vertices are cycling clockwise and signed_area is
		negative then returns True.  Signed_area = 0 happens when
		triangle is degenerate.  For more information look up
		triple products and signed areas of polygons.
		This calculates the signed area of the triangle created by
		the above sequence, and checks if it matches the orientation
		of the polygon.

		We will use x, y, z as variables for space issues. They
		correspond to the coordinates of the previous, vertice_to_test,
		and the next vertice respectively.
		###

		x = vertex.prev
		y = vertex
		z = vertex.next

		signedArea = (x[0]*y[1] + y[0]*z[1] + z[0]*x[1] -
		              y[0]*x[1] - z[0]*y[1] - x[0]*z[1])

		if @orientation
			if signedArea < 0 then true else false
		else
			if signedArea > 0 then true else false

	polygonIsConvex: ->
		# Applies allConvexVertices and analyzes
		@allConvexVertices()
		if not @concaveVertices then true else false


	allConvexVertices: ->
		###
		Traverses through polygon using a sentinel to stop,
		applying vertice_is_convex at each vertice.
		###
		# Resetting @convex/@concave 
		@convexVertices  = []
		@concaveVertices = []

		sentinal = cursor = @head

		if @vertexIsConvex(cursor) then @convexVertices.push(cursor)
		else @concaveVertices.append(cursor)

		cursor = cursor.next
		while cursor isnt sentinel
			if @verticeIsConvex(cursor) then @convexVertices.push(cursor)
			else @concaveVertices.push(cursor)
			cursor = cursor.next


	toString: -> "#{@vertexNumber}-gon at {@head}"



