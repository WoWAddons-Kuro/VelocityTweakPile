-- Velocity Tweak Pile: Classic Era client (Blizzard_UnitFrame\Classic\PlayerFrame.xml).
--
-- Stock anchors (all in PlayerFrame coordinates, portrait is 64x64 at TOPLEFT 24,-16):
--   PlayerRestIcon    TOPLEFT PlayerFrame 19.5,-52     (Zzz)  <- the bottom-left of the portrait,
--                                                          where PlayerLevelText also sits
--   PlayerAttackIcon  TOPLEFT PlayerRestIcon 1,0       (swords)
--   PlayerStatusGlow  TOPLEFT PlayerRestIcon 0,0       (frame holding PlayerRestGlow / PlayerAttackGlow)
-- So moving PlayerRestIcon alone carries the swords and both glows with it. Blizzard only
-- Show()/Hide()s these; it never re-anchors them after load, so a one-time SetPoint sticks.
local ADDON, VTP = ...

local STOCK = { "TOPLEFT", "PlayerFrame", "TOPLEFT", 19.5, -52 }
-- Top-left of the portrait ring: mirror the stock offset vertically about the portrait centre.
local TOPLEFT = { "TOPLEFT", "PlayerFrame", "TOPLEFT", 13.5, -6 }

-- PlayerLevelText: stock is CENTER -> PlayerFrame BOTTOMLEFT (35.25, 30), justifyH RIGHT, and
-- Blizzard never re-anchors it. Right-justified text grows leftwards as digits are added, so it
-- looks off-centre in the badge ring; centre justification + an anchor on the ring's centre fixes that.
local LEVEL_STOCK  = { "CENTER", "PlayerFrame", "BOTTOMLEFT", 35.25, 30 }
local LEVEL_CENTER = { "CENTER", "PlayerFrame", "BOTTOMLEFT", 38.5, 29 }

VTP.ClientFlavours.classic_era = {
	MoveStateIconsToTopLeft = function(enabled)
		local icon = PlayerRestIcon
		if not icon then return end
		local p = enabled and TOPLEFT or STOCK
		icon:ClearAllPoints()
		icon:SetPoint(p[1], _G[p[2]], p[3], p[4], p[5])
	end,
	CenterLevelText = function(enabled)
		local fs = PlayerLevelText
		if not fs then return end
		local p = enabled and LEVEL_CENTER or LEVEL_STOCK
		fs:SetJustifyH(enabled and "CENTER" or "RIGHT")
		fs:ClearAllPoints()
		fs:SetPoint(p[1], _G[p[2]], p[3], p[4], p[5])
	end,
}
