
Vertex = require("./Vertex")



class Polygon extends Array
	constructor: (vertices = []) ->
		if @ instanceof @constructor
			if arguments.length > 1 then Array::push.apply(@, new Vertex(vertex) for vertex in arguments)
			else if vertices instanceof Array then Array::push.apply(@, new Vertex(vertex) for vertex in vertices)
			else Array::push.apply(@, new Vertex(vertex) for vertex in vertices.valueOf())
			link(@)
			return @
		else
			if arguments.length > 1
				terms = Array::slice.call(arguments, 0)
				return new @constructor(terms)
			else
				return new @constructor(terms)

link = (polygon) ->
	polygon.forEach (vertex, i) ->
		console.info i, vertex
		vertex.next = if polygon[i+1]? then polygon[i+1] else polygon[0]
		vertex.prev = if polygon[i-1]? then polygon[i-1] else polygon[polygon.length-1]

if typeof define is 'function' and define.amd then define -> Polygon
else if typeof module is 'object' and module.exports then module.exports = Polygon
else @Polygon = Polygon
