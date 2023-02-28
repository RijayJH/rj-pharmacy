local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('rj-pharmacy:server:CreateRx', function(rx)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	
	local info = {}
	info.rx_patient = rx[1]
	info.rx_quantity = tostring(rx[2])
	info.rx = rx[3]
	info.directions = rx[4]
	info.rx_doctor = Player.PlayerData.charinfo.firstname..' '.. Player.PlayerData.charinfo.lastname
	info.rx_Date = os.date('%d %B %Y')
	info.refilled = '0'
	--print(json.encode(info, {indent=true}))
	if not exports.ox_inventory:CanCarryItem(src, "prescription", 1, info) then
		TriggerClientEvent('QBCore:Notify', source,  "Ain't even got space for a note in these pockets, damn bruh.", "error")
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["prescription"], "add")
	else
		exports.ox_inventory:AddItem(src, "prescription", 1, info)
	end
end)

RegisterNetEvent('rj-pharmacy:server:buymedicine', function()
	local src = source
	local item = exports.ox_inventory:Search(src, 'slots', "prescription")
	for k, v in pairs(item) do
		item = v
		break
	end
	local price = 0
	for k, v in pairs(item.metadata.rx) do
		price = price + Config.Prices[item.metadata.rx[k]] * tonumber(item.metadata.rx_quantity)
	end
	if exports.ox_inventory:RemoveItem(src, "money", price) then
		if exports.ox_inventory:RemoveItem(src, "prescription", 1, item.metadata) then
			for k, v in pairs(item.metadata.rx) do
				if exports.ox_inventory:CanCarryItem(src, item.metadata.rx[k], tonumber(item.metadata.rx_quantity)) then
					exports.ox_inventory:AddItem(src, item.metadata.rx[k], tonumber(item.metadata.rx_quantity))
				end
			end
		else
			TriggerClientEvent('ox_lib:notify', src,
				{ type = 'error', description = 'You do not have the a prescription' })
		end
	else
		TriggerClientEvent('ox_lib:notify', src,
			{ type = 'error', description = 'You do not have enough cash' })
	end
end)

RegisterServerEvent('rj-pharmacy:server:GiveRx', function(target, rx)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local OtherPlayer = QBCore.Functions.GetPlayer(tonumber(target))
    local dist = #(GetEntityCoords(GetPlayerPed(src))-GetEntityCoords(GetPlayerPed(target)))

	local info = {}
	info.rx_patient = rx[1]
	info.rx_quantity = tostring(rx[2])
	info.rx = rx[3]
	info.directions = rx[4]
	info.rx_doctor = Player.PlayerData.charinfo.firstname..' '.. Player.PlayerData.charinfo.lastname
	info.rx_Date = os.date('%d %B %Y')
	info.refilled = '0'

	if Player == OtherPlayer then return TriggerClientEvent('QBCore:Notify', src, "You can't give yourself an item?") end
	if dist > 2 then return TriggerClientEvent('QBCore:Notify', src, "You are too far away to give items!") end
	if exports.ox_inventory:CanCarryItem(tonumber(target), "prescription", 1, info) then
		exports.ox_inventory:AddItem(tonumber(target), "prescription", 1, info)
		TriggerClientEvent('QBCore:Notify', src, ('You pass %s their prescription.'):format(target))
		TriggerClientEvent('QBCore:Notify', target, ('%s passes you a written prescription.'):format(src))
	else
		TriggerClientEvent('QBCore:Notify', src,  "The other players inventory is full!", "error")
		TriggerClientEvent('QBCore:Notify', target,  "Your inventory is full!", "error")
	end
end)

QBCore.Functions.CreateUseableItem("prescriptionpad", function(source, item)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)

	if Player.PlayerData.job.name == 'ambulance' then	
		TriggerClientEvent('rj-pharmacy:client:RxAnimation', src)
		TriggerClientEvent('rj-pharmacy:client:WriteRx', src, item.info)
	else
		TriggerClientEvent('QBCore:Notify', src,  'Your hand stops and you think to yourself; "Maybe I should put some effort into forging this signature instead of going to jail forever."', "error")
	end
end)

RegisterNetEvent('rj-pharmacy:server:tickRx', function(item)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	print('rxtick')
	local refilled = tonumber(item.metadata.refilled)
	if Player.PlayerData.job.name == 'ambulance' then
        refilled =refilled + 1
		item.metadata.refilled = tostring(refilled)
        exports.ox_inventory:SetMetadata(src, item.slot, item.metadata)
	end
end)
