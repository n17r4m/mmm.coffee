
options = {debug: false, strict: true}
console.info("Loading mmm.coffee library", options)
require("../")()


p1 = new Point(2,3)

# needs more testing
console.info(p1.multiply(2))
