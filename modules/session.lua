-- State that lives for the browser session, shared by main.script and the
-- GUI scripts (script.shared_state is on). Nothing here is saved to disk.

local M = {
	muted = false,
	best_score = 0,
	tutorial_seen = false, -- contextual tutorial runs on the first run only
	replay_tutorial = false, -- set by "How to Play"
	skip_tutorial = false,   -- "Skip tutorial" pressed; remembered for the session
}

-- Every sound plays through the master group, so this mutes everything.
function M.set_muted(muted)
	M.muted = muted
	sound.set_group_gain(hash("master"), muted and 0 or 1)
end

return M
