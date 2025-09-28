local Tycoon = require(script.Parent.Tycoon)
local PlayerManager = require(script.Parent.PlayerManager)

local function FindSpawn()
	for _, spawnPoint in ipairs(workspace.Spawns:GetChildren()) do
		if not spawnPoint:GetAttribute("Occupied") then
			return spawnPoint
		end
	end
end

PlayerManager.Start()

--[[ here we use PlayerAdded instead of just Players.PlayerAdded, because it's better.
It only fires after:
- the player has joined,
- leaderstats are created,
- PlayerManager has finished the basic initialization.
]]

PlayerManager.PlayerAdded:Connect(function(player)
	local tycoon = Tycoon.new(player, FindSpawn())
	tycoon:Init()
end)