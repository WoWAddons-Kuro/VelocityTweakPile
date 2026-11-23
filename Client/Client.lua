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
	-- PlayerCombatIconRegions() -> array of Texture regions that together draw the player
	-- frame's "in combat" swords icon. Textures only (no secure frames): SetAlpha on them is
	-- combat-safe. May return an empty table when the regions do not exist on this client.
	"PlayerCombatIconRegions",
}
