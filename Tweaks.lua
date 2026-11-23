-- Velocity Tweak Pile: the tweaks. One VTP.RegisterTweak() block per tweak; keep each
-- self-contained so it can be read, enabled and removed on its own.
local ADDON, VTP = ...
local Client = VTP.Client

--------------------------------------------------------------------------------
-- hideCombatIcon: keep the player level readable in combat
--------------------------------------------------------------------------------
-- Blizzard anchors the crossed-swords "in combat" icon over the bottom-left of the player
-- portrait, which is exactly where the level badge sits. Stock art half-covers the number;
-- unit-frame skins such as EasyFrames cover it completely. On a hardcore character the level
-- must stay readable at all times, so this tweak fades the swords to invisible.
--
-- Why alpha and not Hide(): PlayerFrame_UpdateStatus() calls Show()/Hide() on the icon every
-- time combat/rest state changes, which would immediately undo a Hide(). Alpha is not touched
-- by Blizzard's code for these textures, so a one-time SetAlpha(0) sticks. The textures are
-- plain regions, not secure frames, so this is safe in combat lockdown.
-- Hooking PlayerFrame_UpdateStatus covers any future client build that resets alpha there.
do
	local hooked = false
	local function ApplyAlpha()
		local alpha = VTP.IsEnabled("hideCombatIcon") and 0 or 1
		for _, region in ipairs(Client.PlayerCombatIconRegions()) do
			region:SetAlpha(alpha)
		end
	end

	VTP.RegisterTweak({
		id = "hideCombatIcon",
		label = "Hide the player frame's combat swords icon",
		desc = "The crossed swords that appear on your portrait in combat sit right on top of your level. "
			.. "Hiding them keeps your level readable at all times (the red combat glow still shows).",
		Apply = function(enabled)
			if not hooked and type(PlayerFrame_UpdateStatus) == "function" then
				hooksecurefunc("PlayerFrame_UpdateStatus", ApplyAlpha)
				hooked = true
			end
			ApplyAlpha()
		end,
	})
end
