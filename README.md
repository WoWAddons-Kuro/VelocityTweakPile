# Velocity Tweak Pile

A pile of **small, independent tweaks** to Blizzard's UI. Each tweak is one checkbox, on by default,
applies immediately, and fully undoes itself when you turn it off. Nothing else is bundled.

**Classic Era / Hardcore and WoW Forever**, from one codebase.

## The tweaks

### Hide the player frame's combat swords icon

Blizzard draws the crossed-swords "in combat" icon over the bottom-left of your portrait - exactly
where your **level** is. The stock art half-covers the number; unit-frame skins such as EasyFrames
cover it completely. On a hardcore character you need your level readable at all times, so this
tweak fades the swords to invisible. The red combat glow / flash still shows, so you still know you
are in combat.

Works whether or not EasyFrames (or any other unit-frame skin that keeps Blizzard's frames) is loaded:
it only touches Blizzard's own textures, and never a secure frame, so it is combat-safe.

## Options

`/vtp` opens the page (Options > AddOns > Velocity Tweak Pile). `/vtp status` lists the tweaks and
their state; `/vtp reset` turns everything back on. Settings are account-wide.

## Licence

MIT.
