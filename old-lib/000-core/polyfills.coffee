

unless typeof String::trim is 'function'
  String::trim = -> @replace(/^\s+|\s+$/g, '')

  
unless typeof Function::property is 'function'
	Function::property = (prop, desc) ->
	  Object.defineProperty(@prototype, prop, desc)

unless typeof Function::getter is 'function'
	Function::getter = (prop, get) ->
	  Object.defineProperty(@prototype, prop, {get, configurable: true})

unless typeof Function::setter is 'function'
	Function::setter = (prop, set) ->
	  Object.defineProperty(@prototype, prop, {set, configurable: true})
  
