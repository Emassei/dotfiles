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

## Away from home (e.g. the P14s arrives in Atlanta)

Bring: the Arch ISO USB (**make it before leaving**), the YubiKey, the t490, the phone
(KeePass + tailscale). No ethernet needed.

- **Network on the ISO:** hotel wifi captive portals don't work from a live ISO — use the
  **phone hotspot**. `iwctl` → `station wlan0 connect <hotspot-ssid>` → `exit`. After the
  install, NetworkManager handles wifi normally (`nmtui`).
- **Restore from the t490, not the vault:** the vault is in Medellín behind a home
  upload link. The t490 next to you has the whole home directory. Both on the hotspot
  (or both on tailscale), then **on the t490**: `utils/handoff <new-machine-ip>` —
  pushes essentials in seconds and the bulk in minutes, no key bootstrap needed
  (the fresh install accepts ernie's password over ssh). Then `ripcord` on the new
  machine sees `~/.ssh` and skips the vault restore automatically.
- The vault stays the fallback: if the t490 isn't available, `ripcord` restores from
  it over tailscale — essentials fast, bulk slow (leave it running, or wait until home).
- `tailscale up` on the new machine still happens (approve on the phone) — it's how
  the fleet sees it.
