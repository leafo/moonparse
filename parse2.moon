
peg = require "moonparse.peg"
import V, P, C, S, L, Mta, A, build_grammar from peg

capture = (name, p, extra_c) ->
  if type(name) == "table"
    extra_c = p
    p = name
    name = nil

  escaped_name = if name
    "\"#{name}\""
  else
    ""

  finalize = "accept(#{escaped_name})"
  if extra_c
    finalize = "#{finalize}, #{extra_c}"

  Mta"start(#{escaped_name})" * p * Mta(finalize) + Mta"reject(#{escaped_name})"

simple = (name, p) ->
  C(p) * Mta"push_simple(\"#{name}\", yytext)"

str = (p) ->
  C(p) * Mta"push_string(yytext)"


print build_grammar {
  "start"

  space: S" \\t"^0
  break: "\\n"
  stop: V"break" + -P(1)

  start: V"block" * V"space" * -P(1)
  block: capture V"line" * (V"break" * V"line")^0

  line: V"statement" + V"empty_line"
  empty_line: V"space" * L(V"stop")

  value: V"space" * (V"number" + V"ref")
  ref: simple "ref", S"a-zA-Z_" * S"a-zA-Z_0-9"^0
  number: simple "number", S"0-9"^1

  op: V"space" * str(S"-+")
  exp: capture "exp", V"value" * (V"op" * V"value"), "flatten_last()"

  statement: C(V"space") * Mta'check_indent(yytext)' * (V"if" + V"exp") * V"space" * L(V"stop")
  -- if: capture "if",
  --   P"if" * V"exp" * V"space" * P"then" * ()
}
