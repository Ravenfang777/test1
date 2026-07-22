-- Kingdom Hearts Final Mix (Steam)
-- Sora moveset all-in-one controller v1.
--
-- Combines the four validated controllers listed below without removing any
-- editable setting, option, lookup table, label, validation, or cleanup path.
-- Disable the four standalone source Lua files while using this build.
-- EDITABLE SETTINGS remain in their original labeled sections inside each module.

local function buildComboVisuals()
    -- ====================================================================
    -- BEGIN EMBEDDED CONTROLLER: SoraComboVisualsV13
    -- ====================================================================
-- Kingdom Hearts Final Mix (Steam)
-- Combined Sora combo/visual controller v13 with bank-safe motion routing.
--
-- REQUIRED MSET (unchanged from v11; byte-for-byte identical)
--   xa_ex_0010_SoraComboVisuals_v11_EFFECTS_DEFENSE_POC.mset
--   SHA-256: 3dfac78e664d1eff4c04ee530974b5e6cc5760b5eb12b3bd6df740d3319f6047
--
-- LAYOUT
--   C8 ground attack 1: Raid throw -> real second press -> Raid catch
--   C9 ground attack 2: Raid throw -> real second press -> Raid catch
--   D0 Sliding Dash: Judgement Raid -> real second press -> Raid catch
--   CC air attack 1: Aerial Sweep -> real second press -> Ragnarok F7
--   CD air attack 2: Aerial Sweep -> real second press -> Ragnarok F7
--   D4 Guard: Ripple visual/effect controls plus delayed invulnerability
--   DC Dodge Roll: Zantetsuken visual plus delayed invulnerability
--
-- No input is generated. This script never writes animation ID, resolved
-- motion index, animation time, damage, hitbox, movement, HP, or speed.
-- It permanently routes four visual-only slots while the main Sora MSET is
-- active, and temporarily routes combo continuations after a genuine attack.
--
-- VERIFIED DEFENSE NOTE
--   Controlled hit tests proved that Sora runtime byte +0x00 bit 0x80 is the
--   post-hit damage-rejection flag. v13 preserves every other bit and applies
--   only 0x80 while replaced D4/DC is active. Repeated front/rear Guard and
--   Dodge Roll contacts produced no HP loss or damage animation. The bit is
--   cleared after normal exits and left to the game after any damage state.
--
-- FIXED-LAYOUT STORAGE NOTE
--   To avoid resizing the MSET, v11 uses physical slots 0x03, 0x6F, 0x71,
--   and 0x74 as motion containers. Slot 0x6F is normally D5; slots 0x71 and
--   0x74 are normally D7 and DA. This POC therefore does not preserve those
--   three source attacks as independent, fully functional attacks.

-- ========================================================================
-- EDITABLE SETTINGS
-- ========================================================================

local ENABLE_CONTROLLER = true
local LOG_DETAILS = true
local ENABLE_FULL_DEFENSE_INVULNERABILITY = true

-- Replacement-only vulnerable startup windows (animation frames).
-- The protection bit is OFF before the selected frame and ON afterward.
-- Native Guard, Dodge Roll, Ripple Drive, and Zantetsuken are unchanged.
local GUARD_INVULNERABILITY_START_FRAME = 30.0
local DODGE_INVULNERABILITY_START_FRAME = 30.0

-- Replaced Guard ends at frame 99 and replaced Dodge Roll at frame 89.
local MAX_DEFENSE_PROTECTION_FRAME = 110

-- ========================================================================
-- VERIFIED STEAM ADDRESSES AND V11 FIXED LAYOUT
-- ========================================================================

local SORA_POINTER = 0x2537E48
local POINTER_BANK_TABLE = 0x2EE3980
local POINTER_BANK_COUNT = 64

local CURRENT_ANIMATION_OFFSET = 0x164
local RESOLVED_INDEX_OFFSET = 0x168
local ANIMATION_TIME_OFFSET = 0x16C
local ACTIVE_POINTER_ARRAY_OFFSET = 0x1D4
local OBJECT_FLAGS_OFFSET = 0x00
local POST_HIT_PROTECTION_BIT = 0x80

local ID_C8 = 0xC8
local ID_C9 = 0xC9
local ID_CA = 0xCA
local ID_CB = 0xCB
local ID_CC = 0xCC
local ID_CD = 0xCD
local ID_CE = 0xCE
local ID_D0 = 0xD0
local ID_D4 = 0xD4
local ID_DC = 0xDC

local SLOT_C8 = 0x0062
local SLOT_C9 = 0x0063
local SLOT_CA = 0x0064
local SLOT_CB = 0x0065
local SLOT_CC = 0x0066
local SLOT_CD = 0x0067
local SLOT_CE = 0x0068
local SLOT_D0 = 0x006A
local SLOT_D4 = 0x006E
local SLOT_RAGNAROK_CONTAINER = 0x006F
local SLOT_RIPPLE_GUARD_CONTAINER = 0x0071
local SLOT_ZANT_ROLL_CONTAINER = 0x0074
local SLOT_DC = 0x0075
local SLOT_CC_CONTAINER = 0x0003

-- Physical-record offsets relative to the canonical, never-patched slot 0x65.
-- These are the original archive offsets: v11 does not resize or move records.
local SLOT_DELTA_FROM_65 = {
    [SLOT_CC_CONTAINER] = -0x1BFAB0,
    [SLOT_C8] = -0x13FA0,
    [SLOT_C9] = -0xE860,
    [SLOT_CA] = -0x7E90,
    [SLOT_CB] = 0x0000,
    [SLOT_CC] = 0x5D80,
    [SLOT_CD] = 0xAD00,
    [SLOT_CE] = 0x11BD0,
    [SLOT_D0] = 0x1C5C0,
    [SLOT_D4] = 0x39C60,
    [SLOT_RAGNAROK_CONTAINER] = 0x3F500,
    [SLOT_RIPPLE_GUARD_CONTAINER] = 0x4F5E0,
    [SLOT_ZANT_ROLL_CONTAINER] = 0x62900,
    [SLOT_DC] = 0x6AFD0,
}

local EXPECTED_FRAMES = {
    [SLOT_CC_CONTAINER] = 56,
    [SLOT_C8] = 42,
    [SLOT_C9] = 42,
    [SLOT_CB] = 64,
    [SLOT_CC] = 40,
    [SLOT_CD] = 56,
    [SLOT_CE] = 56,
    [SLOT_D0] = 76,
    [SLOT_D4] = 54,
    [SLOT_RAGNAROK_CONTAINER] = 80,
    [SLOT_RIPPLE_GUARD_CONTAINER] = 100,
    [SLOT_ZANT_ROLL_CONTAINER] = 100,
    [SLOT_DC] = 38,
}

local PERMANENT_ROUTES = {
    { slot = SLOT_CC, replacementSlot = SLOT_CC_CONTAINER, name = "CC Aerial Sweep" },
    { slot = SLOT_CE, replacementSlot = SLOT_RAGNAROK_CONTAINER, name = "CE Ragnarok F7" },
    { slot = SLOT_D4, replacementSlot = SLOT_RIPPLE_GUARD_CONTAINER, name = "D4 Guard/Ripple" },
    { slot = SLOT_DC, replacementSlot = SLOT_ZANT_ROLL_CONTAINER, name = "DC Roll/Zantetsuken" },
}

local ENTRIES = {
    {
        name = "C8 ground attack 1",
        id = ID_C8,
        slot = SLOT_C8,
        firstVisual = "Raid throw",
        secondVisual = "Raid catch",
        replacementSlot = SLOT_CB,
        patchSlots = { SLOT_C9 },
        catches = {
            { id = ID_C9, slot = SLOT_C9 },
        },
    },
    {
        name = "C9 ground attack 2",
        id = ID_C9,
        slot = SLOT_C9,
        firstVisual = "Raid throw",
        secondVisual = "Raid catch",
        replacementSlot = SLOT_CB,
        patchSlots = {},
        catches = {
            { id = ID_CB, slot = SLOT_CB },
        },
    },
    {
        name = "D0 Sliding Dash",
        id = ID_D0,
        slot = SLOT_D0,
        firstVisual = "Judgement Raid",
        secondVisual = "Raid catch",
        replacementSlot = SLOT_CB,
        -- Sliding Dash's native combo position can select a different ground
        -- follow-up. Route every possible ground continuation to the catch.
        patchSlots = { SLOT_C8, SLOT_C9, SLOT_CA },
        catches = {
            { id = ID_C8, slot = SLOT_C8 },
            { id = ID_C9, slot = SLOT_C9 },
            { id = ID_CA, slot = SLOT_CA },
            { id = ID_CB, slot = SLOT_CB },
        },
    },
    {
        name = "CC air attack 1",
        id = ID_CC,
        slot = SLOT_CC,
        firstVisual = "Aerial Sweep",
        secondVisual = "Ragnarok F7",
        replacementSlot = SLOT_RAGNAROK_CONTAINER,
        patchSlots = { SLOT_CD },
        catches = {
            { id = ID_CD, slot = SLOT_CD },
        },
    },
    {
        name = "CD air attack 2",
        id = ID_CD,
        slot = SLOT_CD,
        firstVisual = "Aerial Sweep",
        secondVisual = "Ragnarok F7",
        replacementSlot = SLOT_RAGNAROK_CONTAINER,
        -- The diagnostic proved that native CD advances to CE. CE is routed
        -- permanently so the second press cannot miss the F7 container.
        patchSlots = {},
        catches = {
            { id = ID_CE, slot = SLOT_CE },
        },
    },
}

-- ========================================================================
-- RUNTIME STATE
-- ========================================================================

local enabled = false
local disabledReason = nil
local previousSora = 0
local phase = "waiting"
local activeEntry = nil
local activePointerArray = 0
local sequenceNumber = 0
local appliedPatches = {}
local permanentPointerArray = 0
local lastRouteError = nil
local routesReadyAnnounced = false

-- Full-animation defense protection state. The write is intentionally kept
-- independent from motion routing so a route reset cannot widen its scope.
local defenseActive = false
local defenseSora = 0
local defenseAnimation = 0
local defenseName = ""
local defenseLastFrame = -1
local defenseOwnedBit = false
local defenseTimedOut = false

local function log(message)
    ConsolePrint("[SoraComboVisualsV13] " .. message)
end

local function detail(message)
    if LOG_DETAILS then
        log(message)
    end
end

local function hasPostHitProtectionBit(value)
    return math.floor(value / POST_HIT_PROTECTION_BIT) % 2 == 1
end

local function addPostHitProtectionBit(sora)
    local address = sora + OBJECT_FLAGS_OFFSET
    local value = ReadByte(address, true)
    if not hasPostHitProtectionBit(value) then
        local changed = value + POST_HIT_PROTECTION_BIT
        WriteByte(address, changed, true)
        return true, value, changed
    end
    return false, value, value
end

local function removePostHitProtectionBit(sora)
    local address = sora + OBJECT_FLAGS_OFFSET
    local value = ReadByte(address, true)
    if hasPostHitProtectionBit(value) then
        local changed = value - POST_HIT_PROTECTION_BIT
        WriteByte(address, changed, true)
        return true, value, changed
    end
    return false, value, value
end

local function clearDefenseState()
    defenseActive = false
    defenseSora = 0
    defenseAnimation = 0
    defenseName = ""
    defenseLastFrame = -1
    defenseOwnedBit = false
    defenseTimedOut = false
end

local function defenseTarget(animation, slot)
    if animation == ID_D4 and slot == SLOT_D4 then
        return true, "D4 Guard/Ripple"
    end
    if animation == ID_DC and slot == SLOT_DC then
        return true, "DC Dodge Roll/Zantetsuken"
    end
    return false, ""
end

local function beginDefenseProtection(sora, animation, name, animationFrame)
    defenseActive = true
    defenseSora = sora
    defenseAnimation = animation
    defenseName = name
    defenseLastFrame = animationFrame
    defenseTimedOut = false

    local wrote, before, after = addPostHitProtectionBit(sora)
    defenseOwnedBit = wrote
    detail(string.format(
        "DEFENSE START: %s frame=%.1f flags=0x%02X->0x%02X owned=%s",
        name,
        animationFrame,
        before,
        after,
        tostring(defenseOwnedBit)
    ))
end

local function defenseInvulnerabilityStartsAt(animation)
    if animation == ID_D4 then
        return GUARD_INVULNERABILITY_START_FRAME
    end
    return DODGE_INVULNERABILITY_START_FRAME
end

local function applyDefenseWindow(sora, animation, animationFrame)
    local startFrame = defenseInvulnerabilityStartsAt(animation)
    if animationFrame < startFrame then
        -- This module owns the defense bit once the replacement starts, so it
        -- may safely remove its own full-duration protection during startup.
        if defenseOwnedBit then
            removePostHitProtectionBit(sora)
        end
        return
    end

    local wrote = addPostHitProtectionBit(sora)
    if wrote then
        defenseOwnedBit = true
    end
end

local function finishDefenseProtection(sora, nextAnimation, reason)
    local oldName = defenseName
    local oldFrame = defenseLastFrame
    local removed = false
    local before = 0
    local after = 0

    -- Damage IDs 0x48..0x4D establish the game's own post-hit protection.
    -- Never clear 0x80 after such a transition. For ordinary locomotion,
    -- clear only when v13 originally added the bit. Other actions are left to
    -- their own runtime controller; the game normally changes their flags.
    local receivedDamage = nextAnimation >= 0x48 and nextAnimation <= 0x4D
    local ordinaryExit = nextAnimation == 0x00
        or nextAnimation == 0x01
        or nextAnimation == 0x02

    if sora ~= nil and sora ~= 0 and sora == defenseSora then
        if defenseOwnedBit and ordinaryExit and not receivedDamage then
            removed, before, after = removePostHitProtectionBit(sora)
        else
            before = ReadByte(sora + OBJECT_FLAGS_OFFSET, true)
            after = before
        end
    end

    detail(string.format(
        "DEFENSE END: %s last_frame=%.1f next=0x%02X reason=%s "
            .. "flags=0x%02X->0x%02X cleared=%s",
        oldName,
        oldFrame,
        nextAnimation,
        reason,
        before,
        after,
        tostring(removed)
    ))

    if receivedDamage then
        log(string.format(
            "DEFENSE FAILURE: %s entered damage ID 0x%02X after frame %.1f.",
            oldName,
            nextAnimation,
            oldFrame
        ))
    end

    clearDefenseState()
end

local function updateDefenseProtection(sora, animation, slot, animationFrame)
    if not ENABLE_FULL_DEFENSE_INVULNERABILITY then
        if defenseActive then
            finishDefenseProtection(sora, animation, "setting disabled")
        end
        return
    end

    if defenseActive and sora ~= defenseSora then
        detail("DEFENSE RESET: Sora pointer changed; old memory was not touched.")
        clearDefenseState()
    end

    local target, name = defenseTarget(animation, slot)
    if not defenseActive then
        if target and animationFrame <= MAX_DEFENSE_PROTECTION_FRAME then
            beginDefenseProtection(sora, animation, name, animationFrame)
            applyDefenseWindow(sora, animation, animationFrame)
        end
        return
    end

    if not target or animation ~= defenseAnimation then
        finishDefenseProtection(sora, animation, "animation exited")
        return
    end

    defenseLastFrame = animationFrame
    if animationFrame > MAX_DEFENSE_PROTECTION_FRAME then
        if not defenseTimedOut then
            if defenseOwnedBit then
                removePostHitProtectionBit(sora)
            end
            defenseTimedOut = true
            log(string.format(
                "DEFENSE FAILSAFE: %s exceeded frame %d; owned bit removed.",
                defenseName,
                MAX_DEFENSE_PROTECTION_FRAME
            ))
        end
        return
    end

    applyDefenseWindow(sora, animation, animationFrame)
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

local function compressedBankIndex(encoded)
    local value = unsigned32(encoded)
    if value < 0x80000000 then
        return -1
    end
    return math.floor((value - 0x80000000) / 0x2000000)
end

local function encodeActualPointer(actual, preferredBank)
    if actual == nil or actual <= 0 then
        return 0
    end

    local function tryBank(bankIndex)
        if bankIndex < 0 or bankIndex >= POINTER_BANK_COUNT then
            return 0
        end
        local bankBase = ReadLong(POINTER_BANK_TABLE + bankIndex * 8)
        if bankBase == nil or bankBase == 0 then
            return 0
        end
        local offset = actual - bankBase
        if offset < 0 or offset >= 0x2000000 then
            return 0
        end
        return 0x80000000 + bankIndex * 0x2000000 + offset
    end

    if preferredBank ~= nil and preferredBank >= 0 then
        local preferred = tryBank(preferredBank)
        if preferred ~= 0 then
            return preferred
        end
    end

    local bankIndex = 0
    while bankIndex < POINTER_BANK_COUNT do
        if bankIndex ~= preferredBank then
            local candidate = tryBank(bankIndex)
            if candidate ~= 0 then
                return candidate
            end
        end
        bankIndex = bankIndex + 1
    end
    return 0
end

local function addMotionOffset(encoded, delta)
    local value = unsigned32(encoded)
    if value == 0 then
        return 0
    end

    local actual = resolveCompressedPointer(value)
    if actual == 0 then
        return 0
    end
    local targetActual = actual + delta
    if targetActual <= 0 then
        return 0
    end

    if value < 0x80000000 and targetActual < 0x80000000 then
        return targetActual
    end

    -- A physical MSET can straddle two 0x02000000 resource windows. v12
    -- changed only the low bank offset and deferred forever when a negative
    -- record delta crossed that boundary. Resolve to the physical address,
    -- then find whichever active pointer bank owns the target address.
    return encodeActualPointer(targetActual, compressedBankIndex(value))
end

local function motionPointersEqual(first, second)
    local a = unsigned32(first)
    local b = unsigned32(second)
    if a == b then
        return true
    end
    if a == 0 or b == 0 then
        return false
    end
    local actualA = resolveCompressedPointer(a)
    local actualB = resolveCompressedPointer(b)
    return actualA ~= 0 and actualA == actualB
end

local function readResolvedIndex(sora)
    return unsigned32(ReadInt(sora + RESOLVED_INDEX_OFFSET, true)) % 0x10000
end

local function getActivePointerArray(sora)
    local encoded = unsigned32(ReadInt(
        sora + ACTIVE_POINTER_ARRAY_OFFSET,
        true
    ))
    return resolveCompressedPointer(encoded), encoded
end

local function readMotionPointer(pointerArray, slot)
    if pointerArray == nil or pointerArray == 0 then
        return 0
    end
    return unsigned32(ReadInt(pointerArray + slot * 4, true))
end

local function writeMotionPointer(pointerArray, slot, encodedPointer)
    WriteInt(pointerArray + slot * 4, unsigned32(encodedPointer), true)
end

local function expectedPointersFromCatch(pointerArray)
    local canonical65 = readMotionPointer(pointerArray, SLOT_CB)
    if canonical65 == 0 then
        return nil, "canonical slot 0x65 pointer was zero"
    end

    local expected = {}
    for slot, delta in pairs(SLOT_DELTA_FROM_65) do
        local pointer = addMotionOffset(canonical65, delta)
        if pointer == 0 then
            return nil, string.format(
                "slot 0x%02X physical address could not be encoded by an active pointer bank",
                slot
            )
        end
        expected[slot] = pointer
    end
    return expected, nil
end

local function validateFrameCount(encodedPointer, expectedFrames)
    local actual = resolveCompressedPointer(encodedPointer)
    if actual == 0 then
        return false, "motion pointer could not be resolved"
    end
    local frames = unsigned32(ReadInt(actual + 4, true))
    if frames ~= expectedFrames then
        return false, string.format(
            "expected %d frames but found %d",
            expectedFrames,
            frames
        )
    end
    return true, nil
end

local function permanentReplacementFor(slot, expected)
    for _, route in ipairs(PERMANENT_ROUTES) do
        if route.slot == slot then
            return expected[route.replacementSlot]
        end
    end
    return nil
end

local function validateV11Signature(expected)
    local ragnarok = resolveCompressedPointer(
        expected[SLOT_RAGNAROK_CONTAINER]
    )
    local rippleGuard = resolveCompressedPointer(
        expected[SLOT_RIPPLE_GUARD_CONTAINER]
    )
    local zantRoll = resolveCompressedPointer(
        expected[SLOT_ZANT_ROLL_CONTAINER]
    )
    if ragnarok == 0 or rippleGuard == 0 or zantRoll == 0 then
        return false, "v11 signature pointers could not be resolved"
    end

    -- v11 keeps F7's own empty trigger terminator rather than CE's tail.
    if unsigned32(ReadInt(ragnarok + 0x9CA0, true)) ~= 0xFFFFFFFF then
        return false, "slot 0x6F does not contain the v11 F7 trigger"
    end

    -- v11's fixed-size Ripple/Guard tail begins 7,5,4,4,6. This differs
    -- from v10 and prevents the controller from silently accepting old data.
    local rippleTrigger = rippleGuard + 0x7380
    local rippleKeys = { 0x70000, 0x50000, 0x40000, 0x40001, 0x60000 }
    for index, key in ipairs(rippleKeys) do
        local found = unsigned32(ReadInt(
            rippleTrigger + (index - 1) * 12,
            true
        ))
        if found ~= key then
            return false, string.format(
                "slot 0x71 v11 trigger signature failed at group %d",
                index
            )
        end
    end

    -- The first Dodge control frame is scaled from 30/38 to 78.947/100.
    local scaledRollFrame = ReadFloat(zantRoll + 0x8510 + 0x34, true)
    if scaledRollFrame == nil
        or scaledRollFrame < 78.0
        or scaledRollFrame > 80.0
    then
        return false, "slot 0x74 does not contain the scaled v11 Dodge tail"
    end
    return true, nil
end

