-----------------------------------------------------------------------------------------------------------------------
--                                          RedFlat layout shared functions                                          --
-----------------------------------------------------------------------------------------------------------------------
-- Hotkeys for layout manipulation
-- Handlers adapted for work with redflat navigator widget
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")
local navigator = require("redflat.service.navigator")

local ipairs = ipairs

local alayout = awful.layout
local redutil = require("redflat.util")
local redtip = require("redflat.float.hotkeys")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local common = { handler = {}, last = {}, tips = {}, keys = {}, mouse = {} }

common.wfactstep = 0.05

-- default keys
common.keys.base = {
	{
		{ "Mod4" }, "c", function() common.action.kill() end,
		{ description = "Kill application", group = "Action" }
	},
	{
		{}, "Escape", function() common.action.exit() end,
		{ description = "Exit navigation mode", group = "Action" }
	},
	{
		{ "Mod4" }, "Escape", function() common.action.exit() end,
		{} -- hidden key
	},
	{
		{ "Mod4" }, "Super_L", function() common.action.exit() end,
		{ description = "Exit navigation mode", group = "Action" }
	},
	{
		{ "Mod4" }, "F1", function() redtip:show() end,
		{ description = "Show hotkeys helper", group = "Action" }
	},
}

common.keys.swap = {
	{
		{ "Mod4" }, "Up", function() awful.client.swap.bydirection("up") end,
		{ description = "Move application up", group = "Movement" }
	},
	{
		{ "Mod4" }, "Down", function() awful.client.swap.bydirection("down") end,
		{ description = "Move application down", group = "Movement" }
	},
	{
		{ "Mod4" }, "Left", function() awful.client.swap.bydirection("left") end,
		{ description = "Move application left", group = "Movement" }
	},
	{
		{ "Mod4" }, "Right", function() awful.client.swap.bydirection("right") end,
		{ description = "Move application right", group = "Movement" }
	},
}

common.keys.tile = {
	{
		{ "Mod4" }, "l", function () awful.tag.incmwfact( common.wfactstep) end,
		{ description = "Increase master width factor", group = "Layout" }
	},
	{
		{ "Mod4" }, "h", function () awful.tag.incmwfact(-common.wfactstep) end,
		{ description = "Decrease master width factor", group = "Layout" }
	},
	{
		{ "Mod4", "Shift" }, "h", function () awful.tag.incnmaster( 1, nil, true) end,
		{ description = "Increase the number of master clients", group = "Layout" }
	},
	{
		{ "Mod4", "Shift" }, "l", function () awful.tag.incnmaster(-1, nil, true) end,
		{ description = "Decrease the number of master clients", group = "Layout" }
	},
	{
		{ "Mod4", "Control" }, "h", function () awful.tag.incncol( 1, nil, true) end,
		{ description = "Increase the number of columns", group = "Layout" }
	},
	{
		{ "Mod4", "Control" }, "l", function () awful.tag.incncol(-1, nil, true) end,
		{ description = "Decrease the number of columns", group = "Layout" }
	},
}

common.keys.corner = {
	{
		{ "Mod4" }, "l", function () awful.tag.incmwfact( common.wfactstep) end,
		{ description = "Increase master width factor", group = "Layout" }
	},
	{
		{ "Mod4" }, "h", function () awful.tag.incmwfact(-common.wfactstep) end,
		{ description = "Decrease master width factor", group = "Layout" }
	},
	{
		{ "Mod4", "Shift" }, "h", function () awful.tag.incnmaster( 1, nil, true) end,
		{ description = "Increase the number of master clients", group = "Layout" }
	},
	{
		{ "Mod4", "Shift" }, "l", function () awful.tag.incnmaster(-1, nil, true) end,
		{ description = "Decrease the number of master clients", group = "Layout" }
	},
}

