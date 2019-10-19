#!/usr/bin/env python
# encoding:utf8
"""NetworkManager command line dmenu script.

To add new connections or enable/disable networking requires policykit
permissions setup per:
https://wiki.archlinux.org/index.php/NetworkManager#Set_up_PolicyKit_permissions

OR running the script as root

Add dmenu formatting options and default terminal if desired to
~/.config/networkmanager-dmenu/config.ini

"""
import itertools
import locale
import os
from os.path import expanduser
import shlex
import sys
import uuid
from subprocess import Popen, PIPE

import gi
gi.require_version('NM', '1.0')
from gi.repository import GLib, NM  # pylint: disable=wrong-import-position

try:
    import configparser as configparser
except ImportError:
    import ConfigParser as configparser

ENV = os.environ.copy()
ENV['LC_ALL'] = 'C'
ENC = locale.getpreferredencoding()

CLIENT = NM.Client.new(None)
LOOP = GLib.MainLoop()
CONNS = CLIENT.get_connections()

if sys.version_info.major < 3:
    str = unicode

def dmenu_cmd(num_lines, prompt="Networks", active_lines=None):  # pylint: disable=too-many-branches
    """Parse config.ini if it exists and add options to the dmenu command

    Args: args - num_lines: number of lines to display
                 prompt: prompt to show
    Returns: command invocation (as a list of strings) for
                dmenu -l <num_lines> -p <prompt> -i ...

    """
    dmenu_command = "dmenu"
    conf = configparser.ConfigParser()
    conf.read(expanduser("~/.config/networkmanager-dmenu/config.ini"))
    if not conf.sections():
        res = [dmenu_command, "-i", "-l", str(num_lines), "-p", str(prompt)]
        res.extend(sys.argv[1:])
        return res
    if conf.has_section('dmenu'):
        args = conf.items('dmenu')
        args_dict = dict(args)
        dmenu_args = []
        if "dmenu_command" in args_dict:
            command = shlex.split(args_dict["dmenu_command"])
            dmenu_command = command[0]
            dmenu_args = command[1:]
            del args_dict["dmenu_command"]
        if "p" in args_dict and prompt == "Networks":
            prompt = args_dict["p"]
            del args_dict["p"]
        elif "p" in args_dict:
            del args_dict["p"]
        if "rofi" in dmenu_command:
            lines = "-i -dmenu -lines"
            # rofi doesn't support 0 length line, it requires at least -lines=1
            # see https://github.com/DaveDavenport/rofi/issues/252
            num_lines = num_lines or 1
        else:
            lines = "-i -l"
        if "l" in args_dict:
            # rofi doesn't support 0 length line, it requires at least -lines=1
            # see https://github.com/DaveDavenport/rofi/issues/252
            if "rofi" in dmenu_command:
                args_dict['l'] = min(num_lines, int(args_dict['l'])) or 1
            lines = "{} {}".format(lines, args_dict['l'])
            del args_dict['l']
        else:
            lines = "{} {}".format(lines, num_lines)
        if "pinentry" in args_dict:
            del args_dict["pinentry"]
        if conf.has_option('dmenu', 'rofi_highlight'):
            rofi_highlight = conf.getboolean('dmenu', 'rofi_highlight')
            del args_dict["rofi_highlight"]
        else:
            rofi_highlight = False
        if rofi_highlight is True and "rofi" in dmenu_command:
            if active_lines:
                dmenu_args.extend(["-a", ",".join([str(num)
                                                   for num in active_lines])])
    if prompt == "Passphrase":
        if conf.has_section('dmenu_passphrase'):
            args = conf.items('dmenu_passphrase')
            args_dict.update(args)
        rofi_obscure = True
        if conf.has_option('dmenu_passphrase', 'rofi_obscure'):
            rofi_obscure = conf.getboolean('dmenu_passphrase', 'rofi_obscure')
            del args_dict["rofi_obscure"]
        if rofi_obscure is True and "rofi" in dmenu_command:
            dmenu_args.extend(["-password"])
    extras = (["-" + str(k), str(v)] for (k, v) in args_dict.items())
    res = [dmenu_command, "-p", str(prompt)]
    res.extend(dmenu_args)
    res += list(itertools.chain.from_iterable(extras))
    res[1:1] = lines.split()
    res = list(filter(None, res))  # Remove empty list elements
    res.extend(sys.argv[1:])
    return res


