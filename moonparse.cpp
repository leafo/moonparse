
#include <stdio.h>
#include <stack>

extern "C" {
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int luaopen_moonparse(lua_State *l);
}

static const char* parse_buffer;
static size_t parse_buffer_len;
static int parse_buffer_pos;
static lua_State* _l;

static std::stack<int> pos_stack;

void set_parse_buffer(const char* buffer, const size_t len) {
  parse_buffer_pos = 0;
  parse_buffer = buffer;
  parse_buffer_len = len;
}

void put_input(char* buf, int* result, int max_size) {
  size_t remaining = parse_buffer_len - parse_buffer_pos;
  size_t num_chars = max_size < remaining ? max_size : remaining;

  // printf("reading %d chars (max: %d) (pos: %d) (len: %d)\n",
  //     num_chars, max_size, parse_buffer_pos, parse_buffer_len);

  for (int i = 0; i < num_chars; i++) {
    *(buf++) = parse_buffer[parse_buffer_pos++];
  }

  *result = num_chars;
}

void begin() {
  pos_stack.push(lua_gettop(_l));
}

void start() {
  lua_pushnil(_l);
  pos_stack.push(lua_gettop(_l));
}

void stop(const char* name) {
  int top = pos_stack.top();
  lua_newtable(_l);
  lua_pushstring(_l, name);
  lua_rawseti(_l, -2, 1);
}

void push_string(const char* str) {
  lua_pushstring(_l, str);
}

#define YY_INPUT(buf, result, max_size) put_input(buf, &result, max_size)

#include "parse.h"

int parse(lua_State* l) {
  size_t len;
  const char* input = luaL_checklstring(l, 1, &len);
  _l = l;
  set_parse_buffer(input, len);

  printf("input: %s\n", input);
  while (yyparse()) {
    lua_pushboolean(l, 1);
    return 1;
  }

  return 0;
}

luaL_Reg funcs[] = {
  {"parse", parse}
};

int luaopen_moonparse(lua_State *l) {
  luaL_newlib(l, funcs);
  return 1;
}

