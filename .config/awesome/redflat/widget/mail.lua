-----------------------------------------------------------------------------------------------------------------------
--                                               RedFlat mail widget                                                 --
-----------------------------------------------------------------------------------------------------------------------
-- Check if new mail available using python scripts or curl shell command
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local table = table
local tonumber = tonumber

local awful = require("awful")
local beautiful = require("beautiful")
local timer = require("gears.timer")
local naughty = require("naughty")

local rednotify = require("redflat.float.notify")
local tooltip = require("redflat.float.tooltip")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")
local startup = require("redflat.startup")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local mail = { objects = {}, mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon        = redutil.base.placeholder(),
		notify      = {},
		need_notify = true,
		firstrun    = false,
		color       = { main = "#b1222b", icon = "#a0a0a0" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.mail") or {})
end

-- Mail check functions
-----------------------------------------------------------------------------------------------------------------------
mail.checkers = {}

mail.checkers["script"] = { type = "spawn" }
mail.checkers["script"].action = function(args)
	return args.script
end

mail.checkers["curl_imap"] = { type = "spawn" }
mail.checkers["curl_imap"].action = function(args)
	local port = args.port or 993
	local request = "-X 'STATUS INBOX (UNSEEN)'"
	local head_command = "curl --connect-timeout 5 -fsm 5"

	local curl_req = string.format("%s --url imaps://%s:%s/INBOX -u %s:%s %s -k",
	                               head_command, args.server, port, args.mail, args.password, request)

	return curl_req
end

mail.checkers["imap"] = { type = "plain" }
mail.checkers["imap"].action = function(args)
	-- require imap4 library
	-- need to luarock install imap4 library
	local imap4   = require "imap4"

	-- grab args or set default values
    -- gmail requires 'Less secure app access'
    local port = args.port or 993
	local url = args.server or "outlook.office365.com"
	local mailbox = args.mailbox or "Inbox"

	-- setup connection
	local connection = imap4(url, port, {protocol = 'tlsv1_2'})
	assert(connection:isCapable('IMAP4rev1'))
	connection:login(args.username, args.password)

	-- get information
	local stat = connection:status(mailbox, {'UNSEEN'})

	-- close connection
	connection:logout()

	-- return unseen email count
	return stat.UNSEEN
end

-- Initialize mails structure
-----------------------------------------------------------------------------------------------------------------------
function mail:init(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	args = args or {}
	local count  = 0
	local checks = 0
	local force_notify = false
	local update_timeout = args.update_timeout or 3600
	local maillist = args.maillist or {}
	style = redutil.table.merge(default_style(), style or {})

	self.style = style

	-- Set tooltip
	--------------------------------------------------------------------------------
	self.tp = tooltip(nil, style.tooltip)
	self.tp:set_text("?")

	-- Update info function
	--------------------------------------------------------------------------------
	local function mail_count(output)
		local c = tonumber(string.match(output, "%d+"))
		checks = checks + 1

		if c then
			count = count + c
			if style.need_notify and (count > 0 or force_notify and checks == #maillist) then
				rednotify:show(redutil.table.merge({ text = count .. " new messages" }, style.notify))
			end
		end

		self.tp:set_text(count .. " new messages")

		local color = count > 0 and style.color.main or style.color.icon
		for _, widg in ipairs(mail.objects) do widg:set_color(color) end
	end

	self.check_updates = function(is_force)
		count  = 0
		checks = 0
		force_notify = is_force

		for _, cmail in ipairs(maillist) do
			if mail.checkers[cmail.checker].type == "plain" then
				mail_count(mail.checkers[cmail.checker].action(cmail))
			elseif mail.checkers[cmail.checker].type == "spawn" then
				awful.spawn.easy_async(mail.checkers[cmail.checker].action(cmail), mail_count)
			end
		end
	end

	-- Set update timer
	--------------------------------------------------------------------------------
	self.timer = timer({ timeout = update_timeout })
	self.timer:connect_signal("timeout", function() self.check_updates() end)
	self.timer:start()

	if style.firstrun and startup.is_startup then self.timer:emit_signal("timeout") end
end


-- Create a new mail widget
-----------------------------------------------------------------------------------------------------------------------
function mail.new(style)

	if not mail.style then
		naughty.notify({ title = "Warning!", text = "Mail widget doesn't configured" })
		mail:init({})
	end

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(mail.style, style or {})

	-- Create widget
	--------------------------------------------------------------------------------
	local widg = svgbox(style.icon)
	widg:set_color(style.color.icon)
	table.insert(mail.objects, widg)

	-- Set tooltip
	--------------------------------------------------------------------------------
	mail.tp:add_to_object(widg)

	--------------------------------------------------------------------------------
	return widg
end

-- Update mail info for every widget
-----------------------------------------------------------------------------------------------------------------------
function mail:update(is_force)
	self.check_updates(is_force)
end

-- Config metatable to call mail module as function
-----------------------------------------------------------------------------------------------------------------------
function mail.mt:__call(...)
	return mail.new(...)
end

return setmetatable(mail, mail.mt)
