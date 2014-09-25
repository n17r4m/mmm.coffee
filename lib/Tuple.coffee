
module.exports = exports = class Tuple extends Array
	constructor: (array) ->
		if @constructor.isTuple(array)
			@push.apply @, array.toArray()
		else if @constructor.isArray(array)
			@push.apply @, array
		else
			@push.apply @, arguments
		return @

	zero: -> new @constructor(@map -> 0)
	isZero: -> @every (t) -> t is 0
	deNaN: -> new @constructor(@map (t) -> if isNaN(t) then null else t)

	toArray: -> @slice()
	toString: -> @toArray().toString()
	valueOf: -> @toArray()
	
	max: -> Math.max.apply([], @)
	min: -> Math.min.apply([], @)

	@arrayify: (fn) -> 
		if typeof fn is 'function' then return (args...) ->
			if args.length is 1 and 
					Array.isArray(args[0]) and 
					Tuple.isArray(args[0][0])
					
				args = arguments[0]
			return fn.apply(@, args)
		else return fn

	@isArray: (a) -> a instanceof Array
	@isTuple: (t) -> t instanceof @

	@add: @arrayify (tuples...) -> @op(((a, p) -> a + p), tuples...)
	@subtract: @arrayify (tuples...) -> @op(((a, p) -> a - p), tuples...)
	@multiply: @arrayify (tuples...) -> @op(((a, p) -> a * p), tuples...)
	@divide: @arrayify (tuples...) -> @op(((a, p) -> a / p), tuples...)
	@modulus: @arrayify (tuples...) -> @op(((a, p) -> a % p), tuples...)

	@zero: (dimensions = 1) -> new @(0 for [1..dimensions])
	
	@random: (dimensions = 1, min = 0, max = 1, integers = false) ->		
		[min, max, range] = [Math.min(min, max), Math.max(min, max), Math.abs(max - min)]
		rounding = (n) -> if integers then Math.round(n) else n
		new @(rounding(range*Math.random() + min) for [1..dimensions])

	@op: (fn, tuples...) -> 
		if tuples.length is 2 and Number.isNumber(tuples[1])
			tuples[1] = new @(tuples[0].zero().map (n) -> tuples[1])
		tuples = tuples.map (t) => new @(t)
		result = new @(tuples.zip(if @strict then NaN else null).map((elements) -> 
			elements.reduce(((acc, e) -> fn(acc, e)), elements.shift())
		))
		unless @strict then result.deNaN() else result

	@equals: @arrayify (tuples...) -> 
		not @op(((a, el) -> a is el), tuples...).some (b) -> b isnt true
		
	@max: @arrayify (points...) -> @op(((a, p) -> Math.max(a, p)), points...)
	@min: @arrayify (points...) -> @op(((a, p) -> Math.min(a, p)), points...)
	@average: @arrayify (points...) -> new @(@add(points...).map((p) -> p / points.length))
	
	@floor: (point) -> new @(point.map (p) -> Math.floor(p))
	@ceil: (point) -> new @(point.map (p) -> Math.ceil(p))	
	@round: (point) -> new @(point.map (p) -> Math.round(p))	
	@abs: (point) -> new @(point.map (p) -> Math.abs(p))	
	
	@floori: (point, i = 0) -> p = new @(point); p[i] = Math.floor(p[i]); p; 
	@ceili: (point, i = 0) -> p = new @(point); p[i] = Math.ceil(p[i]); p; 	
	@roundi: (point, i = 0) -> p = new @(point); p[i] = Math.round(p[i]); p; 	
	@absi: (point, i = 0) -> p = new @(point); p[i] = Math.abs(p[i]); p; 	

	
[ "add", "subtract", "multiply", "divide", "modulus"
].forEach(((method) ->
	@::[method] = (tuples...) -> @constructor[method](@, tuples...)
), Tuple)
	
[ "equals", "max", "min", "average"
].forEach(((method) -> 
	solo = @::[method]
	@::[method] = (tuples...) ->
		if tuples.length is 0 then solo.call(@)
		else @constructor[method](@, tuples...)
), Tuple)

[ "floor", "floori", "ceil", "ceili", "round", "roundi", "abs", "absi"
].forEach(((method) -> 
	@::[method] = (i) -> @constructor[method](@, i)
), Tuple)


