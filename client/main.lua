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
    Settings.enabled = not Settings.enabled
    Settings.Save()

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(
        Settings.enabled
            and '~g~BODYCAM~s~: Overlay ~g~enabled'
            or  '~r~BODYCAM~s~: Overlay ~r~disabled'
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

        local uid    = tostring(GetPlayerServerId(PlayerId()))
        local active = Settings.enabled and ERSState.onShift

        SendNUIMessage({
            action       = 'setState',
            visible      = active,
            style        = Settings.style,
            position     = Settings.position,
            scale        = Settings.scale,
            uid          = uid,
            showUnit     = Settings.showUnit,
            showService  = Settings.showService,
            showCallout  = Settings.showCallout,
            showTracking = Settings.showTracking,
            serviceType      = ERSState.serviceType     or false,
            attachedCallout  = ERSState.attachedCallout or false,
            trackingUnit     = ERSState.trackingUnit    or false,
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
        if Settings.enabled and ERSState.onShift then
            TriggerServerEvent('bodycam:requestBeep')
        end
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
