
#include <stdio.h>
#include <stack>

extern "C" {
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int luaopen_moonparse(lua_State *l);
}

void dump_stack(lua_State* l);

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

// starting a new parsing session
void begin() {
  pos_stack.push(lua_gettop(_l));
}

int start(const char* name=0) {
  if (name) {
    printf("* starting '%s'\n", name);
  } else {
    printf("* starting\n");
  }

  dump_stack(_l);

  lua_pushnil(_l); // slot for the finish object
  pos_stack.push(lua_gettop(_l));
  return 1;
}

int stop(const char* name=0) {
  if (name) {
    printf("* stop '%s'\n", name);
  } else {
    printf("* stop\n");
  }

  dump_stack(_l);

  int top = pos_stack.top();
  pos_stack.pop();

  lua_newtable(_l);

  if (name) {
    lua_pushstring(_l, name);
    lua_rawseti(_l, -2, 1);
  }

  lua_replace(_l, top); // put table in place of nil
  // pop values
  int cur = lua_gettop(_l);
  int i = cur - top;
  int offset = name ? 1 : 0;

  while (i >= 1) {
    lua_rawseti(_l, top, i-- + offset);
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

int push_string(const char* str) {
  printf("* pushing '%s'\n", str);
  lua_pushstring(_l, str);
  return 1;
}

// push a basic tuple on the top of the stack
// { name, value }
int push_simple(const char* name, const char* value) {
  printf("* pushing simple '%s' '%s'\n", name, value);
  lua_newtable(_l);
  lua_pushstring(_l, name);
  lua_rawseti(_l, -2, 1);

  lua_pushstring(_l, value);
  lua_rawseti(_l, -2, 2);
  return 1;
}

int flatten_last() {
  int len = lua_objlen(_l, -1);
  if (len == 2) {
    lua_rawgeti(_l, -1, 2);
    lua_remove(_l, -2);
  }
  return 1;
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

  if (yyparse()) return 1;
  return 0;
}

luaL_Reg funcs[] = {
  {"parse", parse}
};

int luaopen_moonparse(lua_State *l) {
  luaL_register(l, "moonparse", funcs);
  return 1;
}

// adapted from http://cc.byexamples.com/2008/11/19/lua-stack-dump-for-c/
void dump_stack(lua_State* l) {
  int i;
  int top = lua_gettop(l);

  printf("\nStack (total: %d)\n",top);

  for (i = top; i > 0; i--) {  /* repeat for each level */
    int t = lua_type(l, i);
    switch (t) {
      case LUA_TSTRING:  /* strings */
        printf("  string: '%s'\n", lua_tostring(l, i));
        break;
      case LUA_TBOOLEAN:  /* booleans */
        printf("  boolean %s\n",lua_toboolean(l, i) ? "true" : "false");
        break;
      case LUA_TNUMBER:  /* numbers */
        printf("  number: %g\n", lua_tonumber(l, i));
        break;
      default:  /* other values */
        printf("  %s\n", lua_typename(l, t));
        break;
    }
  }
  printf("\n\n");  /* end the listing */
}
