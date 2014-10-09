
require("../")()

can = new Can([
	"black", "black", "black", 
	"white", "white", "white", "white"
])

while can.length > 1 
	[b1, b2] = [can.pick(), can.pick()]
	if b1 is b2 then can.put 'black'
	else can.put 'white' 

console.info module.exports = can.pick() is 'black'








