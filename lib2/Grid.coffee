Line = require("./Line")

module.exports = exports = class Grid
	constructor: (attrs = {}) ->
		attrs.spacing ?= 10
		attrs.x1      ?= 0
		attrs.y1      ?= 0
		attrs.x2      ?= 100
		attrs.y2      ?= 100
		@set(attrs)

	set: (attrs = {}) ->
		@[name] = attr for name, attr of attrs
		@compute()

	compute: ->
		@horizontal = (y for y in [@y1..@y2] by @spacing).map (y) => new Line([@x1, y], [@x2, y])
		@vertical = (x for x in [@x1..@x2] by @spacing).map (x) => new Line([x, @y1], [x, @y2])

	lines: -> @horizontal.concat(@vertical)

