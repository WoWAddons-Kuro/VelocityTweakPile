# Velocity Tweak Pile

A pile of **small, independent tweaks** to Blizzard's UI. Each tweak is one checkbox, on by default,
applies immediately, and fully undoes itself when you turn it off. Nothing else is bundled.

**Classic Era / Hardcore and WoW Forever**, from one codebase.

## The tweaks

### Move the rest (Zzz) and combat (swords) icons to the top-left of the portrait

Blizzard draws the crossed-swords "in combat" icon over the bottom-left of your portrait - exactly
where your **level** is. The stock art half-covers the number; unit-frame skins such as EasyFrames
cover it completely. On a hardcore character you need your level readable at all times, so this
tweak moves both icons to the portrait's top-left corner, where nothing else lives.

Works whether or not EasyFrames (or any other unit-frame skin that keeps Blizzard's frames) is loaded:
it only touches Blizzard's own textures, and never a secure frame, so it is combat-safe.

### Centre the level number in its badge

Blizzard right-aligns the level, so with a skin it sits off-centre in the ring and shifts as digits
change. This centres it on the badge.

## Options

`/vtp` opens the page (Options > AddOns > Velocity Tweak Pile). `/vtp status` lists the tweaks and
their state; `/vtp reset` turns everything back on. Settings are account-wide.

## Licence

MIT.
