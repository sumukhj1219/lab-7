-- Every tunable number in the game lives here (PRD §0.3).
-- Changing a value here must never require another code change.

local M = {}

-- Room ------------------------------------------------------------------
M.ROOM_WIDTH = 1280
M.ROOM_HEIGHT = 720
M.WALL_THICKNESS = 24 -- must match the boxes in /game/walls.collisionobject

M.PLAYER_SPAWN = vmath.vector3(100, 90, 0.5) -- bottom-left corner, ~590 px from Subject Zero
M.ZOMBIE_SPAWN = vmath.vector3(640, 360, 0.4) -- Subject Zero, room center

-- Player (§5.1) ------------------------------------------------------------
M.PLAYER_SPEED = 220

-- Zombies (§5.3) -----------------------------------------------------------
M.ZOMBIE_SPEED = 100 -- PRD default 120, lowered after M1 playtest
M.ZOMBIE_SIGHT = math.huge -- zombies see the whole room (was 400)
M.BAIT_BIAS = 80
M.ZOMBIE_MAX = 30
-- Body radii for keeping creatures from stacking (must match the circles in
-- zombie/animal_zombie/animal .collisionobject).
M.ZOMBIE_RADIUS = 27
M.ANIMAL_RADIUS = 9
M.SEPARATION = 0.5 -- share of an overlap each creature resolves per frame
M.ZOMBIE_ATTACK_RANGE = 90 -- play the attack frames when the player is this close (touching is 54)

-- Animals (§5.4) -----------------------------------------------------------
M.CAGE_COUNT = 20
M.ANIMAL_SPEED = 150
M.ANIMAL_TURN_TIME = 3
M.RELEASE_RANGE = 75 -- player (radius 18) + cage (20) touch at 38
M.ANIMAL_FLASH_PERIOD = 0.15 -- blink speed while an infected animal turns
-- Visual only. Each type has its own sheet (idle, run x2, zombie x2) and a
-- matching <type>_sheet property in animal.script, cage.script, zombie.script.
M.ANIMAL_TYPES = { "rabbit", "rat", "cat" }
-- Cages are scattered at random every run (§5.4), within these rules.
M.CAGE_MARGIN = 60             -- keep this far from the room edges
M.CAGE_TOP_CLEAR = 100         -- keep out of the HUD strip at the top
M.CAGE_MIN_SPACING = 80        -- center-to-center gap between cages
M.CAGE_SPAWN_CLEARANCE = 160   -- keep away from player and Subject Zero spawns
M.CAGE_TERMINAL_CLEARANCE = 70 -- keep away from terminals
M.CAGE_PLACE_TRIES = 500       -- give up after this many random tries
M.CAGE_Z = 0.2
-- Furniture painted into lab-floor.png that cages must not cover
-- (room coordinates: x, y of the bottom-left corner, then width, height).
M.CAGE_KEEP_CLEAR = {
	{ x = 110, y = 150, w = 160, h = 170 }, -- big cabinet, bottom left
	{ x = 1165, y = 125, w = 85, h = 85 },  -- block by the right wall
	{ x = 415, y = 25, w = 100, h = 55 },   -- box by the bottom wall
	{ x = 830, y = 575, w = 110, h = 45 },  -- bench near the top
}

-- Research terminals (§5.10) ----------------------------------------------
-- view "front" = terminal-1.png (against the top wall);
-- view "side" = terminal-2.png, drawn for the left wall, flipped for the right.
M.TERMINALS = {
	{ pos = vmath.vector3(300, 650, 0.2), view = "front" },
	{ pos = vmath.vector3(960, 650, 0.2), view = "front" },
	{ pos = vmath.vector3(46, 470, 0.2), view = "side" },
	{ pos = vmath.vector3(1234, 520, 0.2), view = "side", flip = true },
	{ pos = vmath.vector3(1234, 300, 0.2), view = "side", flip = true },
}
M.TERMINAL_RANGE = 70       -- stand this close to upload (touching is 38)
M.UPLOAD_TIME = 8           -- seconds for the first upload
M.UPLOAD_TIME_STEP = 2      -- each later upload takes this much longer
M.TERMINAL_NEXT_DELAY = 3   -- pause before the next terminal lights up
M.TERMINAL_PULSE_TIME = 0.5 -- lit terminal glow pulse period
M.TERMINAL_ANTIDOTES = 1    -- antidotes rewarded per upload (capped at ANTIDOTES)

