-- ─────────────────────────────────────────────────────────────
--  client/menu.lua  —  NativeUI (embedded) + bodycam menu
-- ─────────────────────────────────────────────────────────────
--  NativeUI is defined here directly so no external file or
--  resource dependency is required.
--
--  Public API:
--    BodycamMenu.Open()
-- ─────────────────────────────────────────────────────────────

-- ═════════════════════════════════════════════════════════════
--  EMBEDDED NativeUI
-- ═════════════════════════════════════════════════════════════

NativeUI = {}

-- ── Layout ────────────────────────────────────────────────────
-- Right-side, vertically centred position
-- Visible menu height ≈ TH+SH+(10×IH)+border ≈ 0.474
-- Center start ≈ (1.0 - 0.474) / 2 = 0.263  → use 0.220 (slightly above centre)
local _ML      = 0.660
local _MW      = 0.242
local _MX      = _ML + _MW * 0.5
local _TH      = 0.058
local _SH      = 0.034
local _IH      = 0.038
local _MAX_VIS = 10
local _TPX     = _ML + 0.011
local _TRX     = _ML + _MW - 0.010
local _TOP_Y   = 0.220

-- ── Colours ───────────────────────────────────────────────────
local function _C(r,g,b,a) return {r,g,b,a} end

local _BG_TITLE = _C(  0,   0,   0, 248)
local _BG_SUB   = _C( 28,  28,  28, 220)
local _BG_ITEM  = _C(  0,   0,   0, 178)
local _BG_ITEM2 = _C( 14,  14,  14, 168)
local _BG_SEL   = _C(  0, 100, 200, 232)
local _FG_WHITE = _C(255, 255, 255, 255)
local _FG_LGREY = _C(195, 195, 195, 255)
local _FG_GREY  = _C(130, 130, 130, 255)

-- ── Draw helpers ──────────────────────────────────────────────
local function _Rect(cx, cy, w, h, col)
    DrawRect(cx, cy, w, h, col[1], col[2], col[3], col[4])
end

local function _Text(str, x, y, sc, col, font, rj)
    SetTextFont(font or 0)
    SetTextScale(sc, sc)
    SetTextColour(col[1], col[2], col[3], col[4])
    if rj then
        SetTextRightJustify(true)
        SetTextWrap(0.0, x)
    end
    SetTextEntry('STRING')
    AddTextComponentString(str)
    DrawText(x, y)
    if rj then
        SetTextRightJustify(false)
        SetTextWrap(0.0, 1.0)
    end
end

-- ── Item constructors ─────────────────────────────────────────
local function _NewItem(typ, text, desc)
    return {
        _type = typ, Text = text or '', Description = desc or '',
        _rightLabel = '',
        SetRightLabel = function(self, v) self._rightLabel = v or '' end,
    }
end

function NativeUI.CreateItem(text, desc)
    return _NewItem('item', text, desc)
end

function NativeUI.CreateCheckboxItem(text, checked, desc)
    local it = _NewItem('checkbox', text, desc)
    it.Checked = (checked == true)
    return it
end

function NativeUI.CreateListItem(text, list, idx, desc)
    local it = _NewItem('list', text, desc)
    it._list  = list or {}
    it._Index = math.max(1, idx or 1)
    return it
end

-- ── Menu constructor ──────────────────────────────────────────
function NativeUI.CreateMenu(title, subtitle, _x, _y)
    local m = {
        Title = title or '', SubTitle = subtitle or '',
        Visible = false, _items = {}, _selIdx = 1, _scrollOff = 0,
        OnCheckboxChange = nil, OnListChange = nil, OnItemSelect = nil,
    }
    function m:AddItem(item) table.insert(self._items, item) end
    function m:SetMenuWidthOffset(_) end
    return m
end

