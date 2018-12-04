local Keys = {
["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}


--- esx
ESX                           = nil
local PlayerData              = {}

Citizen.CreateThread(function ()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
		PlayerData = ESX.GetPlayerData()
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

local WheelChair = false
local wheelchairGone = false

local LastWheelchair = nil

RegisterCommand('rullstol', function()
	if PlayerData.job.name == 'ambulance' then
		ESX.LoadModel('prop_wheelchair_01')

		Citizen.Wait(500)
		local pedCoords = GetEntityCoords(PlayerPedId())

		local wheelchair = CreateObject(GetHashKey('prop_wheelchair_01'), pedCoords.x, pedCoords.y, pedCoords.z, true)
	end
	
end, false)

RegisterCommand('tabortrullstol', function()

	if PlayerData.job.name == 'ambulance' then
		local pedCoords = GetEntityCoords(PlayerPedId())

		local wheelchair = GetClosestObjectOfType(pedCoords.x, pedCoords.y, pedCoords.z, 10.0, GetHashKey('prop_wheelchair_01'))

		if wheelchair ~= 0 and wheelchair ~= nil then
			DeleteEntity(wheelchair)
		else
			ESX.ShowNotification('Ingen rullstol är nära!')
		end
	end
	
end, false)


Citizen.CreateThread(function()
	Citizen.Wait(5)
	
	local wheelchairGone = false
	local hasPickedUp = false
	local sits = false
	local going = false

	loadAnimDict('missfinale_c2leadinoutfin_c_int')
	loadAnimDict('anim@heists@box_carry@')

	while not wheelchairGone do
		local sleep = 500

		local pedCoords = GetEntityCoords(PlayerPedId())

		local object = GetClosestObjectOfType(pedCoords.x, pedCoords.y, pedCoords.z, 4.0, GetHashKey('prop_wheelchair_01'))

		if DoesEntityExist(object) then
			sleep = 5
			local heading = GetEntityHeading(object)
			local Distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(object))
			local coords    = GetEntityCoords(object)
			local forward   = GetEntityForwardVector(object)
			local x, y, z   = table.unpack(coords + forward * - 0.5)
			local x1, y1, z1   = table.unpack(coords + forward * 0.3)

			if IsEntityDead(PlayerPedId()) then
				DetachEntity(PlayerPedId())
			end

			if Distance < 5.0 then

				if IsControlJustPressed(0, Keys['E']) and hasPickedUp then
					DetachEntity(object)
					ForceEntityAiAndAnimationUpdate(object)
					Citizen.Wait(100)
					local coords = GetEntityCoords(PlayerPedId())
					local forward = GetEntityForwardVector(PlayerPedId())
					local x, y, z   = table.unpack(coords + forward * 1.25)
					SetEntityCoords(object, x, y, z)
					SetEntityHeading(GetEntityHeading(object))
					PlaceObjectOnGroundProperly(object)
					Citizen.Wait(300)
					ClearPedTasksImmediately(PlayerPedId())

					hasPickedUp = false
				end

				if IsControlJustPressed(0, Keys['X']) and sits then
					DetachEntity(PlayerPedId())
					local coords = GetEntityCoords(PlayerPedId())
					local forward = GetEntityForwardVector(PlayerPedId())
					local x, y, z   = table.unpack(coords + forward * 1.25)
					SetEntityCoords(PlayerPedId(), x,y,z - 1)
					Wait(10)
					ClearPedTasksImmediately(PlayerPedId())
					sits = false
				end

				if sits then

					if IsControlPressed(0, Keys['W']) then
						local x, y, z   = table.unpack(coords + forward * -0.01)
						local Wheelchairheading = GetEntityHeading(object)
						SetEntityCoords(object, x,y,z)
						PlaceObjectOnGroundProperly(object)
						going = true
					end

					if IsControlJustReleased(0, Keys['W']) then
						going = false
					end

					if(IsControlPressed(1,  34))then
						heading = heading + 0.2

						if heading > 360 then
							heading = 0
						end

						SetEntityHeading(object,  heading)
					end

					if IsControlPressed(1,  9) then
						heading = heading - 0.2

						if heading < 0 then
							heading = 360
						end

						SetEntityHeading(object,  heading)
					end

				end

				if hasPickedUp and not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 3) then
					TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
				end

				if sits then
					TaskPlayAnim(PlayerPedId(), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 8.0, 8.0, -1, 0, 1, false, false, false)
				end

				if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), x,y,z) < 1.0 and not sits and not hasPickedUp then
					if object ~= nil then
						ESX.Game.Utils.DrawText3D({x = x, y = y, z = z + 0.5}, 'Tryck [~g~E~s~] för att sätta dig', 0.4)
						if IsControlJustPressed(0, Keys['E']) then
							AttachEntityToEntity(PlayerPedId(), object, 4103, 0, 0.0, 0.4, 0.0, 0.0, 180.0, 0.0, false, false, false, false, 2, true)
							Wait(100)
							loadAnimDict('missfinale_c2leadinoutfin_c_int')
							TaskPlayAnim(PlayerPedId(), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 8.0, 8.0, -1, 0, 1, false, false, false)
							--TaskStartScenarioInPlace(PlayerPedId(), 'PROP_HUMAN_SEAT_BENCH', 0, 0)
							sits = true
						end
					end
				end

				if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), x1,y1,z1) < 0.7 and not hasPickedUp and not sits then
					if object ~= nil then
						ESX.Game.Utils.DrawText3D({x = x1, y = y1, z = z1 + 0.5}, 'Tryck [~g~E~s~] för att ta tag', 0.4)
						if IsControlJustPressed(0, Keys['E']) then
							TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
							Wait(100)
							AttachEntityToEntity(object , PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.00, -0.3, -0.73, 195.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)
							hasPickedUp = true
							sits = false
						end
					end
				end

			end

		end

		Citizen.Wait(sleep)

	end
end)

function DrawText3D(x, y, z, text, scale)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

	SetTextScale(scale, scale)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry("STRING")
	SetTextCentre(1)
	SetTextColour(255, 255, 255, 215)

	AddTextComponentString(text)
	DrawText(_x, _y)

	local factor = (string.len(text)) / 370

	DrawRect(_x, _y + 0.0150, 0.030 + factor, 0.025, 41, 11, 41, 100)
end

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		
		Citizen.Wait(1)
	end
end

function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end