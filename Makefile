
.PHONY: test local

test:
	busted

local:
	luarocks make --local moonparse-dev-1.rockspec
