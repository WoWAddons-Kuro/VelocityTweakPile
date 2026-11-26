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

	-- FixCompareAttackPowerDelta(enabled) -> idempotent. Classic Era's compare tooltip
	-- ("If you replace this item, the following stat changes will occur:") computes the
	-- Attack Power delta from GetItemStats, which on Era reports AP in ITEM-BUDGET units
	-- (1 budget point = 2 displayed AP), so "+2 Attack Power" vs none prints "-1 Attack
	-- Power". enabled == true recomputes that one line from the two items' OWN displayed
	-- "+N Attack Power" tooltip lines and rewrites it when it differs; nothing else in the
	-- block is touched, and a line Blizzard already has right is left alone (so a client
	-- fix later makes this a no-op rather than a double). enabled == false stops rewriting.
	-- Forever's comparison is correct: that flavour is a no-op.
	"FixCompareAttackPowerDelta",
}
