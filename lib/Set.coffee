module.exports = exports = class Set extends Array
	constructor: (array) ->
		if @constructor.isSet(array) then @push.apply @, array.toArray()
		else if @constructor.isArray(array) then @push.apply @, array
		else @push.apply @, arguments
		return @
	equals: (sets...) -> @constructor.equals(@, sets...)
	@isArray: (a) -> a instanceof Array
	@isSet: (set) -> set instanceof @
	@equals: (sets...) -> !@some (x) -> sets.some (set) -> !(x in set)
	@union: (sets...) -> new @(sets.reduce(((union, set) -> union.concat(set)), []))
	@intersection: (A, sets...) ->
		new @(A.filter((x) -> sets.every((set) -> set.some((y) -> x is y))))
	@difference: (A, sets...) -> 
		new @(A.filter((x) -> !sets.some((set) -> set.some((y) -> x is y))))
	@symmetric: (A, sets...) -> @difference(A, sets...).union(@difference(sets.reverse()..., A))

