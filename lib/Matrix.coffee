Tuple = require("./Tuple")


module.exports = exports = class Matrix extends Array
	constructor: (mx = [[]]) -> @push.apply(@, mx.map (row) -> new Tuple(row))
	
	row: (n = 1) -> 
		if n > 0 then return new Tuple(@[n - 1])
		else if n < 0 then return new Tuple(@[@rows - n])
		else return new Tuple(@[0])
		
	col: (n) ->
		if n > 0 then return new Tuple(@map (row) -> row[n - 1])
		else if n < 0 then return new Tuple(@map (row) -> row[@rows - n])
		else return new Tuple(@map (row) -> row[0])
		
	
	
	rref: -> @constructor.rref(@)
	
	@getter 'rows', -> @length
	@getter 'cols', -> @[0].length
	
	@rref: (mx) ->		
		mx = new @(mx)
		[lead, rows, cols] = [0, mx.rows, mx.cols]
		for k in [0...rows]
			if cols <= lead then return
			i = k
			while mx[i][lead] is 0
				i++
				if i is rows
					[i, lead] = [k, lead + 1]
					if lead is cols then return
			[mx[i], mx[k]] = [mx[k], mx[i]]
			val = mx[k][lead]
			for j in [0...cols]
				mx[k][j] /= val
			for i in [0...rows]
				if i is k then continue
				val = mx[i][lead]
				for j in [0...cols]
					mx[i][j] -= val * mx[k][j]
			lead++
		return mx

