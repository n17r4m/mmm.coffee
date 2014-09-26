
options = {debug: false, strict: true}
console.info("Loading mmm.coffee library", options)
require("../")()

p1 = new Vector(1,1)
p2 = new Vector(1,1)
p3 = new Vector(3,1)

console.info (new Matrix([[1,2,3],[4,5,6]])).multiply([[7,8],[9,10],[11,12]])


