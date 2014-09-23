----------------
-- Config ------
----------------
local x, y = 0, -5           -- x, y positioning (two numbers)
local anchorFrame = Minimap -- Frame to anchor Venge to
local frameAnchor = "BOTTOM"-- Position of the anchor frame to attach Venge to
local vengeAnchor = "TOP"   -- Position of the Venge frame to anchor
local fontSize = 12         -- size of the font (one number)
local fontFlag = "OUTLINE"  -- font details (OUTLINE, THICKOUTLINE or MONOCHROME)

----------------

local addon, ns = ...
local playerName, _ = UnitName("player")
local _, class = UnitClass("player")
local colour1 = RAID_CLASS_COLORS[class].colorStr
local fontFamily = "Interface\\AddOns\\Venge\\Roboto-Bold.ttf"--"Interface\\AddOns\\tekticles\\CalibriBold.ttf"
local tank = false

local tankSpecs = {
  [250] = true, -- Blood DK
  [104] = true, -- Guardian Druid
  [268] = true, -- Brewmaster Monk
  [66] = true,  -- Protection Paladin
  [73] = true,  -- Protection Warrior
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

local display = frame:CreateFontString(nil, "OVERLAY")
display:SetFont(fontFamily, fontSize, fontFlag)
display:SetPoint(vengeAnchor, anchorFrame, frameAnchor, x, y)

local function prettifyNumber(n) 
  n = math.floor(n+0.5) -- round to nearest whole number
-- credit to Richard Warburton (http://richard.warburton.it)
-- via http://lua-users.org/wiki/FormattingNumbers
  local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

local function eventHandler(self, event, ...)
  if event == "ADDON_LOADED" then
    if ... == addon then
      local specId, _ = GetSpecializationInfo(GetSpecialization())
      tank = tankSpecs[specId]
      if tank then
        print("|c"..colour1..addon.."|r loaded!")
        frame:RegisterEvent("UNIT_AURA")
        frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
      end
    end
  elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
    local unit = ...
    if unit ~= "player" then return end
    
    local specId, _ = GetSpecializationInfo(GetSpecialization())
    tank = tankSpecs[specId]
    if tank then
      print("|c"..colour1..addon.."|r is now tracking vengeance!")
      frame:RegisterEvent("UNIT_AURA")
    else
      print("|c"..colour1..addon.."|r is no longer tracking vengeance as you've switched to a non-tank spec.")
      frame:UnregisterEvent("UNIT_AURA")
      -- clear the text; usually handled by the UNIT_AURA event but we just stopped tracking it
      display:SetText(nil)
    end
  else
    local unit = ...
    if unit ~= "player" then return end

    local _, _, _, _, _, _, _, _, _, _, _, _, _, _, vengeanceValue, _ = UnitBuff("player", "Vengeance")
    if vengeanceValue then
      display:SetText("|c"..colour1..prettifyNumber(vengeanceValue).."|r")
    else
      display:SetText(nil)
    end
  end
end

frame:SetScript("OnEvent", eventHandler)