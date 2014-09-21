
peg = require "moonparse.peg"
import V, P, C, S, build_grammar from peg

print -S"a-z"

-- print (V"hello" * V"world")^-2

-- print build_grammar {
--   V"hello"
-- 
--   hello: V"bar" * (V"hello" + P"yeah")
--   world: C(P"hello" + V"yeah") * "test"
-- }
