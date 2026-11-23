-- Velocity Tweak Pile: picks the client implementation for the running game and binds it
-- onto VTP.Client. Loads after Client.lua and every Client_*.lua.
--
-- Every method in Client.INTERFACE must exist on the chosen flavour; a missing one is
-- reported once at load ("/vtp status" shows the flavour) instead of failing as a nil call.
local ADDON, VTP = ...
local Client = VTP.Client

VTP.loadWarnings = {}
local function Warn(key, msg)
	if VTP.loadWarnings[key] then return end
	VTP.loadWarnings[key] = msg
	print("|cff80c0ffVelocityTweakPile|r: " .. msg)
end
VTP.WarnOnce = Warn

local function SelectFlavour()
	if WOW_PROJECT_ID ~= nil and WOW_PROJECT_CLASSIC ~= nil and WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
		return "classic_era"
	end
	return "forever"
end

Client.flavour = SelectFlavour()
local impl = VTP.ClientFlavours[Client.flavour]
if not impl then
	Warn("client", "no client implementation for flavour " .. tostring(Client.flavour))
	impl = {}
end

for _, name in ipairs(Client.INTERFACE) do
	if type(impl[name]) == "function" then
		Client[name] = impl[name]
	else
		Warn("client:" .. name, Client.flavour .. " client is missing " .. name)
		Client[name] = function() return {} end
	end
end

-- A flavour file that implements something the interface does not list is flagged too,
-- so the two stay in step.
for flavour, table_ in pairs(VTP.ClientFlavours) do
	for name in pairs(table_) do
		local listed = false
		for _, n in ipairs(Client.INTERFACE) do if n == name then listed = true break end end
		if not listed then Warn("client-extra:" .. flavour .. ":" .. name, flavour .. " client defines " .. name .. " which is not in Client.INTERFACE") end
	end
end
