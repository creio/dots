-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat tasklist widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Custom widget used to show apps, see redtask.lua for more info
-- No icons; labels can be customized in beautiful theme file
-- Same class clients grouped into one object
-- Pop-up tooltip with task names
-- Pop-up menu with window state info
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.widget.tasklist v3.5.2
------ (c) 2008-2009 Julien Danjou
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local table = table
local string = string
local math = math
local unpack = unpack or table.unpack

local beautiful = require("beautiful")
local tag = require("awful.tag")
local awful = require("awful")
local wibox = require("wibox")
local timer = require("gears.timer")

local basetask = require("redflat.gauge.tag.blue")
local redutil = require("redflat.util")
local separator = require("redflat.gauge.separator")
local redmenu = require("redflat.menu")
local svgbox = require("redflat.gauge.svgbox")
local dfparser = require("redflat.service.dfparser")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local redtasklist = { filter = {}, winmenu = {}, tasktip = {}, action = {}, mt = {}, }

local last = {
	client         = nil,
	group          = nil,
	client_list    = nil,
	screen         = mouse.screen,
	tag_screen     = mouse.screen,
	screen_clients = {}
}

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		appnames    = {},
		iconnames   = {},
		widget      = basetask.new,
		width       = 40,
		char_digit  = 3,
		need_group  = true,
		parser      = {},
		icons       = {},
		timeout     = 0.05,
		custom_icon = false,
		task        = {},
		task_margin = { 5, 5, 0, 0 }
	}
	style.winmenu = {
		icon           = { unknown = redutil.base.placeholder() },
		micon          = { blank = redutil.base.placeholder({ txt = " " }),
		                   check = redutil.base.placeholder({ txt = "+" }) },
		layout_icon    = { unknown = redutil.base.placeholder() },
		titleline      = { font = "Sans 16 bold", height = 35 },
		stateline      = { height = 35 },
		state_iconsize = { width = 20, height = 20 },
		separator      = { marginh = { 3, 3, 5, 5 } },
		tagmenu        = { icon_margin = { 2, 2, 2, 2 } },
		hide_action    = { min = true,
		                   move = true,
		                   max = false,
		                   add = false,
		                   floating = false,
		                   sticky = false,
		                   ontop = false,
		                   below = false,
		                   maximized = false },
		color          = { main = "#b1222b", icon = "#a0a0a0", gray = "#404040" }
	}
	style.tasktip = {
		border_width = 2,
		margin       = { 10, 10, 5, 5 },
		timeout      = 0.5,
		sl_highlight = false, -- single line highlight
		color        = { border = "#575757", text = "#aaaaaa", main = "#b1222b", highlight = "#eeeeee",
		                 wibox = "#202020", gray = "#575757", urgent = "#32882d" },
		shape        = nil

	}
	style.winmenu.menu = {
		ricon_margin = { 2, 2, 2, 2 },
		hide_timeout = 1,
		-- color        = { submenu_icon = "#a0a0a0", right_icon = "#a0a0a0", left_icon = "#a0a0a0" }
		nohide       = true
	}

	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.tasklist") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Get info about client group
--------------------------------------------------------------------------------
local function get_state(c_group, style)

	style = style or {}
	local names = style.appnames or {}
	local chars = style.char_digit

	local state = { focus = false, urgent = false, minimized = true, list = {} }

	for _, c in pairs(c_group) do
		state.focus     = state.focus or client.focus == c
		state.urgent    = state.urgent or c.urgent
		state.minimized = state.minimized and c.minimized

		table.insert(state.list, { focus = client.focus == c, urgent = c.urgent, minimized = c.minimized })
	end

	local class = c_group[1].class or "Undefined"
	state.text = names[class] or string.upper(string.sub(class, 1, chars))
	state.num = #c_group
	state.icon = style.custom_icon and style.icons[style.iconnames[class] or string.lower(class)]

	return state
end

-- Function to build item list for submenu
--------------------------------------------------------------------------------
local function tagmenu_items(action, style)
	local items = {}
	for _, t in ipairs(last.screen.tags) do
		if not awful.tag.getproperty(t, "hide") then
			table.insert(
				items,
				{ t.name, function() action(t) end, style.micon.blank, style.micon.blank }
			)
		end
	end
	return items
end

