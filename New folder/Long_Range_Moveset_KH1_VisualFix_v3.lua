-- Kingdom Hearts Final Mix (Steam)
-- Sora moveset all-in-one controller v3 visual-fix revision.
--
-- Combines the validated controllers listed below. Every user-adjustable
-- balance number is collected in the single table immediately below.
-- Disable the five standalone source Lua files and both ZZ_ companion copies
-- (damage v19 and defense-window v14) while using this build.
--
-- NUMBER GUIDE
--   Damage/throw length: 1.00 = 100%, 1.50 = 150%, 0.50 = 50%.
--   Animation speed:     100 = normal, 150 = 1.5x, 75 = 0.75x.
--   Invulnerability:     start is inclusive; end is exclusive.
--
-- Change only numbers in this table, save the Lua, then fully restart KH1.
-- The v17 LOCOMOTION_PARRY_ZANT_FIX MSET is required. It retains v15's
-- verified 1.50 throw paths, restores the complete low locomotion family,
-- moves the CC Aerial Sweep container to physical motion 0x70, and installs
-- a minimal clean-exit Zantetsuken tail.

local ADJUSTMENTS = {
    damage_multiplier = {
        C8_STANDARD_RAID = 1.00,          -- ID 0xC8: ground attack 1 / standard Raid
        C9_STANDARD_RAID = 1.00,          -- ID 0xC9: ground attack 2 / standard Raid
        D0_JUDGEMENT_RAID = 3.00,         -- ID 0xD0: Sliding Dash / Judgement Raid
        REPLACEMENT_RAGNAROK = 0.50,      -- IDs 0xCD/0xCE routed to Ragnarok F7
    },

    throw_length_multiplier = {
        C8_STANDARD_RAID = 1.50,          -- ID 0xC8: 1.00 = donor's standard length
        C9_STANDARD_RAID = 1.50,          -- ID 0xC9: 1.00 = donor's standard length
        D0_JUDGEMENT_RAID = 1.50,         -- ID 0xD0: 1.00 = donor's standard length
    },

    invulnerability_frames = {
        D4_GUARD_RIPPLE = {
            start_frame = 40.0,           -- ID 0xD4: protection begins here
            end_frame = 100.0,            -- ID 0xD4: replacement ends at frame 99
        },
        DC_DODGE_ZANTETSUKEN = {
            start_frame = 49.0,           -- ID 0xDC: 12-frame protected finish
            end_frame = 61.0,             -- ID 0xDC: clean exit occurs here
        },
    },

    sora_animation_speed_percent = {
        -- Replacement visuals take priority over the reused native IDs.
        replacement_visuals = {
            C8_RAID_THROW = 100,           -- ID 0xC8: standard Raid throw
            C9_RAID_THROW = 100,           -- ID 0xC9: standard Raid throw
            CATCH_AFTER_C8 = 100,          -- Raid catch after ID 0xC8
            CATCH_AFTER_C9 = 100,          -- Raid catch after ID 0xC9
            CATCH_AFTER_SLIDING_DASH = 100,-- Raid catch after ID 0xD0
            GENERIC_RAID_CATCH = 100,      -- ID 0xCB motion used without known origin
            SLIDING_DASH_JUDGEMENT_RAID = 100, -- ID 0xD0
            CC_AERIAL_SWEEP = 100,         -- ID 0xCC: air combo 1 replacement
            CD_AERIAL_SWEEP = 100,         -- ID 0xCD: air combo 2 replacement
            GUARD_RIPPLE_DRIVE = 150,      -- ID 0xD4 replacement visual
            DODGE_ROLL_ZANTETSUKEN = 150,  -- ID 0xDC replacement visual
        },

        native_default = 100,              -- Any ID not listed below

        -- Known native runtime matches. These affect Sora's animation clock
        -- only; enemies, projectiles, and world simulation keep normal speed.
        -- Native/replacement Ragnarok IDs 0xF0..0xF7 stay safety-locked at 100.
        native_by_id = {
            [0x00] = 100, -- Idle / base locomotion (recorded)
            [0x01] = 100, -- Walk (recorded; visually routed to native Run)
            [0x02] = 100, -- Run (recorded)
            [0x04] = 100, -- Jump ascent (recorded)
            [0x05] = 100, -- Jump apex / transition to falling (recorded)
            [0x06] = 100, -- Falling (recorded)
            [0x07] = 100, -- Landing recovery (recorded)
            [0x0D] = 100, -- Hang on ledge, phase 1 (user-tested)
            [0x0E] = 100, -- Hang on ledge, phase 2 (user-tested)
            [0x0F] = 100, -- Pull-up flip (user-tested)
            [0x3E] = 125, -- Use item (user-tested)
            [0x48] = 100, -- Receive damage 1 (user-tested)
            [0x49] = 100, -- Receive damage 2 (user-tested)
            [0x4A] = 100, -- Receive damage from behind 1 (user-tested)
            [0x4B] = 100, -- Receive damage from behind 2 (user-tested)
            [0x4C] = 100, -- Damage-reaction family; direction unconfirmed
            [0x4D] = 100, -- Damage-reaction family; direction unconfirmed
            [0x4E] = 100, -- Airborne damage / knockback transition (provisional)
            [0x4F] = 100, -- Damage/recovery family; exact role unconfirmed
            [0x6E] = 75,  -- Parry reaction 1 (user-tested)
            [0x6F] = 75,  -- Parry reaction 2 (user-tested)
            [0xC8] = 100, -- Ground Combo 1 / Sonic Blade 1
            [0xC9] = 100, -- Ground Combo 2 / Sonic Blade 2
            [0xCA] = 100, -- Sonic Blade 3
            [0xCB] = 100, -- Ground Combo Finisher
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
            [0xE6] = 150, -- Strike Raid opening phase (sequence confirmed)
            [0xE7] = 100, -- Strike Raid standard throw (motion-dump confirmed)
            [0xE8] = 100, -- Judgement Raid / final throw (motion-dump confirmed)
            [0xE9] = 100, -- Strike Raid throw-to-catch transition (inference)
            [0xEE] = 100, -- Strike Raid catch / recovery (motion-dump confirmed)
        },
    },
}

local function buildComboVisuals()
    -- ====================================================================
    -- BEGIN EMBEDDED CONTROLLER: SoraComboVisualsV13_VisualFix3
    -- ====================================================================
