
import parse from require "moonparse"

describe "moonparse.peg", ->
  it "should parse empty string", ->
    assert.same {}, parse ""


