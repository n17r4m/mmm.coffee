Tuple = require("./Tuple")

module.exports = exports = class Can extends Tuple
	constructor: (items...) ->
		super(items...)
		return @
	
	put: (items...) -> @push(items...)
	
	pick: ->
		@shuffle()
		return @pop()

