#!/bin/bash

disconnect() {
    nmcli con down id "$active" && notify-send "Network Manager" "Disconnected from $active" || notify-send "Network Manager" "Error disconnecting from $active!"
}
connect() {
    nmcli con up id "$chosen" && notify-send "Network Manager" "Now connected to $chosen" || notify-send "Network Manager" "Error connecting to $chosen!"
}

# Get the active vpn connection if there's one
active="$(nmcli -g name,type con show --active | grep vpn | sed -e 's#:vpn$##')"

# Get the list of vpns
mapfile -t list < <(nmcli -g name,type con | grep vpn | sed -e 's#:vpn$##')
# A vpn is active
if [ -n "$active" ]; then
    status="   Connected"
    status_style="#prompt { background-color: @on; }"
    special="-a 0 -selected-row 1"
    # Variable passed to rofi
    options="$active"
    for i in "${!list[@]}"; do
        [ "${list[i]}" == "$active" ] && unset "list[i]" || options+="\n${list[i]}"
    done
# No vpn is active
else
    status="   Disconnected"
    status_style="#prompt { background-color: @off; }"
    special=""
    # Variable passed to rofi
    options=""
    for i in "${!list[@]}"; do
        options+="${list[i]}\n"
    done
    options=${options::-2}
fi

chosen=$(echo -e "$options" | rofi -theme themes/nmvpnmenu.rasi -theme-str "$status_style" -p "$status" -dmenu -i $special)
if [ -n "$chosen" ]; then
    if [ "$chosen" == "$active" ]; then
        # Disconnect the active vpn
        disconnect
    else
        take_action=false
        # Check if the chosen option is in the list, to avoid taking action
        # on the user pressing Escape for example
        for i in "${!list[@]}"; do
            [ "${list[i]}" == "$chosen" ] && { take_action=true; break; }
        done
        if $take_action; then
            # A vpn is active
            if [ -n "$active" ]; then
                # Disconnect the active vpn
                disconnect
                wait
                sleep 1
                # Connect to the chosen one
                connect
            # No vpn is active
            else
                # Connect to the chosen one
                connect
            fi
        fi
    fi
fi

