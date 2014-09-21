
local *

operators = {"__add", "__sub", "__mul", "__div", "__pow", "__unm", "__tostring"}

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
  __unm: (a) -> Negate a

  __len: (a) -> UnaryOp a, "&", false

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
  -- p: 3 -- TODO:
  new: (@val, @op, @suffix=true) =>

  __tostring: =>
    val = if @val.is_operator
      "( #{@val} )"
    else
      "#{@val}"

    if @suffix
      "#{val} #{@op}"
    else
      "#{@op} #{val}"

class Negate extends UnaryOp
  new: (val) =>
    super val, "!", false

  __tostring: =>
    if @val.__class == Set
      set = Set @val.val
      set.negate = true
      return tostring set

    UnaryOp.__tostring @

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

class Capture extends Node
  new: (@val) =>
  __tostring: => "< #{@val} >"

-- TODO: escape -
class Set extends Node
  negate: false

  new: (@val) =>
  __tostring: =>
    if @negate
      "[^#{@val}]"
    else
      "[#{@val}]"

-- TODO: escape-
class Range extends Node
  new: (...) =>
    @pairs = {...}

  __tostring: =>
    ranges = for p in *@pairs
      switch #p
        when 1
          p
        when 2
          p\sub(1,1) .. "-" .. p\sub(2,2)
        else
          error "invalid range: #{p}"

    "[#{table.concat ranges}]"


class MatchTimeAction extends Node
  new: (@code) =>
  __tostring: =>
    "&{ #{@code} }"

class Action extends Node
  new: (@code) =>
  __tostring: =>
    "{ #{@code} }"

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
  C: Capture
  S: Set
  R: Range
  Mta: MatchTimeAction
  A: Action

  -- synonym for #
  L: (x) -> Node.__len x

  :build_grammar
}


