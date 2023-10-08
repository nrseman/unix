# A collection of UNIX related notes


## Installing minmal ubuntu using debootstrap
- Install systemrescuecd on usb-stick
  ```bash
  sudo dd if=/path/to/systemrescue-x.y.z.iso of=/dev/sdx status=progress 
  ```
- Partition GPT+UEFI
  ```
  /dev/sda1 /efi       vfat   1GB   ESP (ESP-1GB MSR-16MB WIN WRE-1GB)
  /dev/sda2 /msr       vfat  16MB   MSR
  /dev/sda3 /win       ntfs   1TB   WIN
  /dev/sda4 /wre       ntfs   1GB   WRE
  
  /dev/sda5            swap  2xRAM  swap
  /dev/sda6 /guix      f2fs  v64GB  guix
  /dev/sda7 /ubnt      f2fs  v64GB  ubnt
  /dev/sda8 /arch      f2fs  v64GB  arch
  /dev/sda0 /root      f2fs  v64GB  root
  /dev/sdaA /home      f2fs    1TB  users + guix
  ```
- Create filesystem
- Mount root partition
- Install deboostrap
- Run debootstrap
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
