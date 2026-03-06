-- ─────────────────────────────────────────────────────────────
--  server/server.lua  —  bodycam state tracking + proximity beep
-- ─────────────────────────────────────────────────────────────
--
--  OneSync-safe design:
--    • Server tracks which players have an active bodycam.
--    • When a client requests a beep, the server calculates distance
--      to every other player SERVER-SIDE and only sends the event to
--      players within Config.BeepRange.  This means the beep event
--      is never broadcast across the whole map (no -1 TriggerClientEvent).
--    • GetEntityCoords on the server works for all peds under OneSync
--      (Infinity or Legacy) because the server tracks all entity positions.
-- ─────────────────────────────────────────────────────────────

local activeCams = {}   -- [serverId] = true

-- ── State sync ───────────────────────────────────────────────

-- Client fires this whenever its active state changes.
-- "active" = overlay enabled AND player is on shift.
RegisterNetEvent('bodycam:setActive', function(active)
    local src = source
    if active then
        activeCams[src] = true
    else
        activeCams[src] = nil
    end
end)

-- ── Proximity beep ───────────────────────────────────────────

-- Client fires this periodically while the bodycam is active.
-- Server checks the state, calculates distances, and sends the
-- playBeep event ONLY to players within range.
RegisterNetEvent('bodycam:requestBeep', function()
    local src = source

    -- Reject if the server doesn't think this player's cam is active
    -- (guards against spoofed events)
    if not activeCams[src] then return end

    local srcPed    = GetPlayerPed(src)
    local srcCoords = GetEntityCoords(srcPed)

    -- Config.BeepRange is a shared_script value; fall back to 15m if absent
    local range = (Config and Config.BeepRange) or 15.0

    for _, pidStr in ipairs(GetPlayers()) do
        local pid    = tonumber(pidStr)
        local ped    = GetPlayerPed(pid)
        local coords = GetEntityCoords(ped)

        local dx   = srcCoords.x - coords.x
        local dy   = srcCoords.y - coords.y
        local dz   = srcCoords.z - coords.z
        local dist = math.sqrt(dx*dx + dy*dy + dz*dz)

        if dist <= range then
            -- Pass source coords so the client can do its own fade-by-distance
            TriggerClientEvent('bodycam:playBeep', pid,
                               srcCoords.x, srcCoords.y, srcCoords.z, range)
        end
    end
end)

-- ── Clean up on disconnect ───────────────────────────────────

AddEventHandler('playerDropped', function()
    activeCams[source] = nil
end)
