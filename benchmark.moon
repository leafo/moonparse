

socket = require "socket"

import parse from require "moonparse"
old = require "moonscript.parse"
old_parse = old.string

times = 4000
code = [[
for i=2,3
  for i=2,3,4
    if okay
      yeah
]]

start = socket.gettime!
for i=1,times
  assert parse code
print "New: #{socket.gettime! - start}"


start = socket.gettime!
for i=1,times
  assert old_parse code
print "Old: #{socket.gettime! - start}"

