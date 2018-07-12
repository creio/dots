#!/bin/bash

# speedtest-cli --simple > ~/.config/conky/ctl/.speeds 2>&1 &

# gsettings set org.gnome.desktop.background picture-uri "file:///home/$USER/.config/conky/ctl/wall.png"

xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVGA-0/workspace0/last-image -s ~/.config/conky/ctl/wall.png

sleep 1

# conky -c ~/.config/conky/ctl/connections_graph.conf &
# conky -c ~/.config/conky/ctl/disk_graph.conf &
conky -c ~/.config/conky/ctl/cpu_histograme.conf &

# sleep 3

# conky -c ~/.config/conky/ctl/fs_disk.conf &
# conky -c ~/.config/conky/ctl/memory_graph.conf &

# sleep 3

# conky -c ~/.config/conky/ctl/temperature_rings.conf &

# sleep 3

# conky -c ~/.config/conky/ctl/gmail.conf &
# conky -c ~/.config/conky/ctl/cpu_rings.conf &
# conky -c ~/.config/conky/ctl/notes.conf &

# sleep 3

# conky -c ~/.config/conky/ctl/connections_list.conf &
# conky -c ~/.config/conky/ctl/processes_list.conf &

# sleep 10

conky -c ~/.config/conky/ctl/globus_gif &
