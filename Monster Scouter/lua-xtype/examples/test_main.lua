-- Test type creation and inheritance.
package.path = "src/?.lua;"..package.path
local xtype = require("xtype")

-- Init.

local being = xtype.create("being")
local animal = xtype.create("animal", being)
local mammal = xtype.create("mammal", animal)
local carnivorous = xtype.create("carnivorous")
local omnivorous = xtype.create("omnivorous")
local hominidae = xtype.create("hominidae", mammal, omnivorous)
local canidae = xtype.create("canidae", mammal, carnivorous)
local human = xtype.create("human", hominidae)
local dog = xtype.create("dog", canidae)
local chimera = xtype.create("chimera", human, dog)

local Nina = setmetatable({}, {xtype = human})
local Alexander = setmetatable({}, {xtype = dog})
local Chimera = setmetatable({}, {xtype = chimera})

-- Test.

-- check
assert(xtype.check("number"))
assert(xtype.check(being))
assert(not xtype.check(0))
-- name
assert(xtype.name("number") == "number")
assert(xtype.name(being) == "being")
assert(xtype.name(0) == nil)
-- misc get/is
assert(xtype.get(0) == "number")
assert(xtype.is(0, "number"))
assert(not xtype.is(0, "string"))
assert(xtype.get(being) == "xtype")
-- of
assert(xtype.of("number", "number"))
assert(xtype.of(being, being))
assert(xtype.of(animal, being))
assert(xtype.of(mammal, being))
assert(xtype.of(mammal, animal))
assert(xtype.of(canidae, mammal))
assert(xtype.of(canidae, being))
assert(xtype.of(canidae, carnivorous))
assert(xtype.of(dog, canidae))
assert(xtype.of(human, hominidae))
assert(not xtype.of(human, dog))
-- is
assert(xtype.is(Nina, human))
assert(xtype.is(Alexander, dog))
assert(xtype.is(Chimera, human))
assert(xtype.is(Chimera, dog))
-- typeDist
assert(xtype.typeDist(dog, "number") == nil)
assert(xtype.typeDist(dog, dog) == 0)
assert(xtype.typeDist(dog, being) == 5)
assert(xtype.typeDist(being, dog) == nil)
-- misc low-level
assert(xtype.signDist(xtype.checkSign(dog), xtype.checkSign(being)) == 5)
assert(xtype.signDist(xtype.checkSign(being), xtype.checkSign(dog)) == nil)
assert(xtype.formatSign(xtype.checkSign("number", dog, being)) == "(number, dog, being)")
-- tools
assert(xtype.tpllist("a$", 1, 3, "+") == "a1+a2+a3")
assert(xtype.tplsub("$k = $v", {k = "a", v = 1}) == "a = 1")
