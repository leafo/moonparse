
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


_ = V"space"
alpha_num = S"a-zA-Z_0-9"
advance_indent = L C(_) * Mta'advance_indent(yytext)'
check_indent = C(_) * Mta'check_indent(yytext)'

pop_indent = Mta'pop_indent()'

ensure = (p, ensure_with) ->
  p * ensure_with + ensure_with * Mta'0'

debug = (msg) ->
  Mta"_debug(\"#{msg}\", 1)"

-- an operator symbol
sym = (str) -> _ * P(str)

-- a language keyword
key = (name) -> _ * P(name) * -alpha_num

-- either the single line or a body for a statement
line_or_body = (prefix) ->
 key(prefix) * (capture V"exp") + V"break" * V"body"

print build_grammar {
  "start"

  space: S" \\t"^0
  break: "\\n"
  stop: V"break" + -P(1)

  start: V"block" * _ * -P(1)
  block: capture V"line" * (V"break" * V"line")^0

  line: check_indent * V"statement" + V"empty_line"
  empty_line: _ * L(V"stop") * debug"got empty line"

  value: _ * (V"number" + V"ref")
  word: S"a-zA-Z_" * alpha_num^0
  ref: simple "ref", V"word"
  number: simple "number", S"0-9"^1

  op: _ * str(S"-+")
  exp: capture "exp", V"value" * (V"op" * V"value")^0, "flatten_last()"

  statement: (V"if" + V"for" + V"exp") * _ * L(V"stop")
  if: capture "if", key"if" * V"exp" * _ * line_or_body"then"

  for: capture "for", key"for" * _ * str(V"word") * sym"=" * V"for_range" * _ * line_or_body"do"
  for_range: capture V"exp" * sym"," * V"exp" * (sym"," * V"exp")^-1

  body: advance_indent * capture ensure V"line" * (V"break" * V"line")^0, pop_indent
}
