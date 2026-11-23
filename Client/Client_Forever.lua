-- Velocity Tweak Pile: WoW Forever client (Mainline-style Blizzard_UnitFrame\Mainline\PlayerFrame.xml).
--
-- Under PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual:
--   AttackIcon      texture, atlas UI-HUD-UnitFrame-Player-CombatIcon, TOPLEFT 64,-62 (bottom-left of portrait)
--   PlayerRestLoop  frame (flipbook Zzz), 20x20, anchored near the same corner
-- Both are independent, so each is re-anchored. The stock anchor of each is captured on first
-- use (GetPoint) so disabling restores exactly what this client build shipped with.
local ADDON, VTP = ...

local stock = {}   -- region -> { point, relativeTo, relativePoint, x, y }
local TOPLEFT = { AttackIcon = { 64, -12 }, PlayerRestLoop = { 60, -8 } }

local function Contextual()
	local content = PlayerFrame and PlayerFrame.PlayerFrameContent
	return content and content.PlayerFrameContentContextual
end

local function Move(region, key, enabled)
	if not region then return end
	if not stock[region] then
		local pt, rel, relPt, x, y = region:GetPoint(1)
		if not pt then return end
		stock[region] = { pt, rel, relPt, x, y }
	end
	local s = stock[region]
	region:ClearAllPoints()
	if enabled then
		region:SetPoint("TOPLEFT", s[2], "TOPLEFT", TOPLEFT[key][1], TOPLEFT[key][2])
	else
		region:SetPoint(s[1], s[2], s[3], s[4], s[5])
	end
end

-- PlayerLevelText on Forever: stock TOPRIGHT (-24.5, -28) on its parent, justifyH RIGHT. The
-- Mainline art places the level in the frame's top-right badge, not under the portrait, so the
-- same fix applies there: centre-justify and anchor the centre on that badge. Stock captured via GetPoint.
local levelStock
local LEVEL_CENTER = { -35, -36 }   -- CENTER on parent TOPRIGHT; first guess, tune in game

VTP.ClientFlavours.forever = {
	MoveStateIconsToTopLeft = function(enabled)
		local c = Contextual()
		if not c then return end
		Move(c.AttackIcon, "AttackIcon", enabled)
		Move(c.PlayerRestLoop, "PlayerRestLoop", enabled)
	end,
	CenterLevelText = function(enabled)
		local fs = PlayerLevelText
		if not fs then return end
		if not levelStock then
			local pt, rel, relPt, x, y = fs:GetPoint(1)
			if not pt then return end
			levelStock = { pt, rel, relPt, x, y }
		end
		fs:SetJustifyH(enabled and "CENTER" or "RIGHT")
		fs:ClearAllPoints()
		if enabled then fs:SetPoint("CENTER", levelStock[2], "TOPRIGHT", LEVEL_CENTER[1], LEVEL_CENTER[2])
		else fs:SetPoint(levelStock[1], levelStock[2], levelStock[3], levelStock[4], levelStock[5]) end
	end,
}
