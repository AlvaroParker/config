# How to enable hibernation

This doc assumes you followed the installation guide on [Secure-Arch](https://github.com/AlvaroParker/secure-arch/tree/main) (credits to [Ataraxxia](https://github.com/Ataraxxia)). This means you have Arch installed with a Unified Kernel Image, encrypted with LVM and secure boot enabled.

## Creating a swapfile

The first things you'll need to enable hibernation on this specific configuration is to create a swap file. I don't like using swap partitions simply because that would imply I'll have to encrypt that partition as well and I don't want to read the docs to do that.

So, following the Arch Linux wiki on [swap files](https://wiki.archlinux.org/title/Swap#Swap_file), we can create a new one by doing:

```
# mkswap -U clear --size 12G --file /swapfile
```

I'll choose `12G` becuase my current laptop has roughly `6G`. The general rule to choose swap size is:

- 2 GB or less of RAM: Swap should be at least 2x the amount of RAM.
- 2 GB to 8 GB of RAM: Swap can be equal to the amount of RAM or up to 1.5x the RAM.
- 8 GB to 16 GB of RAM: Swap can be equal to the amount of RAM or slightly less (e.g., 0.5x to 1x the RAM).
- More than 16 GB of RAM: Swap size is often equal to the RAM size or even smaller (e.g., 4 GB to 8 GB), depending on your needs.

Now to enable the swap file:

```
# swapon /swapfile
```

And too keep it across reboots we can add the following line to `/etc/fstab`

```
/etc/fstab
    /swapfile none swap defaults 0 0
```

Great! Now we have swap enabled on our system. You can check that by doing

```bash
free
```

And you should see something like this on your terminal

```
               total        used        free      shared  buff/cache   available
Mem:         7034596     4476296      471520       67164     2432656     2558300
Swap:       12582908     2605912     9976996
```

## Enabling hibernation

To enable hibernation, we will need to add two kernel parameters to our configuration. The first one is `resume` to tell the kernel in which device the `swapfile` is and the second one is `resume_offset` to tell the kernel in which part of the device (aka offset) the `swapfile` is located.

### Get `resume` parameter

For the `resume` parameter, we will use the UUID of the disk that contains the `swapfile`. To find the UUID value first you'll need to know in which disk your `swapfile` is:

```bash
df -h /swapfile
```

You should see an output like this:

```
Filesystem           Size  Used Avail Use% Mounted on
/dev/mapper/vg-root  305G   80G  210G  28% /
```

Which indicates that the `/swapfile` is on device `/dev/mapper/vg-root`. Now to get the UUID of that device we can do:

```bash
sudo blkid /dev/mapper/vg-root
```

Wich should return something like this:

```
/dev/mapper/vg-root: UUID="df9c76a1-25bc-4f83-8569-c9425a86115d" BLOCK_SIZE="4096" TYPE="ext4"
```

Great! So now we have our first kernel parameter value. Now let's get the second one.

### Get `resume_offset` parameter

You can check the [Arch wiki article](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Acquire_swap_file_offset) for this as well.

To get the `resume_offset` value, we can run the following command:

```bash
sudo filefrag -v /swapfile
```

Which should return something like this:

```
Filesystem type is: ef53
File size of /swapfile is 4294967296 (1048576 blocks of 4096 bytes)
 ext:     logical_offset:        physical_offset: length:   expected: flags:
   0:        0..       0:      38912..     38912:      1:
   1:        1..   22527:      38913..     61439:  22527:             unwritten
   2:    22528..   53247:     899072..    929791:  30720:      61440: unwritten
...
```

We are interested in the first `physical_offset` value which in this case is `38912`. You can also get the direct value of the offset by using `awk`

```
sudo filefrag -v swap_file | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'
```

### Adding the parameter to the kernel cmd line

Now that we have the `uuid` of the device where the `/swapfile` is and the `offset` of the `/swapfile` file in this device, we can add the values to the kernel parameters.

Remeber that the value we found previously where `"df9c76a1-25bc-4f83-8569-c9425a86115d"` for the UUID of the disk and `38912` for the offset of the `/swapfile`. Now well need to tell the kernel this so it can be able to find the `/swapfile` on boot.

To do this in `dracut` open the `/etc/dracut.conf.d/cmdline.conf` file, where you should see something like this:

```
kernel_cmdline="rd.lunks.uuid=luks-42eb3f89-15a3-427c-9cab-8bcc8d19f94c rd.lvm.lv=vg/root root=/dev/mapper/vg-root rootfstype=ext4 rootflags=rw,relatime"
```

Now simply add the `resume` and `resume_offset` parameters. At the end of the line and **remember to close with a quote character**. Also for the `resume` parameter, you'll need to tell the kernel you are providing the UUID of the device, this is simply done by appending `=UUID` after `resume` (so your kernel parameter should look like `resume=UUID=<uuid of the device>`):

Your `cmdline.conf` file should now look like this:

```
kernel_cmdline="rd.lunks.uuid=luks-42eb3f89-15a3-427c-9cab-8bcc8d19f94c rd.lvm.lv=vg/root root=/dev/mapper/vg-root rootfstype=ext4 rootflags=rw,relatime resume=UUID=df9c76a1-25bc-4f83-8569-c9425a86115d resume_offset=38912"
```

### Rebuilding your unified kernel image

Not sure if this step is needed, but I do it anyway. To rebuild the unified kernel image I simply reinstall the `linux` kernel:

```bash
sudo pacman -S linux
```

## Some tips

If you have enough ram and you just want swap in your system for hibernation, you can [configure the swappiness](https://wiki.archlinux.org/title/Swap#Swappiness) on your devices such that it is never actually used.
