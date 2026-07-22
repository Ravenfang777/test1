-- Kingdom Hearts Final Mix (Steam)
-- Companion for KH1FM_SoraComboVisuals_Controller_v13_BANKSAFE.lua.
--
-- This script narrows invulnerability for the two v13 replacements:
--   D4 Guard routed to the Ripple Drive container at slot 0x71.
--   DC Dodge Roll routed to the Zantetsuken container at slot 0x74.
-- Native Guard, Dodge Roll, Ripple Drive, and Zantetsuken are untouched.

-- ========================================================================
-- EDITABLE SETTINGS (animation frames)
-- ========================================================================

local GUARD_IFRAME_START = 70.0
local DODGE_IFRAME_START = 70.0
local DODGE_IFRAME_END = 72.0
local LOG_TRANSITIONS = true

-- ========================================================================
-- VERIFIED STEAM / V13 LAYOUT
-- ========================================================================

local SORA_POINTER = 0x2537E48
local POINTER_BANK_TABLE = 0x2EE3980

local CURRENT_ANIMATION_OFFSET = 0x164
local ANIMATION_TIME_OFFSET = 0x16C
local ACTIVE_POINTER_ARRAY_OFFSET = 0x1D4

local ID_GUARD = 0xD4
local ID_DODGE_ROLL = 0xDC
local SLOT_GUARD = 0x006E
local SLOT_RIPPLE_CONTAINER = 0x0071
local SLOT_DODGE_ROLL = 0x0075
local SLOT_ZANT_CONTAINER = 0x0074
local INVULNERABLE_BIT = 0x80

local previousSora = 0
local insideReplacement = false
local previousWindow = false
local previousDefenseName = nil
local warnedOrder = false

local function log(message)
    ConsolePrint("[SoraDefenseWindowV14] " .. message)
end

local function unsigned32(value)
    if value == nil then
        return 0
    end
    if value < 0 then
        return value + 4294967296
    end
    return value
end

local function resolveCompressedPointer(encoded)
    local value = unsigned32(encoded)
    if value == 0 then
        return 0
    end
    if value < 0x80000000 then
        return value
    end

    local payload = value - 0x80000000
    local bankIndex = math.floor(payload / 0x2000000)
    local bankOffset = payload % 0x2000000
    local bankBase = ReadLong(POINTER_BANK_TABLE + bankIndex * 8)
    if bankBase == nil or bankBase == 0 then
        return 0
    end
    return bankBase + bankOffset
end

local function sameMotionPointer(activeArray, firstSlot, secondSlot)
    if activeArray == 0 then
        return false
    end
    local first = unsigned32(ReadInt(activeArray + firstSlot * 4))
    local second = unsigned32(ReadInt(activeArray + secondSlot * 4))
    if first == 0 or second == 0 then
        return false
    end
    return first == second
end

local function setInvulnerableBit(sora, enabled)
    local flags = ReadByte(sora)
    if flags == nil then
        return false
    end

    local hasBit = (flags % 0x100) >= 0x80
    if enabled and not hasBit then
        WriteByte(sora, flags + INVULNERABLE_BIT)
    elseif not enabled and hasBit then
        WriteByte(sora, flags - INVULNERABLE_BIT)
    end
    return true
end

function _OnInit()
    if GUARD_IFRAME_START < 0
        or DODGE_IFRAME_START < 0
        or DODGE_IFRAME_END <= DODGE_IFRAME_START
    then
        log("DISABLED: invalid iframe interval.")
        return
    end
    log(string.format(
        "READY: replacement Guard/Ripple is vulnerable before frame %.1f.",
        GUARD_IFRAME_START
    ))
    log(string.format(
        "READY: replacement Dodge/Zantetsuken is vulnerable before frame %.1f and from frame %.1f onward.",
        DODGE_IFRAME_START,
        DODGE_IFRAME_END
    ))
    log("All native abilities are unchanged.")
end

function _OnFrame()
    local sora = ReadLong(SORA_POINTER)
    if sora == nil or sora == 0 then
        previousSora = 0
        insideReplacement = false
        previousWindow = false
        previousDefenseName = nil
        return
    end

    if sora ~= previousSora then
        previousSora = sora
        insideReplacement = false
        previousWindow = false
        previousDefenseName = nil
    end

    local animation = ReadByte(sora + CURRENT_ANIMATION_OFFSET)
    local encodedArray = unsigned32(ReadInt(sora + ACTIVE_POINTER_ARRAY_OFFSET))
    local activeArray = resolveCompressedPointer(encodedArray)
    local isGuardReplacement = animation == ID_GUARD
        and sameMotionPointer(activeArray, SLOT_GUARD, SLOT_RIPPLE_CONTAINER)
    local isDodgeReplacement = animation == ID_DODGE_ROLL
        and sameMotionPointer(activeArray, SLOT_DODGE_ROLL, SLOT_ZANT_CONTAINER)

    if not isGuardReplacement and not isDodgeReplacement then
        insideReplacement = false
        previousWindow = false
        previousDefenseName = nil
        return
    end

    local frame = ReadFloat(sora + ANIMATION_TIME_OFFSET) or 0.0
    local defenseName = "Guard/Ripple"
    local inWindow = frame >= GUARD_IFRAME_START
    if isDodgeReplacement then
        defenseName = "Dodge/Zantetsuken"
        inWindow = frame >= DODGE_IFRAME_START and frame < DODGE_IFRAME_END
    end

    -- This file intentionally starts with ZZ_ so its frame handler runs after
    -- the v13 controller and can narrow v13's full-duration bit 0x80 window.
    if not setInvulnerableBit(sora, inWindow) then
        return
    end

    if LOG_TRANSITIONS and (not insideReplacement
        or defenseName ~= previousDefenseName
        or inWindow ~= previousWindow)
    then
        local state = inWindow and "INVULNERABLE" or "VULNERABLE"
        log(string.format("%s frame %.1f: %s", defenseName, frame, state))
    end
    insideReplacement = true
    previousWindow = inWindow
    previousDefenseName = defenseName

    if not warnedOrder and frame > 0.0 then
        warnedOrder = true
        local flags = ReadByte(sora) or 0
        local actual = (flags % 0x100) >= 0x80
        if actual ~= inWindow then
            log("WARNING: another script overwrote the iframe bit after this companion ran; rename this file so it loads last.")
        end
    end
end
