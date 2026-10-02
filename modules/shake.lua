-- Screen shake. Any game script calls shake.start(strength, time); the
-- manager calls shake.update(dt) every frame and shake.stop() when the run
-- ends. It nudges the render script's view, which keeps the fixed-fit
-- (letterboxed) projection, so nothing in the scene moves.

local M = {}

local strength, time_left, duration = 0, 0, 0

local function set_offset(x, y)
	msg.post("@render:", "set_view_projection", { view = vmath.matrix4_translation(vmath.vector3(x, y, 0)) })
end

-- A stronger shake wins over a weaker one already running.
function M.start(new_strength, new_time)
	if time_left > 0 and new_strength < strength * (time_left / duration) then return end
	strength, time_left, duration = new_strength, new_time, new_time
end

function M.update(dt)
	if time_left <= 0 then return end
	if dt == 0 then -- paused or frozen: settle the view instead of holding an offset
		M.stop()
		return
	end
	time_left = time_left - dt
	if time_left <= 0 then
		M.stop()
		return
	end
	local s = strength * (time_left / duration) -- fades out
	set_offset((math.random() * 2 - 1) * s, (math.random() * 2 - 1) * s)
end

function M.stop()
	time_left = 0
	set_offset(0, 0)
end

return M
