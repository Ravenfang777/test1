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

function _OnInit()
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

function _OnFrame()
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