def choose_adapter(client):
    """If there is more than one wifi adapter installed, ask which one to use

    """
    devices = client.get_devices()
    devices = [i for i in devices if i.get_device_type() == NM.DeviceType.WIFI]
    if not devices:
        return None
    elif devices:
        return devices[0]
    device_names = "\n".join([d.get_iface() for d in devices]).encode(ENC)
    sel = Popen(dmenu_cmd(len(devices), "CHOOSE ADAPTER:"),
                stdin=PIPE,
                stdout=PIPE,
                env=ENV).communicate(input=device_names)[0].decode(ENC)
    if not sel.strip():
        sys.exit()
    devices = [i for i in devices if i.get_iface() == sel.strip()]
    assert len(devices) == 1
    return devices[0]


def is_modemmanager_installed():
    """Check if ModemManager is installed"""
    devnull = open(os.devnull)
    try:
        Popen(["ModemManager"], stdout=devnull, stderr=devnull).communicate()
    except OSError:
        return False
    return True


def create_other_actions(client):
    """Return list of other actions that can be taken

    """
    networking_enabled = client.networking_get_enabled()
    networking_action = "Disable" if networking_enabled else "Enable"
    wifi_enabled = client.wireless_get_enabled()
    wifi_action = "Disable" if wifi_enabled else "Enable"
    actions = [Action("{} Wifi".format(wifi_action), toggle_wifi,
                      not wifi_enabled),
               Action("{} Networking".format(networking_action),
                      toggle_networking, not networking_enabled),
               Action("Launch Connection Manager", launch_connection_editor),
               Action("Delete a Connection", delete_connection)]
    if wifi_enabled:
        actions.append(Action("Rescan Wifi Networks", rescan_wifi))
    return actions

def rescan_wifi():
    """
    Rescan Wifi Access Points
    """
    for dev in CLIENT.get_devices():
        if gi.repository.NM.DeviceWifi == type(dev):
            try:
                dev.request_scan()
            except gi.repository.GLib.Error as err:
                # Too frequent rescan error
                if not err.code == 6: # pylint: disable=no-member
                    raise err

def ssid_to_utf8(nm_ap):
    """ Convert binary ssid to utf-8 """
    ssid = nm_ap.get_ssid()
    if not ssid:
        return ""
    ret = NM.utils_ssid_to_utf8(ssid.get_data())
    if sys.version_info.major < 3:
        return ret.decode(ENC)
    return ret


def ap_security(nm_ap):
    """Parse the security flags to return a string with 'WPA2', etc. """
    flags = nm_ap.get_flags()
    wpa_flags = nm_ap.get_wpa_flags()
    rsn_flags = nm_ap.get_rsn_flags()
    sec_str = ""
    if ((flags & getattr(NM, '80211ApFlags').PRIVACY) and
            (wpa_flags == 0) and (rsn_flags == 0)):
        sec_str += " WEP"
    if wpa_flags != 0:
        sec_str += " WPA1"
    if rsn_flags != 0:
        sec_str += " WPA2"
    if ((wpa_flags & getattr(NM, '80211ApSecurityFlags').KEY_MGMT_802_1X) or
            (rsn_flags & getattr(NM, '80211ApSecurityFlags').KEY_MGMT_802_1X)):
        sec_str += " 802.1X"

    # If there is no security use "--"
    if sec_str == "":
        sec_str = "--"
    return sec_str.lstrip()


class Action(object):  # pylint: disable=too-few-public-methods
    """Helper class to execute functions from a string variable"""
    def __init__(self,
                 name,
                 func,
                 args=None,
                 active=False,
                ):
        self.name = name
        self.func = func
        self.is_active = active
        if args is None:
            self.args = None
        elif isinstance(args, list):
            self.args = args
        else:
            self.args = [args]

    def __str__(self):
        if sys.version_info.major < 3 and \
                isinstance(self.name, unicode) is False:
            return self.name.decode(ENC)
        return self.name

    def __call__(self):
        if self.args is None:
            self.func()
        else:
            self.func(*self.args)


