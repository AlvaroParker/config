# Reinstalling Arch beside Windows

This guide wipes Arch on this laptop and installs it again, keeping Windows.
It runs from booting the Arch ISO to the point where `./install` and
[system/README.md](system/README.md) take over. It is written for one
machine: a ThinkPad P14s Gen 5 with one NVMe drive shared with Windows. It
replaces the generic guide that used to be in `secure-arch/`, which gave
Linux the whole disk and would have formatted the EFI partition Windows
boots from.

Nobody has run this guide from start to finish yet. Each step was checked
against the running system and the man pages where that was possible. Steps
marked **Unverified** could not be checked; read them with care.

## The disk

The drive is `nvme0n1`. Windows and Arch share it. A reinstall erases only
the last partition, and writes one file on the first.

| Partition | Size | What it holds | During a reinstall |
| --- | --- | --- | --- |
| `nvme0n1p1` | 2 GiB | The EFI system partition (vfat), mounted at `/boot/efi`. Windows' boot manager lives here too | Mount it. **Never format it** |
| `nvme0n1p2` | 16 MiB | Microsoft reserved, no file system | **Never touch** |
| `nvme0n1p3` | 585 GiB | Windows, encrypted with BitLocker | **Never touch** |
| `nvme0n1p4` | 890 MiB | Windows recovery (NTFS) | **Never touch** |
| `nvme0n1p5` | 1.3 TiB | LUKS2, holding LVM volume group `vg` with one volume, `root` (ext4, mounted at `/`) | The only partition Arch reinstalls |

- The partition table stays as it is. No partitioning tool (`fdisk`,
  `gdisk`, `cfdisk`, `parted`) is needed, so do not open one.
- There is no `/home` volume. Home lives on the root volume, so both ways
  of reinstalling erase it.
- There is no swap partition. Swap is a file, `/swapfile`, on the root
  volume.
- The boot image is a single signed file on the EFI partition,
  `EFI/Linux/bootx64.efi`. There is no boot loader: the firmware entry
  "Arch Linux" starts the image directly.

Partition numbers are the thing that goes wrong. Before any step that
erases something, confirm the layout:

```sh
lsblk -o NAME,SIZE,FSTYPE,PARTTYPENAME /dev/nvme0n1
```

It should look like this:

```
NAME          SIZE FSTYPE      PARTTYPENAME
nvme0n1       1.9T
├─nvme0n1p1     2G vfat        EFI System
├─nvme0n1p2    16M             Microsoft reserved
├─nvme0n1p3 585.1G BitLocker   Microsoft basic data
├─nvme0n1p4   890M ntfs        Windows recovery environment
└─nvme0n1p5   1.3T crypto_LUKS Linux LVM
```

If the sizes or types differ, stop and find out why before going on.

## Two ways to reinstall

Both erase everything on the root volume, including home. They differ in
what happens to the encryption.

| | **Keep the container**: reformat the root volume only | **New container**: recreate LUKS on `nvme0n1p5` |
| --- | --- | --- |
| When it fits | The normal case. The encryption is fine and you only want a clean system | You want a new disk password and a new encryption key, the LUKS header is damaged, or the LVM layout should change |
| Disk password | Stays the same | You choose a new one |
| LUKS UUID (`<LUKS_UUID>`) | Stays the same | Changes |
| TPM unlock | The TPM key stays in the LUKS header. It keeps working if the Secure Boot keys stay the same; otherwise enroll it again | Gone. Enroll it again |
| `<SWAP_UUID>`, `<SWAP_OFFSET>` | Change: the root file system and the swap file are new | Change |

The three placeholders are the disk values in
`system/etc/dracut.conf.d/cmdline.conf`. Step 6 shows how to find each one.

## Btrfs instead of ext4

The root volume is ext4 today, and the steps below are written for that. The
next reinstall is meant to use btrfs, for one reason: it compresses files as
it writes them, so the same data takes less of the disk. Snapshots are not
part of the plan, so there are no subvolumes: one file system on
`/dev/vg/root`, mounted with `compress=zstd`.

LUKS and LVM stay as they are. Btrfs does not need LVM, but keeping `vg/root`
means the encryption, the TPM unlock and most of the kernel command line do
not change, and both ways of reinstalling still work.