local function inspectV11Layout(sora, allowTemporaryRoutes, allowPermanentRoutes)
    local pointerArray, encodedArray = getActivePointerArray(sora)
    if pointerArray == 0 then
        return nil, "active motion-pointer array could not be resolved"
    end

    local expected, expectedError = expectedPointersFromCatch(pointerArray)
    if expected == nil then
        return nil, expectedError
    end

    local pointer65 = expected[SLOT_CB]
    local pointer6F = expected[SLOT_RAGNAROK_CONTAINER]
    for slot, expectedPointer in pairs(expected) do
        local current = readMotionPointer(pointerArray, slot)
        local permanentPointer = permanentReplacementFor(slot, expected)
        local permanentlyValid = allowPermanentRoutes
            and permanentPointer ~= nil
            and motionPointersEqual(current, permanentPointer)
        local temporarilyValid = allowTemporaryRoutes
            and ((slot == SLOT_C8 or slot == SLOT_C9 or slot == SLOT_CA)
                and motionPointersEqual(current, pointer65)
                or ((slot == SLOT_CD or slot == SLOT_CE)
                    and motionPointersEqual(current, pointer6F)))

        if not motionPointersEqual(current, expectedPointer)
            and not permanentlyValid
            and not temporarilyValid
        then
            return nil, string.format(
                "active MSET does not match v11 at slot 0x%02X "
                    .. "(found 0x%08X expected 0x%08X)",
                slot,
                current,
                expectedPointer
            )
        end
    end

    for slot, expectedFrames in pairs(EXPECTED_FRAMES) do
        local ok, frameError = validateFrameCount(expected[slot], expectedFrames)
        if not ok then
            return nil, string.format(
                "slot 0x%02X frame validation failed: %s",
                slot,
                frameError
            )
        end
    end

    local signatureValid, signatureError = validateV11Signature(expected)
    if not signatureValid then
        return nil, signatureError
    end

    return {
        pointerArray = pointerArray,
        encodedArray = encodedArray,
        expected = expected,
    }, nil
end

local function restorePatches(reason)
    local success = true
    local failure = nil

    for index = #appliedPatches, 1, -1 do
        local patch = appliedPatches[index]
        local current = readMotionPointer(activePointerArray, patch.slot)
        if motionPointersEqual(current, patch.replacement) then
            writeMotionPointer(activePointerArray, patch.slot, patch.original)
            current = readMotionPointer(activePointerArray, patch.slot)
        end
        if not motionPointersEqual(current, patch.original) then
            success = false
            failure = string.format(
                "slot 0x%02X restore conflict: found 0x%08X",
                patch.slot,
                current
            )
            break
        end
    end

    if success and #appliedPatches > 0 then
        detail("Restored temporary motion routes (" .. tostring(reason) .. ").")
    end
    appliedPatches = {}
    return success, failure
end

local function clearSequence()
    phase = "waiting"
    activeEntry = nil
    activePointerArray = 0
    appliedPatches = {}
end

local function resetSequence(reason)
    local restored, restoreError = restorePatches(reason)
    clearSequence()
    if not restored then
        enabled = false
        disabledReason = restoreError
        log("DISABLED: " .. restoreError)
        return false
    end
    return true
end

local function cleanAndApplyRoutes(sora)
    local layout, layoutError = inspectV11Layout(sora, true, true)
    if layout == nil then
        return false, layoutError
    end

    local pointer65 = layout.expected[SLOT_CB]
    local pointer6F = layout.expected[SLOT_RAGNAROK_CONTAINER]
    local cleaned = false

    for _, slot in ipairs({ SLOT_C8, SLOT_C9, SLOT_CA }) do
        local current = readMotionPointer(layout.pointerArray, slot)
        if motionPointersEqual(current, pointer65)
            and not motionPointersEqual(current, layout.expected[slot])
        then
            writeMotionPointer(layout.pointerArray, slot, layout.expected[slot])
            cleaned = true
        end
    end

    -- CE is a permanent v11 route; only CD can be a stale temporary route.
    for _, slot in ipairs({ SLOT_CD }) do
        local current = readMotionPointer(layout.pointerArray, slot)
        if motionPointersEqual(current, pointer6F)
            and not motionPointersEqual(current, layout.expected[slot])
        then
            writeMotionPointer(layout.pointerArray, slot, layout.expected[slot])
            cleaned = true
        end
    end

    for _, route in ipairs(PERMANENT_ROUTES) do
        local replacement = layout.expected[route.replacementSlot]
        local current = readMotionPointer(layout.pointerArray, route.slot)
        if not motionPointersEqual(current, replacement) then
            if not motionPointersEqual(current, layout.expected[route.slot]) then
                return false, string.format(
                    "slot 0x%02X changed before permanent routing (0x%08X)",
                    route.slot,
                    current
                )
            end
            writeMotionPointer(layout.pointerArray, route.slot, replacement)
            if not motionPointersEqual(
                readMotionPointer(layout.pointerArray, route.slot),
                replacement
            ) then
                return false, string.format(
                    "slot 0x%02X permanent route failed readback",
                    route.slot
                )
            end
        end
    end

    local cleanLayout, cleanError = inspectV11Layout(sora, false, true)
    if cleanLayout == nil then
        return false, cleanError
    end
    permanentPointerArray = cleanLayout.pointerArray
    if cleaned then
        detail("Recovered and restored stale routes from a prior script reload.")
    end
    if not routesReadyAnnounced then
        routesReadyAnnounced = true
        log("READY: v13 bank-safe motion routing is active.")
    end
    return true, nil
end

local function verifyPermanentRoutes(layout)
    for _, route in ipairs(PERMANENT_ROUTES) do
        local expected = layout.expected[route.replacementSlot]
        local current = readMotionPointer(layout.pointerArray, route.slot)
        if not motionPointersEqual(current, expected) then
            return false, string.format(
                "permanent route 0x%02X changed to 0x%08X",
                route.slot,
                current
            )
        end
    end
    return true, nil
end

local function applyEntryPatches(entry, layout)
    local replacement = layout.expected[entry.replacementSlot]
    for _, slot in ipairs(entry.patchSlots) do
        local current = readMotionPointer(layout.pointerArray, slot)
        local expected = layout.expected[slot]
        if not motionPointersEqual(current, expected) then
            return false, string.format(
                "slot 0x%02X changed before routing (0x%08X)",
                slot,
                current
            )
        end

        writeMotionPointer(layout.pointerArray, slot, replacement)
        local readback = readMotionPointer(layout.pointerArray, slot)
        if not motionPointersEqual(readback, replacement) then
            return false, string.format(
                "slot 0x%02X route failed readback (0x%08X)",
                slot,
                readback
            )
        end

        appliedPatches[#appliedPatches + 1] = {
            slot = slot,
            original = expected,
            replacement = replacement,
        }
    end
    return true, nil
end

local function beginEntry(entry, sora, animationFrame)
    local layout, layoutError = inspectV11Layout(sora, false, true)
    if layout == nil then
        enabled = false
        disabledReason = layoutError
        log("DISABLED: " .. layoutError)
        return false
    end

    local permanentValid, permanentError = verifyPermanentRoutes(layout)
    if not permanentValid then
        enabled = false
        disabledReason = permanentError
        log("DISABLED: " .. permanentError)
        return false
    end

    phase = "first"
    activeEntry = entry
    activePointerArray = layout.pointerArray
    appliedPatches = {}
    sequenceNumber = sequenceNumber + 1

    local patched, patchError = applyEntryPatches(entry, layout)
    if not patched then
        local previousNumber = sequenceNumber
        resetSequence("route setup failed")
        enabled = false
        disabledReason = patchError
        log(string.format(
            "SEQUENCE #%d DISABLED during route setup: %s",
            previousNumber,
            patchError
        ))
        return false
    end

    log(string.format(
        "SEQUENCE #%d START: %s uses %s at frame %.1f; "
            .. "a real second Attack press selects %s.",
        sequenceNumber,
        entry.name,
        entry.firstVisual,
        animationFrame,
        entry.secondVisual
    ))
    return true
end

local function catchHasStarted(entry, animation, slot)
    for _, candidate in ipairs(entry.catches) do
        if animation == candidate.id and slot == candidate.slot then
            return true
        end
    end
    return false
end

local function verifyActivePatches()
    for _, patch in ipairs(appliedPatches) do
        local current = readMotionPointer(activePointerArray, patch.slot)
        if not motionPointersEqual(current, patch.replacement) then
            return false, string.format(
                "slot 0x%02X route changed to 0x%08X",
                patch.slot,
                current
            )
        end
    end
    return true, nil
end

local function findEntry(animation, slot)
    for _, entry in ipairs(ENTRIES) do
        if animation == entry.id and slot == entry.slot then
            return entry
        end
    end
    return nil
end

local function frameLogic()
    local sora = ReadLong(SORA_POINTER)
    if sora == nil or sora == 0 then
        if defenseActive then
            detail("DEFENSE RESET: Sora pointer became unavailable.")
            clearDefenseState()
        end
        if previousSora ~= 0 then
            resetSequence("Sora pointer unavailable")
        end
        previousSora = 0
        permanentPointerArray = 0
        routesReadyAnnounced = false
        return
    end

    if previousSora ~= 0 and sora ~= previousSora then
        if defenseActive then
            detail("DEFENSE RESET: Sora pointer changed.")
            clearDefenseState()
        end
        if not resetSequence("Sora pointer changed") then
            return
        end
        permanentPointerArray = 0
        routesReadyAnnounced = false
    end
    previousSora = sora

    local animation = ReadByte(sora + CURRENT_ANIMATION_OFFSET, true)
    local slot = readResolvedIndex(sora)
    local animationFrame = ReadFloat(sora + ANIMATION_TIME_OFFSET, true)

    updateDefenseProtection(sora, animation, slot, animationFrame)

    if phase == "waiting" then
        local currentArray = getActivePointerArray(sora)
        if currentArray ~= permanentPointerArray then
            local routed, routeError = cleanAndApplyRoutes(sora)
            if not routed then
                if routeError ~= lastRouteError then
                    detail("Main v11 routing deferred: " .. routeError)
                    lastRouteError = routeError
                end
                return
            end
            lastRouteError = nil
        end

        local entry = findEntry(animation, slot)
        if entry ~= nil then
            beginEntry(entry, sora, animationFrame)
        end
        return
    end

    local currentArray = getActivePointerArray(sora)
    if currentArray ~= activePointerArray then
        local number = sequenceNumber
        resetSequence("active pointer array changed")
        detail(string.format(
            "SEQUENCE #%d aborted because the active motion bank changed.",
            number
        ))
        return
    end

    local patchesValid, patchError = verifyActivePatches()
    if not patchesValid then
        enabled = false
        disabledReason = patchError
        log("DISABLED: " .. patchError)
        resetSequence("pointer route conflict")
        return
    end

    if phase == "first" then
        if catchHasStarted(activeEntry, animation, slot) then
            phase = "second"
            log(string.format(
                "SEQUENCE #%d SECOND PRESS ACCEPTED: %s -> %s at frame %.1f.",
                sequenceNumber,
                activeEntry.firstVisual,
                activeEntry.secondVisual,
                animationFrame
            ))
            return
        end

        if animation ~= activeEntry.id or slot ~= activeEntry.slot then
            local number = sequenceNumber
            local name = activeEntry.name
            local restored = resetSequence("first animation exited without follow-up")
            if restored then
                detail(string.format(
                    "SEQUENCE #%d COMPLETE WITHOUT SECOND PRESS: %s exited "
                        .. "to ID 0x%02X / slot 0x%04X.",
                    number,
                    name,
                    animation,
                    slot
                ))
            end
        end
        return
    end

    if phase == "second"
        and not catchHasStarted(activeEntry, animation, slot)
    then
        local number = sequenceNumber
        local name = activeEntry.name
        local restored = resetSequence("second animation exited")
        if restored then
            detail(string.format(
                "SEQUENCE #%d COMPLETE: %s returned to normal routing.",
                number,
                name
            ))
        end
    end
end

local function moduleInit()
    SetHertz(60)
    enabled = ENABLE_CONTROLLER
    disabledReason = nil
    permanentPointerArray = 0
    lastRouteError = nil
    routesReadyAnnounced = false
    clearSequence()
    clearDefenseState()

    if not enabled then
        disabledReason = "ENABLE_CONTROLLER is false"
        log("DISABLED by setting.")
        return
    end

    if GUARD_INVULNERABILITY_START_FRAME < 0
        or DODGE_INVULNERABILITY_START_FRAME < 0
        or GUARD_INVULNERABILITY_START_FRAME > MAX_DEFENSE_PROTECTION_FRAME
        or DODGE_INVULNERABILITY_START_FRAME > MAX_DEFENSE_PROTECTION_FRAME
    then
        enabled = false
        disabledReason = "invalid defense startup window"
        log("DISABLED: defense invulnerability start frames must be between 0 and MAX_DEFENSE_PROTECTION_FRAME.")
        return
    end

    local sora = ReadLong(SORA_POINTER)
    if sora ~= nil and sora ~= 0 then
        previousSora = sora
        local routed, routeError = cleanAndApplyRoutes(sora)
        if not routed then
            -- Alternate banks used by limits/summons are legitimate. The
            -- exact v11 layout is checked again when the main bank returns.
            detail("Initial v11 routing deferred: " .. routeError)
            lastRouteError = routeError
        end
    else
        previousSora = 0
    end

    if not routesReadyAnnounced then
        log("WAITING: v13 loaded, but main motion routing is not active yet.")
    end
    log("Required asset is the unchanged v11 EFFECTS_DEFENSE_POC MSET.")
    log("Ground C8/C9: Raid throw, real second press Raid catch.")
    log("Sliding Dash: Judgement Raid, real second press Raid catch.")
    log("Air CC/CD: Aerial Sweep, real second press routes through CE to Ragnarok F7.")
    log("Guard keeps Ripple effect/control events without Ripple's offensive type-4 groups.")
    log(string.format(
        "Guard/Ripple is vulnerable before frame %.1f; Dodge/Zantetsuken before frame %.1f.",
        GUARD_INVULNERABILITY_START_FRAME,
        DODGE_INVULNERABILITY_START_FRAME
    ))
    log("Archive size/directory are unchanged; no remastered folder is used.")
    log("No automatic input or animation-ID/index/time writes are used.")
end

local function moduleFrame()
    if not enabled then
        return
    end

    local ok, frameError = pcall(frameLogic)
    if not ok then
        pcall(resetSequence, "runtime error")
        local sora = ReadLong(SORA_POINTER)
        if defenseActive
            and defenseOwnedBit
            and sora ~= nil
            and sora ~= 0
            and sora == defenseSora
        then
            pcall(removePostHitProtectionBit, sora)
        end
        clearDefenseState()
        enabled = false
        disabledReason = tostring(frameError)
        log("DISABLED after runtime error: " .. disabledReason)
    end
end

    return { name = "SoraComboVisualsV13", init = moduleInit, frame = moduleFrame, enabled = true }
end

local function buildAutoPrime()
    -- ====================================================================
    -- BEGIN EMBEDDED CONTROLLER: RagnarokAutoPrimeV4
    -- ====================================================================
-- Kingdom Hearts Final Mix (Steam)
-- Ragnarok complete automatic prime v4.
--
-- PURPOSE
--   Automatically build the genuine native Ragnarok projectile runtime during
--   the first suitable combat attack of a fresh game process.
--
--   This combines the two independently validated stages:
--     1. the v4 clean-exit carrier launches genuine action 0x25 through the
--        game's own special-command wrapper; and
--     2. at genuine F6/counter 6/timer 35, the validated native-release route
--        runs action 0x25's own task creator for one engine interval.
--
--   The result is the same FULL PRIME READY state previously reached by
--   running v3 and NativeRelease v1 together. Once the genuine prime volley
--   finishes, the reusable v8.9.5 projectile controller can initialize
--   automatically without an F1 reload.
--
-- REQUIRED SETUP
--   1. Enable this file, KH1FM_RagnarokProjectile_VisualRoute_v8_9_5_
--      REUSABLE_PRIMED_V13.lua, and the v13 combo controller.
--   2. Disable v3 CLEAN_EXIT, NativeRelease v1, ReleasePulse, PhaseTrace, and
--      every older Ragnarok prime/projectile POC.
--   3. Start a fresh process and enter a real enemy encounter.
--   4. Jump, then press/release Attack once to provide the proven CC carrier.
--   5. Stop pressing buttons while genuine Ragnarok charges and fires.
--
-- SAFETY BOUNDARIES
--   * One automatic-prime attempt per Lua load.
--   * No generated input and no invented manager/data pointer.
--   * No Sora animation-ID/index/time, counter/timer, effect, task-state,
--     damage, HP, MP, suspension, or MSET writes.
--   * The command carrier temporarily patches one validated CALL, one
--     validated clean-exit jump, and one validated two-byte gate; all three
--     restore immediately after native action registration appears.
--   * The release stage temporarily redirects exactly one validated action
--     registry function pointer for one engine interval and restores it on the
--     next Lua frame before any other work.
--   * Every executable signature, registry pointer, runtime prerequisite, and
--     restoration is checked by readback. Unknown values are never replaced.
--
-- This file supersedes v3 CLEAN_EXIT and NativeRelease v1 when it validates.

-- ========================================================================
-- SETTINGS
-- ========================================================================

local ENABLE_TEST = true
local MAX_ROUTE_CALLBACKS = 8
local MONITOR_TIMEOUT_CALLBACKS = 1800
local STATUS_INTERVAL_CALLBACKS = 300
local RELEASE_AT_TIMER = 35.0
local RELEASE_WINDOW_MIN = 10.0
local RELEASE_WINDOW_MAX = 70.0

-- ========================================================================
-- VERIFIED STEAM EXECUTABLE LAYOUT
-- ========================================================================

local SORA_POINTER = 0x2537E48
local NATIVE_RAGNAROK_SORA_POINTER = 0x2D37280

local ACTION_REGISTRY = 0x2DB3840
local ACTION_ENTRY_SIZE = 0x40
local GENERAL_ATTACK_ACTION_ID = 0x02
local NATIVE_RAGNAROK_ACTION_ID = 0x25
local GENERAL_ACTION_ENTRY =
    ACTION_REGISTRY + GENERAL_ATTACK_ACTION_ID * ACTION_ENTRY_SIZE
local NATIVE_ACTION_ENTRY =
    ACTION_REGISTRY + NATIVE_RAGNAROK_ACTION_ID * ACTION_ENTRY_SIZE

local GENERAL_CALLBACK_18_RVA = 0x002AFC20
local SHARED_CALLBACK_20_RVA = 0x002AF6A0
local GENERAL_CALLBACK_28_RVA = 0x002AFBC0
local GENERAL_CALLBACK_38_RVA = 0x002AFD60

local NATIVE_RAGNAROK_COMMAND_WRAPPER_RVA = 0x0028D428
local NATIVE_RAGNAROK_COMMAND_WRAPPER_SIGNATURE = {
    0xBA, 0x03, 0x00, 0x00, 0x00,
    0xE9, 0xCE, 0x03, 0x00, 0x00,
}

local NATIVE_RAGNAROK_SETUP_RVA = 0x0039FAF0
local NATIVE_RAGNAROK_UPDATE_RVA = 0x0039F7A0
local NATIVE_RAGNAROK_TASK_CREATOR_RVA = 0x0039F330
local NATIVE_RAGNAROK_BATTLE_CALLBACK_RVA = 0x0039FF70
local NATIVE_UPDATE_POINTER_FIELD = NATIVE_ACTION_ENTRY + 0x30

local NATIVE_RAGNAROK_UPDATE_SIGNATURE = {
    0x48, 0x89, 0x5C, 0x24, 0x10, 0x57, 0x48, 0x83,
}
local NATIVE_RAGNAROK_TASK_CREATOR_SIGNATURE = {
    0x48, 0x8B, 0xC4, 0x48, 0x89, 0x58, 0x08, 0x48,
}

-- Special-command runtime built by module+0x28D620..0x28D800.
local SPECIAL_COMMAND_STATE = 0x299C220
local SPECIAL_COMMAND_HEAP = 0x299C228
local SPECIAL_COMMAND_ARCHIVE = 0x299C230
local SPECIAL_COMMAND_CONTEXT = 0x299C238
local SPECIAL_COMMAND_ACTION_TABLE = 0x2D22D30
local RAGNAROK_COMMAND_INDEX = 3
local RAGNAROK_DESCRIPTOR_RELATIVE_OFFSET =
    0x08 + RAGNAROK_COMMAND_INDEX * 4
local RAGNAROK_ACTION_WORD_OFFSET =
    0xF4 + RAGNAROK_COMMAND_INDEX * 2

-- General action 0x02 normally calls module+0x2A5F10 here.
local ACTION_02_UPDATE_CALLSITE_RVA = 0x002A7B97
local ORIGINAL_ACTION_02_CALL = { 0xE8, 0x74, 0xE3, 0xFF, 0xFF }

-- After the call above, action 0x02 normally continues at +0x2A7B9C.
-- V2 proved that this continuation immediately replaces genuine action 0x25.
-- V3 temporarily jumps to this function's own clean epilogue instead.
local POST_COMMAND_CONTINUATION_RVA = 0x002A7B9C
local ORIGINAL_POST_COMMAND_PREFIX = { 0xF7, 0x05, 0x6A, 0x70, 0xAB }
local CLEAN_EXIT_EPILOGUE_RVA = 0x002A7C8F
local CLEAN_EXIT_JUMP = { 0xE9, 0xEE, 0x00, 0x00, 0x00 }
local CLEAN_EXIT_EPILOGUE_SIGNATURE = {
    0x48, 0x8B, 0x5C, 0x24, 0x30,
    0x48, 0x8B, 0x74, 0x24, 0x38,
    0x48, 0x83, 0xC4, 0x20, 0x5F, 0xC3,
}

-- Outer combat dispatcher gate.
local ACTION_UPDATE_GATE_BRANCH_RVA = 0x002A6246
local ORIGINAL_GATE_BRANCH = { 0x74, 0x52 }
local BYPASS_GATE_BRANCH = { 0x90, 0x90 }
local ACTION_UPDATE_OVERRIDE_CALLBACK = 0x2D5EC20

local BATTLE_MANAGER_POINTER = 0x2EFB0E0
local NATIVE_HELPER_POINTER = 0x2EFB0E8
local BATTLE_CALLBACK_POINTER = 0x2D53AA0
local EFFECT_OBJECT_A_POINTER = 0x2F11498
local EFFECT_OBJECT_B_POINTER = 0x2F114A0
local PROJECTILE_TASK_FIRST = 0x2F114B0
local PROJECTILE_TASK_LAST = 0x2F114B8
local PROJECTILE_TASK_HANDLE = 0x2F114C8
local RAGNAROK_PHASE_COUNTER = 0x2F11490
local RAGNAROK_PHASE_TIMER = 0x2F11494
local ENGINE_FRAME_DELTA = 0x233FBDC

local CURRENT_ACTION_ID_OFFSET = 0x70
local CURRENT_ANIMATION_OFFSET = 0x164
local RESOLVED_MOTION_INDEX_OFFSET = 0x168

