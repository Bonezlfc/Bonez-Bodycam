-- ─────────────────────────────────────────────────────────────
--  client/main.lua  —  entry point: init, keybinds, NUI sync
-- ─────────────────────────────────────────────────────────────

Settings.Load()

-- ── [ key — open config menu ──────────────────────────────────

RegisterCommand(Config.MenuCommand, function()
    BodycamMenu.Open()
end, false)

RegisterKeyMapping(
    Config.MenuCommand,
    'Open Bodycam Settings Menu',
    'keyboard',
    Config.DefaultKey   -- LBRACKET
)

-- ── ] key — toggle overlay on / off ──────────────────────────

RegisterCommand(Config.ToggleCommand, function()
    -- Block turning on while not on duty
    if not Settings.enabled and not ERSState.onShift then
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName('~r~BODYCAM~s~: You must be on duty to enable the bodycam.')
        EndTextCommandThefeedPostTicker(false, true)
        return
    end

    Settings.enabled = not Settings.enabled
    Settings.Save()

    -- Turning the bodycam on starts recording; turning it off stops recording.
    -- No-op if evidence is not running or already in the correct state.
    if Settings.enabled then
        pcall(function() exports['bonez-bodycam_evidence']:startManualRecord() end)
    else
        pcall(function() exports['bonez-bodycam_evidence']:stopManualRecord() end)
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(
        Settings.enabled
            and '~g~BODYCAM~s~: ~g~ON ~s~— recording started'
            or  '~r~BODYCAM~s~: ~r~OFF ~s~— recording stopped'
    )
    EndTextCommandThefeedPostTicker(false, true)
end, false)

RegisterKeyMapping(
    Config.ToggleCommand,
    'Toggle Bodycam Overlay',
    'keyboard',
    Config.ToggleKey    -- RBRACKET
)

-- ── NUI state sync + server state notification (every 500 ms) ──
--
-- Pushes full current state to the NUI page so HTML/CSS/JS reflects
-- the latest Settings + ERSState.  Also notifies the server whenever
-- the active state changes so it can track who has a running bodycam.

local lastServerActive = nil   -- what we last told the server

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)

        local uid       = tostring(GetPlayerServerId(PlayerId()))
        local active    = Settings.enabled and IsRecording()
        local unitLabel = GetUnitLabel(uid)   -- custom badge/callsign, or server ID fallback

        SendNUIMessage({
            action       = 'setState',
            visible      = active,
            style        = Settings.style,
            position     = Settings.position,
            scale        = Settings.scale,
            uid          = uid,          -- raw server ID (used for device serial in NUI)
            unitLabel    = unitLabel,    -- display label (custom or server ID)
            showUnit     = Settings.showUnit,
            showService  = Settings.showService,
            showCallout  = Settings.showCallout,
            showTracking = Settings.showTracking,
            serviceType      = GetActiveServiceType()       or false,
            attachedCallout  = ERSState.attachedCallout     or false,
            trackingUnit     = ERSState.trackingUnit        or false,
        })

        -- Only fire the server event when state actually changes
        if active ~= lastServerActive then
            TriggerServerEvent('bodycam:setActive', active)
            lastServerActive = active
        end
    end
end)

-- ── Periodic proximity beep ───────────────────────────────────
--
-- While active, ask the server every BeepInterval ms to route a
-- beep to nearby players.  The server does distance filtering so
-- the event is never broadcast to the whole map.

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.BeepInterval)
        if Settings.enabled and IsRecording() then
            TriggerServerEvent('bodycam:requestBeep')
        end
    end
end)

-- ── bonez-bodycam_evidence auto-overlay export ───────────────
--
-- Called by bonez-bodycam_evidence when a callout is attached or
-- a unit is being tracked. Session-only — does NOT persist to KVP.

exports('setOverlayEnabled', function(state)
    Settings.enabled = (state == true)
end)

-- Called by bonez-bodycam_evidence when recording starts or stops.
-- Plays the audio feedback sound for the currently active overlay style.
exports('playRecordSound', function(recording)
    SendNUIMessage({
        action    = 'playRecordSound',
        recording = recording == true,
        style     = Settings.style,
        volume    = Config.RecordSoundVolume or 0.80,
    })
end)

-- ── Server time sync ─────────────────────────────────────────
--
-- Requests the server's wall-clock time so the overlay always shows
-- the server machine's local time regardless of the client's timezone.
-- Re-syncs every 5 minutes to stay accurate.

RegisterNetEvent('bodycam:serverTime')
AddEventHandler('bodycam:serverTime', function(adjustedEpoch)
    SendNUIMessage({
        action       = 'syncServerTime',
        serverTimeMs = adjustedEpoch * 1000,
    })
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)   -- small delay so server event handlers are ready
    while true do
        TriggerServerEvent('bodycam:requestServerTime')
        Citizen.Wait(300000)  -- re-sync every 5 minutes
    end
end)

-- ── Receive proximity beep ────────────────────────────────────
--
-- Server already confirmed we are within range.  We do a final
-- local distance check to drive a smooth volume curve before
-- forwarding the audio request to the NUI.

RegisterNetEvent('bodycam:playBeep', function(sx, sy, sz, range)
    local myCoords = GetEntityCoords(PlayerPedId())
    local dist = #(vector3(sx, sy, sz) - myCoords)

    -- Linear fade: full volume at 0 m, silent at range m
    local vol = math.max(0.0, math.min(1.0, (1.0 - (dist / range)) * (Config.BeepVolume or 1.0)))
    SendNUIMessage({ action = 'playBeep', volume = vol })
end)
