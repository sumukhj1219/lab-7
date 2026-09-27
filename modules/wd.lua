-- Wavedash wrapper (§10). Every Wavedash call in the game goes through here.
-- Outside Wavedash (editor, desktop, itch.io) every function is a safe no-op:
-- the SDK's `wavedash` module only exists in HTML5 builds, and its calls
-- throw if the page has no window.Wavedash, so we check both first.

local M = {}

local available = false
local stats_ready = false
local pending_stats = {}  -- stat increments made before stats finished loading
local unlocked = {}       -- achievements already sent this session
local leaderboard_ids = {} -- leaderboard name -> id

local function detect()
	if not wavedash or not html5 then return false end
	local ok, result = pcall(html5.run, "typeof window.Wavedash !== 'undefined' ? 'yes' : 'no'")
	return ok and result == "yes"
end

-- Run `fn` in a coroutine: inside one, the SDK's *_async calls return
-- their response directly instead of firing an event.
local function async(fn)
	local co = coroutine.create(fn)
	local ok, err = coroutine.resume(co)
	if not ok then
		print("wd: " .. tostring(err))
	end
end

local function succeeded(response)
	return response == true or (type(response) == "table" and response.success)
end

local function apply_stat(id, amount)
	wavedash.set_stat(id, (wavedash.get_stat(id) or 0) + amount, false)
end

local function leaderboard_id(name)
	if not leaderboard_ids[name] then
		local response = wavedash.get_leaderboard_async(name)
		if succeeded(response) then
			leaderboard_ids[name] = response.data.id
		end
	end
	return leaderboard_ids[name]
end

function M.is_available()
	return available
end

-- Must be called once from bootstrap: init() also dismisses the Wavedash
-- loading screen.
function M.init()
	available = detect()
	if not available then return end
	wavedash.init({ debug = false }, function(self, event, payload) end)
	async(function()
		if succeeded(wavedash.request_stats_async()) then
			stats_ready = true
			for id, amount in pairs(pending_stats) do
				apply_stat(id, amount)
			end
			pending_stats = {}
		end
	end)
end

function M.unlock_achievement(id)
	if unlocked[id] then return end
	unlocked[id] = true
	if available then
		wavedash.set_achievement(id, true)
	end
end

-- Increments are kept locally until store() sends them.
function M.add_stat(id, amount)
	if not available then return end
	if stats_ready then
		apply_stat(id, amount)
	else
		pending_stats[id] = (pending_stats[id] or 0) + amount
	end
end

function M.store()
	if available and stats_ready then
		wavedash.store_stats()
	end
end

-- Submits score and survival time once per run.
-- cb(ok, rank) gets the player's high-score rank.
function M.submit_run(run, cb)
	if not available then
		if cb then cb(false, nil) end
		return
	end
	async(function()
		local rank = nil
		local id = leaderboard_id("high-score")
		if id then
			local response = wavedash.upload_leaderboard_score_async(id, run.score, true)
			if succeeded(response) then
				rank = response.data.globalRank
			end
		end
		local survival_id = leaderboard_id("longest-survival")
		if survival_id then
			wavedash.upload_leaderboard_score_async(survival_id, math.floor(run.seconds), true)
		end
		if cb then cb(rank ~= nil, rank) end
	end)
end

-- cb(ok, entries): entries is a list of { rank, name, score }.
function M.get_top(leaderboard_name, count, cb)
	if not available then
		cb(false, {})
		return
	end
	async(function()
		local entries = {}
		local id = leaderboard_id(leaderboard_name)
		local response = id and wavedash.list_leaderboard_entries_async(id, 0, count, false)
		if succeeded(response) then
			for _, e in ipairs(response.data) do
				entries[#entries + 1] = { rank = e.globalRank, name = e.username, score = e.score }
			end
		end
		cb(succeeded(response), entries)
	end)
end

return M
