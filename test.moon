
import p from require "moon"
import parse from require "moonparse"
old = require "moonscript.parse"

code = [[
if hello
  world
  piss

if yea then hi
]]

tree = parse code
print "New parser"
p tree

print "Classic parser"
p old.string code

-- compile = require "moonscript.compile"
-- print "\n=== New compile ==="
-- print (compile.tree tree)
-- print "\n=== Classic compile ==="
-- print (compile.tree old.string code)

