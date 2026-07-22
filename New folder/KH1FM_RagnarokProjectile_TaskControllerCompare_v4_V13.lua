-- Kingdom Hearts Final Mix (Steam)
-- Read-only battle-task/controller comparison for Ragnarok's projectile.
-- v4: paired with KH1FM_SoraComboVisuals_Controller_v13_BANKSAFE.lua.
--
-- FINDING THAT LED TO THIS TEST
--   The v3 full battle-entity-pool capture found no Ragnarok projectile.
--   The two entities that became active were ordinary enemies. The game's
--   executable initializes two separate 96-slot battle-task schedulers after
--   the actor pool. Their records contain callback and owner pointers, making
--   them the next layer that can hold Ragnarok's effect/attack controller.
--
-- PURPOSE
--   Compare every active task record and the first 0x100 bytes of its owner
--   during:
--
--     A. one complete genuine Ragnarok (F0 through F7 and its blast), and
--     B. one v13 aerial replacement (CC/CD into its F7 visual).
--
-- GAME-MEMORY WRITES: NONE
--   This script only reads game memory. Its only writes are the report and
--   binary capture files beside this Lua script.
--
-- TEST SETUP
--   1. Keep the working v13 BANKSAFE controller and its MSET enabled.
--   2. Disable every older diagnostic/test Lua, including EntityPoolCompare.
--   3. Add only this diagnostic beside v13 and begin from normal control.
--
-- TEST ORDER
--   1. Perform one COMPLETE genuine Ragnarok, including the final blast.
--   2. Wait for: GENUINE CAPTURE COMPLETE / PERFORM REPLACEMENT.
--   3. Perform exactly one modified CC or CD aerial starter, then press Attack
--      once more so the replacement Ragnarok F7 visual occurs.
--   4. Stop attacking and wait for REPORT SAVED.
--   5. Send back both generated files:
--        KH1FM_RagnarokProjectile_TaskControllerCompare_v4_V13_Report.txt
--        KH1FM_RagnarokProjectile_TaskControllerCompare_v4_V13_Tasks.bin

-- ========================================================================
-- SETTINGS
-- ========================================================================

local EXIT_GRACE_TICKS = 60
local FAILED_REPLACEMENT_GRACE_TICKS = 30
local MAX_GENUINE_TICKS = 1800
local MAX_REPLACEMENT_TICKS = 900

local REPORT_FILENAME =
    "KH1FM_RagnarokProjectile_TaskControllerCompare_v4_V13_Report.txt"
local CAPTURE_FILENAME =
    "KH1FM_RagnarokProjectile_TaskControllerCompare_v4_V13_Tasks.bin"

local TASK_ENTRY_LENGTH = 0x28
local TASK_COUNT = 96
local OWNER_CAPTURE_LENGTH = 0x100
local RECORD_HEADER_LENGTH = 0x38
local RECORD_LENGTH = RECORD_HEADER_LENGTH
    + TASK_ENTRY_LENGTH
    + OWNER_CAPTURE_LENGTH

-- ========================================================================
-- VERIFIED ADDRESSES FOR THE TESTED STEAM EXECUTABLE
-- ========================================================================

local SORA_POINTER = 0x2537E48

-- The native initializer supplies entry size 0x28 and count 0x60 to each
-- scheduler. These are module-relative storage addresses.
local TASK_POOLS = {
    { id = 1, name = "BATTLE_TASK_A", base = 0x2D59C00 },
    { id = 2, name = "BATTLE_TASK_B", base = 0x2D5BAF0 },
}

local TASK_FLAGS_OFFSET = 0x00
local TASK_PRIORITY_OFFSET = 0x04
local TASK_CALLBACK_OFFSET = 0x10
local TASK_OWNER_OFFSET = 0x18
local TASK_SECONDARY_CALLBACK_OFFSET = 0x20

local CURRENT_ANIMATION_OFFSET = 0x164
local RESOLVED_MOTION_INDEX_OFFSET = 0x168
local ANIMATION_TIME_OFFSET = 0x16C

