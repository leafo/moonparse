

import p from require "moon"
import parse from require "moonparse"
old = require "moonscript.parse"

code = [[
x = :hello
]]

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

