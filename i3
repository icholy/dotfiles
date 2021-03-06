# This file has been auto-generated by i3-config-wizard(1).
# It will not be overwritten, so edit it as you like.
#
# Should you change your keyboard layout somewhen, delete
# this file and re-run i3-config-wizard(1).
#

# i3 config file (v4)
#
# Please see http://i3wm.org/docs/userguide.html for a complete reference!

set $alt Mod1
set $win Mod4

# font for window titles. ISO 10646 = Unicode font -misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1

# Use Mouse+$win to drag floating windows to their wanted position
floating_modifier $win

# start a terminal
bindsym $win+Return exec i3-sensible-terminal

# kill focused window
bindsym $win+Shift+Q kill

# start dmenu (a program launcher)
bindsym $win+d exec dmenu_run -l 20

# change focus
bindsym $win+h focus left
bindsym $win+j focus down
bindsym $win+k focus up
bindsym $win+l focus right

# alternatively, you can use the cursor keys:
bindsym $win+Left focus left
bindsym $win+Down focus down
bindsym $win+Up focus up
bindsym $win+Right focus right

# move focused window
bindsym $win+Shift+H move left
bindsym $win+Shift+J move down
bindsym $win+Shift+K move up
bindsym $win+Shift+L move right

# split in horizontal orientation
bindsym $win+b split h

# split in vertical orientation
bindsym $win+v split v

# enter fullscreen mode for the focused container
bindsym $win+f fullscreen

# change container layout (stacked, tabbed, default)
bindsym $win+s layout stacking
bindsym $win+w layout tabbed
bindsym $win+e layout default

# toggle tiling / floating
bindsym $win+Shift+space floating toggle

# change focus between tiling / floating windows
bindsym $win+space focus mode_toggle

# focus the parent container
bindsym $win+p focus parent

# focus the child container
bindsym $win+c focus child

# switch to workspace
bindsym $win+1 workspace 1
bindsym $win+2 workspace 2
bindsym $win+3 workspace 3
bindsym $win+4 workspace 4
bindsym $win+5 workspace 5
bindsym $win+6 workspace 6
bindsym $win+7 workspace 7
bindsym $win+8 workspace 8
bindsym $win+9 workspace 9
bindsym $win+0 workspace 10

# move focused container to workspace
bindsym $win+Shift+exclam move workspace 1
bindsym $win+Shift+at move workspace 2
bindsym $win+Shift+numbersign move workspace 3
bindsym $win+Shift+dollar move workspace 4
bindsym $win+Shift+percent move workspace 5
bindsym $win+Shift+asciicircum move workspace 6
bindsym $win+Shift+ampersand move workspace 7
bindsym $win+Shift+asterisk move workspace 8
bindsym $win+Shift+parenleft move workspace 9
bindsym $win+Shift+parenright move workspace 10

# reload the configuration file
bindsym $win+Shift+C reload
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym $win+Shift+R restart
# exit i3 (logs you out of your X session)
bindsym $win+Shift+E exit

# resizing
set $resize_speed = 30

bindsym $alt+h resize grow left $resize_speed px
bindsym $alt+Shift+H resize shrink right $resize_speed px

bindsym $alt+j resize grow down $resize_speed px
bindsym $alt+Shift+J resize shrink up $resize_speed px

bindsym $alt+k resize grow up $resize_speed px
bindsym $alt+Shift+K resize shrink down $resize_speed px

bindsym $alt+l resize grow right $resize_speed px
bindsym $alt+Shift+L resize shrink left $resize_speed px

# Start i3bar to display a workspace bar (plus the system information i3status
# finds out, if available)
bar {
        status_command i3status
}

exec --no-startup-id feh --bg-scale ~/Pictures/keep-it-simple.png