Follow the numbered steps, with these changes. None of them has been run on
this machine: `btrfs-progs` is not installed here, so the commands come from
its documentation, not from a test.

| Step | With btrfs |
| --- | --- |
| 3, format | `mkfs.btrfs -f /dev/vg/root` in place of `mkfs.ext4`. `-f` is needed because the volume already holds a file system; check the device name first |
| 3, mount | `mount -o compress=zstd /dev/vg/root /mnt`. The option must be there at this mount: `genfstab` copies it into `fstab`, and the files `pacstrap` writes are compressed from the start |
| 4, packages | Add `btrfs-progs` to `pacstrap`. dracut needs its `btrfs` tool to put btrfs support in the boot image |
| 4, `fstab` | The `/` entry is `btrfs`, and its options include `compress=zstd:3` |
| 6, swap file | `btrfs filesystem mkswapfile --size 68g --uuid clear /swapfile` in place of `mkswap`. A swap file on btrfs must not be compressed or copied on write, and this command makes it that way |
| 6, offset | `btrfs inspect-internal map-swapfile -r /swapfile` prints `<SWAP_OFFSET>`. **Do not use `filefrag` or `genswap`:** on btrfs they print a number the kernel cannot use, and hibernation then fails to resume. `<SWAP_UUID>` is found the same way as before |
| 7, `cmdline.conf` | Besides the three placeholders, change `rootfstype=ext4 rootflags=rw,relatime` to `rootfstype=btrfs rootflags=rw,relatime,compress=zstd` |

Three things to know afterwards:

- **Virtual machine disks.** Large files that are rewritten in place, such
  as the images in `/var/lib/libvirt/images`, fragment badly under copy on
  write. Turn it off for that folder before putting images in it:
  `sudo chattr +C /var/lib/libvirt/images`. It applies to files made there
  from then on, and those files are not compressed.
- **What it saved.** `compsize /`, from the `compsize` package, shows the
  size on disk against the real size.
- **The repo.** `system/etc/dracut.conf.d/cmdline.conf`, the placeholder
  table in system/README.md and the `genswap` script still describe ext4.
  Change them once the machine runs btrfs, so the repo matches it again.

**Unverified:** that dracut, building in the chroot with `hostonly="yes"`,
adds its btrfs module by itself. If the new system cannot find its root at
boot, add a file in `/etc/dracut.conf.d` with `add_dracutmodules+=" btrfs "`
and build the image again.

## 1. Before you start

Do these in the running system, before booting the ISO.

**The BitLocker recovery key.** Write it down somewhere off this laptop.
It is in the Microsoft account that Windows signed in with, or Windows
shows it with `manage-bde -protectors -get C:` in an administrator
terminal. Turning Secure Boot off and on, and above all changing the Secure
Boot keys, can make Windows ask for it at its next start. Without it,
Windows' data is gone.

**The disk password.** To keep the container, you need it: the ISO starts
with Secure Boot off, so the TPM will not unlock the disk there.

**Your home folder.** Both ways erase it. Copy off what you want to keep,
including the personal files listed in DESIGN.md's "State outside the repo".

**The Secure Boot keys.** sbctl keeps the keys that sign the boot image in
`/var/lib/sbctl`, on the root volume, so the reinstall erases them. The
firmware still trusts them afterwards. Restoring them means the firmware's
keys never change: Windows should not ask for its recovery key, and a kept
container's TPM key should keep working. Copy them to an encrypted USB
stick or similar:

```sh
sudo tar -C /var/lib -czf /path/to/usb/sbctl-keys.tar.gz sbctl
```

Treat that file like a password. Whoever holds `db.key` can sign anything
this laptop will boot, and whoever holds `PK.key` can change which keys the
firmware trusts. Without the backup, step 7 makes new keys, which changes
the firmware's keys. If that is the plan, read "New keys" in step 7 now: it
suggests suspending BitLocker in Windows before you start.

**The EFI partition's files.** Nothing in this guide formats the EFI
partition, but Windows' boot manager lives there, and a copy makes a slip
recoverable:

```sh
sudo tar -C /boot/efi -czf /path/to/usb/efi-files.tar.gz EFI
```

**To keep the container, its header.** The LUKS header holds the key slots.
If it is damaged, the disk password no longer opens the disk. A copy can be
written back with `cryptsetup luksHeaderRestore`:

