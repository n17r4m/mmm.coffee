
class Tuple extends Array
	constructor: (terms) ->
		if @ instanceof @constructor
			if arguments.length > 1 then Array::push.apply(@, Array::slice.call(arguments, 0))
			else if terms instanceof Array then Array::push.call(@, terms...)
			else Array::push.call(@, terms)
			return @
		else
			if arguments.length > 1
				terms = Array::slice.call(arguments, 0)
				return new @constructor(terms)
			else
				return new @constructor(terms)
	
	mutate: (tuple) -> @splice(0, @length, tuple...); @
	
	valueOf: -> @map (term) -> term
	toString: -> "(#{@join(',')})"
	
	zero: -> @mutate @map -> 0
	@zero: (dimensions = 1) -> new @(0 for [1..dimensions])
	
	isZero: -> @constructor.isZero(@)
	@isZero: (tuples...) -> !tuples.some (tuple) => !@equals(tuple, @zero(tuple.length))
	
	equals: (tuples...) -> @constructor.equals(@, tuples...)
	@equals: (tuples...) -> 
		if tuples.length is 1 then tuples[0].reduce(((eq, term) -> eq and term is tuples[0][0]), true)
		else @zip(tuples).reduce(((eq, zip) -> eq and !zip.some (term) -> term isnt zip[0]), true)
	
	negate: -> @mutate @constructor.negate(@)
	@negate: (tuple) -> new @ tuple.map (term) -> -term
	
	add: (tuples...) -> @mutate @constructor.add(@, tuples...); @
	@add: (tuples...) -> new @ @zip(tuples).map (zip) -> zip.reduce(((sum, term) -> sum + term), zip.shift())
	
	subtract: (tuples...) -> @mutate @constructor.subtract(@, tuples...); @
	@subtract: (tuples...) -> new @ @zip(tuples).map (zip) -> zip.reduce(((difference, term) -> difference - term), zip.shift())
	
	multiply: (tuples...) -> @mutate @constructor.multiply(@, tuples...); @
	@multiply: (tuples...) -> new @ @zip(tuples).map (zip) -> zip.reduce(((product, term) -> product * term), zip.shift())
	
	dot: (tuples...) -> @constructor.dot(@, tuples...)
	@dot: (tuples...) -> @multiply(tuples...).sum()
	
	divide: (tuples...) -> @mutate @constructor.divide(@, tuples...); @
	@divide: (tuples...) -> new @ @zip(tuples).map (zip) -> zip.reduce(((quotient, term) -> quotient / term), zip.shift())
	
	modulo: (tuples...) -> @mutate @constructor.modulo(@, tuples...); @
	@modulo: (tuples...) -> new @ @zip(tuples).map (zip) -> zip.reduce(((remainder, term) -> remainder % term), zip.shift())
	
	pow: (x) -> @mutate @constructor.pow(@, x)
	@pow: (tuple, x) -> new @ tuple.map (term) -> Math.pow(term, x)
	
	square: -> @mutate @constructor.square(@)
	@square: (tuple) -> new @ tuple.map (term) -> term * term
	
	sqrt: -> @mutate @constructor.sqrt(@)
	@sqrt: (tuple) -> new @ tuple.map (term) -> Math.sqrt(term)
	
	sum: -> @constructor.sum(@)
	@sum: (tuple) -> tuple.reduce(((sum, term) -> sum + term), 0)
	
	product: -> @constructor.product(@)
	@product: (tuple) -> tuple.reduce(((sum, term) -> sum * term), 1)
	
	round: -> @mutate @constructor.round(@)
	@round: (tuple) -> new @ tuple.map (element) -> Math.round(element)
	
	ceil: -> @mutate @constructor.ceil(@)
	@ceil: (tuple) -> new @ tuple.map (element) -> Math.ceil(element)
	
	floor: -> @mutate @constructor.floor(@)
	@floor: (tuple) -> new @ tuple.map (element) -> Math.floor(element)

	abs: -> @mutate @constructor.abs(@)
	@abs: (tuple) -> new @ tuple.map (element) -> Math.abs(element)
	
	max: -> Math.max.apply(null, @)
	@max: (tuples...) -> new @ @zip(tuples).map (zip) -> Math.max.apply(null, zip) 
	
	min: -> Math.min.apply(null, @)
	@min: (tuples...) -> new @ @zip(tuples).map (zip) -> Math.min.apply(null, zip)
	
	average: -> @reduce(((sum, term) -> sum + term), 0)/@length
	@average: (tuples...) -> new @ @zip(tuples).map (zip) -> zip.reduce(((sum, el) -> sum + el), 0) / zip.length
	
	@zip: (tuples) ->
		length = Math.max.apply(null, tuples.map((tuple) -> tuple.length || 0))
		zipped = []; zipped.push tuples.reduce(((s, v) ->
			term = if v[i]? then v[i] else (if v instanceof Array then null else v)
			s.concat(term)), []) for i in [0...length]
		zipped

if typeof define is 'function' and define.amd
	define -> Tuple
else if typeof module is 'object' and module.exports
	module.exports = Tuple
else
	@Tuple = Tuple
