# Intel I218-LM NIC Stability Fix for Proxmox

This guide applies to HP Z440 (or similar) running Proxmox with Intel I218-LM NICs that experience random disconnects or link flaps.

## 1) Verify your NIC

Run:
```bash
lspci | grep -i ethernet
ip link
ethtool eno1
```

Confirm you have the Intel I218-LM and note your interface name (usually `eno1`).

## 2) Apply NIC tweaks manually (one-time)

```bash
# Force 1 Gbps full duplex and autoneg
ethtool -s eno1 speed 1000 duplex full autoneg on

# Disable Energy Efficient Ethernet (EEE)
ethtool --set-eee eno1 eee off 2>/dev/null || true

# Disable TSO/GSO/GRO offloads
ethtool -K eno1 tso off gso off gro off
```

Check the result:

```bash
ethtool -k eno1 | grep -E 'tso|gso|gro'
ethtool eno1 | grep -E 'Speed|Duplex'
```

Expected output:

```bash
Speed: 1000Mb/s
Duplex: Full
tso: off
gso: off
gro: off
```

## 3) Make the tweaks persistent on boot

Create a systemd service:

```bash
vi /etc/systemd/system/fix-nic.service
```

Paste:

```bash
[Unit]
Description=Apply network performance tweaks for eno1
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/ethtool -s eno1 speed 1000 duplex full autoneg on
ExecStart=/usr/sbin/ethtool --set-eee eno1 eee off
ExecStart=/usr/sbin/ethtool -K eno1 tso off gso off gro off
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
systemctl daemon-reload
systemctl enable --now fix-nic.service
```

## 4) Optional: Monitor NIC link drops

Create a simple watchdog script:

```bash
vi /usr/local/bin/nic-watchdog.sh
```

Paste:

```bash
#!/bin/bash
LOGFILE="/var/log/nic-watchdog.log"
if dmesg | grep -q "eno1:.*link is down"; then
    echo "$(date): Link drop detected on eno1" >> "$LOGFILE"
fi
```

Make it executable:

```bash
chmod +x /usr/local/bin/nic-watchdog.sh
```

Create a systemd service:

```bash
vi /etc/systemd/system/nic-watchdog.service
```

```bash
[Unit]
Description=Check for NIC link drops

[Service]
Type=oneshot
ExecStart=/usr/local/bin/nic-watchdog.sh
```

Create a timer:

```bash
vi /etc/systemd/system/nic-watchdog.timer
```

```bash
[Unit]
Description=Periodic NIC watchdog

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
```

Enable and start the timer:

```bash
systemctl daemon-reload
systemctl enable --now nic-watchdog.timer
```

Check logs:

```bash
tail -f /var/log/nic-watchdog.log
```

## 5) Optional BIOS tweaks

- Disable Energy Efficient Ethernet (EEE)
- Disable Deep Sleep / Power Saving
- Disable AMT / vPro if unused
- Disable Wake-on-LAN if unused

## 6) Verify stability

```bash
journalctl -k -g 'eno1\|e1000e' -n 50
```

- If no `link is down` messages appear, the NIC is stable.
- Monitor VMs and web UI; disconnects should no longer occur.

## 7) Check the watchdog script logs

### 7.1) Check the logs

Your watchdog writes to:

```bash
/var/log/nic-watchdog.log
```

View the log file in real-time:

```bash
tail -f /var/log/nic-watchdog.log
```

Or just see the last few entries:

```bash
tail -n 20 /var/log/nic-watchdog.log
```

### 7.2) What the log entries mean

The script only writes a line when the NIC link goes down.

Example entry:

```bash
Tue Oct 21 19:30:12 2025: Link drop detected on eno1
```

- **Date/Time:** When the link went down.
- **eno1:** Your NIC interface.
- **Link drop detected:** Means your NIC lost connection with the switch/router.

### 7.3) How to interpret

- **No entries at all:**
    Your NIC has been stable since boot — everything is fine.

- **One or two entries over days/weeks:**
    Minor blips — could be a cable, switch port, or momentary driver hiccup. Usually not a problem.

- **Frequent entries (every few minutes):**
    NIC instability — may indicate:
    - Driver incompatibility (less likely now after our tweaks)
    - Hardware issue (cable, NIC, switch)
    - BIOS or power-saving interference

### 7.4) Optional: Analyze long-term trends

You can count how many drops happened:

```bash
grep -c "Link drop detected" /var/log/nic-watchdog.log
```

Or see daily counts:

```bash
awk '{print $1, $2, $3}' /var/log/nic-watchdog.log | sort | uniq -c
```

This gives you a rough idea if the problem is sporadic or persistent.
