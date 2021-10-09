(use-modules (gnu))
(use-service-modules xorg networking)
(use-package-modules wm suckless certs xorg)
(use-modules (nongnu packages virtualbox))

(operating-system
  (kernel linux-vbox)
  (host-name "guix_test")
  (timezone "America/New_York")
  (locale "en_US.utf8")

  ;; Boot in "legacy" BIOS mode, assuming /dev/sdX is the
  ;; target hard disk, and "my-root" is the label of the target
  ;; root file system.
  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (target "/dev/sda")))
  (file-systems (cons (file-system
                        (device (file-system-label "my-root"))
                        (mount-point "/")
                        (type "ext4"))
                      %base-file-systems))

  ;; This is where user accounts are specified.  The "root"
  ;; account is implicit, and is initially created with the
  ;; empty password.
  (users (cons (user-account
                (name "ryan")
                (group "users")
		(home-directory "/home/ryan")

                ;; Adding the account to the "wheel" group
                ;; makes it a sudoer.  Adding it to "audio"
                ;; and "video" allows the user to play sound
                ;; and access the webcam.
                (supplementary-groups '("wheel"
                                        "audio" "video")))
               %base-user-accounts))

  ;; Globally-installed packages.
  (packages (append (list
                     ;; Virtualbox Guest Additions
                     vbox-guest-additions
                     ;; Graphics system
                     xorg-server xf86-video-vmware
                     ;; Window Manager
                     i3-wm i3status dmenu
                     ;; Misc
                     nss-certs st)
                    %base-packages))

  ;; Services
  (services (cons* (service slim-service-type (slim-configuration
                                               (display ":0")
                                               (vt "vt7")))
                   (service network-manager-service-type)
                   (service wpa-supplicant-service-type)
                   ;; Was getting a lot of SSL cert errors because my clock was off
                   (service ntp-service-type)
                            %base-services)))