def process_ap(nm_ap, is_active, adapter):
    """Activate/Deactivate a connection and get password if required"""
    if is_active:
        CLIENT.deactivate_connection_async(nm_ap)
    else:
        conns_cur = [i for i in CONNS if
                     i.get_setting_wireless() is not None and
                     i.get_setting_wireless().get_mac_address() ==
                     adapter.get_permanent_hw_address()]
        con = nm_ap.filter_connections(conns_cur)
        if len(con) > 1:
            raise ValueError("There are multiple connections possible")

        if len(con) == 1:
            CLIENT.activate_connection_async(con[0])
        else:
            if ap_security(nm_ap) != "--":
                password = get_passphrase()
            else:
                password = ""
            set_new_connection(nm_ap, password, adapter)


def process_vpngsm(con, activate):
    """Activate/deactive VPN or GSM connections"""
    if activate:
        CLIENT.activate_connection_async(con)
    else:
        CLIENT.deactivate_connection_async(con)


def create_ap_actions(aps, active_ap, active_connection, adapter):  # pylint: disable=too-many-locals
    """For each AP in a list, create the string and its attached function
    (activate/deactivate)

    """
    active_ap_bssid = active_ap.get_bssid() if active_ap is not None else ""

    names = [ssid_to_utf8(ap) for ap in aps]
    max_len_name = max([len(name) for name in names]) if names else 0
    secs = [ap_security(ap) for ap in aps]
    max_len_sec = max([len(sec) for sec in secs]) if secs else 0

    ap_actions = []

    for nm_ap, name, sec in zip(aps, names, secs):
        bars = NM.utils_wifi_strength_bars(nm_ap.get_strength())
        is_active = nm_ap.get_bssid() == active_ap_bssid
        action_name = u"{:<{}s}  {:<{}s}  {}".format(name, max_len_name, sec,
                                                     max_len_sec, bars)
        if is_active:
            ap_actions.append(Action(action_name, process_ap,
                                     [active_connection, True, adapter],
                                     active=True))
        else:
            ap_actions.append(Action(action_name, process_ap,
                                     [nm_ap, False, adapter]))
    return ap_actions


def create_vpn_actions(vpns, active):
    """Create the list of strings to display with associated function
    (activate/deactivate) for VPN connections.

    """
    active_vpns = [i for i in active if i.get_vpn()]
    return _create_vpngsm_actions(vpns, active_vpns, "VPN")


def create_eth_actions(eths, active):
    """Create the list of strings to display with associated function
    (activate/deactivate) for Ethernet connections.

    """
    active_eths = [i for i in active if 'ethernet' in i.get_connection_type()]
    return _create_vpngsm_actions(eths, active_eths, "Eth")


def create_gsm_actions(gsms, active):
    """Create the list of strings to display with associated function
    (activate/deactivate) GSM connections."""
    active_gsms = [i for i in active if
                   i.get_connection() is not None and
                   i.get_connection().is_type(NM.SETTING_GSM_SETTING_NAME)]
    return _create_vpngsm_actions(gsms, active_gsms, "GSM")


def create_blue_actions(blues, active):
    """Create the list of strings to display with associated function
    (activate/deactivate) Bluetooth connections."""
    active_blues = [i for i in active if
                    i.get_connection() is not None and
                    i.get_connection().is_type(NM.SETTING_BLUETOOTH_SETTING_NAME)]
    return _create_vpngsm_actions(blues, active_blues, "Bluetooth")


def _create_vpngsm_actions(cons, active_cons, label):
    active_con_ids = [a.get_id() for a in active_cons]
    actions = []
    for con in cons:
        is_active = con.get_id() in active_con_ids
        action_name = u"{}:{}".format(con.get_id(), label)
        if is_active:
            active_connection = [a for a in active_cons
                                 if a.get_id() == con.get_id()]
            if len(active_connection) != 1:
                raise ValueError(u"Multiple active connections match"
                                 " the connection: {}".format(con.get_id()))
            active_connection = active_connection[0]

            actions.append(Action(action_name, process_vpngsm,
                                  [active_connection, False], active=True))
        else:
            actions.append(Action(action_name, process_vpngsm,
                                  [con, True]))
    return actions


