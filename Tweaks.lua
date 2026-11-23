-- Velocity Tweak Pile: the tweaks. One VTP.RegisterTweak() block per tweak; keep each
-- self-contained so it can be read, enabled and removed on its own.
local ADDON, VTP = ...
local Client = VTP.Client

--------------------------------------------------------------------------------
-- moveStateIcons: keep the player level readable - move Zzz / swords to the top-left
--------------------------------------------------------------------------------
-- Blizzard anchors the rest (Zzz) and in-combat (crossed swords) icons over the bottom-left of
-- the player portrait, which is exactly where the level badge sits. Stock art half-covers the
-- number; unit-frame skins such as EasyFrames cover it completely. On a hardcore character the
-- level must stay readable at all times, so this tweak re-anchors both icons to the portrait's
-- top-left corner instead. Blizzard only Show()/Hide()s these regions and never re-anchors them
-- after load, so a one-time SetPoint sticks; they are plain regions, not secure frames, so this
-- is safe in combat lockdown. PlayerFrame_UpdateStatus is hooked defensively anyway.
do
	local hooked = false
	local function Reapply() Client.MoveStateIconsToTopLeft(VTP.IsEnabled("moveStateIcons")) end

	VTP.RegisterTweak({
		id = "moveStateIcons",
		label = "Move the rest (Zzz) and combat (swords) icons to the top-left of the portrait",
		desc = "Blizzard draws them over the bottom-left of your portrait, right on top of your level. "
			.. "Moving them to the top-left corner keeps your level readable at all times.",
		Apply = function(enabled)
			if not hooked and type(PlayerFrame_UpdateStatus) == "function" then
				hooksecurefunc("PlayerFrame_UpdateStatus", Reapply)
				hooked = true
			end
			Client.MoveStateIconsToTopLeft(enabled)
		end,
	})
end