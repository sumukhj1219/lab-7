-- Animal sheets (§5.4). Every sheet has the same animations (animal_idle,
-- animal_run, animal_zombie), so switching type only swaps the image.
-- Scripts that show an animal declare one resource property per sheet and
-- call animals.set_sheet(); keep ANIMAL_TYPES in config.lua in sync.

local config = require "modules.config"

local M = {}

-- `self` must have a <type>_sheet property for every type in ANIMAL_TYPES.
function M.set_sheet(self, url, kind)
	local name = config.ANIMAL_TYPES[kind] or config.ANIMAL_TYPES[1]
	go.set(url, "image", self[name .. "_sheet"])
end

return M
