package = "moonparse"
version = "dev-1"

source = {
  url = "git://github.com/leafo/moonparse.git"
}

description = {
  summary = "A fast moonscript parser",
  homepage = "http://moonscript.org",
  maintainer = "Leaf Corcoran <leafot@gmail.com>",
  license = "MIT"
}

build = {
	type = "builtin",

  modules = {
    ["moonparse.peg"] = "moonparse/peg.lua",
		["moonparse"] = {
			sources = {"moonparse.cpp"},
      libraries = {"stdc++"},
		}
  },
	install = {
		bin = { "bin/moonparse" }
	},
}