```sh
sudo cryptsetup luksHeaderBackup /dev/nvme0n1p5 --header-backup-file /path/to/usb/luks-header.img
```

Keep it as safe as the keys above: with the disk password, it opens the disk.

**For a new container, the LUKS flags.** Recreating the container drops the
flags saved in the old header. Note them now:

```sh
sudo cryptsetup luksDump /dev/nvme0n1p5 | grep -i flags
```

On this machine TRIM reaches the drive through the encryption (`lsblk -D`
shows discard sizes on the `luks-…` device), and `fstrim.timer` uses it, so
`allow-discards` is probably among them. The old guide also set
`no-read-workqueue` and `no-write-workqueue`. Reuse whatever this command
shows.

**A USB stick with the Arch ISO.** Writing the ISO erases the stick. Check
the stick's name with `lsblk` first, and never write to `nvme0n1`.

## 2. Boot the ISO

At power on, F1 opens the firmware setup and F12 the boot menu. From a
running Arch, `systemctl reboot --firmware-setup` also opens the setup.

1. In the setup, under Security, turn Secure Boot off. The Arch ISO is not
   signed for Secure Boot. Turning it off keeps the enrolled keys; do not
   clear or reset any keys here. Do not start Windows while it is off:
   BitLocker may ask for the recovery key.
2. Start the USB stick from the boot menu.
3. Connect to Wi-Fi. The ISO uses iwd; the installed system will not.

   ```sh
   iwctl station wlan0 connect "<SSID>"   # iwctl device list shows the name
   ping -c 3 archlinux.org
   ```

