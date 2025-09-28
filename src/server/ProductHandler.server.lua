local PlayerManager = require(script.Parent.PlayerManager)
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local products = {
	[3414161280] = function(player)
		PlayerManager.SetMoney(player, PlayerManager.GetMoney(player) + 1000)
	end,
}

MarketplaceService.ProcessReceipt = function(info)
	local player = Players:GetPlayerByUserId(info.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local success, result = pcall(products[info.ProductId], player)
	if not success or not result then
		warn("Error for Product" .. tostring(result))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	return Enum.ProductPurchaseDecision.PurchaseGranted
end