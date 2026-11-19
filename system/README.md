# System files

Root-owned files from `/etc` and `/usr/local/bin` that this laptop depends on.
The install script does not copy them: they control how the machine boots, so
put them in place by hand and check each one first. The folder layout mirrors
the paths on the system.

| File | What it does |
| --- | --- |
| `etc/modprobe.d/thinkpad_acpi.conf` | Lets `bin/set-fan` control the ThinkPad fan |
| `etc/dracut.conf.d/cmdline.conf` | Kernel command line for the unified kernel image: encrypted root, hibernation, fan control, and the Intel `xe` driver for this GPU |
| `etc/dracut.conf.d/drivers.conf`, `flags.conf` | Extra drivers, compression and host-only images |
| `etc/dracut.conf.d/secureboot.conf` | Signs the image with the sbctl keys |
| `etc/pacman.d/hooks/90-dracut-install.hook`, `60-dracut-remove.hook` | Rebuild or remove the kernel image when the kernel package changes |
| `etc/pacman.d/hooks/zz-sbctl.hook` | Re-signs the image after every kernel update |
| `usr/local/bin/dracut-install.sh`, `dracut-remove.sh` | The scripts those hooks run |

See `secure-arch/` for the full setup and `Hibernation.md` for the swap file.

## Placeholders in cmdline.conf

`cmdline.conf` holds three values that identify this machine's disks, so the
repo keeps placeholders. Fill them in when installing:

| Placeholder | How to find it |
| --- | --- |
| `<LUKS_UUID>` | `sudo blkid -s UUID -o value /dev/<encrypted partition>` |
| `<SWAP_UUID>` | `findmnt -no UUID -T /swapfile` |
| `<SWAP_OFFSET>` | `sudo filefrag -v /swapfile`, first physical offset; `genswap` prints both swap values |

## Installing

```sh
sudo install -Dm644 etc/modprobe.d/thinkpad_acpi.conf /etc/modprobe.d/thinkpad_acpi.conf
sudo install -Dm644 -t /etc/dracut.conf.d etc/dracut.conf.d/*.conf
sudo install -Dm644 -t /etc/pacman.d/hooks etc/pacman.d/hooks/*.hook
sudo install -Dm755 -t /usr/local/bin usr/local/bin/*.sh
sudoedit /etc/dracut.conf.d/cmdline.conf   # replace the three placeholders
```
