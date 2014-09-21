
peg = require "moonparse.peg"
import V, P, C, S, L, Mta, A, build_grammar from peg

print build_grammar {
  "start"

  space: S" \\t"^0
  break: "\\n"
  stop: V"break" + -P(1)

  start: V"block" * V"space" * -P(1)
  block: Mta'start("block")' * V"line" * (V"break" * V"line")^0 * Mta'accept()' + Mta'reject("block")'
  line: V"statement" + V"empty_line"
  empty_line: V"space" * L(V"stop")
  statement: C "hello" * Mta'push_simple("line","hello")'
}
