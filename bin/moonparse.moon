import parse from require "moonparse"

fname = ...

code = if fname
  file = assert io.open fname
  with file\read "*a"
    file\close!
else
  io.stdout\read "*a"

require("moon").p parse code