-- ── Rendering ─────────────────────────────────────────────────
local function _DrawMenu(menu)
    local items    = menu._items
    local n        = #items
    local visCount = math.min(n, _MAX_VIS)

    _Rect(_MX, _TOP_Y + _TH * 0.5, _MW, _TH, _BG_TITLE)
    _Rect(_ML + 0.002, _TOP_Y + _TH * 0.5, 0.004, _TH, _C(0, 110, 220, 255))
    _Text(string.upper(menu.Title), _TPX + 0.007, _TOP_Y + 0.015, 0.52, _FG_WHITE, 0)

    local subTop = _TOP_Y + _TH
    _Rect(_MX, subTop + _SH * 0.5, _MW, _SH, _BG_SUB)
    _Text(menu.SubTitle, _TPX, subTop + 0.008, 0.265, _FG_LGREY, 0)

    local itemsTop = subTop + _SH
    local startI   = menu._scrollOff + 1
    local endI     = math.min(n, menu._scrollOff + _MAX_VIS)

    for i = startI, endI do
        local item   = items[i]
        local row    = i - startI
        local rowTop = itemsTop + row * _IH
        local rowMid = rowTop + _IH * 0.5
        local isSel  = (i == menu._selIdx)

        _Rect(_MX, rowMid, _MW, _IH,
              isSel and _BG_SEL or (row % 2 == 0 and _BG_ITEM or _BG_ITEM2))
        _Rect(_MX, rowTop, _MW, 0.001, _C(255, 255, 255, 12))

        local ty = rowTop + _IH * 0.235
        local fc = isSel and _FG_WHITE or _FG_LGREY

        _Text(item.Text, _TPX, ty, 0.295, fc, 0)

        if item._type == 'checkbox' then
            _Text(item.Checked and '~g~[ON]' or '~r~[OFF]', _TRX, ty, 0.275, _FG_WHITE, 0, true)
        elseif item._type == 'list' then
            local val = item._list[item._Index] or ''
            local str = isSel and ('< ' .. val .. ' >') or val
            _Text(str, _TRX, ty, 0.275, isSel and _FG_WHITE or _FG_GREY, 0, true)
        elseif item._rightLabel ~= '' then
            _Text(item._rightLabel, _TRX, ty, 0.275, _FG_GREY, 0, true)
        end
    end

    _Rect(_MX, itemsTop + visCount * _IH, _MW, 0.002, _C(0, 110, 220, 180))

    if n > _MAX_VIS then
        local trackH = visCount * _IH
        local frac   = menu._scrollOff / (n - _MAX_VIS)
        local thumbH = math.max(0.016, trackH * (_MAX_VIS / n))
        local thumbY = itemsTop + frac * (trackH - thumbH) + thumbH * 0.5
        _Rect(_ML + _MW - 0.005, thumbY, 0.005, thumbH, _C(255, 255, 255, 70))
    end
end

-- ── Input ─────────────────────────────────────────────────────
local function _JP(ctrl)
    return IsDisabledControlJustPressed(0, ctrl)
end

local function _HandleInput(menu)
    local n = #menu._items
    if n == 0 then return end

    if _JP(172) then
        menu._selIdx = menu._selIdx - 1
        if menu._selIdx < 1 then
            menu._selIdx    = n
            menu._scrollOff = math.max(0, n - _MAX_VIS)
        elseif menu._selIdx <= menu._scrollOff then
            menu._scrollOff = menu._selIdx - 1
        end
    end

    if _JP(173) then
        menu._selIdx = menu._selIdx + 1
        if menu._selIdx > n then
            menu._selIdx    = 1
            menu._scrollOff = 0
        elseif menu._selIdx > menu._scrollOff + _MAX_VIS then
            menu._scrollOff = menu._selIdx - _MAX_VIS
        end
    end

    local item = menu._items[menu._selIdx]
    if not item then return end

    if item._type == 'list' and #item._list > 0 then
        if _JP(174) then
            item._Index = item._Index - 1
            if item._Index < 1 then item._Index = #item._list end
            if menu.OnListChange then menu.OnListChange(menu, item, item._Index) end
        elseif _JP(175) then
            item._Index = item._Index + 1
            if item._Index > #item._list then item._Index = 1 end
            if menu.OnListChange then menu.OnListChange(menu, item, item._Index) end
        end
    end

    if _JP(201) then
        if item._type == 'checkbox' then
            item.Checked = not item.Checked
            if menu.OnCheckboxChange then menu.OnCheckboxChange(menu, item, item.Checked) end
        else
            if menu.OnItemSelect then menu.OnItemSelect(menu, item, menu._selIdx) end
        end
    end

    if _JP(200) then
        menu.Visible = false
    end
end

-- ── Pool constructor ──────────────────────────────────────────
function NativeUI.CreatePool()
    local pool = { _menus = {} }

    function pool:Add(menu) table.insert(self._menus, menu) end

    function pool:RefreshIndex()
        for _, m in ipairs(self._menus) do
            local n = #m._items
            if n > 0 then
                if m._selIdx < 1 then m._selIdx = 1 end
                if m._selIdx > n then m._selIdx = n end
            end
        end
    end

    function pool:IsAnyMenuOpen()
        for _, m in ipairs(self._menus) do
            if m.Visible then return true end
        end
        return false
    end

    function pool:ProcessMenus()
        local anyOpen = false
        for _, m in ipairs(self._menus) do
            if m.Visible then
                anyOpen = true
                _DrawMenu(m)
                _HandleInput(m)
            end
        end
        if anyOpen then DisableAllControlActions(0) end
    end

    return pool
end

-- ═════════════════════════════════════════════════════════════
--  BODYCAM MENU
-- ═════════════════════════════════════════════════════════════

BodycamMenu = {}

