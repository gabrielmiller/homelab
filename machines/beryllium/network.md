# Wake-on-lan (wol)

## Prerequisites

### Hardware

Make sure that bios/uefi is configured to enable wake on lan. As of writing I am doing this on a wired interface, _not_ wireless / wowlan.

### Software

Ensure that the wake-on-lan setting is persisted for the server's network interface. I also had to make sure EEE was disabled on the interface. This seems like a quirk of my particular hardware. _See later section for how to configure that._

#### Option 1: Add to existing network unit file
Make sure the unit file contains the `WakeOnLan=magic` directive, like so:
```
# file: /etc/systemd/network/50-wired.link

[Match]
MACAddress=aa:bb:cc:dd:ee:ff

[Link]
NamePolicy=kernel database onboard slot path
MACAddressPolicy=persistent
WakeOnLan=magic
```

reference: https://wiki.archlinux.org/title/Wake-on-LAN#systemd.link

#### Option 2: Create a dedicated unit file for wol
Alternatively configure a dedicated unit file for the configuration, like so:
```
# file: /etc/systemd/system/wol@.service

[Unit]
Description=Wake-on-LAN for <interface>
Requires=network.target
After=network.target

[Service]
ExecStart=/usr/bin/ethtool -s <interface> wol g
Type=oneshot

[Install]
WantedBy=multi-user.target
```

reference: https://wiki.archlinux.org/title/Wake-on-LAN#systemd_service

#### Dry run

You will need to install `wakeonlan` or a comparable wol tool on the client.

```sh
# On the server:
#  - First note the mac address of the network interface
#  - Then power off the machine
ip addr
sudo poweroff

# On the client:
#  - Confirm that the server is off
#  - Send the server a magic packet to wake it up
#  - Check if it woke up
nc -v -z -w 1 <server host, ip or dns> 22 &> /dev/null && echo "Online" || echo "Offline"
wakeonlan <mac_address>
```

To diagnose the network interface on the server, make sure wake on lan is running and set to magic packet. The magic packet setting for wake-on is sometimes abbreviated as `g`.
```sh
ethtool <interface> | grep Wake-on
```

# Configuration

## Disable EEE

In order for wake on lan to work on rtl8125 you may need to disable EEE on the respective network interface.

To diagnose:
```sh
sudo ethtool --show-eee <interface>
sudo ethtool --set-eee <interface> eee off
```

Systemd unit file to make the change persistent:
```
[Unit]
Description=Disable Energy-Efficient Ethernet for <interface>
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/ethtool --set-eee <interface> eee off
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

reference: https://bbs.archlinux.org/viewtopic.php?pid=2239472#p2239472