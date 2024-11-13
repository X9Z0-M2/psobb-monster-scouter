-- Benchmark type checking.
package.path = "src/?.lua;"..package.path

local xtype = require("xtype")

local Entity = xtype.create("Entity")
local Player = xtype.create("Player", Entity)
local Mob = xtype.create("Mob", Entity)

local entities = {}
local player_count = 0
for i=1,1e3 do
  local T = math.random() <= 1/2 and Player or Mob
  if T == Player then player_count = player_count+1 end
  table.insert(entities, setmetatable({}, {xtype = T}))
end

local n = ...; n = tonumber(n) or 1e4
for i=1, n do
  local count = 0
  for _, entity in ipairs(entities) do
    if xtype.is(entity, Player) then count = count+1 end
  end
  assert(count == player_count)
end
