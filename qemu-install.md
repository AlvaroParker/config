# QEMU-KVM installation Fedora Linux with Virt manager

First, install the following packages:

```
sudo dnf install qemu-kvm qemu-system-x86 libvirt-client libvirt-daemon bridge-utils virt-manager
```

Enable Libvirtd service

```
sudo systemctl enable --now libvirtd
```

## Start Default Network for Networking

The following command might return an error if the network is already active, this is expected and should be ignored.

```
 sudo virsh net-start default
```

Mark Network default as autostart

```
sudo virsh net-autostart default
```

Check status with:

```
sudo virsh net-list --all
```

Expected output:

```
 Name      State    Autostart   Persistent
--------------------------------------------
 default   active   yes         yes
```

## Add User to libvirt to Allow Access to VMs

Add your user to the following groups:

```
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
sudo usermod -aG input $USER
sudo usermod -aG disk $USER
```

Reboot your computer and you are ready to go!
