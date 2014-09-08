Util = require("./Util")
Point = require("./Point")

module.exports = exports = class Line extends Point
	constructor: (tail = new Point(), @tip = new Point()) ->
		super(tail)
		@tip.tail = @
	
	vector: -> @tip.subtract(@)
	
