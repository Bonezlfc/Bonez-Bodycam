---@diagnostic disable: undefined-global, duplicate-set-field, need-check-nil, undefined-field, lowercase-global
-- Bonez-Bodycam | client/menu.lua
-- Bodycam settings menu using the bundled FrazzIe NativeUI.
-- Role-gated: only players whose Discord roles match Config.AdminRoles may open it.

-- ── Permissions ────────────────────────────────────────────────
playerPerms = {}   -- populated server-side via bodycam:perms event

Citizen.CreateThread(function()
    Citizen.Wait(500)
    if NetworkIsSessionStarted() then
        TriggerServerEvent('bodycam:checkPerms')
    end
end)

RegisterNetEvent('bodycam:perms')
AddEventHandler('bodycam:perms', function(roles)
    playerPerms = roles or {}
end)

-- ── Labels / keys ──────────────────────────────────────────────
BodycamMenu = {}

local STYLE_LABELS = { 'Axon', 'Motorola', 'Generic' }
local STYLE_KEYS   = { 'axon', 'motorola', 'generic' }
local POS_LABELS   = { 'Top Left', 'Top Right', 'Bottom Left', 'Bottom Right' }
local POS_KEYS     = { 'topleft',  'topright',  'bottomleft',  'bottomright'  }
local SCALE_LABELS = { 'Small', 'Medium', 'Large' }
local SCALE_KEYS   = { 'small', 'medium', 'large' }

-- Service type list — built from Config.ServiceTypes at startup
local SVC_LABELS = {}
local SVC_KEYS   = {}
for _, v in ipairs(Config.ServiceTypes or {}) do
    local label = (v == '') and '(None)' or v
    table.insert(SVC_LABELS, label)
    table.insert(SVC_KEYS,   v)
end
if #SVC_KEYS == 0 then
    SVC_LABELS = { '(None)' }
    SVC_KEYS   = { '' }
end

local menuPool, mainMenu
local itStatus   -- updated each frame in the render loop

-- ── Onscreen keyboard input ────────────────────────────────────
local function GetKeyboardInput(title, defaultVal, maxLen)
    AddTextEntry('BC_KB_INPUT', title)
    DisplayOnscreenKeyboard(1, 'BC_KB_INPUT', '', defaultVal or '', '', '', '', maxLen or 12)
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Citizen.Wait(0)
    end
    EnableAllControlActions(0)
    if UpdateOnscreenKeyboard() == 1 then
        return GetOnscreenKeyboardResult()
    end
    return nil  -- cancelled
end