-- Function to rebuild the submenu entries according to current screen's tags
--------------------------------------------------------------------------------
local function tagmenu_rebuild(menu, submenu_index, style)
	for _, index in ipairs(submenu_index) do
			local new_items
			if index == 1 then
				new_items = tagmenu_items(redtasklist.winmenu.movemenu_action, style)
			else
				new_items = tagmenu_items(redtasklist.winmenu.addmenu_action, style)
			end
			menu.items[index].child:replace_items(new_items)
	end
end

-- Function to update tag submenu icons
--------------------------------------------------------------------------------
local function tagmenu_update(c, menu, submenu_index, style)
	-- if the screen has changed (and thus the tags) since the last time the
	-- tagmenu was built, rebuild it first
	if last.tag_screen ~= mouse.screen then
		tagmenu_rebuild(menu, submenu_index, style)
		last.tag_screen = mouse.screen
	end
	for k, t in ipairs(last.screen.tags) do
		if not awful.tag.getproperty(t, "hide") then

			-- set layout icon for every tag
			local l = awful.layout.getname(awful.tag.getproperty(t, "layout"))

			local check_icon = style.micon.blank
			if c then
				local client_tags = c:tags()
				check_icon = awful.util.table.hasitem(client_tags, t) and style.micon.check or check_icon
			end

			for _, index in ipairs(submenu_index) do
				local submenu = menu.items[index].child
				if submenu.items[k].icon then
					submenu.items[k].icon:set_image(style.layout_icon[l] or style.layout_icon.unknown)
				end

				-- set "checked" icon if tag active for given client
				-- otherwise set empty icon
				if c then
					if submenu.items[k].right_icon then
						submenu.items[k].right_icon:set_image(check_icon)
					end
				end

				-- update position of any visible submenu
				if submenu.wibox.visible then submenu:show() end
			end
		end
	end
end

-- Function to construct menu line with state icons
--------------------------------------------------------------------------------
local function state_line_construct(state_icons, setup_layout, style)
	local stateboxes = {}

	for i, v in ipairs(state_icons) do
		-- create widget
		stateboxes[i] = svgbox(v.icon)
		stateboxes[i]:set_forced_width(style.state_iconsize.width)
		stateboxes[i]:set_forced_height(style.state_iconsize.height)

		-- set widget in line
		local l = wibox.layout.align.horizontal()
		l:set_expand("outside")
		l:set_second(stateboxes[i])
		setup_layout:add(l)

		-- set mouse action
		stateboxes[i]:buttons(awful.util.table.join(awful.button({}, 1,
			function()
				v.action()
				stateboxes[i]:set_color(v.indicator(last.client) and style.color.main or style.color.gray)
			end
		)))
	end

	return stateboxes
end

-- Calculate menu position
-- !!! Bad code is here !!!
-- !!! TODO: make variant when panel place on top of screen !!!
--------------------------------------------------------------------------------
local function coords_calc(menu, tip_wibox, gap)
	local coords = {}

	if gap then
		coords.x = tip_wibox.x + (tip_wibox.width - menu.wibox.width) / 2
		coords.y = tip_wibox.y - menu.wibox.height - 2 * menu.wibox.border_width + tip_wibox.border_width + gap
	else
		coords = mouse.coords()
		coords.x = coords.x - menu.wibox.width / 2 - menu.wibox.border_width
	end

	return coords
end

-- Create tasklist object
--------------------------------------------------------------------------------
local function new_task(c_group, style)
	local task = {}
	task.widg  = style.widget(style.task)
	task.group = c_group
	task.l     = wibox.container.margin(task.widg, unpack(style.task_margin))

	task.widg:connect_signal("mouse::enter", function() redtasklist.tasktip:show(task.group) end)
	task.widg:connect_signal("mouse::leave",
		function()
			redtasklist.tasktip.hidetimer:start()
			if not redtasklist.winmenu.menu.hidetimer.started then redtasklist.winmenu.menu.hidetimer:start() end
		end
	)
	return task
end

-- Find all clients to be shown
--------------------------------------------------------------------------------
local function visible_clients(filter, screen)
	local clients = {}

	for _, c in ipairs(client.get()) do
		local hidden = c.skip_taskbar or c.hidden or c.type == "splash" or c.type == "dock" or c.type == "desktop"

		if not hidden and filter(c, screen) then
			table.insert(clients, c)
		end
	end

	return clients
