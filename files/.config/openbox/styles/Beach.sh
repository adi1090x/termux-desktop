#!/data/data/com.termux/files/usr/bin/bash

## Dirs #############################################
polybar_path="$HOME/.config/polybar"
rofi_path="$HOME/.config/rofi"
terminal_path="$HOME/.config/xfce4/terminal"
geany_path="$HOME/.config/geany"
openbox_path="$HOME/.config/openbox"

# wallpaper ---------------------------------
feh --bg-scale $HOME/.local/share/backgrounds/Beach.jpg

# polybar ---------------------------------
sed -i -e 's/STYLE=.*/STYLE="beach"/g' $polybar_path/launch.sh
sed -i -e 's/font-0 = .*/font-0 = "Terminus:size=8;3"/g' $polybar_path/beach/config.ini

# relaunch polybar
$polybar_path/launch.sh

# rofi ---------------------------------
sed -i -e 's/STYLE=.*/STYLE="beach"/g' "$rofi_path/bin/mpd" "$rofi_path/bin/network" "$rofi_path/bin/battery"
sed -i -e 's/DIR=.*/DIR="beach"/g' "$rofi_path/bin/launcher" "$rofi_path/bin/powermenu"
sed -i -e 's/STYLE=.*/STYLE="launcher"/g' "$rofi_path/bin/launcher"
sed -i -e 's/STYLE=.*/STYLE="powermenu"/g' "$rofi_path/bin/powermenu"
sed -i -e 's/font:.*/font:				 	"Terminus 9";/g' "$rofi_path/beach/font.rasi"

sed -i -e 's/font:.*/font:				 	"Terminus 9";/g' "$rofi_path/dialogs/askpass.rasi" "$rofi_path/dialogs/confirm.rasi"
sed -i -e 's/border:.*/border:					0px;/g' "$rofi_path/dialogs/askpass.rasi" "$rofi_path/dialogs/confirm.rasi"
cat > $rofi_path/dialogs/colors.rasi << _EOF_
/* Color-Scheme */

* {
    BG:    #141c21ff;
    FG:    #93a1a1ff;
    BDR:   #2587ccff;
}
_EOF_

# Terminal ---------------------------------
sed -i -e 's/FontName=.*/FontName=Terminus 9/g' $terminal_path/terminalrc
sed -i -e 's/ColorPalette=.*/ColorPalette=#263640;#d12f2c;#819400;#b08500;#2587cc;#696ebf;#289c93;#bfbaac;#4a697d;#fa3935;#a4bd00;#d9a400;#2ca2f5;#8086e8;#33c5ba;#fdf6e3/g' $terminal_path/terminalrc
sed -i -e 's/ColorForeground=.*/ColorForeground=#93a1a1/g' $terminal_path/terminalrc
sed -i -e 's/ColorBackground=.*/ColorBackground=#141c21/g' $terminal_path/terminalrc
sed -i -e 's/ColorCursor=.*/ColorCursor=#afbfbf/g' $terminal_path/terminalrc

# geany ---------------------------------
sed -i -e 's/color_scheme=.*/color_scheme=github.conf/g' "$geany_path"/geany.conf
sed -i -e 's/editor_font=.*/editor_font=Terminus 9/g' "$geany_path"/geany.conf

# gtk theme, icons and fonts ---------------------------------
xfconf-query -c xsettings -p /Net/ThemeName -s "Arc"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Arc"
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Arc"
xfconf-query -c xsettings -p /Gtk/FontName -s "Terminus 9"

# openbox ---------------------------------
obconfig () {
	namespace="http://openbox.org/3.4/rc"
	config="$openbox_path/rc.xml"
	theme="beach"
	layout="CLM"
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
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:margins/a:top' -v 20 "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:margins/a:bottom' -v 0 "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:margins/a:left' -v 20 "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:margins/a:right' -v 20 "$config"
}

obconfig && openbox --reconfigure

# Other ---------------------------------
sed -i -e 's/progressbar_color = .*/progressbar_color = "black"/g' $HOME/.ncmpcpp/config

## EOF #############################################
