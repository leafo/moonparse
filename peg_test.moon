
peg = require "moonparse.peg"
import V, P, C, build_grammar from peg

-- print (V"hello" * V"world")^-2

-- print build_grammar {
--   V"hello"
-- 
--   hello: V"bar" * (V"hello" + P"yeah")
--   world: C(P"hello" + V"yeah") * "test"
-- }