local RAGNAROK_F6_ANIMATION = 0xF6
local RAGNAROK_F6_SLOT = 0x0020

-- Known v13 attack carriers. D0 is Sliding Dash.
local COMBAT_CARRIER_ANIMATIONS = {
    [0xC8] = true,
    [0xC9] = true,
    [0xCA] = true,
    [0xCB] = true,
    [0xCC] = true,
    [0xCD] = true,
    [0xCE] = true,
    [0xD0] = true,
}

-- ========================================================================
-- STATE
-- ========================================================================

local enabled = false
local waitingForRuntime = false
local runtimeTicks = 0
local moduleBase = 0
local redirectCommandCall = nil
local nativeUpdatePointer = 0
local nativeTaskCreatorPointer = 0
local nativeBattleCallbackPointer = 0

local currentSora = 0
local commandArchive = 0
local commandContext = 0
local commandActionTable = 0
local ragnarokDescriptor = 0
local ragnarokActionCode = 0

local attemptUsed = false
local routeArmed = false
local routeCallbacks = 0
local monitorActive = false
local monitorTicks = 0
local nativeActionSeen = false
local finalReported = false
local releaseRedirectArmed = false
local releaseAttemptUsed = false

-- ========================================================================
-- MEMORY HELPERS
-- ========================================================================

local function log(message)
    ConsolePrint("[RagnarokAutoPrimeV4] " .. message)
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

local function signed32(value)
    local result = unsigned32(value)
    if result >= 2147483648 then
        result = result - 4294967296
    end
    return result
end

