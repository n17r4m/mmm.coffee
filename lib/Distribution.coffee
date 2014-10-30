pow = Math.pow
abs = Math.abs
E = Math.E


module.exports = exports = class Distribution
	constructor: (@bounds = [-Infinity, Infinity], @center: 0) -> @
	pdf: (a, b) -> 0 # Probability density function (x 
	cdf: (a, b) -> 0 # Cumulative density function
	ppf: (a, b) -> 0 # Percent point function (inverse of cdf)
	multiply: (d) -> # new Distribution of D = (@*d)
	divide: (d) ->   # new Distribution of D = (@/d)

class Bump extends Distribution
	constructor: (x = 1) -> 
		if abs(x) > 1 then return pow(E, -(1/(1 - pow(x, 2))))
		else return 0
		
		###
		
		
		
		D = new UniformDistribution(a = Infinity, b = -Infinity)
		
		D instanceof UniformDistribution // true
		D instanceof Distribution // true
		
		D(3) // == 3
		
		D
		
		G = new GaussianDistribution(mean = 70,  = 4)
		
		D instanceof UniformDistribution // true
		D instanceof Distribution // true
		
		D(3) // == 3
		
		G = 
		
		
		
