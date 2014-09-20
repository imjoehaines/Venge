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

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("UNIT_AURA")

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
      print("|c"..colour1..addon.."|r loaded!")
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