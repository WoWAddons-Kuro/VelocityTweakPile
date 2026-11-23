-- Velocity Tweak Pile: settings page and slash command.
--
-- One checkbox per registered tweak, label + description, all default on. Canvas category
-- via Settings.RegisterCanvasLayoutCategory (fallback InterfaceOptions_AddCategory).
local ADDON, VTP = ...

local optionsCategory, optionsFrame
local WIDTH = 580

local function CreateOptions()
	if optionsFrame then return end
	optionsFrame = CreateFrame("Frame", "VelocityTweakPileOptions")
	optionsFrame.name = "Velocity Tweak Pile"

	local title = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16); title:SetText("Velocity Tweak Pile")
	local sub = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6); sub:SetWidth(WIDTH); sub:SetJustifyH("LEFT")
	sub:SetText("A pile of small, independent tweaks to Blizzard's UI. Each one is its own checkbox and applies immediately.")

	local checks = {}
	local last = sub
	for i, def in ipairs(VTP.tweaks) do
		local cb = CreateFrame("CheckButton", "VelocityTweakPileCheck" .. i, optionsFrame, "InterfaceOptionsCheckButtonTemplate")
		cb:SetPoint("TOPLEFT", last, "BOTTOMLEFT", i == 1 and -2 or 0, i == 1 and -18 or -10)
		local text = cb.Text or _G[cb:GetName() .. "Text"]
		text:SetText(def.label); text:SetFontObject("GameFontHighlight")
		cb:SetScript("OnClick", function(self) VTP.SetEnabled(def.id, self:GetChecked() and true or false) end)
		cb.Update = function(self) self:SetChecked(VTP.IsEnabled(def.id)) end
		local desc = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
		desc:SetPoint("TOPLEFT", cb, "BOTTOMLEFT", 28, 2); desc:SetWidth(WIDTH - 28); desc:SetJustifyH("LEFT"); desc:SetText(def.desc or "")
		checks[#checks + 1] = cb
		last = desc
	end

	local resetBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
	resetBtn:SetSize(160, 22); resetBtn:SetText("Reset to defaults")
	resetBtn:SetPoint("TOPLEFT", last, "BOTTOMLEFT", -28, -20)
	resetBtn:SetScript("OnClick", function() VTP.ResetToDefaults(); optionsFrame:Update() end)
	local status = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	status:SetPoint("TOPLEFT", resetBtn, "BOTTOMLEFT", 0, -8); status:SetWidth(WIDTH); status:SetJustifyH("LEFT")

	function optionsFrame:Update()
		if not VTP.db then return end
		for _, cb in ipairs(checks) do cb:Update() end
		status:SetText(VTP.StatusText())
	end
	optionsFrame:SetScript("OnShow", optionsFrame.Update)

	if Settings and Settings.RegisterCanvasLayoutCategory then
		optionsCategory = Settings.RegisterCanvasLayoutCategory(optionsFrame, "Velocity Tweak Pile")
		Settings.RegisterAddOnCategory(optionsCategory)
	elseif InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(optionsFrame)
	end
end

function VTP.OpenOptions()
	CreateOptions()
	if Settings and Settings.OpenToCategory and optionsCategory then
		Settings.OpenToCategory(optionsCategory:GetID())
	elseif InterfaceOptionsFrame_OpenToCategory then
		InterfaceOptionsFrame_OpenToCategory(optionsFrame); InterfaceOptionsFrame_OpenToCategory(optionsFrame)
	end
end

--------------------------------------------------------------------------------
-- Slash
--------------------------------------------------------------------------------
SLASH_VELOCITYTWEAKPILE1 = "/vtp"
SLASH_VELOCITYTWEAKPILE2 = "/velocitytweakpile"
SlashCmdList.VELOCITYTWEAKPILE = function(msg)
	msg = (msg or ""):lower():match("^%s*(.-)%s*$")
	if msg == "" or msg == "options" or msg == "config" then
		VTP.OpenOptions()
	elseif msg == "status" then
		VTP.Print(VTP.StatusText())
		for _, def in ipairs(VTP.tweaks) do
			VTP.Print(string.format("  [%s] %s", VTP.IsEnabled(def.id) and "x" or " ", def.id))
		end
	elseif msg == "reset" then
		VTP.ResetToDefaults(); VTP.Print("all tweaks reset to defaults (enabled)")
	else
		VTP.Print("/vtp  |  /vtp status  |  /vtp reset")
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self) self:UnregisterEvent("PLAYER_LOGIN"); CreateOptions() end)
