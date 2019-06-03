-----------------------------------------------------------------------------------------------------------------------
--                                              RedFlat updates widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Show if system updates available using apt-get
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local table = table
local string = string
local os = os
local unpack = unpack or table.unpack

local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local timer = require("gears.timer")

local rednotify = require("redflat.float.notify")
local tooltip = require("redflat.float.tooltip")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")
local separator = require("redflat.gauge.separator")
local redtip = require("redflat.float.hotkeys")
local startup = require("redflat.startup")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
-- TODO: weak table for all multi panel widget
local updates = { objects = {}, mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		wibox = {
			geometry     = { width = 400, height = 200 },
			border_width = 2,
			title_font   = "Sans 14 bold",
			tip_font     = "Sans 10",
			set_position = nil,
			separator    = {},
			shape        = nil,
			icon         = {
				package = redutil.base.placeholder(),
				close   = redutil.base.placeholder({ txt = "X" }),
				daily   = redutil.base.placeholder(),
				weekly  = redutil.base.placeholder(),
				normal  = redutil.base.placeholder(),
				silent  = redutil.base.placeholder(),
			},
			height = { title = 40, state = 50, tip = 20 },
			margin = { close = { 0, 0, 0, 0 }, state = { 0, 0, 0, 0 }, title = { 0, 0, 0, 0 }, image = { 0, 0, 0, 0 } }
		},
		icon        = redutil.base.placeholder(),
		keytip      = { geometry = { width = 400 } },
		notify      = {},
		firstrun    = false,
		need_notify = true,
		tooltip     = {
			base = {},
			state = {
				timeout = 3,
				set_position = function(w) awful.placement.under_mouse(w) w.y = w.y - 30 end,
			}
		},
		color       = { main = "#b1222b", icon = "#a0a0a0", wibox = "#202020", border = "#575757", gray = "#404040",
		                urgent = "#32882d" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.updates") or {})
end


local STATE = setmetatable(
	{ keywords = { "NORMAL", "DAILY", "WEEKLY", "SILENT" } },
	{ __index = function(table_, key)
		return awful.util.table.hasitem(table_.keywords, key) or rawget(table_, key)
	end }
)

local tips = {}
tips[STATE.NORMAL] = "regular notifications"
tips[STATE.DAILY]  = "postponed for a day"
tips[STATE.WEEKLY] = "postponed for a week"
tips[STATE.SILENT] = "notifications disabled"

-- key bindings
updates.keys = {}
updates.keys.control = {
	{
		{}, "1", function() updates.set_mode(STATE.NORMAL) end,
		{ description = "Regular notifications", group = "Notifications" }
	},
	{
		{}, "2", function() updates.set_mode(STATE.DAILY) end,
		{ description = "Postponed for a day", group = "Notifications" }
	},
	{
		{}, "3", function() updates.set_mode(STATE.WEEKLY) end,
		{ description = "Postponed for a week", group = "Notifications" }
	},
	{
		{}, "4", function() updates.set_mode(STATE.SILENT) end,
		{ description = "Notifications disabled", group = "Notifications" }
	},
}
updates.keys.action = {
	{
		{}, "u", function() updates:update(true) end,
		{ description = "Check updates", group = "Action" }
	},
	{
		{}, "Escape", function() updates:hide() end,
		{ description = "Close updates widget", group = "Action" }
	},
	{
		{ "Mod4" }, "F1", function() redtip:show() end,
		{ description = "Show hotkeys helper", group = "Action" }
	},
}

updates.keys.all = awful.util.table.join(updates.keys.control, updates.keys.action)


-- Initialize notify widbox
-----------------------------------------------------------------------------------------------------------------------
function updates:init(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	args = args or {}
	local update_timeout = args.update_timeout or 3600
	local command = args.command or "echo 0"
	local force_notify = false
	style = redutil.table.merge(default_style(), style or {})


	self.style = style
	self.is_updates = false
	self.config = awful.util.getdir("cache") .. "/updates"

	-- Create floating wibox for updates widget
	--------------------------------------------------------------------------------
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		shape        = style.shape,
		border_width = style.wibox.border_width,
		border_color = style.color.border
	})

	self.wibox:geometry(style.wibox.geometry)

	-- Floating widget structure
	--------------------------------------------------------------------------------

	-- main image
	self.packbox = svgbox(style.wibox.icon.package, nil, style.color.icon)

	-- titlebar
	self.titlebox = wibox.widget.textbox("0 UPDATES")
	self.titlebox:set_font(style.wibox.title_font)
	self.titlebox:set_align("center")

	-- tip line
	--self.tipbox = wibox.widget.textbox()
	--self.tipbox:set_font(style.wibox.tip_font)
	--self.tipbox:set_align("center")
	--self.tipbox:set_forced_height(style.wibox.height.tip)

	-- close button
	local closebox = svgbox(style.wibox.icon.close, nil, style.color.icon)
	closebox:buttons(awful.util.table.join(awful.button({}, 1, function() self:hide() end)))
	closebox:connect_signal("mouse::enter", function() closebox:set_color(style.color.main) end)
	closebox:connect_signal("mouse::leave", function() closebox:set_color(style.color.icon) end)

	-- Control buttons
	------------------------------------------------------------
	local statebox = {}
	local statearea = wibox.layout.flex.horizontal()
	statearea:set_forced_height(style.wibox.height.state)

	-- color update fucntions
	local function update_state()
		for k, box in pairs(statebox) do
			box:set_color(STATE[k] == self.state and style.color.main or style.color.gray)
		end
		--self.tipbox:set_markup(string.format('<span color="%s">%s</span>', style.color.gray, tips[self.state]))
	end

	local function check_alert()
		local time = os.time()
		return self.is_updates and
		       (  self.state == STATE.NORMAL
		       or self.state == STATE.DAILY  and (time - self.time > 24 * 3600)
		       or self.state == STATE.WEEKLY and (time - self.time > 7 * 24 * 3600))
	end

	local function update_widget_colors()
		local is_alert = check_alert()
		local color = is_alert and style.color.main or style.color.icon
		for _, w in ipairs(updates.objects) do w:set_color(color) end
	end

	-- create control buttons
	function self.set_mode(state)
		if self.state ~= state then
			self.state = state
			self.time  = (state == STATE.DAILY or state == STATE.WEEKLY) and os.time() or 0
			update_state()
			update_widget_colors()
		end
	end

	for state, k in pairs(STATE.keywords) do
		statebox[k] = svgbox(style.wibox.icon[k:lower()], nil, style.color.gray)
		local tp = tooltip({ objects = { statebox[k] } }, style.tooltip.state)
		tp:set_text(tips[state])

		statebox[k]:buttons(awful.util.table.join(
			awful.button({}, 1, function() self.set_mode(state) end)
		))

		local area = wibox.layout.align.horizontal()
		area:set_middle(statebox[k])
		area:set_expand("outside")

		statearea:add(area)
	end

	-- Setup wibox layouts
	------------------------------------------------------------
	local titlebar = wibox.widget({
		nil,
		self.titlebox,
		wibox.container.margin(closebox, unpack(style.wibox.margin.close)),
		forced_height = style.wibox.height.title,
		layout        = wibox.layout.align.horizontal
	})

	self.wibox:setup({
		{
			nil,
			wibox.container.margin(titlebar, unpack(style.wibox.margin.title)),
			separator.horizontal(style.wibox.separator),
			layout = wibox.layout.align.vertical
		},
		{
			nil,
			{
				nil, wibox.container.margin(self.packbox, unpack(style.wibox.margin.image)), nil,
				expand = "outside",
				layout = wibox.layout.align.horizontal
			},
			--self.tipbox,
			nil,
			layout = wibox.layout.align.vertical
		},
		wibox.container.margin(statearea, unpack(style.wibox.margin.state)),
		layout = wibox.layout.align.vertical
	})

	-- Widget keygrabber
	--------------------------------------------------------------------------------
	self.keygrabber = function(mod, key, event)
		if     event ~= "press" then return end
		for _, k in ipairs(self.keys.all) do
			if redutil.key.match_grabber(k, mod, key) then k[3](); return end
		end
	end

	-- Start up setup
	------------------------------------------------------------
	self:load_state()
	self:set_keys()
	update_state()

	-- Set tooltip
	--------------------------------------------------------------------------------
	self.tp = tooltip(nil, style.tooltip.base)
	self.tp:set_text("?")

	-- Update info function
	--------------------------------------------------------------------------------
	local function update_count(output)
		local c = string.match(output, "(%d+)")

		self.is_updates = tonumber(c) > 0
		local is_alert = check_alert()

		if style.need_notify and (is_alert or force_notify) then
			rednotify:show(redutil.table.merge({ text = c .. " updates available" }, style.notify))
		end
		self.titlebox:set_text(c .. " UPDATES")
		self.packbox:set_color(tonumber(c) > 0  and style.color.main or style.color.icon)

		if self.tp then self.tp:set_text(c .. " updates") end
		update_widget_colors()
	end

	-- Set update timer
	--------------------------------------------------------------------------------
	self.check_updates = function(is_force)
		force_notify = is_force
		awful.spawn.easy_async_with_shell(command, update_count)
	end

	updates.timer = timer({ timeout = update_timeout })
	updates.timer:connect_signal("timeout", function() self.check_updates() end)
	updates.timer:start()

	if style.firstrun and startup.is_startup then updates.timer:emit_signal("timeout") end

	-- Connect additional signals
	------------------------------------------------------------
	awesome.connect_signal("exit", function() self:save_state() end)
end

-- Create a new updates widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function updates.new(style)

	if not updates.wibox then updates:init({}) end

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(updates.style, style or {})

	local widg = svgbox(style.icon)
	widg:set_color(style.color.icon)
	table.insert(updates.objects, widg)

	updates.tp:add_to_object(widg)

	--------------------------------------------------------------------------------
	return widg
end

-- Show/hide updates wibox
-----------------------------------------------------------------------------------------------------------------------
function updates:show()
	if self.style.wibox.set_position then
		self.style.wibox.set_position(self.wibox)
	else
		redutil.placement.centered(self.wibox, nil, mouse.screen.workarea)
	end
	redutil.placement.no_offscreen(self.wibox, self.style.screen_gap, screen[mouse.screen].workarea)

	self.wibox.visible = true
	awful.keygrabber.run(self.keygrabber)
	redtip:set_pack("System updates", self.tip, self.style.keytip.column, self.style.keytip.geometry)
end

function updates:hide()
	self.wibox.visible = false
	awful.keygrabber.stop(self.keygrabber)
	redtip:remove_pack()
end

function updates:toggle()
	if self.wibox.visible then
		self:hide()
	else
		self:show()
	end
end

-- Save/restore state between sessions
-----------------------------------------------------------------------------------------------------------------------
function updates:load_state()
	local info = redutil.read.file(self.config)
	if info then
		local state, time = string.match(info, "(%d)=(%d+)")
		self.state, self.time = tonumber(state), tonumber(time)
	else
		self.state = STATE.NORMAL
		self.time = 0
	end
end

function updates:save_state()
	local file = io.open(self.config, "w")
	file:write(string.format("%d=%d", self.state, self.time))
	file:close()
end

-- Set user hotkeys
-----------------------------------------------------------------------------------------------------------------------
function updates:set_keys(keys, layout)
	layout = layout or "all"
	if keys then
		self.keys[layout] = keys
		if layout ~= "all" then self.keys.all = awful.util.table.join(self.keys.control, self.keys.action) end
	end

	self.tip = self.keys.all
end

-- Update updates info for every widget
-----------------------------------------------------------------------------------------------------------------------
function updates:update(is_force)
	self.check_updates(is_force)
end

-- Config metatable to call updates module as function
-----------------------------------------------------------------------------------------------------------------------
function updates.mt:__call(...)
	return updates.new(...)
end

return setmetatable(updates, updates.mt)
