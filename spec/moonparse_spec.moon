
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


