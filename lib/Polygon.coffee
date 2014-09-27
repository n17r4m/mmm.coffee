Tuple = require("./Tuple")
Vertex = require("./Vertex")
Line = require("./Line")

module.exports = exports = class Polygon # extends Tuple/Array?
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
		@coordinates.remove(vertex)
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
		@coordinates.insert(cursorIndex, newVertex)
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
		cursor.replace(0, newCoord.toArray())
		# Checking if polygon remains simple """
		unless @simple
			cursor.replace(0, oldCoord.toArray())
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



###
class Triangulate

    """
    Triangulate Class is used for producing a triangulation
    of a simple polygon using Polygon Class.  This is done
    using the 'ear-clipping algorithm'.
    
    Warning:
            Algorithm reduces original polygon set as it
            finds 'ears', so will have to reset it using
            a method if original polygon is required after
            triangulation.
    
    Can initialize with coordinates or a polygon """
    To initialize with polygon use Triangulate([], polygon)
    """

    constructor: (coordinates = [], polygon = null) ->

        @coordinates   = polygon.coordinates if polygon else coordinates
        @polygon       = polygon if polygon else polygon.SimplePolygon(coordinates)
        @triangulation = []


    def reset(self):
        """ Resets to a clockwise orientation using coordinate data."""
        self.triangulation = []
        self.polygon       = polygon.SimplePolygon(self.coordinates, True)

    """ The following are helper functions for triangulation """

    def triangle_by_ear_tip(self, vertice):
        """
        This finds the triangle in the polygon created using the
        vertice argument as the ear-tip.  It returns a triplet
        of coordinates.  The triangle is
        vertice.prev - vertice - vertice.next
        """
        return [vertice.prev.coord, vertice.coord, vertice.next.coord]


    def convert_to_barycentric(self, triangle, cartesian_coord):
        """
        Please consult http://en.wikipedia.org/wiki/Barycentric_coordinate_system
        for further information.  For converted coordinate z = (z1, z2, z3), if
        z1, z2, z3 are all between 0 and 1 then they are inside the inputted
        triangle.  If any are equal to 1 or 0 and the rest are in [0,1] then z
        is on the border of the triangle.  Any above 1 or below 0 means that it
        is outside of the triangle.
        """
        """ The triangle coordinates are [a, b, c] """
        a_x, a_y         = triangle[0][0], triangle[0][1]
        b_x, b_y         = triangle[1][0], triangle[1][1]
        c_x, c_y         = triangle[2][0], triangle[2][1]
        coord_x, coord_y = cartesian_coord[0] , cartesian_coord[1]
        """ We next calculate the determinant of the transformation matrix T """
        det_T = (a_x - c_x)*(b_y - c_y) + (c_x - b_x)*(a_y - c_y)
        """
        Using the determinant, we can now calculate the value of each coordinate
        in the barycentric conversion z.
        """
        z_1 = 1.0*((b_y - c_y)*(coord_x - c_x) + (c_x - b_x)*(coord_y - c_y)) / det_T
        z_2 = 1.0*((c_y - a_y)*(coord_x - c_x) + (a_x - c_x)*(coord_y - c_y)) / det_T
        z_3 = 1.0 - z_1 - z_2

        return (z_1, z_2, z_3)


    def is_coord_in_triangle(self, triangle, coordinate):
        """
        See convert_to_barycentric for more information.
        """
        converted_coord = self.convert_to_barycentric(triangle, coordinate)
        for z_i in converted_coord:
            if z_i <= 0.0 or i >= 1.0:
                return False
        return True


    def is_coord_on_triangle(self, triangle, coordinate):
        """
        See convert_to_barycentric for more information.
        """
        converted_coord = self.convert_to_barycentric(triangle, coordinate)
        border_switch   = False
        for z_i in converted_coord:
            if z_i < 0.0 or z_i > 1.0:
                return False
            if i == 0 or i == 1:
                border_switch = True
        return border_switch


    def share_edge(self, triangleA, triangleB):
        """ Converts triangles to polygons and applys share_edge method """
        pgon_A = polygon.SimplePolygon(triangleA, True)
        pgon_B = polygon.SimplePolygon(triangleB, True)
        return pgon_A.share_edge(pgon_B)


    def no_concave_vertices_in(self, triangle):
        """
        Draws from self.polygon.concave, so all_convex_vertices from Polygon
        must be called first for meaningful result.
        """
        for vertice_coord in self.polygon.concave_vertices:
            if self.is_coord_in_triangle(self, triangle, vertice_coord):
                return False
        return True


    def find_ear(self):
        """
        Finds triangles of polygon where the ear-tip is a convex vertice,
        and checks to see if any concave vertices are inside the triangle.
        If not, it is a valid ear to clip off for triangulation.
        """
        polygon_sides = self.polygon.vertice_number
        cursor        = self.polygon.head

        """ Trivial case where polygon is a triangle:"""
        if polygon_sides == 3:
            triangle = self.triangle_by_ear_tip(cursor)
            return [triangle, cursor.coord]

        self.polygon.all_convex_vertices()

        i = 0
        while i <= polygon_sides + 2:
            if cursor.coord in self.polygon.convex_vertices:
                triangle = self.triangle_by_ear_tip(cursor)
                if self.no_concave_vertices_in(triangle):
                    return [triangle, cursor.coord]
            cursor = cursor.next
            i     += 1
        raise ValueError('Polygon is not simple as no ear was found')


    def triangulate(self):
        """
        Culmination of all of the helper functions, triangulate uses the
        'ear-clipping' algorithm to break apart a simple polygon into
        triangles.
        """
        if self.triangulation:
            raise ValueError('Already triangulated')

        while self.polygon.vertice_number >= 3:
            ear = self.find_ear()
            self.triangulation.append(ear[0])
            self.polygon.remove_vertice(ear[1])

        return self.triangulation

###




