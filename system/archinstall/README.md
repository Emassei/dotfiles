# New laptop, day of

1. Boot the Arch ISO USB (wired ethernet plugged in — no wifi driver dance).
2. `pacman -Sy --noconfirm git && git clone https://github.com/Emassei/dotfiles /root/dotfiles`
3. `python /root/dotfiles/system/archinstall/install.py --dry-run`  — read the plan.
4. Plug in the YubiKey. `python /root/dotfiles/system/archinstall/install.py`
   - checkpoint: type the target disk path to confirm the wipe
   - checkpoint: LUKS passphrase (KeePass), user password
   - checkpoint: touch the key when it blinks (FIDO2 enrollment)
5. `reboot`. Unlock with the key (or passphrase). Log in as ernie.
   (zsh will offer its new-user config wizard — press `q`; deploy sets up the real config.)
6. `git clone https://github.com/Emassei/dotfiles ~/dotfiles && ~/dotfiles/ripcord`
   - checkpoint: approve `tailscale up` on the phone
   - checkpoint: vault password (KeePass) for the home-directory restore
7. `startx` → your dwm. Done.

Rehearse the whole thing in a VM first (`ripcord` and `install.py` both run there).
Swap is zram (archinstall's default); no swap LV. /boot is an unencrypted ESP —
archinstall doesn't do GRUB-cryptodisk, and it's the standard layout anyway.
