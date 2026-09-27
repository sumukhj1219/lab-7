-- Sound effects. Game scripts call sfx.play("coin"); each sound's component
-- lives on the /sfx object in game.collection and its settings are in
-- config.SFX. Everything plays through the "master" group, so the menu's
-- mute toggle covers it.
--
-- Sounds with a `gap` never overlap: plays that arrive together are queued
-- back to back, each a bit higher pitched (10 stuns at once = 10 fast,
-- rising coins). Other sounds just play once per call.

local config = require "modules.config"

local M = {}

local queue_free = {} -- name -> time the queue is free again
local streak = {}     -- name -> how many plays are queued back to back

function M.play(name)
	local s = config.SFX[name]
	if not s then return end
	local delay, speed = 0, 1
	if s.gap then
		local now = socket.gettime()
		local free = queue_free[name] or 0
		if free > now then
			delay = free - now
			streak[name] = streak[name] + 1
		else
			streak[name] = 0
		end
		queue_free[name] = now + delay + s.gap
		speed = math.min(s.max_pitch, 1 + streak[name] * s.pitch_step)
	end
	sound.play("/sfx#" .. name, { gain = s.gain, delay = delay, speed = speed })
end

return M
