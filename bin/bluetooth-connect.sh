#!/bin/sh

set -euC

connect() {
	local MAC=$(echo "$1" | cut -d ' ' -f2)

	pulseaudio --start
	bluetoothctl power on
	bluetoothctl connect $MAC
}

devs=$(echo 'devices' | bluetoothctl | grep '^Device')

IFS="
"

if [ -n "${1:-}" ]; then
	for dev in $(echo "$devs"); do
		if echo "$dev" | grep -iq "$1$"; then
			connect "$dev"
			break
		fi
	done
	exit 0
fi

i=0
for dev in $(echo "$devs" | cut -d ' ' -f3-); do
	echo "$(( i=i+1 )) $dev"
done

printf "Device number: "
read n
connect $(echo "$devs" | sed "${n}p;d")
