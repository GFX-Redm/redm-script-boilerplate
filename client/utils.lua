--- A simple wrapper around SendNUIMessage that you can use to
--- dispatch actions to the React frame.
---
---@param action string The action you wish to target
---@param data any The data you wish to send along with this action
function SendReactMessage(action, data)
  SendNUIMessage({
    action = action,
    data = data
  })
end

local currentResourceName = GetCurrentResourceName()

local debugIsEnabled = GetConvarInt(('%s-debugMode'):format(currentResourceName), 0) == 1

--- A simple debug print function that is dependent on a convar
--- will output a nice prettfied message if debugMode is on
function debugPrint(...)
  if not debugIsEnabled then return end
  local args <const> = { ... }

  local appendStr = ''
  for _, v in ipairs(args) do
    appendStr = appendStr .. ' ' .. tostring(v)
  end
  local msgTemplate = '^3[%s]^0%s'
  local finalMsg = msgTemplate:format(currentResourceName, appendStr)
  print(finalMsg)
end

function TriggerCallback(name, ...)
  local id = GetRandomIntInRange(0, 999999)
  local eventName = currentResourceName..":triggerCallback:" .. id
  local eventHandler
  local promise = promise:new()
  RegisterNetEvent(eventName)
  local eventHandler = AddEventHandler(eventName, function(...)
      promise:resolve(...)
  end)

  SetTimeout(15000, function()
    promise:resolve("timeout")
    RemoveEventHandler(eventHandler)
  end)
  local args = {...}
  TriggerServerEvent(name, id, args)

  local result = Citizen.Await(promise)
  RemoveEventHandler(eventHandler)
  return result
end