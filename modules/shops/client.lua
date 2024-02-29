if not lib then return end

local shopTypes = {}
local shops = {}
local createBlip = require 'modules.utils.client'.CreateBlip

for shopType, shopData in pairs(lib.load('data.shops') --[[@as table<string, OxShop>]]) do
	local shop = {
		name = shopData.name,
		groups = shopData.groups or shopData.jobs,
		blip = shopData.blip,
		label = shopData.label,
        icon = shopData.icon
	}
	shop.model = shopData.model
	shop.locations = shopData.locations

	shopTypes[shopType] = shop
	local blip = shop.blip

	if blip then
		blip.name = ('ox_shop_%s'):format(shopType)
		AddTextEntry(blip.name, shop.name or shopType)
	end
end

local Utils = require 'modules.utils.client'

local function hasShopAccess(shop)
	return not shop.groups or client.hasGroup(shop.groups)
end

local function wipeShops()
	for i = 1, #shops do
		local shop = shops[i]
		--exports.interact:RemoveInteraction(shop)
	end

	table.wipe(shops)
end

local function refreshShops()
	wipeShops()

	local id = 0

	for shopType, shop in pairs(shopTypes) do
		local blip = shop.blip
		local label = shop.label or locale('open_label', shop.name)
		if not hasShopAccess(shop) then goto skipLoop end
		if shop.locations then
			for i = 1, #shop.locations do
				local coords = shop.locations[i]
				id += 1
				shops[id] = exports.interact:AddInteraction({
					id = 'ox_inventory_shop'..id,
					coords = coords,
					distance = 8.0,
					interactDst = 1.5,
					options = {
						{
							label = label,
							action = function(entity, coords, args)
								client.openInventory('shop', { id = i, type = shopType })
							end,
						},
					}
				})
			end
		elseif shop.model then
			id += 1
			if type(shop.model) == 'number' then
				id += 1
				exports.interact:AddModelInteraction({
					model = shop.model,
					ignoreLos = true,
					id = 'ox_inventory_shop'..id,
					distance = 8.0,
					interactDst = 2.0,
					options = {
						{
							label = label,
							action = function(entity, coords, args)
								client.openInventory('shop', { id = id, type = shopType })
							end,
						},
					}
				})
			else
				for spid, modelName in pairs(shop.model) do
					exports.interact:AddModelInteraction({
						model = modelName,
						ignoreLos = true,
						id = 'ox_inventory_shop'..tostring(spid)..id,
						distance = 8.0,
						interactDst = 2.0,
						options = {
							{
								label = label,
								action = function(entity, coords, args)
									client.openInventory('shop', { id = id, type = shopType })
								end,
							},
						}
					})
				end
			end
		end
		::skipLoop::
	end
end

return {
	refreshShops = refreshShops,
	wipeShops = wipeShops,
}
