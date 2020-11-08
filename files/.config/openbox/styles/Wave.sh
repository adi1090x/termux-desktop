#!/data/data/com.termux/files/usr/bin/bash

## Dirs #############################################
polybar_path="$HOME/.config/polybar"
rofi_path="$HOME/.config/rofi"
terminal_path="$HOME/.config/xfce4/terminal"
geany_path="$HOME/.config/geany"
openbox_path="$HOME/.config/openbox"

# wallpaper ---------------------------------
feh --bg-scale $HOME/.local/share/backgrounds/Wave.jpg

# polybar ---------------------------------
sed -i -e 's/STYLE=.*/STYLE="wave"/g' $polybar_path/launch.sh
sed -i -e 's/font-0 = .*/font-0 = "Iosevka Nerd Font:size=10;3"/g' $polybar_path/wave/config.ini

# relaunch polybar
$polybar_path/launch.sh

# rofi ---------------------------------
sed -i -e 's/STYLE=.*/STYLE="wave"/g' "$rofi_path/bin/mpd" "$rofi_path/bin/network" "$rofi_path/bin/battery"
sed -i -e 's/DIR=.*/DIR="wave"/g' "$rofi_path/bin/launcher" "$rofi_path/bin/powermenu"
sed -i -e 's/STYLE=.*/STYLE="launcher"/g' "$rofi_path/bin/launcher"
sed -i -e 's/STYLE=.*/STYLE="powermenu"/g' "$rofi_path/bin/powermenu"
sed -i -e 's/font:.*/font:				 	"Iosevka 10";/g' "$rofi_path/wave/font.rasi"

sed -i -e 's/font:.*/font:				 	"Iosevka 10";/g' "$rofi_path/dialogs/askpass.rasi" "$rofi_path/dialogs/confirm.rasi"
sed -i -e 's/border:.*/border:					0px;/g' "$rofi_path/dialogs/askpass.rasi" "$rofi_path/dialogs/confirm.rasi"
cat > $rofi_path/dialogs/colors.rasi << _EOF_
/* Color-Scheme */

* {
    BG:    #3D4C5Fff;
    FG:    #F8F8F2ff;
    BDR:   #F48FB1ff;
}
_EOF_

# Network Manager ---------------------------------
sed -i -e 's#dmenu_command = .*#dmenu_command = rofi -dmenu -theme wave/networkmenu.rasi#g' "$HOME"/.config/networkmanager-dmenu/config.ini

# Terminal ---------------------------------
sed -i -e 's/FontName=.*/FontName=Iosevka Custom 9/g' $terminal_path/terminalrc
sed -i -e 's/ColorPalette=.*/ColorPalette=#3D4C5F;#F48FB1;#A1EFD3;#F1FA8C;#92B6F4;#BD99FF;#87DFEB;#F8F8F2;#56687E;#EE4F84;#53E2AE;#F1FF52;#6498EF;#985EFF;#24D1E7;#E5E5E5/g' $terminal_path/terminalrc
sed -i -e 's/ColorForeground=.*/ColorForeground=#F8F8F2/g' $terminal_path/terminalrc
sed -i -e 's/ColorBackground=.*/ColorBackground=#323F4E/g' $terminal_path/terminalrc
sed -i -e 's/ColorCursor=.*/ColorCursor=#F8F8F2/g' $terminal_path/terminalrc

# geany ---------------------------------
sed -i -e 's/color_scheme=.*/color_scheme=wave.conf/g' "$geany_path"/geany.conf
sed -i -e 's/editor_font=.*/editor_font=Iosevka Custom 10/g' "$geany_path"/geany.conf

# gtk theme, icons and fonts ---------------------------------
xfconf-query -c xsettings -p /Net/ThemeName -s "wave"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Hybrid"
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Hybrid"
xfconf-query -c xsettings -p /Gtk/FontName -s "Noto Sans 9"

# openbox ---------------------------------
obconfig () {
	namespace="http://openbox.org/3.4/rc"
	config="$openbox_path/rc.xml"
	theme="wave"
	layout="LIMC"
	font="Noto Sans"
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
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:margins/a:top' -v 10 "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:margins/a:bottom' -v 0 "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:margins/a:left' -v 10 "$config"
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:margins/a:right' -v 10 "$config"
}

obconfig && openbox --reconfigure

# Other ---------------------------------
sed -i -e 's/progressbar_color = .*/progressbar_color = "black"/g' $HOME/.ncmpcpp/config

## EOF #############################################
