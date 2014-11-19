Tuple = require("./Point")
Vector = require("./Vector")

axis = require("./helpers/axis")


class Matrix extends Array

	constructor: (mx = [[]]) ->
		if @ instanceof @constructor
			mx.forEach (row) => @push new Tuple(row) 
		else return new @constructor(mx)
	

	toString: -> "{" + @map((row) -> "{#{row.join(',')}}").join(",") + "}"
	toArray: -> @valueOf()
	valueOf: -> @map (row) -> row.map (cell) -> cell
	
	mutate: (mx) -> @splice(0, @length, (mx.map (row) -> new Tuple(row))...); @
	
	zero: -> @constructor.zero(@height(), @width())
	@zero: (height = 1, width = height) -> new @(0 for i in [0...width] for j in [0...height])
	
	identity: -> if (n = @isSquare()) then @constructor.identity(n)
	@identity: (size = 1) -> new @ (@zero(size).rows (row, i) -> row[i] = 1; row)
	
	isSquare: -> if (n = @width()) is @height() then n else false
	@isSquare: (mx) -> if (n = @width(mx)) is @height(mx) then n else false
	
	height: -> @constructor.height(@)
	@height: (mx) -> mx.length
	
	width: -> @constructor.width(@)
	@width: (mx) -> mx[0].length
	
	row: (i = 0) -> @rows()[i]
	@row: (mx, i = 0) -> @rows(mx)[i]
	
	col: (j = 0) -> @cols()[j]
	@col: (mx, j = 0) -> @cols(mx)[j]
	
	rows: (fn) -> if fn? then @constructor.rows(@).map(fn) else @constructor.rows(@)
	@rows: (mx) -> mx.map (row) -> new Tuple(row)
	
	cols: (fn) -> if fn? then @constructor.cols(@).map(fn) else @constructor.cols(@)
	@cols: (mx) -> 
		cols = []; 
		@rows(mx).forEach (row, i) -> row.forEach (cell, j) -> 
			unless cols[j]? then cols[j] = new Tuple(cell) else cols[j].push(cell);
		new @ cols;
	
	transpose: -> @mutate @constructor.transpose(@)
	@transpose: (mx) -> new @ @cols(mx)
	
	add: (mxs...) -> @mutate @constructor.add(@, mxs...)
	@add: (mxs...) -> mxs.reduce(((sumx, mx) -> 
		mx.forEach((row, i) -> sumx[i].add(row)); sumx ), new @(mxs.shift()))
	
	subtract: (mxs...) -> @mutate @constructor.subtract(@, mxs...)
	@subtract: (mxs...) -> mxs.reduce(((diffx, mx) -> 
		mx.forEach((row, i) -> diffx[i].subtract(row)); diffx ), new @(mxs.shift()))
	
	multiply: (mxs...) -> @mutate @constructor.multiply(@, mxs...)
	product: (mxs...) -> @constructor.multiply(@, mxs...)
	@multiply: (mxs...) -> 
		rmx = new @ mxs.shift()
		mxs.forEach (mx) =>
			if mx[0]?[0]?
				rmx.mutate rmx.map (row) => @cols(mx).map (col) -> Tuple.dot(col, row)
			else if mx[0]?
				rmx.mutate @multiply(rmx, @transpose([mx]))
			else 
				rmx.forEach (row) -> row.multiply(mx)
		rmx
	
	divide: (x) -> @mutate @constructor.divide(@, x)
	@divide: (mx, x = 1) -> new @ mx.map (row) -> row.map (cell) -> cell/x
	
	scale: (x) -> 
		if (n = @isSquare()) then @multiply(@constructor.scale(n, x))
		else undefined
	@scale: (n = 1, x = 1) -> @identity(n).multiply(x)
	
	mirror: (along) -> 
		@multiply @constructor.mirror(@height, along)
	@mirror: (size, along) -> 
		if size? and not along? then (along = size) and (size = 3)
		if along? then unless along instanceof Array then along = Vector.standard(size, axis(along, size))
		else along = Vector.standard(2, 0)
		unless size? then size = along.length
		@build(along.length, (x) -> Tuple.subtract(x, Vector.project(along, x).multiply(2)))
	
	skew: (i = 0, j = 1, factor = 1) -> 
		@multiply @constructor.skew(@height, i, j, factor)
	@skew: (size = 2, i = 0, j = 1, factor = 1) -> 
		[i, j] = [axis(i, size), axis(j, size)]
		if i is j or i >= size or j >= size then return undefined
		skewmx = @identity(size)
		skewmx[i][j] = factor
		new @ skewmx
		
	
	minor: (i, j) -> @constructor.minor(@, i, j)
	@minor: (mx, i = 0, j = 0) ->
		new @(mx.filter((row, ii) -> ii isnt i).map((row) -> row.filter((col, jj) -> jj isnt j)))
	
	cofactor: (i, j) -> @constructor.cofactor(@, i, j)
	@cofactor: (mx, i = 0, j = 0) -> Math.pow(-1, i+j) * @determinant(@minor(mx, i, j))
	
	determinant: -> @constructor.determinant(@)
	@determinant: (mx) ->
		mx.reduce(((det, row, r) =>
			if row.length > 1
				if row[0] is 0 then det 
				else det + row[0] * @cofactor(mx, r, 0)
			else det + row[0]
		), 0)
	
	adjugate: -> @mutate @constructor.adjugate(@)
	@adjugate: (mx) -> new @ mx.map (row, i) => row.map (cell, j) => @cofactor(mx, i, j)
	
	inverse: -> @mutate @constructor.inverse(@)
	@inverse: (mx) -> @adjugate(mx).multiply(1/@determinant(mx))
		
	isometry: -> @constructor.isometry(@)
	@isometry : (mx) ->
		cols = @cols(mx)
		cols.every (col) => 
			col.norm() is 1 and cols.every (col2) -> 
				col2 is col or col.dot(col2) is 0
	
	rref: -> @constructor.rref(@)
	@rref: (mx) ->
		# https://github.com/substack/rref
		mx = new @(mx)
		[lead, rows, cols] = [0, mx.height(), mx.width()]
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
		
	@build: (size = 2, fn = (x) -> x) ->
		@transpose((fn(Vector.standard(size, i), i)) for i in [0...size])
		
	
	@zip: (mxs...) -> mxs.reduce(((mmx, mx) -> 
		mx.forEach((row, i) -> row.forEach((cell, j) -> mmx[i][j].push(cell)))
		return mmx
	), mxs.shift().map((row) -> row.map((cell) -> [cell])))
	
	
	
	
	# todo .rank()

if typeof define is 'function' and define.amd then define -> Matrix
else if typeof module is 'object' and module.exports then module.exports = Matrix
else @Matrix = Matrix