-- Scoring (§6) --------------------------------------------------------------
M.SCORE_PER_SECOND = 10
M.SCORE_STUN = 50
M.SCORE_CHAIN = 50          -- chain of n (n >= 2) adds SCORE_CHAIN * n * n
M.SCORE_CASCADE_STOPPED = 200
M.SCORE_MUTATION = 250
M.SCORE_UPLOAD = 1000
M.SCORE_ANTIDOTE_LEFT = 500 -- per unused antidote at game over
M.INFECTED_MULTIPLIER = 2

-- UI -----------------------------------------------------------------------
M.FLOAT_TEXT_RISE = 40      -- px floating score text rises
M.FLOAT_TEXT_TIME = 0.9
M.FLOAT_TEXT_Z = 0.9
M.NOTIFY_TIME = 1.5         -- small feedback messages ("no gas left") stay this long
M.BANNER_TIME = 1.5         -- big center messages ("INFECTED!") stay this long
M.MUTATION_BANNER_TIME = 3  -- "MUTATION! TIER n" stays on screen this long in total
M.BANNER_FADE = 0.3         -- banners fade out over the end of their time
M.WARNING_BLINK = 0.25      -- mutation bar blink period in the last seconds
M.INFECTED_SCREEN_ALPHA = 0.18

-- Dialog and tutorial (§8) --------------------------------------------------
M.DIALOG_CHARS_PER_SEC = 40
M.DIALOG_AUTO_HIDE = 4      -- seconds a fully shown line stays if ignored
M.TUTORIAL_TOWER_DELAY = 3  -- "tower" tip this long after play starts

-- Achievements (§10) ------------------------------------------------------------
M.ACH_CHAIN = 5             -- CHAIN_5
M.ACH_LAST_VIAL_TIME = 60   -- LAST_VIAL: survive this long after the 3rd antidote
M.ACH_LAST_VIAL_COUNT = 3
M.ACH_STEADY_HANDS_TIME = 180
M.ACH_ANIMAL_RIGHTS_TIME = 120
M.ACH_MUTATIONS = 10        -- MUTATION_10
M.ACH_SURVIVE_TIME = 300    -- SURVIVE_5MIN
M.LEADERBOARD_TOP = 10

-- Effects -------------------------------------------------------------------
M.LINK_FX_TIME = 0.6 -- how long an infection link stays visible
M.ARC_FX_TIME = 0.4 -- how long a stun arc stays visible
M.BURST_FX_TIME = 0.5 -- how long a mutation burst ring takes to expand
M.TOWER_POP_SCALE = 1.4 -- tower grows briefly when it pulses
M.TOWER_POP_TIME = 0.15
M.TOWER_Z = 0.3
M.FX_Z = 0.45

-- Stun towers (§5.5) -------------------------------------------------------
M.TOWER_MAX = 3
M.TOWER_COOLDOWN = 6
M.TOWER_LIFETIME = 10 -- towers vanish after this long (added after M3 playtest)
M.TOWER_PULSE_INTERVAL = 3
M.TOWER_RANGE = 140
M.CHAIN_RADIUS = 110
M.CHAIN_MAX = 8
M.STUN_TIME = 2.5
M.STUN_IMMUNE = 1

-- Mutation gas (§5.6) ------------------------------------------------------
M.GAS_CHARGES = 3
M.GAS_REGEN = 20
M.GAS_RANGE = 300
M.GAS_RADIUS = 90
M.GAS_DURATION = 6
M.GAS_SLOW = 0.5
M.GAS_FADE_TIME = 0.5 -- cloud fades out over the last part of GAS_DURATION
M.GAS_ALPHA = 0.85    -- cloud opacity, so zombies inside stay visible
M.GAS_Z = 0.44
-- A blocked infection only counts as "cascade stopped" once per target
-- in this window, so a zombie pressed against gas is not farmed for points.
M.CASCADE_BLOCK_COOLDOWN = 6

-- Mutation (§5.7) ----------------------------------------------------------
M.MUTATION_INTERVAL = 30
M.MUTATION_WARNING = 5
M.BURST_RADIUS = 150
M.TIER_MAX = 4
M.TIER1_SPEED_BONUS = 0.2  -- tier 1: +20% speed
M.TIER2_SIGHT_BONUS = 0.25 -- tier 2: +25% sight, visible glow
M.TIER4_SPEED_BONUS = 0.2  -- tier 4: another +20% speed
M.TIER4_BURST_MULT = 1.5   -- tier 4: burst radius +50%
M.SPLIT_TIER = 3           -- reaching this tier splits the zombie in two
M.SPLIT_OFFSET = 24        -- px between the two halves of a split

