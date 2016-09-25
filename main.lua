mst = {};

local function debug(...)
  if mst.debug then
    print(...)
  end
end

local function getCurrentTrinkets()
  local t1 = GetInventoryItemID("player", 13)
  local t2 = GetInventoryItemID("player", 14)
  return t1, t2
end

local function getLink(item)
  local name, link = GetItemInfo(item)
  return link
end

local function getCurrentSpecName()
  local currentSpec = GetSpecialization()
  local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"
  return currentSpecName
end

local function printCurrentSpec()
  print("Your current spec:", getCurrentSpecName())
end

local function setCurrentSpecCurrentTrinkets()
  local t1, t2 = getCurrentTrinkets()
  local spec = getCurrentSpecName()
  mst[spec] = {}
  mst[spec]["spec"] = spec
  mst[spec]["Trinket1_id"] = t1
  mst[spec]["Trinket2_id"] = t2
  print("mst: Spec",spec, "using trinkets")
  print(getLink(t1), getLink(t2))
end

local function printSpecState(spec)
  print("mst: spec:", mst[spec]["spec"])
  print("mst: first trinket:", getLink(mst[spec]["Trinket1_id"]))
  print("mst: second trinket:", getLink(mst[spec]["Trinket2_id"]))
end

local function haveStateForSpec(spec)
  return mst[spec] ~= nil
end

local function enterGameWorld() 
  mst.debug = false
  local spec = getCurrentSpecName()
  if next(mst) == nil or next(mst[spec]) == nil then
    setCurrentSpecCurrentTrinkets()
  end
end

local function equipSpecTrinkets(spec)
  local t1 = mst[spec]["Trinket1_id"]
  local t2 = mst[spec]["Trinket2_id"]
  local current_t1 = GetInventoryItemID("player", 13)
  local current_t2 = GetInventoryItemID("player", 14)
  if current_t1 ~= t1 then
    EquipItemByName(t1, 13)
  end
  if current_t2 ~= t2 then
    EquipItemByName(t2, 14)
  end
end

local function specChanged()
  local spec = getCurrentSpecName()
  print("mst: You changed spec to", spec)
  if haveStateForSpec(spec) then
    equipSpecTrinkets(spec)
  else
    print("mst: No trinkets saved for", spec)
    print("mst: Going to save your current ones for now")
    setCurrentSpecCurrentTrinkets()
  end
end

local function equipChanged()
  setCurrentSpecCurrentTrinkets()
end

local event_entering_world = "PLAYER_ENTERING_WORLD"
local event_change_spec = "PLAYER_SPECIALIZATION_CHANGED"
local event_equip_change = "PLAYER_EQUIPMENT_CHANGED"
local f = CreateFrame("Frame", nil, UIParent)
f:RegisterEvent(event_entering_world)
f:RegisterEvent(event_change_spec)
f:RegisterEvent(event_equip_change)
f:SetScript("OnEvent", function(self, event, glStr, value)
  if event == event_entering_world then
    debug("mst: PLAYER_ENTERING_WORLD")
    enterGameWorld()
  elseif event == event_change_spec then 
    debug("mst: PLAYER_SPECIALIZATION_CHANGED")
    specChanged() 
  elseif event == event_equip_change then
    debug("mst: PLAYER_EQUIPMENT_CHANGED")
    equipChanged()
  end
end)