def create_wwan_actions(client):
    """Create WWWAN actions

    """
    wwan_enabled = client.wwan_get_enabled()
    wwan_action = "Disable" if wwan_enabled else "Enable"
    return [Action("{} WWAN".format(wwan_action), toggle_wwan, not wwan_enabled)]


def get_selection(eths, aps, vpns, gsms, blues, wwan, others):
    """Combine the arg lists and send to dmenu for selection.
    Also executes the associated action.

    Args: args - eths: list of Actions
                 aps: list of Actions
                 vpns: list of Actions
                 gsms: list of Actions
                 blues: list of Actions
                 wwan: list of Actions
                 others: list of Actions

    """
    conf = configparser.ConfigParser()
    conf.read(expanduser("~/.config/networkmanager-dmenu/config.ini"))
    rofi_highlight = False
    if conf.has_option('dmenu', 'rofi_highlight'):
        rofi_highlight = conf.getboolean('dmenu', 'rofi_highlight')
    inp = []
    empty_action = [Action('', None)]
    all_actions = []
    all_actions += eths + empty_action if eths else []
    all_actions += aps + empty_action if aps else []
    all_actions += vpns + empty_action if vpns else []
    all_actions += gsms + empty_action if (gsms and wwan) else []
    all_actions += blues + empty_action if blues else []
    all_actions += wwan + empty_action if wwan else []
    all_actions += others

    if rofi_highlight is True:
        inp = [str(action) for action in all_actions]
    else:
        inp = [('** ' if action.is_active else '   ') + str(action)
               for action in all_actions]
    active_lines = [index for index, action in enumerate(all_actions)
                    if action.is_active]

    inp_bytes = "\n".join([i for i in inp]).encode(ENC)
    command = dmenu_cmd(len(inp), active_lines=active_lines)
    sel = Popen(command, stdin=PIPE, stdout=PIPE,
                env=ENV).communicate(input=inp_bytes)[0].decode(ENC)

    if not sel.rstrip():
        sys.exit()

    if rofi_highlight is False:
        action = [i for i in eths + aps + vpns + gsms + blues + wwan + others
                  if ((str(i).strip() == str(sel.strip())
                       and not i.is_active) or
                      ('** ' + str(i) == str(sel.rstrip('\n'))
                       and i.is_active))]
    else:
        action = [i for i in eths + aps + vpns + gsms + blues + wwan + others
                  if str(i).strip() == sel.strip()]
    assert len(action) == 1, \
            u"Selection was ambiguous: '{}'".format(str(sel.strip()))
    return action[0]


def toggle_networking(enable):
    """Enable/disable networking

    Args: enable - boolean

    """
    CLIENT.networking_set_enabled(enable)


def toggle_wifi(enable):
    """Enable/disable Wifi

    Args: enable - boolean

    """
    CLIENT.wireless_set_enabled(enable)


def toggle_wwan(enable):
    """Enable/disable WWAN

    Args: enable - boolean

    """
    CLIENT.wwan_set_enabled(enable)


def launch_connection_editor():
    """Launch nmtui or the gui nm-connection-editor

    """
    conf = configparser.ConfigParser()
    conf.read(expanduser("~/.config/networkmanager-dmenu/config.ini"))
    if conf.has_option("editor", "terminal"):
        terminal = conf.get("editor", "terminal")
    else:
        terminal = "xterm"
    if conf.has_option("editor", "gui_if_available"):
        gui_if_available = conf.get("editor", "gui_if_available")
    else:
        gui_if_available = "True"
    if gui_if_available == "True":
        try:
            Popen(["nm-connection-editor"]).communicate()
        except OSError:
            Popen([terminal, "-e", "nmtui"]).communicate()
    else:
        Popen([terminal, "-e", "nmtui"]).communicate()


