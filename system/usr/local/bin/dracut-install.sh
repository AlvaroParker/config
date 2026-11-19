#!/usr/bin/env bash

mkdir -p /boot/efi/EFI/Linux

while read -r line; do
	if [[ "$line" == 'usr/lib/modules/'+([^/])'/pkgbase' ]]; then
		kver="${line#'usr/lib/modules/'}"
		kver="${kver%'/pkgbase'}"

		dracut --force --uefi --kver "$kver" /boot/efi/EFI/Linux/bootx64.efi
	fi
done
