-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat taglist widget                                                 --
-----------------------------------------------------------------------------------------------------------------------
-- Custom widget used to display tag info
-- Separators added
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.widget.taglist v3.5.2
------ (c) 2008-2009 Julien Danjou
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local table = table
local string = string
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local timer = require("gears.timer")

local redutil = require("redflat.util")
local basetag = require("redflat.gauge.tag")
local tooltip = require("redflat.float.tooltip")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local taglist = { filter = {}, mt = {} , queue = setmetatable({}, { __mode = 'k' }) }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		tag       = {},
		widget    = basetag.blue.new,
		show_tip  = false,
		timeout   = 0.05,
		separator = nil
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.taglist") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Get info about tag
--------------------------------------------------------------------------------
local function get_state(t)
	local state = { focus = false, urgent = false, list = {} }
	local client_list = t:clients()
	local client_count = 0

	for _, c in pairs(client_list) do
		state.focus     = state.focus or client.focus == c
		state.urgent    = state.urgent or c.urgent
		if not c.skip_taskbar then
			client_count = client_count + 1
			table.insert(state.list, { focus = client.focus == c, urgent = c.urgent, minimized = c.minimized })
		end
	end

	state.active = t.selected
	state.occupied = client_count > 0 and not (client_count == 1 and state.focus)
	state.text = string.upper(t.name)
	state.layout = awful.tag.getproperty(t, "layout")

	return state
end

-- Generate tooltip string
--------------------------------------------------------------------------------
local function make_tip(t)
	return string.format("%s (%d apps)", t.name, #(t:clients()))
end

-- Find all tag to be shown
--------------------------------------------------------------------------------
local function filtrate_tags(screen, filter)
	local tags = {}
	for _, t in ipairs(screen.tags) do
		if not awful.tag.getproperty(t, "hide") and filter(t) then
			table.insert(tags, t)
		end
	end
	return tags
end

-- Layout composition
--------------------------------------------------------------------------------
local function base_pack(layout, widg, i, tags, style)
	layout:add(widg)
	if style.separator and i < #tags then
		layout:add(style.separator)
	end
end


-- Create a new taglist widget
-----------------------------------------------------------------------------------------------------------------------
function taglist.new(args, style)

	if not taglist.queue then taglist:init() end

	-- Initialize vars
	--------------------------------------------------------------------------------
	local cs = args.screen
	local layout = args.layout or wibox.layout.fixed.horizontal()
	local data = setmetatable({}, { __mode = 'k' })
	local filter = args.filter or taglist.filter.all
	local hint = args.hint or make_tip
	local pack = args.pack or base_pack

	style = redutil.table.merge(default_style(), style or {})

	-- Set tooltip
	--------------------------------------------------------------------------------
	if not taglist.tp then taglist.tp = tooltip() end

	-- Update function
	--------------------------------------------------------------------------------
	local update = function(s)
		if s ~= cs then return end
		local tags = filtrate_tags(s, filter)

		-- Construct taglist
		------------------------------------------------------------
		layout:reset()
		for i, t in ipairs(tags) do
			local cache = data[t]
			local widg

			-- use existing widgets or create new one
			if cache then
				widg = cache
			else
				widg = style.widget(style.tag)
				if args.buttons then  widg:buttons(redutil.base.buttons(args.buttons, t)) end
				data[t] = widg

				-- set optional tooltip (what about removing?)
				if style.show_tip then
					taglist.tp:add_to_object(widg)
					widg:connect_signal("mouse::enter", function() taglist.tp:set_text(widg.tip) end)
				end
			end

			-- set tag state info to widget
			local state = get_state(t)
			widg:set_state(state)
			widg.tip = hint(t)

			-- add widget and separator to base layout
			pack(layout, widg, i, tags, style)
		end
		------------------------------------------------------------

		if taglist.queue[s] and taglist.queue[s].started then taglist.queue[s]:stop() end
	end

	-- Create timer to prevent multiply call
	--------------------------------------------------------------------------------
	taglist.queue[cs] = timer({ timeout = style.timeout })
	taglist.queue[cs]:connect_signal("timeout", function() update(cs) end)

	local uc = function (c) if taglist.queue[c.screen] then taglist.queue[c.screen]:again() end end
	local ut = function (t) if taglist.queue[t.screen] then taglist.queue[t.screen]:again() end end

	-- Signals setup
	--------------------------------------------------------------------------------
	local tag_signals = {
		"property::selected",  "property::icon", "property::hide",
		"property::activated", "property::name", "property::screen",
		"property::index", "property::layout"
	}
	local client_signals = {
		"focus",  "unfocus",  "property::urgent",
		"tagged", "untagged", "unmanage"
	}

	for _, sg in ipairs(tag_signals) do awful.tag.attached_connect_signal(nil, sg, ut) end
	for _, sg in ipairs(client_signals) do client.connect_signal(sg, uc) end

	client.connect_signal("property::screen", function() update(cs) end) -- dirty

	--------------------------------------------------------------------------------
	update(cs) -- create taglist widget
	return layout  -- return taglist widget
end

-- Filtering functions
-- @param t The awful.tag
-- @param args unused list of extra arguments
-----------------------------------------------------------------------------------------------------------------------
function taglist.filter.noempty(t) -- to include all nonempty tags on the screen.
	return #t:clients() > 0 or t.selected
end

function taglist.filter.all() -- to include all tags on the screen.
	return true
end

-- Config metatable to call taglist module as function
-----------------------------------------------------------------------------------------------------------------------
function taglist.mt:__call(...)
	return taglist.new(...)
end

return setmetatable(taglist, taglist.mt)
