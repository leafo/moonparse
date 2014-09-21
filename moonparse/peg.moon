
local *

operators = {"__add","__sub", "__mul", "__div", "__pow", "__tostring"}

class Node
  __inherited: (child) =>
    for o in *operators
      continue if rawget child.__base, o
      child.__base[o] = @__base[o]

  __add: (a,b) -> AlternateOp a,b
  __sub: (a,b) -> error "no sub yet"
  __mul: (a,b) -> SequenceOp a,b
  __div: (a,b) -> error "divide not defined"
  __pow: (a,b) -> RepeatOp a,b

class OperatorNode extends Node
  is_operator: true
  p: 0
  op_text: " "
  new: (@left, @right) =>
    -- coerce operators
    if type(@left) != "table"
      @left = Literal @left

    if type(@right) != "table"
      @right = Literal @right

  __tostring: =>
    left = tostring @left
    right = tostring @right

    if @left.p and @left.p < @p
      left = "( #{left} )"

    if @right.p and @right.p < @p
      right = "( #{right} )"

    left .. @op_text .. right

class AlternateOp extends OperatorNode
  p: 1
  op_text: " / "

class SequenceOp extends OperatorNode
  p: 2
  op_text: " "

class UnaryOp extends Node
  -- p: 3
  new: (@val, @rep) =>

  __tostring: =>
    val = if @val.is_operator
      "( #{@val} )"
    else
      "#{@val}"

    "#{val} #{@rep}"

RepeatOp = (a, b) ->
  assert type(b), "number"

  if b == 1
    return UnaryOp a, "+"

  if b == -1
    return UnaryOp a, "?"

  if b >= 0
    inside = UnaryOp a, "*"
    while b > 1
      b -= 1
      inside = SequenceOp a, inside
    return inside

  if b < 0
    b = -b
    inside = UnaryOp a, "?"
    while b > 1
      b -= 1
      inside = SequenceOp UnaryOp(a, "?"), inside

    return inside

  error "Not sure how to handle rep #{b}"

class DefineOp extends OperatorNode
  op_text: " <- "
  new: (left, right) =>
    if type(left) != "table"
      left = Identifier left

    super left, right

class Literal extends Node
  new: (@val) =>

  __tostring: =>
    if type(@val) == "number"
      error "not yet" if @val < 1
      return "."\rep @val

    if @val\match '"'
      "'#{@val}'"
    else
      '"' .. tostring(@val) .. '"'

class Identifier extends Node
  new: (@name) =>
  __tostring: =>
    tostring @name

class Group extends Node
  new: (@inside) =>
  __tostring: => "< #{@inside} >"

build_grammar = (grammar) ->
  start = assert grammar[1], "missing grammar start state"
  start_val = tostring start
  start_rule = assert grammar[start_val], "missing start rule"

  buffer = {
    tostring DefineOp start, start_rule
  }

  for k,v in pairs grammar
    continue if type(k) == "number"
    continue if k == start_val
    table.insert buffer, tostring DefineOp k, v

  table.concat buffer, "\n"

{
  V: Identifier
  P: Literal
  C: Group

  :build_grammar
}


