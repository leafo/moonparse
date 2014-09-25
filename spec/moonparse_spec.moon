
import parse from require "moonparse"

describe "moonparse.peg", ->
  it "should parse empty string", ->
    assert.same {}, parse ""

  it "should parse refs", ->
    assert.same {
      {"ref", "hello"}
    }, parse "hello"

    assert.same {
      {"ref", "hello"}
      {"ref", "world"}
    }, parse [[
hello
world]]


  it "should parse expressions", ->
    assert.same {
      {"exp", {"ref", "a"}, "+", {"number", "345"}}
    }, parse "a + 345"

    assert.same {
      {"exp", {"number", "3"}, "-", {"number", "5"}}
      {"exp", {"ref", "a"}, "+", {"ref", "c"}}
    }, parse [[
3 - 5
a + c
]]

  it "should parse if statement", ->
    assert.same {
      {
        "if"
        {"ref", "something"}
        {
          {"ref", "yeah"}
        }
      }
    }, parse [[
if something
  yeah
]]

  it "should parse if statement single line", ->
    assert.same {
      {
        "if"
        {"ref", "something"}
        {
          {"ref", "yeah"}
        }
      }
    }, parse [[
if something then yeah
]]


