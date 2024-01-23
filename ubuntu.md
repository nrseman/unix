# Installing minimal ubuntu using debootstrap

- Install systemrescuecd on usb-stick
```bash
  sudo dd if=/path/to/systemrescue-x.y.z.iso of=/dev/sdx status=progress 
```
- Partition GPT+UEFI
```bash
  /dev/sda1 /efi       vfat    1GB   ESP (ESP-1GB MSR-16MB WIN WRE-1GB)
  /dev/sda2 /msr       vfat   16MB   MSR
  /dev/sda3 /win       ntfs  800GB   WIN
  /dev/sda4 /wre       ntfs    1GB   WRE
  
  /dev/sda5 /swap      f2fs   64GB  swap
  /dev/sda6 /ubnt      f2fs   64GB  ubnt
  /dev/sda7 /guix      f2fs   64GB  guix
  /dev/sda8 /arch      f2fs   64GB  arch
 
  /dev/sdaA /home      f2fs  256GB  home
  /dev/sdaA /data      f2fs  256GB  data
  /dev/sdaA /free      f2fs  256GB  free
```
- Create filesystem
``` bash
  mkswap /dev/nvme0n1p5
  mkfs.f2fs /dev/nvme0n1p6
```
- Mount root partition
``` bash
  mkdir -p /mnt/ubnt
  mount -t f2fs /dev/nvme0n1p6 /mnt/ubnt
```
- Install debootstrap
``` bash
  mkdir work
  cd work
  wget http://ftp.debian.org/debian/pool/main/d/debootstrap/debootstrap_1.0.132_all.deb
  ar -x debootstrap_1.0.132_all.deb
  cd /
  zcat /full-path-to-work/data.tar.gz | tar xv
```
- Run debootstrap
``` bash
  /usr/sbin/debootstrap --arch amd64 jammy /mnt/ubnt http://archive.ubuntu.com/ubuntu
```
- Configure apt
  - /mnt/ubnt/etc/apt/sources.list
```
    deb http://archive.ubuntu.com/ubuntu jammy           main restricted universe
    deb http://archive.ubuntu.com/ubuntu jammy-security  main restricted universe
    deb http://archive.ubuntu.com/ubuntu jammy-updates   main restricted universe
```
  - /mnt/ubnt/etc/apt/preferences.d/ignored-packages
```
    Package: grub-common grub2-common grub-pc grub-pc-bin grub-gfxpayload-lists
    Pin: release *
    Pin-Priority: -1
    
    Package: snapd cloud-init landscape-common popularity-contest ubuntu-advantage-tools
    Pin: release *
    Pin-Priority: -1
```
- Chroot into new system
```
  arch-chroot /mnt/ubnt
```
- Configure time-zone, locale, and keyboard
```
  dpkg-reconfigure tzdata
  dpkg-reconfigure locales
  dpkg-reconfigure keyboard-configuration
```
- Configure hwclock
- Update, upgrade, and install
```
  apt update and upgrade
  apt install linux-image-generic-hwe linux-headers-generic-hwe linux-firmware initranfs-tools
  apt install efibootmgr systemd-boot
  apt install vim git tmux
```
- Configure users
```
  passwd
  adduser kjetil
  usermod -a -G sudo kjetil
```
- Configure networking
  - Configure hostname
```
    echo "caja" > /etc/hostname
    echo "127.0.1.1. caja" >> /etc/hosts 
```
  - `/etc/systemd/network/ethernet.network
```
    [Match]
    Name=enp8s0

    [Network]
    DHCP=yes
```
- Edit fstab
```
  # <device>      <dir>       <type> <options> <dump> <fsck>
  /dev/nvme0n1p1  /efi        vfat   defaults  0       2
  /dev/nvme0n1p2  /msr        vfat   defaults  0       0
  /dev/nvme0n1p3  /win        ntfs   defaults  0       0
  /dev/nvme0n1p4  /wre        ntfs   defaults  0       0

  /dev/nvme0n1p5  none        swap   defaults  0       0
  /dev/nvme0n1p6  /           f2fs   defaults  0       1
  /dev/nvme0n1p7  /guix       f2fs   defaults  0       0
  /dev/nvme0n2p8  /arch       f2fs   defaults  0       0

  /dev/nvme0n1p9  /home       f2fs   defaults  0       2  
  /dev/nvme0n1p10 /gnu        f2fs   defaults  0       2
  /dev/nvme0n1p11 /free       f2fs   defaults  0       0
```
- Set up boot manager
```
  mkdir -p /efi/EFI/ubuntu
  cp /boot/vmlinuz-6.2.0-34-generic /efi/EFI/ubuntu/vmlinuz-6.2.0-34.efi
  cp /boot/initrd.img-6.2.0-34-generic /efi/EFI/ubuntu/initrd-6.2.0-34.img
```
```
  efibootmgr -c -d /dev/nvme0n1 -p 1 -L "ubuntu" -l '\efi\ubuntu\vmlinuz-6.3.0-34.efi' -u 'root=/dev/nvme0n1p6 initrd=\efi\ubuntu\initramfs-6.2.0-34.img'
  efibootmgr -o 0000,0001,0002
```
- Configure ssh
```
  ssh-keygen -t ed25519 -C "your_email@example.com"
```
- Install packages
```
  sudo apt install vivaldi xinit i3-wm dmenu rxvt-unicode man-db
```

## References
- https://www.debian.org/releases/stable/i386/apds03.en.html
- http://ftp.debian.org/debian/pool/main/d/debootstrap
- https://www.system-rescue.org/Installing-SystemRescue-on-a-USB-memory-stick
- https://wiki.gentoo.org/wiki/Handbook:AMD64/Blocks/Disks
- https://wiki.archlinux.org/title/partitioning
- https://www.debian.org/releases/bullseye/amd64/apcs03.en.html
- https://semjonov.de/posts/2021-09/minimal-ubuntu-installation-with-debootstrap
- https://wiki.gentoo.org/wiki/Efibootmgr
