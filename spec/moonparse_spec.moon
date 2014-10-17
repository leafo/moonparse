
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

  it "should parse numeric for", ->
    assert.same {
      {
        "for"
        "i"
        {
          {"number", "1"}
          {"number", "3"}
        }
        {
          {"ref", "okay"}
        }
      }
    }, parse "for i=1,3 do okay"


    assert.same {
      {
        "for"
        "i"
        {
          {"number", "1"}
          {"number", "3"}
        }
        {
          {"ref", "okay"}
        }
      }
    }, parse [[
for i=1,3
  okay
]]

  it "should parse numeric for with step", ->
    assert.same {
      {
        "for"
        "i"
        {
          {"number", "1"}
          {"number", "3"}
          {"ref", "hello"}
        }
        {
          {"ref", "okay"}
        }
      }
    }, parse "for i=1,3,hello do okay"


    assert.same {
      {
        "for"
        "i"
        {
          {"number", "1"}
          {"number", "3"}
          {"ref", "hello"}
        }
        {
          {"ref", "okay"}
        }
      }
    }, parse [[
for i=1,3,hello
  okay
]]


  it "should while", ->
    assert.same {
      {
        "while"
        {"ref", "yeah"}
        {
          {"ref", "okay"}
        }
      }
    }, parse "while yeah do okay"

    assert.same {
      {
        "while"
        {"ref", "yeah"}
        {
          {"ref", "okay"}
        }
      }
    }, parse [[
while yeah
  okay
]]


  it "should parse assign", ->
    assert.same {
      {
        "assign"
        {
          {"ref", "a"}
        }
        {
          {"ref", "b"}
        }
      }
    }, parse "a = b"

    assert.same {
      {
        "assign"
        {
          {"ref", "a"}
          {"ref", "b"}
        }
        {
          {"ref", "b"}
          {"ref", "a"}
        }
      }
    }, parse "a,b = b,a"


  it "should match unbounded table", ->
    assert.same {
      {
        "table"
        {
          {
            {
              "key_literal"
              "hello"
            }
            {
              "ref"
              "world"
            }
          }
        }
      }
    }, parse[[hello: world]]

    assert.same {
      {
        "table"
        {
          {
            {
              "key_literal"
              "hello"
            }
            {
              "ref"
              "world"
            }
          }

          {
            {
              "key_literal"
              "world"
            }
            {
              "ref"
              "hello"
            }
          }

        }
      }
    }, parse[[hello: world, world: hello]]

  it "should match unbounded table self assign", ->
    assert.same {
      {
        "table"
        {
          {
            {
              "key_literal"
              "hello"
            }
            {
              "ref"
              "hello"
            }
          }
        }
      }
    }, parse[[:hello]]

  it "should parse function literal", ->
    assert.same {
      {
        "fndef"
        { }
        { }
        "slim"
        { }
      }
    }, parse[[->]]

    assert.same {
      {
        "fndef"
        { }
        { }
        "slim"
        {
          {
            "ref"
            "hello"
          }
        }
      }
    }, parse[[-> hello]]

    assert.same {
      {
        "fndef"
        { }
        { }
        "slim"
        {
          {
            "ref"
            "hello"
          }
          {
            "ref"
            "yeah"
          }
        }
      }
    }, parse[[
->
  hello
  yeah
]]


  it "should parse function with args", ->
    assert.same {
      {
        "fndef"
        {}
        {}
        "slim"
        {}
      }
    }, parse[[()->]]
    assert.same {
      {
        "fndef"
        {}
        {}
        "slim"
        {}
      }
    }, parse[[() ->]]

    assert.same {
      {
        "fndef"
        {
          { "a" }
        }
        {}
        "slim"
        {}
      }
    }, parse[[(a) ->]]
    assert.same {
      {
        "fndef"
        {
          { "a" }
          { "b" }
        }
        {}
        "slim"
        {}
      }
    }, parse[[(a,b) ->]]


  it "should parse single line table", ->
    assert.same {
      {
        "table"
        {}
      }
    }, parse[[{}]]

    assert.same {
      {
        "table"
        {
          {
            {"ref", "a"}
          }
        }
      }
    }, parse[[{a}]]


    assert.same {
      {
        "table"
        {
          { {"ref", "a"} }
          { {"ref", "b"} }
        }
      }
    }, parse[[{ a,   b,}]]

    assert.same {
      {
        "table"
        {
          {
            {"key_literal", "hello"}
            {"ref", "world"}
          }
        }
      }
    }, parse[[{ hello: world }]]

    assert.same {
      {
        "table"
        {
          { {"ref", "a"} }
          {
            {"key_literal", "hello"}
            {"ref", "world"}
          }
          { {"ref", "b"} }
        }
      }
    }, parse[[{ a, hello: world, b }]]


  it "should parse multi line table", ->
    assert.same {
      {
        "table"
        {}
      }
    }, parse [[
{

}
]]

    assert.same {
      {
        "table"
        {
          { {"ref", "a"} }
          { {"ref", "b"} }
        }
      }
    }, parse [[
{
a
b
}
]]


    assert.same {
      {
        "table"
        {
          {
            {"key_literal", "hello"}
            {"ref", "world"}
          }
          { {"ref", "a"} }
          {
            {"key_literal", "foo"}
            {"ref", "bar"}
          }
        }
      }
    }, parse [[
{
  hello: world, a
foo: bar
}
]]

  it "should parse chain", ->
    assert.same {
      {
        "chain"
        { "ref", "one" }
        { "dot", "hello" }
        { "call", {
          {"ref", "world"}
          {"exp", {"ref", "foo"}, "+", {"ref", "bar"}}
          {"chain", {"ref", "boba"}, {"call", {
            {"ref", "cat"}
          }}}
        }}
      }
    }, parse[[one.hello world, foo + bar, boba cat]]


  it "should parse simple string", ->
    assert.same {
      {
        "string"
        '"'
        "he'llo"
      }
    }, parse[["he'llo"]]

    assert.same {
      {
        "string"
        "'"
        'he"llo'
      }
    }, parse[['he"llo']]


  it "should parse string interpolation", ->
    assert.same {
      {
        "string"
        '"'
        "he"
        {
          "interpolation"
          { "ref", "a" }
        }
        "llo"
      }
    }, parse[["he#{a}llo"]]



  it "should parse escape sequence", ->
    assert.same {
      {
        "string"
        "'"
        [[h\'e]]
      }
    }, parse[['h\'e']]

    assert.same {
      {
        "string"
        '"'
        [[h\"e]]
      }
    }, parse[["h\"e"]]



  it "should parse function with parens", ->
    assert.same {
      {
        "chain"
        {"ref", "hello"}
        {"call", {}}
      }
    }, parse[[hello(   )]]

    assert.same {
      {
        "chain"
        {"ref", "hello"}
        {"call", {
          {"ref", "a"}
        }}
      }
    }, parse[[hello( a )]]

    assert.same {
      {
        "chain"
        {"ref", "hello"}
        {"call", {
          {"ref", "a"}
          {"ref", "b"}
        }}

        {"call", { }}
      }
    }, parse[[hello( a,b )()]]

  it "should parse basic generic for comprehension", ->
    assert.same {
      {
        "comprehension"
        { "ref", "x" }
        {
          {
            "foreach"
            {"x"}
            {"ref", "y"}
          }
        }
      }
    }, parse"[x for x in y]"


  it "should parse basic numeric for comprehension", ->
    assert.same {
      {
        "comprehension"
        { "ref", "x" }
        {
          {
            "for"
            "x"
            {
              {"ref", "a"}
              {"ref", "b"}
            }
          }
        }
      }
    }, parse"[x for x=a,b]"


  it "should parse basic class", ->
    assert.same {
      {
        "class"
        "Thing"
        ""
        {
          {
            "props"
            {
              { "key_literal", "color" }
              { "ref", "blue" }
            }
          }
        }
      }
    }, parse [[class Thing
    color: blue]]


    assert.same {
      {
        "class"
        "Thing"
        ""
        {
          {
            "props"
            {
              { "key_literal", "color" }
              { "ref", "blue" }
            }
          }

          {
            "props"
            {
              { "key_literal", "height" }
              { "number", "123" }
            }
          }
        }
      }
    }, parse [[class Thing
    color: blue
    height: 123]]

  it "should parse class with extends", ->
    assert.same {
      {
        "class"
        "Thing"
        { "number", "123" }
        {
          {
            "props"
            {
              { "key_literal", "color" }
              { "ref", "blue" }
            }
          }
        }
      }
    }, parse [[class Thing extends 123
    color: blue]]


  it "should parse class with expressions in body", ->
    assert.same {
      {
        "class"
        "Thing"
        { "ref", "Hello" }
        {
          {
            "stm"
            {
              "if"
              {"ref", "cool"}
              {
                {
                  "chain"
                  {"ref", "print"}
                  {"call", {
                    {"string", '"', "hello"}
                  }}
                }
              }
            }
          }
        }
      }
    }, parse [[class Thing extends Hello
  if cool
    print "hello"]]

