# A collection of UNIX related notes


## Installing minmal ubuntu using debootstrap
- Install systemrescuecd on usb-stick
  ```bash
  sudo dd if=/path/to/systemrescue-x.y.z.iso of=/dev/sdx status=progress 
  ```
- Partition GPT+UEFI
  ```
  /dev/sda1 /efi       vfat    1GB   ESP (ESP-1GB MSR-16MB WIN WRE-1GB)
  /dev/sda2 /msr       vfat   16MB   MSR
  /dev/sda3 /win       ntfs  800GB   WIN
  /dev/sda4 /wre       ntfs    1GB   WRE
  
  /dev/sda6 /ubnt      f2fs   64GB  ubnt
  /dev/sda7 /guix      f2fs   64GB  guix
  /dev/sda8 /arch      f2fs   64GB  arch
  /dev/sda0 /swap      f2fs   64GB  swap
  /dev/sdaA /home      f2fs  256GB  home
  /dev/sdaA /data      f2fs  256GB  data
  /dev/sdaA /free      f2fs  256GB  free
  ```
- Create filesystem
  ```bash
  mk.f2fs /dev/sda6
  ```
- Mount root partition
  ```bash
  mkdir -p /mnt/ubnt
  mount -t f2fs /dev/sda6 /mnt/ubnt
  ```
- Install deboostrap
  ```bash
  wget http://ftp.debian.org/debian/pool/main/d/debootstrap/debootstrap_1.0.132_all.deb
  mkdir work
  cd work
  ar -x debootstrap_1.0.132_all.deb
  cd /
  zcat /full-path-to-work/data.tar.gz | tar xv
  ```
- Run debootstrap
  ```bash
  /usr/sbin/debootstrap --arch amd64 jammy/mantic /mnt/ubnt http://archive.ubuntu.com/ubuntu
  ```
- Chroot into new system
- Configure base system
- Create device files (or udev?)
- Edit fstab
- Set timezone
- Configure networking
- Configure apt
- Configure locales and keyboard
- Install a kernel
- Set up boot loader
- Configure ssh
- Clean-up

## References
- https://www.debian.org/releases/stable/i386/apds03.en.html
- http://ftp.debian.org/debian/pool/main/d/debootstrap
- https://www.system-rescue.org/Installing-SystemRescue-on-a-USB-memory-stick
- https://wiki.gentoo.org/wiki/Handbook:AMD64/Blocks/Disks
- https://wiki.archlinux.org/title/partitioning
- https://www.debian.org/releases/bullseye/amd64/apcs03.en.html
- https://semjonov.de/posts/2021-09/minimal-ubuntu-installation-with-debootstrap
