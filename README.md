# Bonez-Bodycam

A FiveM bodycam overlay resource with three visual styles. Requires **Night_ers** and **night_shifts** — the overlay is only visible while a player is on shift.

---

## Features

- Three overlay styles: **Axon**, **Motorola**, and **Generic (Watchdog)**
- Configurable corner position and text scale
- Optional info lines: Service Type, Callout Status, Tracking Status, Unit ID
- In-game settings menu (no file edits needed per player)
- Per-player settings saved via KVP (persist across sessions)
- Proximity beep: nearby players hear a soft beep while your bodycam is active
- NUI (HTML/CSS) rendering — sharp at any resolution
- OneSync compatible
- NativeUI is embedded — no separate NativeUI resource needed

---

## Requirements

- **FiveM** server (OneSync Legacy or Infinity recommended)
- **Night_ers** — required; controls on-shift detection
- **night_shifts** — required; provides shift state data to Night_ers

---

## Installation

1. Drop the `Bonez-Bodycam` folder into your server's `resources` directory.
2. Add `ensure Bonez-Bodycam` to your `server.cfg`.
3. Restart your server or use `refresh` + `ensure Bonez-Bodycam` in the console.

---

## Default Keybinds

Players can rebind these in **FiveM Settings → Key Bindings → Bonez-Bodycam**.

| Action | Default Key | Command |
|---|---|---|
| Open settings menu | `[` (Left Bracket) | `/bodycam` |
| Toggle overlay on/off | `]` (Right Bracket) | `/bodycamtoggle` |

To change the server-side defaults, edit `Config.DefaultKey` and `Config.ToggleKey` in [config.lua](config.lua).

---

## Configuration

All options are in [config.lua](config.lua).

```lua
-- Default overlay appearance (players can override via in-game menu)
Config.Defaults = {
    enabled      = true,
    style        = 'axon',      -- 'axon' | 'motorola' | 'generic'
    position     = 'topright',  -- 'topleft' | 'topright' | 'bottomleft' | 'bottomright'
    scale        = 'medium',    -- 'small' | 'medium' | 'large'
    showService  = true,        -- show ERS service type (FIRE, EMS, etc.)
    showCallout  = true,        -- show CALLOUT badge when attached to a callout
    showTracking = true,        -- show TRACKING badge
    showUnit     = true,        -- show server ID as UNIT: X
}

-- How often the bodycam emits a proximity beep (milliseconds)
Config.BeepInterval = 120000   -- 2 minutes

-- Maximum distance (metres) at which the beep can be heard
Config.BeepRange    = 15.0

-- Volume of the beep (0.0 = silent, 1.0 = full)
Config.BeepVolume   = 0.25
```

---

## In-Game Menu

Open with the menu keybind (default `[`). The menu lets players configure:

- Enable / disable the overlay
- Overlay style, position, and scale
- Which info lines to show
- Reset to server defaults
- Live ERS status indicator

---

## Dependencies

This resource requires both **Night_ers** and **night_shifts** to be running. The overlay will only show while a player is on shift — if either dependency is not started, the overlay will not appear.

---

## File Structure

```
Bonez-Bodycam/
  config.lua             -- server-side defaults and tunables
  fxmanifest.lua
  shared/
    util.lua             -- shared helper functions
  client/
    settings.lua         -- KVP-backed per-player settings
    ers.lua              -- Night_ers polling thread
    menu.lua             -- embedded NativeUI + settings menu
    main.lua             -- entry point, keybinds, NUI sync, beep logic
  server/
    server.lua           -- state tracking + proximity beep routing
  html/
    index.html           -- NUI overlay (all three styles)
    css/style.css
    fonts/KlartextMonoBold.ttf
    img/logo.png
    sound/beep.wav
```

---

## Credits

- **Bonez Workshop** — script author
- KlartextMono font — used for overlay text
- Axon style inspired by real-world AXON Body 3 BWC layout
- Motorola style inspired by Motorola Solutions BWC2 layout
