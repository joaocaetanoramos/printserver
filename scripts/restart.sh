#!/bin/bash
# Reiniciar todos os servicos do print server
systemctl restart cups cups-browsed avahi-daemon smbd nmbd
ufw --force disable && ufw --force enable
systemctl status cups --no-pager -l | head -8