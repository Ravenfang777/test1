-- Kingdom Hearts Final Mix (Steam)
-- Alice-over-Sora hitbox motion trace v2
--
-- READ-ONLY DIAGNOSTIC:
--   * reads Sora's current action, animation, resolved MSET slot, and frame;
--   * prints a compact line when a motion begins or ends;
--   * prints a periodic heartbeat so its installation cannot be ambiguous;
--   * never writes animation, collision, damage, position, input, or model data.
--
-- The "zz_" prefix loads this after normally named scripts, leaving its READY
-- message near the bottom of the F2 console after a full game restart.

local ENABLE_TRACE = true
local HEARTBEAT_INTERVAL = 180

local SORA_POINTER = 0x2537E48
local CURRENT_ACTION_ID_OFFSET = 0x70
local CURRENT_ANIMATION_OFFSET = 0x164
local RESOLVED_INDEX_OFFSET = 0x168
local ANIMATION_TIME_OFFSET = 0x16C

local currentSora = 0
local previousAction = nil
local previousAnimation = nil
local previousSlot = nil
local previousTime = 0.0
local maximumTime = 0.0
local traceNumber = 0
local frameCounter = 0
local enabled = false

local function log(message)
    ConsolePrint("[AliceHitboxTraceV2] " .. message)
end

local function safeReadByte(address, absolute)
    local ok, value = pcall(ReadByte, address, absolute)
    if not ok or value == nil then
        return nil
    end
    if value < 0 then
        return value + 256
    end
    return value
end

local function safeReadShort(address, absolute)
    local ok, value = pcall(ReadShort, address, absolute)
    if not ok or value == nil then
        return nil
    end
    if value < 0 then
        return value + 65536
    end
    return value
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

local function resetMotionState()
    previousAction = nil
    previousAnimation = nil
    previousSlot = nil
    previousTime = 0.0
    maximumTime = 0.0
end

local function endPreviousMotion(nextAction, nextAnimation, nextSlot)
    if previousAnimation == nil then
        return
    end

    log(string.format(
        "END #%d action=0x%02X anim=0x%02X slot=0x%04X max_frame=%.2f -> action=0x%02X anim=0x%02X slot=0x%04X",
        traceNumber,
        previousAction or 0,
        previousAnimation or 0,
        previousSlot or 0,
        maximumTime or 0.0,
        nextAction or 0,
        nextAnimation or 0,
        nextSlot or 0
    ))
end

local function beginMotion(action, animation, slot, animationTime, restarted)
    traceNumber = traceNumber + 1
    log(string.format(
        "%s #%d action=0x%02X anim=0x%02X slot=0x%04X frame=%.2f",
        restarted and "RESTART" or "BEGIN",
        traceNumber,
        action or 0,
        animation or 0,
        slot or 0,
        animationTime or 0.0
    ))

    previousAction = action
    previousAnimation = animation
    previousSlot = slot
    previousTime = animationTime or 0.0
    maximumTime = animationTime or 0.0
end

local function frameLogic()
    local sora = safeReadLong(SORA_POINTER)
    if sora == nil or sora == 0 then
        if currentSora ~= 0 then
            log("Sora unloaded; trace state reset.")
        end
        currentSora = 0
        resetMotionState()
        return
    end

    if sora ~= currentSora then
        currentSora = sora
        resetMotionState()
        log(string.format("Sora loaded at 0x%X.", sora))
    end

    local action = safeReadByte(sora + CURRENT_ACTION_ID_OFFSET, true)
    local animation = safeReadByte(sora + CURRENT_ANIMATION_OFFSET, true)
    local slot = safeReadShort(sora + RESOLVED_INDEX_OFFSET, true)
    local animationTime = safeReadFloat(sora + ANIMATION_TIME_OFFSET, true)
    if action == nil or animation == nil or slot == nil or animationTime == nil then
        return
    end

    local motionChanged = previousAnimation == nil
        or action ~= previousAction
        or animation ~= previousAnimation
        or slot ~= previousSlot
    local restarted = not motionChanged
        and animationTime + 1.0 < previousTime

    if motionChanged then
        endPreviousMotion(action, animation, slot)
        beginMotion(action, animation, slot, animationTime, false)
    elseif restarted then
        endPreviousMotion(action, animation, slot)
        beginMotion(action, animation, slot, animationTime, true)
    else
        previousTime = animationTime
        if animationTime > maximumTime then
            maximumTime = animationTime
        end
    end

    frameCounter = frameCounter + 1
    if frameCounter >= HEARTBEAT_INTERVAL then
        frameCounter = 0
        log(string.format(
            "HEARTBEAT action=0x%02X anim=0x%02X slot=0x%04X frame=%.2f",
            action,
            animation,
            slot,
            animationTime
        ))
    end
end

function _OnInit()
    enabled = ENABLE_TRACE
    frameCounter = 0
    resetMotionState()

    if enabled then
        log("READY: read-only action/animation/MSET-slot trace is active.")
        log("Expect BEGIN/END lines plus a periodic HEARTBEAT; no gameplay writes are used.")
    else
        log("DISABLED by setting.")
    end
end

function _OnFrame()
    if not enabled then
        return
    end

    local ok, reason = pcall(frameLogic)
    if not ok then
        enabled = false
        log("DISABLED after read error: " .. tostring(reason))
    end
end
