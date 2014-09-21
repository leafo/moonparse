
peg = require "moonparse.peg"
import I, P from peg

-- print I"hello" + P"yeah" * I"bar"
print I"bar" * (I"hello" + P"yeah")