-- ── Rebuild — clears and repopulates the menu ──────────────────
local function Rebuild()
    mainMenu:Clear()

    -- ── Status (read-only, updated each frame) ─────────────────
    itStatus          = NativeUI.CreateItem('Status', 'Live bodycam state')
    itStatus.Enabled  = false

    -- ── Identity ────────────────────────────────────────────────
    local uid         = Settings.manualUnitId ~= '' and Settings.manualUnitId
                        or ('SID ' .. tostring(GetPlayerServerId(PlayerId())))
    local itUnitId    = NativeUI.CreateItem('Unit ID', 'Your badge / callsign shown on the overlay')
    itUnitId:RightLabel(uid)

    local itSvcType   = NativeUI.CreateListItem(
                            'Service Type', SVC_LABELS,
                            IndexOf(SVC_KEYS, Settings.manualServiceType),
                            'Your department badge. ERS takes priority when on shift.'
                        )

    -- ── Appearance ──────────────────────────────────────────────
    local itStyle     = NativeUI.CreateListItem('Camera Style', STYLE_LABELS, IndexOf(STYLE_KEYS, Settings.style),    'Visual style of the overlay.')
    local itPosition  = NativeUI.CreateListItem('Position',     POS_LABELS,   IndexOf(POS_KEYS,   Settings.position), 'Screen corner for the overlay.')
    local itScale     = NativeUI.CreateListItem('Scale',        SCALE_LABELS, IndexOf(SCALE_KEYS, Settings.scale),    'Overlay text size.')

    -- ── Visibility toggles ──────────────────────────────────────
    local itEnabled   = NativeUI.CreateCheckboxItem('Show Overlay',         Settings.enabled,      'Toggle the bodycam overlay on / off.')
    local itShowUnit  = NativeUI.CreateCheckboxItem('Show Unit ID',         Settings.showUnit,     'Display your unit ID on the overlay.')
    local itShowSvc   = NativeUI.CreateCheckboxItem('Show Service Badge',   Settings.showService,  'Display your service / department badge.')
    local itShowCO    = NativeUI.CreateCheckboxItem('Show Callout Badge',   Settings.showCallout,  'Show CALLOUT badge when attached to a callout.')
    local itShowTR    = NativeUI.CreateCheckboxItem('Show Tracking Badge',  Settings.showTracking, 'Show TRACKING badge when tracking a unit.')

    -- ── Actions ─────────────────────────────────────────────────
    local itReset     = NativeUI.CreateItem('Reset Defaults', 'Restore all settings to defaults.')
    local itClose     = NativeUI.CreateItem('Close',          'Close this menu.')

    for _, it in ipairs({
        itStatus,
        itUnitId, itSvcType,
        itStyle, itPosition, itScale,
        itEnabled, itShowUnit, itShowSvc, itShowCO, itShowTR,
        itReset, itClose,
    }) do
        mainMenu:AddItem(it)
    end

    -- ── Callbacks ───────────────────────────────────────────────

    -- Unit ID: close menu, open keyboard, save, reopen
    itUnitId.Activated = function()
        mainMenu:Visible(false)
        Citizen.SetTimeout(150, function()
            local current = Settings.manualUnitId ~= '' and Settings.manualUnitId or ''
            local input   = GetKeyboardInput('Unit ID (badge / callsign)', current, 12)
            if input ~= nil then
                -- Trim whitespace
                Settings.manualUnitId = input:gsub('^%s+', ''):gsub('%s+$', '')
                Settings.Save()
            end
            Rebuild()
            mainMenu:Visible(true)
        end)
    end

    itSvcType.OnListChanged  = function(_, _, i) Settings.manualServiceType = SVC_KEYS[i]  Settings.Save() end
    itStyle.OnListChanged    = function(_, _, i) Settings.style             = STYLE_KEYS[i] Settings.Save() end
    itPosition.OnListChanged = function(_, _, i) Settings.position          = POS_KEYS[i]   Settings.Save() end
    itScale.OnListChanged    = function(_, _, i) Settings.scale             = SCALE_KEYS[i] Settings.Save() end

    itEnabled.CheckboxEvent  = function(_, _, v) Settings.enabled      = v  Settings.Save() end
    itShowUnit.CheckboxEvent = function(_, _, v) Settings.showUnit     = v  Settings.Save() end
    itShowSvc.CheckboxEvent  = function(_, _, v) Settings.showService  = v  Settings.Save() end
    itShowCO.CheckboxEvent   = function(_, _, v) Settings.showCallout  = v  Settings.Save() end
    itShowTR.CheckboxEvent   = function(_, _, v) Settings.showTracking = v  Settings.Save() end

    itReset.Activated = function()
        Settings.Reset()
        Rebuild()
    end

    itClose.Activated = function()
        mainMenu:Visible(false)
    end

    menuPool:RefreshIndex()
end

-- ── Menu init — runs once ──────────────────────────────────────
local initialized = false

local function Init()
    menuPool = NativeUI.CreatePool()
    mainMenu = NativeUI.CreateMenu('BODYCAM', 'Configure settings')
    menuPool:Add(mainMenu)
    initialized = true

    -- Render thread — ProcessMenus must run every frame (not gated on visibility)
    -- so NativeUI's input state is always current. Gating it causes one-frame
    -- input buffering that makes list items skip when you first press left/right.
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            menuPool:ProcessMenus()
            if menuPool:IsAnyMenuOpen() then
                -- Update status label
                if itStatus then
                    local unitLabel = GetUnitLabel(tostring(GetPlayerServerId(PlayerId())))
                    local recState  = IsRecording() and '~g~REC' or '~s~OFF'
                    itStatus:RightLabel(unitLabel .. '  |  ' .. recState)
                end
                -- Block game controls so they don't double-fire into NativeUI
                -- and cause list items to jump when navigating left/right.
                DisableAllControlActions(0)
            end
        end
    end)
end

-- ── Permission check ───────────────────────────────────────────
local function HasAccess()
    if not Config.AdminRoles or #Config.AdminRoles == 0 then return true end
    for _, required in ipairs(Config.AdminRoles) do
        for _, role in ipairs(playerPerms) do
            if role == required then return true end
        end
    end
    return false
end

-- ── Public API ─────────────────────────────────────────────────
function BodycamMenu.Open()
    if not HasAccess() then
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName('~r~BODYCAM~s~: You do not have permission to access settings.')
        EndTextCommandThefeedPostTicker(false, true)
        return
    end

    if not initialized then Init() end
    Rebuild()
    mainMenu:Visible(true)
end
