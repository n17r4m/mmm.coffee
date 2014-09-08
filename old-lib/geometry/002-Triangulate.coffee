
coord = (vertex) -> 
	(new Point(vertex)).toArray()

arrayInArray = (needle, haystack) ->
	for x, hay of haystack
		if needle.map((a, i) -> a is hay[i])
		         .reduce(((found,eq)-> found and eq), true)
			return true
	return false



@Triangulate = class Triangulate 
	""" Triangulate Class for Simple Polygons in
		Polygon Class.
		Note:  Reduces data to triangle so should
			   send @data, not polygon class.
	"""
	constructor: (polygon) ->
		@polygon = new Polygon(polygon)
		@triangulation = []

	######################
	#Triangulation Methods
	######################

	getTriangle: (vertex) ->
		""" Returns triangle as triplet of coordinates,
			with vertex as the 'ear-tip'.
		"""
		return [coord(vertex.prev), coord(vertex), coord(vertex.next)]

	getTriangleNormals: (triangle) ->
		""" Returns normals of triangle edges. norm([x,y]) = (-y,x)
			Note that these normals are not of length 1.
		"""
		# !!!
		return [[-p.y, p.x] for p in triangle]

	getBarycentricCoordinate: (triangle, point) ->
		""" http://en.wikipedia.org/wiki/Barycentric_coordinate_system
			if coordinates z_1, z_2, z_3 between 0 and 1 then they are
			inside triangle.  Equal to 1 or 0 and rest in [0,1] means
			on border of triangle.
		"""
		[x_1, y_1] = [triangle[0][0], triangle[0][1]]
		[x_2, y_2] = [triangle[1][0], triangle[1][1]]
		[x_3, y_3] = [triangle[2][0], triangle[2][1]]
		[x  , y]   = [point[0]	     , point[1]]

		detT = (x_1 - x_3)*(y_2 - y_3) + (x_3 - x_2)*(y_1 - y_3)

		z_1 = ((y_2 - y_3)*(x - x_3) + (x_3 - x_2)*(y - y_3)) / detT
		z_2 = ((y_3 - y_1)*(x - x_3) + (x_1 - x_3)*(y - y_3)) / detT
		z_3 = 1.0 - z_1 - z_2
		return  [z_1, z_2, z_3]

	checkPointIn: (triangle, point) ->
		""" Using definition of Barycentric Coordinate System:
			if coordinates all in (0,1) then inside, else outside
			or on border.
		"""
		point_bbc = @getBarycentricCoordinate(triangle, point)
		for i in point_bbc
			if i <= 0.0 or i >= 1.0
				return false
		return true

	checkPointOn: (triangle, point) ->
		""" Using definition of Barycentric Coordinate System:
			if at least one coordinate is 0 or 1 and the rest
			in [0,1] then point is on border of triangle.
		"""
		point_bbc = @getBarycentricCoordinate(triangle, point)
		gate = false
		for i in point_bbc
			if i < 0.0 or i > 1.0
				return false
			if i is 0 or i is 1
				gate = true
		return if gate then true else false

	triangulate: ->
		""" Finds an ear, documents and removes vertice from polygon,
			repeats until only a triangle is left and adds that to
			triangulation.
		"""
		@triangulation = []
		while @polygon.ngon > 3
			ear = @findEar()
			@triangulation.push(ear[0])
			ear[1].unlink()
			#@polygon.remove(ear[1])

		finalear = @findEar()
		@triangulation.push(finalear[0])
		return @triangulation

	########
	#Helpers
	########

	noConcaveIn: (triangle) ->
		""" Checks @polygon.concave for intersecting points.
		"""
		concaves = @polygon.concaves.map (v) -> v.point.toArray()
		for vertex_coord in concaves
			if @checkPointIn(triangle, vertex_coord)
				return false
		return true

	findEar: ->
		""" Resets and populates @convex/@concave,
			checks triangles where the ear-tip is a convex
			vertex for intersection with any concave vert-
			ices.  If no intersection returns that ear.
		"""
		n = @polygon.ngon
		cursor = @polygon.first()

		if n == 3
			triangle = @getTriangle(cursor)
			return [triangle, cursor]

		convexes = @polygon.convexes.map (v) -> v.point.toArray()

		i = 0
		while i <= n + 2
			if arrayInArray(coord(cursor), convexes)
				triangle = @getTriangle(cursor)
				if @noConcaveIn(triangle)
					return [triangle, cursor]
			cursor = cursor.next
			i += 1
		throw new Error('Algorithm is bugged, this should not happen.')

	##############
	#Miscellaneous
	##############

	toString: -> "Triangulation of Polygon with Vertex #{@polygon.point}"


