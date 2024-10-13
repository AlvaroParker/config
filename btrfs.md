To create subvolumes on btrfs:

```bash
mount /dev/sdXn /mnt

btrfs subvolume create /mnt/@

btrfs subvolume create /mnt/@home

umount /mnt
mount -o subvol=@ /dev/sdXn /mnt
# mount -o subvol=@,compress=zstd /dev/sdXn /mnt
mkdir -p /mnt/home
mount -o subvol=@home /dev/sdXn /mnt/home
# mount -o subvol=@home,compress=zstd /dev/sdXn /mnt/home
```
