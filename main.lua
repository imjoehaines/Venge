----------------
-- Config ------
----------------
local fontScaling = true

local x, y = -100, -50            -- x, y positioning (two numbers)
local anchorFrame = UIParent   -- Frame to anchor Venge to
local frameAnchor = "CENTER"  -- Position of the anchor frame to attach Venge to
local anchor = "CENTER"     -- Position of the Venge frame to anchor
local fontSize = 12           -- size of the font (one number)
local fontFlag = "OUTLINE"    -- font details (OUTLINE, THICKOUTLINE or MONOCHROME)

----------------

local addon, ns = ...
local playerName, _ = UnitName("player")
local _, class = UnitClass("player")
local colour1 = RAID_CLASS_COLORS[class].colorStr
local fontFamily = "Interface\\AddOns\\Venge\\Roboto-Bold.ttf"
local tank = false
local active = false

local tankClass = {
  ["DEATHKNIGHT"] = true,
  ["DRUID"] = true,
  ["MONK"] = true,
  ["PALADIN"] = true,
  ["WARRIOR"] = true,
}

local tankSpecs = {
  [250] = true, -- Blood DK
  [104] = true, -- Guardian Druid
  [268] = true, -- Brewmaster Monk
  [66] = true,  -- Protection Paladin
  [73] = true,  -- Protection Warrior
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

local display = frame:CreateFontString(nil, "OVERLAY")
display:SetFont(fontFamily, fontSize, fontFlag)
display:SetPoint(anchor, anchorFrame, frameAnchor, x, y)

local function prettifyNumber(n) 
  n = math.floor(n+0.5) -- round to nearest whole number
-- credit to Richard Warburton (http://richard.warburton.it)
-- via http://lua-users.org/wiki/FormattingNumbers
  local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

local function eventHandler(self, event, ...)
  if event == "PLAYER_LOGIN" then
    if not tankClass[class] then
      DisableAddOn("Venge") -- class is not capable of tanking so disable the addon
    else
      local specId, _ = GetSpecializationInfo(GetSpecialization())
      tank = tankSpecs[specId]
      if tank and not active then
        active = true
        print("|c"..colour1..addon.."|r loaded!")
        frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
        frame:RegisterUnitEvent("UNIT_AURA", "player")
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        frame:RegisterEvent("PLAYER_REGEN_DISABLED")
        if not InCombatLockdown() then display:SetAlpha(0.2) end
      end
    end
  elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
    local specId, _ = GetSpecializationInfo(GetSpecialization())
    tank = tankSpecs[specId]
    if tank and not active then
      active = true
      print("|c"..colour1..addon.."|r is now tracking vengeance!")
      frame:RegisterEvent("UNIT_AURA")
    elseif active and not tank then
      active = false
      print("|c"..colour1..addon.."|r is no longer tracking vengeance as you've switched to a non-tank spec.")
      frame:UnregisterEvent("UNIT_AURA")
      -- clear thet text; usually handled by the UNIT_AURA event but we just stopped tracking it
      display:SetText(nil)
    end
  elseif event == "PLAYER_REGEN_ENABLED" then
    display:SetAlpha(0.2)
  elseif event == "PLAYER_REGEN_DISABLED" then
    display:SetAlpha(1)
  else
    local _, _, _, _, _, _, _, _, _, _, _, _, _, _, vengeanceValue, _ = UnitBuff("player", "Resolve")
    if vengeanceValue then
      display:SetText("|c"..colour1..prettifyNumber(vengeanceValue).."|r")
      if fontScaling then
        display:SetFont(fontFamily, fontSize + (vengeanceValue / 24), fontFlag)
      end
    else
      display:SetText(nil)
    end
  end
end

frame:SetScript("OnEvent", eventHandler)