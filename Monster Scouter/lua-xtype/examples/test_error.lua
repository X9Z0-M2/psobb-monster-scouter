-- Test errors.
package.path = "src/?.lua;"..package.path
local xtype = require("xtype")

local function errcheck(perr, f, ...)
  local ok, err = pcall(f, ...)
  assert(not ok and not not err:find(perr))
end

do -- test xtype
  errcheck("bad argument #1", xtype.create)
  errcheck("bad argument #1", xtype.create, 5)
  errcheck("bad argument #2", xtype.create, "test", 5)
  errcheck("bad argument #2", xtype.is, 5, nil)
  errcheck("bad argument #1", xtype.of, 5, "number")
  errcheck("bad argument #2", xtype.of, "number", 5)
end
do -- test multifunction
  local mf = xtype.multifunction()
  errcheck("type expected", mf.define, mf, function() end, nil)
  errcheck("type expected", mf.define, mf, function() end, 1)
  errcheck("type expected", mf.define, mf, nil, "number", nil, "number")
  mf:define(function() end, "number", "number")
  mf(5,5)
  errcheck("unresolved call signature", mf)
  errcheck("unresolved call signature", mf, 5)
  errcheck("unresolved call signature", mf, 5, 5, 5)
  errcheck("unresolved call signature", mf, 5, "5")
  mf:define(nil, "number", "number")
  errcheck("unresolved call signature", mf, 5, 5)
  -- test ambiguity
  local A = xtype.create("A")
  local B = xtype.create("B")
  local C = xtype.create("C", A, B)
  mf:define(function() end, A, B)
  mf:define(function() end, B, A)
  errcheck("ambiguous call signature", mf.resolve, mf, C, C)
end