-- Infection and antidotes (§5.8) ------------------------------------------
-- Player health (§5.8). Never refills by itself: only antidotes heal.
M.PLAYER_HEALTH = 100
M.HIT_DAMAGE = 15        -- each zombie hit
M.HIT_INVULN = 1         -- seconds of protection after a hit (blinking)
M.INFECTION_DRAIN = 100 / 30 -- health lost per second while infected (full bar = 30 s)
M.ANTIDOTE_HEAL = 25     -- health an antidote gives back (capped at PLAYER_HEALTH)
M.HEALTH_BAR_Y = 34      -- bar height above the player's center
M.HEALTH_BAR_W = 40      -- must match health_bg.sprite / health_fill.sprite
M.ANTIDOTES = 3
M.DRINK_TIME = 1
M.CURE_INVULN = 2
M.TURN_TIME = 1.5
M.BLINK_PERIOD = 0.1 -- invulnerability blink speed
M.CLOSE_CALL_HEALTH = 15 -- CLOSE_CALL: antidote finished with less health than this

-- Difficulty ramp (§5.9) ---------------------------------------------------
M.AUTO_INFECT_INTERVAL = 45
M.AUTO_INFECT_MIN_ZOMBIES = 3

-- Sound effects (modules/sfx.lua). gain = volume. Sounds with `gap` queue
-- up instead of overlapping: `gap` seconds apart, each `pitch_step` higher
-- than the last, up to `max_pitch`.
M.SFX = {
	coin = { gain = 0.5, gap = 0.06, pitch_step = 0.05, max_pitch = 1.8 }, -- pickupCoin.wav: each points award
	powerup = { gain = 0.7 }, -- powerUp.wav: cured
	tone = { gain = 0.6 },    -- tone.wav: start uploading at the lit terminal (once per terminal)
	hit = { gain = 0.8 },     -- hitHurt.wav: hit by a zombie
}

-- Placeholder art (§9.1) ---------------------------------------------------
-- While true, sprites are tinted builtin blobs. Set to false once all of
-- the developer's art is in the atlases so the real art is not recolored.
M.PLACEHOLDER_ART = true
-- Pieces whose final art is already in, while the rest are placeholders.
M.FINAL_ART = {
	floor = true, -- assets/images/lab-floor.png (walls are painted into it)
	terminal = true, -- assets/images/terminal-1.png (front) and terminal-2.png (side)
	cage = true,  -- assets/images/cage.png (one image for all three cage states)
	player = true, -- assets/images/player.png sheet via assets/player.tilesource
	zombie = true, -- assets/images/zombie.png sheet via assets/zombie.tilesource
	animal = true, -- rabbit.png, rat.png, cat.png sheets via assets/<type>.tilesource
	tower = true,  -- assets/images/tower.png sheet via assets/tower.tilesource
	gas = true,    -- assets/images/gas-cloud.png sheet via assets/gas.tilesource
	beams = true,  -- assets/images/stun-arc.png and infection-link.png
}

-- True if `piece` should still be drawn as a tinted placeholder.
function M.placeholder(piece)
	return M.PLACEHOLDER_ART and not M.FINAL_ART[piece]
end

M.TINT = {
	player = vmath.vector4(0.3, 0.9, 1.0, 1),
	player_infected = vmath.vector4(0.6, 1.0, 0.4, 1),
	player_drinking = vmath.vector4(1.0, 1.0, 1.0, 1),
	player_turned = vmath.vector4(0.3, 0.8, 0.2, 1),
	glow = vmath.vector4(0.8, 1.0, 0.3, 0.6),
	arc = vmath.vector4(0.6, 0.85, 1.0, 1),
	burst = vmath.vector4(0.6, 1.0, 0.2, 0.7),
	animal = vmath.vector4(1.0, 0.9, 0.2, 1),
	animal_infected = vmath.vector4(0.6, 1.0, 0.2, 1),
	cage = vmath.vector4(0.6, 0.6, 0.6, 1),
	cage_open = vmath.vector4(0.3, 0.3, 0.3, 1),
	cage_broken = vmath.vector4(0.4, 0.5, 0.3, 1),
	terminal_off = vmath.vector4(0.25, 0.28, 0.35, 1),
	terminal_active = vmath.vector4(1.0, 0.85, 0.3, 1),
	terminal_glow = vmath.vector4(2.6, 2.2, 0.9, 1), -- lit terminal pulses to this; >1 brightens the dark art
	upload_bar = vmath.vector4(1.0, 0.85, 0.3, 1), -- always drawn as a solid bar
	link = vmath.vector4(0.5, 1.0, 0.2, 1),
	tower = vmath.vector4(0.2, 0.4, 1.0, 1),
	gas = vmath.vector4(0.6, 0.2, 0.8, 0.5),
	wall = vmath.vector4(0.35, 0.37, 0.42, 1),
	floor = vmath.vector4(0.14, 0.15, 0.18, 1),
}

