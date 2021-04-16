conky.config = {
    alignment = 'top_left',
    background = true,
    default_color = 'a5adff',
    color0 = '494b5a',
    color1 = '494b5a',
    color2 = '494b5a',
    color3 = '23ada0',
    color4 = 'af2445',
    color5 = 'a5adff',
    color6 = 'a5adff',
    cpu_avg_samples = 2,
    diskio_avg_samples = 2,
    double_buffer = true,
    font = 'Ubuntu:size=9:style=regular',
    font2 = 'Ubuntu:size=9:style=bold',
    draw_shades = false,
    draw_outline = false,
    draw_borders = false,
    draw_graph_borders = false,
    border_inner_margin = 0,
    border_outer_margin = 0,
    border_width = 0,
    stippled_borders = 0,
    pad_percents = 0,
    gap_x = 5,
    gap_y = 0,
    maximum_width = 200,
    minimum_width = 200,
    no_buffers = true,
    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    out_to_x = true,
    own_window = true,
    own_window_type = 'override',
    own_window_transparent = true,
    update_interval = 1,
    use_xft = true,
    uppercase = false,
}

conky.text = [[

# DATE
${color}${alignc}${font Ubuntu:size=10}${time %a %b %d}${font}
${color0}${hr}

# SYSTEM
# USERNAME / HOSTNAME
${font2}${color1}SYSTEM${font}
# ${color}USERNAME# ${alignr}${color6}${user_names}
${color}HOSTNAME${alignr}${color5}${nodename}
# UPTIME / KERNEL
${color}UPTIME${alignr}${color3}${uptime}
${color}KERNEL${alignr}${color4}${kernel}
# LAST UPDATED / PACKAGES
${color}PACKAGES${alignr}${color5}${execi 3600 pacman -Q | wc -l}
${color}UPDATED${alignr}${color6}${execi 3600 ~/.hax/pac.sh}
${color}PKG UP${alignr}${color6}${execi 3600 ~/.config/polybar/uparch.sh}

${color0}${hr}

# INFORM
${font2}${color1}INFORM${font}
${color}VOLUME${alignr}${color3}${exec pamixer --get-volume-human}
${color}MUSIC
${alignr}${color5}${mpd_title}

${color0}${hr}

# BATTERY / STATUS
# ${font2}${color1}BATTERY${font}
# ${color}PERCENTAGE# ${alignr}${if_match ${battery_percent}>20}${color2}${battery_percent}${else}${color1}${battery_percent}${endif}%
# ${color}STATUS# ${alignr}${color4}${battery_status}
# STORAGE
${font2}${color1}STORAGE${font}
${color}USED /${alignr}${color3}${fs_used /} of ${fs_size /}
${color}USED /home${alignr}${color3}${fs_used /home} of ${fs_size /home}
${color}USED /m/files${alignr}${color3}${fs_used /media/files} of ${fs_size /media/files}
${color}TYPE /${alignr}${color2}${fs_type /}

${color0}${hr}

# MEMORY
${font2}${color1}MEMORY USAGE${font}
${color}SWAP${alignr}${color5}${swap} of ${swapmax}
${color}RAM${alignr}${color2}${mem} of ${memmax}

${color0}${hr}

# MEM GRAPH
${color5}${memgraph 35,220 af2445 14151f scale 100KiB -l}

# TOP RAM
${font2}${color1}TOP RAM${alignr}${color0}PID | NAME | RAM${font}
${color}${top_mem pid 1}${goto 55}${color4}${top_mem name 1}${alignr}${color5}${top_mem mem 1}%
${color}${top_mem pid 2}${goto 55}${color4}${top_mem name 2}${alignr}${color5}${top_mem mem 2}%
${color}${top_mem pid 3}${goto 55}${color4}${top_mem name 3}${alignr}${color5}${top_mem mem 3}%
${color}${top_mem pid 4}${goto 55}${color4}${top_mem name 4}${alignr}${color5}${top_mem mem 4}%
${color}${top_mem pid 5}${goto 55}${color4}${top_mem name 5}${alignr}${color5}${top_mem mem 5}%
${color}${top_mem pid 6}${goto 55}${color4}${top_mem name 6}${alignr}${color5}${top_mem mem 6}%
${color}${top_mem pid 7}${goto 55}${color4}${top_mem name 7}${alignr}${color5}${top_mem mem 7}%

${color0}${hr}

]];
