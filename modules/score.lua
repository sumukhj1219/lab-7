-- Scoring rules and run stats (§6). The manager owns one run table and
-- calls these; each award returns the points actually given (after ×2).

local config = require "modules.config"

local M = {}

-- Rows of the Game Over breakdown, in display order.
M.CATEGORIES = {
	{ id = "survival", label = "Survival" },
	{ id = "stuns", label = "Stuns" },
	{ id = "chains", label = "Chain bonus" },
	{ id = "cascades", label = "Cascades stopped" },
	{ id = "mutations", label = "Mutations survived" },
	{ id = "uploads", label = "Research uploads" },
	{ id = "antidotes", label = "Unused antidotes" },
}

function M.new_run()
	local run = {
		score = 0,
		seconds = 0,
		stuns = 0,
		best_chain = 0,
		antidotes_used = 0,
		antidotes_left = 0,
		mutations_survived = 0,
		animals_released = 0,
		uploads = 0,
		cascades_stopped = 0,
		infected = false, -- while true every award is multiplied
		breakdown = {},
		second_acc = 0,
	}
	for _, c in ipairs(M.CATEGORIES) do
		run.breakdown[c.id] = 0
	end
	return run
end

local function award(run, category, points, no_multiplier)
	if run.infected and not no_multiplier then
		points = points * config.INFECTED_MULTIPLIER
	end
	run.score = run.score + points
	run.breakdown[category] = run.breakdown[category] + points
	return points
end

function M.tick(run, dt)
	run.seconds = run.seconds + dt
	run.second_acc = run.second_acc + dt
	while run.second_acc >= 1 do
		run.second_acc = run.second_acc - 1
		award(run, "survival", config.SCORE_PER_SECOND)
	end
end

function M.stun(run)
	run.stuns = run.stuns + 1
	return award(run, "stuns", config.SCORE_STUN)
end

-- Returns the chain bonus (0 for a single stun).
function M.chain(run, length)
	run.best_chain = math.max(run.best_chain, length)
	if length < 2 then return 0 end
	return award(run, "chains", config.SCORE_CHAIN * length * length)
end

function M.cascade_stopped(run)
	run.cascades_stopped = run.cascades_stopped + 1
	return award(run, "cascades", config.SCORE_CASCADE_STOPPED)
end

function M.mutation(run)
	run.mutations_survived = run.mutations_survived + 1
	return award(run, "mutations", config.SCORE_MUTATION)
end

function M.upload(run)
	run.uploads = run.uploads + 1
	return award(run, "uploads", config.SCORE_UPLOAD)
end

-- End-of-run bonus. Not multiplied: the player has just turned.
function M.finish(run, antidotes_left)
	run.antidotes_left = antidotes_left
	award(run, "antidotes", config.SCORE_ANTIDOTE_LEFT * antidotes_left, true)
end

return M
