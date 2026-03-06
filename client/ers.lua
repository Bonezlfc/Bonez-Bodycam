-- ─────────────────────────────────────────────────────────────
--  client/ers.lua  —  ERS export wrappers + polling thread
-- ─────────────────────────────────────────────────────────────
--  Exposes a single global table: ERSState
--    .available       (bool) — night_ers resource is running
--    .onShift         (bool) — player is currently on shift
--    .serviceType     (str|nil) — active service ("FIRE", "EMS", etc.)
--    .attachedCallout (bool) — player is attached to a callout
--    .trackingUnit    (bool) — player is tracking a unit
--
--  The table is updated every Config.ERSPollInterval ms.
--  All export calls are pcall-wrapped so a bad export never
--  crashes the resource.
-- ─────────────────────────────────────────────────────────────

ERSState = {
    available       = false,
    onShift         = false,
    serviceType     = nil,
    attachedCallout = false,
    trackingUnit    = false,
}

-- ── helpers ──────────────────────────────────────────────────

-- Safe wrapper: calls fn, returns (ok, result).  Never throws.
local function SafeExport(fn)
    local ok, result = pcall(fn)
    return ok, result
end

-- ── poll ─────────────────────────────────────────────────────

local function PollERS()
    -- Bail immediately if the ERS resource isn't running
    if GetResourceState('night_ers') ~= 'started' then
        ERSState.available       = false
        ERSState.onShift         = false
        ERSState.serviceType     = nil
        ERSState.attachedCallout = false
        ERSState.trackingUnit    = false
        return
    end

    ERSState.available = true

    local ok, val

    ok, val = SafeExport(function()
        return exports['night_ers']:getIsPlayerOnShift()
    end)
    ERSState.onShift = ok and (val == true) or false

    -- Only pull the detailed state when on shift — skip unnecessary calls
    if ERSState.onShift then
        ok, val = SafeExport(function()
            return exports['night_ers']:getPlayerActiveServiceType()
        end)
        ERSState.serviceType = (ok and type(val) == 'string') and val or nil

        ok, val = SafeExport(function()
            return exports['night_ers']:getIsPlayerAttachedToCallout()
        end)
        ERSState.attachedCallout = ok and (val == true) or false

        ok, val = SafeExport(function()
            return exports['night_ers']:getIsPlayerTrackingUnit()
        end)
        ERSState.trackingUnit = ok and (val == true) or false
    else
        ERSState.serviceType     = nil
        ERSState.attachedCallout = false
        ERSState.trackingUnit    = false
    end
end

-- ── polling thread ────────────────────────────────────────────

Citizen.CreateThread(function()
    while true do
        PollERS()
        Citizen.Wait(Config.ERSPollInterval)
    end
end)