4. Confirm the layout with the `lsblk` command from [The disk](#the-disk).
   The USB stick shows up as another drive, such as `sda`.

## 3. Prepare the root volume

Do one of the two. Both end with an empty ext4 file system on
`/dev/vg/root`. For btrfs, the format and mount commands differ; see
[Btrfs instead of ext4](#btrfs-instead-of-ext4).

### Keep the container

```sh
lsblk -dno FSTYPE /dev/nvme0n1p5             # must print crypto_LUKS
cryptsetup open /dev/nvme0n1p5 cryptlvm      # asks for the disk password
vgchange -ay vg
lsblk /dev/nvme0n1p5                         # cryptlvm and vg-root under it
mkfs.ext4 /dev/vg/root
```

Flags saved in the header apply by themselves when the container opens. If
`mkfs.ext4` says the volume already holds a file system and asks whether to
go on, that is the old system: answer `y`.

### New container

This erases the whole of `nvme0n1p5`. Check it first, and read the device
name in `luksFormat`'s question before typing `YES`.

```sh
lsblk -dno FSTYPE,SIZE /dev/nvme0n1p5        # must print crypto_LUKS 1.3T
cryptsetup luksFormat --type luks2 /dev/nvme0n1p5
cryptsetup open --allow-discards --persistent /dev/nvme0n1p5 cryptlvm
pvcreate /dev/mapper/cryptlvm
vgcreate vg /dev/mapper/cryptlvm
lvcreate -l 100%FREE vg -n root
mkfs.ext4 /dev/vg/root
```

`--persistent` saves the open flags in the new header, so every later boot
uses them. Put in the flags step 1 found; `--allow-discards` is the one
TRIM needs. It also lets someone with the raw drive see which blocks are in
use, which the old setup accepted too.

Keep the names `vg` and `root`. The kernel command line looks for
`vg/root`.

### Mount

```sh
mount /dev/vg/root /mnt
mount --mkdir -o fmask=0077,dmask=0077 /dev/nvme0n1p1 /mnt/boot/efi
ls /mnt/boot/efi/EFI
```

The last command should list `Microsoft`, and `Linux` from the old system.
That is the shared EFI partition: mount it, never format it. The
`fmask`/`dmask` options keep it readable by root only, as now, and
`genfstab` copies them into `fstab`.

If you are restoring the Secure Boot keys, copy the backup in now, so the
chroot can reach it:

```sh
cp /path/to/usb/sbctl-keys.tar.gz /mnt/root/
```

## 4. Install the base system

```sh
pacstrap -K /mnt base linux linux-firmware intel-ucode sof-firmware \
    lvm2 dracut tpm2-tools sbctl sbsigntools binutils efibootmgr \
    e2fsprogs dosfstools networkmanager sudo vim git zsh man-db
```

`install` brings everything else later. These are what the first boot needs
before it runs:

| Packages | Why |
| --- | --- |
| `intel-ucode` | CPU microcode; dracut adds it to the image |
| `sof-firmware` | Firmware for the laptop's audio |
| `lvm2`, `dracut` | The encrypted LVM root, and the tool that builds the boot image. dracut stands in for mkinitcpio, which is not used |
| `tpm2-tools` | Without it, dracut refuses the TPM module that `tpm2.conf` asks for and stops before writing the image |
| `sbctl`, `sbsigntools`, `binutils` | Secure Boot keys, and the signing and packing that `dracut --uefi` does |
| `efibootmgr` | The firmware boot entry |
| `e2fsprogs`, `dosfstools` | File system checks for `/` and `/boot/efi`; `filefrag` for the swap offset |
| `networkmanager` | The network. The desktop's Wi-Fi menu drives it with `nmcli`. The old guide's `iwd` and `dhcpcd` are not used |
| `git`, `zsh`, `sudo`, `vim` | To clone this repo, the login shell, and editing |

If pacman asks which package should provide `initramfs`, pick `dracut`.

dracut's and sbctl's own pacman hooks run during `pacstrap` and may print
errors, because the boot files are not in place yet. They are harmless: step
7 builds the image. dracut's hook may also leave `/boot/vmlinuz-linux` and
`/boot/initramfs-linux.img` on the root volume; nothing uses them, and they
can be deleted. **Unverified:** what these hooks print in `pacstrap`.

Write `fstab`:

```sh
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
```

It should hold two entries: `/` (ext4, `rw,relatime`) and `/boot/efi`
(vfat, with `fmask=0077,dmask=0077`). Step 6 adds the swap file.

## 5. Configure the system

```sh
arch-chroot /mnt
```

Time, language and name:

```sh
ln -sf /usr/share/zoneinfo/<Region>/<City> /etc/localtime
hwclock --systohc                             # the hardware clock keeps UTC
vim /etc/locale.gen                           # uncomment en_US.UTF-8 UTF-8
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo '<hostname>' > /etc/hostname
```

The keyboard is US, the console's default, so no `vconsole.conf` is needed.

The root password, and your user in `wheel` with zsh as its shell:

```sh
passwd
useradd -m -G wheel -s /usr/bin/zsh <user>
passwd <user>
EDITOR=vim visudo                             # uncomment %wheel ALL=(ALL:ALL) ALL
```

`install` adds the other groups it needs (`libvirt`, `kvm`, `docker`,
`video` and so on). It would also set the login shell, but `useradd` sets it
here so the first login is already zsh.

Services. `install` enables Bluetooth, TLP, Docker, Tailscale and libvirt
itself. The network is needed before `install` can run, so it is enabled
here, with the others `install` leaves alone:

```sh
systemctl enable NetworkManager systemd-resolved systemd-timesyncd fstrim.timer
```

NetworkManager starts `wpa_supplicant` for Wi-Fi when it needs it.
`systemd-resolved` is enabled to match the current system.

This repo, in your home folder:

```sh
sudo -u <user> git clone https://github.com/AlvaroParker/config.git /home/<user>/config
```

## 6. The swap file and hibernation values

Hibernation writes memory into the swap file. At boot, the kernel finds it
by two values on the command line: `resume=UUID=` names the file system that
holds the file, and `resume_offset=` says where the file starts on it. Make
the file at least as large as the memory (64 GB here; the current file is
68 GiB). These commands are for ext4. On btrfs both the file and its offset
are made differently, and the ext4 commands give a wrong offset; see
[Btrfs instead of ext4](#btrfs-instead-of-ext4).

```sh
mkswap -U clear --size 68G --file /swapfile
echo '/swapfile none swap defaults 0 0' >> /etc/fstab
```

Then read the three values `cmdline.conf` needs:

```sh
blkid -s UUID -o value /dev/nvme0n1p5         # <LUKS_UUID>
blkid -s UUID -o value /dev/vg/root           # <SWAP_UUID>, the root file system
filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'   # <SWAP_OFFSET>
```

`<SWAP_UUID>` is the UUID of the root file system, because that is where
the file lives; on the running system it matches
`findmnt -no UUID -T /swapfile`. The offset is the first physical block in
`filefrag`'s table.

The `genswap` script does the same on an installed system: it makes the
file, turns it on, adds the `fstab` line and prints the two swap values. It
is for making a swap file later. Do not run it after this step, or `fstab`
gets a second swap line. If the swap file is ever made again, its offset
changes: put the new value in `cmdline.conf` and rebuild the image.

## 7. Boot files, Secure Boot keys and the boot image

### Boot files

Put the boot files from `system/` in place. These are the boot lines from
system/README.md's "Installing"; you are root here, so no `sudo`:

```sh
cd /home/<user>/config/system
install -Dm644 -t /etc/dracut.conf.d etc/dracut.conf.d/*.conf
install -Dm644 -t /etc/pacman.d/hooks etc/pacman.d/hooks/*.hook
install -Dm755 -t /usr/local/bin usr/local/bin/dracut-install.sh usr/local/bin/dracut-remove.sh
install -Dm644 etc/modprobe.d/thinkpad_acpi.conf /etc/modprobe.d/thinkpad_acpi.conf
vim /etc/dracut.conf.d/cmdline.conf           # fill in the three values from step 6
grep -o 'rd.luks.uuid=[^ ]*\|resume[^ ]*' /etc/dracut.conf.d/cmdline.conf
```

The last command should print three lines with real values and no `<`.
Replace only the placeholders: `rd.luks.uuid=` keeps its `luks-` prefix.
On btrfs, change `rootfstype` and `rootflags` here too.

The hooks in `/etc/pacman.d/hooks` replace dracut's and sbctl's own hooks of
the same name. From now on, every kernel update rebuilds
`EFI/Linux/bootx64.efi` and signs it.

The rest of `system/` (login screen, fingerprint, sleep, the splash) waits
until after `./install`, because it needs packages `install` brings.

### Secure Boot keys

`secureboot.conf` tells dracut to sign the image with the key in
`/var/lib/sbctl/keys/db/`, so the keys must be there before the image is
built. Do one of the two.

**Restore the backup** (step 1). The firmware already trusts these keys, so
nothing changes in the firmware:

```sh
tar -C /var/lib -xzf /root/sbctl-keys.tar.gz
rm /root/sbctl-keys.tar.gz
ls /var/lib/sbctl/keys                        # db  KEK  PK
```

**New keys**, when there is no backup:

```sh
sbctl create-keys
```

The firmware does not trust new keys until they are enrolled, which happens
after the first boot (step 9). Enrolling replaces the firmware's keys, which
changes what the TPM measures in PCR 7. Windows' BitLocker will very likely
ask for its recovery key once, and a kept container's TPM key stops working
until it is enrolled again. **Unverified:** that BitLocker asks; it depends
on how Windows sealed its key. To avoid the question, suspend BitLocker in
Windows before step 2, in an administrator PowerShell, then shut Windows
down and go straight to the reinstall:
`Suspend-BitLocker -MountPoint "C:" -RebootCount 2`. Its protection comes
back by itself after two Windows starts, sealed to the new keys.
**Unverified** on this machine. Keep the recovery key at hand either way.

### Build the image

```sh
kver=$(ls /usr/lib/modules)                   # one kernel is installed
dracut --force --uefi --kver "$kver" /boot/efi/EFI/Linux/bootx64.efi
sbverify --cert /var/lib/sbctl/keys/db/db.pem /boot/efi/EFI/Linux/bootx64.efi
```

`sbverify` should say `Signature verification OK`. The image replaces the
old system's at the same path; nothing else on the EFI partition changes.

**Unverified:** building in the chroot with `hostonly="yes"` (from
`flags.conf`). dracut then picks drivers from the ISO's running system, which
should match this hardware. If the new system cannot find its disk at boot,
come back to the chroot (see [If the boot breaks](#if-the-boot-breaks)),
build again with `--no-hostonly` added, and once the system runs, rebuild
without it.

### The firmware boot entry

The reinstall keeps the image's path, so the firmware entry from the old
system still points at it. Check:

```sh
efibootmgr
```

Look for `Arch Linux` with `EFI\Linux\bootx64.efi`, and a `BootOrder`
that starts with it, followed by `Windows Boot Manager`. If both hold, there
is nothing to do. If the entry is missing, add it:

```sh
efibootmgr --create --disk /dev/nvme0n1 --part 1 --label "Arch Linux" --loader '\EFI\Linux\bootx64.efi'
```

`--part 1` only says where the image lives; it does not change the
partition. `--create` puts the new entry in the boot order. Run `efibootmgr`
again, and if the order is wrong, set it with
`efibootmgr --bootorder XXXX,YYYY,…`: Arch's number, then Windows', then
the rest as listed. Do not delete the Windows entry or the firmware's own
entries.

## 8. Restart

```sh
exit
umount -R /mnt
reboot
```

Open the firmware setup (F1) on the way.

- **Restored keys:** turn Secure Boot back on. The disk may unlock by itself
  (a kept container, with PCR 7 as before) or ask for its password.
- **New keys:** put Secure Boot in Setup Mode by clearing its keys. On
  ThinkPads the option is under Security, Secure Boot, named something like
  "Reset to Setup Mode" or "Clear All Secure Boot Keys" (**Unverified**
  wording). Do not start Windows until step 9 is done.

## 9. First boot

There is no login screen yet. Log in on the text console as your user, then
connect:

```sh
sudo nmcli --ask device wifi connect "<SSID>"
```

**New keys only.** Enroll them, with Microsoft's beside them:

```sh
sudo sbctl status                             # Setup Mode: Enabled
sudo sbctl enroll-keys --microsoft
systemctl reboot --firmware-setup
```

Never leave out `--microsoft`. Microsoft's certificates are what let
Windows and the firmware's own drivers start; sbctl 0.18 carries both the
2011 and the 2023 ones, as the current firmware has. In the setup, check
that Secure Boot is on, then start Arch. `sbctl status` should now show
Secure Boot enabled and `Vendor Keys: microsoft`. Then start Windows once
and give it the recovery key if it asks.

**The TPM unlock.** Enroll the TPM only from a boot with Secure Boot on and
this image, which already carries the TPM module. system/README.md,
[Unlocking with the TPM](system/README.md#unlocking-with-the-tpm), explains
why the order matters.

- Kept container, and the boot did not ask for the disk password: nothing to
  do. The old TPM key still works.
- Kept container, and it asked: enroll again. The old TPM key is replaced;
  the password stays.

  ```sh
  sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p5
  ```

  After `./install`, `tpm-reenroll` runs the same command.
- New container: enroll for the first time.

  ```sh
  sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p5
  ```

Restart: no password prompt means it worked.

## 10. Hand over to `./install` and system/README.md

```sh
cd ~/config
./install
```

Then:

1. Restart, since `install` may have updated the kernel. Rebuild the boot
   image as system/README.md, [The boot image](system/README.md#the-boot-image),
   shows. The pacman hook rebuilds it only when the kernel changes, and the
   image needs Plymouth, which `install` has now added.
2. Follow [system/README.md](system/README.md) for the rest: the splash, the
   login screen, the fingerprint and sleep. Check the greeter's user id
   before installing `skip-greeter.conf`; a new install may give it a
   number other than 954.
3. README.md's [Installation](README.md#installation) section covers
   mirrors and the login screen.
4. Test hibernation with `systemctl hibernate`. If it does not come back to
   the open session, check `resume=` and `resume_offset=` in `/proc/cmdline`
   against step 6.

This machine also has `fwupd` (firmware updates) and `iwd` installed outside
the package lists. Neither is needed to boot. A firmware or revocation
update from `fwupd` changes PCR 7; `tpm-reenroll` handles that.

## If the boot breaks

The image has no rescue shell (`rd.shell=0`) and restarts on failure
(`rd.emergency=reboot`). To fix it from the ISO, turn Secure Boot off, start
the ISO, and:

```sh
cryptsetup open /dev/nvme0n1p5 cryptlvm       # the disk password
vgchange -ay vg
mount /dev/vg/root /mnt
mount /dev/nvme0n1p1 /mnt/boot/efi
arch-chroot /mnt
```

Fix the problem, build the image again (step 7), and turn Secure Boot back
on before starting Arch. With Secure Boot off the TPM unlocks nothing, which
is the point.
