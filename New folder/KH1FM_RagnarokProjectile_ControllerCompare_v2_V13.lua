-- Kingdom Hearts Final Mix (Steam)
-- Paired, read-only controller-state capture for Ragnarok's projectile.
-- v2: explicitly paired with the working v13 bank-safe controller.
--
-- PURPOSE
--   A copied Ragnarok F7 motion produces the pose but not the projectile.
--   The captured F6/F7 records both have empty terminal event sections, which
--   proves that the blast is launched by gameplay/controller state outside the
--   visual motion. This diagnostic records that state for:
--
--     A. one complete genuine Ragnarok (F0 through F7), and
--     B. one v13 aerial replacement (CC/CD into its F7 visual).
--
-- GAME-MEMORY WRITES: NONE
--   This script only reads game memory. Its only writes are the report and
--   snapshot files beside the Lua script.
--
-- REQUIRED TEST SETUP
--   1. Keep the v11 EFFECTS_DEFENSE_POC MSET installed.
--   2. Keep KH1FM_SoraComboVisuals_Controller_v13_BANKSAFE.lua enabled.
--   3. Remove KH1FM_Defense_Invulnerability_PostHitBit_Test_v2.lua and disable
--      every other diagnostic/test Lua.
--   4. Add this Lua and start the game in a room where genuine Ragnarok can be
--      performed.
--
-- TEST ORDER
--   1. Perform one COMPLETE genuine Ragnarok, including its final blast.
--   2. Wait for: GENUINE CAPTURE COMPLETE / PERFORM REPLACEMENT.
--   3. Perform exactly one modified aerial starter (CC or CD), then press
--      Attack a second time so the Ragnarok F7 visual occurs.
--   4. Stop attacking and wait for REPORT SAVED.
--   5. Send back both generated files:
--        KH1FM_RagnarokProjectile_ControllerCompare_v2_V13_Report.txt
--        KH1FM_RagnarokProjectile_ControllerCompare_v2_V13_Snapshots.bin

-- ========================================================================
-- SETTINGS
-- ========================================================================

local SORA_SNAPSHOT_START = 0x000
local SORA_SNAPSHOT_LENGTH = 0x1000
local EXIT_GRACE_TICKS = 60
local FAILED_REPLACEMENT_GRACE_TICKS = 30
local MAX_GENUINE_TICKS = 1800
local MAX_REPLACEMENT_TICKS = 900

local REPORT_FILENAME =
    "KH1FM_RagnarokProjectile_ControllerCompare_v2_V13_Report.txt"
local SNAPSHOT_FILENAME =
    "KH1FM_RagnarokProjectile_ControllerCompare_v2_V13_Snapshots.bin"

-- ========================================================================
-- VERIFIED ADDRESSES FOR THE TESTED STEAM EXECUTABLE
-- ========================================================================

local SORA_POINTER = 0x2537E48

local CURRENT_ANIMATION_OFFSET = 0x164
local RESOLVED_MOTION_INDEX_OFFSET = 0x168
local ANIMATION_TIME_OFFSET = 0x16C
local ACTIVE_BANK_BASE_OFFSET = 0x1D0
local ACTIVE_POINTER_ARRAY_OFFSET = 0x1D4
local ACTIVE_SECOND_SECTION_OFFSET = 0x1D8

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
local snapshotCount = 0
local eventCount = 0
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
local previousPointerArray = nil

local reportLines = {}
local snapshotFile = nil
local fileOpenFailed = false
local finished = false

-- ========================================================================
-- HELPERS
-- ========================================================================

local function diagnosticPrint(message)
    ConsolePrint("[RagnarokProjectileCompareV2] " .. message)
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

local function snapshotToBinary(snapshot)
    local parts = {}
    local index = 1
    while index <= #snapshot do
        parts[index] = string.char(snapshot[index] or 0)
        index = index + 1
    end
    return table.concat(parts)
end

local function openSnapshotFile()
    if snapshotFile ~= nil then
        return true, "already open"
    end
    if fileOpenFailed then
        return false, "a prior open attempt failed"
    end
    if io == nil or io.open == nil then
        fileOpenFailed = true
        return false, "Lua file I/O is unavailable"
    end

    local path = SCRIPT_PATH .. "\\" .. SNAPSHOT_FILENAME
    local file, openError = io.open(path, "wb")
    if file == nil then
        fileOpenFailed = true
        return false, tostring(openError)
    end
    snapshotFile = file
    return true, path
end

local function closeSnapshotFile()
    if snapshotFile ~= nil then
        snapshotFile:close()
        snapshotFile = nil
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
    previousPointerArray = nil
end

local function captureSnapshot(
    sora,
    reason,
    animation,
    index,
    animationTime,
    bankBase,
    pointerArray,
    secondSection
)
    if snapshotFile == nil then
        return
    end

    local ok, snapshot = pcall(
        ReadArray,
        sora + SORA_SNAPSHOT_START,
        SORA_SNAPSHOT_LENGTH,
        true
    )
    if not ok or snapshot == nil or #snapshot < SORA_SNAPSHOT_LENGTH then
        appendLine(string.format(
            "SNAPSHOT_FAILED phase=%s tick=%d reason=%s error=%s",
            phaseLabel(),
            phaseTick,
            reason,
            tostring(snapshot)
        ))
        return
    end

    snapshotCount = snapshotCount + 1
    snapshotFile:write(snapshotToBinary(snapshot))
    appendLine(string.format(
        "SNAPSHOT chunk=%05d phase=%s phase_tick=%d global_tick=%d "
            .. "reason=%s animation=0x%02X name=%s time=%.4f "
            .. "index=0x%04X bank=0x%08X pointer_array=0x%08X "
            .. "second_section=0x%08X offset=0x%03X length=0x%04X",
        snapshotCount,
        phaseLabel(),
        phaseTick,
        globalTick,
        reason,
        animation,
        actionName(animation),
        animationTime,
        index,
        bankBase,
        pointerArray,
        secondSection,
        SORA_SNAPSHOT_START,
        SORA_SNAPSHOT_LENGTH
    ))
