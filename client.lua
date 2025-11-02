-- RV SHOP - rv-seatbelt (v1.0.3.0)
-- Single resource: /seatbelt command + B key via RegisterKeyMapping.
-- Emergency vehicles: auto-fastens, cannot unfasten, CAN exit.
-- Regular vehicles: block exit while belted.
-- Forward ejection through windshield if not wearing a belt.

print('^2[RV SHOP] rv-seatbelt v1.0.3.0 loaded.^0')

-- ============ Framework detection ============
local ESX, QBCore
if GetResourceState('es_extended') == 'started' then
  ESX = exports['es_extended']:getSharedObject()
elseif GetResourceState('qb-core') == 'started' then
  QBCore = exports['qb-core']:GetCoreObject()
end

-- ============ State ============
local seatbeltOn = false
local lastSpeed = 0.0
local lastVelocity = vector3(0.0, 0.0, 0.0)
local lastVeh = 0

-- If you have addon emergency vehicles that aren't class 18, add them here:
local emergencyWhitelist = {
  -- [`yourAddonModel`] = true,
}

local function isEmergency(veh)
  if veh == 0 or not DoesEntityExist(veh) then return false end
  if GetVehicleClass(veh) == 18 then return true end
  local model = GetEntityModel(veh)
  return emergencyWhitelist[model] == true
end

-- ============ Notifications (6s) ============
local function ShowNotify(msg, color) -- color: "g" (green) / "r" (red)
  local esxOk, qbOk = ESX ~= nil, QBCore ~= nil
  local hasLib = (type(lib) == "table" and lib.notify ~= nil)

  if esxOk then
    local ok = pcall(function() ESX.ShowNotification(("~%s~%s"):format(color, msg)) end)
    if ok then return end
  end
  if qbOk then
    local typ = (color == "g") and "success" or "error"
    local ok = pcall(function() QBCore.Functions.Notify(msg, typ, 6000) end)
    if ok then return end
  end
  if hasLib then
    local typ = (color == "g") and "success" or "error"
    local ok = pcall(function() lib.notify({ description = msg, type = typ, duration = 6000 }) end)
    if ok then return end
  end

  local prefix = (color == "g") and "~g~" or "~r~"
  BeginTextCommandThefeedPost("STRING")
  AddTextComponentSubstringPlayerName(prefix .. msg)
  EndTextCommandThefeedPostTicker(false, false)
  BeginTextCommandPrint("STRING")
  AddTextComponentSubstringPlayerName(prefix .. msg)
  EndTextCommandPrint(6000, true)
end

-- ============ Core toggle ============
local function canToggleHere()
  local ped = PlayerPedId()
  if not IsPedInAnyVehicle(ped, false) then
    ShowNotify("You must be in a vehicle.", "r")
    return false
  end
  local veh = GetVehiclePedIsIn(ped, false)
  if isEmergency(veh) then
    ShowNotify("You cannot unfasten your seatbelt in an emergency vehicle.", "r")
    return false
  end
  return true
end

local function setBelt(val, silent)
  seatbeltOn = val and true or false
  if not silent then
    if seatbeltOn then
      ShowNotify("Seatbelt fastened successfully.", "g")
    else
      ShowNotify("Seatbelt unfastened successfully.", "r")
    end
  end
end

local function toggleBelt()
  if not canToggleHere() then return end
  setBelt(not seatbeltOn, false)
end

-- ============ Command + chat suggestion ============
RegisterCommand('seatbelt', function() toggleBelt() end, false)

CreateThread(function()
  Wait(1500)
  TriggerEvent('chat:addSuggestion', '/seatbelt', 'Toggle seatbelt on or off')
end)

-- ============ B key mapping (FiveM keybinds) ============
-- Hidden command for key mapping:
RegisterCommand('rvsb_toggle', function() toggleBelt() end, false)

CreateThread(function()
  -- palaukiam, kol žaidėjas pilnai įsikels
  while not PlayerPedId() or PlayerPedId() == 0 do Wait(100) end
  Wait(500)
  -- Default bind = B; žaidėjai gali pasikeisti Settings → Key Bindings → FiveM
  RegisterKeyMapping('rvsb_toggle', 'Seatbelt: toggle', 'keyboard', 'B')
  print('^2[RV SHOP] Keybind registered: Seatbelt: toggle = B^0')
end)

-- ============ Emergency auto-fastens (cannot unfasten, CAN exit) ============
CreateThread(function()
  while true do
    Wait(1200)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
      local veh = GetVehiclePedIsIn(ped, false)
      if isEmergency(veh) and not seatbeltOn then
        seatbeltOn = true
        ShowNotify("Seatbelt fastened automatically (emergency vehicle).", "g")
      end
    end
  end
end)

-- ============ Block exit if belted (EXCEPT emergency) ============
CreateThread(function()
  while true do
    Wait(0)
    local ped = PlayerPedId()
    if seatbeltOn and IsPedInAnyVehicle(ped, false) then
      local veh = GetVehiclePedIsIn(ped, false)
      if not isEmergency(veh) then
        DisableControlAction(0, 75, true)   -- exit vehicle
        DisableControlAction(27, 75, true)
      end
    end
  end
end)

-- ============ Windshield break + forward ejection ============
local function breakWindshield(veh)
  if DoesEntityExist(veh) then
    if type(PopOutVehicleWindscreen) == "function" then
      PopOutVehicleWindscreen(veh)
    end
    if type(SetVehicleWindscreenIntact) == "function" then
      pcall(function() SetVehicleWindscreenIntact(veh, false) end)
    end
    if type(IsVehicleWindowIntact) == "function" and type(SmashVehicleWindow) == "function" then
      for i = 0, 7 do
        if IsVehicleWindowIntact(veh, i) then
          SmashVehicleWindow(veh, i)
        end
      end
    end
  end
end

local function ejectForward(ped, veh, baseVel)
  local outPos = GetOffsetFromEntityInWorldCoords(veh, 0.0, 2.0, 0.4)
  SetEntityCoords(ped, outPos.x, outPos.y, outPos.z, true, true, true, false)
  local fwd = GetEntityForwardVector(veh)
  local push, up = 22.0, 0.0
  local vx = fwd.x * push + (baseVel.x * 0.25)
  local vy = fwd.y * push + (baseVel.y * 0.25)
  local vz = up           + (baseVel.z * 0.10)
  SetEntityVelocity(ped, vx, vy, vz)
  Wait(60)
  SetPedToRagdoll(ped, 1200, 1200, 0, 0, 0, 0)
end

CreateThread(function()
  local delta = 25.0 -- m/s drop (~90 km/h)
  while true do
    Wait(75)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
      local veh = GetVehiclePedIsIn(ped, false)

      if veh ~= lastVeh then
        lastVeh = veh
        lastSpeed = GetEntitySpeed(veh)
        lastVelocity = GetEntityVelocity(veh)
      end

      local speed = GetEntitySpeed(veh)
      local vel = GetEntityVelocity(veh)

      if (lastSpeed - speed) > delta then
        if not seatbeltOn then
          breakWindshield(veh)
          ejectForward(ped, veh, lastVelocity)
          ShowNotify("You were ejected through the windshield because the seatbelt was not fastened.", "r")
        end
      end

      lastSpeed = speed
      lastVelocity = vel
    else
      seatbeltOn = false
      lastVeh = 0
      Wait(300)
    end
  end
end)

