-- Benchmark multifunction call.
package.path = "src/?.lua;"..package.path

local xtype = require("xtype")

local Entity = xtype.create("Entity")
local Player = xtype.create("Player", Entity)
local Mob = xtype.create("Mob", Entity)

local f = xtype.multifunction()
local entities = {}
local player_count = 0
for i=1,1e3 do
  local T = math.random() <= 1/2 and Player or Mob
  if T == Player then player_count = player_count+1 end
  table.insert(entities, setmetatable({}, {xtype = T}))
end

local n = ...; n = tonumber(n) or 1e4
local count
f:define(function() count=count+1 end, Player)
f:define(function() end, Mob)
for i=1, n do
  count = 0
  for _, entity in ipairs(entities) do f(entity) end
  assert(count == player_count)
end