def get_passphrase():
    """Get a password

    Returns: string

    """

    conf = configparser.ConfigParser()
    conf.read(expanduser("~/.config/networkmanager-dmenu/config.ini"))
    pinentry = None
    if conf.has_option("dmenu", "pinentry"):
        pinentry = conf.get("dmenu", "pinentry")
    if pinentry:
        pin = ""
        out = Popen(pinentry,
                    stdout=PIPE,
                    stdin=PIPE).communicate( \
                            input=b'setdesc Get network password\ngetpin\n')[0]
        if out:
            res = out.decode(ENC).split("\n")[2]
            if res.startswith("D "):
                pin = res.split("D ")[1]
        return pin
    else:
        return Popen(dmenu_cmd(0, "Passphrase"),
                     stdin=PIPE, stdout=PIPE).communicate()[0].decode(ENC)


def delete_connection():
    """Display list of NM connections and delete the selected one

    """
    conn_acts = [Action(i.get_id(), i.delete) for i in CONNS]
    conn_names = "\n".join([str(i) for i in conn_acts]).encode(ENC)
    sel = Popen(dmenu_cmd(len(conn_acts), "CHOOSE CONNECTION TO DELETE:"),
                stdin=PIPE,
                stdout=PIPE,
                env=ENV).communicate(input=conn_names)[0].decode(ENC)
    if not sel.strip():
        sys.exit()
    action = [i for i in conn_acts if str(i) == sel.rstrip("\n")]
    assert len(action) == 1, u"Selection was ambiguous: {}".format(str(sel))
    action[0]()


def set_new_connection(nm_ap, nm_pw, adapter):
    """Setup a new NetworkManager connection

    Args: ap - NM.AccessPoint
          pw - string

    """
    nm_pw = str(nm_pw).strip()
    profile = create_wifi_profile(nm_ap, nm_pw, adapter)
    CLIENT.add_and_activate_connection_async(profile, adapter, nm_ap.get_path(),
                                             None, verify_conn, profile)
    LOOP.run()


def create_wifi_profile(nm_ap, password, adapter):
    # pylint: disable=C0301
    # From https://cgit.freedesktop.org/NetworkManager/NetworkManager/tree/examples/python/gi/add_connection.py
    # and https://cgit.freedesktop.org/NetworkManager/NetworkManager/tree/examples/python/dbus/add-wifi-psk-connection.py
    # pylint: enable=C0301
    """Create the NM profile given the AP and passphrase"""
    ap_sec = ap_security(nm_ap)
    profile = NM.SimpleConnection.new()

    s_con = NM.SettingConnection.new()
    s_con.set_property(NM.SETTING_CONNECTION_ID, ssid_to_utf8(nm_ap))
    s_con.set_property(NM.SETTING_CONNECTION_UUID, str(uuid.uuid4()))
    s_con.set_property(NM.SETTING_CONNECTION_TYPE, "802-11-wireless")
    profile.add_setting(s_con)

    s_wifi = NM.SettingWireless.new()
    s_wifi.set_property(NM.SETTING_WIRELESS_SSID, nm_ap.get_ssid())
    s_wifi.set_property(NM.SETTING_WIRELESS_MODE, 'infrastructure')
    s_wifi.set_property(NM.SETTING_WIRELESS_MAC_ADDRESS, adapter.get_permanent_hw_address())
    profile.add_setting(s_wifi)

    s_ip4 = NM.SettingIP4Config.new()
    s_ip4.set_property(NM.SETTING_IP_CONFIG_METHOD, "auto")
    profile.add_setting(s_ip4)

    s_ip6 = NM.SettingIP6Config.new()
    s_ip6.set_property(NM.SETTING_IP_CONFIG_METHOD, "auto")
    profile.add_setting(s_ip6)

    if ap_sec != "--":
        s_wifi_sec = NM.SettingWirelessSecurity.new()
        if "WPA" in ap_sec:
            s_wifi_sec.set_property(NM.SETTING_WIRELESS_SECURITY_KEY_MGMT,
                                    "wpa-psk")
            s_wifi_sec.set_property(NM.SETTING_WIRELESS_SECURITY_AUTH_ALG,
                                    "open")
            s_wifi_sec.set_property(NM.SETTING_WIRELESS_SECURITY_PSK, password)
        elif "WEP" in ap_sec:
            s_wifi_sec.set_property(NM.SETTING_WIRELESS_SECURITY_KEY_MGMT,
                                    "None")
            s_wifi_sec.set_property(NM.SETTING_WIRELESS_SECURITY_WEP_KEY_TYPE,
                                    NM.WepKeyType.PASSPHRASE)
            s_wifi_sec.set_wep_key(0, password)
        profile.add_setting(s_wifi_sec)

    return profile


