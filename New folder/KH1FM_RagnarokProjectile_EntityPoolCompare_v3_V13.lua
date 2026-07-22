-- Kingdom Hearts Final Mix (Steam)
-- Read-only battle-entity-pool comparison for Ragnarok's projectile.
-- v3: paired with KH1FM_SoraComboVisuals_Controller_v13_BANKSAFE.lua.
--
-- PURPOSE
--   The copied F7 motion supplies Ragnarok's pose, but the genuine attack's
--   blast is created by a separate battle entity/controller. This diagnostic
--   compares every occupied entry in the game's 96-slot battle-entity pool
--   during:
--
--     A. one complete genuine Ragnarok (F0 through F7 and its blast), and
--     B. one v13 aerial replacement (CC/CD into its F7 visual).
--
-- GAME-MEMORY WRITES: NONE
--   This script only reads game memory. Its only writes are the report and
--   binary entry-capture files beside this Lua script.
--
-- TEST SETUP
--   1. Keep the working v13 BANKSAFE controller and its MSET enabled.
--   2. Remove/disable all older diagnostics and test Lua files.
--   3. Add only this diagnostic beside v13.
--
-- TEST ORDER
--   1. Perform one COMPLETE genuine Ragnarok, including the final blast.
--   2. Wait for: GENUINE CAPTURE COMPLETE / PERFORM REPLACEMENT.
--   3. Perform one modified CC or CD aerial starter, then press Attack a
--      second time so the replacement Ragnarok F7 visual occurs.
--   4. Stop attacking and wait for REPORT SAVED.
--   5. Send back both generated files:
--        KH1FM_RagnarokProjectile_EntityPoolCompare_v3_V13_Report.txt
--        KH1FM_RagnarokProjectile_EntityPoolCompare_v3_V13_Entries.bin

-- ========================================================================
-- SETTINGS
-- ========================================================================

local EXIT_GRACE_TICKS = 60
local FAILED_REPLACEMENT_GRACE_TICKS = 30
local MAX_GENUINE_TICKS = 1800
local MAX_REPLACEMENT_TICKS = 900

local REPORT_FILENAME =
    "KH1FM_RagnarokProjectile_EntityPoolCompare_v3_V13_Report.txt"
local CAPTURE_FILENAME =
    "KH1FM_RagnarokProjectile_EntityPoolCompare_v3_V13_Entries.bin"

-- Each binary record is a 32-byte little-endian header followed by one
-- complete 0x4B0-byte pool entry. See the report header for field order.
local RECORD_HEADER_LENGTH = 0x20
local ENTITY_ENTRY_LENGTH = 0x4B0
local RECORD_LENGTH = RECORD_HEADER_LENGTH + ENTITY_ENTRY_LENGTH

-- ========================================================================
-- VERIFIED ADDRESSES FOR THE TESTED STEAM EXECUTABLE
-- ========================================================================

local SORA_POINTER = 0x2537E48

-- Module-relative battle-entity pool. The executable iterates exactly 96
-- entries from 0x2D372A0 to 0x2D534A0, stepping by 0x4B0.
local ENTITY_POOL_BASE = 0x2D372A0
local ENTITY_POOL_COUNT = 96
local ENTITY_POOL_FLAGS_OFFSET = 0x374

-- Useful fields inside an entity entry, recorded in APPEAR/DISAPPEAR lines.
local ENTITY_OBJECT_STATE_OFFSET = 0x000
local ENTITY_TYPE_OFFSET = 0x006
local ENTITY_RESOURCE_OFFSET = 0x130
local ENTITY_ANIMATION_OFFSET = 0x164
local ENTITY_MOTION_INDEX_OFFSET = 0x168

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
local failedEntryReads = 0
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
local previousActive = {}
local lastKnownEntity = {}

local reportLines = {}
local captureFile = nil
local fileOpenFailed = false
local finished = false

-- ========================================================================
-- HELPERS
-- ========================================================================

local function diagnosticPrint(message)
    ConsolePrint("[RagnarokEntityPoolCompareV3] " .. message)
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

local function hasBit(value, bitValue)
    return math.floor(unsigned32(value) / bitValue) % 2 == 1
end

local function isOccupied(flags)
    -- Native pool iteration accepts bit 0 and rejects bit 1.
    return hasBit(flags, 1) and not hasBit(flags, 2)
end

local function readModuleInt(address)
    local ok, value = pcall(ReadInt, address)
    if not ok or value == nil then
        return 0
    end
    return unsigned32(value)
end

local function readModuleByte(address)
    local ok, value = pcall(ReadByte, address)
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

