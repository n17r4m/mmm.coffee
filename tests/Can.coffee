
require("../")()

can = new Can([
	"black", "black", "black", "black", "black",
	"white", "white", "white", "white", "white"
])

lt = false

count = (col) -> can.reduce(((n, b) -> n + (if b is col then 1 else 0)), 0)

while can.length > 1 
	[b1, b2] = [can.pick(), can.pick()]
	if b1 is b2 is 'white' then can.put 'white'
	else if b1 is b2 is 'black' then can.put 'white'
	else can.put 'black'
	lt = count('white') <= count('black') or lt
	console.info "W:", count('white'), "B:", count('black'), "T:", count("white") + count("black")

###
while can.length > 1 
	[b1, b2] = [can.pick(), can.pick()]
	if b1 is b2 is 'white' then can.put 'white'
	else if b1 is b2 is 'black' then can.put 'black'
	else can.put 'white'
	lt = count('white') <= count('black') or lt
	console.info "W:", count('white'), "B:", count('black'), "T:", count("white") + count("black")
###

###
while can.length > 1 
	[b1, b2] = [can.pick(), can.pick()]
	if b1 is b2 is 'white' then can.put 'white'
	else if b1 is b2 is 'black' then can.put 'white'
	else can.put 'black'
	lt = count('white') <= count('black') or lt
	console.info "W:", count('white'), "B:", count('black'), "T:", count("white") + count("black")
###
console.info module.exports = can.pick()








