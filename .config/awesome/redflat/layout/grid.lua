-----------------------------------------------------------------------------------------------------------------------
--                                               RedFlat grid layout                                                 --
-----------------------------------------------------------------------------------------------------------------------
-- Floating layout with discrete geometry
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local beautiful = require("beautiful")

local ipairs = ipairs
local pairs = pairs
local math = math
local unpack = unpack or table.unpack

local awful = require("awful")
local common = require("redflat.layout.common")
local redutil = require("redflat.util")

local hasitem = awful.util.table.hasitem


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local grid = { data = {} }
grid.name = "grid"

-- default keys
grid.keys = {}
grid.keys.move = {
	{
		{ "Mod4" }, "Up", function() grid.move_to("up") end,
		{ description = "Move window up", group = "Movement" }
	},
	{
		{ "Mod4" }, "Down", function() grid.move_to("down") end,
		{ description = "Move window down", group = "Movement" }
	},
	{
		{ "Mod4" }, "Left", function() grid.move_to("left") end,
		{ description = "Move window left", group = "Movement" }
	},
	{
		{ "Mod4" }, "Right", function() grid.move_to("right") end,
		{ description = "Move window right", group = "Movement" }
	},
	{
		{ "Mod4", "Control" }, "Up", function() grid.move_to("up", true) end,
		{ description = "Move window up by bound", group = "Movement" }
	},
	{
		{ "Mod4", "Control" }, "Down", function() grid.move_to("down", true) end,
		{ description = "Move window down by bound", group = "Movement" }
	},
	{
		{ "Mod4", "Control" }, "Left", function() grid.move_to("left", true) end,
		{ description = "Move window left by bound", group = "Movement" }
	},
	{
		{ "Mod4", "Control" }, "Right", function() grid.move_to("right", true) end,
		{ description = "Move window right by bound", group = "Movement" }
	},
}

grid.keys.resize = {
	{
		{ "Mod4" }, "k", function() grid.resize_to("up") end,
		{ description = "Inrease window size to the up", group = "Resize" }
	},
	{
		{ "Mod4" }, "j", function() grid.resize_to("down") end,
		{ description = "Inrease window size to the down", group = "Resize" }
	},
	{
		{ "Mod4" }, "h", function() grid.resize_to("left") end,
		{ description = "Inrease window size to the left", group = "Resize" }
	},
	{
		{ "Mod4" }, "l", function() grid.resize_to("right") end,
		{ description = "Inrease window size to the right", group = "Resize" }
	},
	{
		{ "Mod4", "Shift" }, "k", function() grid.resize_to("up", nil, true) end,
		{ description = "Decrease window size from the up", group = "Resize" }
	},
	{
		{ "Mod4", "Shift" }, "j", function() grid.resize_to("down", nil, true) end,
		{ description = "Decrease window size from the down", group = "Resize" }
	},
	{
		{ "Mod4", "Shift" }, "h", function() grid.resize_to("left", nil, true) end,
		{ description = "Decrease window size from the left", group = "Resize" }
	},
	{
		{ "Mod4", "Shift" }, "l", function() grid.resize_to("right", nil, true) end,
		{ description = "Decrease window size from the right", group = "Resize" }
	},
	{
		{ "Mod4", "Control" }, "k", function() grid.resize_to("up", true) end,
		{ description = "Increase window size to the up by bound", group = "Resize" }
	},
	{
		{ "Mod4", "Control" }, "j", function() grid.resize_to("down", true) end,
		{ description = "Increase window size to the down by bound", group = "Resize" }
	},
	{
		{ "Mod4", "Control" }, "h", function() grid.resize_to("left", true) end,
		{ description = "Increase window size to the left by bound", group = "Resize" }
	},
	{
		{ "Mod4", "Control" }, "l", function() grid.resize_to("right", true) end,
		{ description = "Increase window size to the right by bound", group = "Resize" }
	},
	{
		{ "Mod4", "Control", "Shift" }, "k", function() grid.resize_to("up", true, true) end,
		{ description = "Decrease window size from the up by bound ", group = "Resize" }
	},
	{
		{ "Mod4", "Control", "Shift" }, "j", function() grid.resize_to("down", true, true) end,
		{ description = "Decrease window size from the down by bound ", group = "Resize" }
	},
	{
		{ "Mod4", "Control", "Shift" }, "h", function() grid.resize_to("left", true, true) end,
		{ description = "Decrease window size from the left by bound ", group = "Resize" }
	},
	{
		{ "Mod4", "Control", "Shift" }, "l", function() grid.resize_to("right", true, true) end,
		{ description = "Decrease window size from the right by bound ", group = "Resize" }
	},
}

grid.keys.all = awful.util.table.join(grid.keys.move, grid.keys.resize)


-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function compare(a ,b) return a < b end

