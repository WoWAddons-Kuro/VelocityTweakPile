# Velocity Tweak Pile - spec

**Repo:** `VelocityTweakPile\` (origin WoWAddons-Kuro/VelocityTweakPile). **Slash:** `/vtp`. **SV:** `VelocityTweakPileDB`.
**Clients:** Classic Era (11509) and WoW Forever (16001), via the `Client\` flavour split (PROJECT_STRUCTURE.md).

## Purpose

A home for small UI tweaks that are too tiny to be their own addon and too specific to belong in any
existing one. Each tweak is one idempotent `Apply(enabled)` with a checkbox; all default **on**.

## Architecture

```
Client\Client.lua            VTP.Client.INTERFACE = { "MoveStateIconsToTopLeft", "FixCompareAttackPowerDelta" }
Client\Client_ClassicEra.lua re-anchors PlayerRestIcon (carries swords + glows); rewrites the compare AP delta line
Client\Client_Forever.lua    re-anchors ...PlayerFrameContentContextual.AttackIcon + .PlayerRestLoop; AP fix is a no-op
Client\Client_Select.lua     binds flavour onto VTP.Client, warns on missing/extra methods
Core.lua                     DB init (ADDON_LOADED), VTP.RegisterTweak, IsEnabled/SetEnabled, ApplyAll at PLAYER_LOGIN
Tweaks.lua                   one `do ... VTP.RegisterTweak({...}) end` block per tweak
Options.lua                  one checkbox + description per registered tweak, Reset button, status line, /vtp
```

**Rules for a tweak**
- `id` is a stable string; it is the SV key and must never be renamed once released.
- `Apply(enabled)` is idempotent and is called at login, on every checkbox change and on reset.
  `Apply(false)` must restore Blizzard's state.
- Never call Show/Hide/SetPoint on a secure frame; prefer alpha / hooks on plain regions.
- No Blizzard region paths outside `Client_*.lua`.

## Tweak: `moveStateIcons` (shipped)

**Problem.** Blizzard anchors the rest icon (Zzz) and the combat icon (swords) over the portrait's bottom-left,
which is also where `PlayerLevelText` lives. EasyFrames' larger portrait ring puts them squarely over the level
number (EasyFrames' own `Core:MoveLevelText()` is commented out upstream).

**Fix.** `Client.MoveStateIconsToTopLeft(enabled)` re-anchors the icons to the portrait's top-left corner;
`enabled == false` restores the stock anchors. Blizzard only Show/Hides these after load, so a one-shot SetPoint
sticks; `PlayerFrame_UpdateStatus` is `hooksecurefunc`'d to re-assert defensively. Regions only - combat-safe.

**Era** (`Blizzard_UnitFrame\Classic\PlayerFrame.xml`): `PlayerAttackIcon`, `PlayerStatusGlow` (holding
`PlayerRestGlow`/`PlayerAttackGlow`) are all anchored to `PlayerRestIcon` (stock TOPLEFT 19.5,-52 on PlayerFrame),
so moving `PlayerRestIcon` alone (-> 19.5,-12) carries everything. **Forever** (`Mainline\PlayerFrame.xml`):
`PlayerFrameContentContextual.AttackIcon` (atlas, stock 64,-62 -> 64,-12) and `.PlayerRestLoop` (flipbook frame,
-> 60,-8) are independent and each re-anchored; stock anchors captured via `GetPoint` on first use.
Forever offsets are a first guess - verify in game and tune.

**Not touched:** `PlayerAttackBackground` / `PlayerFrameFlash` (the red combat glow). Target frame has no state icons.

## Tweak: `fixCompareAttackPower` (shipped 2026-11-26)

**Problem.** On Classic Era `GetItemStats(link)` reports Attack Power in **item-budget units** - the item stat
budget values 1 point = 1 Str = 1 Agi = 2 AP, and the API hands back the budget point (a `+2 Attack Power`
dagger -> `ITEM_MOD_ATTACK_POWER_SHORT = 1`; owner research 2026-11-26). Blizzard's own compare block
("If you replace this item, the following stat changes will occur:") is built from that number by
`C_TooltipComparison.GetItemComparisonDelta`, so replacing that dagger with a no-AP staff prints
`-1 Attack Power`. Forever's `C_Item.GetItemStats` reports displayed AP and its compare block is correct.

**Where the lines come from.** `Blizzard_SharedXMLGame\Tooltip\TooltipComparisonManager.lua :SetItemTooltip()`
builds each `ShoppingTooltipN` as: `ClearLines`, header, `ProcessInfo(worn item's own tooltip data)`, then appends
the **pre-formatted strings** the delta API returns via `GameTooltip_AddHighlightLine`. A `TooltipDataProcessor`
post-call fires after `ProcessInfo` and never sees the delta lines; the hook is `hooksecurefunc` on
`TooltipComparisonManager.SetItemTooltip`, which runs with the block complete.

**Fix (the invariant that matters).** The corrected delta is **read from displayed text, never from the API and
never from Blizzard's delta line**: hovered AP is summed from `+N Attack Power` lines in the owning `GameTooltip`,
worn AP from the same lines in the shopping tooltip above the `ITEM_DELTA_DESCRIPTION` header. Then the first
line under the header matching `^[+-]N Attack Power$` is rewritten to `hovered - worn` (green/red by sign, cleared
when 0) - **only if it differs** from what Blizzard drew. Displayed text is the truth today and after any client
fix, so when Blizzard corrects the API this tweak becomes a no-op instead of doubling a fixed value. Other lines in
the block are not touched. Hook is installed once; disabling flips a flag the hook checks.

**Known limits.** Only Attack Power is corrected (the one budget-unit stat confirmed). Items whose AP comes from a
`Equip: Increases attack power by N.` line are also read; AP from set bonuses or procs is not. Secondary shopping
tooltip (`IF_EQUIPPED_TOGETHER`) is handled by the same hook when it carries its own delta block.

## Ideas backlog (not scheduled)

- Level number vs EasyFrames badge ring: the ring is baked into EasyFrames' border art (UI-TargetingFrame.blp),
  not a region, so it cannot be moved. A "centre the level text" tweak was tried (2026-11-23) and removed: it
  only looked wrong while resting and looked worse the rest of the time. Not worth reopening.
