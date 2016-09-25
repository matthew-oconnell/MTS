mst = {}
mst.specs = {}
mst.debug = false
mst.am_currently_swapping = {}
mst.am_currently_swapping["13"] = false
mst.am_currently_swapping["14"] = false

local function debug(...)
  if mst.debug then
    print("[MST:DEBUG]",...)
  end
end

local function createEmptySpec(spec)
  if mst.specs[spec] == nil then
    mst.specs[spec] = {}
  end
end

local function getLink(item)
  if item == nil then
    return nil
  end
  local name, link = GetItemInfo(item)
  if link == nil then
    link = name
  end
  return name
end

local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local function printAllSavedSpecs()
  if mst.specs ~= nil then
    for spec,values in pairs(mst.specs) do
      if values ~= nil then
        local name = values["spec_name"]
        local t1 = values["Trinket1_id"]
        local t2 = values["Trinket2_id"]
        print(name, getLink(t1), getLink(t2))
      end
    end
  end
end

local function getCurrentTrinkets()
  local t1 = GetInventoryItemID("player", 13)
  local t2 = GetInventoryItemID("player", 14)
  return t1, t2
end


local function getCurrentSpecName()
  local currentSpec = GetSpecialization()
  local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"
  return currentSpecName
end

local function setCurrentSpecCurrentTrinkets()
  local t1, t2 = getCurrentTrinkets()
  local spec = getCurrentSpecName()
  if spec == nil then 
    return
  end
  createEmptySpec(spec)
  mst.specs[spec]["spec_name"] = spec
  mst.specs[spec]["Trinket1_id"] = t1
  mst.specs[spec]["Trinket2_id"] = t2
end

local function haveStateForSpec(spec)
  return mst.specs[spec] ~= nil
end

local function equipIfNeeded(t1, slot)
  if mst.am_currently_swapping[slot] == false then
    return 
  else
    local current_t1 = GetInventoryItemID("player", slot)
    if current_t1 ~= t1 then
      print("Equipping trinket to slot", slot)
      mst.am_currently_swapping[slot] = true
      EquipItemByName(t1, slot)
    else
      debug("Already have", getLink(t1),"equipped")
    end
  end
end

local function equipSpecTrinketInSlot(spec, slot)
  print("Equipping trinket in slot", slot)
  debug("Equipping trinkets")
  if slot == 13 then
    local t1 = mst.specs[spec]["Trinket1_id"]
    equipIfNeeded(t1, 13)
  end
  if slot == 14 then
    local t2 = mst.specs[spec]["Trinket2_id"]
    equipIfNeeded(t2, 14)
  end
end

local function specChanged()
  local spec = getCurrentSpecName()
  if haveStateForSpec(spec) then
    equipSpecTrinketInSlot(spec, 13)
    equipSpecTrinketInSlot(spec, 14)
  else
    print("mst: No trinkets saved for", spec)
    print("mst: Going to save your current ones for now")
    setCurrentSpecCurrentTrinkets()
  end
end

local function equipChanged(slot)
  if slot ~= 13 and slot ~= 14 then
    debug("Changed slot", slot, "doing nothing")
    return
  end
  setCurrentSpecCurrentTrinkets()
end

local function enterGameWorld() 
  local spec = getCurrentSpecName()
  if next(mst) == nil or next(mst.specs) == nil or next(mst.specs[spec]) == nil then
    setCurrentSpecCurrentTrinkets()
  end
  printAllSavedSpecs()
end

local function removeNone() 
  if mst.specs ~= nil then
    for spec,values in pairs(mst.specs) do
      if spec == "None" then
        mst.specs[spec] = nil
      end
    end
  end
end

local event_entering_world = "PLAYER_ENTERING_WORLD"
local event_change_spec = "PLAYER_SPECIALIZATION_CHANGED"
local event_equip_change = "PLAYER_EQUIPMENT_CHANGED"
local f = CreateFrame("Frame", nil, UIParent)
f:RegisterEvent(event_entering_world)
f:RegisterEvent(event_change_spec)
f:RegisterEvent(event_equip_change)
f:SetScript("OnEvent", function(self, event, ...)
  if event == event_entering_world then
    debug("EVENT PLAYER_ENTERING_WORLD")
    mst.debug = false
    enterGameWorld()
    removeNone()
  elseif event == event_change_spec then 
    debug("EVENT PLAYER_SPECIALIZATION_CHANGED")
    specChanged() 
  elseif event == event_equip_change then
    slot = ...
    debug("EVENT PLAYER_EQUIPMENT_CHANGED, slot", slot)
    equipChanged(slot)
  end
end)
