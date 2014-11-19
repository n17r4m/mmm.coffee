module.exports = exports = class Set extends Array
	constructor: (array) ->
		if @constructor.isSet(array) then @push.apply @, array.toArray()
		else if @constructor.isArray(array) then @push.apply @, array
		else @push.apply @, arguments
		return @
	
	
	@union: (sets...) -> new @(sets.reduce(((union, set) -> union.concat(set)), []))
	
	@intersection: (A, sets...) ->
		new @(A.filter((x) -> sets.every((set) -> set.some((y) -> x is y))))
	
	@difference: (A, sets...) -> 
		new @(A.filter((x) -> !sets.some((set) -> set.some((y) -> x is y))))
		
	@symmetric: (A, sets...) -> @difference(A, sets...).union(@difference(sets.reverse()..., A))
	
	
	
	
	@isArray: (a) -> a instanceof Array # note that this is subtley different than
	                                    # using Array.isArray(a)
	
	@isSet: (set) -> set instanceof @

