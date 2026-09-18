# Print Server · Centralize every legacy printer on your network

Turn one old PC or a Raspberry Pi into a **central print hub** for your whole
organization. Give printers that only speak USB a real network address, and let
every computer — Windows, macOS, Linux — print to them over the LAN *and* over
WiFi. No per-device driver hunts, no "who's connected to the printer?" guessing.

> **Printers are meant to be shared. This is the cheapest way to do it.**

> 🇧🇷 Fala português? Veja o [`README.pt-BR.md`](README.pt-BR.md).
> The interface and scripts follow your system language automatically
> (English default, Brazilian Portuguese when `LANG` is `pt_*`).

---

## Why you want this

- **Your printer only has USB.** It sits on one desk, and only the person
  plugged into it can print. This server gives it an IP, and everyone prints to
  it like it was a network printer.
- **You juggle many printers** (HP, Brother, Epson, Zebra thermal, generic
  Chinese ones). One server manages all of them in a single web UI.
- **Shares & PDF**: print to a shared folder, or "print to PDF" when you just
  need the file.
- **Old hardware still rocks.** A decade-old PC or a Raspberry Pi is more than
  enough. This is a headless, lightweight Debian server — no desktop, no waste.
- **Zero per-machine setup chaos.** Drivers live in one place. Clients just
  add a network printer (IPP) and go.

(Images of printers, and of a beat-up old PC happily serving them, go here.)

---

## Features

| | |
|---|---|
| **CUPS/IPP server** | industry-standard printing, works with Windows/macOS/Linux, AirPrint-ready |
| **Samba** | legacy Windows sharing (`Add printer` via `\\server`) |
| **Avahi/mDNS** | printers are *discovered* automatically on the network |
| **Raw socket (9100)** | one-liner for Zebra, thermal and generic printers — no driver needed |
| **Drivers included** | HP, Brother laser, Epson, 58 mm thermal, foo2zjs for Samsung/Xerox-clones |
| **Localized** | English by default; Brazilian Portuguese if your system is `pt_BR` |
| **Git-managed, idempotent** | install once with one command, update the same way |

---

## What can run this

- Any old PC (Intel/AMD, **64-bit**).
- **Raspberry Pi** and similar low-power boards (ARM).
- Under Debian-based distributions. You'll need ~2 GB of storage for a comfy setup.

> This project installs CUPS, Avahi, Samba and UFW on a minimal Debian install.

---

## Quick start

The whole server is provisioned by **one command**:

```bash
sudo -i
wget -qO- https://raw.githubusercontent.com/joaocaetanoramos/printserver/main/scripts/bootstrap.sh | bash
```

The installer:
- installs CUPS + drivers (HP, Epson, Brother laser, thermal, generic), Avahi, Samba, UFW;
- copies operational scripts, adds your user to `lpadmin`;
- opens the right ports (631 CUPS, 9100 raw, 5353 Avahi, Samba);
- enables and starts services.

First boot (once, manual):
1. Install Debian netinst — your choice of language, hostname `printserver`, any
   username you like (the installer auto-detects it).
   **Do not tick any package selection.**
2. Run the command above.
3. Set a **static IP** with `ps-ip` (it suggests your current address/gateway/DNS).
4. Add your printers in the CUPS web UI — `http://SERVER-IP:631`.

### Add printers

| Printer | How |
|---|---|
| USB | plug it in → CUPS web UI → Add Printer → pick the USB device → driver |
| Network/IPP | CUPS web UI → "IPP / Network Printer", or auto-discovery |
| HP | `hp-setup -i` |
| Epson | managed automatically (escpr/gutenprint) |
| Brother laser | covered by `brlaser`; inkjet: download the `.deb` from Brother |
| Zebra / thermal / generic | no driver at all — raw queue: |

```bash
ps-add-raw-printer zebra-100 192.168.1.150
lpr -P zebra-100 label.zpl
```

---

## Commands (installed as `/usr/local/bin/ps-*`)

| Action | Command |
|---|---|
| Status overview | `ps-status` |
| Full diagnostics | `ps-check` |
| Restart services | `ps-restart` |
| Tail logs | `ps-logs` |
| Backup configs | `ps-backup` |
| Connect to WiFi | `ps-wifi` |
| Set static IP | `ps-ip` |
| Raw printer (Zebra/generic) | `ps-add-raw-printer name ip` |
| Update from the repo | `ps-update` |
| Printer tools | `lpinfo -v`, `lpstat -p`, `lpq`, `cancel -a` |

---

## Updates

The repository is the single source of truth. Updates are **idempotent** — re-run
and only the changes apply:

```bash
sudo -i
ps-update
```

`update.sh` does a `git pull`, re-applies configs and restarts services.
Configs are copied from the repo on every update — edit them in
`/opt/printserver/configs/`, not in `/etc/...`, or your tweaks will be overwritten.

---

## WiFi

```bash
sudo -i
ps-wifi                # list networks, pick one, type the password
ps-wifi MySSID MyPass  # or connect directly
```

NetworkManager is installed if missing and left to manage only WiFi — the
Ethernet config from `/etc/network/interfaces` stays untouched.

Best practice for a WiFi-only box: keep DHCP but set a **DHCP reservation** for
the server's MAC in your router — the IP then never changes. `ps-ip` shows you
the MAC to register.

---

## Static IP (`ps-ip`)

Detects the active interface and offers your current IP/gateway/DNS as
suggestions — you just confirm or tweak:

- **Ethernet** → writes `/etc/network/interfaces` (backup in `/root/net-backup`)
  and applies without dropping your SSH session. Permanent after a reboot.
- **WiFi** → applies through NetworkManager (`nmcli`) and reconnects (your SSH
  session drops briefly).

Private networks you don't have to fear: this shares *printers only*, not files.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Printer not discovered on the network | `systemctl status avahi-daemon` · `avahi-browse -rt _ipp._tcp` |
| CUPS not answering | `ss -tlnp \| grep 631` · `tail -50 /var/log/cups/error_log` |
| Old Windows won't install over Samba | use IPP instead: add printer → `http://SERVER-IP:631/printers/NAME` |
| foo2zjs firmware missing (Samsung/Xerox-clones) | `sudo /usr/share/doc/printer-driver-foo2zjs/getweb <model>` |

---

## Internationalization

Messages and the interface follow the system locale:

- `LANG=pt_BR.*` → **Portuguese (Brazil)**
- anything else → **English** (default)

Override with: `PS_LANG=pt-BR ps-ip`.

---

## Manual steps that can't be automated

| Step | Why |
|---|---|
| Install Debian netinst, set root password | boot-time and install-time only |
| Static IP (now via `ps-ip`) | network-specific |
| Add the actual printers | model/firmware-specific (HP `hp-setup`, Brother `.deb`) |
| Zebra/thermal/generic | raw queue via `ps-add-raw-printer` |

---

## License & notes

Runs on Debian-based systems; everything used here (CUPS, Samba, Avahi, UFW,
the `printer-driver-*` packages) is free and open source.