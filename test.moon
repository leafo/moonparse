
import p from require "moon"
import parse from require "moonparse"

code = [[10 + 3]]

tree = parse code
p tree

-- compile = require "moonscript.compile"
-- print (compile.tree tree)

