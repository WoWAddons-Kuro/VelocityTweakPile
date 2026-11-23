# Velocity Tweak Pile - spec

**Repo:** `VelocityTweakPile\` (origin WoWAddons-Kuro/VelocityTweakPile). **Slash:** `/vtp`. **SV:** `VelocityTweakPileDB`.
**Clients:** Classic Era (11509) and WoW Forever (16001), via the `Client\` flavour split (PROJECT_STRUCTURE.md).

## Purpose

A home for small UI tweaks that are too tiny to be their own addon and too specific to belong in any
existing one. Each tweak is one idempotent `Apply(enabled)` with a checkbox; all default **on**.

## Architecture

```
Client\Client.lua            VTP.Client.INTERFACE = { "PlayerCombatIconRegions" }
Client\Client_ClassicEra.lua PlayerAttackIcon, PlayerAttackGlow (named globals)
Client\Client_Forever.lua    PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.AttackIcon
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

## Tweak: `hideCombatIcon` (shipped)

**Problem.** Blizzard anchors `PlayerAttackIcon` (+ `PlayerAttackGlow` on Era) to `PlayerRestIcon` at the
portrait's bottom-left, which is also where `PlayerLevelText` lives. EasyFrames' larger portrait ring puts the
swords squarely over the level number (EasyFrames' own `Core:MoveLevelText()` is commented out upstream).

**Fix.** `SetAlpha(0)` on the regions returned by `Client.PlayerCombatIconRegions()`; `SetAlpha(1)` when
disabled. `PlayerFrame_UpdateStatus()` uses Show/Hide (not alpha) so a one-shot alpha sticks; it is additionally
`hooksecurefunc`'d to re-assert alpha defensively. Textures only - safe in combat lockdown.

**Era regions** (`Blizzard_UnitFrame\Classic\PlayerFrame.xml`): `PlayerAttackIcon` (UI-StateIcon, right half) and
`PlayerAttackGlow` (ADD blend). **Forever** (`Mainline\PlayerFrame.xml`): single atlas texture
`UI-HUD-UnitFrame-Player-CombatIcon` at `...PlayerFrameContentContextual.AttackIcon`; no glow.

**Not touched:** `PlayerAttackBackground` / `PlayerFrameFlash` (the red combat glow) - that remains the combat cue.
Target frame has no combat icon; enemy level is unaffected.

## Ideas backlog (not scheduled)

- none yet
