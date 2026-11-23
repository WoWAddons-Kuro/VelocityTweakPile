-- Velocity Tweak Pile: WoW Forever client (Mainline-style Blizzard_UnitFrame\Mainline\PlayerFrame.xml).
--
-- The swords icon is a single atlas texture, UI-HUD-UnitFrame-Player-CombatIcon, at
-- PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.AttackIcon. It has no
-- separate glow texture. PlayerFrame_UpdateStatus() toggles it with Show()/Hide().
local ADDON, VTP = ...

VTP.ClientFlavours.forever = {
	PlayerCombatIconRegions = function()
		local content = PlayerFrame and PlayerFrame.PlayerFrameContent
		local contextual = content and content.PlayerFrameContentContextual
		local icon = contextual and contextual.AttackIcon
		if icon then return { icon } end
		return {}
	end,
}
