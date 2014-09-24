
import p from require "moon"
import parse from require "moonparse"
old = require "moonscript.parse"

code = [[
if hello then world
]]

tree = parse code
print "New parser"
p tree

-- print "Classic parser"
-- p old.string code

-- compile = require "moonscript.compile"
-- print (compile.tree tree)

