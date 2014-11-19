Ray = require("./Ray")

class Line extends Ray
	at: (x) -> @constructor.at(@, x)
	@at: (line, x) -> 
		if x > 1 then undefined
		else super line, x


if typeof define is 'function' and define.amd then define -> Line
else if typeof module is 'object' and module.exports then module.exports = Line
else @Line = Line