end

-- Split tasks into groups by class
--------------------------------------------------------------------------------
local function group_task(clients, need_group)
	local client_groups = {}
	local classes = {}

	for _, c in ipairs(clients) do
		if need_group then
			local index = awful.util.table.hasitem(classes, c.class or "Undefined")
			if index then
				table.insert(client_groups[index], c)
			else
				table.insert(classes, c.class or "Undefined")
				table.insert(client_groups, { c })
			end
		else
			table.insert(client_groups, { c })
		end
	end

	return client_groups
end

-- Form ordered client list special for switch function
--------------------------------------------------------------------------------
local function sort_list(client_groups)
	local list = {}

	for _, g in ipairs(client_groups) do
		for _, c in ipairs(g) do
			if not c.minimized then table.insert(list, c) end
		end
	end

	return list
end

-- Create tasktip line
--------------------------------------------------------------------------------
local function tasktip_line(style)
	local line = {}

	-- text
	line.tb = wibox.widget.textbox()

	-- horizontal align wlayout
	local horizontal = wibox.layout.fixed.horizontal()
	horizontal:add(wibox.container.margin(line.tb, unpack(style.margin)))

	-- background for client state mark
	line.field = wibox.container.background(horizontal)

	-- tasktip line metods
	function line:set_text(text)
		line.tb:set_markup(text)

		if style.max_width then
			line.tb:set_ellipsize("middle")
			local _, line_h = line.tb:get_preferred_size()
			line.tb:set_forced_height(line_h)
			line.tb:set_forced_width(style.max_width)
		end

		line.field:set_fg(style.color.text)
		line.field:set_bg(style.color.wibox)
	end

	function line:mark_focused()
		line.field:set_bg(style.color.main)
		line.field:set_fg(style.color.highlight)
	end

	function line:mark_urgent()
		line.field:set_bg(style.color.urgent)
		line.field:set_fg(style.color.highlight)
	end

	function line:mark_minimized()
		line.field:set_fg(style.color.gray)
	end

	return line
end

-- Switch task
--------------------------------------------------------------------------------
local function switch_focus(list, is_reverse)
	local diff = is_reverse and - 1 or 1

	if #list == 0 then return end

	local index = (awful.util.table.hasitem(list, client.focus) or 1) + diff

	if     index < 1 then index = #list
	elseif index > #list then index = 1
	end

	-- set focus to new task
	client.focus = list[index]
	list[index]:raise()
end

local function client_group_sort_by_class(a, b)
	return (a[1].class or "Undefined") < (b[1].class or "Undefined")
end