local function makeRecordHeader(
    recordIndex,
    currentPhaseCode,
    currentPhaseTick,
    currentGlobalTick,
    soraAnimation,
    poolSlot,
    poolFlags
)
    return littleEndianU32(recordIndex)
        .. littleEndianU32(currentPhaseCode)
        .. littleEndianU32(currentPhaseTick)
        .. littleEndianU32(currentGlobalTick)
        .. littleEndianU32(soraAnimation)
        .. littleEndianU32(poolSlot)
        .. littleEndianU32(poolFlags)
        .. littleEndianU32(ENTITY_ENTRY_LENGTH)
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

local function resetPreviousState()
    previousAnimation = nil
    previousIndex = nil
    previousTime = nil
    previousActive = {}
    lastKnownEntity = {}
end

local function entitySummary(slot, flags)
    local base = ENTITY_POOL_BASE + slot * ENTITY_ENTRY_LENGTH
    local summary = {
        slot = slot,
        flags = unsigned32(flags),
        objectState = readModuleInt(base + ENTITY_OBJECT_STATE_OFFSET),
        entityType = readModuleByte(base + ENTITY_TYPE_OFFSET),
        resource = readModuleInt(base + ENTITY_RESOURCE_OFFSET),
        animation = readModuleByte(base + ENTITY_ANIMATION_OFFSET),
        motionIndex = readModuleInt(base + ENTITY_MOTION_INDEX_OFFSET)
            % 0x10000,
    }
    return summary
end

local function formatEntitySummary(summary)
    return string.format(
        "slot=%02d flags=0x%08X state=0x%08X type=0x%02X "
            .. "resource=0x%08X animation=0x%02X index=0x%04X",
        summary.slot,
        summary.flags,
        summary.objectState,
        summary.entityType,
        summary.resource,
        summary.animation,
        summary.motionIndex
    )
end

