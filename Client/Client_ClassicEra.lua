-- Velocity Tweak Pile: Classic Era client (Blizzard_UnitFrame\Classic\PlayerFrame.xml).
--
-- Stock anchors (all in PlayerFrame coordinates, portrait is 64x64 at TOPLEFT 24,-16):
--   PlayerRestIcon    TOPLEFT PlayerFrame 19.5,-52     (Zzz)  <- the bottom-left of the portrait,
--                                                          where PlayerLevelText also sits
--   PlayerAttackIcon  TOPLEFT PlayerRestIcon 1,0       (swords)
--   PlayerStatusGlow  TOPLEFT PlayerRestIcon 0,0       (frame holding PlayerRestGlow / PlayerAttackGlow)
-- So moving PlayerRestIcon alone carries the swords and both glows with it. Blizzard only
-- Show()/Hide()s these; it never re-anchors them after load, so a one-time SetPoint sticks.
local ADDON, VTP = ...

local STOCK = { "TOPLEFT", "PlayerFrame", "TOPLEFT", 19.5, -52 }
-- Top-left of the portrait ring: mirror the stock offset vertically about the portrait centre.
local TOPLEFT = { "TOPLEFT", "PlayerFrame", "TOPLEFT", 13.5, -6 }

--------------------------------------------------------------------------------
-- Compare-tooltip Attack Power delta (see Client.lua for the why).
--
-- Blizzard_SharedXMLGame\Tooltip\TooltipComparisonManager.lua :SetItemTooltip() builds each
-- ShoppingTooltipN as: ClearLines, header, ProcessInfo(worn item's own lines), then appends
-- the PRE-FORMATTED strings C_TooltipComparison.GetItemComparisonDelta() returns via
-- GameTooltip_AddHighlightLine. That C function reads the API's budget-unit AP, so the
-- delta line is wrong by a factor of two. A TooltipDataProcessor post-call fires before
-- the delta lines exist, so the hook is hooksecurefunc on SetItemTooltip itself.
--
-- The corrected delta is NOT Blizzard's number doubled and NOT GetItemStats scaled: both
-- would double a fixed client later. It is read from each item's own displayed
-- "+N Attack Power" line - the hovered item's in GameTooltip, the worn item's in the
-- shopping tooltip above the delta block. Displayed text is the truth today and after
-- any API fix, so the rewrite only happens when the displayed-derived delta differs from
-- the line Blizzard drew; when they agree the tweak does nothing.
--------------------------------------------------------------------------------
local compareHooked = false
local compareEnabled = false

-- "+2 Attack Power" / "Equip: Increases attack power by 2." -> 2 (displayed AP), else nil.
-- Only the item's own stat lines; a delta line ("-1 Attack Power" in the delta block) has
-- the same shape, so callers must stop scanning at the delta header.
local AP_LABEL = (ITEM_MOD_ATTACK_POWER_SHORT or "Attack Power")
local function DisplayedAP_FromLineText(text)
	if type(text) ~= "string" then return nil end
	text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	local n = text:match("^%s*%+(%d+)%s+" .. AP_LABEL:gsub("%p", "%%%0") .. "%s*$")
	if not n then n = text:match("^%s*[Ee]quip:%s*Increases attack power by (%d+)%.?%s*$") end
	if not n then n = text:match("^%s*Increases attack power by (%d+)%.?%s*$") end
	return n and tonumber(n) or nil
end

-- Sum of displayed AP on tooltip `tt`, scanning left-column lines 1..stopBefore-1.
local function DisplayedAP_OnTooltip(tt, stopBefore)
	local name = tt:GetName()
	if not name then return nil end
	local total, found = 0, false
	local last = (stopBefore or (tt:NumLines() + 1)) - 1
	for i = 1, last do
		local fs = _G[name .. "TextLeft" .. i]
		local v = fs and DisplayedAP_FromLineText(fs:GetText())
		if v then total = total + v; found = true end
	end
	return found and total or 0
end

-- The line index of ITEM_DELTA_DESCRIPTION in a shopping tooltip, or nil when there is no delta block.
local function DeltaHeaderIndex(tt)
	local name = tt:GetName()
	if not name then return nil end
	local header = ITEM_DELTA_DESCRIPTION
	for i = 1, tt:NumLines() do
		local fs = _G[name .. "TextLeft" .. i]
		if fs and fs:GetText() == header then return i end
	end
	return nil
end

local DELTA_LINE = "^%s*([%+%-])(%d+)%s+" .. AP_LABEL:gsub("%p", "%%%0") .. "%s*$"

local function RewriteAPDelta(shoppingTooltip)
	if not compareEnabled or not shoppingTooltip or not shoppingTooltip:IsShown() then return end
	local headerIdx = DeltaHeaderIndex(shoppingTooltip)
	if not headerIdx then return end
	local name = shoppingTooltip:GetName()
	-- Hovered item: the owning GameTooltip. Worn item: this shopping tooltip, above the header.
	local owner = shoppingTooltip:GetOwner()
	if not owner or not owner.NumLines then return end
	local hoveredAP = DisplayedAP_OnTooltip(owner)
	local wornAP = DisplayedAP_OnTooltip(shoppingTooltip, headerIdx)
	if hoveredAP == nil or wornAP == nil then return end
	local want = hoveredAP - wornAP
	for i = headerIdx + 1, shoppingTooltip:NumLines() do
		local fs = _G[name .. "TextLeft" .. i]
		local raw = fs and fs:GetText()
		if raw then
			local plain = raw:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
			local sign, n = plain:match(DELTA_LINE)
			if sign then
				local shown = tonumber(n) * (sign == "-" and -1 or 1)
				if shown ~= want and want ~= 0 then
					local color = want > 0 and "|cff00ff00" or "|cffff2020"
					fs:SetText(string.format("%s%+d|r %s", color, want, AP_LABEL))
				elseif shown ~= want and want == 0 then
					fs:SetText("")
				end
				return
			end
		end
	end
end

local function OnSetItemTooltip(manager, isPrimaryTooltip)
	local tt = manager and manager.tooltip
	local shopping = tt and tt.shoppingTooltips and tt.shoppingTooltips[isPrimaryTooltip and 1 or 2]
	VTP._apHookFired = (VTP._apHookFired or 0) + 1
	RewriteAPDelta(shopping)
end

-- Era 1.15 (verified in-game 2026-11-26 via /vtp apdebug): TooltipComparisonManager is NOT a
-- global on this client even though the file sits in the Gethe classic_era tree, so that hook
-- can never fire. The compare is driven by the FrameXML global GameTooltip_ShowCompareItem(tt)
-- (ContainerFrame_Shared.lua, QuestInfo.lua, PaperDollFrame...), which fills tt.shoppingTooltips
-- [1] / [2] (ShoppingTooltip1 / 2, owner = tt) including the delta block. Hook THAT post-call.
local function OnShowCompareItem(tt)
	tt = tt or GameTooltip
	VTP._apHookFired = (VTP._apHookFired or 0) + 1
	local shopping = tt and tt.shoppingTooltips
	if shopping then
		RewriteAPDelta(shopping[1])
		RewriteAPDelta(shopping[2])
	else
		RewriteAPDelta(ShoppingTooltip1)
		RewriteAPDelta(ShoppingTooltip2)
	end
end

-- /vtp apdebug: everything the rewrite reasons over, for the compare currently on screen.
local function APDebug()
	VTP.Print(string.format("hooked=%s enabled=%s hookFired=%d TooltipComparisonManager=%s SetItemTooltip=%s",
		tostring(compareHooked), tostring(compareEnabled), VTP._apHookFired or 0,
		type(TooltipComparisonManager), type(TooltipComparisonManager and TooltipComparisonManager.SetItemTooltip)))
	VTP.Print(string.format("AP_LABEL=%q ITEM_DELTA_DESCRIPTION=%q", AP_LABEL, tostring(ITEM_DELTA_DESCRIPTION)))
	for _, name in ipairs({ "GameTooltip", "ShoppingTooltip1", "ShoppingTooltip2" }) do
		local tt = _G[name]
		if tt then
			VTP.Print(string.format("%s shown=%s lines=%d owner=%s", name, tostring(tt:IsShown()), tt:NumLines(),
				tostring(tt.GetOwner and tt:GetOwner() and tt:GetOwner():GetName())))
			for i = 1, tt:NumLines() do
				local fs = _G[name .. "TextLeft" .. i]
				local text = fs and fs:GetText()
				if text and text ~= "" then
					local ap = DisplayedAP_FromLineText(text)
					VTP.Print(string.format("  %2d: %s%s", i, text:gsub("|", "||"), ap and ("   <- AP " .. ap) or ""))
				end
			end
		end
	end
end
VTP.APDebug = APDebug

VTP.ClientFlavours.classic_era = {
	MoveStateIconsToTopLeft = function(enabled)
		local icon = PlayerRestIcon
		if not icon then return end
		local p = enabled and TOPLEFT or STOCK
		icon:ClearAllPoints()
		icon:SetPoint(p[1], _G[p[2]], p[3], p[4], p[5])
	end,

	FixCompareAttackPowerDelta = function(enabled)
		compareEnabled = enabled and true or false
		if enabled and not compareHooked and type(hooksecurefunc) == "function" then
			-- The FrameXML global is the path this client actually uses; the manager hook is
			-- kept so a later build that exposes it keeps working without a code change.
			if type(GameTooltip_ShowCompareItem) == "function" then
				hooksecurefunc("GameTooltip_ShowCompareItem", OnShowCompareItem)
				compareHooked = true
			end
			if type(TooltipComparisonManager) == "table" and type(TooltipComparisonManager.SetItemTooltip) == "function" then
				hooksecurefunc(TooltipComparisonManager, "SetItemTooltip", OnSetItemTooltip)
				compareHooked = true
			end
		end
		if enabled and not compareHooked then
			VTP.Print("fixCompareAttackPower: neither GameTooltip_ShowCompareItem ("
				.. type(GameTooltip_ShowCompareItem) .. ") nor TooltipComparisonManager ("
				.. type(TooltipComparisonManager) .. ") is available to hook; run /vtp apdebug")
		end
	end,
}
