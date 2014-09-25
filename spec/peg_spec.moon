
peg = require "moonparse.peg"
import V, P, C, L, R, S, build_grammar from peg

same = (a,b) ->
  assert.same tostring(a), tostring(b)

describe "moonparse.peg", ->
  it "literal", ->
    same [["hello"]], P "hello"
    same [["dad's world"]], P "dad's world"
    same [['hello"world']], P 'hello"world'

    same ".", P(1)
    same "..", P(2)
    same "....", P(4)
    assert.has_error ->
      same "", P(0)

  it "sequence", ->

  it "pow", ->
    same "hello *",V"hello"^0
    same "hello +", V"hello"^1
    same "hello hello *", V"hello"^2
    same "hello hello hello *", V"hello"^3

    same "( hello world ) +", (V"hello" * V"world")^1

    same "hello ?", V"hello"^-1
    same "hello ? hello ?", V"hello"^-2
    same "hello ? hello ? hello ?", V"hello"^-3

    same "( hello world ) ? ( hello world ) ?", (V"hello" * V"world")^-2

  it "no consume", ->
    same [[& "hello"]], L P "hello"
    same [[& hello]], L "hello" -- TODO: should be coerced to P
    same [[& ( hello / world )]], L (V"hello" + V"world")

  it "capture", ->
    same [[< "hello" >]], C P "hello"
    same [[< hello >]], C "hello" -- TODO: coerce to P
    same [[< hello / world >]], C (V"hello" + V"world")


  it "range", ->
    same "[a-zA-Z]", R "az", "AZ"

  it "set", ->
    same "[abcd]", S "abcd"

  it "negate", ->
    same [[! "hello"]], -P"hello"
    same [[! hello]], -V"hello"
    same [[! ( hello world )]], -(V"hello" * V"world")
    same "[^abcd]", -S "abcd"