local function recordPoolFrame(soraAnimation, soraIndex, animationTime)
    if captureFile == nil then
        return
    end

    frameCount = frameCount + 1
    local firstRecord = recordCount + 1
    local recordsThisFrame = 0
    local activeNow = {}
    local activeSlotLabels = {}

    local slot = 0
    while slot < ENTITY_POOL_COUNT do
        local base = ENTITY_POOL_BASE + slot * ENTITY_ENTRY_LENGTH
        local flags = readModuleInt(base + ENTITY_POOL_FLAGS_OFFSET)

        if isOccupied(flags) then
            activeNow[slot] = true
            activeSlotLabels[#activeSlotLabels + 1] = string.format("%02d", slot)

            local summary = entitySummary(slot, flags)
            lastKnownEntity[slot] = summary
            if not previousActive[slot] then
                eventCount = eventCount + 1
                local eventLine = string.format(
                    "ENTITY_EVENT %04d phase=%s phase_tick=%d global_tick=%d "
                        .. "kind=APPEAR %s",
                    eventCount,
                    phaseLabel(),
                    phaseTick,
                    globalTick,
                    formatEntitySummary(summary)
                )
                appendLine(eventLine)
                diagnosticPrint(eventLine)
            end

            local ok, entry = pcall(
                ReadArray,
                base,
                ENTITY_ENTRY_LENGTH
            )
            if ok and entry ~= nil and #entry >= ENTITY_ENTRY_LENGTH then
                recordCount = recordCount + 1
                recordsThisFrame = recordsThisFrame + 1
                captureFile:write(makeRecordHeader(
                    recordCount,
                    phaseCode(),
                    phaseTick,
                    globalTick,
                    soraAnimation,
                    slot,
                    flags
                ))
                captureFile:write(byteArrayToBinary(entry))
            else
                failedEntryReads = failedEntryReads + 1
                appendLine(string.format(
                    "ENTRY_READ_FAILED phase=%s phase_tick=%d global_tick=%d "
                        .. "slot=%02d error=%s",
                    phaseLabel(),
                    phaseTick,
                    globalTick,
                    slot,
                    tostring(entry)
                ))
            end
        end

        slot = slot + 1
    end

    slot = 0
    while slot < ENTITY_POOL_COUNT do
        if previousActive[slot] and not activeNow[slot] then
            eventCount = eventCount + 1
            local prior = lastKnownEntity[slot]
            local description = "slot=" .. string.format("%02d", slot)
            if prior ~= nil then
                description = formatEntitySummary(prior)
            end
            local eventLine = string.format(
                "ENTITY_EVENT %04d phase=%s phase_tick=%d global_tick=%d "
                    .. "kind=DISAPPEAR %s",
                eventCount,
                phaseLabel(),
                phaseTick,
                globalTick,
                description
            )
            appendLine(eventLine)
            diagnosticPrint(eventLine)
        end
        slot = slot + 1
    end

    previousActive = activeNow

    local slotList = "NONE"
    if #activeSlotLabels > 0 then
        slotList = table.concat(activeSlotLabels, ",")
    end

    appendLine(string.format(
        "FRAME %05d phase=%s phase_tick=%d global_tick=%d "
            .. "sora_animation=0x%02X name=%s sora_index=0x%04X "
            .. "sora_time=%.4f first_record=%06d record_count=%d "
            .. "active_slots=%s",
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
        slotList
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

    recordPoolFrame(animation, index, animationTime)

    previousAnimation = animation
    previousIndex = index
    previousTime = animationTime

    return animation, index
end

local function startGenuineCapture(sora)
    local opened, result = openCaptureFile()
    if not opened then
        diagnosticPrint("ENTRY CAPTURE FILE FAILED: " .. result)
        appendLine("CAPTURE_FILE_ERROR " .. result)
    else
        diagnosticPrint("ENTRY CAPTURE FILE OPEN: " .. result)
    end

    genuineAttempt = genuineAttempt + 1
    phase = "capturing_genuine"
    phaseTick = 0
    sawGenuineF7 = false
    genuineOutsideTicks = 0
    previousSora = sora
    resetPreviousState()
    appendLine("")
    appendLine(string.format(
        "GENUINE ATTEMPT %02d BEGIN global_tick=%d",
        genuineAttempt,
        globalTick
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
    resetPreviousState()
    diagnosticPrint("GENUINE CAPTURE COMPLETE.")
    diagnosticPrint(
        "PERFORM REPLACEMENT: one CC or CD starter, then press Attack again."
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
    resetPreviousState()
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
    resetPreviousState()
    appendLine("")
    appendLine(string.format(
        "REPLACEMENT ATTEMPT %02d BEGIN global_tick=%d "
            .. "start_ID=0x%02X expected_second_ID=0x%02X",
        replacementAttempt,
        globalTick,
        replacementStartID,
        replacementExpectedSecondID
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
    resetPreviousState()
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
            .. "events=%d records=%d failed_entry_reads=%d "
            .. "record_bytes=%d",
        genuineAttempt,
        replacementAttempt,
        frameCount,
        eventCount,
        recordCount,
        failedEntryReads,
        recordCount * RECORD_LENGTH
    ))

    closeCaptureFile()
    local saved, result = writeReport()
    phase = "finished"
    finished = true

    if saved then
        diagnosticPrint("REPORT SAVED: " .. result)
        diagnosticPrint("Send the EntityPoolCompare Report.txt and Entries.bin files.")
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
    failedEntryReads = 0
    genuineAttempt = 0
    replacementAttempt = 0
    previousSora = 0
    reportLines = {
        "KH1FM Ragnarok projectile entity-pool comparison v3 / v13",
        "Game memory writes: NONE",
        "Required companion: v13 BANKSAFE controller and its verified MSET.",
        "Do not run another diagnostic concurrently.",
        string.format(
            "Pool: module+0x%08X; entries=%d; entry_length=0x%03X; flags=+0x%03X.",
            ENTITY_POOL_BASE,
            ENTITY_POOL_COUNT,
            ENTITY_ENTRY_LENGTH,
            ENTITY_POOL_FLAGS_OFFSET
        ),
        string.format(
            "Binary record length=0x%03X (%d bytes): 0x20-byte header + 0x4B0 entry.",
            RECORD_LENGTH,
            RECORD_LENGTH
        ),
        "Header is eight little-endian u32 fields in this order:",
        "record_index, phase_code, phase_tick, global_tick, Sora_animation_ID, pool_slot, pool_flags, entry_length.",
        "phase_code: 1=genuine Ragnarok, 2=v13 replacement.",
        "FRAME lines map each game frame to its first binary record and record count.",
        "Only entries satisfying native occupancy flags (bit0=1 and bit1=0) are saved.",
        "Order: complete genuine Ragnarok, then one CC/CD replacement plus second press.",
        "",
        "TRACE BEGIN",
    }
    fileOpenFailed = false
    finished = false
    resetPreviousState()

    diagnosticPrint("READY. READ-ONLY game-memory diagnostic.")
    diagnosticPrint("Keep v13 enabled; remove all older diagnostics/tests.")
    diagnosticPrint("STEP 1: perform one complete genuine Ragnarok through its blast.")
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
            return
        end
    elseif phase == "waiting_replacement" then
        if (animation == ID_CC and index == SLOT_CC)
            or (animation == ID_CD and index == SLOT_CD)
        then
            startReplacementCapture(sora, animation)
        else
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
