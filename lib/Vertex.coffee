Point = require("./Point")

module.exports = exports = class Vertex extends Point
	constructor: (point = new Point(0,0), @next = null, @prev = null) -> super(point)

	@isVertex: (v) -> v isntanceof Vertex