-- Build or update tasklist.
--------------------------------------------------------------------------------
local function tasklist_construct(client_groups, layout, data, buttons, style)

	layout:reset()
	local task_full_width = style.width + style.task_margin[1] + style.task_margin[2]
	layout:set_max_widget_size(task_full_width)
	layout:set_forced_width(task_full_width * #client_groups)

	-- construct tasklist
	for i, c_group in ipairs(client_groups) do
		local task

		-- use existing widgets or create new
		if data[i] then
			task = data[i]
			task.group = c_group
		else
			task = new_task(c_group, style)
			data[i] = task
		end

		-- set info and buttons to widget
		local state = get_state(c_group, style)
		task.widg:set_state(state)
		task.widg:buttons(redutil.base.buttons(buttons, { group = c_group }))

		-- construct
		layout:add(task.l)
	end
end

-- Construct or update tasktip
--------------------------------------------------------------------------------
local function construct_tasktip(c_group, layout, data, buttons, style)
	layout:reset()
	local tb_w, tb_h
	local tip_width = 1

	for i, c in ipairs(c_group) do
		local line

		-- use existing widgets or create new
		if data[i] then
			line = data[i]
		else
			line = tasktip_line(style)
			data[i] = line
		end

		line:set_text(awful.util.escape(c.name) or "Untitled")
		tb_w, tb_h = line.tb:get_preferred_size()
		if line.tb.forced_width then
			tb_w = math.min(line.tb.forced_width, tb_w)
		end

		-- set state highlight only for grouped tasks
		if #c_group > 1 or style.sl_highlight then
			local state = get_state({ c })

			if state.focus     then line:mark_focused()   end
			if state.minimized then line:mark_minimized() end
			if state.urgent    then line:mark_urgent()    end
		end

		-- set buttons
		local gap = (i - 1) * (tb_h + style.margin[3] + style.margin[4])
		if buttons then line.field:buttons(redutil.base.buttons(buttons, { group = { c }, gap = gap })) end

		-- add line widget to tasktip layout
		tip_width = math.max(tip_width, tb_w)
		layout:add(line.field)
	end

	-- return tasktip size
	return {
		width  = tip_width + style.margin[1] + style.margin[2],
		height = #c_group * (tb_h + style.margin[3] + style.margin[4])
	}
end


-- Initialize window menu widget
-----------------------------------------------------------------------------------------------------------------------
function redtasklist.winmenu:init(style)

	-- Window managment functions
	--------------------------------------------------------------------------------
	self.hide_check = function(action)
		if style.hide_action[action] then self.menu:hide() end
	end

	local close    = function() last.client:kill(); self.menu:hide() end
	local minimize = function() last.client.minimized = not last.client.minimized; self.hide_check("min") end
	-- local maximize = function() last.client.maximized = not last.client.maximized; self.hide_check("max")end

	-- Create array of state icons
	-- associate every icon with action and state indicator
	--------------------------------------------------------------------------------
	local function icon_table_ganerator(property)
		return {
			icon      = style.icon[property] or style.icon.unknown,
			action    = function() last.client[property] = not last.client[property]; self.hide_check(property) end,
			indicator = function(c) return c[property] end
		}
	end

	local state_icons = {
		icon_table_ganerator("floating"),
		icon_table_ganerator("sticky"),
		icon_table_ganerator("ontop"),
		icon_table_ganerator("below"),
		icon_table_ganerator("maximized"),
	}

	-- Construct menu
	--------------------------------------------------------------------------------

	-- Client class line (menu title) construction
	------------------------------------------------------------
	local classbox = wibox.widget.textbox()
	classbox:set_font(style.titleline.font)
	classbox:set_align ("center")

	local classline = wibox.container.constraint(classbox, "exact", nil, style.titleline.height)

	-- Window state line construction
	------------------------------------------------------------

	-- layouts
	local stateline_horizontal = wibox.layout.flex.horizontal()
	local stateline_vertical = wibox.layout.align.vertical()
	stateline_vertical:set_second(stateline_horizontal)
	stateline_vertical:set_expand("outside")
	local stateline = wibox.container.constraint(stateline_vertical, "exact", nil, style.stateline.height)

	-- set all state icons in line
	local stateboxes = state_line_construct(state_icons, stateline_horizontal, style)

	-- update function for state icons
	local function stateboxes_update(c, icons, boxes)
		for i, v in ipairs(icons) do
			boxes[i]:set_color(v.indicator(c) and style.color.main or style.color.gray)
		end
	end

	-- Separators config
	------------------------------------------------------------
	local menusep = { widget = separator.horizontal(style.separator) }

	-- Construct tag submenus ("move" and "add")
	------------------------------------------------------------

	-- menu item actions
	self.movemenu_action = function(t)
		last.client:move_to_tag(t); awful.layout.arrange(t.screen); self.hide_check("move")
	end

	self.addmenu_action = function(t)
		last.client:toggle_tag(t); awful.layout.arrange(t.screen); self.hide_check("add")
	end

	-- menu items
	local movemenu_items = tagmenu_items(self.movemenu_action, style)
	local addmenu_items = tagmenu_items(self.addmenu_action, style)

	-- Create menu
	------------------------------------------------------------
	self.menu = redmenu({
		theme = style.menu,
		items = {
			{ widget = classline },
			menusep,
			{ "Move to tag", { items = movemenu_items, theme = style.tagmenu } },
			{ "Add to tag",  { items = addmenu_items,  theme = style.tagmenu } },

			{ "Minimize",    minimize, nil, style.icon.minimize or style.icon.unknown },
			{ "Close",       close,    nil, style.icon.close or style.icon.unknown },
			menusep,
			{ widget = stateline, focus = true }
		}
	})

	-- Widget update functions
	--------------------------------------------------------------------------------
	function self:update(c)
		if self.menu.wibox.visible then
			classbox:set_text(c.class or "Undefined")
			stateboxes_update(c, state_icons, stateboxes)
			tagmenu_update(c, self.menu, { 1, 2 }, style)
		end
	end

	-- Signals setup
	-- Signals which affect window menu only
	-- and does not connected to tasklist
	--------------------------------------------------------------------------------
	local client_signals = {
		"property::ontop", "property::floating", "property::below", "property::maximized",
	}
	for _, sg in ipairs(client_signals) do
		client.connect_signal(sg, function() self:update(last.client) end)
	end
end

-- Show window menu widget
-----------------------------------------------------------------------------------------------------------------------
function redtasklist.winmenu:show(c_group, gap)

	-- do nothing if group of task received
	-- show state only for single task
	if #c_group > 1 then return end

	local c = c_group[1]

	-- toggle menu
	if self.menu.wibox.visible and c == last.client and mouse.screen == last.screen  then
		self.menu:hide()
	else
		last.client = c
		last.screen = mouse.screen
		self.menu:show({ coords = coords_calc(self.menu, redtasklist.tasktip.wibox, gap) })

		if self.menu.hidetimer.started then self.menu.hidetimer:stop() end
		self:update(c)
	end
end


-- Initialize a tasktip
-----------------------------------------------------------------------------------------------------------------------
function redtasklist.tasktip:init(buttons, style)

	local tippat = {}

	-- Create wibox
	--------------------------------------------------------------------------------
	self.wibox = wibox({
		type = "tooltip",
		bg   = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border,
		shape        = style.shape
	})

	self.wibox.ontop = true

	self.layout = wibox.layout.fixed.vertical()
	self.wibox:set_widget(self.layout)

	-- Update function
	--------------------------------------------------------------------------------
	function self:update(c_group)

		if not self.wibox.visible then return end

		local wg = construct_tasktip(c_group, self.layout, tippat, buttons, style)
		self.wibox:geometry(wg)
	end

	-- Set tasktip autohide timer
	--------------------------------------------------------------------------------
	self.hidetimer = timer({ timeout = style.timeout })
	self.hidetimer:connect_signal("timeout",
		function()
			self.wibox.visible = false
			if self.hidetimer.started then self.hidetimer:stop() end
		end
	)
	self.hidetimer:emit_signal("timeout")

	-- Signals setup
	--------------------------------------------------------------------------------
	self.wibox:connect_signal("mouse::enter",
		function()
			if self.hidetimer.started then self.hidetimer:stop() end
		end
	)

	self.wibox:connect_signal("mouse::leave",
		function()
			self.hidetimer:start()
			if not redtasklist.winmenu.menu.hidetimer.started then redtasklist.winmenu.menu.hidetimer:start() end
		end
	)
end

-- Show tasktip
-----------------------------------------------------------------------------------------------------------------------
function redtasklist.tasktip:show(c_group)

	if self.hidetimer.started then self.hidetimer:stop() end

	if not self.wibox.visible or last.group ~= c_group then
		self.wibox.visible = true
		last.group = c_group
		self:update(c_group)
		awful.placement.under_mouse(self.wibox)
		awful.placement.no_offscreen(self.wibox)
	end
end

-- Create a new tasklist widget
-----------------------------------------------------------------------------------------------------------------------
function redtasklist.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local cs = args.screen
	local filter = args.filter or redtasklist.filter.currenttags

	style = redutil.table.merge(default_style(), style or {})
	if style.custom_icon then style.icons = dfparser.icon_list(style.parser) end
	if style.task.width  then style.width = style.task.width end

	redtasklist.winmenu:init(style.winmenu)
	redtasklist.tasktip:init(args.buttons, style.tasktip)

	local tasklist = wibox.layout.flex.horizontal()
	local data = {}

	-- Update tasklist
	--------------------------------------------------------------------------------

	-- Tasklist update function
	------------------------------------------------------------
	local function tasklist_update()
		local clients = visible_clients(filter, cs)
		local client_groups = group_task(clients, style.need_group)

		table.sort(client_groups, client_group_sort_by_class)
		last.screen_clients[cs] = sort_list(client_groups)

		tasklist_construct(client_groups, tasklist, data, args.buttons, style)
	end

	-- Full update including pop-up widgets
	------------------------------------------------------------
	local function update()
		tasklist_update()
		redtasklist.tasktip:update(last.group)
		redtasklist.winmenu:update(last.client)
	end

	-- Create timer to prevent multiply call
	--------------------------------------------------------------------------------
	tasklist.queue = timer({ timeout = style.timeout })
	tasklist.queue:connect_signal("timeout", function() update(cs); tasklist.queue:stop() end)

	-- Signals setup
	--------------------------------------------------------------------------------
	local client_signals = {
		"property::urgent", "property::sticky", "property::minimized",
		"property::name", "  property::icon",   "property::skip_taskbar",
		"property::screen", "property::hidden",
		"tagged", "untagged", "list", "focus", "unfocus"
	}

	local tag_signals = { "property::selected", "property::activated" }

	-- for _, sg in ipairs(client_signals) do client.connect_signal(sg, update) end
	-- for _, sg in ipairs(tag_signals)    do tag.attached_connect_signal(cs, sg, update) end
	for _, sg in ipairs(client_signals) do client.connect_signal(sg, function() tasklist.queue:again() end) end
	for _, sg in ipairs(tag_signals) do tag.attached_connect_signal(cs, sg, function() tasklist.queue:again() end) end

	-- force hide pop-up widgets if any client was closed
	-- because last vars may be no actual anymore
	client.connect_signal("unmanage",
		function()
			tasklist_update()
			redtasklist.tasktip.wibox.visible = false
			redtasklist.winmenu.menu:hide()
			last.client = nil
			last.group  = nil
		end
	)

	-- Construct
	--------------------------------------------------------------------------------
	update()

	return tasklist
end

-- Mouse action functions
-----------------------------------------------------------------------------------------------------------------------

-- focus/minimize
function redtasklist.action.select(args)
	args = args or {}
	local state = get_state(args.group)

	if state.focus then
		for _, c in ipairs(args.group) do c.minimized = true end
	else
		if state.minimized then
			for _, c in ipairs(args.group) do c.minimized = false end
		end

		client.focus = args.group[1]
		args.group[1]:raise()
	end
end

-- close all in group
function redtasklist.action.close(args)
	args = args or {}
	for _, c in ipairs(args.group) do c:kill() end
end

-- show/close winmenu
function redtasklist.action.menu(args)
	args = args or {}
	redtasklist.winmenu:show(args.group, args.gap)
end

-- switch to next task
function redtasklist.action.switch_next()
	switch_focus(last.screen_clients[mouse.screen])
end

-- switch to previous task
function redtasklist.action.switch_prev()
	switch_focus(last.screen_clients[mouse.screen], true)
end


-- Filtering functions
-- @param c The client
-- @param screen The screen we are drawing on
-----------------------------------------------------------------------------------------------------------------------

-- To include all clients
--------------------------------------------------------------------------------
function redtasklist.filter.allscreen()
	return true
end

-- To include the clients from all tags on the screen
--------------------------------------------------------------------------------
function redtasklist.filter.alltags(c, screen)
	return c.screen == screen
end

-- To include only the clients from currently selected tags
--------------------------------------------------------------------------------
function redtasklist.filter.currenttags(c, screen)
	if c.screen ~= screen then return false end
	if c.sticky then return true end

	local tags = screen.tags

	for _, t in ipairs(tags) do
		if t.selected then
			local ctags = c:tags()

			for _, v in ipairs(ctags) do
				if v == t then return true end
			end
		end
	end

	return false
end

-- To include only the minimized clients from currently selected tags
--------------------------------------------------------------------------------
function redtasklist.filter.minimizedcurrenttags(c, screen)
	if c.screen ~= screen then return false end
	if not c.minimized then return false end
	if c.sticky then return true end

	local tags = screen.tags

	for _, t in ipairs(tags) do
		if t.selected then
			local ctags = c:tags()

			for _, v in ipairs(ctags) do
				if v == t then return true end
			end
		end
	end

	return false
end

-- To include only the currently focused client
--------------------------------------------------------------------------------
function redtasklist.filter.focused(c, screen)
	return c.screen == screen and client.focus == c
end

-- Config metatable to call redtasklist module as function
-----------------------------------------------------------------------------------------------------------------------
function redtasklist.mt:__call(...)
	return redtasklist.new(...)
end

return setmetatable(redtasklist, redtasklist.mt)
