
options = {debug: false, strict: true}
console.info("Loading mmm.coffee library", options)
require("../")()

p1 = new Vector(1,1)
p2 = new Vector(2,3)
p3 = new Vector(3,1)

console.info p1.project(p3)