-- Kingdom Hearts Final Mix (Steam)
-- Combined Sora combo/visual controller v13 visual-fix revision 3 with
-- bank-safe motion routing.
--
-- REQUIRED MSET (v17; retains the validated v15/v11 fixed layout)
--   xa_ex_0010_SoraComboVisuals_v17_LOCOMOTION_PARRY_ZANT_FIX.mset
--   SHA-256: 21f0eea713860e645b47942683caa75bb16085078c2c2b916ebb4b8a27387a61
--
-- LAYOUT
--   C8 ground attack 1: Raid throw -> real second press -> Raid catch
--   C9 ground attack 2: Raid throw -> real second press -> Raid catch
--   D0 Sliding Dash: Judgement Raid -> real second press -> Raid catch
--   CC air attack 1: Aerial Sweep -> real second press -> Ragnarok F7
--   CD air attack 2: Aerial Sweep -> real second press -> Ragnarok F7
--   D4 Guard: Ripple visual/effect controls plus delayed invulnerability
--   DC Dodge Roll: Zantetsuken visual plus delayed invulnerability
--   01 Walk: all three variants 0x02/0x03/0x04 use matching native Run
--            variants 0x05/0x06/0x07
--
-- No input is generated. This script never writes animation ID, resolved
-- motion index, animation time, damage, hitbox, movement, HP, or speed.
-- It permanently routes seven visual slots while the main Sora MSET is active,
-- and temporarily routes combo continuations after a genuine attack.
--
-- VERIFIED DEFENSE NOTE
--   Controlled hit tests proved that Sora runtime byte +0x00 bit 0x80 is the
--   post-hit damage-rejection flag. v13 preserves every other bit and applies
--   only 0x80 while replaced D4/DC is active. Repeated front/rear Guard and
--   Dodge Roll contacts produced no HP loss or damage animation. The bit is
--   cleared after normal exits and left to the game after any damage state.
--
-- FIXED-LAYOUT STORAGE NOTE
--   V17 no longer uses physical slot 0x03 as storage. That slot belongs to
--   KH1's low walk family and is restored byte-for-byte. The CC Aerial Sweep
--   container now occupies 0x70, whose intact Aerial Sweep core has exactly
--   enough capacity for CC's control tail. Slots 0x6F, 0x71, and 0x74 retain
--   the other fixed-layout containers. All three walk variants are routed to
--   the matching native Run variants; movement speed is untouched.

-- ========================================================================
-- EDITABLE SETTINGS
-- ========================================================================

local ENABLE_CONTROLLER = true
local LOG_DETAILS = true
local ENABLE_FULL_DEFENSE_INVULNERABILITY = true

-- Replacement-only vulnerable startup windows (animation frames).
-- The protection bit is forced ON only inside each configured [start, end)
-- interval and forced OFF before/after it.
-- Native Guard, Dodge Roll, Ripple Drive, and Zantetsuken are unchanged.
local GUARD_INVULNERABILITY_START_FRAME =
    ADJUSTMENTS.invulnerability_frames.D4_GUARD_RIPPLE.start_frame
local GUARD_INVULNERABILITY_END_FRAME =
    ADJUSTMENTS.invulnerability_frames.D4_GUARD_RIPPLE.end_frame
local DODGE_INVULNERABILITY_START_FRAME =
    ADJUSTMENTS.invulnerability_frames.DC_DODGE_ZANTETSUKEN.start_frame
local DODGE_INVULNERABILITY_END_FRAME =
    ADJUSTMENTS.invulnerability_frames.DC_DODGE_ZANTETSUKEN.end_frame

-- Replaced Guard ends at frame 99. The v17 replacement Dodge Roll exits at
-- frame 61, before the post-destination deformation. Lua owns the 12-frame
-- protection interval, so the imported native Dodge Roll trigger tail is no
-- longer required.
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
local ID_PARRY_A = 0x6E
local ID_PARRY_B = 0x6F
local PARRY_TRACE_TICKS = 300

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
local SLOT_WALK_A = 0x0002
local SLOT_WALK_B = 0x0003
local SLOT_WALK_C = 0x0004
local SLOT_RUN_A = 0x0005
local SLOT_RUN_B = 0x0006
local SLOT_RUN_C = 0x0007
local SLOT_CC_CONTAINER = 0x0070

-- Physical-record offsets relative to the canonical, never-patched slot 0x65.
-- These are the original archive offsets: v11 does not resize or move records.
local SLOT_DELTA_FROM_65 = {
    [SLOT_WALK_A] = -0x1C4F90,
    [SLOT_WALK_B] = -0x1BFAB0,
    [SLOT_WALK_C] = -0x1BA1B0,
    [SLOT_RUN_A] = -0x1B4940,
    [SLOT_RUN_B] = -0x1AFC90,
    [SLOT_RUN_C] = -0x1AAA80,
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
    [SLOT_CC_CONTAINER] = 0x4A4D0,
    [SLOT_RIPPLE_GUARD_CONTAINER] = 0x4F5E0,
    [SLOT_ZANT_ROLL_CONTAINER] = 0x62900,
    [SLOT_DC] = 0x6AFD0,
}

local EXPECTED_FRAMES = {
    [SLOT_WALK_A] = 60,
    [SLOT_WALK_B] = 60,
    [SLOT_WALK_C] = 48,
    [SLOT_RUN_A] = 36,
    [SLOT_RUN_B] = 36,
    [SLOT_RUN_C] = 36,
    [SLOT_C8] = 42,
    [SLOT_C9] = 42,
    [SLOT_CB] = 64,
    [SLOT_CC] = 40,
    [SLOT_CD] = 56,
    [SLOT_CE] = 56,
    [SLOT_D0] = 76,
    [SLOT_D4] = 54,
    [SLOT_RAGNAROK_CONTAINER] = 80,
    [SLOT_CC_CONTAINER] = 56,
    [SLOT_RIPPLE_GUARD_CONTAINER] = 100,
    [SLOT_ZANT_ROLL_CONTAINER] = 100,
    [SLOT_DC] = 38,
}

