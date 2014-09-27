
# Math

unless typeof Math.radians is 'function'
	Object.defineProperty(Math, "radians", {
		value: (degrees = 360) -> (Math.PI * degrees) / 180
	})

unless typeof Math.degrees is 'function'
	Object.defineProperty(Math, "degrees", {
		value: (radians = 2*Math.PI) -> (180 * radians) / Math.PI
	})


# Functions
  
unless typeof Function::property is 'function'
	Object.defineProperty(Function::, "property", {
		value: (prop, desc) -> 
			Object.defineProperty(@prototype, prop, desc)
	})

unless typeof Function::getter is 'function'
	Object.defineProperty(Function::, "getter", {
		value: (prop, get) -> 
			Object.defineProperty(@prototype, prop, {get, configurable: false})
	})

unless typeof Function::setter is 'function'
	Object.defineProperty(Function::, "setter", {
		value: (prop, set) ->
			Object.defineProperty(@prototype, prop, {set, configurable: true})
	})


# Arrays

unless typeof Array::zip is 'function'
	Object.defineProperty(Array::, "zip", {
		value: (empty = null) ->
			length = Math.max.apply(Math, @map((a) -> a.length))
			zipped = []
			for i in [0..length-1]
				zipped.push @reduce(((s, v) -> s.push(v[i]||empty); s), [])
			zipped
	})

unless typeof Array::remove is 'function'
	Object.defineProperty(Array::, "remove", {
		value: (element) ->
			if (i = @indexOf(element)) >= 0 then @splice(i, 1)
	})

unless typeof Array::insert is 'function'
	Object.defineProperty(Array::, "insert", {
		value: (i, elements...) -> @splice(i, 0, elements...)
	})

unless typeof Array::replace is 'function'
	Object.defineProperty(Array::, "replace", {
		value: (i, elements = []) -> @splice(i, elements.length, elements...)
	})


# Strings

unless typeof String::trim is 'function'
  String::trim = -> @replace(/^\s+|\s+$/g, '')

# Numbers
unless typeof Number.isNumber is 'function'
	Number.isNumber = (n) -> !isNaN(parseFloat(n)) && isFinite(n)

