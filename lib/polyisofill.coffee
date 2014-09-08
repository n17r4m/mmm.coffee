
# Functions
  
unless typeof Function::property is 'function'
	Object.defineProperty(Function, "property", {
		value: (prop, desc) -> 
			Object.defineProperty(@prototype, prop, desc)
	})

unless typeof Function::getter is 'function'
	Object.defineProperty(Function, "getter", {
		value: (prop, get) -> 
			Object.defineProperty(@prototype, prop, {get, configurable: false})
	})

unless typeof Function::setter is 'function'
	Object.defineProperty(Function, "setter", {
		value: (prop, set) ->
			Object.defineProperty(@prototype, prop, {set, configurable: true})
	})


# Arrays

unless typeof Array::zip is 'function'
	Object.defineProperty(Array.prototype, "zip", {
		value: (empty = null) ->
			length = Math.max.apply(Math, @map((a) -> a.length))
			zipped = []
			for i in [0..length-1]
				zipped.push @reduce(((s, v) -> s.push(v[i]||empty); s), [])
			zipped
	})


# Strings

unless typeof String::trim is 'function'
  String::trim = -> @replace(/^\s+|\s+$/g, '')
