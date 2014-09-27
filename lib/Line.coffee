
Point = require("./Point")
Vector = require("./Vector")
Arrow = require("./Arrow")

module.exports = exports = class Line extends Point
	constructor: (A = new Point(), B = new Point()) ->
		###
		@vector = new Vector(point) 
		super(point)
		###
		
		if Line.isLine(A)
			@vector = new Vector(A.vector)
			super(A)
		else if Arrow.isArrow(A)
			@vector = new Vector(A)
			super(A.point)			
		else if Vector.isVector(A)
			@vector = new Vector(A)
			super(new Point())
		else if Point.isPoint(A)
			super(A)
			if Vector.isVector(B)
				@vector = new Vector(B)
			else if Point.isPoint(B)
				@vector = new Vector(B.subtract(A))
		else if Array.isArray(A)
			if Array.isArray(B)
				super(A)
				@vector = (new Vector(A)).subtract(@)
			else
				@vector = new Vector(A)
				super(@vector.zero())

		else 
			throw new Error("Unsupported Argument type(s)")

	@getter 'A', -> @
	@getter 'B', -> @.add(@vector)
	
	
	
	translate: (point) -> @point.add(point)
	
	@isLine: (a) -> a instanceof Line
	
	@intersection: (lines...) ->
		unless l1.length = 2
			throw new RangeError("Only 2d line intersections are presently supported")
		(new Intersection2(lines)).generalIntersection()
		

class Intersection2
	###
	Class containing boolean testing methods for general
	line intersection in the plane ℝ^2. Initiates with lines
	of form [(x1,y1), (x2,y2)] which are converted to
	labeled endpoints [(xi, yi), label].  The main test
	for general line intersection uses a sweep-line
	algorithm.
	###
	constructor: (lines) ->

		@count      = 0
		@lines      = {}
		@sweeps     = []
		@tested     = []
		@addLines(lines)


	addLine: (line) ->
		###
		Breaks line into endpoints, labels according to
		current self.count value, adds to dictionary and
		raises count by 1.
		###
		@sweeps.push([line[0], @count])
		@sweeps.push([line[1], @count])
		@lines[@count] = line
		@count += 1

	addLines: (lines) -> lines.forEach (line) => @addLine(line)

	sortSweeps: -> @sweeps.sort((sw1, sw2) -> 
		(sw2[0][0] - sw1[0][0])*1e10 + (sw2[1]-sw1[1]))

	# The following are boolean tests for line intersection.

	intersectingTwo: (l1, l2) ->
		###
		It suffices to check if two points are on opposite sides of
		a line segment.  To do this we compute the cross products of
		lineA and the endpoints of lineB and take their product. The
		product will be negative if and only if they intersect.

		Endpoints of lineA will be labeled A and B 
		Endpoints of lineB will be labeled P and Q 
		###
		[A, B] = [l1.A, l1.B]
		[P, Q] = [l2.A, l2.B]


		# We now take the cross product of each endpoint with lineA
		xproductP = ((B[0]-A[0])*(P[1]-B[1]) - (B[1]-A[1])*(P[0]-B[0]))
		xproductQ = ((B[0]-A[0])*(Q[1]-B[1]) - (B[1]-A[1])*(Q[0]-B[0]))

		if xproductP*xproductQ < 0 then true else false


	generalIntersection: ->
		###
		The following is the implementation of a sweep-line algorithm 

		Sorting the endpoints of each line(sweeps), we iterate through them
		from left to right, adding them to events as they come up.  If the
		other endpoint of the line comes up, both are removed.  If any endpoints
		of other lines come up while an endpoint is an event, these two lines
		need to be tested for intersection.
		###

		# Empty case
		unless @sweeps.length > 0 then return false

		# Sorting the sweeps, initializing events.
		@sortSweeps()
		events = []

		# Beginning sweep
		[i, l] = [0, @sweeps.length]
		while i < l
			# Getting new endpoint's dictionary key
			lineName = @sweeps[i][1]
			unless events.length > 0
				events.push(lineName)
			else if lineName in events
				events.remove(line_name)
			# New endpoint arrives while another is active
			else for event of events
				# Grabs data for calculation from dictionary using keys
				testResults = @intersectingTwo(@lines[event], @lines[lineName])
				if testResults then return true
			i += 1
		return false