local function safeReadInt(address, absolute)
    local ok, value = pcall(ReadInt, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return unsigned32(value)
end

local function safeReadLong(address, absolute)
    local ok, value = pcall(ReadLong, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return value
end

local function safeReadFloat(address, absolute)
    local ok, value = pcall(ReadFloat, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return value
end

local function safeReadByte(address, absolute)
    local ok, value = pcall(ReadByte, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return value
end

local function safeReadArray(address, length, absolute)
    local ok, value = pcall(ReadArray, address, length, absolute)
    if not ok or value == nil then
        return nil
    end
    return value
end

local function arraysEqual(left, right)
    if left == nil or right == nil or #left ~= #right then
        return false
    end
    for index = 1, #left do
        if left[index] ~= right[index] then
            return false
        end
    end
    return true
end

local function pointerText(pointer)
    if pointer == nil or pointer == 0 then
        return "0x0"
    end
    return string.format("0x%X", pointer)
end

local function relativeCallBytes(callsiteRVA, targetRVA)
    local relative = targetRVA - (callsiteRVA + 5)
    if relative < 0 then
        relative = relative + 4294967296
    end
    return {
        0xE8,
        relative % 0x100,
        math.floor(relative / 0x100) % 0x100,
        math.floor(relative / 0x10000) % 0x100,
        math.floor(relative / 0x1000000) % 0x100,
    }
end

local function writeArrayChecked(address, bytes)
    local ok, reason = pcall(WriteArray, address, bytes)
    if not ok then
        return false, tostring(reason)
    end
    local current = safeReadArray(address, #bytes)
    if not arraysEqual(current, bytes) then
        return false, "write did not verify"
    end
    return true, "verified"
end

local function pointerBytes(value)
    local bytes = {}
    local remaining = value
    for index = 1, 8 do
        bytes[index] = remaining % 0x100
        remaining = math.floor(remaining / 0x100)
    end
    return bytes
end

local function writePointerChecked(address, value)
    local ok, reason = pcall(WriteArray, address, pointerBytes(value))
    if not ok then
        return false, tostring(reason)
    end
    local current = safeReadLong(address)
    if current ~= value then
        return false, string.format(
            "pointer write did not verify (found %s expected %s)",
            pointerText(current or 0),
            pointerText(value)
        )
    end
    return true, "verified"
end

local function pointerLooksReadable(pointer, length)
    if pointer == nil
        or pointer < 0x10000
        or pointer >= 0x0000800000000000
    then
        return false
    end
    return safeReadArray(pointer, length or 0x10, true) ~= nil
end

local function nativeRegistrationValid()
    if moduleBase == 0 then
        return false
    end
    return safeReadInt(NATIVE_ACTION_ENTRY) == 0x00000005
        and safeReadLong(NATIVE_ACTION_ENTRY + 0x08)
            == moduleBase + NATIVE_RAGNAROK_SETUP_RVA
        and safeReadLong(NATIVE_UPDATE_POINTER_FIELD)
            == nativeUpdatePointer
end

local function readRagnarokActionWord(tablePointer)
    -- The desired u16 is at +0xFA. Read the aligned dword at +0xF8 and take
    -- its high word so the test does not depend on a ReadShort API.
    local aligned = RAGNAROK_ACTION_WORD_OFFSET - 2
    local value = safeReadInt(tablePointer + aligned, true)
    if value == nil then
        return nil
    end
    return math.floor(value / 0x10000) % 0x10000
end

local function stateText(sora)
    local action = 0
    local animation = 0
    local slot = 0
    if sora ~= nil and sora ~= 0 then
        action = safeReadInt(sora + CURRENT_ACTION_ID_OFFSET, true) or 0
        animation = safeReadByte(
            sora + CURRENT_ANIMATION_OFFSET,
            true
        ) or 0
        slot = (safeReadInt(
            sora + RESOLVED_MOTION_INDEX_OFFSET,
            true
        ) or 0) % 0x10000
    end
    return string.format(
        "action=0x%02X animation=0x%02X slot=0x%04X "
            .. "manager=%s helper=%s task_first=%s task_last=%s handle=0x%X",
        action,
        animation,
        slot,
        pointerText(safeReadLong(BATTLE_MANAGER_POINTER) or 0),
        pointerText(safeReadLong(NATIVE_HELPER_POINTER) or 0),
        pointerText(safeReadLong(PROJECTILE_TASK_FIRST) or 0),
        pointerText(safeReadLong(PROJECTILE_TASK_LAST) or 0),
        safeReadInt(PROJECTILE_TASK_HANDLE) or 0
    )
end

-- ========================================================================
-- RUNTIME VALIDATION
-- ========================================================================

local function validateGeneralRuntime()
    local generalFlags = safeReadInt(GENERAL_ACTION_ENTRY)
    local callback18 = safeReadLong(GENERAL_ACTION_ENTRY + 0x18)
    if generalFlags ~= 0x0000003D
        or callback18 == nil
        or callback18 == 0
    then
        return false, "general action 0x02 is not initialized yet"
    end

    moduleBase = callback18 - GENERAL_CALLBACK_18_RVA
    nativeUpdatePointer = moduleBase + NATIVE_RAGNAROK_UPDATE_RVA
    nativeTaskCreatorPointer =
        moduleBase + NATIVE_RAGNAROK_TASK_CREATOR_RVA
    nativeBattleCallbackPointer =
        moduleBase + NATIVE_RAGNAROK_BATTLE_CALLBACK_RVA
    if moduleBase < 0x100000000
        or moduleBase >= 0x0000800000000000
    then
        return false, "derived executable base is invalid"
    end

    local checks = {
        {
            address = GENERAL_ACTION_ENTRY + 0x20,
            expected = moduleBase + SHARED_CALLBACK_20_RVA,
            label = "general callback +0x20",
        },
        {
            address = GENERAL_ACTION_ENTRY + 0x28,
            expected = moduleBase + GENERAL_CALLBACK_28_RVA,
            label = "general callback +0x28",
        },
        {
            address = GENERAL_ACTION_ENTRY + 0x38,
            expected = moduleBase + GENERAL_CALLBACK_38_RVA,
            label = "general callback +0x38",
        },
    }
    for index = 1, #checks do
        local check = checks[index]
        local actual = safeReadLong(check.address)
        if actual ~= check.expected then
            return false, string.format(
                "%s mismatch: found %s expected %s",
                check.label,
                pointerText(actual or 0),
                pointerText(check.expected)
            )
        end
    end

    if safeReadLong(GENERAL_ACTION_ENTRY + 0x08) ~= 0
        or safeReadLong(GENERAL_ACTION_ENTRY + 0x10) ~= 0
    then
        return false, "general action setup/cleanup signature mismatch"
    end

    local wrapper = safeReadArray(
        NATIVE_RAGNAROK_COMMAND_WRAPPER_RVA,
        #NATIVE_RAGNAROK_COMMAND_WRAPPER_SIGNATURE
    )
    if not arraysEqual(
        wrapper,
        NATIVE_RAGNAROK_COMMAND_WRAPPER_SIGNATURE
    ) then
        return false, "native Ragnarok command-wrapper signature mismatch"
    end

    local updateSignature = safeReadArray(
        NATIVE_RAGNAROK_UPDATE_RVA,
        #NATIVE_RAGNAROK_UPDATE_SIGNATURE
    )
    local creatorSignature = safeReadArray(
        NATIVE_RAGNAROK_TASK_CREATOR_RVA,
        #NATIVE_RAGNAROK_TASK_CREATOR_SIGNATURE
    )
    if not arraysEqual(
        updateSignature,
        NATIVE_RAGNAROK_UPDATE_SIGNATURE
    ) or not arraysEqual(
        creatorSignature,
        NATIVE_RAGNAROK_TASK_CREATOR_SIGNATURE
    ) then
        return false, "native update/task-creator signature mismatch"
    end

    local nativeCallback = safeReadLong(NATIVE_UPDATE_POINTER_FIELD)
    if nativeCallback == nativeTaskCreatorPointer then
        local restored, reason = writePointerChecked(
            NATIVE_UPDATE_POINTER_FIELD,
            nativeUpdatePointer
        )
        if not restored then
            return false,
                "stale one-interval release route could not restore: "
                    .. reason
        end
        log("Recovered a stale v4 native-release redirect after F1.")
        nativeCallback = safeReadLong(NATIVE_UPDATE_POINTER_FIELD)
    end
    if nativeCallback ~= 0 and nativeCallback ~= nativeUpdatePointer then
        return false, string.format(
            "native +0x30 callback mismatch: found %s expected 0 or %s",
            pointerText(nativeCallback or 0),
            pointerText(nativeUpdatePointer)
        )
    end

    local cleanEpilogue = safeReadArray(
        CLEAN_EXIT_EPILOGUE_RVA,
        #CLEAN_EXIT_EPILOGUE_SIGNATURE
    )
    if not arraysEqual(cleanEpilogue, CLEAN_EXIT_EPILOGUE_SIGNATURE) then
        return false, "general-action clean-epilogue signature mismatch"
    end

    redirectCommandCall = relativeCallBytes(
        ACTION_02_UPDATE_CALLSITE_RVA,
        NATIVE_RAGNAROK_COMMAND_WRAPPER_RVA
    )

    local callsite = safeReadArray(ACTION_02_UPDATE_CALLSITE_RVA, 5)
    if arraysEqual(callsite, redirectCommandCall) then
        local restored, reason = writeArrayChecked(
            ACTION_02_UPDATE_CALLSITE_RVA,
            ORIGINAL_ACTION_02_CALL
        )
        if not restored then
            return false, "stale native-command route could not be restored: "
                .. reason
        end
        log("Recovered a stale v4 CALL route after an F1 reload.")
        callsite = safeReadArray(ACTION_02_UPDATE_CALLSITE_RVA, 5)
    end
    if not arraysEqual(callsite, ORIGINAL_ACTION_02_CALL) then
        return false, "general action callsite signature mismatch"
    end

    local continuation = safeReadArray(POST_COMMAND_CONTINUATION_RVA, 5)
    if arraysEqual(continuation, CLEAN_EXIT_JUMP) then
        local restored, reason = writeArrayChecked(
            POST_COMMAND_CONTINUATION_RVA,
            ORIGINAL_POST_COMMAND_PREFIX
        )
        if not restored then
            return false, "stale clean-exit route could not be restored: "
                .. reason
        end
        log("Recovered a stale v4 clean-exit route after an F1 reload.")
        continuation = safeReadArray(POST_COMMAND_CONTINUATION_RVA, 5)
    end
    if not arraysEqual(continuation, ORIGINAL_POST_COMMAND_PREFIX) then
        return false, "post-command continuation signature mismatch"
    end

    local gate = safeReadArray(ACTION_UPDATE_GATE_BRANCH_RVA, 2)
    if arraysEqual(gate, BYPASS_GATE_BRANCH) then
        local restored, reason = writeArrayChecked(
            ACTION_UPDATE_GATE_BRANCH_RVA,
            ORIGINAL_GATE_BRANCH
        )
        if not restored then
            return false, "stale action gate could not be restored: "
                .. reason
        end
        log("Recovered a stale v4 action-gate bypass after F1.")
        gate = safeReadArray(ACTION_UPDATE_GATE_BRANCH_RVA, 2)
    end
    if not arraysEqual(gate, ORIGINAL_GATE_BRANCH) then
        return false, "action-update gate signature mismatch"
    end

    local delta = safeReadFloat(ENGINE_FRAME_DELTA)
    if delta == nil or delta < 0.01 or delta > 5.0 then
        return false, string.format(
            "engine timing is not active yet (delta=%.4f)",
            delta or -1.0
        )
    end

    local sora = safeReadLong(SORA_POINTER)
    local nativeSora = safeReadLong(NATIVE_RAGNAROK_SORA_POINTER)
    if sora == nil or sora == 0 or nativeSora ~= sora then
        return false, "Sora/native-Sora pointers are not ready or do not match"
    end
    currentSora = sora

    return true, "general runtime and native wrapper are valid"
end

local function validateSpecialCommandRuntime()
    local state = safeReadInt(SPECIAL_COMMAND_STATE)
    local heap = safeReadLong(SPECIAL_COMMAND_HEAP)
    local archive = safeReadLong(SPECIAL_COMMAND_ARCHIVE)
    local context = safeReadLong(SPECIAL_COMMAND_CONTEXT)
    local actionTable = safeReadLong(SPECIAL_COMMAND_ACTION_TABLE)

    if state == nil or state < 2 then
        return false, string.format(
            "special-command state is not ready (state=%d)",
            state or -1
        )
    end
    if not pointerLooksReadable(heap, 0x10) then
        return false, "special-command heap is unavailable"
    end
    if not pointerLooksReadable(archive, 0x20) then
        return false, "special-command archive is unavailable"
    end
    if not pointerLooksReadable(context, 0x10) then
        return false, "special-command context is unavailable"
    end
    if not pointerLooksReadable(actionTable, 0x100) then
        return false, "special-command action table is unavailable"
    end

    local rawRelative = safeReadInt(
        archive + RAGNAROK_DESCRIPTOR_RELATIVE_OFFSET,
        true
    )
    if rawRelative == nil then
        return false, "Ragnarok descriptor offset could not be read"
    end
    local descriptor = archive + signed32(rawRelative)
    if not pointerLooksReadable(descriptor, 0x20) then
        return false, string.format(
            "derived Ragnarok descriptor is unreadable (%s)",
            pointerText(descriptor)
        )
    end

    local actionCode = readRagnarokActionWord(actionTable)
    if actionCode == nil or actionCode == 0 then
        return false, "Ragnarok native action code is unavailable"
    end

    commandArchive = archive
    commandContext = context
    commandActionTable = actionTable
    ragnarokDescriptor = descriptor
    ragnarokActionCode = actionCode

    return true, string.format(
        "state=%d archive=%s context=%s descriptor=%s action_code=0x%04X",
        state,
        pointerText(archive),
        pointerText(context),
        pointerText(descriptor),
        actionCode
    )
end

local function tryRuntimeInitialization()
    runtimeTicks = runtimeTicks + 1
    if runtimeTicks > 1 and runtimeTicks % 10 ~= 1 then
        return
    end

    local generalOK, generalReason = validateGeneralRuntime()
    if not generalOK then
        if runtimeTicks % 300 == 1 then
            log("WAITING: " .. generalReason)
        end
        return
    end

    local commandOK, commandReason = validateSpecialCommandRuntime()
    if not commandOK then
        if runtimeTicks % 300 == 1 then
            log("WAITING: " .. commandReason)
        end
        return
    end

    waitingForRuntime = false
    enabled = true
    log(string.format(
        "READY: base=%s wrapper=%s %s",
        pointerText(moduleBase),
        pointerText(moduleBase + NATIVE_RAGNAROK_COMMAND_WRAPPER_RVA),
        commandReason
    ))

    if nativeRegistrationValid() then
        attemptUsed = true
        finalReported = true
        log(
            "ALREADY PRIMED: native action 0x25 is registered; v3 will "
                .. "make no changes."
        )
    else
        log(
            "Enter a real enemy encounter and press Attack once. The first "
                .. "recognized v13 attack will carry the native command."
        )
    end
end

-- ========================================================================
-- ROUTE INSTALLATION AND RESTORATION
-- ========================================================================

local function nativeStateIdle()
    return safeReadLong(BATTLE_CALLBACK_POINTER) == 0
        and safeReadLong(EFFECT_OBJECT_A_POINTER) == 0
        and safeReadLong(EFFECT_OBJECT_B_POINTER) == 0
        and safeReadLong(PROJECTILE_TASK_LAST) == 0
        and safeReadInt(PROJECTILE_TASK_HANDLE) == 0
end

local function restoreExecutableRoute()
    local allOK = true

    local continuation = safeReadArray(POST_COMMAND_CONTINUATION_RVA, 5)
    if arraysEqual(continuation, CLEAN_EXIT_JUMP) then
        local ok, reason = writeArrayChecked(
            POST_COMMAND_CONTINUATION_RVA,
            ORIGINAL_POST_COMMAND_PREFIX
        )
        if not ok then
            allOK = false
            log("CRITICAL: clean-exit restoration failed: " .. reason)
        end
    elseif not arraysEqual(continuation, ORIGINAL_POST_COMMAND_PREFIX) then
        allOK = false
        log(
            "CRITICAL: post-command continuation has unknown bytes; "
                .. "they were not overwritten."
        )
    end

    local callsite = safeReadArray(ACTION_02_UPDATE_CALLSITE_RVA, 5)
    if arraysEqual(callsite, redirectCommandCall) then
        local ok, reason = writeArrayChecked(
            ACTION_02_UPDATE_CALLSITE_RVA,
            ORIGINAL_ACTION_02_CALL
        )
        if not ok then
            allOK = false
            log("CRITICAL: native-command CALL restoration failed: " .. reason)
        end
    elseif not arraysEqual(callsite, ORIGINAL_ACTION_02_CALL) then
        allOK = false
        log(
            "CRITICAL: CALL site has unknown bytes; they were not "
                .. "overwritten."
        )
    end

    local gate = safeReadArray(ACTION_UPDATE_GATE_BRANCH_RVA, 2)
    if arraysEqual(gate, BYPASS_GATE_BRANCH) then
        local ok, reason = writeArrayChecked(
            ACTION_UPDATE_GATE_BRANCH_RVA,
            ORIGINAL_GATE_BRANCH
        )
        if not ok then
            allOK = false
            log("CRITICAL: action-gate restoration failed: " .. reason)
        end
    elseif not arraysEqual(gate, ORIGINAL_GATE_BRANCH) then
        allOK = false
        log(
            "CRITICAL: action gate has unknown bytes; they were not "
                .. "overwritten."
        )
    end

    routeArmed = false
    if not allOK then
        enabled = false
    end
    return allOK
end

local function restoreNativeReleaseRedirect()
    local current = safeReadLong(NATIVE_UPDATE_POINTER_FIELD)
    if current == nativeUpdatePointer then
        releaseRedirectArmed = false
        return true
    end
    if current ~= nativeTaskCreatorPointer then
        enabled = false
        monitorActive = false
        finalReported = true
        log(string.format(
            "CRITICAL: native +0x30 contains unknown pointer %s; "
                .. "it was not overwritten.",
            pointerText(current or 0)
        ))
        return false
    end

    local restored, reason = writePointerChecked(
        NATIVE_UPDATE_POINTER_FIELD,
        nativeUpdatePointer
    )
    if not restored then
        enabled = false
        monitorActive = false
        finalReported = true
        log("CRITICAL: native release route did not restore: " .. reason)
        return false
    end

    releaseRedirectArmed = false
    log(
        "RELEASE ROUTE RESTORED: native action +0x30 points to its "
            .. "updater again."
    )
    return true
end

local function armNativeRelease()
    if releaseAttemptUsed or releaseRedirectArmed then
        return false
    end
    releaseAttemptUsed = true

    local current = safeReadLong(NATIVE_UPDATE_POINTER_FIELD)
    if current ~= nativeUpdatePointer then
        finalReported = true
        monitorActive = false
        log(string.format(
            "AUTO-PRIME FAILED: native +0x30 changed before release "
                .. "(found %s expected %s).",
            pointerText(current or 0),
            pointerText(nativeUpdatePointer)
        ))
        return false
    end

    local written, reason = writePointerChecked(
        NATIVE_UPDATE_POINTER_FIELD,
        nativeTaskCreatorPointer
    )
    if not written then
        if safeReadLong(NATIVE_UPDATE_POINTER_FIELD)
            == nativeTaskCreatorPointer
        then
            releaseRedirectArmed = true
            restoreNativeReleaseRedirect()
        end
        finalReported = true
        monitorActive = false
        log("AUTO-PRIME FAILED: native release redirect failed: " .. reason)
        return false
    end

    releaseRedirectArmed = true
    log(string.format(
        "RELEASE ARMED: genuine F6 counter=6 timer=%.2f; action 0x25 "
            .. "+0x30 uses %s for one engine interval.",
        safeReadFloat(RAGNAROK_PHASE_TIMER) or -1.0,
        pointerText(nativeTaskCreatorPointer)
    ))
    return true
end

local function armNativeCommand(sora, animation)
    if attemptUsed or routeArmed then
        return
    end
    attemptUsed = true

    if nativeRegistrationValid() then
        finalReported = true
        log("ALREADY PRIMED: native action 0x25 became registered.")
        return
    end

    local commandOK, commandReason = validateSpecialCommandRuntime()
    if not commandOK then
        attemptUsed = false
        log("NOT ARMED: " .. commandReason)
        return
    end

    if not nativeStateIdle() then
        attemptUsed = false
        log("NOT ARMED: native callback/effect/projectile state is busy.")
        return
    end

    local override = safeReadLong(ACTION_UPDATE_OVERRIDE_CALLBACK)
    if override == nil or override ~= 0 then
        attemptUsed = false
        log(string.format(
            "NOT ARMED: action-update override is busy at %s.",
            pointerText(override or 0)
        ))
        return
    end

    local callsite = safeReadArray(ACTION_02_UPDATE_CALLSITE_RVA, 5)
    local continuation = safeReadArray(POST_COMMAND_CONTINUATION_RVA, 5)
    local gate = safeReadArray(ACTION_UPDATE_GATE_BRANCH_RVA, 2)
    if not arraysEqual(callsite, ORIGINAL_ACTION_02_CALL)
        or not arraysEqual(continuation, ORIGINAL_POST_COMMAND_PREFIX)
        or not arraysEqual(gate, ORIGINAL_GATE_BRANCH)
    then
        enabled = false
        log("DISABLED: executable route changed before arming.")
        return
    end

    -- Install the clean exit first so the native command can never return
    -- into action 0x02's original continuation, even transiently.
    local exitOK, exitReason = writeArrayChecked(
        POST_COMMAND_CONTINUATION_RVA,
        CLEAN_EXIT_JUMP
    )
    if not exitOK then
        log("ABORTED: clean-exit route failed: " .. exitReason)
        return
    end

    local callOK, callReason = writeArrayChecked(
        ACTION_02_UPDATE_CALLSITE_RVA,
        redirectCommandCall
    )
    if not callOK then
        restoreExecutableRoute()
        log("ABORTED: native-command redirect failed: " .. callReason)
        return
    end

    local gateOK, gateReason = writeArrayChecked(
        ACTION_UPDATE_GATE_BRANCH_RVA,
        BYPASS_GATE_BRANCH
    )
    if not gateOK then
        restoreExecutableRoute()
        log("ABORTED: action-gate bypass failed: " .. gateReason)
        return
    end

    routeArmed = true
    routeCallbacks = 0
    log(string.format(
        "ARMED: combat animation 0x%02X will invoke native command index 3 "
            .. "once (descriptor=%s action_code=0x%04X).",
        animation,
        pointerText(ragnarokDescriptor),
        ragnarokActionCode
    ))
end

local function finishRoute(executed, reason)
    local restored = restoreExecutableRoute()
    if not executed then
        finalReported = true
        log("NO PRIME: " .. reason .. "; temporary patches were restored.")
        return
    end

    monitorActive = true
    monitorTicks = 0
    nativeActionSeen = false
    log("NATIVE COMMAND EXECUTED: " .. stateText(currentSora))
    if restored then
        log(
            "ROUTE RESTORED: the temporary CALL redirect, clean exit, "
                .. "and gate bypass are no longer active."
        )
    end
end

local function monitorArmedRoute()
    routeCallbacks = routeCallbacks + 1
    local sora = safeReadLong(SORA_POINTER) or 0
    local nativeSora = safeReadLong(NATIVE_RAGNAROK_SORA_POINTER) or 0

    -- Registration is the first persistent result of dispatcher case 3.
    -- Restore immediately; waiting for the next animation could invoke the
    -- native command more than once.
    if nativeRegistrationValid() and nativeSora == sora then
        currentSora = sora
        finishRoute(true, "native action registration appeared")
        return
    end

    if routeCallbacks >= MAX_ROUTE_CALLBACKS then
        finishRoute(
            false,
            "native command did not execute before the route timeout"
        )
    end
end

-- ========================================================================
-- POST-COMMAND MONITOR
-- ========================================================================

local function monitorPrime()
    monitorTicks = monitorTicks + 1
    local sora = safeReadLong(SORA_POINTER) or 0
    local nativeSora = safeReadLong(NATIVE_RAGNAROK_SORA_POINTER) or 0
    local action = 0
    local animation = 0
    local slot = 0
    if sora ~= 0 then
        action = safeReadInt(sora + CURRENT_ACTION_ID_OFFSET, true) or 0
        animation = safeReadByte(
            sora + CURRENT_ANIMATION_OFFSET,
            true
        ) or 0
        slot = (safeReadInt(
            sora + RESOLVED_MOTION_INDEX_OFFSET,
            true
        ) or 0) % 0x10000
    end

    if action == NATIVE_RAGNAROK_ACTION_ID
        or (animation >= 0xF0 and animation <= 0xF7)
    then
        nativeActionSeen = true
    end

    local registered = nativeRegistrationValid()
    local manager = safeReadLong(BATTLE_MANAGER_POINTER) or 0
    local helper = safeReadLong(NATIVE_HELPER_POINTER) or 0
    local callback = safeReadLong(BATTLE_CALLBACK_POINTER) or 0
    local effectA = safeReadLong(EFFECT_OBJECT_A_POINTER) or 0
    local effectB = safeReadLong(EFFECT_OBJECT_B_POINTER) or 0
    local taskFirst = safeReadLong(PROJECTILE_TASK_FIRST) or 0
    local taskLast = safeReadLong(PROJECTILE_TASK_LAST) or 0
    local handle = safeReadInt(PROJECTILE_TASK_HANDLE) or 0
    local counter = safeReadInt(RAGNAROK_PHASE_COUNTER) or 0
    local timer = safeReadFloat(RAGNAROK_PHASE_TIMER) or 0.0

    local fullReady = registered
        and nativeSora == sora
        and manager == ragnarokDescriptor
        and helper ~= 0
        and taskFirst ~= 0

    if fullReady then
        finalReported = true
        monitorActive = false
        log("FULL PRIME READY: " .. stateText(sora))
        log(
            "AUTO-PRIME COMPLETE: genuine command, F0..F6 charge, native "
                .. "release, and projectile-task initialization all passed."
        )
        log(
            "Leave v8.9.5 enabled. It will become READY automatically after "
                .. "this genuine prime volley returns idle; do not press F1."
        )
        return
    end

    if not releaseAttemptUsed
        and action == NATIVE_RAGNAROK_ACTION_ID
        and animation == RAGNAROK_F6_ANIMATION
        and slot == RAGNAROK_F6_SLOT
        and counter == 6
        and timer >= RELEASE_AT_TIMER
    then
        if timer < RELEASE_WINDOW_MIN or timer >= RELEASE_WINDOW_MAX then
            finalReported = true
            monitorActive = false
            log(string.format(
                "AUTO-PRIME FAILED: native release window was missed "
                    .. "(timer=%.2f).",
                timer
            ))
            return
        end

        if registered
            and callback == nativeBattleCallbackPointer
            and manager == ragnarokDescriptor
            and helper ~= 0
            and effectA ~= 0
            and effectB == 0
            and taskLast == 0
            and handle == 0
        then
            armNativeRelease()
            return
        end
    end

    if nativeActionSeen
        and action ~= NATIVE_RAGNAROK_ACTION_ID
        and not (animation >= 0xF0 and animation <= 0xF7)
        and monitorTicks > 15
    then
        finalReported = true
        monitorActive = false
        log(
            "PARTIAL PRIME: genuine native action exited before the "
                .. "projectile runtime became ready."
        )
        log("FINAL STATE: " .. stateText(sora))
        log(
            "Restart the game before retrying; do not reload this file "
                .. "inside the partial process."
        )
        return
    end

    if monitorTicks >= MONITOR_TIMEOUT_CALLBACKS then
        finalReported = true
        monitorActive = false
        log("PRIME MONITOR TIMEOUT: " .. stateText(sora))
        return
    end

    if monitorTicks % STATUS_INTERVAL_CALLBACKS == 0 then
        log(string.format(
            "PRIME STILL RUNNING: %s counter=%d timer=%.2f callback=%s "
                .. "effectA=%s effectB=%s",
            stateText(sora),
            counter,
            timer,
            pointerText(callback),
            pointerText(effectA),
            pointerText(effectB)
        ))
    end
end

-- ========================================================================
-- LUA EVENTS
-- ========================================================================

local function moduleInit()
    enabled = false
    waitingForRuntime = false
    runtimeTicks = 0
    moduleBase = 0
    redirectCommandCall = nil
    nativeUpdatePointer = 0
    nativeTaskCreatorPointer = 0
    nativeBattleCallbackPointer = 0

    currentSora = 0
    commandArchive = 0
    commandContext = 0
    commandActionTable = 0
    ragnarokDescriptor = 0
    ragnarokActionCode = 0

    attemptUsed = false
    routeArmed = false
    routeCallbacks = 0
    monitorActive = false
    monitorTicks = 0
    nativeActionSeen = false
    finalReported = false
    releaseRedirectArmed = false
    releaseAttemptUsed = false

    if not ENABLE_TEST then
        log("DISABLED: ENABLE_TEST is false.")
        return
    end

    waitingForRuntime = true
    log(
        "WAITING: complete v4 auto-prime loaded; command and native-release "
            .. "routes must both validate before the one allowed attempt."
    )
end

local function moduleFrame()
    -- The prior engine interval may have used the native task creator. Restore
    -- action 0x25's updater before observing state or doing any other work.
    if releaseRedirectArmed and not restoreNativeReleaseRedirect() then
        return
    end

    if waitingForRuntime then
        tryRuntimeInitialization()
        return
    end
    if not enabled then
        return
    end

    if routeArmed then
        monitorArmedRoute()
        return
    end
    if monitorActive then
        monitorPrime()
        return
    end
    if finalReported or attemptUsed then
        return
    end

    local sora = safeReadLong(SORA_POINTER) or 0
    local nativeSora = safeReadLong(NATIVE_RAGNAROK_SORA_POINTER) or 0
    if sora == 0 or nativeSora ~= sora then
        return
    end

    if currentSora ~= sora then
        currentSora = sora
        local commandOK, commandReason = validateSpecialCommandRuntime()
        if not commandOK then
            log("WAITING AFTER SORA CHANGE: " .. commandReason)
            return
        end
        log(
            "Sora instance changed; special-command pointers were "
                .. "revalidated successfully."
        )
    end

    local action = safeReadInt(sora + CURRENT_ACTION_ID_OFFSET, true) or 0
    local animation = safeReadByte(sora + CURRENT_ANIMATION_OFFSET, true) or 0
    if action == GENERAL_ATTACK_ACTION_ID
        and COMBAT_CARRIER_ANIMATIONS[animation]
    then
        armNativeCommand(sora, animation)
    end
end




    return { name = "RagnarokAutoPrimeV4", init = moduleInit, frame = moduleFrame, enabled = true }
end

local function buildProjectileRoute()
    -- ====================================================================
    -- BEGIN EMBEDDED CONTROLLER: RagnarokProjectileV8_9_5
    -- ====================================================================
-- Kingdom Hearts Final Mix (Steam)
-- Ragnarok projectile visual route v8.9.5 REUSABLE PRIMED / v13.
--
-- REQUIRED COMPANION
--   Keep the known-working v13 BANKSAFE Sora combo controller and its v13
--   MSET enabled. This file does not replace v13; it runs beside it.
--
-- PURPOSE
--   The v7.1 trace proved that native Ragnarok uses action controller 0x25,
--   while the modified CC/CD/CE aerial combo remains on controller 0x02.
--   v8.1 proved that controller 0x02 does not dispatch registry callback
--   +0x30. Static verification then found the executable's explicit action
--   0x02 branch and its hard-coded per-frame helper call.
--   v8.3 proved that CC/CD does not enter that inner dispatcher. Its caller
--   rejects the active aerial-combat state at a verified two-byte JE gate.
--   v8.6 proved that the native update and battle callback can run on the
--   replacement controller and create effect B, but the automatic maximum-
--   charge effect did not emit projectile tasks.
--
--   The genuine trace resolves why: native F6 charges through timer 34. The
--   player's real release/follow-up changes F6 -> F7 at timer 35, and message
--   0x0B calls the native task creator in that same frame (task count 0 -> 10).
--   Waiting at timer 50 is therefore not equivalent to the release event.
--   v8.7 then called the verified native task creator at timer 35. It built
--   the native list (active-head 0 -> nonzero), but the global task callback
--   left the active-count handle at zero. Static verification found two local
--   state guards at the start of that callback which reject controller 0x02.
--
--   v8.8 succeeded in-game: the native task list was built, its updater
--   activated with handle 0xA, projectiles moved, and damage was dealt. It
--   also exposed the remaining visual defect. The native task creator issues
--   its own explicit F7 motion request, which displaces v13's already-routed
--   CD/CE -> F7 visual and appears as an idle pose in this mixed controller.
--   v8.9 then exposed an initialization-only issue: after a clean process
--   restart, native action entry 0x25 can remain unregistered even though
--   v13 and the general attack entry 0x02 are fully active. v8.9.1 derives
--   the executable base from general callback +0x18 instead. The native
--   projectile code and every patched instruction are still byte-validated.
--   v8.9.2 proved that static code validation is not sufficient. It crashed
--   after ARMED when native action 0x25, the battle manager, and the native
--   projectile task pool were all uninitialized. The read-only v8.9.3
--   preflight then proved the required primed state after one genuine
--   Ragnarok: registered action 0x25, matching general/native Sora pointers,
--   nonzero battle manager and task pool, and idle callback/effect/task state.
--
--   v8.9.4 refuses to initialize or arm without that complete primed state.
--   It isolates one new change: suppress the duplicate native F7 motion
--   request while retaining v13's already-routed F7 visual. It intentionally
--   does NOT add Ragnarok suspension flags. If this succeeds without a crash,
--   suspension can be added separately in the following build.
--   The in-game v8.9.4 result was complete: correct routed F7 visual, native
--   projectile updater handle 0xA, moving/damaging projectiles, and clean
--   volley teardown. No suspension flags were needed. v8.9.5 keeps that exact
--   route, removes the one-attempt POC limit, and resets its sequence detector
--   after each completed or failed volley so later aerial finishers can run.
--
--   On the real second press of ONE modified aerial sequence, this test:
--     1. primes Ragnarok's verified F7 release counter and timer (6 / 35);
--     2. suppresses only the task creator's explicit duplicate F7 motion
--        request for its one routed interval, leaving v13's F7 visual active;
--     3. bypasses that caller gate and redirects action 0x02's verified call
--        directly to the native Ragnarok projectile-task creator;
--     4. bypasses only the two verified local guards in Ragnarok's registered
--        task updater while the resulting volley is active;
--     5. restores the main action route and duplicate-motion call after one
--        engine interval, and restores the task guards after the volley ends
--        or the failsafe expires; and
--     6. reports list construction, updater activation, and completion.
--
-- SAFETY BOUNDARIES
--   * Reusable after each complete volley; never arms while native tasks,
--     effects, or callbacks are busy.
--   * No input generation.
--   * No animation ID, action ID, motion pointer, MSET, HP, or damage edits.
--     One verified CALL instruction is NOPed for the same one engine interval
--     as the task route; no animation data or table entry is modified.
--   * The main two-byte gate and five-byte call are patched for exactly one
--     engine-update interval. The task creator's five-byte duplicate-motion
--     call is suppressed for that same interval. Two two-byte branches local
--     to Ragnarok's task updater remain bypassed only while this test's volley
--     is alive.
--   * ENABLE_SUSPENSION_TEST is false. This build performs no Sora flag writes.
--   * The battle callback and effect-object pointers must be idle and are
--     never written. The original controller globals are always restored.
--   * A stale call-site patch left by an F1 reload is removed at initialization.
--   * The script waits for the game to populate the action registry instead of
--     treating an early Lua initialization event as an unsupported build.
--   * The native task list must be idle before arming. This prevents its
--     initializer from replacing still-active genuine Ragnarok tasks.
--
-- TEST
--   1. Disable every older Ragnarok diagnostic and projectile POC.
--   2. Keep only the working v13 controller plus this file enabled.
--   3. If a genuine Ragnarok was needed to initialize the registry, wait
--      until all its projectiles disappear.
--   4. Use modified aerial attack CC or CD and press Attack a second time.
--   5. Stop attacking and read the F2 console.
--
-- EXPECTED SUCCESS LINES
--   SUCCESS: native Ragnarok projectile updater activated immediately.
--   VISUAL ROUTE ACTIVE: duplicate native F7 request suppressed...
--
-- If the route is not invoked, the script prints NO TASK CREATED and restores
-- everything. Reload the Lua scripts with F1 before another attempt.

-- ========================================================================
-- EDITABLE SETTINGS
-- ========================================================================

local ENABLE_TEST = true
local TEST_ONCE_PER_LOAD = false
local ENABLE_SUSPENSION_TEST = false
local RAGNAROK_F7_RELEASE_TIMER = 35.0
local TASK_ACTIVATION_TIMEOUT_CALLBACKS = 30
local TASK_LIFETIME_FAILSAFE_CALLBACKS = 600
local SUSPENSION_EXIT_CONFIRM_CALLBACKS = 2
local SUSPENSION_LIFETIME_FAILSAFE_CALLBACKS = 240

-- ========================================================================
-- VERIFIED STEAM EXECUTABLE LAYOUT
-- ========================================================================

local SORA_POINTER = 0x2537E48
local NATIVE_RAGNAROK_SORA_POINTER = 0x2D37280
local BATTLE_MANAGER_POINTER = 0x2EFB0E0

local ACTION_REGISTRY = 0x2DB3840
local ACTION_ENTRY_SIZE = 0x40
local GENERAL_ATTACK_ACTION_ID = 0x02
local NATIVE_RAGNAROK_ACTION_ID = 0x25

local NATIVE_RAGNAROK_SETUP_RVA = 0x0039FAF0
local NATIVE_RAGNAROK_UPDATE_RVA = 0x0039F7A0
local NATIVE_RAGNAROK_BATTLE_CALLBACK_RVA = 0x0039FF70
local NATIVE_RAGNAROK_TASK_CREATOR_RVA = 0x0039F330
local NATIVE_TASK_CREATOR_SIGNATURE = {
    0x48, 0x8B, 0xC4, 0x48, 0x89, 0x58, 0x08, 0x48,
}

-- The native task creator chooses an F7/F8 motion and calls the engine motion
-- requester here:
--   module+0x39F470: E8 0B 05 F0 FF  call module+0x29F980
-- In this mixed controller that explicit request exits v13's CD/CE route.
-- Its return value is not consumed. Suppress only this call while the task
-- creator runs, then restore it on the next Lua callback.
local TASK_CREATOR_MOTION_CALL_RVA = 0x0039F470
local ORIGINAL_TASK_CREATOR_MOTION_CALL = {
    0xE8, 0x0B, 0x05, 0xF0, 0xFF,
}
local SUPPRESSED_TASK_CREATOR_MOTION_CALL = {
    0x90, 0x90, 0x90, 0x90, 0x90,
}

-- Native task callback module+0x39FB60 contains two state guards before it
-- calls the generic list updater at module+0x28A710:
--   module+0x39FB6B: 74 2B  je  module+0x39FB98
--   module+0x39FB77: 75 1F  jne module+0x39FB98
-- Both rejection branches are bypassed while this POC's task list is active.
local TASK_UPDATE_GATE_A_RVA = 0x0039FB6B
local ORIGINAL_TASK_UPDATE_GATE_A = { 0x74, 0x2B }
local TASK_UPDATE_GATE_B_RVA = 0x0039FB77
local ORIGINAL_TASK_UPDATE_GATE_B = { 0x75, 0x1F }
local BYPASS_TASK_UPDATE_GATE = { 0x90, 0x90 }

-- At module+0x2A7B97, action 0x02 normally executes:
--   E8 74 E3 FF FF    call module+0x2A5F10
-- The surrounding dispatcher explicitly bypasses registry callback +0x30
-- for action IDs 0x02 and 0x04.
local ACTION_02_UPDATE_CALLSITE_RVA = 0x002A7B97
local ORIGINAL_ACTION_02_CALL = { 0xE8, 0x74, 0xE3, 0xFF, 0xFF }

-- At module+0x2A6246, the caller skips the action dispatcher when its combat
-- state gate returns false:
--   74 52    je module+0x2A629A
-- Temporarily NOP only this branch so the already-verified dispatcher runs.
local ACTION_UPDATE_GATE_BRANCH_RVA = 0x002A6246
local ORIGINAL_GATE_BRANCH = { 0x74, 0x52 }
local BYPASS_GATE_BRANCH = { 0x90, 0x90 }
local ACTION_UPDATE_OVERRIDE_CALLBACK = 0x2D5EC20

local GENERAL_CALLBACK_18_RVA = 0x002AFC20
local SHARED_CALLBACK_20_RVA = 0x002AF6A0
local GENERAL_CALLBACK_28_RVA = 0x002AFBC0
local GENERAL_CALLBACK_38_RVA = 0x002AFD60

local BATTLE_CALLBACK_POINTER = 0x2D53AA0
local CONTROLLER_COUNTER = 0x2F11490
local CONTROLLER_TIMER = 0x2F11494
local EFFECT_OBJECT_A_POINTER = 0x2F11498
local EFFECT_OBJECT_B_POINTER = 0x2F114A0
local PROJECTILE_TASK_FIRST = 0x2F114B0
local PROJECTILE_TASK_LAST = 0x2F114B8
local PROJECTILE_TASK_HANDLE = 0x2F114C8
local RAGNAROK_FINAL_THRESHOLD = 0x3E0018
local ENGINE_FRAME_DELTA = 0x233FBDC

local CURRENT_ACTION_ID_OFFSET = 0x70
local CURRENT_ANIMATION_OFFSET = 0x164
local RESOLVED_MOTION_INDEX_OFFSET = 0x168
local NATIVE_RAGNAROK_SUSPENSION_MASK = 0x01200000

local ID_CC = 0xCC
local ID_CD = 0xCD
local ID_CE = 0xCE
local SLOT_CC = 0x0066
local SLOT_CD = 0x0067
local SLOT_CE = 0x0068

local GENERAL_ACTION_ENTRY =
    ACTION_REGISTRY + GENERAL_ATTACK_ACTION_ID * ACTION_ENTRY_SIZE
local NATIVE_ACTION_ENTRY =
    ACTION_REGISTRY + NATIVE_RAGNAROK_ACTION_ID * ACTION_ENTRY_SIZE
local ZERO_POINTER_BYTES = { 0, 0, 0, 0, 0, 0, 0, 0 }

-- ========================================================================
-- STATE
-- ========================================================================

local enabled = false
local waitingForRuntime = false
local initializationTicks = 0
local waitingDetailPrinted = false
local timingWaitPrinted = false
local nativeUpdatePointer = 0
local nativeTaskCreatorPointer = 0
local redirectCallBytes = nil
local staleNativeUpdateCallBytes = nil
local nativeBattleCallbackPointer = 0
local nativeBattleCallbackBytes = nil

local sequenceState = "waiting"
local expectedSecondAnimation = 0
local previousAnimation = nil
local previousIndex = nil
local outsideSequenceTicks = 0

local routeArmed = false
local armedLuaCallbacks = 0
local taskMonitorActive = false
local taskMonitorTicks = 0
local taskUpdaterActivated = false
local testAttempted = false
local originalCounter = 0
local originalTimer = 0.0
local beforeTaskFirst = 0
local beforeTaskLast = 0
local beforeTaskHandle = 0
local armedTimer = 0.0

local suspensionActive = false
local suspensionSora = 0
local suspensionOwnedMask = 0
local suspensionAnimation = 0
local suspensionIndex = -1
local suspensionOutsideTicks = 0
local suspensionLifetimeTicks = 0

-- ========================================================================
-- HELPERS
-- ========================================================================

local function log(message)
    ConsolePrint("[RagnarokProjectileV8_9_5] " .. message)
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

local function missingBits(value, mask)
    local missing = 0
    local bit = 1
    local remaining = mask
    while remaining > 0 do
        local maskHasBit = remaining % 2
        if maskHasBit == 1 and math.floor(value / bit) % 2 == 0 then
            missing = missing + bit
        end
        remaining = math.floor(remaining / 2)
        bit = bit * 2
    end
    return missing
end

local function clearBits(value, mask)
    local result = value
    local bit = 1
    local remaining = mask
    while remaining > 0 do
        local maskHasBit = remaining % 2
        if maskHasBit == 1 and math.floor(result / bit) % 2 == 1 then
            result = result - bit
        end
        remaining = math.floor(remaining / 2)
        bit = bit * 2
    end
    return result
end

local function safeReadInt(address, absolute)
    local ok, value = pcall(ReadInt, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return unsigned32(value)
end

local function safeReadLong(address, absolute)
    local ok, value = pcall(ReadLong, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return value
end

local function safeReadFloat(address, absolute)
    local ok, value = pcall(ReadFloat, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return value
end

local function safeReadArray(address, length, absolute)
    local ok, value = pcall(ReadArray, address, length, absolute)
    if not ok or value == nil then
        return nil
    end
    return value
end

local function arraysEqual(left, right)
    if left == nil or right == nil or #left ~= #right then
        return false
    end
    for index = 1, #left do
        if left[index] ~= right[index] then
            return false
        end
    end
    return true
end

local function relativeCallBytes(callsiteRVA, targetRVA)
    local relative = targetRVA - (callsiteRVA + 5)
    if relative < 0 then
        relative = relative + 4294967296
    end
    return {
        0xE8,
        relative % 0x100,
        math.floor(relative / 0x100) % 0x100,
        math.floor(relative / 0x10000) % 0x100,
        math.floor(relative / 0x1000000) % 0x100,
    }
end

local function pointerBytes(pointer)
    local bytes = {}
    local remaining = pointer
    for index = 1, 8 do
        bytes[index] = remaining % 0x100
        remaining = math.floor(remaining / 0x100)
    end
    return bytes
end

local function pointerText(pointer)
    if pointer == nil or pointer == 0 then
        return "0x0"
    end
    return string.format("0x%X", pointer)
end

local function writeArrayChecked(address, bytes)
    local ok, result = pcall(WriteArray, address, bytes)
    if not ok then
        return false, tostring(result)
    end
    local current = safeReadArray(address, #bytes)
    if not arraysEqual(current, bytes) then
        return false, "write did not verify"
    end
    return true, "verified"
end

local function writeIntChecked(address, value)
    local ok, result = pcall(WriteInt, address, value)
    if not ok then
        return false, tostring(result)
    end
    local current = safeReadInt(address)
    if current ~= unsigned32(value) then
        return false, "integer write did not verify"
    end
    return true, "verified"
end

local function writeAbsoluteIntChecked(address, value)
    local ok, result = pcall(WriteInt, address, value, true)
    if not ok then
        return false, tostring(result)
    end
    local current = safeReadInt(address, true)
    if current ~= unsigned32(value) then
        return false, "absolute integer write did not verify"
    end
    return true, "verified"
end

local function writeFloatChecked(address, value)
    local ok, result = pcall(WriteFloat, address, value)
    if not ok then
        return false, tostring(result)
    end
    local current = safeReadFloat(address)
    if current == nil or math.abs(current - value) > 0.01 then
        return false, "float write did not verify"
    end
    return true, "verified"
end

local function restoreTaskCreatorMotionCall()
    local current = safeReadArray(TASK_CREATOR_MOTION_CALL_RVA, 5)
    if arraysEqual(current, ORIGINAL_TASK_CREATOR_MOTION_CALL) then
        return true, "already restored"
    end
    if not arraysEqual(current, SUPPRESSED_TASK_CREATOR_MOTION_CALL) then
        return false, "unknown bytes; call was not overwritten"
    end
    return writeArrayChecked(
        TASK_CREATOR_MOTION_CALL_RVA,
        ORIGINAL_TASK_CREATOR_MOTION_CALL
    )
end

local function suppressTaskCreatorMotionCall()
    local current = safeReadArray(TASK_CREATOR_MOTION_CALL_RVA, 5)
    if not arraysEqual(current, ORIGINAL_TASK_CREATOR_MOTION_CALL) then
        return false, "duplicate-motion call signature changed before arming"
    end
    return writeArrayChecked(
        TASK_CREATOR_MOTION_CALL_RVA,
        SUPPRESSED_TASK_CREATOR_MOTION_CALL
    )
end

local function restoreTaskUpdateGates()
    local allRestored = true
    local gates = {
        {
            address = TASK_UPDATE_GATE_A_RVA,
            original = ORIGINAL_TASK_UPDATE_GATE_A,
            label = "task-update gate A",
        },
        {
            address = TASK_UPDATE_GATE_B_RVA,
            original = ORIGINAL_TASK_UPDATE_GATE_B,
            label = "task-update gate B",
        },
    }

    for index = 1, #gates do
        local gate = gates[index]
        local current = safeReadArray(gate.address, 2)
        if arraysEqual(current, BYPASS_TASK_UPDATE_GATE) then
            local ok, reason = writeArrayChecked(
                gate.address,
                gate.original
            )
            if not ok then
                allRestored = false
                log("CRITICAL: " .. gate.label
                    .. " restoration failed: " .. reason)
            end
        elseif not arraysEqual(current, gate.original) then
            allRestored = false
            log("CRITICAL: " .. gate.label
                .. " has unknown bytes; it was not overwritten.")
        end
    end

    return allRestored
end

local function installTaskUpdateGates()
    local currentA = safeReadArray(TASK_UPDATE_GATE_A_RVA, 2)
    local currentB = safeReadArray(TASK_UPDATE_GATE_B_RVA, 2)
    if not arraysEqual(currentA, ORIGINAL_TASK_UPDATE_GATE_A)
        or not arraysEqual(currentB, ORIGINAL_TASK_UPDATE_GATE_B)
    then
        return false, "task-update gate signature changed before arming"
    end

    local gateAOK, gateAReason = writeArrayChecked(
        TASK_UPDATE_GATE_A_RVA,
        BYPASS_TASK_UPDATE_GATE
    )
    if not gateAOK then
        return false, "gate A: " .. gateAReason
    end

    local gateBOK, gateBReason = writeArrayChecked(
        TASK_UPDATE_GATE_B_RVA,
        BYPASS_TASK_UPDATE_GATE
    )
    if not gateBOK then
        local restored = restoreTaskUpdateGates()
        if not restored then
            enabled = false
        end
        return false, "gate B: " .. gateBReason
    end

    return true, "verified"
end

local function expectedSlot(animation)
    if animation == ID_CC then
        return SLOT_CC
    end
    if animation == ID_CD then
        return SLOT_CD
    end
    if animation == ID_CE then
        return SLOT_CE
    end
    return -1
end

local function releaseSuspension(reason)
    if not suspensionActive then
        return true
    end

    local currentSora = safeReadLong(SORA_POINTER)
    local restored = true
    local beforeFlags = 0
    local afterFlags = 0

    -- Never write through a stale entity pointer after a room/load change.
    if currentSora == suspensionSora and suspensionSora ~= 0 then
        local currentFlags = safeReadInt(suspensionSora, true)
        if currentFlags == nil then
            restored = false
            log("ERROR: suspension flags became unreadable; no stale write made.")
        else
            beforeFlags = currentFlags
            afterFlags = clearBits(currentFlags, suspensionOwnedMask)
            if afterFlags ~= currentFlags then
                local ok, writeReason = writeAbsoluteIntChecked(
                    suspensionSora,
                    afterFlags
                )
                if not ok then
                    restored = false
                    log("ERROR: suspension-bit release failed: " .. writeReason)
                end
            end
        end
    else
        -- The old pointer may already be invalid. Abandon ownership rather
        -- than risking a write into a recycled entity.
        restored = false
        log(
            "NOTICE: Sora pointer changed while suspension was active; "
                .. "the stale address was not written."
        )
    end

    log(string.format(
        "SUSPENSION END: reason=%s owned=0x%08X flags=0x%08X->0x%08X.",
        reason,
        suspensionOwnedMask,
        beforeFlags,
        afterFlags
    ))

    suspensionActive = false
    suspensionSora = 0
    suspensionOwnedMask = 0
    suspensionAnimation = 0
    suspensionIndex = -1
    suspensionOutsideTicks = 0
    suspensionLifetimeTicks = 0
    return restored
end

local function beginSuspension(sora, animation)
    if suspensionActive then
        return false, "a suspension window is already active"
    end
    if sora == nil or sora == 0 then
        return false, "Sora pointer is unavailable"
    end

    local flags = safeReadInt(sora, true)
    if flags == nil then
        return false, "Sora flags could not be read"
    end

    local owned = missingBits(flags, NATIVE_RAGNAROK_SUSPENSION_MASK)
    local after = flags + owned
    if after ~= flags then
        local ok, reason = writeAbsoluteIntChecked(sora, after)
        if not ok then
            return false, reason
        end
    end

    suspensionActive = true
    suspensionSora = sora
    suspensionOwnedMask = owned
    suspensionAnimation = animation
    suspensionIndex = expectedSlot(animation)
    suspensionOutsideTicks = 0
    suspensionLifetimeTicks = 0

    log(string.format(
        "VISUAL/SUSPENSION ACTIVE: duplicate native F7 request will be "
            .. "suppressed; animation=0x%02X slot=0x%04X "
            .. "flags=0x%08X->0x%08X owned=0x%08X.",
        suspensionAnimation,
        suspensionIndex,
        flags,
        after,
        owned
    ))
    return true, "verified"
end

local function monitorSuspension()
    if not suspensionActive then
        return
    end

    suspensionLifetimeTicks = suspensionLifetimeTicks + 1
    local sora = safeReadLong(SORA_POINTER)
    if sora == nil or sora == 0 or sora ~= suspensionSora then
        releaseSuspension("Sora pointer changed")
        return
    end

    local action = safeReadInt(sora + CURRENT_ACTION_ID_OFFSET, true)
    local animation = ReadByte(sora + CURRENT_ANIMATION_OFFSET, true)
    local indexValue = safeReadInt(
        sora + RESOLVED_MOTION_INDEX_OFFSET,
        true
    )
    if action == nil or animation == nil or indexValue == nil then
        suspensionOutsideTicks = suspensionOutsideTicks + 1
    else
        local index = indexValue % 0x10000
        if action == GENERAL_ATTACK_ACTION_ID
            and animation == suspensionAnimation
            and index == suspensionIndex
        then
            suspensionOutsideTicks = 0

            -- Keep only the bits this script owns asserted for the visual
            -- window. If the engine cleared one, reapply it without touching
            -- any unrelated state.
            local flags = safeReadInt(sora, true)
            if flags ~= nil then
                local missingOwned = missingBits(flags, suspensionOwnedMask)
                if missingOwned ~= 0 then
                    local ok, reason = writeAbsoluteIntChecked(
                        sora,
                        flags + missingOwned
                    )
                    if not ok then
                        enabled = false
                        releaseSuspension("owned-bit maintenance failed")
                        log("DISABLED: suspension maintenance failed: " .. reason)
                        return
                    end
                end
            end
        else
            suspensionOutsideTicks = suspensionOutsideTicks + 1
        end
    end

    if suspensionOutsideTicks >= SUSPENSION_EXIT_CONFIRM_CALLBACKS then
        releaseSuspension("routed F7 visual exited")
        return
    end

    if suspensionLifetimeTicks >= SUSPENSION_LIFETIME_FAILSAFE_CALLBACKS then
        releaseSuspension("lifetime failsafe")
    end
end

local function isReplacementAnimation(animation, index)
    return expectedSlot(animation) == index
end

local function resetSequence()
    sequenceState = "waiting"
    expectedSecondAnimation = 0
    outsideSequenceTicks = 0
end

local function validatePointer(address, expected, label)
    local actual = safeReadLong(address)
    if actual == nil then
        return false, label .. " could not be read"
    end
    if actual ~= expected then
        return false, string.format(
            "%s mismatch: found %s expected %s",
            label,
            pointerText(actual),
            pointerText(expected)
        )
    end
    return true, ""
end

local function validateRuntime()
    -- General attack action 0x02 is the controller v13 actually uses and is
    -- available as soon as v13 reports READY. Native action 0x25 is lazily
    -- registered on some clean launches, so it is not a valid base anchor.
    local generalAnchor = safeReadLong(GENERAL_ACTION_ENTRY + 0x18)
    if generalAnchor == nil or generalAnchor == 0 then
        return false, "general action callback +0x18 is unavailable"
    end

    local moduleBase = generalAnchor - GENERAL_CALLBACK_18_RVA
    if moduleBase < 0x100000000
        or moduleBase >= 0x0000800000000000
    then
        return false, "derived executable base is invalid"
    end

    nativeUpdatePointer = moduleBase + NATIVE_RAGNAROK_UPDATE_RVA
    nativeTaskCreatorPointer =
        moduleBase + NATIVE_RAGNAROK_TASK_CREATOR_RVA
    nativeBattleCallbackPointer =
        moduleBase + NATIVE_RAGNAROK_BATTLE_CALLBACK_RVA
    nativeBattleCallbackBytes = pointerBytes(nativeBattleCallbackPointer)
    redirectCallBytes = relativeCallBytes(
        ACTION_02_UPDATE_CALLSITE_RVA,
        NATIVE_RAGNAROK_TASK_CREATOR_RVA
    )
    staleNativeUpdateCallBytes = relativeCallBytes(
        ACTION_02_UPDATE_CALLSITE_RVA,
        NATIVE_RAGNAROK_UPDATE_RVA
    )

    local taskCreatorSignature = safeReadArray(
        NATIVE_RAGNAROK_TASK_CREATOR_RVA,
        #NATIVE_TASK_CREATOR_SIGNATURE
    )
    if not arraysEqual(
        taskCreatorSignature,
        NATIVE_TASK_CREATOR_SIGNATURE
    ) then
        return false, "native Ragnarok task-creator signature mismatch"
    end

    local generalFlags = safeReadInt(GENERAL_ACTION_ENTRY)
    if generalFlags ~= 0x0000003D then
        return false, string.format(
            "general action flags mismatch: found 0x%08X expected 0x0000003D",
            generalFlags or 0
        )
    end

    -- v8.9.3 proved that direct task creation is unsafe unless native action
    -- 0x25 has been completely registered by one genuine Ragnarok.
    local nativeFlags = safeReadInt(NATIVE_ACTION_ENTRY)
    local nativeSetup = safeReadLong(NATIVE_ACTION_ENTRY + 0x08)
    local nativeUpdate = safeReadLong(NATIVE_ACTION_ENTRY + 0x30)
    if nativeFlags == nil or nativeSetup == nil or nativeUpdate == nil then
        return false, "native action entry could not be read safely"
    end
    if nativeFlags ~= 0x00000005 then
        return false, string.format(
            "native action flags mismatch: found 0x%08X "
                .. "expected 0x00000005",
            nativeFlags or 0
        )
    end
    if nativeSetup ~= moduleBase + NATIVE_RAGNAROK_SETUP_RVA then
        return false, string.format(
            "native 0x25 setup mismatch: found %s expected %s",
            pointerText(nativeSetup),
            pointerText(moduleBase + NATIVE_RAGNAROK_SETUP_RVA)
        )
    end
    if nativeUpdate ~= nativeUpdatePointer then
        return false, string.format(
            "native 0x25 update mismatch: found %s expected %s",
            pointerText(nativeUpdate),
            pointerText(nativeUpdatePointer)
        )
    end

    local checks = {
        {
            address = GENERAL_ACTION_ENTRY + 0x18,
            expected = moduleBase + GENERAL_CALLBACK_18_RVA,
            label = "general 0x02 callback(+18)",
        },
        {
            address = GENERAL_ACTION_ENTRY + 0x20,
            expected = moduleBase + SHARED_CALLBACK_20_RVA,
            label = "general 0x02 callback(+20)",
        },
        {
            address = GENERAL_ACTION_ENTRY + 0x28,
            expected = moduleBase + GENERAL_CALLBACK_28_RVA,
            label = "general 0x02 callback(+28)",
        },
        {
            address = GENERAL_ACTION_ENTRY + 0x38,
            expected = moduleBase + GENERAL_CALLBACK_38_RVA,
            label = "general 0x02 callback(+38)",
        },
    }

    for index = 1, #checks do
        local check = checks[index]
        local ok, reason = validatePointer(
            check.address,
            check.expected,
            check.label
        )
        if not ok then
            return false, reason
        end
    end

    local setup = safeReadLong(GENERAL_ACTION_ENTRY + 0x08)
    local cleanup = safeReadLong(GENERAL_ACTION_ENTRY + 0x10)
    if setup ~= 0 or cleanup ~= 0 then
        return false, "general 0x02 setup/cleanup signature mismatch"
    end

    local recoveredStalePatch = false

    local currentMotionCall = safeReadArray(
        TASK_CREATOR_MOTION_CALL_RVA,
        5
    )
    if arraysEqual(
        currentMotionCall,
        SUPPRESSED_TASK_CREATOR_MOTION_CALL
    ) then
        local restored, reason = restoreTaskCreatorMotionCall()
        if not restored then
            return false,
                "stale task-creator motion suppression could not be removed: "
                    .. reason
        end
        recoveredStalePatch = true
        log(
            "Recovered and removed stale task-creator motion suppression "
                .. "from an F1 reload."
        )
        currentMotionCall = safeReadArray(TASK_CREATOR_MOTION_CALL_RVA, 5)
    end

    if not arraysEqual(
        currentMotionCall,
        ORIGINAL_TASK_CREATOR_MOTION_CALL
    ) then
        return false, "task-creator duplicate-motion call signature mismatch"
    end

    local currentRoute = safeReadArray(ACTION_02_UPDATE_CALLSITE_RVA, 5)
    if arraysEqual(currentRoute, redirectCallBytes)
        or arraysEqual(currentRoute, staleNativeUpdateCallBytes)
    then
        local restored, reason = writeArrayChecked(
            ACTION_02_UPDATE_CALLSITE_RVA,
            ORIGINAL_ACTION_02_CALL
        )
        if not restored then
            return false, "stale call-site route could not be removed: " .. reason
        end
        recoveredStalePatch = true
        log("Recovered and removed a stale call-site route from an F1 reload.")
        currentRoute = safeReadArray(ACTION_02_UPDATE_CALLSITE_RVA, 5)
    end

    if not arraysEqual(currentRoute, ORIGINAL_ACTION_02_CALL) then
        return false, "action 0x02 per-frame call-site signature mismatch"
    end

    local currentGate = safeReadArray(ACTION_UPDATE_GATE_BRANCH_RVA, 2)
    if arraysEqual(currentGate, BYPASS_GATE_BRANCH) then
        local restored, reason = writeArrayChecked(
            ACTION_UPDATE_GATE_BRANCH_RVA,
            ORIGINAL_GATE_BRANCH
        )
        if not restored then
            return false, "stale action gate could not be removed: " .. reason
        end
        recoveredStalePatch = true
        log("Recovered and removed a stale action-gate bypass from an F1 reload.")
        currentGate = safeReadArray(ACTION_UPDATE_GATE_BRANCH_RVA, 2)
    end

    if not arraysEqual(currentGate, ORIGINAL_GATE_BRANCH) then
        return false, "action-update gate branch signature mismatch"
    end

    local taskGateA = safeReadArray(TASK_UPDATE_GATE_A_RVA, 2)
    local taskGateB = safeReadArray(TASK_UPDATE_GATE_B_RVA, 2)
    if arraysEqual(taskGateA, BYPASS_TASK_UPDATE_GATE)
        or arraysEqual(taskGateB, BYPASS_TASK_UPDATE_GATE)
    then
        if not restoreTaskUpdateGates() then
            return false, "stale task-update gates could not be restored"
        end
        recoveredStalePatch = true
        log("Recovered and removed stale task-update bypasses from F1.")
        taskGateA = safeReadArray(TASK_UPDATE_GATE_A_RVA, 2)
        taskGateB = safeReadArray(TASK_UPDATE_GATE_B_RVA, 2)
    end

    if not arraysEqual(taskGateA, ORIGINAL_TASK_UPDATE_GATE_A)
        or not arraysEqual(taskGateB, ORIGINAL_TASK_UPDATE_GATE_B)
    then
        return false, "native task-update gate signature mismatch"
    end

    if recoveredStalePatch then
        local staleCallback = safeReadArray(BATTLE_CALLBACK_POINTER, 8)
        if arraysEqual(staleCallback, nativeBattleCallbackBytes) then
            local restored, reason = writeArrayChecked(
                BATTLE_CALLBACK_POINTER,
                ZERO_POINTER_BYTES
            )
            if not restored then
                return false,
                    "stale native callback could not be removed: " .. reason
            end
            log("Recovered and removed the stale native battle callback.")
        elseif not arraysEqual(staleCallback, ZERO_POINTER_BYTES) then
            return false,
                "battle callback changed during stale-route recovery"
        end
    end

    local threshold = safeReadFloat(RAGNAROK_FINAL_THRESHOLD)
    if threshold == nil or threshold < 20.0 or threshold > 90.0 then
        return false, string.format(
            "Ragnarok final threshold is invalid: %.4f",
            threshold or -1.0
        )
    end

    local frameDelta = safeReadFloat(ENGINE_FRAME_DELTA)
    if frameDelta == nil or frameDelta < 0.01 or frameDelta > 5.0 then
        return false, string.format(
            "engine frame delta is invalid: %.4f",
            frameDelta or -1.0
        )
    end

    return true, string.format(
        "validated base=%s native_task_creator=%s "
            .. "F7_release_timer=%.2f final_threshold=%.2f delta=%.2f",
        pointerText(moduleBase),
        pointerText(nativeTaskCreatorPointer),
        RAGNAROK_F7_RELEASE_TIMER,
        threshold,
        frameDelta
    )
end

local function runtimeRegistryReady()
    local generalFlags = safeReadInt(GENERAL_ACTION_ENTRY)
    local nativeFlags = safeReadInt(NATIVE_ACTION_ENTRY)
    local nativeSetup = safeReadLong(NATIVE_ACTION_ENTRY + 0x08)
    local nativeUpdate = safeReadLong(NATIVE_ACTION_ENTRY + 0x30)
    local generalCallback18 = safeReadLong(GENERAL_ACTION_ENTRY + 0x18)
    local generalCallback20 = safeReadLong(GENERAL_ACTION_ENTRY + 0x20)
    local generalCallback28 = safeReadLong(GENERAL_ACTION_ENTRY + 0x28)
    local generalCallback38 = safeReadLong(GENERAL_ACTION_ENTRY + 0x38)
    local sora = safeReadLong(SORA_POINTER)
    local nativeSora = safeReadLong(NATIVE_RAGNAROK_SORA_POINTER)
    local manager = safeReadLong(BATTLE_MANAGER_POINTER)
    local callback = safeReadLong(BATTLE_CALLBACK_POINTER)
    local effectA = safeReadLong(EFFECT_OBJECT_A_POINTER)
    local effectB = safeReadLong(EFFECT_OBJECT_B_POINTER)
    local taskFirst = safeReadLong(PROJECTILE_TASK_FIRST)
    local taskLast = safeReadLong(PROJECTILE_TASK_LAST)
    local taskHandle = safeReadInt(PROJECTILE_TASK_HANDLE)
    local managerProbe = nil
    if manager ~= nil and manager ~= 0 then
        managerProbe = safeReadInt(manager, true)
    end
    local taskFirstProbe = nil
    if taskFirst ~= nil and taskFirst ~= 0 then
        taskFirstProbe = safeReadInt(taskFirst, true)
    end

    return generalFlags ~= nil and generalFlags ~= 0
        and nativeFlags == 0x00000005
        and nativeSetup ~= nil and nativeSetup ~= 0
        and nativeUpdate ~= nil and nativeUpdate ~= 0
        and generalCallback18 ~= nil and generalCallback18 ~= 0
        and generalCallback20 ~= nil and generalCallback20 ~= 0
        and generalCallback28 ~= nil and generalCallback28 ~= 0
        and generalCallback38 ~= nil and generalCallback38 ~= 0
        and sora ~= nil and sora ~= 0
        and nativeSora ~= nil and nativeSora == sora
        and manager ~= nil and manager ~= 0
        and managerProbe ~= nil
        and callback == 0 and effectA == 0 and effectB == 0
        and taskFirst ~= nil and taskFirst ~= 0
        and taskFirstProbe ~= nil
        and taskLast == 0 and taskHandle == 0
end

local function runtimeTimingReady()
    local threshold = safeReadFloat(RAGNAROK_FINAL_THRESHOLD)
    local frameDelta = safeReadFloat(ENGINE_FRAME_DELTA)
    return threshold ~= nil and threshold >= 20.0 and threshold <= 90.0
        and frameDelta ~= nil and frameDelta >= 0.01 and frameDelta <= 5.0
end

local function tryFinishRuntimeInitialization()
    initializationTicks = initializationTicks + 1

    -- Ten ticks avoids validating a registry while the game is midway through
    -- constructing it. Waiting has no timeout because title/load timing varies.
    if initializationTicks > 1 and initializationTicks % 10 ~= 1 then
        return false
    end

    if not runtimeRegistryReady() then
        if not waitingDetailPrinted then
            waitingDetailPrinted = true
            log(
                "WAITING: native Ragnarok is not fully primed and idle. "
                    .. "Perform one genuine Ragnarok, let every projectile "
                    .. "finish, then keep playing; no F1 reload is required."
            )
        end
        return false
    end

    if not runtimeTimingReady() then
        if not timingWaitPrinted then
            timingWaitPrinted = true
            log(
                "WAITING: action 0x02 is ready; engine timing globals are "
                    .. "not active yet. Resume gameplay and do not press F1."
            )
        end
        return false
    end

    local ok, result = validateRuntime()
    waitingForRuntime = false
    if not ok then
        enabled = false
        log("DISABLED after runtime initialization: " .. result)
        return false
    end

    enabled = true
    log("READY: " .. result)
    log("Keep v13 enabled. Perform CC or CD, then press Attack once more.")
    return true
end

local function restoreControllerGlobals()
    local counterOK, counterReason = writeIntChecked(
        CONTROLLER_COUNTER,
        originalCounter
    )
    local timerOK, timerReason = writeFloatChecked(
        CONTROLLER_TIMER,
        originalTimer
    )
    if not counterOK then
        log("ERROR: controller counter restoration failed: " .. counterReason)
    end
    if not timerOK then
        log("ERROR: controller timer restoration failed: " .. timerReason)
    end
    return counterOK and timerOK
end

local function armOneFrameRoute()
    if routeArmed or (TEST_ONCE_PER_LOAD and testAttempted) then
        return
    end

    local currentRoute = safeReadArray(ACTION_02_UPDATE_CALLSITE_RVA, 5)
    if not arraysEqual(currentRoute, ORIGINAL_ACTION_02_CALL) then
        enabled = false
        log("DISABLED: action 0x02 call site changed before arming.")
        return
    end

    local currentGate = safeReadArray(ACTION_UPDATE_GATE_BRANCH_RVA, 2)
    if not arraysEqual(currentGate, ORIGINAL_GATE_BRANCH) then
        enabled = false
        log("DISABLED: action-update gate changed before arming.")
        return
    end

    local currentMotionCall = safeReadArray(
        TASK_CREATOR_MOTION_CALL_RVA,
        5
    )
    if not arraysEqual(
        currentMotionCall,
        ORIGINAL_TASK_CREATOR_MOTION_CALL
    ) then
        enabled = false
        log("DISABLED: task-creator duplicate-motion call changed before arming.")
        return
    end

    local overrideCallback = safeReadLong(ACTION_UPDATE_OVERRIDE_CALLBACK)
    if overrideCallback == nil then
        log("ABORTED: action-update override callback could not be read.")
        return
    end
    if overrideCallback ~= 0 then
        log(string.format(
            "ABORTED: action-update override callback is active at %s.",
            pointerText(overrideCallback)
        ))
        return
    end

    local battleCallback = safeReadLong(BATTLE_CALLBACK_POINTER)
    local effectA = safeReadLong(EFFECT_OBJECT_A_POINTER)
    local effectB = safeReadLong(EFFECT_OBJECT_B_POINTER)
    local taskFirst = safeReadLong(PROJECTILE_TASK_FIRST)
    local taskLast = safeReadLong(PROJECTILE_TASK_LAST)
    local taskHandle = safeReadInt(PROJECTILE_TASK_HANDLE)
    if battleCallback == nil or effectA == nil or effectB == nil
        or taskFirst == nil or taskLast == nil or taskHandle == nil
    then
        log("ABORTED: one or more projectile-state fields could not be read.")
        return
    end

    -- Recheck every prerequisite from the successful v8.9.3 baseline on the
    -- exact callback that would arm the route. A room transition or native
    -- cleanup between READY and the second press must fail closed.
    local sora = safeReadLong(SORA_POINTER)
    local nativeSora = safeReadLong(NATIVE_RAGNAROK_SORA_POINTER)
    local manager = safeReadLong(BATTLE_MANAGER_POINTER)
    local managerProbe = nil
    if manager ~= nil and manager ~= 0 then
        managerProbe = safeReadInt(manager, true)
    end
    local taskFirstProbe = nil
    if taskFirst ~= nil and taskFirst ~= 0 then
        taskFirstProbe = safeReadInt(taskFirst, true)
    end
    local nativeFlags = safeReadInt(NATIVE_ACTION_ENTRY)
    local nativeSetup = safeReadLong(NATIVE_ACTION_ENTRY + 0x08)
    local nativeUpdate = safeReadLong(NATIVE_ACTION_ENTRY + 0x30)
    local expectedSetup =
        nativeUpdatePointer - NATIVE_RAGNAROK_UPDATE_RVA
            + NATIVE_RAGNAROK_SETUP_RVA
    if sora == nil or sora == 0 or nativeSora ~= sora
        or manager == nil or manager == 0 or managerProbe == nil
        or nativeFlags ~= 0x00000005
        or nativeSetup ~= expectedSetup
        or nativeUpdate ~= nativeUpdatePointer
        or taskFirst == 0 or taskFirstProbe == nil
    then
        log(string.format(
            "ABORTED: primed preflight changed before arming "
                .. "(sora=%s native_sora=%s manager=%s flags=0x%08X "
                .. "setup=%s update=%s task_first=%s).",
            pointerText(sora),
            pointerText(nativeSora),
            pointerText(manager),
            nativeFlags or 0,
            pointerText(nativeSetup),
            pointerText(nativeUpdate),
            pointerText(taskFirst)
        ))
        return
    end

    -- Direct task creation initializes the native Ragnarok task list. Do not
    -- invoke it over still-active genuine projectiles or an owned effect.
    if battleCallback ~= 0 or effectA ~= 0 or effectB ~= 0 then
        log(string.format(
            "ABORTED: native projectile state is busy "
                .. "(callback=%s effectA=%s effectB=%s last=%s handle=0x%X).",
            pointerText(battleCallback),
            pointerText(effectA),
            pointerText(effectB),
            pointerText(taskLast),
            taskHandle
        ))
        return
    end

    if taskLast ~= 0 or taskHandle ~= 0 then
        log(string.format(
            "NOT ARMED: native projectiles are still active "
                .. "(last=%s handle=0x%X). Wait for them to disappear, "
                .. "then perform CC/CD and the second press again.",
            pointerText(taskLast),
            taskHandle
        ))
        return
    end

    testAttempted = true

    originalCounter = safeReadInt(CONTROLLER_COUNTER)
    originalTimer = safeReadFloat(CONTROLLER_TIMER)
    beforeTaskFirst = taskFirst
    beforeTaskLast = taskLast
    beforeTaskHandle = taskHandle

    if originalCounter == nil or originalTimer == nil then
        log("ABORTED: native controller globals could not be read.")
        return
    end

    if ENABLE_SUSPENSION_TEST then
        local suspendOK, suspendReason = beginSuspension(
            sora,
            expectedSecondAnimation
        )
        if not suspendOK then
            log(
                "ABORTED: Ragnarok suspension could not begin: "
                    .. suspendReason
            )
            return
        end
    else
        log(string.format(
            "VISUAL ROUTE ACTIVE: duplicate native F7 request will be "
                .. "suppressed for animation=0x%02X slot=0x%04X; "
                .. "suspension flag writes are disabled.",
            expectedSecondAnimation,
            expectedSlot(expectedSecondAnimation)
        ))
    end

    armedTimer = RAGNAROK_F7_RELEASE_TIMER

    local counterOK, counterReason = writeIntChecked(CONTROLLER_COUNTER, 6)
    local timerOK, timerReason = writeFloatChecked(
        CONTROLLER_TIMER,
        armedTimer
    )
    if not counterOK or not timerOK then
        restoreControllerGlobals()
        releaseSuspension("controller priming failed")
        log(
            "ABORTED: controller priming failed: "
                .. tostring(counterReason) .. " / " .. tostring(timerReason)
        )
        return
    end

    local motionOK, motionReason = suppressTaskCreatorMotionCall()
    if not motionOK then
        restoreControllerGlobals()
        releaseSuspension("motion suppression failed")
        log(
            "ABORTED: duplicate native F7 request could not be suppressed: "
                .. motionReason
        )
        return
    end

    local routeOK, routeReason = writeArrayChecked(
        ACTION_02_UPDATE_CALLSITE_RVA,
        redirectCallBytes
    )
    if not routeOK then
        local motionRestored, motionRestoreReason =
            restoreTaskCreatorMotionCall()
        restoreControllerGlobals()
        releaseSuspension("call-site redirect failed")
        if not motionRestored then
            enabled = false
            log(
                "CRITICAL: failed to restore duplicate-motion call: "
                    .. motionRestoreReason
            )
        end
        log("ABORTED: one-frame call-site redirect failed: " .. routeReason)
        return
    end

    local gateOK, gateReason = writeArrayChecked(
        ACTION_UPDATE_GATE_BRANCH_RVA,
        BYPASS_GATE_BRANCH
    )
    if not gateOK then
        local routeRestored, restoreReason = writeArrayChecked(
            ACTION_02_UPDATE_CALLSITE_RVA,
            ORIGINAL_ACTION_02_CALL
        )
        local motionRestored, motionRestoreReason =
            restoreTaskCreatorMotionCall()
        restoreControllerGlobals()
        releaseSuspension("action-gate bypass failed")
        if not routeRestored or not motionRestored then
            enabled = false
            log(
                "CRITICAL: failed to undo temporary patches after gate error: "
                    .. restoreReason .. " / " .. motionRestoreReason
            )
        end
        log("ABORTED: action-gate bypass failed: " .. gateReason)
        return
    end

    local taskGatesOK, taskGatesReason = installTaskUpdateGates()
    if not taskGatesOK then
        local gateRestored, gateRestoreReason = writeArrayChecked(
            ACTION_UPDATE_GATE_BRANCH_RVA,
            ORIGINAL_GATE_BRANCH
        )
        local routeRestored, routeRestoreReason = writeArrayChecked(
            ACTION_02_UPDATE_CALLSITE_RVA,
            ORIGINAL_ACTION_02_CALL
        )
        local motionRestored, motionRestoreReason =
            restoreTaskCreatorMotionCall()
        restoreControllerGlobals()
        releaseSuspension("task-update gate install failed")
        if not gateRestored or not routeRestored or not motionRestored then
            enabled = false
            log(
                "CRITICAL: task-gate rollback was incomplete: "
                    .. tostring(gateRestoreReason) .. " / "
                    .. tostring(routeRestoreReason) .. " / "
                    .. tostring(motionRestoreReason)
            )
        end
        log("ABORTED: " .. taskGatesReason)
        return
    end

    routeArmed = true
    armedLuaCallbacks = 0
    log(string.format(
        "ARMED: one engine interval routed to task_creator=%s "
            .. "counter=6 timer=%.2f; duplicate F7 request suppressed; "
            .. "task-update guards bypassed.",
        pointerText(nativeTaskCreatorPointer),
        armedTimer
    ))
end

local function finishOneFrameRoute()
    local afterCounter = safeReadInt(CONTROLLER_COUNTER) or 0
    local afterTimer = safeReadFloat(CONTROLLER_TIMER) or -1.0
    local afterEffectA = safeReadLong(EFFECT_OBJECT_A_POINTER) or 0
    local afterEffectB = safeReadLong(EFFECT_OBJECT_B_POINTER) or 0
    local afterTaskFirst = safeReadLong(PROJECTILE_TASK_FIRST) or 0
    local afterTaskLast = safeReadLong(PROJECTILE_TASK_LAST) or 0
    local afterTaskHandle = safeReadInt(PROJECTILE_TASK_HANDLE) or 0

    local listConstructed = beforeTaskLast == 0 and afterTaskLast ~= 0

    local currentGate = safeReadArray(ACTION_UPDATE_GATE_BRANCH_RVA, 2)
    local gateRestored = false
    if arraysEqual(currentGate, BYPASS_GATE_BRANCH) then
        local ok, reason = writeArrayChecked(
            ACTION_UPDATE_GATE_BRANCH_RVA,
            ORIGINAL_GATE_BRANCH
        )
        gateRestored = ok
        if not ok then
            enabled = false
            log("CRITICAL: action-gate restoration failed: " .. reason)
        end
    elseif arraysEqual(currentGate, ORIGINAL_GATE_BRANCH) then
        gateRestored = true
    else
        enabled = false
        log(
            "CRITICAL: action gate changed by another owner; unknown bytes "
                .. "were not overwritten."
        )
    end

    local currentRoute = safeReadArray(ACTION_02_UPDATE_CALLSITE_RVA, 5)
    local routeRestored = false
    if arraysEqual(currentRoute, redirectCallBytes) then
        local ok, reason = writeArrayChecked(
            ACTION_02_UPDATE_CALLSITE_RVA,
            ORIGINAL_ACTION_02_CALL
        )
        routeRestored = ok
        if not ok then
            enabled = false
            log("CRITICAL: call-site restoration failed: " .. reason)
        end
    elseif arraysEqual(currentRoute, ORIGINAL_ACTION_02_CALL) then
        routeRestored = true
    else
        enabled = false
        log(
            "CRITICAL: call site changed by another owner; unknown bytes "
                .. "were not overwritten."
        )
    end

    local motionCallRestored, motionCallReason =
        restoreTaskCreatorMotionCall()
    if not motionCallRestored then
        enabled = false
        log(
            "CRITICAL: duplicate-motion call restoration failed: "
                .. motionCallReason
        )
    end

    local currentCallback = safeReadArray(BATTLE_CALLBACK_POINTER, 8)
    local callbackStayedIdle = arraysEqual(
        currentCallback,
        ZERO_POINTER_BYTES
    )
    if not callbackStayedIdle then
        enabled = false
        log(
            "CRITICAL: battle callback changed during the test; it was "
                .. "not overwritten."
        )
    end

    local globalsRestored = restoreControllerGlobals()
    routeArmed = false
    armedLuaCallbacks = 0

    if listConstructed then
        taskMonitorActive = true
        taskMonitorTicks = 0
        taskUpdaterActivated = afterTaskHandle > 0
    end

    log(string.format(
        "RESULT: release_route_interval=1 counter=6->%u "
            .. "timer=%.2f->%.2f effect_A=%s effect_B=%s "
            .. "task_first=%s->%s task_last=%s->%s handle=0x%X->0x%X",
        afterCounter,
        armedTimer,
        afterTimer,
        pointerText(afterEffectA),
        pointerText(afterEffectB),
        pointerText(beforeTaskFirst),
        pointerText(afterTaskFirst),
        pointerText(beforeTaskLast),
        pointerText(afterTaskLast),
        beforeTaskHandle,
        afterTaskHandle
    ))

    if not gateRestored or not routeRestored or not motionCallRestored
        or not callbackStayedIdle
        or not globalsRestored
    then
        restoreTaskUpdateGates()
        taskMonitorActive = false
        releaseSuspension("temporary patch restoration failed")
        resetSequence()
        log("FAILED: one or more temporary values did not restore cleanly.")
        return true
    end

    if listConstructed and taskUpdaterActivated then
        log(
            "SUCCESS: native Ragnarok projectile updater activated "
                .. "immediately."
        )
    elseif listConstructed then
        log(
            "TASK LIST CREATED: waiting for the registered native updater "
                .. "to activate it."
        )
    else
        restoreTaskUpdateGates()
        releaseSuspension("no task list was created")
        resetSequence()
        log(
            "NO TASK CREATED: the one-interval F7 release route produced no "
                .. "native projectile tasks."
        )
        log("Send the RESULT and NO TASK CREATED console lines.")
    end
    return true
end

local function monitorProjectileTasks()
    taskMonitorTicks = taskMonitorTicks + 1

    local taskLast = safeReadLong(PROJECTILE_TASK_LAST)
    local taskHandle = safeReadInt(PROJECTILE_TASK_HANDLE)
    if taskLast == nil or taskHandle == nil then
        restoreTaskUpdateGates()
        taskMonitorActive = false
        enabled = false
        resetSequence()
        log("FAILED: projectile task state became unreadable; gates restored.")
        return
    end

    if not taskUpdaterActivated and taskHandle > 0 then
        taskUpdaterActivated = true
        log(string.format(
            "SUCCESS: native Ragnarok projectile updater activated "
                .. "(last=%s handle=0x%X).",
            pointerText(taskLast),
            taskHandle
        ))
        log("Observe projectile movement/damage and send the SUCCESS line.")
    end

    if taskLast == 0 and taskHandle == 0 then
        local restored = restoreTaskUpdateGates()
        taskMonitorActive = false
        resetSequence()
        if taskUpdaterActivated then
            log(
                "VOLLEY COMPLETE: task list returned idle; task-update "
                    .. "guards restored."
            )
        else
            log(
                "FAILED: task list ended before its updater reported an "
                    .. "active handle; task-update guards restored."
            )
        end
        if not restored then
            enabled = false
        end
        return
    end

    if not taskUpdaterActivated
        and taskMonitorTicks >= TASK_ACTIVATION_TIMEOUT_CALLBACKS
    then
        local restored = restoreTaskUpdateGates()
        taskMonitorActive = false
        resetSequence()
        log(string.format(
            "FAILED: task updater did not activate within %u callbacks "
                .. "(last=%s handle=0x%X); guards restored.",
            TASK_ACTIVATION_TIMEOUT_CALLBACKS,
            pointerText(taskLast),
            taskHandle
        ))
        if not restored then
            enabled = false
        end
        return
    end

    if taskMonitorTicks >= TASK_LIFETIME_FAILSAFE_CALLBACKS then
        local restored = restoreTaskUpdateGates()
        taskMonitorActive = false
        resetSequence()
        log(string.format(
            "FAILSAFE: task monitor reached %u callbacks "
                .. "(last=%s handle=0x%X); guards restored.",
            TASK_LIFETIME_FAILSAFE_CALLBACKS,
            pointerText(taskLast),
            taskHandle
        ))
        if not restored then
            enabled = false
        end
    end
end

local function observeSequence(action, animation, index)
    if sequenceState == "waiting" then
        if action == GENERAL_ATTACK_ACTION_ID
            and animation == ID_CC and index == SLOT_CC
        then
            sequenceState = "awaiting_second"
            expectedSecondAnimation = ID_CD
            outsideSequenceTicks = 0
            log("Observed CC starter; waiting for the real second press (CD).")
        elseif action == GENERAL_ATTACK_ACTION_ID
            and animation == ID_CD and index == SLOT_CD
        then
            sequenceState = "awaiting_second"
            expectedSecondAnimation = ID_CE
            outsideSequenceTicks = 0
            log("Observed CD starter; waiting for the real second press (CE).")
        end
        return
    end

    if action == GENERAL_ATTACK_ACTION_ID
        and animation == expectedSecondAnimation
        and index == expectedSlot(expectedSecondAnimation)
        and (previousAnimation ~= animation or previousIndex ~= index)
    then
        sequenceState = "fired"
        armOneFrameRoute()
        return
    end

    if action == GENERAL_ATTACK_ACTION_ID
        and isReplacementAnimation(animation, index)
    then
        outsideSequenceTicks = 0
    else
        outsideSequenceTicks = outsideSequenceTicks + 1
        if outsideSequenceTicks >= 8 then
            resetSequence()
        end
    end
end

-- ========================================================================
-- LUA BACKEND ENTRY POINTS
-- ========================================================================

local function moduleInit()
    SetHertz(60)
    enabled = false
    waitingForRuntime = false
    initializationTicks = 0
    waitingDetailPrinted = false
    timingWaitPrinted = false
    routeArmed = false
    armedLuaCallbacks = 0
    taskMonitorActive = false
    taskMonitorTicks = 0
    taskUpdaterActivated = false
    testAttempted = false
    suspensionActive = false
    suspensionSora = 0
    suspensionOwnedMask = 0
    suspensionAnimation = 0
    suspensionIndex = -1
    suspensionOutsideTicks = 0
    suspensionLifetimeTicks = 0
    previousAnimation = nil
    previousIndex = nil
    resetSequence()

    if not ENABLE_TEST then
        log("DISABLED by ENABLE_TEST setting.")
        return
    end

    waitingForRuntime = true
    log(
        "WAITING: v8.9.5 REUSABLE PRIMED loaded; runtime validation requires "
            .. "registered action 0x25, matching Sora pointers, a nonzero "
            .. "manager/task pool, and fully idle native state."
    )
end

local function moduleFrame()
    if waitingForRuntime then
        tryFinishRuntimeInitialization()
        return
    end

    if not enabled then
        return
    end

    -- Lua callbacks occur before the following game action update. The first
    -- callback after arming proves that exactly one engine-update interval has
    -- elapsed; restore immediately to prevent duplicate projectile volleys.
    if routeArmed then
        armedLuaCallbacks = armedLuaCallbacks + 1
        finishOneFrameRoute()
        return
    end

    if suspensionActive then
        monitorSuspension()
        if not enabled then
            return
        end
    end

    if taskMonitorActive then
        monitorProjectileTasks()
        return
    end

    if TEST_ONCE_PER_LOAD and testAttempted then
        return
    end

    local sora = safeReadLong(SORA_POINTER)
    if sora == nil or sora == 0 then
        previousAnimation = nil
        previousIndex = nil
        resetSequence()
        return
    end

    local action = safeReadInt(sora + CURRENT_ACTION_ID_OFFSET, true)
    local animation = ReadByte(sora + CURRENT_ANIMATION_OFFSET, true)
    local indexValue = safeReadInt(
        sora + RESOLVED_MOTION_INDEX_OFFSET,
        true
    )
    if action == nil or animation == nil or indexValue == nil then
        return
    end
    local index = indexValue % 0x10000

    observeSequence(action, animation, index)
    previousAnimation = animation
    previousIndex = index
end

    return { name = "RagnarokProjectileV8_9_5", init = moduleInit, frame = moduleFrame, enabled = true }
end

local function buildMoveSpeed()
    -- ====================================================================
    -- BEGIN EMBEDDED CONTROLLER: SoraMoveSpeedV3
    -- ====================================================================
-- Kingdom Hearts Final Mix (Steam)
-- Sora move-speed controller v3: v13-compatible, Ragnarok-safe.
--
-- WHAT THIS BUILD CHANGES
--   * Changes only Sora's local animation-time value at Sora + 0x16C.
--   * Does not use the global animation-speed address and does not accelerate
--     enemies, projectiles, world simulation, or the whole game.
--   * Recognizes the v13 replacement visuals by their resolved MSET motion
--     pointers, not only by reused runtime IDs.
--   * Protects genuine Ragnarok action 0x25, IDs F0..F7, and every v13
--     replacement using the verified Ragnarok F7 container. Their speed is
--     always 100%, regardless of values lower in this file.
--
-- INSTALLATION
--   Disable/delete every older SoraMoveSpeed or Vortex speed Lua before using
--   this file. Run only one animation-time speed controller.
--
-- EDITING
--   Change one number in MODDED_V13_SPEED_PERCENT for the current replacement
--   moves. Change one number in ID_SPEED_PERCENT for other native animations.
--   100 = normal, 150 = 1.5x, 200 = 2x, 75 = 0.75x.
--
-- IDENTIFICATION EVIDENCE
--   "recorded" and "user-tested" labels came from the supplied gameplay and
--   console captures. Strike Raid labels came from the captured E6/E7/E8/E9/
--   EE sequence and dumped motions. Names marked provisional/inference are
--   useful working labels, not asserted internal names. All remaining IDs are
--   deliberately left unidentified rather than guessed.

-- ========================================================================
-- EDITABLE SETTINGS: CURRENT V13 REPLACEMENT VISUALS
-- ========================================================================

local ENABLE_CONTROLLER = true
local LOG_ANIMATION_CHANGES = false
local MIN_SPEED_PERCENT = 10
local MAX_SPEED_PERCENT = 400

local MODDED_V13_SPEED_PERCENT = {
    C8_RAID_THROW = 100,
    C9_RAID_THROW = 100,

    CATCH_AFTER_C8 = 100,
    CATCH_AFTER_C9 = 100,
    CATCH_AFTER_SLIDING_DASH = 100,
    GENERIC_RAID_CATCH = 100,

    SLIDING_DASH_JUDGEMENT_RAID = 100,

    CC_AERIAL_SWEEP = 100,
    CD_AERIAL_SWEEP = 100,

    GUARD_RIPPLE_DRIVE = 150,
    DODGE_ROLL_ZANTETSUKEN = 150,

    -- There is intentionally no Ragnarok setting here. Both genuine and
    -- replacement Ragnarok are hard-protected at 100%.
}

-- ========================================================================
-- EDITABLE SETTINGS: NATIVE RUNTIME IDS
-- ========================================================================
-- Context-specific v13 settings above take priority when their replacement
-- visual is actually selected. These values cover native/unmodified contexts.
-- F0..F7 are shown for completeness, but the controller ignores their values.

local ID_SPEED_PERCENT = {
    [0x00] = 100, -- Idle / base locomotion (recorded)
    [0x01] = 100, -- Locomotion and action blend transition (recorded; shared)
    [0x02] = 100, -- Walk / run / common locomotion state (recorded; shared)
    [0x03] = 100, -- Unidentified / not confirmed by supplied captures
    [0x04] = 100, -- Jump ascent (recorded)
    [0x05] = 100, -- Jump apex / transition to falling (recorded)
    [0x06] = 100, -- Falling (recorded)
    [0x07] = 100, -- Landing recovery (recorded)
    [0x08] = 100, -- Unidentified / not confirmed by supplied captures
    [0x09] = 100, -- Unidentified / not confirmed by supplied captures
    [0x0A] = 100, -- Unidentified / not confirmed by supplied captures
    [0x0B] = 100, -- Unidentified / not confirmed by supplied captures
    [0x0C] = 100, -- Unidentified / not confirmed by supplied captures
    [0x0D] = 100, -- Hang on ledge, phase 1 (user-tested)
    [0x0E] = 100, -- Hang on ledge, phase 2 (user-tested)
    [0x0F] = 100, -- Pull-up flip (user-tested)
    [0x10] = 100, -- Unidentified / not confirmed by supplied captures
    [0x11] = 100, -- Unidentified / not confirmed by supplied captures
    [0x12] = 100, -- Unidentified / not confirmed by supplied captures
    [0x13] = 100, -- Unidentified / not confirmed by supplied captures
    [0x14] = 100, -- Unidentified / not confirmed by supplied captures
    [0x15] = 100, -- Unidentified / not confirmed by supplied captures
    [0x16] = 100, -- Unidentified / not confirmed by supplied captures
    [0x17] = 100, -- Unidentified / not confirmed by supplied captures
    [0x18] = 100, -- Unidentified / not confirmed by supplied captures
    [0x19] = 100, -- Unidentified / not confirmed by supplied captures
    [0x1A] = 100, -- Unidentified / not confirmed by supplied captures
    [0x1B] = 100, -- Unidentified / not confirmed by supplied captures
    [0x1C] = 100, -- Unidentified / not confirmed by supplied captures
    [0x1D] = 100, -- Unidentified / not confirmed by supplied captures
    [0x1E] = 100, -- Unidentified / not confirmed by supplied captures
    [0x1F] = 100, -- Unidentified / not confirmed by supplied captures
    [0x20] = 100, -- Unidentified / not confirmed by supplied captures
    [0x21] = 100, -- Unidentified / not confirmed by supplied captures
    [0x22] = 100, -- Unidentified / not confirmed by supplied captures
    [0x23] = 100, -- Unidentified / not confirmed by supplied captures
    [0x24] = 100, -- Unidentified / not confirmed by supplied captures
    [0x25] = 100, -- Unidentified / not confirmed by supplied captures
    [0x26] = 100, -- Unidentified / not confirmed by supplied captures
    [0x27] = 100, -- Unidentified / not confirmed by supplied captures
    [0x28] = 100, -- Unidentified / not confirmed by supplied captures
    [0x29] = 100, -- Unidentified / not confirmed by supplied captures
    [0x2A] = 100, -- Unidentified / not confirmed by supplied captures
    [0x2B] = 100, -- Unidentified / not confirmed by supplied captures
    [0x2C] = 100, -- Unidentified / not confirmed by supplied captures
    [0x2D] = 100, -- Unidentified / not confirmed by supplied captures
    [0x2E] = 100, -- Unidentified / not confirmed by supplied captures
    [0x2F] = 100, -- Unidentified / not confirmed by supplied captures
    [0x30] = 100, -- Unidentified / not confirmed by supplied captures
    [0x31] = 100, -- Unidentified / not confirmed by supplied captures
    [0x32] = 100, -- Unidentified / not confirmed by supplied captures
    [0x33] = 100, -- Unidentified / not confirmed by supplied captures
    [0x34] = 100, -- Unidentified / not confirmed by supplied captures
    [0x35] = 100, -- Unidentified / not confirmed by supplied captures
    [0x36] = 100, -- Unidentified / not confirmed by supplied captures
    [0x37] = 100, -- Unidentified / not confirmed by supplied captures
    [0x38] = 100, -- Unidentified / not confirmed by supplied captures
    [0x39] = 100, -- Unidentified / not confirmed by supplied captures
    [0x3A] = 100, -- Unidentified / not confirmed by supplied captures
    [0x3B] = 100, -- Unidentified / not confirmed by supplied captures
    [0x3C] = 100, -- Unidentified / not confirmed by supplied captures
    [0x3D] = 100, -- Unidentified / not confirmed by supplied captures
    [0x3E] = 125, -- Use item (user-tested)
    [0x3F] = 100, -- Unidentified / not confirmed by supplied captures
    [0x40] = 100, -- Unidentified / not confirmed by supplied captures
    [0x41] = 100, -- Unidentified / not confirmed by supplied captures
    [0x42] = 100, -- Unidentified / not confirmed by supplied captures
    [0x43] = 100, -- Unidentified / not confirmed by supplied captures
    [0x44] = 100, -- Unidentified / not confirmed by supplied captures
    [0x45] = 100, -- Unidentified / not confirmed by supplied captures
    [0x46] = 100, -- Unidentified / not confirmed by supplied captures
    [0x47] = 100, -- Unidentified / not confirmed by supplied captures
    [0x48] = 100, -- Receive damage 1 (user-tested)
    [0x49] = 100, -- Receive damage 2 (user-tested)
    [0x4A] = 100, -- Receive damage from behind 1 (user-tested)
    [0x4B] = 100, -- Receive damage from behind 2 (user-tested)
    [0x4C] = 100, -- Damage-reaction family; exact direction unconfirmed
    [0x4D] = 100, -- Damage-reaction family; exact direction unconfirmed
    [0x4E] = 100, -- Airborne damage / knockback transition (observed; provisional name)
    [0x4F] = 100, -- Damage/recovery family; exact role unconfirmed
    [0x50] = 100, -- Unidentified / not confirmed by supplied captures
    [0x51] = 100, -- Unidentified / not confirmed by supplied captures
    [0x52] = 100, -- Unidentified / not confirmed by supplied captures
    [0x53] = 100, -- Unidentified / not confirmed by supplied captures
    [0x54] = 100, -- Unidentified / not confirmed by supplied captures
    [0x55] = 100, -- Unidentified / not confirmed by supplied captures
    [0x56] = 100, -- Unidentified / not confirmed by supplied captures
    [0x57] = 100, -- Unidentified / not confirmed by supplied captures
    [0x58] = 100, -- Unidentified / not confirmed by supplied captures
    [0x59] = 100, -- Unidentified / not confirmed by supplied captures
    [0x5A] = 100, -- Unidentified / not confirmed by supplied captures
    [0x5B] = 100, -- Unidentified / not confirmed by supplied captures
    [0x5C] = 100, -- Unidentified / not confirmed by supplied captures
    [0x5D] = 100, -- Unidentified / not confirmed by supplied captures
    [0x5E] = 100, -- Unidentified / not confirmed by supplied captures
    [0x5F] = 100, -- Unidentified / not confirmed by supplied captures
    [0x60] = 100, -- Unidentified / not confirmed by supplied captures
    [0x61] = 100, -- Unidentified / not confirmed by supplied captures
    [0x62] = 100, -- Unidentified / not confirmed by supplied captures
    [0x63] = 100, -- Unidentified / not confirmed by supplied captures
    [0x64] = 100, -- Unidentified / not confirmed by supplied captures
    [0x65] = 100, -- Unidentified / not confirmed by supplied captures
    [0x66] = 100, -- Unidentified / not confirmed by supplied captures
    [0x67] = 100, -- Unidentified / not confirmed by supplied captures
    [0x68] = 100, -- Unidentified / not confirmed by supplied captures
    [0x69] = 100, -- Unidentified / not confirmed by supplied captures
    [0x6A] = 100, -- Unidentified / not confirmed by supplied captures
    [0x6B] = 100, -- Unidentified / not confirmed by supplied captures
    [0x6C] = 100, -- Unidentified / not confirmed by supplied captures
    [0x6D] = 100, -- Unidentified / not confirmed by supplied captures
    [0x6E] = 75, -- Parry reaction 1 (user-tested)
    [0x6F] = 75, -- Parry reaction 2 (user-tested)
    [0x70] = 100, -- Unidentified / not confirmed by supplied captures
    [0x71] = 100, -- Unidentified / not confirmed by supplied captures
    [0x72] = 100, -- Unidentified / not confirmed by supplied captures
    [0x73] = 100, -- Unidentified / not confirmed by supplied captures
    [0x74] = 100, -- Unidentified / not confirmed by supplied captures
    [0x75] = 100, -- Unidentified / not confirmed by supplied captures
    [0x76] = 100, -- Unidentified / not confirmed by supplied captures
    [0x77] = 100, -- Unidentified / not confirmed by supplied captures
    [0x78] = 100, -- Unidentified / not confirmed by supplied captures
    [0x79] = 100, -- Unidentified / not confirmed by supplied captures
    [0x7A] = 100, -- Unidentified / not confirmed by supplied captures
    [0x7B] = 100, -- Unidentified / not confirmed by supplied captures
    [0x7C] = 100, -- Unidentified / not confirmed by supplied captures
    [0x7D] = 100, -- Unidentified / not confirmed by supplied captures
    [0x7E] = 100, -- Unidentified / not confirmed by supplied captures
    [0x7F] = 100, -- Unidentified / not confirmed by supplied captures
    [0x80] = 100, -- Unidentified / not confirmed by supplied captures
    [0x81] = 100, -- Unidentified / not confirmed by supplied captures
    [0x82] = 100, -- Unidentified / not confirmed by supplied captures
    [0x83] = 100, -- Unidentified / not confirmed by supplied captures
    [0x84] = 100, -- Unidentified / not confirmed by supplied captures
    [0x85] = 100, -- Unidentified / not confirmed by supplied captures
    [0x86] = 100, -- Unidentified / not confirmed by supplied captures
    [0x87] = 100, -- Unidentified / not confirmed by supplied captures
    [0x88] = 100, -- Unidentified / not confirmed by supplied captures
    [0x89] = 100, -- Unidentified / not confirmed by supplied captures
    [0x8A] = 100, -- Unidentified / not confirmed by supplied captures
    [0x8B] = 100, -- Unidentified / not confirmed by supplied captures
    [0x8C] = 100, -- Unidentified / not confirmed by supplied captures
    [0x8D] = 100, -- Unidentified / not confirmed by supplied captures
    [0x8E] = 100, -- Unidentified / not confirmed by supplied captures
    [0x8F] = 100, -- Unidentified / not confirmed by supplied captures
    [0x90] = 100, -- Unidentified / not confirmed by supplied captures
    [0x91] = 100, -- Unidentified / not confirmed by supplied captures
    [0x92] = 100, -- Unidentified / not confirmed by supplied captures
    [0x93] = 100, -- Unidentified / not confirmed by supplied captures
    [0x94] = 100, -- Unidentified / not confirmed by supplied captures
    [0x95] = 100, -- Unidentified / not confirmed by supplied captures
    [0x96] = 100, -- Unidentified / not confirmed by supplied captures
    [0x97] = 100, -- Unidentified / not confirmed by supplied captures
    [0x98] = 100, -- Unidentified / not confirmed by supplied captures
    [0x99] = 100, -- Unidentified / not confirmed by supplied captures
    [0x9A] = 100, -- Unidentified / not confirmed by supplied captures
    [0x9B] = 100, -- Unidentified / not confirmed by supplied captures
    [0x9C] = 100, -- Unidentified / not confirmed by supplied captures
    [0x9D] = 100, -- Unidentified / not confirmed by supplied captures
    [0x9E] = 100, -- Unidentified / not confirmed by supplied captures
    [0x9F] = 100, -- Unidentified / not confirmed by supplied captures
    [0xA0] = 100, -- Unidentified / not confirmed by supplied captures
    [0xA1] = 100, -- Unidentified / not confirmed by supplied captures
    [0xA2] = 100, -- Unidentified / not confirmed by supplied captures
    [0xA3] = 100, -- Unidentified / not confirmed by supplied captures
    [0xA4] = 100, -- Unidentified / not confirmed by supplied captures
    [0xA5] = 100, -- Unidentified / not confirmed by supplied captures
    [0xA6] = 100, -- Unidentified / not confirmed by supplied captures
    [0xA7] = 100, -- Unidentified / not confirmed by supplied captures
    [0xA8] = 100, -- Unidentified / not confirmed by supplied captures
    [0xA9] = 100, -- Unidentified / not confirmed by supplied captures
    [0xAA] = 100, -- Unidentified / not confirmed by supplied captures
    [0xAB] = 100, -- Unidentified / not confirmed by supplied captures
    [0xAC] = 100, -- Unidentified / not confirmed by supplied captures
    [0xAD] = 100, -- Unidentified / not confirmed by supplied captures
    [0xAE] = 100, -- Unidentified / not confirmed by supplied captures
    [0xAF] = 100, -- Unidentified / not confirmed by supplied captures
    [0xB0] = 100, -- Unidentified / not confirmed by supplied captures
    [0xB1] = 100, -- Unidentified / not confirmed by supplied captures
    [0xB2] = 100, -- Unidentified / not confirmed by supplied captures
    [0xB3] = 100, -- Unidentified / not confirmed by supplied captures
    [0xB4] = 100, -- Unidentified / not confirmed by supplied captures
    [0xB5] = 100, -- Unidentified / not confirmed by supplied captures
    [0xB6] = 100, -- Unidentified / not confirmed by supplied captures
    [0xB7] = 100, -- Unidentified / not confirmed by supplied captures
    [0xB8] = 100, -- Unidentified / not confirmed by supplied captures
    [0xB9] = 100, -- Unidentified / not confirmed by supplied captures
    [0xBA] = 100, -- Unidentified / not confirmed by supplied captures
    [0xBB] = 100, -- Unidentified / not confirmed by supplied captures
    [0xBC] = 100, -- Unidentified / not confirmed by supplied captures
    [0xBD] = 100, -- Unidentified / not confirmed by supplied captures
    [0xBE] = 100, -- Unidentified / not confirmed by supplied captures
    [0xBF] = 100, -- Unidentified / not confirmed by supplied captures
    [0xC0] = 100, -- Unidentified / not confirmed by supplied captures
    [0xC1] = 100, -- Unidentified / not confirmed by supplied captures
    [0xC2] = 100, -- Unidentified / not confirmed by supplied captures
    [0xC3] = 100, -- Unidentified / not confirmed by supplied captures
    [0xC4] = 100, -- Unidentified / not confirmed by supplied captures
    [0xC5] = 100, -- Unidentified / not confirmed by supplied captures
    [0xC6] = 100, -- Unidentified / not confirmed by supplied captures
    [0xC7] = 100, -- Unidentified / not confirmed by supplied captures
    [0xC8] = 100, -- Ground Combo 1 / Sonic Blade 1
    [0xC9] = 100, -- Ground Combo 2 / Sonic Blade 2
    [0xCA] = 100, -- Sonic Blade 3
    [0xCB] = 100, -- Ground Combo Finisher (Possible raid catch)
    [0xCC] = 100, -- Air Combo 1
    [0xCD] = 100, -- Air Combo 2
    [0xCE] = 100, -- Air Combo Finisher
    [0xCF] = 100, -- Slapshot
    [0xD0] = 100, -- Sliding Dash
    [0xD1] = 100, -- Hurricane Blast
    [0xD2] = 100, -- Ars Arcanum phase 1 / Blitz
    [0xD3] = 100, -- Ars Arcanum phase 2 / Vortex (recording-confirmed)
    [0xD4] = 100, -- Ars Arcanum phase 3 / Guard
    [0xD5] = 100, -- Ars Arcanum phase 4
    [0xD6] = 100, -- Ars Arcanum phase 5 / Aerial Sweep
    [0xD7] = 100, -- Ars Arcanum phase 6 / Ripple Drive
    [0xD8] = 100, -- Ars Arcanum phase 7 / Stun Impact
    [0xD9] = 100, -- Ars Arcanum phase 8 / Gravity Break
    [0xDA] = 100, -- Ars Arcanum phase 9 / Zantetsuken
    [0xDB] = 100, -- Ars Arcanum phase 10
    [0xDC] = 100, -- Ars Arcanum phase 11 / Dodge Roll (recording-confirmed)
    [0xDD] = 100, -- Ars Arcanum phase 12
    [0xDE] = 100, -- Ars Arcanum phase 13
    [0xDF] = 100, -- Ars Arcanum phase 14
    [0xE0] = 100, -- Unidentified / not confirmed by supplied captures
    [0xE1] = 100, -- Unidentified / not confirmed by supplied captures
    [0xE2] = 100, -- Unidentified / not confirmed by supplied captures
    [0xE3] = 100, -- Unidentified / not confirmed by supplied captures
    [0xE4] = 100, -- Unidentified / not confirmed by supplied captures
    [0xE5] = 100, -- Unidentified / not confirmed by supplied captures
    [0xE6] = 150, -- Strike Raid opening phase (sequence-capture confirmed)
    [0xE7] = 100, -- Strike Raid standard throw (motion-dump confirmed)
    [0xE8] = 100, -- Judgement Raid / final throw (motion-dump confirmed)
    [0xE9] = 100, -- Strike Raid throw-to-catch transition (sequence inference)
    [0xEA] = 100, -- Unidentified / not confirmed by supplied captures
    [0xEB] = 100, -- Unidentified / not confirmed by supplied captures
    [0xEC] = 100, -- Unidentified / not confirmed by supplied captures
    [0xED] = 100, -- Unidentified / not confirmed by supplied captures
    [0xEE] = 100, -- Strike Raid catch / recovery (motion-dump confirmed)
    [0xEF] = 100, -- Unidentified / not confirmed by supplied captures
    [0xF0] = 100, -- Ragnarok phase 1 (protected)
    [0xF1] = 100, -- Ragnarok phase 2 (protected)
    [0xF2] = 100, -- Ragnarok phase 3 (protected)
    [0xF3] = 100, -- Ragnarok phase 4 (protected)
    [0xF4] = 100, -- Ragnarok phase 5 (protected)
    [0xF5] = 100, -- Ragnarok phase 6 (protected)
    [0xF6] = 100, -- Ragnarok charged release phase (protected)
    [0xF7] = 100, -- Ragnarok projectile finisher (protected)
    [0xF8] = 100, -- Unidentified / not confirmed by supplied captures
    [0xF9] = 100, -- Unidentified / not confirmed by supplied captures
    [0xFA] = 100, -- Unidentified / not confirmed by supplied captures
    [0xFB] = 100, -- Unidentified / not confirmed by supplied captures
    [0xFC] = 100, -- Unidentified / not confirmed by supplied captures
    [0xFD] = 100, -- Unidentified / not confirmed by supplied captures
    [0xFE] = 100, -- Unidentified / not confirmed by supplied captures
    [0xFF] = 100, -- Unidentified / not confirmed by supplied captures
}

local ID_NAME = {
    [0x00] = "Idle / base locomotion (recorded)",
    [0x01] = "Locomotion and action blend transition (recorded; shared)",
    [0x02] = "Walk / run / common locomotion state (recorded; shared)",
    [0x04] = "Jump ascent (recorded)",
    [0x05] = "Jump apex / transition to falling (recorded)",
    [0x06] = "Falling (recorded)",
    [0x07] = "Landing recovery (recorded)",
    [0x0D] = "Hang on ledge, phase 1 (user-tested)",
    [0x0E] = "Hang on ledge, phase 2 (user-tested)",
    [0x0F] = "Pull-up flip (user-tested)",
    [0x3E] = "Use item (user-tested)",
    [0x48] = "Receive damage 1 (user-tested)",
    [0x49] = "Receive damage 2 (user-tested)",
    [0x4A] = "Receive damage from behind 1 (user-tested)",
    [0x4B] = "Receive damage from behind 2 (user-tested)",
    [0x4C] = "Damage-reaction family; exact direction unconfirmed",
    [0x4D] = "Damage-reaction family; exact direction unconfirmed",
    [0x4E] = "Airborne damage / knockback transition (observed; provisional name)",
    [0x4F] = "Damage/recovery family; exact role unconfirmed",
    [0x6E] = "Parry reaction 1 (user-tested)",
    [0x6F] = "Parry reaction 2 (user-tested)",
    [0xC8] = "Ground Combo 1 / Sonic Blade 1",
    [0xC9] = "Ground Combo 2 / Sonic Blade 2",
    [0xCA] = "Sonic Blade 3",
    [0xCB] = "Ground Combo Finisher",
    [0xCC] = "Air Combo 1",
    [0xCD] = "Air Combo 2",
    [0xCE] = "Air Combo Finisher",
    [0xCF] = "Slapshot",
    [0xD0] = "Sliding Dash",
    [0xD1] = "Hurricane Blast",
    [0xD2] = "Ars Arcanum phase 1 / Blitz",
    [0xD3] = "Ars Arcanum phase 2 / Vortex (recording-confirmed)",
    [0xD4] = "Ars Arcanum phase 3 / Guard",
    [0xD5] = "Ars Arcanum phase 4",
    [0xD6] = "Ars Arcanum phase 5 / Aerial Sweep",
    [0xD7] = "Ars Arcanum phase 6 / Ripple Drive",
    [0xD8] = "Ars Arcanum phase 7 / Stun Impact",
    [0xD9] = "Ars Arcanum phase 8 / Gravity Break",
    [0xDA] = "Ars Arcanum phase 9 / Zantetsuken",
    [0xDB] = "Ars Arcanum phase 10",
    [0xDC] = "Ars Arcanum phase 11 / Dodge Roll (recording-confirmed)",
    [0xDD] = "Ars Arcanum phase 12",
    [0xDE] = "Ars Arcanum phase 13",
    [0xDF] = "Ars Arcanum phase 14",
    [0xE6] = "Strike Raid opening phase (sequence-capture confirmed)",
    [0xE7] = "Strike Raid standard throw (motion-dump confirmed)",
    [0xE8] = "Judgement Raid / final throw (motion-dump confirmed)",
    [0xE9] = "Strike Raid throw-to-catch transition (sequence inference)",
    [0xEE] = "Strike Raid catch / recovery (motion-dump confirmed)",
    [0xF0] = "Ragnarok phase 1 (protected)",
    [0xF1] = "Ragnarok phase 2 (protected)",
    [0xF2] = "Ragnarok phase 3 (protected)",
    [0xF3] = "Ragnarok phase 4 (protected)",
    [0xF4] = "Ragnarok phase 5 (protected)",
    [0xF5] = "Ragnarok phase 6 (protected)",
    [0xF6] = "Ragnarok charged release phase (protected)",
    [0xF7] = "Ragnarok projectile finisher (protected)",
}

-- ========================================================================
-- VERIFIED STEAM RUNTIME LAYOUT
-- ========================================================================

local SORA_POINTER = 0x2537E48
local POINTER_BANK_TABLE = 0x2EE3980

local CURRENT_ACTION_ID_OFFSET = 0x70
local CURRENT_ANIMATION_OFFSET = 0x164
local RESOLVED_MOTION_INDEX_OFFSET = 0x168
local ANIMATION_TIME_OFFSET = 0x16C
local ACTIVE_POINTER_ARRAY_OFFSET = 0x1D4

local GENERAL_ATTACK_ACTION_ID = 0x02
local NATIVE_RAGNAROK_ACTION_ID = 0x25
local RAGNAROK_FIRST_ID = 0xF0
local RAGNAROK_LAST_ID = 0xF7

local ID_C8 = 0xC8
local ID_C9 = 0xC9
local ID_CA = 0xCA
local ID_CB = 0xCB
local ID_CC = 0xCC
local ID_CD = 0xCD
local ID_CE = 0xCE
local ID_D0 = 0xD0
local ID_D4 = 0xD4
local ID_DC = 0xDC

local SLOT_C8 = 0x0062
local SLOT_C9 = 0x0063
local SLOT_CA = 0x0064
local SLOT_CB = 0x0065
local SLOT_CC = 0x0066
local SLOT_CD = 0x0067
local SLOT_CE = 0x0068
local SLOT_D0 = 0x006A
local SLOT_D4 = 0x006E
local SLOT_RAGNAROK_CONTAINER = 0x006F
local SLOT_RIPPLE_GUARD_CONTAINER = 0x0071
local SLOT_ZANT_ROLL_CONTAINER = 0x0074
local SLOT_DC = 0x0075

-- ========================================================================
-- STATE AND SAFE MEMORY HELPERS
-- ========================================================================

local enabled = false
local previousSora = 0
local previousContextKey = nil
local previousContextName = nil
local observedTicks = 0
local lastTimeBeforeAdjustment = 0.0
local lastTimeAfterAdjustment = 0.0
local sequenceOrigin = nil
local invalidSettingReported = {}
local writeFailureReported = false

local function log(message)
    ConsolePrint("[SoraMoveSpeedV3] " .. message)
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

local function safeReadByte(address, absolute)
    local ok, value = pcall(ReadByte, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return value
end

local function safeReadInt(address, absolute)
    local ok, value = pcall(ReadInt, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return unsigned32(value)
end

local function safeReadLong(address, absolute)
    local ok, value = pcall(ReadLong, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return value
end

local function safeReadFloat(address, absolute)
    local ok, value = pcall(ReadFloat, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return value
end

local function safeWriteFloat(address, value, absolute)
    local ok, reason = pcall(WriteFloat, address, value, absolute)
    if not ok then
        return false, tostring(reason)
    end
    local current = safeReadFloat(address, absolute)
    if current == nil or math.abs(current - value) > 0.01 then
        return false, "animation-time write did not verify"
    end
    return true, "verified"
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
    local bankBase = safeReadLong(POINTER_BANK_TABLE + bankIndex * 8)
    if bankBase == nil or bankBase == 0 then
        return 0
    end
    return bankBase + bankOffset
end

local function getActivePointerArray(sora)
    local encoded = safeReadInt(
        sora + ACTIVE_POINTER_ARRAY_OFFSET,
        true
    )
    return resolveCompressedPointer(encoded or 0)
end

local function readMotionPointer(pointerArray, slot)
    if pointerArray == nil or pointerArray == 0 then
        return 0
    end
    return safeReadInt(pointerArray + slot * 4, true) or 0
end

local function validPercent(value)
    return value ~= nil
        and value >= MIN_SPEED_PERCENT
        and value <= MAX_SPEED_PERCENT
end

local function checkedPercent(key, value)
    if validPercent(value) then
        return value
    end
    if not invalidSettingReported[key] then
        invalidSettingReported[key] = true
        log(string.format(
            "INVALID SETTING %s=%s; using 100. Valid range is %g..%g.",
            tostring(key),
            tostring(value),
            MIN_SPEED_PERCENT,
            MAX_SPEED_PERCENT
        ))
    end
    return 100
end

local function isGenuineRagnarok(action, animation)
    return action == NATIVE_RAGNAROK_ACTION_ID
        or (animation >= RAGNAROK_FIRST_ID
            and animation <= RAGNAROK_LAST_ID)
end

local function clearSequenceOnOrdinaryExit(animation)
    if animation <= 0x0F
        or (animation >= 0x48 and animation <= 0x4F)
    then
        sequenceOrigin = nil
    end
end

-- ========================================================================
-- V13 VISUAL-CONTEXT DETECTION
-- ========================================================================

local function moddedVisualContext(sora, action, animation, slot)
    if isGenuineRagnarok(action, animation) then
        sequenceOrigin = nil
        return 100, "Protected genuine Ragnarok", true, "RAGNAROK_NATIVE"
    end

    local relevant = animation == ID_C8
        or animation == ID_C9
        or animation == ID_CA
        or animation == ID_CB
        or animation == ID_CC
        or animation == ID_CD
        or animation == ID_CE
        or animation == ID_D0
        or animation == ID_D4
        or animation == ID_DC

    if not relevant then
        clearSequenceOnOrdinaryExit(animation)
        return nil, nil, false, nil
    end

    local pointerArray = getActivePointerArray(sora)
    local currentMotion = readMotionPointer(pointerArray, slot)
    local catchMotion = readMotionPointer(pointerArray, SLOT_CB)
    local ragnarokMotion = readMotionPointer(
        pointerArray,
        SLOT_RAGNAROK_CONTAINER
    )
    local rippleMotion = readMotionPointer(
        pointerArray,
        SLOT_RIPPLE_GUARD_CONTAINER
    )
    local zantMotion = readMotionPointer(
        pointerArray,
        SLOT_ZANT_ROLL_CONTAINER
    )

    -- Pointer identity protects the replacement even if this Lua is loaded
    -- in the middle of a CD/CE F7 animation and no sequence history exists.
    if currentMotion ~= 0 and currentMotion == ragnarokMotion then
        return 100, "Protected replacement Ragnarok F7", true,
            "RAGNAROK_REPLACEMENT"
    end

    -- Fail closed if the bank is being swapped or is temporarily unreadable.
    -- In the v13 layout CE is the dedicated bridge into replacement Ragnarok F7.
    -- Protecting CD/CE while the pointer array is unavailable is safer than
    -- accidentally accelerating projectile/visual setup for one frame.
    if pointerArray == 0 and (animation == ID_CD or animation == ID_CE) then
        return 100,
            "Protected v13 air-finisher route (motion bank unavailable)",
            true,
            "RAGNAROK_REPLACEMENT_FAILSAFE"
    end

    if animation == ID_CE and slot == SLOT_CE then
        return 100, "Protected replacement Ragnarok F7 (CE fallback)", true,
            "RAGNAROK_REPLACEMENT_CE"
    end

    if currentMotion ~= 0
        and currentMotion == catchMotion
        and slot >= SLOT_C8
        and slot <= SLOT_CB
    then
        local settingKey = "GENERIC_RAID_CATCH"
        local name = "Raid catch"
        if sequenceOrigin == "C8" then
            settingKey = "CATCH_AFTER_C8"
            name = "Raid catch after C8"
        elseif sequenceOrigin == "C9" then
            settingKey = "CATCH_AFTER_C9"
            name = "Raid catch after C9"
        elseif sequenceOrigin == "D0" then
            settingKey = "CATCH_AFTER_SLIDING_DASH"
            name = "Raid catch after Sliding Dash"
        end
        return checkedPercent(
            settingKey,
            MODDED_V13_SPEED_PERCENT[settingKey]
        ), name, false, settingKey
    end

    if action == GENERAL_ATTACK_ACTION_ID
        and animation == ID_C8
        and slot == SLOT_C8
    then
        sequenceOrigin = "C8"
        return checkedPercent(
            "C8_RAID_THROW",
            MODDED_V13_SPEED_PERCENT.C8_RAID_THROW
        ), "C8 Raid throw", false, "C8_RAID_THROW"
    end

    if action == GENERAL_ATTACK_ACTION_ID
        and animation == ID_C9
        and slot == SLOT_C9
    then
        sequenceOrigin = "C9"
        return checkedPercent(
            "C9_RAID_THROW",
            MODDED_V13_SPEED_PERCENT.C9_RAID_THROW
        ), "C9 Raid throw", false, "C9_RAID_THROW"
    end

    if action == GENERAL_ATTACK_ACTION_ID
        and animation == ID_D0
        and slot == SLOT_D0
    then
        sequenceOrigin = "D0"
        return checkedPercent(
            "SLIDING_DASH_JUDGEMENT_RAID",
            MODDED_V13_SPEED_PERCENT.SLIDING_DASH_JUDGEMENT_RAID
        ), "Sliding Dash / Judgement Raid", false,
            "SLIDING_DASH_JUDGEMENT_RAID"
    end

    if action == GENERAL_ATTACK_ACTION_ID
        and animation == ID_CC
        and slot == SLOT_CC
    then
        sequenceOrigin = "CC"
        return checkedPercent(
            "CC_AERIAL_SWEEP",
            MODDED_V13_SPEED_PERCENT.CC_AERIAL_SWEEP
        ), "CC Aerial Sweep", false, "CC_AERIAL_SWEEP"
    end

    if action == GENERAL_ATTACK_ACTION_ID
        and animation == ID_CD
        and slot == SLOT_CD
    then
        sequenceOrigin = "CD"
        return checkedPercent(
            "CD_AERIAL_SWEEP",
            MODDED_V13_SPEED_PERCENT.CD_AERIAL_SWEEP
        ), "CD Aerial Sweep", false, "CD_AERIAL_SWEEP"
    end

    if animation == ID_D4
        and slot == SLOT_D4
        and currentMotion ~= 0
        and currentMotion == rippleMotion
    then
        sequenceOrigin = nil
        return checkedPercent(
            "GUARD_RIPPLE_DRIVE",
            MODDED_V13_SPEED_PERCENT.GUARD_RIPPLE_DRIVE
        ), "Guard / Ripple Drive visual", false, "GUARD_RIPPLE_DRIVE"
    end

    if animation == ID_DC
        and slot == SLOT_DC
        and currentMotion ~= 0
        and currentMotion == zantMotion
    then
        sequenceOrigin = nil
        return checkedPercent(
            "DODGE_ROLL_ZANTETSUKEN",
            MODDED_V13_SPEED_PERCENT.DODGE_ROLL_ZANTETSUKEN
        ), "Dodge Roll / Zantetsuken visual", false,
            "DODGE_ROLL_ZANTETSUKEN"
    end

    return nil, nil, false, nil
end

local function selectSpeed(sora, action, animation, slot)
    local percent, name, protected, key =
        moddedVisualContext(sora, action, animation, slot)
    if percent ~= nil then
        return percent, name, protected, key
    end

    local idKey = string.format("ID_%02X", animation)
    local idPercent = checkedPercent(
        idKey,
        ID_SPEED_PERCENT[animation] or 100
    )
    local idName = ID_NAME[animation]
        or "Unidentified runtime animation"
    return idPercent, idName, false, idKey
end

-- ========================================================================
-- LOGGING AND FRAME EVENT
-- ========================================================================

local function printContextEnd()
    if LOG_ANIMATION_CHANGES and previousContextKey ~= nil then
        log(string.format(
            "END %s ticks=%d before=%.3f after=%.3f",
            previousContextName or previousContextKey,
            observedTicks,
            lastTimeBeforeAdjustment,
            lastTimeAfterAdjustment
        ))
    end
end

local function resetObservation()
    previousContextKey = nil
    previousContextName = nil
    observedTicks = 0
    lastTimeBeforeAdjustment = 0.0
    lastTimeAfterAdjustment = 0.0
    sequenceOrigin = nil
end

local function moduleInit()
    enabled = false
    previousSora = 0
    resetObservation()
    invalidSettingReported = {}
    writeFailureReported = false

    if not ENABLE_CONTROLLER then
        log("DISABLED: ENABLE_CONTROLLER is false.")
        return
    end

    pcall(SetHertz, 60)
    enabled = true
    log(
        "READY: Sora-only v13-compatible speed control is active. "
            .. "Genuine and replacement Ragnarok are protected at 100%."
    )
    log(
        "Disable every older SoraMoveSpeed/Vortex speed Lua to prevent "
            .. "double application."
    )
end

local function moduleFrame()
    if not enabled then
        return
    end

    local sora = safeReadLong(SORA_POINTER)
    if sora == nil or sora == 0 then
        previousSora = 0
        resetObservation()
        return
    end
    if previousSora ~= 0 and sora ~= previousSora then
        printContextEnd()
        resetObservation()
    end
    previousSora = sora

    local action = safeReadInt(
        sora + CURRENT_ACTION_ID_OFFSET,
        true
    ) or 0
    local animation = safeReadByte(
        sora + CURRENT_ANIMATION_OFFSET,
        true
    )
    local slotValue = safeReadInt(
        sora + RESOLVED_MOTION_INDEX_OFFSET,
        true
    )
    local animationTime = safeReadFloat(
        sora + ANIMATION_TIME_OFFSET,
        true
    )
    if animation == nil or slotValue == nil or animationTime == nil then
        return
    end
    local slot = slotValue % 0x10000

    local percent, contextName, protected, contextKey =
        selectSpeed(sora, action, animation, slot)
    contextKey = contextKey
        or string.format("ID_%02X_SLOT_%04X", animation, slot)

    if contextKey ~= previousContextKey then
        printContextEnd()
        previousContextKey = contextKey
        previousContextName = contextName
        observedTicks = 0
        if LOG_ANIMATION_CHANGES then
            log(string.format(
                "START %s id=0x%02X slot=0x%04X action=0x%02X "
                    .. "percent=%g protected=%s time=%.3f",
                contextName or contextKey,
                animation,
                slot,
                action,
                percent,
                tostring(protected),
                animationTime
            ))
        end
    end

    observedTicks = observedTicks + 1
    lastTimeBeforeAdjustment = animationTime
    lastTimeAfterAdjustment = animationTime

    if protected or percent == 100 then
        return
    end

    local extraTime = (percent / 100) - 1.0
    local adjustedTime = animationTime + extraTime
    if adjustedTime < 0.0 then
        adjustedTime = 0.0
    end

    local written, reason = safeWriteFloat(
        sora + ANIMATION_TIME_OFFSET,
        adjustedTime,
        true
    )
    if not written then
        if not writeFailureReported then
            writeFailureReported = true
            log("DISABLED: animation-time write failed: " .. reason)
        end
        enabled = false
        return
    end
    lastTimeAfterAdjustment = adjustedTime
end

    return { name = "SoraMoveSpeedV3", init = moduleInit, frame = moduleFrame, enabled = true }
end

local MODULES = {
    buildComboVisuals(),
    buildAutoPrime(),
    buildProjectileRoute(),
    buildMoveSpeed(),
}

local function combinedLog(message)
    print("[KH1FM_SoraMoveset_AllInOneV1] " .. message)
end

local function runModuleCallback(module, callbackName)
    if not module.enabled then return end
    local callback = module[callbackName]
    if callback == nil then return end
    local ok, reason = pcall(callback)
    if not ok then
        module.enabled = false
        combinedLog(module.name .. " disabled after " .. callbackName .. " error: " .. tostring(reason))
    end
end

function _OnInit()
    combinedLog("Loading four coordinated controllers; disable their standalone copies.")
    for index = 1, #MODULES do
        runModuleCallback(MODULES[index], "init")
    end
end

function _OnFrame()
    for index = 1, #MODULES do
        runModuleCallback(MODULES[index], "frame")
    end
end