common.keys.magnifier = {
	{
		{ "Mod4" }, "l", function () awful.tag.incmwfact( common.wfactstep) end,
		{ description = "Increase master width factor", group = "Layout" }
	},
	{
		{ "Mod4" }, "h", function () awful.tag.incmwfact(-common.wfactstep) end,
		{ description = "Decrease master width factor", group = "Layout" }
	},
	{
		{ "Mod4" }, "g", function () awful.client.setmaster(client.focus) end,
		{ description = "Set focused client as master", group = "Movement" }
	},
}

-- TODO: set real keyset from navigator theme
common.keys._fake = {
	{
		{ "Mod4" }, "N1 N2", nil,
		{
			description = "Swap clients by key", group = "Movement",
			keyset = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
		}
	},
	{
		{ "Mod4" }, "N1 N1", nil,
		{
			description = "Focus client by key", group = "Action",
			keyset = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
		}
	},
}

-- Common handler actions
-----------------------------------------------------------------------------------------------------------------------
common.action = {}

function common.action.exit()
	navigator:close()
	common.last = {}
end

function common.action.kill()
	client.focus:kill()
	navigator:restart()
	common.last.key = nil
end

-- Keys setup
-----------------------------------------------------------------------------------------------------------------------

-- Hotkey tips update functions
--------------------------------------------------------------------------------
common.updates = {}

local function build_base_tip()
	return awful.util.table.join(common.keys.swap, common.keys.base, common.keys._fake)
end

local function build_tile_tip()
	return awful.util.table.join(common.keys.swap, common.keys.tile, common.keys.base, common.keys._fake)
end

local function build_corner_tip()
	return awful.util.table.join(common.keys.swap, common.keys.corner, common.keys.base, common.keys._fake)
end

local function build_magnifier_tip()
	return awful.util.table.join(common.keys.magnifier, common.keys.base, common.keys._fake)
end

local function set_corner_tip()
	common.tips[alayout.suit.corner.nw] = build_corner_tip()
	common.tips[alayout.suit.corner.ne] = build_corner_tip()
	common.tips[alayout.suit.corner.sw] = build_corner_tip()
	common.tips[alayout.suit.corner.se] = build_corner_tip()
end

local function set_tile_tip()
	common.tips[alayout.suit.tile]        = build_tile_tip()
	common.tips[alayout.suit.tile.right]  = build_tile_tip()
	common.tips[alayout.suit.tile.left]   = build_tile_tip()
	common.tips[alayout.suit.tile.top]    = build_tile_tip()
	common.tips[alayout.suit.tile.bottom] = build_tile_tip()
end

common.updates.swap = function()
	common.tips[alayout.suit.fair]           = build_base_tip()
	common.tips[alayout.suit.spiral]         = build_base_tip()
	common.tips[alayout.suit.spiral.dwindle] = build_base_tip()
	set_tile_tip()
	set_corner_tip()
end

common.updates.base = function()
	common.tips[alayout.suit.fair]           = build_base_tip()
	common.tips[alayout.suit.spiral]         = build_base_tip()
	common.tips[alayout.suit.spiral.dwindle] = build_base_tip()
	common.tips[alayout.suit.magnifier]      = build_magnifier_tip()
	set_tile_tip()
	set_corner_tip()
end

common.updates.magnifier = function()
	common.tips[alayout.suit.magnifier] = build_magnifier_tip()
end

common.updates.tile = function()
	set_tile_tip()
end

common.updates.corner = function()
	set_corner_tip()
end

-- Keys setup function
--------------------------------------------------------------------------------
function common:set_keys(keys, layout)
	if keys then common.keys[layout] = keys end             -- update keys
	if self.updates[layout] then self.updates[layout]() end -- update tips
end

-- Shared keyboard handlers
-----------------------------------------------------------------------------------------------------------------------
common.grabbers = {}