-- Player state tints on the final art: the sheet has no infected/drinking
-- frames, so the state shows as a color wash.
M.PLAYER_STATE_TINT = {
	normal = vmath.vector4(1, 1, 1, 1),
	infected = vmath.vector4(0.65, 1.0, 0.5, 1),
	drinking = vmath.vector4(0.8, 0.95, 1.3, 1),
	turned = vmath.vector4(0.4, 0.8, 0.3, 1),
}

-- Zombie look per tier and when stunned: an additive color glow on top of
-- the (very dark) art. rgb = color, w = strength. See pixel_flash.fp.
M.ZOMBIE_TIER_FLASH = {
	[0] = vmath.vector4(0, 0, 0, 0),
	vmath.vector4(0.3, 0.8, 0.1, 0.25),
	vmath.vector4(0.5, 0.9, 0.1, 0.35),
	vmath.vector4(0.9, 0.6, 0.1, 0.45),
	vmath.vector4(1.0, 0.2, 0.1, 0.55),
}
M.ZOMBIE_STUN_FLASH = vmath.vector4(0.4, 0.7, 1.0, 0.7)

-- UI colors (always used; these are not placeholder tints).
M.UI_COLOR = {
	text = vmath.vector4(1, 1, 1, 1),
	dim = vmath.vector4(0.7, 0.72, 0.78, 1),
	score = vmath.vector4(1.0, 0.9, 0.4, 1),
	chain = vmath.vector4(0.6, 0.85, 1.0, 1),
	good = vmath.vector4(0.5, 1.0, 0.5, 1),
	bad = vmath.vector4(1.0, 0.4, 0.3, 1),
	infected = vmath.vector4(0.6, 1.0, 0.3, 1),
	bar_bg = vmath.vector4(0.1, 0.1, 0.12, 0.8),
	bar_mutation = vmath.vector4(0.85, 0.12, 0.1, 1),
	bar_mutation_hatch = vmath.vector4(0.5, 0.04, 0.04, 1), -- diagonal stripes on the red bar
	bar_warning = vmath.vector4(1.0, 0.75, 0.15, 1),  -- last seconds before a mutation
	bar_gas = vmath.vector4(0.7, 0.4, 0.9, 1),
	bar_tower = vmath.vector4(0.4, 0.6, 1.0, 1),
	panel = vmath.vector4(0.05, 0.06, 0.08, 0.85),
	button = vmath.vector4(0.18, 0.2, 0.26, 1),
	button_hover = vmath.vector4(0.3, 0.34, 0.44, 1),
	flash = vmath.vector4(1.0, 0.3, 0.2, 0.35),
	infected_screen = vmath.vector4(0.3, 0.9, 0.1, 1),
	health_bg = vmath.vector4(0.08, 0.08, 0.1, 0.85),
	health_high = vmath.vector4(0.3, 0.9, 0.3, 1),  -- above 60%
	health_mid = vmath.vector4(1.0, 0.8, 0.2, 1),   -- above 30%
	health_low = vmath.vector4(0.95, 0.2, 0.15, 1), -- 30% and below
	-- code-drawn icons (modules/ui.lua)
	vial_glass = vmath.vector4(0.75, 0.82, 0.88, 1),
	vial_inside = vmath.vector4(0.12, 0.14, 0.18, 1),
	vial_liquid = vmath.vector4(0.4, 1.0, 0.6, 1),
	gas_icon = vmath.vector4(0.55, 0.2, 0.8, 1),
	gas_icon_light = vmath.vector4(0.72, 0.4, 0.95, 1),
	tower_base = vmath.vector4(0.55, 0.58, 0.65, 1),
	tower_top = vmath.vector4(0.4, 0.9, 1.0, 1),
	portrait_screen = vmath.vector4(0.04, 0.08, 0.1, 1),
}

return M