-- Find all rails for given client
------------------------------------------------------------
local function get_rail(c)
	local wa = screen[c.screen].workarea
	local cls = awful.client.visible(c.screen)

	local rail = { x = { wa.x, wa.x + wa.width }, y = { wa.y, wa.y + wa.height } }
	table.remove(cls, hasitem(cls, c))

	for _, v in ipairs(cls) do
		local lg = redutil.client.fullgeometry(v)
		local xr = lg.x + lg.width
		local yb = lg.y + lg.height

		if not hasitem(rail.x, lg.x) then table.insert(rail.x, lg.x) end
		if not hasitem(rail.x, xr)   then table.insert(rail.x, xr)   end
		if not hasitem(rail.y, lg.y) then table.insert(rail.y, lg.y) end
		if not hasitem(rail.y, yb)   then table.insert(rail.y, yb)   end
	end

	table.sort(rail.x, compare)
	table.sort(rail.y, compare)

	return rail
end

local function update_rail(c) grid.data.rail = get_rail(c) end

-- Calculate cell geometry
------------------------------------------------------------
local function make_cell(wa, cellnum)
	local cell = {
		x = wa.width  / cellnum.x,
		y = wa.height / cellnum.y
	}

	-- adapt cell table to work with geometry prop
	cell.width = cell.x
	cell.height = cell.y

	return cell
end

-- Grid rounding
------------------------------------------------------------
local function round(a, n)
	return n * math.floor((a + n / 2) / n)
end

-- Fit client into grid
------------------------------------------------------------
local function fit_cell(g, cell)
	local ng = {}

	for k, v in pairs(g) do
		ng[k] = math.ceil(round(v, cell[k]))
	end

	return ng
end

-- Check geometry difference
------------------------------------------------------------
local function is_diff(g1, g2, cell)
	for k, v in pairs(g1) do
		if math.abs(g2[k] - v) >= cell[k] then return true end
	end

	return false
end

-- Move client
-----------------------------------------------------------------------------------------------------------------------
function grid.move_to(dir, is_rail, k)
	local ng = {}
	local data = grid.data
	local c = client.focus

	if not c then return end
	if data.last ~= c then
		data.last = c
		update_rail(c)
	end

	local g = redutil.client.fullgeometry(c)
	k = k or 1

	if dir == "left" then
		if is_rail then
			for i = #data.rail.x, 1, - 1 do
				if data.rail.x[i] < g.x then
					ng.x = data.rail.x[i]
					break
				end
			end
		else
			ng.x = g.x - data.cell.x * k
		end
	elseif dir == "right" then
		if is_rail then
			for i = 1, #data.rail.x  do
				if data.rail.x[i] > g.x + g.width + 1 then
					ng.x = data.rail.x[i] - g.width
					break
				end
			end
		else
			ng.x = g.x + data.cell.x * k
		end
	elseif dir == "up" then
		if is_rail then
			for i = #data.rail.y, 1, - 1  do
				if data.rail.y[i] < g.y then
					ng.y = data.rail.y[i]
					break
				end
			end
		else
			ng.y = g.y - data.cell.y * k
		end
	elseif dir == "down" then
		if is_rail then
			for i = 1, #data.rail.y  do
				if data.rail.y[i] > g.y + g.height + 1 then
					ng.y = data.rail.y[i] - g.height
					break
				end
			end
		else
			ng.y = g.y + data.cell.y * k
		end
	end

	redutil.client.fullgeometry(c, ng)
end

