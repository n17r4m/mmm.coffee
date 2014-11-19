Point = require("./Point")

class Vertex extends Point
	constructor: (vertex, @next, @prev) ->
		super(vertex)
		@next ?= vertex.next
		@prev ?= vertex.prev

if typeof define is 'function' and define.amd then define -> Vertex
else if typeof module is 'object' and module.exports then module.exports = Vertex
else @Vertex = Vertex
