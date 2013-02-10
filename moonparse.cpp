
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

int start() {
  printf("* starting\n");
  lua_pushnil(_l);
  pos_stack.push(lua_gettop(_l));
  return 1;
}

int stop(const char* name) {
  printf("* stop '%s'\n", name);
  int top = pos_stack.top();
  pos_stack.pop();

  lua_newtable(_l);
  lua_pushstring(_l, name);
  lua_rawseti(_l, -2, 1);

  lua_replace(_l, top); // put table in place of nil
  // pop values
  int cur = lua_gettop(_l);
  int i = cur - top;
  while (i >= 1) {
    lua_rawseti(_l, top, i-- + 1);
  }

  return 1;
}

int reject() {
  printf("* rejecting\n");

  int top = pos_stack.top();
  pos_stack.pop();
  lua_settop(_l, top);

  return 0;
}

void push_string(const char* str) {
  printf("* pushing '%s'\n", str);
  lua_pushstring(_l, str);
}

void push_simple(const char* name, const char* value) {
  printf("* pushing simple '%s' '%s'\n", name, value);
  lua_newtable(_l);
  lua_pushstring(_l, name);
  lua_rawseti(_l, -2, 1);

  lua_pushstring(_l, value);
  lua_rawseti(_l, -2, 2);
}

void flatten_last() {
  int len = lua_rawlen(_l, -1);
  if (len == 2) {
    lua_rawgeti(_l, -1, 2);
    lua_remove(_l, -2);
  }
}

#define YY_INPUT(buf, result, max_size) put_input(buf, &result, max_size)

#include "parse.h"

int parse(lua_State* l) {
  size_t len;
  const char* input = luaL_checklstring(l, 1, &len);
  _l = l;

  pos_stack = std::stack<int>();
  begin();

  set_parse_buffer(input, len);

  printf("input: %s\n", input);

  if (yyparse()) {
    printf("pos: %d len: %d\n", parse_buffer_pos, parse_buffer_len);
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

