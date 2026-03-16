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
    -- Unit ID and Service Type are set by players via the in-game menu,
    -- not here. They persist per-player via KVP.
}

-- ─────────────────────────────────────────────────────────────
--  PERMISSIONS
-- ─────────────────────────────────────────────────────────────

-- Discord role IDs allowed to open the bodycam settings menu.
-- Right-click a role in Discord (Developer Mode on) → "Copy Role ID", paste it below.
-- Leave as an empty table ({}) to allow ALL players to open the menu.
Config.AdminRoles = {
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

Config.BeepInterval  = 120000  -- ms between proximity beeps (2 minutes)
Config.BeepRange     = 15.0    -- metres at which beep can be heard
Config.BeepVolume    = 0.25    -- volume multiplier (distance-faded)

-- ─────────────────────────────────────────────────────────────
--  SERVICE TYPES
-- ─────────────────────────────────────────────────────────────
--  Shown in the settings menu when ERS is not running so players
--  can manually set their department badge on the overlay.
--  Add / remove entries to match your server's departments.
-- ─────────────────────────────────────────────────────────────

Config.ServiceTypes = {
    '',               -- blank = no service badge
    'POLICE',
    'FIRE',
    'EMS',
    'SAR',
    'RANGER',
    'SHERIFF',
    'HIGHWAY PATROL',
}

-- ─────────────────────────────────────────────────────────────
--  RECORDING TOGGLE SOUNDS
-- ─────────────────────────────────────────────────────────────
--  Each overlay style gets its own pair of sounds played when
--  recording starts (on) and stops (off).
--
--  Drop your WAV/MP3 files into  bonez-bodycam/html/sound/
--  and name them as below.  Placeholder copies of beep.wav
--  ship with the resource — replace them with real sounds.
-- ─────────────────────────────────────────────────────────────

Config.RecordSoundVolume = 0.80   -- 0.0 – 1.0
