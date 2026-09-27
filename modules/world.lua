-- Shared registry of live entity positions, so scripts can look each other
-- up without per-frame physics queries (§11). Reset at the start of every run.

local M = {}

function M.reset()
	M.paused = false
	M.in_intro = false       -- intro dialog is running (game frozen)
	M.dialog_showing = false -- a LAB-AI line is on screen
	M.player_pos = nil
	M.player_state = "normal"
	M.player_health = 0
	M.zombies = {} -- [go id] = { pos = vector3 }
	M.animals = {} -- [go id] = { pos = vector3, infected = bool }
	M.cages = {}   -- [go id] = { pos = vector3, state = "closed"|"open"|"broken", kind = n }
	M.terminals = {} -- [go id] = { pos = vector3, active = bool, progress = 0..1 }
	M.gas = {}       -- [go id] = { pos = vector3, radius = n }
end

-- Nearest entry of `list` to `pos`, optionally filtered. Returns id, entry, distance.
function M.nearest(list, pos, filter)
	local best_id, best, best_d = nil, nil, math.huge
	for id, e in pairs(list) do
		if not filter or filter(e) then
			local d = vmath.length(e.pos - pos)
			if d < best_d then
				best_id, best, best_d = id, e, d
			end
		end
	end
	return best_id, best, best_d
end

function M.in_gas(pos)
	for _, cloud in pairs(M.gas) do
		local d = pos - cloud.pos
		d.z = 0
		if vmath.length(d) <= cloud.radius then
			return true
		end
	end
	return false
end

-- How far to step so `pos` (with `radius`) stops overlapping the entries
-- of `list` (each needs pos and radius). `skip_id` is the caller itself;
-- `filter(entry)` can exclude entries. Both sides push, so each takes
-- config.SEPARATION of the overlap.
function M.push_apart(skip_id, pos, radius, list, share, filter)
	local push = vmath.vector3()
	for id, e in pairs(list) do
		if id ~= skip_id and (not filter or filter(e)) then
			local d = pos - e.pos
			d.z = 0
			local dist = vmath.length(d)
			local overlap = radius + e.radius - dist
			if overlap > 0 then
				-- Exactly on top of each other: the ids decide who goes which way.
				local dir
				if dist < 0.001 then
					local mine = skip_id and hash_to_hex(skip_id) or ""
					dir = vmath.vector3(mine > hash_to_hex(id) and 1 or -1, 0, 0)
				else
					dir = d / dist
				end
				push = push + dir * overlap * share
			end
		end
	end
	return push
end

function M.count(list)
	local n = 0
	for _ in pairs(list) do n = n + 1 end
	return n
end

M.reset()

return M
