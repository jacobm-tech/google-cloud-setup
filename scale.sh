#!/bin/bash


if [ "$1" == "1" ]; then
	cursor="24"
	theme="Default"
elif [ "$1" == "2" ]; then
	cursor="48"
	theme="Default-hdpi"
elif [ "$1" == "3" ]; then
	cursor="72"
	theme="Default-xhdpi"
else
	echo "Unsupported scale"
	exit 1
fi

xfconf-query -c xsettings -p /Gdk/WindowScalingFactor -s $1
xfconf-query -c xsettings -p /Gtk/CursorThemeSize -s $cursor
xfconf-query -c xfwm4 -p /general/theme -s $theme
xfce4-panel -r