-- Resize client
-----------------------------------------------------------------------------------------------------------------------
grid.resize_to = function(dir, is_rail, is_reverse)
	local ng = {}
	local c = client.focus
	local data = grid.data

	if not c then return end
	if data.last ~= c then
		data.last = c
		update_rail(c)
	end

	local g = redutil.client.fullgeometry(c)
	local sign = is_reverse and -1 or 1

	if dir == "up" then
		if is_rail then
				-- select loop direction (from min to max or from max to min)
				local f, l, s = unpack(is_reverse and { 1, #data.rail.y, 1 } or { #data.rail.y, 1, - 1 })
				for i = f, l, s do
					if is_reverse and data.rail.y[i] > g.y or not is_reverse and data.rail.y[i] < g.y then
						ng = { y = data.rail.y[i], height = g.height + g.y - data.rail.y[i] }
						break
					end
				end
		else
			ng = { y = g.y - sign * data.cell.y, height = g.height + sign * data.cell.y }
		end
	elseif dir == "down" then
		if is_rail then
				local f, l, s = unpack(is_reverse and { #data.rail.y, 1, - 1 } or { 1, #data.rail.y, 1 })
				for i = f, l, s do
					if is_reverse and data.rail.y[i] < (g.y + g.height - 1)
					   or not is_reverse and data.rail.y[i] > (g.y + g.height + 1) then
						ng = { height = data.rail.y[i] - g.y }
						break
					end
				end
		else
			ng = { height = g.height + sign * data.cell.y }
		end
	elseif dir == "left" then
		if is_rail then
				local f, l, s = unpack(is_reverse and { 1, #data.rail.x, 1 } or { #data.rail.x, 1, - 1 })
				for i = f, l, s do
					if is_reverse and data.rail.x[i] > g.x or not is_reverse and data.rail.x[i] < g.x then
						ng = { x = data.rail.x[i], width = g.width + g.x - data.rail.x[i] }
						break
					end
				end
		else
			ng = { x = g.x - sign * data.cell.x, width = g.width + sign * data.cell.x }
		end
	elseif dir == "right" then
		if is_rail then
				local f, l, s = unpack(is_reverse and { #data.rail.x, 1, - 1 } or { 1, #data.rail.x, 1 })
				for i = f, l, s do
					if is_reverse and data.rail.x[i] < (g.x + g.width)
					   or not is_reverse and data.rail.x[i] > (g.x + g.width + 1) then
						ng = { width = data.rail.x[i] - g.x }
						break
					end
				end
		else
			ng = { width = g.width + sign * data.cell.x }
		end
	end

	redutil.client.fullgeometry(c, ng)
end

-- Keygrabber
-----------------------------------------------------------------------------------------------------------------------
grid.maingrabber = function(mod, key)
	for _, k in ipairs(grid.keys.all) do
		if redutil.key.match_grabber(k, mod, key) then k[3](); return true end
	end
end

grid.key_handler = function (mod, key, event)
	if event == "press" then return end
	if grid.maingrabber(mod, key, event)     then return end
	if common.grabbers.base(mod, key, event) then return end
end


-- Tile function
-----------------------------------------------------------------------------------------------------------------------
function grid.arrange(p)

	-- theme vars
	local cellnum = beautiful.cellnum or { x = 100, y = 60 }

	-- aliases
	local wa = p.workarea
	local cls = p.clients

	-- calculate cell
	-- fix useless gap correction?
	grid.data.cell = make_cell({ width = wa.width + 2 * p.useless_gap, height = wa.height + 2 * p.useless_gap }, cellnum)

	-- nothing to tile here
	if #cls == 0 then return end

	-- tile
	for _, c in ipairs(cls) do
		local g = redutil.client.fullgeometry(c)

		g = fit_cell(g, grid.data.cell)
		redutil.client.fullgeometry(c, g)
	end
end


-- Mouse moving function
-----------------------------------------------------------------------------------------------------------------------
function grid.move_handler(c, _, hints)
	local g = redutil.client.fullgeometry(c)
	local hg = { x = hints.x, y = hints.y, width = g.width, height = g.height }
	if is_diff(hg, g, grid.data.cell) then
		redutil.client.fullgeometry(c, fit_cell(hg, grid.data.cell))
	end
end


-- Mouse resizing function
-----------------------------------------------------------------------------------------------------------------------
function grid.mouse_resize_handler(c, corner)
	local g = redutil.client.fullgeometry(c)
	local cg = g

	-- set_mouse_on_corner(g, corner)

	mousegrabber.run(
		function (_mouse)
			 for _, v in ipairs(_mouse.buttons) do
				if v then
					local ng
					if corner == "bottom_right" then
						ng = {
							width  = _mouse.x - g.x,
							height = _mouse.y - g.y
						}
					elseif corner == "bottom_left" then
						ng = {
							x = _mouse.x,
							width  = (g.x + g.width) - _mouse.x,
							height = _mouse.y - g.y
						}
					elseif corner == "top_left" then
						ng = {
							x = _mouse.x,
							y = _mouse.y,
							width  = (g.x + g.width)  - _mouse.x,
							height = (g.y + g.height) - _mouse.y
						}
					else
						ng = {
							y = _mouse.y,
							width  = _mouse.x - g.x,
							height = (g.y + g.height) - _mouse.y
						}
					end

					if ng.width  <= 0 then ng.width  = nil end
					if ng.height <= 0 then ng.height = nil end
					-- if c.maximized_horizontal then ng.width  = g.width  ng.x = g.x end
					-- if c.maximized_vertical   then ng.height = g.height ng.y = g.y end

					if is_diff(ng, cg, grid.data.cell) then
						cg = redutil.client.fullgeometry(c, fit_cell(ng, grid.data.cell))
					end

					return true
				end
			end
			return false
		end,
		corner .. "_corner"
	)
end

-- Redflat navigator support functions
-----------------------------------------------------------------------------------------------------------------------
function grid:set_keys(keys, layout)
	layout = layout or "all"
	if keys then
		self.keys[layout] = keys
		if layout ~= "all" then grid.keys.all = awful.util.table.join(grid.keys.move, grid.keys.resize) end
	end

	self.tip = awful.util.table.join(self.keys.all, common.keys.base)
end

function grid.startup()
	if not grid.tip then grid:set_keys() end
end

function grid.cleanup()
	grid.data.last = nil
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return grid