end

local function recordFrame(sora)
    local animation = ReadByte(sora + CURRENT_ANIMATION_OFFSET, true)
    local index = readResolvedIndex(sora)
    local animationTime = ReadFloat(sora + ANIMATION_TIME_OFFSET, true)
    local bankBase = unsigned32(ReadInt(
        sora + ACTIVE_BANK_BASE_OFFSET,
        true
    ))
    local pointerArray = unsigned32(ReadInt(
        sora + ACTIVE_POINTER_ARRAY_OFFSET,
        true
    ))
    local secondSection = unsigned32(ReadInt(
        sora + ACTIVE_SECOND_SECTION_OFFSET,
        true
    ))

    local reason = "FRAME"
    if previousAnimation == nil then
        reason = "PHASE_START"
    elseif animation ~= previousAnimation then
        reason = "ID_CHANGE"
    elseif index ~= previousIndex then
        reason = "INDEX_CHANGE"
    elseif pointerArray ~= previousPointerArray then
        reason = "POINTER_ARRAY_CHANGE"
    elseif previousTime ~= nil and animationTime < previousTime - 0.5 then
        reason = "TIME_RESTART"
    end

    if reason ~= "FRAME" then
        eventCount = eventCount + 1
        local line = string.format(
            "EVENT %04d phase=%s phase_tick=%d global_tick=%d reason=%s "
                .. "animation=0x%02X name=%s time=%.4f index=0x%04X "
                .. "bank=0x%08X pointer_array=0x%08X second_section=0x%08X",
            eventCount,
            phaseLabel(),
            phaseTick,
            globalTick,
            reason,
            animation,
            actionName(animation),
            animationTime,
            index,
            bankBase,
            pointerArray,
            secondSection
        )
        appendLine(line)
        diagnosticPrint(line)
    end

    captureSnapshot(
        sora,
        reason,
        animation,
        index,
        animationTime,
        bankBase,
        pointerArray,
        secondSection
    )

    previousAnimation = animation
    previousIndex = index
    previousTime = animationTime
    previousPointerArray = pointerArray

    return animation, index, animationTime
end

local function startGenuineCapture(sora)
    local opened, result = openSnapshotFile()
    if not opened then
        diagnosticPrint("SNAPSHOT FILE FAILED: " .. result)
        appendLine("SNAPSHOT_FILE_ERROR " .. result)
    else
        diagnosticPrint("SNAPSHOT FILE OPEN: " .. result)
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
        "PERFORM REPLACEMENT: one CC or CD aerial starter, then press Attack again."
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
        "REPLACEMENT ATTEMPT %02d BEGIN global_tick=%d start_ID=0x%02X expected_second_ID=0x%02X",
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
    diagnosticPrint("Try one CC or CD aerial starter, then one second Attack press.")
end

local function finishAllCaptures()
    appendLine(string.format(
        "REPLACEMENT ATTEMPT %02d COMPLETE ticks=%d start_ID=0x%02X second_ID=0x%02X",
        replacementAttempt,
        phaseTick,
        replacementStartID,
        replacementExpectedSecondID
    ))
    appendLine("")
    appendLine("CAPTURE COMPLETE")
    appendLine(string.format(
        "SUMMARY genuine_attempts=%d replacement_attempts=%d events=%d snapshots=%d snapshot_bytes=%d",
        genuineAttempt,
        replacementAttempt,
        eventCount,
        snapshotCount,
        snapshotCount * SORA_SNAPSHOT_LENGTH
    ))

    closeSnapshotFile()
    local saved, result = writeReport()
    phase = "finished"
    finished = true

    if saved then
        diagnosticPrint("REPORT SAVED: " .. result)
        diagnosticPrint(
            "Send the ControllerCompare Report.txt and Snapshots.bin files."
        )
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
    snapshotCount = 0
    eventCount = 0
    genuineAttempt = 0
    replacementAttempt = 0
    previousSora = 0
    reportLines = {
        "KH1FM Ragnarok projectile controller comparison v2 / v13",
        "Game memory writes: NONE",
        "Required companion: v13 BANKSAFE controller and its verified MSET.",
        "Do not run the standalone defense invulnerability test concurrently.",
        string.format(
            "Each snapshot chunk is Sora +0x%03X..+0x%03X (%d bytes).",
            SORA_SNAPSHOT_START,
            SORA_SNAPSHOT_START + SORA_SNAPSHOT_LENGTH - 1,
            SORA_SNAPSHOT_LENGTH
        ),
        "One sequential chunk is written for every captured 60 Hz frame.",
        "The SNAPSHOT lines map chunks in the binary to action IDs and frames.",
        "Order: complete genuine Ragnarok, then one CC/CD replacement plus second press.",
        "",
        "TRACE BEGIN",
    }
    fileOpenFailed = false
    finished = false
    resetPreviousState()

    diagnosticPrint("READY. READ-ONLY game-memory diagnostic.")
    diagnosticPrint("Keep v13 enabled; remove older controllers and diagnostics.")
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
                retryReplacement("second Attack press/F7 visual was not observed")
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
