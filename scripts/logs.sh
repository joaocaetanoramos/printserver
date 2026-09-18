#!/bin/bash
# Acompanhar logs relevantes em tempo real
tail -f \
    /var/log/cups/error_log \
    /var/log/samba/log.smbd \
    /var/log/syslog 2>/dev/null \
    | grep -i -E "(cups|samba|printer|usb|error|warn)"