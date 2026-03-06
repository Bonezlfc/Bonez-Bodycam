Config = {}

-- ─────────────────────────────────────────────────────────────
--  KEYBINDS / COMMANDS
-- ─────────────────────────────────────────────────────────────

-- [ = open the configuration menu
Config.MenuCommand = 'bodycam'
Config.DefaultKey  = 'LBRACKET'

-- ] = toggle the overlay on / off (quick access, no menu needed)
Config.ToggleCommand = 'bodycamtoggle'
Config.ToggleKey     = 'RBRACKET'

-- ─────────────────────────────────────────────────────────────
--  DEFAULT OVERLAY SETTINGS
-- ─────────────────────────────────────────────────────────────

Config.Defaults = {
    enabled      = true,
    style        = 'axon',        -- 'axon' | 'motorola' | 'generic'
    position     = 'topright',    -- 'topleft' | 'topright' | 'bottomleft' | 'bottomright'
    scale        = 'medium',      -- 'small' | 'medium' | 'large'
    showService  = true,
    showCallout  = true,
    showTracking = true,
    showUnit     = true,
}

-- ─────────────────────────────────────────────────────────────
--  PERFORMANCE
-- ─────────────────────────────────────────────────────────────

Config.ERSPollInterval = 300   -- ms between ERS export polls

-- ─────────────────────────────────────────────────────────────
--  LAYOUT
-- ─────────────────────────────────────────────────────────────

Config.Padding       = 0.012   -- safe-area gap from screen edge
Config.BlinkInterval = 900     -- REC blink period (ms)

-- ─────────────────────────────────────────────────────────────
--  PROXIMITY SOUND
-- ─────────────────────────────────────────────────────────────

-- How often (ms) the bodycam emits a beep audible to nearby players
Config.BeepInterval  = 120000  -- 2 minutes

-- Maximum distance (metres) at which the beep can be heard
Config.BeepRange     = 15.0

-- Master volume multiplier for the proximity beep (0.0 = silent, 1.0 = full)
-- The final per-player volume is this value × the distance fade (loud nearby, quiet at edge)
Config.BeepVolume    = 0.25
