
import p from require "moon"
import parse from require "moonparse"
old = require "moonscript.parse"

code = [[




10 + 3

yes


3 + no

]]

tree = parse code
p tree

-- p old.string code
-- compile = require "moonscript.compile"
-- print (compile.tree tree)

