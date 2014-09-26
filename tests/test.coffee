
options = {debug: false, strict: true}
console.info("Loading mmm.coffee library", options)
require("../")()

p1 = new Vector(1,1)
p2 = new Vector(1,1)
p3 = new Vector(3,1)

console.info p1.equals(p2)

console.info v1 = Vector.cross([2, -3, 0], [1, 2, 2]).fix()


