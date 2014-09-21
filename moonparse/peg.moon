
local *

operators = {"__add","__sub", "__mul", "__div", "__tostring"}

class Node
  __inherited: (child) =>
    for o in *operators
      continue if rawget child.__base, o
      child.__base[o] = @__base[o]

  __add: (a,b) -> AlternateNode a,b
  __sub: (a,b) -> error "no sub yet"
  __mul: (a,b) -> SequenceNode a,b
  __div: (a,b) -> error "divide not defined"

class OperatorNode extends Node
  p: 0
  op_text: " "
  new: (@left, @right) =>
    print "Op #{@@__name}"

  __tostring: =>
    print "#{@p}, left: #{@left.p}, right: #{@right.p}"
    left = tostring @left
    right = tostring @right

    if @left.p and @left.p < @p
      left = "( #{left} )"

    if @right.p and @right.p < @p
      right = "( #{right} )"

    left .. @op_text .. right

class AlternateNode extends OperatorNode
  p: 1
  op_text: " / "

class SequenceNode extends OperatorNode
  p: 2
  op_text: " "

class DefineNode extends OperatorNode

class Literal extends Node
  new: (@str) =>
  __tostring: =>
    if @str\match '"'
      "'#{@str}'"
    else
      '"' .. tostring(@str) .. '"'

class Identifier extends Node
  new: (@name) =>
  __tostring: =>
    tostring @name

build_grammar = (grammar) ->
  start = assert grammar[1], "missing grammar start state"

{
  I: Identifier
  P: Literal
  :build_grammar
}