local PERMANENT_ROUTES = {
    { slot = SLOT_WALK_A, replacementSlot = SLOT_RUN_A, name = "Walk A uses Run A" },
    { slot = SLOT_WALK_B, replacementSlot = SLOT_RUN_B, name = "Walk B uses Run B" },
    { slot = SLOT_WALK_C, replacementSlot = SLOT_RUN_C, name = "Walk C uses Run C" },
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
local parryTraceRemaining = 0
local parryTraceAnimation = -1
local parryTraceSlot = -1

-- Full-animation defense protection state. The write is intentionally kept
-- independent from motion routing so a route reset cannot widen its scope.
local defenseActive = false
local defenseSora = 0
local defenseAnimation = 0
local defenseName = ""
local defenseLastFrame = -1
local defenseManagesBit = false
local defenseTimedOut = false

local function log(message)
    ConsolePrint("[SoraComboVisualsV13_VisualFix3] " .. message)
end

local function detail(message)
    if LOG_DETAILS then
        log(message)
    end
end

-- Read-only transition trace for the newly reported post-parry issue. V17
-- removes the known slot collision, but if another path remains this records
-- the exact animation ID and physical slot without requiring a diagnostic Lua.
local function updateParryTrace(animation, slot, animationFrame)
    local isParry = animation == ID_PARRY_A or animation == ID_PARRY_B
    if isParry then
        if parryTraceRemaining == 0 then
            log("PARRY TRACE START: capturing animation/slot transitions.")
        end
        parryTraceRemaining = PARRY_TRACE_TICKS
    end

    if parryTraceRemaining <= 0 then
        return
    end

    if animation ~= parryTraceAnimation or slot ~= parryTraceSlot then
        log(string.format(
            "PARRY TRACE: ID=0x%02X slot=0x%04X frame=%.1f.",
            animation,
            slot,
            animationFrame or -1
        ))
        parryTraceAnimation = animation
        parryTraceSlot = slot
    end

    parryTraceRemaining = parryTraceRemaining - 1
    if parryTraceRemaining == 0 then
        log("PARRY TRACE END.")
        parryTraceAnimation = -1
        parryTraceSlot = -1
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
    defenseManagesBit = false
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

    -- Replacement D4/DC owns the state of bit 0x80 for its configured
    -- interval, including clearing a native frame-0 bit during startup.
    local inWindow = animationFrame >= GUARD_INVULNERABILITY_START_FRAME
        and animationFrame < GUARD_INVULNERABILITY_END_FRAME
    if animation == ID_DC then
        inWindow = animationFrame >= DODGE_INVULNERABILITY_START_FRAME
            and animationFrame < DODGE_INVULNERABILITY_END_FRAME
    end
    local changed, before, after
    if inWindow then
        changed, before, after = addPostHitProtectionBit(sora)
    else
        changed, before, after = removePostHitProtectionBit(sora)
    end
    defenseManagesBit = true
    detail(string.format(
        "DEFENSE START: %s frame=%.1f flags=0x%02X->0x%02X managed=%s changed=%s",
        name,
        animationFrame,
        before,
        after,
        tostring(defenseManagesBit),
        tostring(changed)
    ))
end

local function applyDefenseWindow(sora, animation, animationFrame)
    local inWindow = animationFrame >= GUARD_INVULNERABILITY_START_FRAME
        and animationFrame < GUARD_INVULNERABILITY_END_FRAME
    if animation == ID_DC then
        inWindow = animationFrame >= DODGE_INVULNERABILITY_START_FRAME
            and animationFrame < DODGE_INVULNERABILITY_END_FRAME
    end

    if inWindow then
        addPostHitProtectionBit(sora)
    else
        -- This is intentionally unconditional with respect to the bit's
        -- origin. The game can begin replacement D4/DC with 0x80 already set;
        -- leaving it intact made the configured startup falsely invulnerable.
        removePostHitProtectionBit(sora)
    end
end

local function finishDefenseProtection(sora, nextAnimation, reason)
    local oldName = defenseName
    local oldFrame = defenseLastFrame
    local removed = false
    local before = 0
    local after = 0

    -- Damage IDs 0x48..0x4D establish the game's own post-hit protection.
    -- Never clear 0x80 after such a transition. Clear it only when returning
    -- to ordinary locomotion. Other actions are
    -- left to their own runtime controller; the game normally changes flags.
    local receivedDamage = nextAnimation >= 0x48 and nextAnimation <= 0x4D
    local ordinaryExit = nextAnimation == 0x00
        or nextAnimation == 0x01
        or nextAnimation == 0x02

    if sora ~= nil and sora ~= 0 and sora == defenseSora then
        if defenseManagesBit and ordinaryExit and not receivedDamage then
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
            if defenseManagesBit then
                removePostHitProtectionBit(sora)
            end
            defenseTimedOut = true
            log(string.format(
                "DEFENSE FAILSAFE: %s exceeded frame %d; managed bit removed.",
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

    -- V17 replaces the imported Dodge Roll tail with one nonoffensive exit
    -- event. This prevents the post-destination deformation while Lua supplies
    -- the configured protection window independently.
    if unsigned32(ReadInt(zantRoll + 0x8510, true)) ~= 0
        or unsigned32(ReadInt(zantRoll + 0x8514, true)) ~= 1
        or unsigned32(ReadInt(zantRoll + 0x8518, true)) ~= 0x8520
        or unsigned32(ReadInt(zantRoll + 0x851C, true)) ~= 0xFFFFFFFF
        or unsigned32(ReadInt(zantRoll + 0x8524, true)) ~= 1
    then
        return false, "slot 0x74 does not contain the v17 minimal Dodge tail"
    end
    local cleanExitFrame = ReadFloat(zantRoll + 0x8520, true)
    if cleanExitFrame == nil
        or cleanExitFrame < 60.9
        or cleanExitFrame > 61.1
    then
        return false, "slot 0x74 does not contain the v17 frame-61 Dodge exit"
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

    updateParryTrace(animation, slot, animationFrame)
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
    parryTraceRemaining = 0
    parryTraceAnimation = -1
    parryTraceSlot = -1
    clearSequence()
    clearDefenseState()

    if not enabled then
        disabledReason = "ENABLE_CONTROLLER is false"
        log("DISABLED by setting.")
        return
    end

    if type(GUARD_INVULNERABILITY_START_FRAME) ~= "number"
        or type(GUARD_INVULNERABILITY_END_FRAME) ~= "number"
        or type(DODGE_INVULNERABILITY_START_FRAME) ~= "number"
        or type(DODGE_INVULNERABILITY_END_FRAME) ~= "number"
        or GUARD_INVULNERABILITY_START_FRAME < 0
        or GUARD_INVULNERABILITY_END_FRAME <= GUARD_INVULNERABILITY_START_FRAME
        or DODGE_INVULNERABILITY_START_FRAME < 0
        or DODGE_INVULNERABILITY_END_FRAME <= DODGE_INVULNERABILITY_START_FRAME
        or GUARD_INVULNERABILITY_START_FRAME > MAX_DEFENSE_PROTECTION_FRAME
        or GUARD_INVULNERABILITY_END_FRAME > MAX_DEFENSE_PROTECTION_FRAME
        or DODGE_INVULNERABILITY_START_FRAME > MAX_DEFENSE_PROTECTION_FRAME
        or DODGE_INVULNERABILITY_END_FRAME > MAX_DEFENSE_PROTECTION_FRAME
    then
        enabled = false
        disabledReason = "invalid defense window"
        log("DISABLED: defense invulnerability windows are outside the allowed frame range.")
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
    log("Required asset is the v17 LOCOMOTION_PARRY_ZANT_FIX MSET with the validated v15/v11 layout.")
    log("All Walk slots 0x0002/0x0003/0x0004 route to matching Run slots 0x0005/0x0006/0x0007; movement speed is unchanged.")
    log("Aerial Sweep storage moved from native Walk slot 0x0003 to safe slot 0x0070; the walk/parry collision is removed.")
    log("Ground C8/C9: Raid throw, real second press Raid catch.")
    log("Sliding Dash: Judgement Raid, real second press Raid catch.")
    log("Air CC/CD: Aerial Sweep, real second press routes through CE to Ragnarok F7.")
    log("Guard keeps Ripple effect/control events without Ripple's offensive type-4 groups.")
    log("Dodge/Zantetsuken exits at frame 61 with only its nonoffensive exit event retained.")
    log("Post-parry transitions are logged read-only if the reported visual issue recurs.")
    log(string.format(
        "Guard/Ripple invulnerability=[%.1f, %.1f); Dodge/Zantetsuken invulnerability=[%.1f, %.1f).",
        GUARD_INVULNERABILITY_START_FRAME,
        GUARD_INVULNERABILITY_END_FRAME,
        DODGE_INVULNERABILITY_START_FRAME,
        DODGE_INVULNERABILITY_END_FRAME
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
            and defenseManagesBit
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

    return { name = "SoraComboVisualsV13_VisualFix3", init = moduleInit, frame = moduleFrame, enabled = true }
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

local function buildRaidThrowLength()
    -- ====================================================================
    -- RUNTIME THROW-LENGTH CONTROLLER
    -- ====================================================================
    -- The required v17 MSET retains v15's C8, C9, and D0 paths at 1.50x
    -- donor travel.
    -- This module validates that exact baseline, recovers the donor-space
    -- curve values, and writes the requested per-attack length. Animation
    -- frames, collision triggers, Sora movement, and genuine Strike Raid are
    -- untouched. A fresh process is required after changing these settings.

    local ENABLE_CONTROLLER = true
    local V15_BASELINE_LENGTH = 1.50
    local MIN_LENGTH_MULTIPLIER = 0.10
    local MAX_LENGTH_MULTIPLIER = 5.00

    local SORA_POINTER = 0x2537E48
    local POINTER_BANK_TABLE = 0x2EE3980
    local ACTIVE_POINTER_ARRAY_OFFSET = 0x1D4

    local TARGETS = {
        {
            slot = 0x0062,
            name = "C8 standard Raid throw",
            frames = 42,
            fcurve_count = 184,
            desired = ADJUSTMENTS.throw_length_multiplier.C8_STANDARD_RAID,
            curves = {
                { channel = 7, count = 9, start = 246, anchor = -1.5233,
                    probe_index = 8, original_probe = 617.291870 },
                { channel = 8, count = 8, start = 255, anchor = -0.1572,
                    probe_index = 5, original_probe = 565.367554 },
                { channel = 9, count = 8, start = 263, anchor = 3.1643,
                    probe_index = 7, original_probe = 550.108093 },
            },
        },
        {
            slot = 0x0063,
            name = "C9 standard Raid throw",
            frames = 42,
            fcurve_count = 184,
            desired = ADJUSTMENTS.throw_length_multiplier.C9_STANDARD_RAID,
            curves = {
                { channel = 7, count = 9, start = 246, anchor = -1.5233,
                    probe_index = 8, original_probe = 617.291870 },
                { channel = 8, count = 8, start = 255, anchor = -0.1572,
                    probe_index = 5, original_probe = 565.367554 },
                { channel = 9, count = 8, start = 263, anchor = 3.1643,
                    probe_index = 7, original_probe = 550.108093 },
            },
        },
        {
            slot = 0x006A,
            name = "D0 Judgement Raid throw",
            frames = 76,
            fcurve_count = 187,
            desired = ADJUSTMENTS.throw_length_multiplier.D0_JUDGEMENT_RAID,
            curves = {
                { channel = 7, count = 11, start = 235, anchor = -1.5233,
                    probe_index = 9, original_probe = 760.451843 },
                { channel = 8, count = 9, start = 246, anchor = -0.1572,
                    probe_index = 4, original_probe = 503.442596 },
                { channel = 9, count = 10, start = 255, anchor = 3.1643,
                    probe_index = 9, original_probe = 641.711182 },
            },
        },
    }

    local enabled = false
    local verifiedPointerArrays = {}
    local patchedRecords = {}
    local lastWaitingReason = nil

    local function log(message)
        ConsolePrint("[RaidThrowLength] " .. message)
    end

    local function unsigned32(value)
        if value == nil then return 0 end
        if value < 0 then return value + 4294967296 end
        return value
    end

    local function safeReadByte(address, absolute)
        local ok, value = pcall(ReadByte, address, absolute)
        if not ok then return nil end
        return value
    end

    local function safeReadShort(address, absolute)
        local ok, value = pcall(ReadShort, address, absolute)
        if not ok or value == nil then return nil end
        if value < 0 then value = value + 65536 end
        return value
    end

    local function safeReadInt(address, absolute)
        local ok, value = pcall(ReadInt, address, absolute)
        if not ok or value == nil then return nil end
        return unsigned32(value)
    end

    local function safeReadLong(address, absolute)
        local ok, value = pcall(ReadLong, address, absolute)
        if not ok then return nil end
        return value
    end

    local function safeReadFloat(address, absolute)
        local ok, value = pcall(ReadFloat, address, absolute)
        if not ok then return nil end
        return value
    end

    local function writeFloatVerified(address, value)
        local ok, reason = pcall(WriteFloat, address, value, true)
        if not ok then return false, tostring(reason) end
        local readback = safeReadFloat(address, true)
        if readback == nil or math.abs(readback - value) > 0.02 then
            return false, "float write did not verify"
        end
        return true, nil
    end

    local function resolveCompressedPointer(encoded)
        local value = unsigned32(encoded)
        if value == 0 then return 0 end
        if value < 0x80000000 then return value end
        local payload = value - 0x80000000
        local bankIndex = math.floor(payload / 0x2000000)
        local bankOffset = payload % 0x2000000
        local bankBase = safeReadLong(POINTER_BANK_TABLE + bankIndex * 8)
        if bankBase == nil or bankBase == 0 then return 0 end
        return bankBase + bankOffset
    end

    local function closeEnough(actual, expected, tolerance)
        return actual ~= nil and math.abs(actual - expected) <= tolerance
    end

    local function findCurve(fcurve, target, joint, expected)
        for index = 0, target.fcurve_count - 1 do
            local row = fcurve + index * 6
            local foundJoint = safeReadShort(row, true)
            local packedChannel = safeReadByte(row + 2, true)
            local count = safeReadByte(row + 3, true)
            local start = safeReadShort(row + 4, true)
            if foundJoint == joint and packedChannel ~= nil
                and packedChannel % 16 == expected.channel
            then
                if count ~= expected.count or start ~= expected.start then
                    return false
                end
                return true
            end
        end
        return false
    end

    local function prepareTarget(pointerArray, target)
        local encodedRecord = safeReadInt(pointerArray + target.slot * 4, true)
        local record = resolveCompressedPointer(encodedRecord or 0)
        if record == 0 then
            return nil, string.format("%s motion is unavailable", target.name)
        end
        if patchedRecords[record] then
            return { record = record, writes = {} }, nil
        end

        local frames = safeReadInt(record + 4, true)
        local fcurveCount = safeReadInt(record + 0x18, true)
        local fcurve = resolveCompressedPointer(
            safeReadInt(record + 0x1C, true) or 0
        )
        local keyTable = resolveCompressedPointer(
            safeReadInt(record + 0x28, true) or 0
        )
        if frames ~= target.frames or fcurveCount ~= target.fcurve_count
            or fcurve == 0 or keyTable == 0
        then
            return nil, string.format(
                "%s is not the verified v15/v17 Raid layout",
                target.name
            )
        end

        local writes = {}
        for _, curve in ipairs(target.curves) do
            if not findCurve(fcurve, target, 102, curve)
                or not findCurve(fcurve, target, 280, curve)
            then
                return nil, string.format(
                    "%s channel %d signature mismatch",
                    target.name,
                    curve.channel
                )
            end

            local firstKey = keyTable + curve.start * 16
            local probeKey = keyTable + (curve.start + curve.probe_index) * 16
            local loadedAnchor = safeReadFloat(firstKey + 4, true)
            local loadedProbe = safeReadFloat(probeKey + 4, true)
            local expectedProbe = curve.anchor
                + (curve.original_probe - curve.anchor) * V15_BASELINE_LENGTH
            if not closeEnough(loadedAnchor, curve.anchor, 0.002)
                or not closeEnough(loadedProbe, expectedProbe, 0.05)
            then
                return nil, string.format(
                    "%s is not an untouched v15/v17 1.50 path; fully restart KH1",
                    target.name
                )
            end

            -- Leave the verified v15/v17 bytes completely untouched at the
            -- default 1.50 setting. Other values are derived from that
            -- baseline once, before any write occurs.
            if math.abs(target.desired - V15_BASELINE_LENGTH) > 0.0001 then
                for keyIndex = 0, curve.count - 1 do
                    local key = keyTable + (curve.start + keyIndex) * 16
                    local loadedValue = safeReadFloat(key + 4, true)
                    local loadedTangentIn = safeReadFloat(key + 8, true)
                    local loadedTangentOut = safeReadFloat(key + 12, true)
                    if loadedValue == nil or loadedTangentIn == nil
                        or loadedTangentOut == nil
                    then
                        return nil, string.format("%s key data is unreadable", target.name)
                    end

                    local donorValue = curve.anchor
                        + (loadedValue - curve.anchor) / V15_BASELINE_LENGTH
                    local donorTangentIn = loadedTangentIn / V15_BASELINE_LENGTH
                    local donorTangentOut = loadedTangentOut / V15_BASELINE_LENGTH
                    writes[#writes + 1] = {
                        address = key + 4,
                        old = loadedValue,
                        value = curve.anchor
                            + (donorValue - curve.anchor) * target.desired,
                    }
                    writes[#writes + 1] = {
                        address = key + 8,
                        old = loadedTangentIn,
                        value = donorTangentIn * target.desired,
                    }
                    writes[#writes + 1] = {
                        address = key + 12,
                        old = loadedTangentOut,
                        value = donorTangentOut * target.desired,
                    }
                end
            end
        end
        return { record = record, writes = writes }, nil
    end

    local function applyPointerArray(pointerArray)
        local prepared = {}
        local allWrites = {}
        for _, target in ipairs(TARGETS) do
            local item, reason = prepareTarget(pointerArray, target)
            if item == nil then return false, reason end
            prepared[#prepared + 1] = item
            for _, write in ipairs(item.writes) do
                allWrites[#allWrites + 1] = write
            end
        end

        for index, write in ipairs(allWrites) do
            local ok, reason = writeFloatVerified(write.address, write.value)
            if not ok then
                for rollback = 1, index do
                    pcall(
                        WriteFloat,
                        allWrites[rollback].address,
                        allWrites[rollback].old,
                        true
                    )
                end
                return false, string.format(
                    "write %d failed and prior writes were rolled back: %s",
                    index,
                    reason
                )
            end
        end

        for _, item in ipairs(prepared) do
            patchedRecords[item.record] = true
        end
        verifiedPointerArrays[pointerArray] = true
        return true, nil
    end

    local function validateSettings()
        for _, target in ipairs(TARGETS) do
            if type(target.desired) ~= "number"
                or target.desired < MIN_LENGTH_MULTIPLIER
                or target.desired > MAX_LENGTH_MULTIPLIER
            then
                return false, string.format(
                    "%s length must be between %.2f and %.2f",
                    target.name,
                    MIN_LENGTH_MULTIPLIER,
                    MAX_LENGTH_MULTIPLIER
                )
            end
        end
        return true, nil
    end

    local function moduleInit()
        enabled = false
        verifiedPointerArrays = {}
        patchedRecords = {}
        lastWaitingReason = nil
        if not ENABLE_CONTROLLER then
            log("DISABLED by setting.")
            return
        end
        local valid, reason = validateSettings()
        if not valid then
            log("DISABLED: " .. reason .. ".")
            return
        end
        enabled = true
        log(string.format(
            "WAITING: requested lengths C8=%.2f C9=%.2f D0=%.2f; loading verified v15/v17 paths.",
            TARGETS[1].desired,
            TARGETS[2].desired,
            TARGETS[3].desired
        ))
    end

    local function moduleFrame()
        if not enabled then return end
        local sora = safeReadLong(SORA_POINTER)
        if sora == nil or sora == 0 then return end
        local pointerArray = resolveCompressedPointer(
            safeReadInt(sora + ACTIVE_POINTER_ARRAY_OFFSET, true) or 0
        )
        if pointerArray == 0 or verifiedPointerArrays[pointerArray] then return end

        local ok, reason = applyPointerArray(pointerArray)
        if ok then
            lastWaitingReason = nil
            log(string.format(
                "READY: throw lengths applied C8=%.2f C9=%.2f D0=%.2f; timing/triggers unchanged.",
                TARGETS[1].desired,
                TARGETS[2].desired,
                TARGETS[3].desired
            ))
        elseif reason ~= lastWaitingReason then
            lastWaitingReason = reason
            log("WAITING: " .. reason .. ".")
        end
    end

    return {
        name = "RaidThrowLength",
        init = moduleInit,
        frame = moduleFrame,
        enabled = true,
    }
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
--   Change animation-speed numbers only in the ADJUSTMENTS table at the top.
--   100 = normal, 150 = 1.5x, 200 = 2x, 75 = 0.75x.
--
-- IDENTIFICATION EVIDENCE
--   "recorded" and "user-tested" labels came from the supplied gameplay and
--   console captures. Strike Raid labels came from the captured E6/E7/E8/E9/
--   EE sequence and dumped motions. Names marked provisional/inference are
--   useful working labels, not asserted internal names. All remaining IDs are
--   deliberately left unidentified rather than guessed.

-- ========================================================================
-- SETTINGS ALIASES: VALUES LIVE IN THE TOP ADJUSTMENTS TABLE
-- ========================================================================

local ENABLE_CONTROLLER = true
local LOG_ANIMATION_CHANGES = false
local MIN_SPEED_PERCENT = 10
local MAX_SPEED_PERCENT = 400

local SPEED_SETTINGS = ADJUSTMENTS.sora_animation_speed_percent
local MODDED_V13_SPEED_PERCENT = SPEED_SETTINGS.replacement_visuals
local NATIVE_ID_DEFAULT_SPEED_PERCENT = SPEED_SETTINGS.native_default
local ID_SPEED_PERCENT = SPEED_SETTINGS.native_by_id

local ID_NAME = {
    [0x00] = "Idle / base locomotion (recorded)",
    [0x01] = "Walk (recorded; visually routed to native Run)",
    [0x02] = "Run (recorded)",
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
        ID_SPEED_PERCENT[animation] or NATIVE_ID_DEFAULT_SPEED_PERCENT
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

local function buildReplacementDamage()
    -- ====================================================================
    -- BEGIN EMBEDDED CONTROLLER: ReplacementDamageV19
    -- ====================================================================
-- Kingdom Hearts Final Mix (Steam)
-- Replacement-only pre-commit damage multiplier v19, validated and merged.
--
-- The executable hook runs inside the game's verified final HP-adjust
-- function before HP is clamped or death is processed. Lua changes one
-- multiplier float only while a proven replacement context is active.
--
-- Scope (defaults are shown in the top ADJUSTMENTS table):
--   * C8 and C9 standard replacement Raid: separately adjustable
--   * D0 replacement Judgement Raid: adjustable
--   * routed CD/CE replacement Ragnarok: adjustable
--   * damage to Sora: never scaled by this hook
--   * healing/nonnegative HP deltas: never scaled by this hook
--
-- The isolated v19 test passed. Start a fresh game process after adding or
-- removing this merged controller because the executable hook is process-local.

-- ========================================================================
-- SETTINGS ALIASES: VALUES LIVE IN THE TOP ADJUSTMENTS TABLE
-- ========================================================================

local ENABLE_REPLACEMENT_DAMAGE_SCALING = true
local C8_STANDARD_RAID_DAMAGE_MULTIPLIER =
    ADJUSTMENTS.damage_multiplier.C8_STANDARD_RAID
local C9_STANDARD_RAID_DAMAGE_MULTIPLIER =
    ADJUSTMENTS.damage_multiplier.C9_STANDARD_RAID
local D0_JUDGEMENT_RAID_DAMAGE_MULTIPLIER =
    ADJUSTMENTS.damage_multiplier.D0_JUDGEMENT_RAID
local REPLACEMENT_RAGNAROK_DAMAGE_MULTIPLIER =
    ADJUSTMENTS.damage_multiplier.REPLACEMENT_RAGNAROK

local RAID_COLLISION_TAIL_TICKS = 30
local RAGNAROK_TASK_START_GRACE_TICKS = 120
local REPORT_FILENAME = "KH1FM_SoraMoveset_AllInOne_v2_Damage_Report.txt"

-- ========================================================================
-- VERIFIED STEAM LAYOUT
-- ========================================================================

local SORA_POINTER = 0x2537E48
local POINTER_BANK_TABLE = 0x2EE3980

local CURRENT_ACTION_ID_OFFSET = 0x70
local CURRENT_ANIMATION_OFFSET = 0x164
local RESOLVED_INDEX_OFFSET = 0x168
local ANIMATION_TIME_OFFSET = 0x16C
local ACTIVE_POINTER_ARRAY_OFFSET = 0x1D4

local PROJECTILE_TASK_LAST = 0x2F114B8
local PROJECTILE_TASK_HANDLE = 0x2F114C8

local POINTER_RESOLVER_RVA = 0x38ADC0
local POINTER_RESOLVER_SIGNATURE = {
    0x85, 0xC9, 0x75, 0x03, 0x33, 0xC0,
    0xC3, 0xE9, 0x74, 0x01, 0x00, 0x00,
}

local FINAL_HP_ADJUST_RVA = 0x2A4920
local FINAL_HP_ADJUST_SIGNATURE = {
    0x48, 0x89, 0x74, 0x24, 0x10,
    0x48, 0x89, 0x7C, 0x24, 0x18,
    0x41, 0x56, 0x48, 0x83, 0xEC, 0x20,
}

-- At module+0x2A4930 the original routine copies the target and signed HP
-- delta into nonvolatile registers. The six-byte patch calls the private
-- padding hook and then resumes at the next untouched instruction.
local HOOK_CALLSITE_RVA = 0x2A4930
local HOOK_CALLSITE_ORIGINAL = {
    0x48, 0x8B, 0xF1, 0x44, 0x8B, 0xF2,
}
local HOOK_CALLSITE_PATCH = {
    0xE8, 0x1B, 0xA8, 0x10, 0x00, 0x90,
}

-- The final 0xB0 bytes of .nep are raw/virtual executable alignment padding
-- in the supplied Steam executable. The hook occupies 53 bytes of that
-- verified zero region. Its multiplier float is kept separately at 0x3AF1F0.
local HOOK_CAVE_RVA = 0x3AF150
local HOOK_CAVE_BYTES = {
    0x48, 0x89, 0xCE, 0x41, 0x89, 0xD6, 0x45, 0x85,
    0xF6, 0x7D, 0x29, 0x48, 0x3B, 0x0D, 0xE6, 0x8C,
    0x18, 0x02, 0x74, 0x20, 0x66, 0x41, 0x0F, 0x6E,
    0xC6, 0x0F, 0x5B, 0xC0, 0xF3, 0x0F, 0x59, 0x05,
    0x7C, 0x00, 0x00, 0x00, 0xF3, 0x44, 0x0F, 0x2D,
    0xF0, 0x45, 0x85, 0xF6, 0x75, 0x06, 0x41, 0xBE,
    0xFF, 0xFF, 0xFF, 0xFF, 0xC3,
}
local DAMAGE_MULTIPLIER_RVA = 0x3AF1F0

local ID_C8 = 0xC8
local ID_C9 = 0xC9
local ID_CD = 0xCD
local ID_CE = 0xCE
local ID_D0 = 0xD0

local SLOT_C8 = 0x0062
local SLOT_C9 = 0x0063
local SLOT_CD = 0x0067
local SLOT_CE = 0x0068
local SLOT_D0 = 0x006A
local SLOT_RAGNAROK_CONTAINER = 0x006F

-- ========================================================================
-- RUNTIME STATE
-- ========================================================================

local enabled = false
local tick = 0
local activeContext = "NONE"
local activeName = ""
local activeStartTick = 0
local lastRelevantTick = 0
local sawRagnarokTasks = false
local currentMultiplier = 1.0
local reportLines = {}
local reportDirty = false

-- ========================================================================
-- LOGGING
-- ========================================================================

local function log(message)
    ConsolePrint("[ReplacementDamageV19] " .. message)
end

local function saveReport()
    if not reportDirty then
        return
    end
    if io == nil or io.open == nil or SCRIPT_PATH == nil then
        return
    end
    local file = io.open(SCRIPT_PATH .. "\\" .. REPORT_FILENAME, "w")
    if file == nil then
        return
    end
    file:write(table.concat(reportLines, "\n"))
    file:write("\n")
    file:close()
    reportDirty = false
end

local function record(message, echo)
    reportLines[#reportLines + 1] = message
    reportDirty = true
    if echo then
        log(message)
    end
end

-- ========================================================================
-- SAFE MEMORY HELPERS
-- ========================================================================

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

local function safeReadArray(address, length, absolute)
    local ok, value = pcall(ReadArray, address, length, absolute)
    if not ok or value == nil or #value < length then
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

local function isZeroArray(bytes)
    if bytes == nil then
        return false
    end
    for index = 1, #bytes do
        if bytes[index] ~= 0 then
            return false
        end
    end
    return true
end

local function writeArrayChecked(address, bytes)
    local ok, reason = pcall(WriteArray, address, bytes)
    if not ok then
        return false, tostring(reason)
    end
    local readback = safeReadArray(address, #bytes)
    if not arraysEqual(readback, bytes) then
        return false, "write did not verify"
    end
    return true
end

local function writeMultiplier(value)
    local ok, reason = pcall(WriteFloat, DAMAGE_MULTIPLIER_RVA, value)
    if not ok then
        return false, tostring(reason)
    end
    local readback = safeReadFloat(DAMAGE_MULTIPLIER_RVA)
    if readback == nil or math.abs(readback - value) > 0.0001 then
        return false, "multiplier write did not verify"
    end
    currentMultiplier = value
    return true
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

-- ========================================================================
-- HOOK INSTALLATION
-- ========================================================================

local function validateSettings()
    local settings = {
        C8_STANDARD_RAID_DAMAGE_MULTIPLIER,
        C9_STANDARD_RAID_DAMAGE_MULTIPLIER,
        D0_JUDGEMENT_RAID_DAMAGE_MULTIPLIER,
        REPLACEMENT_RAGNAROK_DAMAGE_MULTIPLIER,
    }
    for _, value in ipairs(settings) do
        if type(value) ~= "number" or value <= 0.0 or value > 100.0 then
            return false, "damage multipliers must be numbers above 0 and no greater than 100"
        end
    end
    return true
end

local function installHook()
    if not arraysEqual(
        safeReadArray(FINAL_HP_ADJUST_RVA, #FINAL_HP_ADJUST_SIGNATURE),
        FINAL_HP_ADJUST_SIGNATURE
    ) then
        return false, "final HP-adjust function signature mismatch"
    end

    if not arraysEqual(
        safeReadArray(POINTER_RESOLVER_RVA, #POINTER_RESOLVER_SIGNATURE),
        POINTER_RESOLVER_SIGNATURE
    ) then
        return false, "compressed-pointer resolver signature mismatch"
    end

    local callsite = safeReadArray(
        HOOK_CALLSITE_RVA,
        #HOOK_CALLSITE_ORIGINAL
    )
    local cave = safeReadArray(HOOK_CAVE_RVA, #HOOK_CAVE_BYTES)

    if arraysEqual(callsite, HOOK_CALLSITE_PATCH) then
        if not arraysEqual(cave, HOOK_CAVE_BYTES) then
            return false, "hook call is present but cave signature differs"
        end
        local neutralOK, neutralReason = writeMultiplier(1.0)
        if not neutralOK then
            return false, neutralReason
        end
        return true, "verified an already-installed v19 hook"
    end

    if not arraysEqual(callsite, HOOK_CALLSITE_ORIGINAL) then
        return false, "HP-adjust hook site is not original and is not v19"
    end
    if not isZeroArray(cave) then
        return false, "private executable padding is not zero/unused"
    end

    local neutralOK, neutralReason = writeMultiplier(1.0)
    if not neutralOK then
        return false, neutralReason
    end

    local caveOK, caveReason = writeArrayChecked(HOOK_CAVE_RVA, HOOK_CAVE_BYTES)
    if not caveOK then
        return false, "hook cave install failed: " .. caveReason
    end

    local callOK, callReason = writeArrayChecked(
        HOOK_CALLSITE_RVA,
        HOOK_CALLSITE_PATCH
    )
    if not callOK then
        return false, "hook call install failed: " .. callReason
    end

    return true, "installed the v19 pre-commit hook"
end

-- ========================================================================
-- REPLACEMENT CONTEXT IDENTIFICATION
-- ========================================================================

local function getActivePointerArray(sora)
    local encoded = safeReadInt(sora + ACTIVE_POINTER_ARRAY_OFFSET, true)
    if encoded == nil then
        return 0
    end
    return resolveCompressedPointer(encoded)
end

local function currentMotionMatchesRagnarok(sora, slot)
    local pointerArray = getActivePointerArray(sora)
    if pointerArray == 0 then
        return false
    end
    local current = safeReadInt(pointerArray + slot * 4, true) or 0
    local ragnarok = safeReadInt(
        pointerArray + SLOT_RAGNAROK_CONTAINER * 4,
        true
    ) or 0
    return current ~= 0 and current == ragnarok
end

local function readRawContext(sora)
    if sora == nil or sora == 0 then
        return "NONE", "", 0.0, 0, 0, 0
    end

    local action = safeReadInt(sora + CURRENT_ACTION_ID_OFFSET, true) or 0
    local animation = safeReadByte(sora + CURRENT_ANIMATION_OFFSET, true) or 0
    local slotValue = safeReadInt(sora + RESOLVED_INDEX_OFFSET, true) or 0
    local slot = slotValue % 0x10000
    local frame = safeReadFloat(sora + ANIMATION_TIME_OFFSET, true) or 0.0

    if animation == ID_C8 and slot == SLOT_C8 then
        return "RAID_STANDARD_C8", "C8 standard replacement Raid",
            frame, animation, slot, action
    end

    if animation == ID_C9 and slot == SLOT_C9 then
        return "RAID_STANDARD_C9", "C9 standard replacement Raid",
            frame, animation, slot, action
    end

    if animation == ID_D0 and slot == SLOT_D0 then
        return "RAID_JUDGEMENT_D0", "D0 replacement Judgement Raid",
            frame, animation, slot, action
    end

    local possibleRagnarok = (animation == ID_CD and slot == SLOT_CD)
        or (animation == ID_CE and slot == SLOT_CE)
    if possibleRagnarok and currentMotionMatchesRagnarok(sora, slot) then
        return "RAGNAROK_REPLACEMENT", "routed replacement Ragnarok",
            frame, animation, slot, action
    end

    return "NONE", "", frame, animation, slot, action
end

local function projectileTasksActive()
    local last = safeReadLong(PROJECTILE_TASK_LAST) or 0
    local handle = safeReadInt(PROJECTILE_TASK_HANDLE) or 0
    return last ~= 0 or handle ~= 0
end

local function multiplierForContext(context)
    if context == "RAID_STANDARD_C8" then
        return C8_STANDARD_RAID_DAMAGE_MULTIPLIER
    end
    if context == "RAID_STANDARD_C9" then
        return C9_STANDARD_RAID_DAMAGE_MULTIPLIER
    end
    if context == "RAID_JUDGEMENT_D0" then
        return D0_JUDGEMENT_RAID_DAMAGE_MULTIPLIER
    end
    if context == "RAGNAROK_REPLACEMENT" then
        return REPLACEMENT_RAGNAROK_DAMAGE_MULTIPLIER
    end
    return 1.0
end

local function setContextMultiplier(context)
    local value = multiplierForContext(context)
    if math.abs(value - currentMultiplier) <= 0.0001 then
        return true
    end
    local ok, reason = writeMultiplier(value)
    if not ok then
        record("FAILSAFE: could not set multiplier: " .. reason, true)
        enabled = false
        pcall(WriteFloat, DAMAGE_MULTIPLIER_RVA, 1.0)
        return false
    end
    return true
end

local function beginContext(context, name, frame, animation, slot, action)
    activeContext = context
    activeName = name
    activeStartTick = tick
    lastRelevantTick = tick
    sawRagnarokTasks = context == "RAGNAROK_REPLACEMENT"
        and projectileTasksActive()

    if not setContextMultiplier(context) then
        return
    end

    record(string.format(
        "CONTEXT START tick=%d context=%s name=%s multiplier=%.3f "
            .. "action=0x%02X animation=0x%02X slot=0x%04X frame=%.2f tasks=%s",
        tick,
        context,
        name,
        currentMultiplier,
        action,
        animation,
        slot,
        frame,
        tostring(projectileTasksActive())
    ), true)
    saveReport()
end

local function finishContext(reason)
    if activeContext == "NONE" then
        return
    end

    local oldContext = activeContext
    local oldName = activeName
    local duration = tick - activeStartTick + 1

    activeContext = "NONE"
    activeName = ""
    activeStartTick = 0
    lastRelevantTick = 0
    sawRagnarokTasks = false

    if not setContextMultiplier("NONE") then
        return
    end

    record(string.format(
        "CONTEXT END tick=%d context=%s name=%s duration_ticks=%d "
            .. "multiplier=%.3f reason=%s",
        tick,
        oldContext,
        oldName,
        duration,
        currentMultiplier,
        reason
    ), true)
    saveReport()
end

local function updateContext(sora)
    local rawContext, rawName, frame, animation, slot, action =
        readRawContext(sora)
    local tasksActive = projectileTasksActive()

    if activeContext == "NONE" then
        if rawContext ~= "NONE" then
            beginContext(
                rawContext,
                rawName,
                frame,
                animation,
                slot,
                action
            )
        end
        return
    end

    if rawContext == activeContext then
        lastRelevantTick = tick
        if activeContext == "RAGNAROK_REPLACEMENT" and tasksActive then
            sawRagnarokTasks = true
        end
        return
    end

    if activeContext == "RAGNAROK_REPLACEMENT" then
        if tasksActive then
            sawRagnarokTasks = true
            lastRelevantTick = tick
            return
        end

        if sawRagnarokTasks then
            finishContext("replacement Ragnarok task list became idle")
        elseif tick - activeStartTick > RAGNAROK_TASK_START_GRACE_TICKS then
            finishContext("replacement Ragnarok task list did not activate")
        else
            return
        end
    elseif rawContext ~= "NONE" then
        finishContext("another replacement context began")
    elseif tick - lastRelevantTick > RAID_COLLISION_TAIL_TICKS then
        finishContext("replacement Raid collision tail ended")
    else
        return
    end

    if enabled and rawContext ~= "NONE" then
        beginContext(
            rawContext,
            rawName,
            frame,
            animation,
            slot,
            action
        )
    end
end

-- ========================================================================
-- PUBLIC CALLBACKS
-- ========================================================================

local function moduleInit()
    enabled = false
    tick = 0
    activeContext = "NONE"
    activeName = ""
    activeStartTick = 0
    lastRelevantTick = 0
    sawRagnarokTasks = false
    currentMultiplier = 1.0
    reportLines = {}
    reportDirty = false

    record("KH1FM all-in-one v3 replacement damage report", false)
    record(string.format(
        "Requested multipliers: C8=%.3f C9=%.3f D0_judgement=%.3f replacement_ragnarok=%.3f",
        C8_STANDARD_RAID_DAMAGE_MULTIPLIER,
        C9_STANDARD_RAID_DAMAGE_MULTIPLIER,
        D0_JUDGEMENT_RAID_DAMAGE_MULTIPLIER,
        REPLACEMENT_RAGNAROK_DAMAGE_MULTIPLIER
    ), false)

    if not ENABLE_REPLACEMENT_DAMAGE_SCALING then
        record("DISABLED: ENABLE_REPLACEMENT_DAMAGE_SCALING is false.", true)
        saveReport()
        return
    end

    local settingsOK, settingsReason = validateSettings()
    if not settingsOK then
        record("DISABLED: " .. settingsReason .. ".", true)
        saveReport()
        return
    end

    pcall(SetHertz, 60)
    local hookOK, hookReason = installHook()
    if not hookOK then
        record("DISABLED: " .. hookReason .. ".", true)
        saveReport()
        return
    end

    enabled = true
    record("READY: " .. hookReason .. "; neutral multiplier is 1.000.", true)
    record(
        "The multiplier is applied before HP clamp/death and never scales damage to Sora or healing.",
        true
    )
    saveReport()
end

local function moduleFrame()
    if not enabled then
        return
    end

    tick = tick + 1
    local sora = safeReadLong(SORA_POINTER) or 0
    if sora == 0 then
        if activeContext ~= "NONE" then
            finishContext("Sora pointer became unavailable")
        elseif math.abs(currentMultiplier - 1.0) > 0.0001 then
            local ok = writeMultiplier(1.0)
            if not ok then
                enabled = false
            end
        end
        return
    end

    updateContext(sora)
end

    local function moduleFailSafe(reason)
        enabled = false
        activeContext = "NONE"
        activeName = ""
        activeStartTick = 0
        lastRelevantTick = 0
        sawRagnarokTasks = false
        pcall(WriteFloat, DAMAGE_MULTIPLIER_RVA, 1.0)
        currentMultiplier = 1.0
        record("DISABLED after combined-controller error: " .. tostring(reason) .. "; multiplier reset to 1.000.", true)
        saveReport()
    end

    return { name = "ReplacementDamageV19", init = moduleInit, frame = moduleFrame, fail = moduleFailSafe, enabled = true }
end

local MODULES = {
    buildComboVisuals(),
    buildRaidThrowLength(),
    buildAutoPrime(),
    buildProjectileRoute(),
    buildMoveSpeed(),
    -- Keep damage last, matching the validated standalone ZZ_ execution
    -- order after visual routing and projectile task-state updates.
    buildReplacementDamage(),
}

local function combinedLog(message)
    print("[KH1FM_SoraMoveset_AllInOneV3] " .. message)
end

local function runModuleCallback(module, callbackName)
    if not module.enabled then return end
    local callback = module[callbackName]
    if callback == nil then return end
    local ok, reason = pcall(callback)
    if not ok then
        if module.fail ~= nil then
            pcall(module.fail, reason)
        end
        module.enabled = false
        combinedLog(module.name .. " disabled after " .. callbackName .. " error: " .. tostring(reason))
    end
end

function _OnInit()
    combinedLog("Loading six coordinated controllers; disable their standalone copies.")
    for index = 1, #MODULES do
        runModuleCallback(MODULES[index], "init")
    end
end

function _OnFrame()
    for index = 1, #MODULES do
        runModuleCallback(MODULES[index], "frame")
    end
end