local ID_IDLE = 0x00
local ID_FALL = 0x07
local ID_CC = 0xCC
local ID_CD = 0xCD
local ID_CE = 0xCE
local ID_RAGNAROK_FIRST = 0xF0
local ID_RAGNAROK_LAST = 0xF7

local SLOT_CC = 0x0066
local SLOT_CD = 0x0067
local SLOT_CE = 0x0068

-- ========================================================================
-- RUNTIME STATE
-- ========================================================================

local phase = "waiting_genuine"
local phaseTick = 0
local globalTick = 0
local frameCount = 0
local recordCount = 0
local eventCount = 0
local failedTaskReads = 0
local failedOwnerReads = 0
local genuineAttempt = 0
local replacementAttempt = 0

local sawGenuineF7 = false
local genuineOutsideTicks = 0
local sawReplacementSecond = false
local replacementOutsideTicks = 0
local replacementStartID = 0
local replacementExpectedSecondID = 0

local previousSora = 0
local previousAnimation = nil
local previousIndex = nil
local previousTime = nil
local previousTasks = {}
local waitingBaselineReady = false

local reportLines = {}
local captureFile = nil
local fileOpenFailed = false
local finished = false

-- ========================================================================
-- HELPERS
-- ========================================================================

local function diagnosticPrint(message)
    ConsolePrint("[RagnarokTaskCompareV4] " .. message)
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

