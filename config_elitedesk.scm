;; -*- mode: scheme; -*-
;; This is an operating system configuration template
;; for a "desktop" setup without full-blown desktop
;; environments.

(use-modules (gnu) #;(gnu system nss))
(use-service-modules xorg desktop networking ssh)
(use-package-modules bootloaders tmux vim suckless wm xorg xdisorg glib chromium)

(operating-system
  (host-name "kajita")
  (timezone "America/Chicago")
  (locale "en_US.utf8")

  ;; Use the UEFI variant of GRUB with the EFI System
  ;; Partition mounted on /boot/efi.
  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/boot/efi"))))

  ;; Assume the target root file system is labelled "my-root",
  ;; and the EFI System Partition has UUID 1234-ABCD.
  (file-systems (append
                 (list (file-system
                         (device (file-system-label "root"))
                         (mount-point "/")
                         (type "f2fs"))
                       (file-system
                         (device (file-system-label "home"))
                         (mount-point "/home")
                         (type "f2fs"))
                       (file-system
                         (device (file-system-label "gnu"))
                         (mount-point "/gnu")
                         (type "f2fs"))
                       (file-system
                         (device (file-system-label "efi"))
                         (mount-point "/boot/efi")
                         (type "vfat")))
                 %base-file-systems))

  (users (cons (user-account
                (name "kjetil")
                (comment "me")
                (group "users")
                (supplementary-groups '("wheel" "audio" "video" "input")))
               %base-user-accounts))

  ;; Add a bunch of window managers; we can choose one at
  ;; the log-in screen with F1.
  (packages (append (list
                     ;; window managers
                     ;ratpoison
		     sx dbus
		     ungoogled-chromium
		     ;font-terminus
		     i3-wm i3status dmenu
                     ;emacs emacs-exwm emacs-desktop-environment
                     ;; terminal emulator
                     tmux rxvt-unicode xterm
		     vim )
                    %base-packages))

  ;; Use the "desktop" services, which include the X11
  ;; log-in service, networking with NetworkManager, and more.
  (services (append (list
      (service dhcp-client-service-type)
      (service xorg-server-service-type)
      (service openssh-service-type)
      (service elogind-service-type)
      )
      ;(service console-font-service-type `(("tty2" . ,(file-append font-terminus "/share/consolefonts/ter-132n")))))
      %base-services))

  ;; Allow resolution of '.local' host names with mDNS.
  ;(name-service-switch %mdns-host-lookup-nss)
)
