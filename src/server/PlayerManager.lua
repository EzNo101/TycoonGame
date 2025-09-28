local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local PlayerData = DataStoreService:GetDataStore("PlayerData_Debug1")
local MarketplaceService = game:GetService("MarketplaceService")
local Gamepasses = require(script.Parent.Gamepasses)

local function Reconcile(source, template)
	for k, v in pairs(template) do
			-- check if source table have all keys from template
		if not source[k] then
			-- if not then add key with default value from template
			source[k] = v
		end
	end
	return source
end

function LeaderboardSetup(value)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	
	local money = Instance.new("IntValue")
	money.Value = value
	money.Name = "Money"
	money.Parent = leaderstats
	return leaderstats
end

local function LoadData(player)
	local success, result = pcall(function()
		return PlayerData:GetAsync(player.UserId)
	end)
	if not success then
		warn(result)
	end
	return success, result
end

local function SaveData(player, data)
	local success, result = pcall(function()
		PlayerData:SetAsync(player.UserId, data)
	end)
	if not success then
		warn(result)
	end
	return success
end

local sessionData = {}

local playerAdded = Instance.new("BindableEvent")
local playerRemoving = Instance.new("BindableEvent")

local PlayerManager = {}

PlayerManager.PlayerAdded = playerAdded.Event
PlayerManager.PlayerRemoving = playerRemoving.Event

function PlayerManager.Start()
	-- reinsurance
	for _, player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(PlayerManager.OnPlayerAdded)(player)
	end
	
	Players.PlayerAdded:Connect(PlayerManager.OnPlayerAdded)
	Players.PlayerRemoving:Connect(PlayerManager.OnPlayerRemoving)
	
	game:BindToClose(PlayerManager.OnClose)
end

function PlayerManager.OnPlayerAdded(player)
	PlayerManager.RegisterGamepasses(player)
	-- we connect an anonymous function here because ":Connect" expects a function, not the result of a call
	player.CharacterAdded:Connect(function(character)
		PlayerManager.OnCharacterAdded(player, character)
	end)
	
	local success, data = LoadData(player)
	-- if sucess return data else return default data
	sessionData[player.UserId] = Reconcile(
		if success then data else {},
		{
			Money = 0,
			UnlockIds = {},
			Multiplier = 1,
		}
	)
	
	local leaderstats = LeaderboardSetup(PlayerManager.GetMoney(player))
	leaderstats.Parent = player
	
	playerAdded:Fire(player)
end

function PlayerManager.OnCharacterAdded(player, character)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			wait(3)
			player:LoadCharacter()
		end)
	end
end

function PlayerManager.GetMoney(player)
	return sessionData[player.UserId].Money
end

function PlayerManager.SetMoney(player, value)
	if value then
		sessionData[player.UserId].Money = value
		local leaderstats = player:FindFirstChild("leaderstats") 
		if leaderstats then
			local money = leaderstats:FindFirstChild("Money")
			if money then
				money.Value = value
			end
		end
	end
end

function PlayerManager.AddMultiplier(player, multiplier)
	sessionData[player.UserId].Multiplier *= multiplier
end

function PlayerManager.GetMultiplier(player)
	return sessionData[player.UserId].Multiplier
end

function PlayerManager.AddUnlockId(player, id)
	local data = sessionData[player.UserId]
	
	if not table.find(data.UnlockIds, id) then
		table.insert(data.UnlockIds, id)
	end
end

function PlayerManager.GetUnlockIds(player)
	return sessionData[player.UserId].UnlockIds
end

function PlayerManager.ClearUnlockIds(player)
	local data = sessionData[player.UserId]
	
	table.clear(data.UnlockIds)
end

function PlayerManager.OnPlayerRemoving(player)
	SaveData(player, sessionData[player.UserId])
	playerRemoving:Fire(player)
end

function PlayerManager.OnClose()
	for _, player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(PlayerManager.OnPlayerRemoving(player))() 
	end
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, wasPurchased)
	if wasPurchased then
		local passFunction = Gamepasses[id]
		if passFunction then
			passFunction(player)
		end
	end
end)

function PlayerManager.RegisterGamepasses(player)
	for id, passFunction in pairs(Gamepasses) do
		if MarketplaceService:UserOwnsGamePassAsync(player.UserId, id) then
			passFunction(player)
		end
	end
end

return PlayerManager
