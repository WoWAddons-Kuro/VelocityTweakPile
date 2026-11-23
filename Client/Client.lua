-- Velocity Tweak Pile: client interface declaration.
--
-- Flavour-specific frame paths live in Client_ClassicEra.lua / Client_Forever.lua; this file
-- declares exactly which methods a flavour must provide. Client_Select.lua binds the right one
-- onto VTP.Client. Tweaks never reference Blizzard region paths directly.
local ADDON, VTP = ...

VTP.Client = {}
VTP.ClientFlavours = {}

-- Every flavour implements all of these (checked at load by Client_Select.lua).
VTP.Client.INTERFACE = {
	-- MoveStateIconsToTopLeft(enabled) -> idempotent. enabled == true re-anchors the player
	-- frame's rest (Zzz) and combat (swords) state icons from the bottom-left of the portrait
	-- (where the level badge lives) to the portrait's top-left corner. enabled == false restores
	-- Blizzard's original anchors. Regions only, no secure frames: combat-safe.
	"MoveStateIconsToTopLeft",
	-- CenterLevelText(enabled) -> idempotent. enabled == true centre-justifies the player frame's
	-- level FontString and anchors its centre on the centre of the level badge ring, so one- and
	-- two-digit levels both sit in the middle. enabled == false restores Blizzard's anchor and
	-- right justification.
	"CenterLevelText",
}
