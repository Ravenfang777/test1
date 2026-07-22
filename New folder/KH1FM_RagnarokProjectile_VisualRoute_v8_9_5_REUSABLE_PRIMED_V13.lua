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

function _OnInit()
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

function _OnFrame()
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
