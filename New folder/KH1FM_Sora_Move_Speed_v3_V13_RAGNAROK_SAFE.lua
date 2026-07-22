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

function _OnInit()
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

function _OnFrame()
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
