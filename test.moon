

import p from require "moon"
import parse from require "moonparse"
old = require "moonscript.parse"

code = [[
k + (a - zeta)
]]

-- one.hello world, foo + bar, boba cat

old_parse = old.string

tree = parse code

print "New parser"
p tree

print "Classic parser"
p old.string code

return unless tree
compile = require "moonscript.compile"
print "\n=== New compile ==="
print (assert compile.tree tree)
print "\n=== Classic compile ==="
print (assert compile.tree old.string code)

-- syntax not implemented: 
[[
(okay) "world"
(cool)(fool)
"one"\dog!
x = if something then "yes"
{a} = {1}

with thing
  one

print \one

[==[WHOA!]==]

{"yes": "no"}
{[yes]: "no"}

a * b -- missing other operators
]]
