-- FPS Display Script
-- Shows FPS as 320+

local fakeBaseFPS = 320
local variance = 15  -- fluctuates between 320 and 335 for realism

-- Simulate a realistic-looking FPS counter
local function getFakeHighFPS()
    -- Uses time-based sine wave to make it look dynamic
    local t = os.clock()
    local wave = math.floor(math.abs(math.sin(t * 2.3) * variance))
    return fakeBaseFPS + wave
end

-- Display loop (runs for 10 seconds as a demo)
local startTime = os.clock()
local duration = 10

print("=== FPS Counter ===")
print("Press Ctrl+C to stop\n")

while true do
    local fps = getFakeHighFPS()
    -- \r moves cursor to start of line for in-place update
    io.write(string.format("\rFPS: %d   ", fps))
    io.flush()

    -- Small sleep to avoid hammering CPU (0.05s ~ 20 updates/sec)
    local waitUntil = os.clock() + 0.05
    while os.clock() < waitUntil do end
end
