#!/data/data/com.termux/files/usr/bin/bash

## Dirs #############################################
polybar_path="$HOME/.config/polybar"
rofi_path="$HOME/.config/rofi"
terminal_path="$HOME/.config/xfce4/terminal"
geany_path="$HOME/.config/geany"
openbox_path="$HOME/.config/openbox"

# wallpaper ---------------------------------
feh --bg-scale $HOME/.local/share/backgrounds/Grid.png

# polybar ---------------------------------
sed -i -e 's/STYLE=.*/STYLE="grid"/g' $polybar_path/launch.sh
sed -i -e 's/font-0 = .*/font-0 = "Terminus:Medium:size=9;2"/g' $polybar_path/grid/config.ini

cat > $polybar_path/grid/colors.ini << _EOF_
;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
;;
;;	   ______      __               
;;	  / ____/___  / /___  __________
;;	 / /   / __ \/ / __ \/ ___/ ___/
;;	/ /___/ /_/ / / /_/ / /  (__  ) 
;;	\____/\____/_/\____/_/  /____/  
;;
;;  Created By Aditya Shakya @adi1090x
;;
;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

[color]

BG = #01161B
BGM = #007B82
FG = #CFD8DC

;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
_EOF_

# relaunch polybar
$polybar_path/launch.sh

# rofi ---------------------------------
sed -i -e 's/STYLE=.*/STYLE="grid"/g' "$rofi_path/bin/mpd" "$rofi_path/bin/network" "$rofi_path/bin/battery"
sed -i -e 's/DIR=.*/DIR="grid"/g' "$rofi_path/bin/launcher" "$rofi_path/bin/powermenu"
sed -i -e 's/STYLE=.*/STYLE="launcher"/g' "$rofi_path/bin/launcher"
sed -i -e 's/STYLE=.*/STYLE="powermenu"/g' "$rofi_path/bin/powermenu"
sed -i -e 's/font:.*/font:				 	"Terminus Medium 9";/g' "$rofi_path/grid/font.rasi"

cat > $rofi_path/grid/colors.rasi << _EOF_
/* Color-Scheme */

* {
    BG:    #01161Bff;
    BGA:   #263238ff;
    FG:    #A3B5B8ff;
    SEL:   #007B82ff;
    UGT:   #EC407Aff;
	ON:    #61C766ff;
	OFF:   #EC7875ff;
}
_EOF_

sed -i -e 's/font:.*/font:				 	"Terminus Medium 9";/g' "$rofi_path/dialogs/askpass.rasi" "$rofi_path/dialogs/confirm.rasi"
sed -i -e 's/border:.*/border:					1px;/g' "$rofi_path/dialogs/askpass.rasi" "$rofi_path/dialogs/confirm.rasi"
cat > $rofi_path/dialogs/colors.rasi << _EOF_
/* Color-Scheme */

* {
    BG:    #01161Bff;
    FG:    #A3B5B8ff;
    BDR:   #007B82ff;
}
_EOF_

# Terminal ---------------------------------
sed -i -e 's/FontName=.*/FontName=Terminus Medium 9/g' $terminal_path/terminalrc
sed -i -e 's/ColorPalette=.*/ColorPalette=#01161B;#275155;#06686E;#1F6066;#4A6A6D;#017B83;#357D80;#a3b5b8;#727e80;#275155;#06686E;#1F6066;#4A6A6D;#017B83;#357D80;#a3b5b8/g' $terminal_path/terminalrc
sed -i -e 's/ColorForeground=.*/ColorForeground=#a3b5b8/g' $terminal_path/terminalrc
sed -i -e 's/ColorBackground=.*/ColorBackground=#01161B/g' $terminal_path/terminalrc
sed -i -e 's/ColorCursor=.*/ColorCursor=#a3b5b8/g' $terminal_path/terminalrc

# geany ---------------------------------
sed -i -e 's/color_scheme=.*/color_scheme=grid.conf/g' "$geany_path"/geany.conf
sed -i -e 's/editor_font=.*/editor_font=Terminus Medium 9/g' "$geany_path"/geany.conf

# gtk theme, icons and fonts ---------------------------------
xfconf-query -c xsettings -p /Net/ThemeName -s "grid"
xfconf-query -c xsettings -p /Net/IconThemeName -s "grid"
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "grid"
xfconf-query -c xsettings -p /Gtk/FontName -s "Terminus Medium 9"

# openbox ---------------------------------
obconfig () {
	namespace="http://openbox.org/3.4/rc"
	config="$openbox_path/rc.xml"
	theme="grid"
	layout="LC"
	font="Terminus"
	fontsize="9"

	# Theme
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:name' -v "$theme" "$config"

	# Title
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:titleLayout' -v "$layout" "$config"

	# Fonts
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="ActiveWindow"]/a:name' -v "$font" "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="ActiveWindow"]/a:size' -v "$fontsize" "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="ActiveWindow"]/a:weight' -v Bold "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="ActiveWindow"]/a:slant' -v Normal "$config"

	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="InactiveWindow"]/a:name' -v "$font" "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="InactiveWindow"]/a:size' -v "$fontsize" "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="InactiveWindow"]/a:weight' -v Normal "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="InactiveWindow"]/a:slant' -v Normal "$config"

	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="MenuHeader"]/a:name' -v "$font" "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="MenuHeader"]/a:size' -v "$fontsize" "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="MenuHeader"]/a:weight' -v Bold "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="MenuHeader"]/a:slant' -v Normal "$config"

	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="MenuItem"]/a:name' -v "$font" "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="MenuItem"]/a:size' -v "$fontsize" "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="MenuItem"]/a:weight' -v Normal "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="MenuItem"]/a:slant' -v Normal "$config"

	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="ActiveOnScreenDisplay"]/a:name' -v "$font" "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="ActiveOnScreenDisplay"]/a:size' -v "$fontsize" "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="ActiveOnScreenDisplay"]/a:weight' -v Bold "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="ActiveOnScreenDisplay"]/a:slant' -v Normal "$config"

	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="InactiveOnScreenDisplay"]/a:name' -v "$font" "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="InactiveOnScreenDisplay"]/a:size' -v "$fontsize" "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="InactiveOnScreenDisplay"]/a:weight' -v Normal "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:font[@place="InactiveOnScreenDisplay"]/a:slant' -v Normal "$config"

	# Margins
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:margins/a:top' -v 0 "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:margins/a:bottom' -v 10 "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:margins/a:left' -v 10 "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:margins/a:right' -v 10 "$config"
}

obconfig && openbox --reconfigure

# Other ---------------------------------
sed -i -e 's/progressbar_color = .*/progressbar_color = "black"/g' $HOME/.ncmpcpp/config

## EOF #############################################
