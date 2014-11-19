Tuple = require("./Tuple")
Vector = require("./Vector")

module.exports = exports = class Matrix extends Tuple
	constructor: (mx = [[]]) -> @push.apply(@, mx.map (row) -> new Tuple(row))
	
	@getter 'height', -> @length
	@getter 'width', -> @[0].length
	@getter 'size', -> "#{@width}x#{@height}"
	
	toArray: -> @map (row) -> row.toArray()
	toString: -> "[#{@size} Matrix]"
	valueOf: -> @toArray()
	
	@isMatrix: (mx) -> mx instanceof Matrix
	
	@row: (mx, n = 1) -> 
		if n > 0 then return new Tuple(mx[n - 1])
		else if n < 0 then return new Tuple(mx[mx.length - n])
		else return new Tuple(mx[0])
		
	@col: (mx, n) ->
		if n > 0 then return new Tuple(mx.map (row) -> row[n - 1])
		else if n < 0 then return new Tuple(mx.map (row) -> row[mx[0].length - n])
		else return new Tuple(mx.map (row) -> row[0])
	
	@rows: (mx) -> mx
	@cols: (mx) -> cols = @col(mx, n) for n in [1..mx[0].length]
	
	@add: (m1, m2) -> new @(m1.map (row, r) -> row.map (m, c) -> m + m2[r][c])
	@subtract: (m1, m2) -> new @(m1.map (row, r) -> row.map (m, c) -> m - m2[r][c])
	@multiply: (m1, m2) -> 
		if Number.isNumber(m2) then new @(m1.map (row) -> row.map (m) -> m * m2)
		else 
			if @strict and m1.length isnt m2[0].length
				return undefined
			else
				return new @(m1.map (row) => @cols(m2).map (col) -> col.dot(row))
	
	@transpose: (mx) -> new @(mx[0].map((col, i) -> mx.map((row) -> row[i])))
	
	@minor: (mx, i, j) ->
		new @(mx.filter((row, r) -> r isnt i).map((row) -> 
			row.filter((col, c) -> c isnt j)))
	
	@cofactor: (mx, i = 0, j = 0) ->
		Math.pow(-1, i+j) * @determinant(@minor(mx, i, j))
	
	@determinant: (mx) ->
		mx.reduce(((det, row, r) =>
			if row.length > 1
				if row[0] is 0 then det
				else det + row[0] * @cofactor(mx, r, 0)
			else det + row[0]
		), 0)
	
	@rank: (mx) -> @rref(mx).reduce(((rank, row) ->
		#todo: count leading 1's in cols < col.length-1
	), 0)
		
	
	@isometry: (mx) ->
		@cols(mx).every (col) => 
			# need to deal with float issues
			Vector.norm(col) is 1 and @cols(mx).every (otherCol) ->
				otherCol is col or Vector.dot(col, otherCol) is 0
	
	
	
	@rref: (mx) ->		
		# https://github.com/substack/rref
		mx = new @(mx)
		[lead, rows, cols] = [0, mx.height, mx.width]
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
		
	
	
	@Zero: (n) ->
		mx = []
		for i in [0..n]
		  row = []
		  for j in [0..n]
		  	row.push(0)
		  mx.push(row)
		return new @(mx)
	
	@Identity: (n) -> new @(@Zero(n).map((row, i) -> 
		row.map((col, j) -> if i is j then 1 else col)))



[
	"row", "col", "rows", "cols", 
	"add", "subtract", "multiply", 
	"transpose", "minor", "cofactor",
	"determinant", "isometry", "rref"
].forEach(((method) ->
	@::[method] = (args...) -> @constructor[method](@, args...)
), Matrix)

