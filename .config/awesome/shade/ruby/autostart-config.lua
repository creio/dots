-----------------------------------------------------------------------------------------------------------------------
--                                              Autostart app list                                                   --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local autostart = {}

-- Application list function
--------------------------------------------------------------------------------
function autostart.run()
	-- environment
	-- awful.spawn.with_shell("python ~/scripts/env/pa-setup.py")
	-- awful.spawn.with_shell("python ~/scripts/env/color-profile-setup.py")
	-- awful.spawn.with_shell("python ~/scripts/env/kbd-setup.py")
	awful.spawn.with_shell("setxkbmap -layout us,ru -option 'grp:win_space_toggle,grp_led:scroll'")

	-- environment
	awful.spawn.with_shell("xsettingsd")
	awful.spawn.with_shell("/usr/lib/xfce-polkit/xfce-polkit")

	-- firefox sync
	-- awful.spawn.with_shell("python ~/scripts/firefox/ff-sync.py")

	-- utilst
	awful.spawn.with_shell("numlockx")
	awful.spawn.with_shell("compton -b")
	-- awful.spawn.with_shell("nm-applet")
	awful.spawn.with_shell("thunar --daemon")
	awful.spawn.with_shell("urxvtd")
	awful.spawn.with_shell("pulseaudio --start")

	-- apps
	awful.spawn.with_shell("redshift-gtk")	
	awful.spawn.with_shell("clipit")
	-- awful.spawn.with_shell("transmission-gtk -m")
	awful.spawn.with_shell("telegram-desktop")
	awful.spawn.with_shell("megasync")
	awful.spawn.with_shell("caffeine")
end

-- Read and commads from file and spawn them
--------------------------------------------------------------------------------
function autostart.run_from_file(file_)
	local f = io.open(file_)
	for line in f:lines() do
		if line:sub(1, 1) ~= "#" then awful.spawn.with_shell(line) end
	end
	f:close()
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return autostart
