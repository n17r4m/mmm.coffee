
root = (-> @)()

module.exports = exports = class Unpack
	constructor: (packed, namespace = root) -> 
		unless Type = namespace[packed.type]
			throw new TypeError("Type '#{packed.type}' not found when unpacking")
		args = if Array.isArray(packed.data) then packed.data else [packed.data]
		return Unpack.conthunktor(Type, args)
		
	@conthunktor: (Type) -> (args) ->
		Temp = (->)
		Temp.prototype = Type.prototype
		Temp.prototype.constructor = Type
		instance = new Temp
		applied = Type.apply(instance, args)
		return if Object(applied) is applied then applied else instance

