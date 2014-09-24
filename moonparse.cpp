
#include <stack>
#include <cstring>
#include <cstdio>

#define DEBUG 0

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
static std::stack<int> indent_stack;

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
  if (DEBUG) {
    if (name) {
      printf("* starting '%s'\n", name);
    } else {
      printf("* starting\n");
    }
  }

  lua_pushnil(_l); // slot for the finish object
  pos_stack.push(lua_gettop(_l));
  return 1;
}

int accept(const char* name=0) {
  if (DEBUG) {
    if (name) {
      printf("* accept '%s'\n", name);
    } else {
      printf("* accept\n");
    }
  }

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

int reject(const char* name=0) {
  if (DEBUG) {
    if (name) {
      printf("* rejecting '%s'\n", name);
    } else {
      printf("* rejecting\n");
    }
  }

  int top = pos_stack.top();
  pos_stack.pop();
  lua_settop(_l, top - 1);

  return 0;
}

int push_string(const char* str) {
  if (DEBUG) {
    printf("* pushing '%s'\n", str);
  }

  lua_pushstring(_l, str);
  return 1;
}

// push a basic tuple on the top of the stack
// { name, value }
int push_simple(const char* name, const char* value) {
  if (DEBUG) {
    printf("* pushing simple '%s' '%s'\n", name, value);
  }

  lua_newtable(_l);
  lua_pushstring(_l, name);
  lua_rawseti(_l, -2, 1);

  lua_pushstring(_l, value);
  lua_rawseti(_l, -2, 2);
  return 1;
}

// converts a single value exp to just the value
int flatten_last() {
  int len = lua_objlen(_l, -1);
  if (len == 2) {
    lua_rawgeti(_l, -1, 2);
    lua_remove(_l, -2);
  }
  return 1;
}

int check_indent(const char* indent) {
  if (DEBUG) {
    printf("checking indent: %d\n", strlen(indent));
  }

  if (indent_stack.empty()) {
    return 0 == strlen(indent);
  }

  return indent_stack.top() == strlen(indent);
}

int push_indent(const char* indent) {
  indent_stack.push(strlen(indent));
  return 1;
}

int pop_indent() {
  indent_stack.pop();
  return 1;
}

// only pushes if indent is greater, otherwise fails
int advance_indent(const char* indent) {
  int new_indent = strlen(indent);
  int top = 0;

  if (!indent_stack.empty()) {
    top = indent_stack.top();
  }

  if (new_indent <= top) {
    return 0;
  }

  indent_stack.push(new_indent);
  return 1;
}


int _debug(const char* msg, int ret) {
  if (DEBUG) {
    printf("DEBUG: %s\n", msg);
  }
  return ret;
}

#define YY_INPUT(buf, result, max_size) put_input(buf, &result, max_size)

#include "parse2.h"

int parse(lua_State* l) {
  size_t len;
  const char* input = luaL_checklstring(l, 1, &len);
  _l = l;

  pos_stack = std::stack<int>();
  begin();

  set_parse_buffer(input, len);

  if (DEBUG) {
    printf("input: %s\n", input);
  }

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
