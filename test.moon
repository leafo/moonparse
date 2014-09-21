
import p from require "moon"
import parse from require "moonparse"
old = require "moonscript.parse"

code = [[
if hello then world
1 + 5
]]

code = [[
hello
hello
]]

tree = parse code
p tree

-- print "Classic parser"
-- p old.string code

-- compile = require "moonscript.compile"
-- print (compile.tree tree)

