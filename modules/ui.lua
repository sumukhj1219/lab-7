-- Small helpers for building GUI nodes in code. Every .gui file registers
-- the font as "main". The HUD icons and LAB-AI portrait are drawn from
-- plain shapes here (no image files).

local config = require "modules.config"

local M = {}

function M.text(parent, x, y, str, scale, color, pivot)
	local node = gui.new_text_node(vmath.vector3(x, y, 0), str or "")
	gui.set_font(node, "main")
	gui.set_scale(node, vmath.vector3(scale or 1, scale or 1, 1))
	gui.set_color(node, color or config.UI_COLOR.text)
	gui.set_pivot(node, pivot or gui.PIVOT_CENTER)
	-- Wide box + line breaks, so text only breaks at "\n".
	gui.set_line_break(node, true)
	gui.set_size(node, vmath.vector3(2000, 40, 0))
	if parent then gui.set_parent(node, parent) end
	return node
end

-- Untextured box: drawn as a solid rectangle in `color`.
function M.box(parent, x, y, w, h, color, pivot)
	local node = gui.new_box_node(vmath.vector3(x, y, 0), vmath.vector3(w, h, 0))
	gui.set_color(node, color or config.UI_COLOR.panel)
	gui.set_pivot(node, pivot or gui.PIVOT_CENTER)
	if parent then gui.set_parent(node, parent) end
	return node
end

-- Solid disc of diameter `d`.
function M.disc(parent, x, y, d, color)
	local node = gui.new_pie_node(vmath.vector3(x, y, 0), vmath.vector3(d, d, 0))
	gui.set_outer_bounds(node, gui.PIEBOUNDS_ELLIPSE)
	gui.set_color(node, color)
	if parent then gui.set_parent(node, parent) end
	return node
end

-- Code-drawn icons ------------------------------------------------------------

-- An invisible (zero-size) node to hang an icon's shapes on.
local function group(parent, x, y)
	return M.box(parent, x, y, 0, 0, vmath.vector4(1, 1, 1, 1))
end

local C = config.UI_COLOR

-- Antidote vial, 24x32: neck, glass body, liquid. Use set_vial to fill/empty.
function M.vial(parent, x, y)
	local root = group(parent, x, y)
	M.box(root, 0, 12, 8, 6, C.vial_glass)            -- neck
	M.box(root, 0, -3, 20, 24, C.vial_glass)          -- glass
	M.box(root, 0, -3, 16, 20, C.vial_inside)         -- inside
	local liquid = M.box(root, 0, -13, 16, 14, C.vial_liquid, gui.PIVOT_S)
	return { root = root, liquid = liquid }
end

function M.set_vial(v, full)
	gui.set_enabled(v.liquid, full)
end

-- Gas icon: a little purple cloud of three discs.
function M.gas_icon(parent, x, y)
	local root = group(parent, x, y)
	M.disc(root, -6, -3, 16, C.gas_icon)
	M.disc(root, 6, -3, 16, C.gas_icon)
	M.disc(root, 0, 5, 18, C.gas_icon_light)
	return root
end

-- Tower icon: base, pole, glowing top.
function M.tower_icon(parent, x, y)
	local root = group(parent, x, y)
	M.box(root, 0, -11, 16, 5, C.tower_base)
	M.box(root, 0, -2, 6, 16, C.tower_base)
	M.disc(root, 0, 9, 11, C.tower_top)
	return root
end

-- LAB-AI portrait, 64x64: a monitor with a face. `mouth` can be resized to talk.
function M.labai_portrait(parent, x, y)
	local root = M.box(parent, x, y, 64, 64, C.chain)               -- frame
	M.box(root, 0, 0, 56, 56, C.portrait_screen)                     -- screen
	M.box(root, -12, 8, 10, 8, C.chain)                              -- eyes
	M.box(root, 12, 8, 10, 8, C.chain)
	local mouth = M.box(root, 0, -13, 26, 4, C.chain)
	return { root = root, mouth = mouth }
end

-- A progress bar: returns the background and the fill (left-pivoted).
function M.bar(parent, x, y, w, h, color)
	local bg = M.box(parent, x, y, w, h, config.UI_COLOR.bar_bg)
	local fill = M.box(bg, -w / 2, 0, w, h, color, gui.PIVOT_W)
	return bg, fill
end

-- Small diagonal stripes across a bar fill, clipped to the fill so they
-- only show on the filled part.
function M.hatch(fill, full_width, height, spacing, color)
	gui.set_clipping_mode(fill, gui.CLIPPING_MODE_STENCIL)
	local rotation = vmath.vector3(0, 0, 45)
	for x = -height, full_width + height, spacing do
		local stripe = M.box(fill, x, 0, 3, height * 2, color)
		if gui.set_euler then gui.set_euler(stripe, rotation) else gui.set_rotation(stripe, rotation) end
	end
end

function M.set_bar(fill, full_width, fraction)
	local size = gui.get_size(fill)
	size.x = full_width * math.max(0, math.min(1, fraction))
	gui.set_size(fill, size)
end

-- Two text columns, top-aligned at y: fill with set_columns(). The font is
-- proportional, so columns are separate nodes rather than padded strings.
-- `right_x` is where the right column ends (right-aligned) unless
-- `right_pivot` says otherwise.
function M.columns(parent, left_x, right_x, y, scale, left_color, right_color, right_pivot)
	return {
		left = M.text(parent, left_x, y, "", scale, left_color, gui.PIVOT_NW),
		right = M.text(parent, right_x, y, "", scale, right_color or left_color, right_pivot or gui.PIVOT_NE),
	}
end

-- rows: list of { left_text, right_text }.
function M.set_columns(cols, rows)
	local left, right = {}, {}
	for i, row in ipairs(rows) do
		left[i], right[i] = row[1], row[2]
	end
	gui.set_text(cols.left, table.concat(left, "\n"))
	gui.set_text(cols.right, table.concat(right, "\n"))
end

-- Leaderboard rows: "1. name" on the left, score on the right.
function M.leaderboard_rows(entries)
	local rows = {}
	for i, e in ipairs(entries) do
		rows[i] = { (e.rank or i) .. ".  " .. (e.name or "?"):sub(1, 16), tostring(e.score or 0) }
	end
	return rows
end

function M.button(parent, x, y, w, h, label)
	local node = M.box(parent, x, y, w, h, config.UI_COLOR.button)
	local text = M.text(node, 0, 0, label, 0.8)
	return { node = node, text = text }
end

function M.hit(button, action)
	return gui.is_enabled(button.node, true) and gui.pick_node(button.node, action.x, action.y)
end

-- Highlight whichever button the mouse is over.
function M.hover(buttons, action)
	if not action.x then return end -- key presses carry no mouse position
	for _, b in pairs(buttons) do
		local over = M.hit(b, action)
		gui.set_color(b.node, over and config.UI_COLOR.button_hover or config.UI_COLOR.button)
	end
end

return M