def verify_conn(client, result, data):
    """Callback function for add_and_activate_connection_async

    Check if connection completes successfully. Delete the connection if there
    is an error.

    """
    try:
        act_conn = client.add_and_activate_connection_finish(result)
        conn = act_conn.get_connection()
        conn.verify()
        conn.verify_secrets()
        data.verify()
        data.verify_secrets()
    except GLib.Error:  # pylint: disable=catching-non-exception
        try:
            conn.delete()
        except UnboundLocalError:
            pass
    finally:
        LOOP.quit()


def create_ap_list(adapter, active_connections):
    """Generate list of access points. Remove duplicate APs , keeping strongest
    ones and the active AP

    Args: adapter
          active_connections - list of all active connections
    Returns: aps - list of access points
             active_ap - active AP
             active_ap_con - active Connection
             adapter

    """
    aps = []
    ap_names = []
    active_ap = adapter.get_active_access_point()
    aps_all = sorted(adapter.get_access_points(),
                     key=lambda a: a.get_strength(), reverse=True)
    conns_cur = [i for i in CONNS if
                 i.get_setting_wireless() is not None and
                 i.get_setting_wireless().get_mac_address() ==
                 adapter.get_permanent_hw_address()]
    try:
        ap_conns = active_ap.filter_connections(conns_cur)
        active_ap_name = ssid_to_utf8(active_ap)
        active_ap_con = [active_conn for active_conn in active_connections
                         if active_conn.get_connection() in ap_conns]
    except AttributeError:
        active_ap_name = None
        active_ap_con = []
    if len(active_ap_con) > 1:
        raise ValueError("Multiple connection profiles match"
                         " the wireless AP")
    active_ap_con = active_ap_con[0] if active_ap_con else None
    for nm_ap in aps_all:
        ap_name = ssid_to_utf8(nm_ap)
        if nm_ap != active_ap and ap_name == active_ap_name:
            # Skip adding AP if it's not active but same name as active AP
            continue
        if ap_name not in ap_names:
            ap_names.append(ap_name)
            aps.append(nm_ap)
    return aps, active_ap, active_ap_con, adapter


def run():
    """Main script entrypoint"""
    active = CLIENT.get_active_connections()
    adapter = choose_adapter(CLIENT)
    if adapter:
        ap_actions = create_ap_actions(*create_ap_list(adapter, active))
    else:
        ap_actions = []

    vpns = [i for i in CONNS if i.is_type(NM.SETTING_VPN_SETTING_NAME)]
    eths = [i for i in CONNS if i.is_type(NM.SETTING_WIRED_SETTING_NAME)]
    blues = [i for i in CONNS if i.is_type(NM.SETTING_BLUETOOTH_SETTING_NAME)]

    vpn_actions = create_vpn_actions(vpns, active)
    eth_actions = create_eth_actions(eths, active)
    blue_actions = create_blue_actions(blues, active)
    other_actions = create_other_actions(CLIENT)
    wwan_installed = is_modemmanager_installed()
    if wwan_installed:
        gsms = [i for i in CONNS if i.is_type(NM.SETTING_GSM_SETTING_NAME)]
        gsm_actions = create_gsm_actions(gsms, active)
        wwan_actions = create_wwan_actions(CLIENT)
    else:
        gsm_actions = []
        wwan_actions = []

    sel = get_selection(eth_actions, ap_actions, vpn_actions, gsm_actions,
                        blue_actions, wwan_actions, other_actions)
    sel()


if __name__ == '__main__':
    run()

# vim: set et ts=4 sw=4 :
