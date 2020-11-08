#!/data/data/com.termux/files/usr/bin/bash

## Change Wallpaper - Openbox Pipemenu

# Dir
dir="$HOME/.local/share/backgrounds"

# Lib
if ! . "/data/data/com.termux/files/home/.local/lib/termux-ob/common/al-include.cfg" 2>/dev/null; then
    echo $"Error: Failed to source /data/data/com.termux/files/home/.local/lib/termux-ob/common/al-include.cfg" >&2 ; exit 1
fi

# Wallpaper
wallpapers=($(ls $dir))

gen_menu () {
    local count=1

	menuStart
	for wallpaper in "${wallpapers[@]}"; do
		menuItem "${count}. ${wallpaper%.*}" "feh --bg-scale $dir/$wallpaper"
		count=$(($count+1))
	done
	menuEnd
}

{ gen_menu; exit 0; }
