module.exports = exports = class Pack
	constructor: (object) -> 
		if object.serialize? then data = object.serialize()
		else if object.toArray? then data = object.toArray()
		else data = object.valueOf()
		return {type: object.constructor.name, data}
