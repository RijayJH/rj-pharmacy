local QBCore = exports['qb-core']:GetCoreObject()
local writingrx = false
local ox_inventory = exports.ox_inventory
local IsTargetReady = GetResourceState(Config.target) == "started" or GetResourceState("ox_target") == "started" or GetResourceState("qb-target") == "started"

AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    if GetResourceState('ox_inventory'):match("start") then
        exports.ox_inventory:displayMetadata({
            rx_patient = "Patient",
            rx_quantity = "Quantity",
            rx = "Prescription",
            rx_directions = "Directions",
            rx_doctor = "Doctor",
            rx_Date = "Date",
        })
    end
end)

local function SpawnPed()
    if pedSpawned then return end
    local model = joaat(Config.model)
    lib.requestModel(model)
    local coords = Config.coords4
    local shopdude = CreatePed(0, model, coords.x, coords.y, coords.z-1.0, coords.w, false, false)

    spawnedPed = shopdude

    TaskStartScenarioInPlace(shopdude, 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
    FreezeEntityPosition(shopdude, true)
    SetEntityInvincible(shopdude, true)
    SetBlockingOfNonTemporaryEvents(shopdude, true)

    pedSpawned = true
    if true then
        if IsTargetReady then
            if Config.targettype == 'ox' then
                exports.ox_target:addLocalEntity(shopdude, {
                    {
                        name = 'rj-gunrepairs',
                        label = 'Buy Medicine',
                        event = 'rj-pharmacy:client:buymedicine',
                        icon = 'fa-solid fa-kit-medical',
                        canInteract = function(_, distance)
                            return distance < 2.0
                        end
                    }
                })
            elseif Config.targettype == 'qb' then
                exports['qb-target']:AddTargetEntity(shopdude, {
                    {
                        num = 1,
                        type = 'client',
                        event = 'rj-pharmacy:client:buymedicine',
                        icon = 'fa-solid fa-kit-medical',
                        label = 'Buy Medicine',
                        canInteract = function(_, distance)
                            return distance < 2.0
                        end
                    }
                })
            else
                print('This target is not supported')
            end
        else
            print('No targets found')
        end
    end
end

CreateThread(function()
    SpawnPed()
end)

RegisterNetEvent('rj-pharmacy:client:buymedicine', function()
    local item = exports.ox_inventory:Search('slots', 'prescription')
    local itemcount = exports.ox_inventory:Search('count', 'prescription')
    --print(json.encode(item, {indent=true}))
    if itemcount > 0 then
        if itemcount == 1 then
            TriggerServerEvent('rj-pharmacy:server:buymedicine', item)
        else
            lib.notify({
                title = 'Too many Prescriptions',
                description = 'I can only manage one prescription at a time',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'No Prescriptions',
            description = 'You dont have any priscriptions',
            type = 'error'
        })
    end
end)

RegisterNetEvent('rj-pharmacy:client:WriteRx', function()
    if writingrx then return end        
    writingrx = true
    local input = lib.inputDialog('Prescription Pad', {
        { type = 'input', label = 'Patient Name', placeholder = 'Full Name', required = true },
        { type = 'number', label = 'Quantity', required = true, placeholder = 'Number', default = 1, min = 0, max = 10 },
        { type = 'multi-select', label = 'Prescription', required = true, options = Config.Medicines, placeholder = 'Drop Down' },
        { type = 'textarea', label = 'Directions', required = true, placeholder = 'Eat it BOZO', autosize = true, min = 4 },
    })
    
    
    --print(json.encode(input, {indent=true}))


    CreateThread(function()
        while writingrx do
            Wait(100)
            if not IsNuiFocused() then
                TriggerEvent('rj-pharmacy:client:RxAnimation')
                writingrx = false
            end
        end   
    end)

    if input then
        TriggerEvent('rj-pharmacy:client:CreateRx', input)
    else
        return
    end
end)

RegisterNetEvent('rj-pharmacy:client:CreateRx', function(rx)
    lib.registerContext({
        id = 'pharmacy_menu',
        title = 'Write Prescription',
        options = {
            {
                title = 'Create RX',
                description = 'Create a Prescription',
                icon = 'fa-solid fa-prescription',
                serverEvent = 'rj-pharmacy:server:CreateRx',
                args = rx
            },
            {
                title = 'Give RX',
                description = 'Give the Prescription',
                icon = 'fa-solid fa-prescription-bottle-medical',
                event = 'rj-pharmacy:client:GiveRx',
                args = rx
            },
        },
    })
    lib.showContext('pharmacy_menu')
end)

RegisterNetEvent('rj-pharmacy:client:GiveRx', function(rx)
    local player, distance = QBCore.Functions.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
    if player ~= -1 and distance < 3 then
            local playerId = GetPlayerServerId(player)
            SetCurrentPedWeapon(PlayerPedId(),'WEAPON_UNARMED',true)
            TriggerServerEvent('rj-pharmacy:server:GiveRx', playerId, rx)
    else
        QBCore.Functions.Notify("No one nearby!", "error")
    end
end)

RegisterNetEvent('rj-pharmacy:client:tickRx', function(item)
    TriggerEvent('animations:client:EmoteCommandStart', {"notepad"})
    QBCore.Functions.Progressbar("tickrx", "Updating prescription...", 1500, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        TriggerServerEvent('rj-pharmacy:server:tickRx', item)
    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end)
end)

RegisterNetEvent('rj-pharmacy:client:RxAnimation', function()
    local player = PlayerPedId()
    local ad = "missheistdockssetup1clipboard@base"
                
    local prop_name = prop_name or 'prop_notepad_01'
    local secondaryprop_name = secondaryprop_name or 'prop_pencil_01'
    
    if ( DoesEntityExist( player ) and not IsEntityDead( player )) then 
        loadAnimDict( ad )
        if ( IsEntityPlayingAnim( player, ad, "base", 3 ) ) then 
            TaskPlayAnim( player, ad, "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
            Citizen.Wait(100)
            ClearPedSecondaryTask(PlayerPedId())
            DetachEntity(prop, 1, 1)
            DeleteObject(prop)
            DetachEntity(secondaryprop, 1, 1)
            DeleteObject(secondaryprop)
        else
            local x,y,z = table.unpack(GetEntityCoords(player))
            prop = CreateObject(GetHashKey(prop_name), x, y, z+0.2,  true,  true, true)
            secondaryprop = CreateObject(GetHashKey(secondaryprop_name), x, y, z+0.2,  true,  true, true)
            AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.1, 0.02, 0.05, 10.0, 0.0, 0.0, true, true, false, true, 1, true) -- lkrp_notepadpad
            AttachEntityToEntity(secondaryprop, player, GetPedBoneIndex(player, 58866), 0.11, -0.02, 0.001, -120.0, 0.0, 0.0, true, true, false, true, 1, true) -- pencil
            TaskPlayAnim( player, ad, "base", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
        end     
    end
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function openRx()
    SetNuiFocus(false, false)
end
