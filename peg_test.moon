
peg = require "moonparse.peg"
import V, P, C, build_grammar from peg

print P(12)

print build_grammar {
  V"hello"

  hello: V"bar" * (V"hello" + P"yeah")
  world: C(P"hello" + V"yeah") * "test"
}
