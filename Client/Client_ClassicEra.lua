-- Velocity Tweak Pile: Classic Era client (Blizzard_UnitFrame\Classic\PlayerFrame.xml).
--
-- The swords icon is two named global textures anchored to PlayerRestIcon at the bottom-left
-- of the portrait: PlayerAttackIcon (the swords) and PlayerAttackGlow (ADD-blend halo).
-- PlayerFrame_UpdateStatus() Show()/Hide()s them, so we fade them with alpha rather than
-- hiding - Blizzard's Show() would otherwise bring them straight back.
local ADDON, VTP = ...

VTP.ClientFlavours.classic_era = {
	PlayerCombatIconRegions = function()
		local out = {}
		if PlayerAttackIcon then out[#out + 1] = PlayerAttackIcon end
		if PlayerAttackGlow then out[#out + 1] = PlayerAttackGlow end
		return out
	end,
}