local function appendLine(line)
    reportLines[#reportLines + 1] = line
end

local function readModuleInt(address)
    local ok, value = pcall(ReadInt, address)
    if not ok or value == nil then
        return 0
    end
    return unsigned32(value)
end

local function readModuleLong(address)
    local ok, value = pcall(ReadLong, address)
    if not ok or value == nil then
        return 0
    end
    return value
end

local function readResolvedIndex(sora)
    return unsigned32(ReadInt(
        sora + RESOLVED_MOTION_INDEX_OFFSET,
        true
    )) % 0x10000
end

local function actionName(animation)
    if animation >= ID_RAGNAROK_FIRST
        and animation <= ID_RAGNAROK_LAST
    then
        return string.format("GENUINE_RAGNAROK_%02X", animation)
    end
    if animation == ID_CC then
        return "CC_AERIAL_START_1"
    end
    if animation == ID_CD then
        return "CD_AERIAL_START_2"
    end
    if animation == ID_CE then
        return "CE_AERIAL_FINISHER"
    end
    if animation == ID_IDLE then
        return "IDLE"
    end
    if animation == ID_FALL then
        return "FALL_OR_AIR_RECOVERY"
    end
    return "OTHER"
end

local function isGenuineRagnarok(animation)
    return animation >= ID_RAGNAROK_FIRST
        and animation <= ID_RAGNAROK_LAST
end

local function isReplacementAerial(animation, index)
    return (animation == ID_CC and index == SLOT_CC)
        or (animation == ID_CD and index == SLOT_CD)
        or (animation == ID_CE and index == SLOT_CE)
end

local function phaseLabel()
    if phase == "capturing_genuine" then
        return string.format("GENUINE_ATTEMPT_%02d", genuineAttempt)
    end
    if phase == "capturing_replacement" then
        return string.format("REPLACEMENT_ATTEMPT_%02d", replacementAttempt)
    end
    return string.upper(phase)
end

local function phaseCode()
    if phase == "capturing_genuine" then
        return 1
    end
    if phase == "capturing_replacement" then
        return 2
    end
    return 0
end

local function taskKey(poolID, slot)
    return string.format("%d:%02d", poolID, slot)
end

local function pointerLow(pointer)
    if pointer == nil or pointer == 0 then
        return 0
    end
    return pointer % 4294967296
end

local function pointerHigh(pointer)
    if pointer == nil or pointer == 0 then
        return 0
    end
    return math.floor(pointer / 4294967296) % 4294967296
end

local function byteArrayToBinary(bytes)
    local parts = {}
    local index = 1
    while index <= #bytes do
        parts[index] = string.char((bytes[index] or 0) % 256)
        index = index + 1
    end
    return table.concat(parts)
end

local function littleEndianU32(value)
    value = unsigned32(value) % 4294967296
    local b1 = value % 256
    value = math.floor(value / 256)
    local b2 = value % 256
    value = math.floor(value / 256)
    local b3 = value % 256
    value = math.floor(value / 256)
    local b4 = value % 256
    return string.char(b1, b2, b3, b4)
end

local ZERO_OWNER_BLOCK = string.rep("\0", OWNER_CAPTURE_LENGTH)

local function makeRecordHeader(
    recordIndex,
    currentPhaseCode,
    currentPhaseTick,
    currentGlobalTick,
    soraAnimation,
    poolID,
    taskSlot,
    taskFlags,
    priority,
    callback,
    owner,
    ownerLength
)
    return littleEndianU32(recordIndex)
        .. littleEndianU32(currentPhaseCode)
        .. littleEndianU32(currentPhaseTick)
        .. littleEndianU32(currentGlobalTick)
        .. littleEndianU32(soraAnimation)
        .. littleEndianU32(poolID)
        .. littleEndianU32(taskSlot)
        .. littleEndianU32(taskFlags)
        .. littleEndianU32(priority)
        .. littleEndianU32(pointerLow(callback))
        .. littleEndianU32(pointerHigh(callback))
        .. littleEndianU32(pointerLow(owner))
        .. littleEndianU32(pointerHigh(owner))
        .. littleEndianU32(ownerLength)
end

local function openCaptureFile()
    if captureFile ~= nil then
        return true, "already open"
    end
    if fileOpenFailed then
        return false, "a prior open attempt failed"
    end
    if io == nil or io.open == nil then
        fileOpenFailed = true
        return false, "Lua file I/O is unavailable"
    end

    local path = SCRIPT_PATH .. "\\" .. CAPTURE_FILENAME
    local file, openError = io.open(path, "wb")
    if file == nil then
        fileOpenFailed = true
        return false, tostring(openError)
    end
    captureFile = file
    return true, path
end

local function closeCaptureFile()
    if captureFile ~= nil then
        captureFile:close()
        captureFile = nil
    end
end

local function writeReport()
    if io == nil or io.open == nil then
        return false, "Lua file I/O is unavailable"
    end
    local path = SCRIPT_PATH .. "\\" .. REPORT_FILENAME
    local file, openError = io.open(path, "w")
    if file == nil then
        return false, tostring(openError)
    end
    file:write(table.concat(reportLines, "\n"))
    file:write("\n")
    file:close()
    return true, path
end

local function resetAnimationHistory()
    previousAnimation = nil
    previousIndex = nil
    previousTime = nil
end

local function readTaskIdentity(pool, slot)
    local base = pool.base + slot * TASK_ENTRY_LENGTH
    local flags = readModuleInt(base + TASK_FLAGS_OFFSET) % 0x10000
    if flags == 0 then
        return nil
    end

    local identity = {
        poolID = pool.id,
        poolName = pool.name,
        slot = slot,
        base = base,
        flags = flags,
        priority = readModuleInt(base + TASK_PRIORITY_OFFSET),
        callback = readModuleLong(base + TASK_CALLBACK_OFFSET),
        owner = readModuleLong(base + TASK_OWNER_OFFSET),
        secondary = readModuleLong(base + TASK_SECONDARY_CALLBACK_OFFSET),
    }
    identity.fingerprint = string.format(
        "%04X:%08X:%X:%X:%X",
        identity.flags,
        identity.priority,
        identity.callback,
        identity.owner,
        identity.secondary
    )
    return identity
end

local function scanTaskIdentities()
    local current = {}
    for _, pool in ipairs(TASK_POOLS) do
        local slot = 0
        while slot < TASK_COUNT do
            local identity = readTaskIdentity(pool, slot)
            if identity ~= nil then
                current[taskKey(pool.id, slot)] = identity
            end
            slot = slot + 1
        end
    end
    return current
end

local function updateWaitingBaseline()
    previousTasks = scanTaskIdentities()
    waitingBaselineReady = true
end

local function formatTaskIdentity(identity)
    return string.format(
        "pool=%s pool_id=%d slot=%02d flags=0x%04X priority=0x%08X "
            .. "callback=0x%X owner=0x%X secondary=0x%X",
        identity.poolName,
        identity.poolID,
        identity.slot,
        identity.flags,
        identity.priority,
        identity.callback,
        identity.owner,
        identity.secondary
    )
end

local function captureOwner(owner)
    if owner == nil or owner == 0 then
        return ZERO_OWNER_BLOCK, 0
    end

    local ok, bytes = pcall(
        ReadArray,
        owner,
        OWNER_CAPTURE_LENGTH,
        true
    )
    if not ok or bytes == nil or #bytes < OWNER_CAPTURE_LENGTH then
        failedOwnerReads = failedOwnerReads + 1
        return ZERO_OWNER_BLOCK, 0
    end
    return byteArrayToBinary(bytes), OWNER_CAPTURE_LENGTH
end

local function captureTask(identity, soraAnimation)
    local ok, taskBytes = pcall(
        ReadArray,
        identity.base,
        TASK_ENTRY_LENGTH
    )
    if not ok or taskBytes == nil or #taskBytes < TASK_ENTRY_LENGTH then
        failedTaskReads = failedTaskReads + 1
        appendLine(string.format(
            "TASK_READ_FAILED phase=%s phase_tick=%d global_tick=%d "
                .. "pool=%s slot=%02d error=%s",
            phaseLabel(),
            phaseTick,
            globalTick,
            identity.poolName,
            identity.slot,
            tostring(taskBytes)
        ))
        return false
    end

    local ownerBinary, ownerLength = captureOwner(identity.owner)
    recordCount = recordCount + 1
    captureFile:write(makeRecordHeader(
        recordCount,
        phaseCode(),
        phaseTick,
        globalTick,
        soraAnimation,
        identity.poolID,
        identity.slot,
        identity.flags,
        identity.priority,
        identity.callback,
        identity.owner,
        ownerLength
    ))
    captureFile:write(byteArrayToBinary(taskBytes))
    captureFile:write(ownerBinary)
    return true
end

local function recordTaskFrame(soraAnimation, soraIndex, animationTime)
    if captureFile == nil then
        return
    end

    frameCount = frameCount + 1
    local firstRecord = recordCount + 1
    local recordsThisFrame = 0
    local current = scanTaskIdentities()
    local activeLabels = {}

    for key, identity in pairs(current) do
        local previous = previousTasks[key]
        if previous == nil then
            eventCount = eventCount + 1
            local line = string.format(
                "TASK_EVENT %04d phase=%s phase_tick=%d global_tick=%d "
                    .. "kind=APPEAR %s",
                eventCount,
                phaseLabel(),
                phaseTick,
                globalTick,
                formatTaskIdentity(identity)
            )
            appendLine(line)
            diagnosticPrint(line)
        elseif previous.fingerprint ~= identity.fingerprint then
            eventCount = eventCount + 1
            local line = string.format(
                "TASK_EVENT %04d phase=%s phase_tick=%d global_tick=%d "
                    .. "kind=REPLACE old_fingerprint=%s %s",
                eventCount,
                phaseLabel(),
                phaseTick,
                globalTick,
                previous.fingerprint,
                formatTaskIdentity(identity)
            )
            appendLine(line)
            diagnosticPrint(line)
        end

        activeLabels[#activeLabels + 1] = string.format(
            "%d:%02d",
            identity.poolID,
            identity.slot
        )
        if captureTask(identity, soraAnimation) then
            recordsThisFrame = recordsThisFrame + 1
        end
    end

    for key, previous in pairs(previousTasks) do
        if current[key] == nil then
            eventCount = eventCount + 1
            local line = string.format(
                "TASK_EVENT %04d phase=%s phase_tick=%d global_tick=%d "
                    .. "kind=DISAPPEAR %s",
                eventCount,
                phaseLabel(),
                phaseTick,
                globalTick,
                formatTaskIdentity(previous)
            )
            appendLine(line)
            diagnosticPrint(line)
        end
    end

    previousTasks = current
    table.sort(activeLabels)

    local activeList = "NONE"
    if #activeLabels > 0 then
        activeList = table.concat(activeLabels, ",")
    end

    appendLine(string.format(
        "FRAME %05d phase=%s phase_tick=%d global_tick=%d "
            .. "sora_animation=0x%02X name=%s sora_index=0x%04X "
            .. "sora_time=%.4f first_record=%06d record_count=%d "
            .. "active_tasks=%s",
        frameCount,
        phaseLabel(),
        phaseTick,
        globalTick,
        soraAnimation,
        actionName(soraAnimation),
        soraIndex,
        animationTime,
        firstRecord,
        recordsThisFrame,
        activeList
    ))
end

local function recordFrame(sora)
    local animation = ReadByte(sora + CURRENT_ANIMATION_OFFSET, true)
    local index = readResolvedIndex(sora)
    local animationTime = ReadFloat(sora + ANIMATION_TIME_OFFSET, true)

    local reason = "FRAME"
    if previousAnimation == nil then
        reason = "PHASE_START"
    elseif animation ~= previousAnimation then
        reason = "ID_CHANGE"
    elseif index ~= previousIndex then
        reason = "INDEX_CHANGE"
    elseif previousTime ~= nil and animationTime < previousTime - 0.5 then
        reason = "TIME_RESTART"
    end

    if reason ~= "FRAME" then
        eventCount = eventCount + 1
        local line = string.format(
            "SORA_EVENT %04d phase=%s phase_tick=%d global_tick=%d "
                .. "reason=%s animation=0x%02X name=%s time=%.4f "
                .. "index=0x%04X",
            eventCount,
            phaseLabel(),
            phaseTick,
            globalTick,
            reason,
            animation,
            actionName(animation),
            animationTime,
            index
        )
        appendLine(line)
        diagnosticPrint(line)
    end

    recordTaskFrame(animation, index, animationTime)
    previousAnimation = animation
    previousIndex = index
    previousTime = animationTime
    return animation, index
end

local function startGenuineCapture(sora)
    local opened, result = openCaptureFile()
    if not opened then
        diagnosticPrint("TASK CAPTURE FILE FAILED: " .. result)
        appendLine("CAPTURE_FILE_ERROR " .. result)
    else
        diagnosticPrint("TASK CAPTURE FILE OPEN: " .. result)
    end

    genuineAttempt = genuineAttempt + 1
    phase = "capturing_genuine"
    phaseTick = 0
    sawGenuineF7 = false
    genuineOutsideTicks = 0
    previousSora = sora
    resetAnimationHistory()
    appendLine("")
    appendLine(string.format(
        "GENUINE ATTEMPT %02d BEGIN global_tick=%d waiting_baseline=%s",
        genuineAttempt,
        globalTick,
        tostring(waitingBaselineReady)
    ))
    diagnosticPrint(string.format(
        "GENUINE CAPTURE %02d STARTED. Complete every Ragnarok prompt.",
        genuineAttempt
    ))
end

local function completeGenuineCapture()
    appendLine(string.format(
        "GENUINE ATTEMPT %02d COMPLETE ticks=%d saw_F7=%s",
        genuineAttempt,
        phaseTick,
        tostring(sawGenuineF7)
    ))
    phase = "waiting_replacement"
    phaseTick = 0
    resetAnimationHistory()
    diagnosticPrint("GENUINE CAPTURE COMPLETE.")
    diagnosticPrint(
        "PERFORM REPLACEMENT: one CC or CD starter, then press Attack once more."
    )
end

local function retryGenuine(reason)
    appendLine(string.format(
        "GENUINE ATTEMPT %02d REJECTED ticks=%d reason=%s",
        genuineAttempt,
        phaseTick,
        reason
    ))
    phase = "waiting_genuine"
    phaseTick = 0
    sawGenuineF7 = false
    genuineOutsideTicks = 0
    resetAnimationHistory()
    diagnosticPrint("GENUINE CAPTURE REJECTED: " .. reason)
    diagnosticPrint("Perform one complete genuine Ragnarok again.")
end

local function startReplacementCapture(sora, animation)
    replacementAttempt = replacementAttempt + 1
    phase = "capturing_replacement"
    phaseTick = 0
    sawReplacementSecond = false
    replacementOutsideTicks = 0
    replacementStartID = animation
    if animation == ID_CC then
        replacementExpectedSecondID = ID_CD
    else
        replacementExpectedSecondID = ID_CE
    end
    previousSora = sora
    resetAnimationHistory()
    appendLine("")
    appendLine(string.format(
        "REPLACEMENT ATTEMPT %02d BEGIN global_tick=%d "
            .. "start_ID=0x%02X expected_second_ID=0x%02X "
            .. "waiting_baseline=%s",
        replacementAttempt,
        globalTick,
        replacementStartID,
        replacementExpectedSecondID,
        tostring(waitingBaselineReady)
    ))
    diagnosticPrint(string.format(
        "REPLACEMENT CAPTURE %02d STARTED at 0x%02X. Press Attack once more.",
        replacementAttempt,
        replacementStartID
    ))
end

local function retryReplacement(reason)
    appendLine(string.format(
        "REPLACEMENT ATTEMPT %02d REJECTED ticks=%d reason=%s",
        replacementAttempt,
        phaseTick,
        reason
    ))
    phase = "waiting_replacement"
    phaseTick = 0
    sawReplacementSecond = false
    replacementOutsideTicks = 0
    replacementStartID = 0
    replacementExpectedSecondID = 0
    resetAnimationHistory()
    diagnosticPrint("REPLACEMENT CAPTURE REJECTED: " .. reason)
    diagnosticPrint("Try one CC or CD aerial starter, then one second press.")
end

local function finishAllCaptures()
    appendLine(string.format(
        "REPLACEMENT ATTEMPT %02d COMPLETE ticks=%d "
            .. "start_ID=0x%02X second_ID=0x%02X",
        replacementAttempt,
        phaseTick,
        replacementStartID,
        replacementExpectedSecondID
    ))
    appendLine("")
    appendLine("CAPTURE COMPLETE")
    appendLine(string.format(
        "SUMMARY genuine_attempts=%d replacement_attempts=%d frames=%d "
            .. "events=%d records=%d failed_task_reads=%d "
            .. "failed_owner_reads=%d record_bytes=%d",
        genuineAttempt,
        replacementAttempt,
        frameCount,
        eventCount,
        recordCount,
        failedTaskReads,
        failedOwnerReads,
        recordCount * RECORD_LENGTH
    ))

    closeCaptureFile()
    local saved, result = writeReport()
    phase = "finished"
    finished = true

    if saved then
        diagnosticPrint("REPORT SAVED: " .. result)
        diagnosticPrint("Send the TaskControllerCompare Report.txt and Tasks.bin files.")
    else
        diagnosticPrint("REPORT SAVE FAILED: " .. result)
    end
end

local function handleSoraChange(sora)
    if previousSora ~= 0 and sora ~= previousSora then
        appendLine(string.format(
            "SORA_POINTER_CHANGED phase=%s old=0x%X new=0x%X",
            phaseLabel(),
            previousSora,
            sora
        ))
        if phase == "capturing_genuine" then
            retryGenuine("Sora pointer changed; repeat in one room")
        elseif phase == "capturing_replacement" then
            retryReplacement("Sora pointer changed; repeat in one room")
        end
        previousSora = sora
        return true
    end
    previousSora = sora
    return false
end

-- ========================================================================
-- LUA BACKEND ENTRY POINTS
-- ========================================================================

function _OnInit()
    SetHertz(60)
    phase = "waiting_genuine"
    phaseTick = 0
    globalTick = 0
    frameCount = 0
    recordCount = 0
    eventCount = 0
    failedTaskReads = 0
    failedOwnerReads = 0
    genuineAttempt = 0
    replacementAttempt = 0
    previousSora = 0
    previousTasks = {}
    waitingBaselineReady = false
    reportLines = {
        "KH1FM Ragnarok projectile task-controller comparison v4 / v13",
        "Game memory writes: NONE",
        "Required companion: v13 BANKSAFE controller and its verified MSET.",
        "Do not run another diagnostic concurrently.",
        string.format(
            "Task pools: A=module+0x%08X, B=module+0x%08X; entries=%d; entry_length=0x%02X.",
            TASK_POOLS[1].base,
            TASK_POOLS[2].base,
            TASK_COUNT,
            TASK_ENTRY_LENGTH
        ),
        string.format(
            "Binary record length=0x%03X (%d bytes): 0x38 header + 0x28 task + 0x100 owner.",
            RECORD_LENGTH,
            RECORD_LENGTH
        ),
        "Header is fourteen little-endian u32 fields in this order:",
        "record_index, phase_code, phase_tick, global_tick, Sora_animation_ID, pool_id, task_slot, task_flags, priority, callback_low, callback_high, owner_low, owner_high, owner_capture_length.",
        "phase_code: 1=genuine Ragnarok, 2=v13 replacement.",
        "A zero owner_capture_length means no readable owner was available; its fixed 0x100-byte area is zero-filled.",
        "The script monitors both pools while waiting, so first-frame events are compared with the preceding idle frame.",
        "FRAME lines map each game frame to its first binary record and record count.",
        "Order: complete genuine Ragnarok, then exactly one CC/CD replacement plus second press.",
        "",
        "TRACE BEGIN",
    }
    fileOpenFailed = false
    finished = false
    resetAnimationHistory()

    diagnosticPrint("READY. READ-ONLY game-memory diagnostic.")
    diagnosticPrint("Keep v13 enabled; remove all older diagnostics/tests.")
    diagnosticPrint("Wait one second at idle, then perform complete genuine Ragnarok.")
end

function _OnFrame()
    if finished then
        return
    end

    globalTick = globalTick + 1
    local sora = ReadLong(SORA_POINTER)
    if sora == nil or sora == 0 then
        return
    end

    if handleSoraChange(sora) then
        return
    end

    local animation = ReadByte(sora + CURRENT_ANIMATION_OFFSET, true)
    local index = readResolvedIndex(sora)

    if phase == "waiting_genuine" then
        if animation == ID_RAGNAROK_FIRST then
            startGenuineCapture(sora)
        else
            updateWaitingBaseline()
            return
        end
    elseif phase == "waiting_replacement" then
        if (animation == ID_CC and index == SLOT_CC)
            or (animation == ID_CD and index == SLOT_CD)
        then
            startReplacementCapture(sora, animation)
        else
            updateWaitingBaseline()
            return
        end
    end

    phaseTick = phaseTick + 1
    animation, index = recordFrame(sora)

    if phase == "capturing_genuine" then
        if animation == ID_RAGNAROK_LAST then
            sawGenuineF7 = true
        end

        if sawGenuineF7 and not isGenuineRagnarok(animation) then
            genuineOutsideTicks = genuineOutsideTicks + 1
            if genuineOutsideTicks >= EXIT_GRACE_TICKS then
                completeGenuineCapture()
            end
        else
            genuineOutsideTicks = 0
        end

        if phase == "capturing_genuine"
            and phaseTick >= MAX_GENUINE_TICKS
        then
            retryGenuine("timeout before a complete F0-F7 sequence")
        end
        return
    end

    if phase == "capturing_replacement" then
        if animation == replacementExpectedSecondID then
            sawReplacementSecond = true
        end

        if sawReplacementSecond
            and not isReplacementAerial(animation, index)
        then
            replacementOutsideTicks = replacementOutsideTicks + 1
            if replacementOutsideTicks >= EXIT_GRACE_TICKS then
                finishAllCaptures()
            end
        elseif not sawReplacementSecond
            and not isReplacementAerial(animation, index)
        then
            replacementOutsideTicks = replacementOutsideTicks + 1
            if replacementOutsideTicks >= FAILED_REPLACEMENT_GRACE_TICKS then
                retryReplacement("second press/F7 visual was not observed")
            end
        else
            replacementOutsideTicks = 0
        end

        if phase == "capturing_replacement"
            and phaseTick >= MAX_REPLACEMENT_TICKS
        then
            retryReplacement("timeout before replacement returned to control")
        end
    end
end
