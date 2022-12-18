# `btrfs` File system setup

First create the partition using a tool like `fdisk` or `gdisk`.

After creating the partition, format it with `btrfs`:

```bash
mkfs.btrfs /dev/sdXn
```

Mount the partition:

```bash
mount /dev/sdXn /mnt
```

Create subvolumes:

```bash
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@vm_disks
```

Unmount the partition:

```bash
umount /mnt
```

And mount the subvolumes using `zstd` compression:

```bash
# Root subvolume
mount -o subvol=@,compress=zstd /dev/sdXn /mnt
# Home
mkdir -p /mnt/home
mount -o subvol=@home,compress=zstd /dev/sdXn /mnt/home
# Snapshots
mkdir -p /mnt/.snapshots
mount -o subvol=@snapshots,compress=zstd /dev/sdXn /mnt/.snapshots
# To exclude qemu images from snapshots
mkdir -p /mnt/var/lib/libvirt/images
mount -o subvol=@vm_disks,compress=zstd /dev/sdXn /mnt/var/lib/libvirt/images
```

Finally if using `dracut` and an encrypted LVM, add the following cmdline:

```
kernel_cmdline="rd.luks.uuid=luks-<uuid> rd.lvm.lv=vg/root root=/dev/mapper/vg-root rootfstype=btrfs rootflags=subvol=@,rw,relatime,compress=zstd"

```

Where `<uuid>` is the UUID of the vg/root partition.
