-- Test FFI cdata support.
package.path = "src/?.lua;"..package.path

-- No need to test if the FFI is not available.
local ffi_ok, ffi = pcall(require, "ffi")
if not ffi_ok then return end

local xtype = require("xtype")

do -- test vec example
  ffi.cdef("typedef struct{double x, y;} vec2_t;")
  local vec2 = xtype.create("vec2")
  local vec2_t = ffi.typeof("vec2_t")
  -- type behavior
  setmetatable(vec2, {
    xtype = "xtype",
    __call = function(_, ...) return vec2_t(...) end
  })
  -- instance behavior
  ffi.metatype(vec2_t, {
    __unm = function(v) return vec2(-v.x, -v.y) end,
    __add = xtype.op.add,
    __sub = xtype.op.sub,
    __mul = xtype.op.mul,
    __div = xtype.op.div,
    __eq = xtype.op.eq
  })
  xtype.op.add:define(function(a, b) return vec2(a.x+b.x, a.y+b.y) end, vec2, vec2)
  xtype.op.mul:define(function(v, n) return vec2(v.x*n, v.y*n) end, vec2, "number")
  xtype.op.mul:define(function(n, v) return vec2(v.x*n, v.y*n) end, "number", vec2)
  xtype.op.div:define(function(a, b) return vec2(a.x/b.x, a.y/b.y) end, vec2, vec2)
  xtype.op.div:define(function(v, n) return vec2(v.x/n, v.y/n) end, vec2, "number")
  xtype.op.eq:define(function(a, b) return a.x == b.x and a.y == b.y end, vec2, vec2)
  -- bind
  xtype.ctype(vec2_t, vec2)
  -- checks
  assert(vec2(1,1) == vec2(1,1))
  assert(vec2(1,1)*2 == 2*vec2(1,1))
  assert(vec2(1,1)+vec2(1,1) == vec2(4,4)/2)
  local a = ffi.new("vec2_t[1]", {{2,2}})
  local r = a[0]
  local p = a+0
  xtype.ctype(ffi.typeof(r), vec2)
  xtype.ctype(ffi.typeof(p), vec2)
  assert(r == p)
  assert(r == vec2(2,2))
  assert(r/p == vec2(1,1))
end
do -- test type acquisition from field
  ffi.cdef("typedef struct{} test_field_t;")
  local test_field = xtype.create("test_field")
  local ctype = ffi.typeof("test_field_t")
  ffi.metatype(ctype, {__index = {__xtype = test_field}})
  -- checks
  assert(xtype.get(ffi.new("test_field_t")) == test_field)
  assert(xtype.get(ffi.new("test_field_t*")) == test_field)
  local ar = ffi.new("test_field_t[1]")
  assert(xtype.get(ar[1]) == test_field)
end
