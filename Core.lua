-- Velocity Tweak Pile: saved variables, the tweak registry, and apply-all.
--
-- A tweak is one small, independent change to Blizzard's UI with an on/off checkbox.
-- Each tweak registers itself from Tweaks.lua via VTP.RegisterTweak(def):
--   def.id       string, key in VelocityTweakPileDB.enabled (never renamed once shipped)
--   def.label    checkbox text
--   def.desc     one or two sentences shown under the checkbox
--   def.Apply(enabled)  idempotent; called at login and on every checkbox change. Must
--                       fully undo itself when enabled == false.
-- All tweaks default to enabled. The settings DB stores only the enabled flags.
local ADDON, VTP = ...

VTP.tweaks = {}          -- ordered array of defs, in registration order (= display order)
VTP.tweaksById = {}

local DEFAULTS = { enabled = {} }

function VTP.Print(msg)
	print("|cff80c0ffVelocityTweakPile|r: " .. tostring(msg))
end

function VTP.RegisterTweak(def)
	assert(type(def.id) == "string" and def.id ~= "", "tweak needs an id")
	assert(type(def.Apply) == "function", "tweak " .. def.id .. " needs Apply(enabled)")
	assert(not VTP.tweaksById[def.id], "duplicate tweak id " .. def.id)
	VTP.tweaks[#VTP.tweaks + 1] = def
	VTP.tweaksById[def.id] = def
	DEFAULTS.enabled[def.id] = true
end

function VTP.IsEnabled(id)
	local v = VTP.db and VTP.db.enabled[id]
	if v == nil then return true end
	return v
end

function VTP.SetEnabled(id, enabled)
	local def = VTP.tweaksById[id]
	if not def or not VTP.db then return end
	VTP.db.enabled[id] = enabled and true or false
	def.Apply(VTP.db.enabled[id])
end

function VTP.ApplyAll()
	for _, def in ipairs(VTP.tweaks) do
		def.Apply(VTP.IsEnabled(def.id))
	end
end

function VTP.ResetToDefaults()
	if not VTP.db then return end
	wipe(VTP.db.enabled)
	for id, v in pairs(DEFAULTS.enabled) do VTP.db.enabled[id] = v end
	VTP.ApplyAll()
end

function VTP.StatusText()
	local on, total = 0, #VTP.tweaks
	for _, def in ipairs(VTP.tweaks) do if VTP.IsEnabled(def.id) then on = on + 1 end end
	local version = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(ADDON, "Version")
		or (GetAddOnMetadata and GetAddOnMetadata(ADDON, "Version")) or "?"
	return string.format("v%s  client=%s  tweaks on: %d/%d", tostring(version), tostring(VTP.Client.flavour), on, total)
end

local function InitDB()
	VelocityTweakPileDB = VelocityTweakPileDB or {}
	local db = VelocityTweakPileDB
	db.enabled = db.enabled or {}
	for id, v in pairs(DEFAULTS.enabled) do
		if db.enabled[id] == nil then db.enabled[id] = v end
	end
	VTP.db = db
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == ADDON then
		self:UnregisterEvent("ADDON_LOADED")
		InitDB()
	elseif event == "PLAYER_LOGIN" then
		self:UnregisterEvent("PLAYER_LOGIN")
		if not VTP.db then InitDB() end
		VTP.ApplyAll()
	end
end)
