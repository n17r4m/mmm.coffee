
class LineIntersection(object):
	""" Line Intersection Class. initiates with lines
		[(x1,y1), (x2, y2)] to be converted to labeled
		endpoints [(x,y), label].  Main test for gen.
		line intersection uses sweep-line algorithm.
	"""
	def __init__(self, data):
		self.count    = 0
		self.lines    = {}
		self.sweeps   = []
		self.tested   = []
		self.addLines(data)

	################
	#Data Properties
	################

	def addLine(self, line):
		self.sweeps.append([line[0], str(self.count)])
		self.sweeps.append([line[1], str(self.count)])
		self.lines[str(self.count)] = line
		self.count += 1


	def addLines(self, array):
		for line in array:
			self.addLine(line)


	def sortSweeps(self):
		self.sweeps.sort(key = lambda x: (x[0][0], not x[1]))

	###################
	#Line Intersections
	###################

	def intersectTwo(self, lineA, lineB):
		""" It suffices to check if two points are on
			opposite sides of a line segment.  To do
			this we compute the cross products of
			lineA and the endpoints of lineB and take
			their product.  The product will be negative
			if and only if they intersect.
		"""
		P, Q 	  = lineB[0], lineB[1]
		xproductP = (1.0*(lineA[1][0] - lineA[0][0])*(P[1] + lineA[1][1]) -
					 1.0*(lineA[0][1] - lineA[1][1])*(P[0] - lineA[1][0]))
		xproductQ = (1.0*(lineA[1][0] - lineA[0][0])*(Q[1] + lineA[1][1]) -
					 1.0*(lineA[0][1] - lineA[1][1])*(Q[0] - lineA[1][0]))
		return true if xproductP * xproductQ < 0 else false


	def checkIntersection(self):

		if not self.sweeps:
			return False

		self.sortSweeps()
		self.tested = []
		events 	    = []
		i 			= 0
		while i < len(self.sweeps):
			newvalue = self.sweeps[i][1]

			if not events:
				events.append(newvalue)
			elif newvalue in events:
				events.remove(newvalue)
			else:
				for event in events:
					if (event, newvalue) in self.tested:
						continue
					test = self.intersectTwo(self.lines[event],
										  self.lines[newvalue])
					if test:
						return True
					else:
						self.tested.append((event, newvalue))
			i += 1
		return False

	##############
	#Miscellaneous
	##############

	def __repr__(self):
		return 'Line Intersection Class for lines %s' % self.lines