local STYLE_LABELS = { 'Axon', 'Motorola', 'Generic' }
local STYLE_KEYS   = { 'axon', 'motorola', 'generic' }
local POS_LABELS   = { 'Top Left', 'Top Right', 'Bottom Left', 'Bottom Right' }
local POS_KEYS     = { 'topleft',  'topright',  'bottomleft',  'bottomright'  }
local SCALE_LABELS = { 'Small', 'Medium', 'Large' }
local SCALE_KEYS   = { 'small', 'medium', 'large' }

local menuPool, mainMenu
local initialized = false
local itEnabled, itStyle, itPosition, itScale
local itShowSvc, itShowCallout, itShowTracking, itShowUnit
local itErsStatus, itReset, itClose

local function RefreshItems()
    itEnabled.Checked      = Settings.enabled
    itStyle._Index         = IndexOf(STYLE_KEYS,  Settings.style)
    itPosition._Index      = IndexOf(POS_KEYS,    Settings.position)
    itScale._Index         = IndexOf(SCALE_KEYS,  Settings.scale)
    itShowSvc.Checked      = Settings.showService
    itShowCallout.Checked  = Settings.showCallout
    itShowTracking.Checked = Settings.showTracking
    itShowUnit.Checked     = Settings.showUnit
end

local function BuildMenu()
    menuPool = NativeUI.CreatePool()
    mainMenu = NativeUI.CreateMenu('BODYCAM', 'Configure overlay settings', 0.5, 0.15)
    menuPool:Add(mainMenu)

    itErsStatus  = NativeUI.CreateItem('ERS Status',          'Shows if night_ers is active.')
    itEnabled    = NativeUI.CreateCheckboxItem('Enable Overlay',       Settings.enabled,      'Toggle the bodycam overlay.')
    itStyle      = NativeUI.CreateListItem('Style',      STYLE_LABELS,  IndexOf(STYLE_KEYS,  Settings.style),    'Visual style of the overlay.')
    itPosition   = NativeUI.CreateListItem('Position',   POS_LABELS,    IndexOf(POS_KEYS,    Settings.position), 'Screen corner for the overlay.')
    itScale      = NativeUI.CreateListItem('Scale',      SCALE_LABELS,  IndexOf(SCALE_KEYS,  Settings.scale),    'Overlay text size.')
    itShowSvc    = NativeUI.CreateCheckboxItem('Show Service Type',     Settings.showService,  'Show ERS service on overlay.')
    itShowCallout= NativeUI.CreateCheckboxItem('Show Callout Status',   Settings.showCallout,  'Show CALLOUT badge.')
    itShowTracking=NativeUI.CreateCheckboxItem('Show Tracking Status',  Settings.showTracking, 'Show TRACKING badge.')
    itShowUnit   = NativeUI.CreateCheckboxItem('Show Unit ID',          Settings.showUnit,     'Show server ID as UNIT: X.')
    itReset      = NativeUI.CreateItem('Reset to Defaults',   'Restore all settings to defaults.')
    itClose      = NativeUI.CreateItem('Close',               'Close this menu.')

    for _, it in ipairs({ itErsStatus, itEnabled, itStyle, itPosition, itScale,
                          itShowSvc, itShowCallout, itShowTracking, itShowUnit,
                          itReset, itClose }) do
        mainMenu:AddItem(it)
    end

    menuPool:RefreshIndex()

    mainMenu.OnCheckboxChange = function(_, item, checked)
        if     item == itEnabled       then Settings.enabled      = checked
        elseif item == itShowSvc       then Settings.showService  = checked
        elseif item == itShowCallout   then Settings.showCallout  = checked
        elseif item == itShowTracking  then Settings.showTracking = checked
        elseif item == itShowUnit      then Settings.showUnit     = checked
        else return end
        Settings.Save()
    end

    mainMenu.OnListChange = function(_, item, index)
        if     item == itStyle    then Settings.style    = STYLE_KEYS[index]
        elseif item == itPosition then Settings.position = POS_KEYS[index]
        elseif item == itScale    then Settings.scale    = SCALE_KEYS[index]
        else return end
        Settings.Save()
    end

    mainMenu.OnItemSelect = function(_, item, _)
        if item == itReset then
            Settings.Reset()
            RefreshItems()
            menuPool:RefreshIndex()
        elseif item == itClose then
            mainMenu.Visible = false
        end
    end

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if menuPool:IsAnyMenuOpen() then
                itErsStatus:SetRightLabel(ERSState.available and 'Active' or 'Not Detected')
            end
            menuPool:ProcessMenus()
        end
    end)

    initialized = true
end

function BodycamMenu.Open()
    if not initialized then BuildMenu() end
    RefreshItems()
    menuPool:RefreshIndex()
    mainMenu.Visible = true
end
