# lib/en.sh — English catalog (default base)
# Values may contain printf placeholders (%s) used via tf().

# common
MSG_ROOT_ERR="Run as root (sudo -i)."

# bootstrap
MSG_BOOT_UPDATE="[0/4] Updating package lists..."
MSG_BOOT_GIT="[1/4] Installing git..."
MSG_BOOT_DOWNLOAD="[2/4] Downloading the printserver repo... (this can prompt for your GitHub credentials)"
MSG_BOOT_RUN="[3/4] Running installer..."
MSG_BOOT_FW="[4/4] Configuring firewall..."
MSG_BOOT_DONE="Done! Check status:"
MSG_BOOT_MANUAL="What remains manual (see README):"
MSG_BOOT_MANUAL_1="  1. Add printers through the CUPS web UI: http://localhost:631"
MSG_BOOT_MANUAL_2="  2. HP: hp-setup -i | Brother: download .deb from their site | Zebra/generic: ps-add-raw-printer"

# install
MSG_INST_TITLE="  Print Server - Installation"
MSG_INST_STEP1="[1/6] Updating system..."
MSG_INST_STEP2="[2/6] Installing CUPS and dependencies..."
MSG_INST_STEP3="[3/6] Installing printer drivers..."
MSG_INST_STEP4="[4/6] Installing Avahi..."
MSG_INST_STEP5="[5/6] Installing Samba..."
MSG_INST_STEP6="[6/6] Installing UFW..."
MSG_INST_ENABLE="Enabling services..."
MSG_INST_SHORTCUTS="Shortcuts created: ps-status ps-check ps-logs ps-restart ps-backup ps-firewall ps-add-raw-printer ps-wifi ps-ip ps-update"
MSG_INST_DONE="  Installation complete!"
MSG_INST_CUPS_URL="CUPS:  http://localhost:631  (or http://SERVER-IP:631)"
MSG_INST_ACCESS="Access CUPS from another computer on this network:"
MSG_INST_FIRMWARE="Firmware for some foo2zjs models may need 'getweb' - see README."
MSG_INST_ADMIN_MISSING="User 'admin' not found."
MSG_INST_ADMIN_PROMPT="Username to give CUPS admin (not root): "
MSG_INST_ADMIN_ADDED="User '%s' added to the lpadmin group."
MSG_INST_ADMIN_ERR="! User '%s' does not exist. Create it or run: usermod -aG lpadmin <user>"
MSG_INST_ADMIN_HINT="# enter the username you created during Debian install"

# firewall
MSG_FW_CONFIG="Configuring Firewall..."
MSG_FW_STATUS="Firewall status:"
MSG_FW_DONE="Firewall configured!"

# wifi
MSG_WIFI_NM="Installing NetworkManager..."
MSG_WIFI_NM_MISSING="NetworkManager is not installed. Run the installer once (ps-update) to install it."
MSG_WIFI_NODEV="No WiFi interface detected:"
MSG_WIFI_SCAN="Scanning for WiFi networks..."
MSG_WIFI_NONE="No networks found. Check the antenna is enabled or get closer to the router."
MSG_WIFI_CHOOSE="Enter the network number: "
MSG_WIFI_INVALID="Invalid option."
MSG_WIFI_PASS="WiFi password: "
MSG_WIFI_CONNECT="Connecting to '%s'..."
MSG_WIFI_OK="Connected to '%s'!"
MSG_WIFI_NODHCP="Connected, but no IP yet (DHCP pending or not answering — check the router):"

# ip
MSG_IP_NOROUTE="No active default route. Plug in a cable or run ps-wifi first."
MSG_IP_NOADDR="No IP address on %s."
MSG_IP_NMCONN="Active NetworkManager connection not found."
MSG_IP_WIFIIFACE="WiFi interface: %s (connection '%s')"
MSG_IP_MAC="MAC: %s  <- use it for a DHCP reservation in the router"
MSG_IP_PROMPT_IP="Static IP (e.g. %s)"
MSG_IP_PROMPT_GW="Gateway"
MSG_IP_PROMPT_DNS="DNS (space separated)"
MSG_IP_PROMPT_MASK="Netmask (e.g. 255.255.255.0)"
MSG_IP_APPLY_NM="Applying via NetworkManager..."
MSG_IP_RECONNECT="Reconnecting (the SSH session drops for a few seconds)..."
MSG_IP_NEWIP="New IP: %s"
MSG_IP_HINT="Tip: reserve the MAC in the router to skip this step next time."
MSG_IP_ETHIFACE="Ethernet interface: %s"
MSG_IP_WRITE="Writing /etc/network/interfaces..."
MSG_IP_APPLY_HOT="Applying without dropping the session..."
MSG_IP_REBOOT_HINT="After a reboot the configuration becomes permanent."

# status
MSG_STATUS_HEADER="  Print Server - Status"
MSG_STATUS_CUPS=">>> CUPS:"
MSG_STATUS_BROWSED=">>> cups-browsed (discovers network printers):"
MSG_STATUS_AVAHI=">>> Avahi:"
MSG_STATUS_SAMBA=">>> Samba:"
MSG_STATUS_FW=">>> Firewall:"
MSG_STATUS_PRINTERS=">>> Configured printers:"
MSG_STATUS_NONE="   None configured"
MSG_STATUS_QUEUE=">>> Queue:"
MSG_STATUS_QUEUE_EMPTY="   Queue is empty"
MSG_STATUS_NET=">>> Network:"
MSG_STATUS_ACTIVE="   Active"
MSG_STATUS_INACTIVE="   INACTIVE"

# check
MSG_CHECK_DEVICES="=== Detected print devices ==="
MSG_CHECK_PORTS="=== Listening ports ==="
MSG_CHECK_NOTHING="nothing listening"
MSG_CHECK_AVAHI="=== Network printers via Avahi (IPP) ==="
MSG_CHECK_AVAHI_NA="avahi-browse unavailable"
MSG_CHECK_SAMBA="=== Samba config check ==="
MSG_CHECK_LOG="=== CUPS error log (last 30 lines) ==="

# backup
MSG_BACKUP_SAVED="Backup saved to: %s"

# update
MSG_UPDATE_NOREPO="Repository not found in /opt/printserver."
MSG_UPDATE_FIRST="Install it first with the bootstrap one-liner."
MSG_UPDATE_PULL="Fetching updates..."
MSG_UPDATE_APPLY="Re-applying configuration..."

# add-raw-printer
MSG_RAW_PERM="Run as root or as a user in the lpadmin group."
MSG_RAW_USAGE="Usage: %s <name> <ip> [port]"
MSG_RAW_ADDED="Printer '%s' -> socket://%s:%s (raw) added."
MSG_RAW_SEND="Send ZPL/Esc-POS straight:"
MSG_RAW_EXAMPLE="  lpr -P %s file.zpl   (or  nc %s %s < file.zpl)"