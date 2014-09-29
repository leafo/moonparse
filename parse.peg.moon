
peg = require "moonparse.peg"
import V, P, C, S, L, Mta, A, build_grammar from peg

-- runs patterns inside a new capture table (optionally named)
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

-- captures pattern into string then creates a 1 element tuple
simple = (name, p) ->
  assert name, "missing name for `simple`"
  assert p, "missing pattern for `simple`"

  C(p) * Mta"push_simple(\"#{name}\", yytext)"

-- pushes string capture on stack
str = (p) ->
  if type(p) == "string"
    Mta"push_string(\"#{p}\")"
  else
    C(p) * Mta"push_string(yytext)"

_ = V"space"
alpha_num = S"a-zA-Z_0-9"
advance_indent = L C(_) * Mta'advance_indent(yytext)'
check_indent = C(_) * Mta'check_indent(yytext)'

pop_indent = Mta'pop_indent()'
push_indent = C(_) * Mta'push_indent(yytext)'

ensure = (p, ensure_with) ->
  p * ensure_with + ensure_with * Mta'0'

debug = (msg, pass=true) ->
  ret = pass and "1" or "0"
  Mta"_debug(\"#{msg}\", #{ret}, yy->__pos)"

-- an operator symbol
sym = (str, white=true) ->
  if white
    _ * P(str)
  else
    P(str)

-- a language keyword
key = (name) -> _ * P(name) * -alpha_num

empty_table = capture P"" -- todo make more efficient

-- either the single line or a body for a statement
line_or_body = (prefix) ->
  stm = capture V"statement"
  if prefix
    stm = key(prefix) * stm

  suffix = stm + V"break" * V"body"
  _ * suffix

print build_grammar {
  "start"

  space: S" \\t"^0
  some_space: S" \\t"^1
  break: "\\n"
  stop: V"break" + -P(1)

  start: V"block" * _ * -P(1)
  block: capture V"line" * (V"break" * V"line")^0

  line: check_indent * V"statement" + V"empty_line"
  empty_line: _ * L V"stop"

  value: _ * (V"table_lit" + V"fn_lit" + V"unbounded_table" + V"number" + V"ref")
  word: S"a-zA-Z_" * alpha_num^0
  ref: simple "ref", V"word"
  ref_list: V"ref" * (sym"," * V"ref")^0

  number: simple "number", S"0-9"^1

  op: _ * str(S"-+")
  exp: capture "exp", V"value" * (V"op" * V"value")^0, "flatten_last()"
  exp_list: V"exp" * (sym"," * V"exp")^0

  statement: (V"if" + V"for" + V"while" + V"assign" + V"exp") * _ * L(V"stop")

  if: capture "if", key"if" * V"exp" * line_or_body"then"

  for: capture "for", key"for" * _ * str(V"word") * sym"=" * V"for_range" * line_or_body"do"
  for_range: capture V"exp" * sym"," * V"exp" * (sym"," * V"exp")^-1

  while: capture "while", key"while" * V"exp" * line_or_body"do"

  assign: capture "assign", capture(V"ref_list") * sym"=" * capture(V"exp_list")

  body: advance_indent * capture ensure V"line" * (V"break" * V"line")^0, pop_indent

  unbounded_table: capture "table", capture V"key_value_list"
  key_value_list: V"key_value" * (sym"," * V"key_value")^0
  key_value: V"table_self_assign" + _ * V"table_assign"
  table_assign: capture simple("key_literal", V"word") * sym(":", false) * V"exp"

  -- TODO: this is lame to match twice, refector the moonscript compiler
  table_self_assign: sym":" * -V"some_space" * capture capture("key_literal", L(str V"word")) * simple "ref", V"word"

  fn_lit: capture "fndef", V"fn_args" * empty_table * sym"->" * str"slim" * (line_or_body! + empty_table)
  fn_args: capture V"fn_args_inner"^-1
  fn_args_inner: sym"(" * (V"fn_arg" * (sym"," * V"fn_arg")^0)^-1 * sym")"
  fn_lit_peek: L _ * S"-("

  -- name followed by optional default value
  fn_arg: _ * capture str(V"word") * (sym"=" * V"exp")^-1

  table_lit: capture "table", sym"{" * capture((V"table_value_list" * sym","^-1)^-1 * V"table_lit_line"^0) * sym"}"
  table_value_list: V"table_value" * (sym"," * V"table_value")^0
  table_value: V"key_value" + capture V"exp"
  table_lit_line: _ * V"break" * (push_indent * ensure(V"table_value_list", pop_indent) + _)
}
