# Disk encryption: LUKS2 unlocked by YubiKey (FIDO2)

How the t490 boots (captured 2026-09-11 from the live machine). Reproduce this on
any new Arch install AFTER the base install — archinstall sets up LUKS with a
passphrase; the YubiKey is enrolled as an additional keyslot afterwards.

## Layout
    nvme0n1p1   1M     BIOS boot (GRUB)
    nvme0n1p2   550M   vfat  /efi
    nvme0n1p3   rest   LUKS2 (aes-xts-plain64) -> LVM "vg": swap 30G, root 50G, home rest
    bootloader  GRUB

## The three pieces that make the key work
1. **mkinitcpio hooks — systemd-based, NOT the udev/encrypt ones:**
       HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt lvm2 filesystems fsck)
   `sd-encrypt` pulls in systemd-cryptsetup + the fido2 token plugin
   (usr/lib/cryptsetup/libcryptsetup-token-systemd-fido2.so, libcbor).
2. **Kernel cmdline (GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub):**
       rd.luks.name=<LUKS-UUID>=cryptlvm rd.luks.options=<LUKS-UUID>=fido2-device=auto root=/dev/vg/root
   Get the UUID with `cryptsetup luksUUID /dev/nvme0n1p3`. Then `grub-mkconfig -o /boot/grub/grub.cfg`.
3. **Enrollment** — see `enroll-luks-yubikey` next to this file. Keeps the passphrase
   slot as fallback; the key becomes an extra keyslot with a `systemd-fido2` token.

## At boot
Plug the YubiKey in, touch it when it blinks. Without the key, press Enter on the
prompt and type the LUKS passphrase (fallback slot). KEEP THAT PASSPHRASE IN KEEPASS.

## Packages involved
libfido2 (required), yubikey-manager, pcsclite + ccid (for OATH/PIV, not needed for LUKS).
