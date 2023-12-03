#!/bin/sh
dconf load / < ~/.config/gnome-settings.ini
rm -f ~/.config/gnome-settings.ini ~/.config/autostart-scripts/dconf.sh &
