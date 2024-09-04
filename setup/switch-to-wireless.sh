#!/run/current-system/sw/bin/bash

IFCONFIG=/run/current-system/sw/bin/ifconfig
DNSMASQ=/run/current-system/sw/bin/dnsmasq
PKILL=/run/current-system/sw/bin/pkill

echo "Bringing down enp0s3 . . ."
$IFCONFIG enp0s3 down

echo "Bringing up <wireless> . . ."
$IFCONFIG <wireless> 10.0.0.69 netmask 255.255.0.0

echo "Restarting dnsmasq . . ."
$PKILL dnsmasq
$DNSMASQ --enable-dbus -C /etc/nixos/setup/dnsmasq.conf