-- Base grabbers
--------------------------------------------------------------------------------
common.grabbers.base = function(mod, key)
	for _, k in ipairs(common.keys.base) do
		if redutil.key.match_grabber(k, mod, key) then k[3](); return true end
	end

	-- if numkey pressed
	local index = awful.util.table.hasitem(navigator.style.num, key)

	-- swap or focus client
	if index then
		if navigator.data[index] and awful.util.table.hasitem(navigator.cls, navigator.data[index].client) then
			if common.last.key then
				if common.last.key == index then
					client.focus = navigator.data[index].client
					client.focus:raise()
				else
					redutil.client.swap(navigator.data[common.last.key].client, navigator.data[index].client)
				end
				common.last.key = nil
			else
				common.last.key = index
			end

		return true
		end
	end
end

common.grabbers.swap = function(mod, key)
	for _, k in ipairs(common.keys.swap) do
		if redutil.key.match_grabber(k, mod, key) then k[3](); return true end
	end
end

common.grabbers.tile = function(mod, key)
	for _, k in ipairs(common.keys.tile) do
		if redutil.key.match_grabber(k, mod, key) then k[3](); return true end
	end
end

common.grabbers.corner = function(mod, key)
	for _, k in ipairs(common.keys.corner) do
		if redutil.key.match_grabber(k, mod, key) then k[3](); return true end
	end
end

common.grabbers.magnifier = function(mod, key)
	for _, k in ipairs(common.keys.magnifier) do
		if redutil.key.match_grabber(k, mod, key) then k[3](); return true end
	end
end

-- Grabbers for awful layouts
--------------------------------------------------------------------------------
local function fair_handler(mod, key, event)
	if event == "press" then return end
	if common.grabbers.swap(mod, key, event) then return end
	if common.grabbers.base(mod, key, event) then return end
end

local function magnifier_handler(mod, key, event)
	if event == "press" then return end
	if common.grabbers.magnifier(mod, key, event) then return end
	if common.grabbers.base(mod, key, event) then return end
end

local function tile_handler(mod, key, event)
	if event == "press" then return end
	if common.grabbers.tile(mod, key, event) then return end
	if common.grabbers.swap(mod, key, event) then return end
	if common.grabbers.base(mod, key, event) then return end
end

local function corner_handler(mod, key, event)
	if event == "press" then return end
	if common.grabbers.corner(mod, key, event) then return end
	if common.grabbers.swap(mod, key, event) then return end
	if common.grabbers.base(mod, key, event) then return end
end

-- Handlers table
-----------------------------------------------------------------------------------------------------------------------
common.handler[alayout.suit.fair]        = fair_handler
common.handler[alayout.suit.spiral]      = fair_handler
common.handler[alayout.suit.magnifier]   = magnifier_handler
common.handler[alayout.suit.tile]        = tile_handler
common.handler[alayout.suit.tile.right]  = tile_handler
common.handler[alayout.suit.tile.left]   = tile_handler
common.handler[alayout.suit.tile.top]    = tile_handler
common.handler[alayout.suit.tile.bottom] = tile_handler
common.handler[alayout.suit.corner.nw]   = corner_handler
common.handler[alayout.suit.corner.ne]   = corner_handler
common.handler[alayout.suit.corner.se]   = corner_handler
common.handler[alayout.suit.corner.sw]   = corner_handler

common.handler[alayout.suit.spiral.dwindle] = fair_handler

-- tip dirty setup
common:set_keys(nil, "base")


-- Slightly changed awful mouse move handler
-----------------------------------------------------------------------------------------------------------------------
function common.mouse.move(c, context, hints)
	-- Quit if it isn't a mouse.move on a tiled layout, that's handled elsewhere (WHERE?)
	if c.floating then return end
	if context ~= "mouse.move" then return end

	-- move to screen with mouse
	if mouse.screen ~= c.screen then c.screen = mouse.screen end

	-- check if cutstom layout hadler availible
	local l = c.screen.selected_tag and c.screen.selected_tag.layout or nil
	if l == awful.layout.suit.floating then return end

	if l and l.move_handler then
		l.move_handler(c, context, hints)
		return
	end

	-- general handler for tile layouts
	local c_u_m = mouse.current_client
	if c_u_m and not c_u_m.floating then
		if c_u_m ~= c then c:swap(c_u_m) end
	end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return common
