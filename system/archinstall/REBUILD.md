# Rebuilding my machine from nothing

How a blank laptop becomes *my* laptop — Arch, LUKS+YubiKey, LVM, dwm, every config,
every package, my home directory back from the vault — in about an hour, with four
human checkpoints. Everything here was executed end to end in a VM on 2026-09-12
(`rehearse.sh`), not just written.

```
  Arch ISO USB
      │
      ▼
  install.py ──── partitions, LUKS2 (+YubiKey), LVM, base Arch, GRUB, user ──▶ reboot
      │                                                                          │
      │                                                                          ▼
      │                                                            log in as ernie
      │                                                                          │
      ▼                                                                          ▼
  (rehearse.sh runs all of this in a VM first)                              ripcord
                                                                                 │
                     ┌───────────────────────────────────────────────────────────┤
                     ▼                      ▼                      ▼             ▼
               tailscale up        restore ~ from vault         deploy      YubiKey check
             (approve on phone)   (.ssh, configs, agent      (packages,    (enroll + fix
                                   history; bulk in bg)      dwm build,    boot if needed)
                                                              links, units)
                                                                                 │
                                                                                 ▼
                                                                              startx
```

## The pieces

### 1. `install.py` — the base install (runs from the Arch ISO)
Drives `archinstall` as a Python library — no JSON config that can drift. Builds the
disk layout with archinstall's own classes, then runs the same sequence its guided
installer does.

What it produces on the target disk:
| Partition | Size | Purpose |
|---|---|---|
| p1 | 1 GiB, fat32, flags BOOT+ESP | `/boot` — unencrypted (GRUB needs it; archinstall can't do cryptodisk) |
| p2 | rest, LUKS2 | container for LVM |
| └ vg/root | 60 GiB (35% of small disks) | `/` ext4 |
| └ vg/home | remainder | `/home` ext4 |
Swap is **zram** (archinstall's default), no swap LV.

Encryption: LUKS2 with the passphrase you type. **If a YubiKey is plugged in**, it is
enrolled as a FIDO2 keyslot *during* install and the initramfs gets the systemd hooks
(`sd-encrypt`) so the disk unlocks with the key from the first boot. Without a key the
script refuses to run (pass `--no-yubikey` to install passphrase-only; `ripcord` can
enroll + convert later).

Then: base system, GRUB (UEFI), NetworkManager, sshd, timezone America/Bogota,
en_US.UTF-8, user `ernie` in wheel with zsh, `base-devel git vim libfido2 restic tailscale`.

Human checkpoints: **confirm the target disk** (typed), **LUKS passphrase**, **user
password**, **touch the key**.

`--dry-run` prints the exact plan and touches nothing.

### 2. `ripcord` — from "fresh Arch with my user" to "my machine" (repo root)
Run once as ernie after the first boot. Idempotent. Four steps:

1. **tailscale** — `sudo tailscale up`, approve on the phone. Needed because the vault
   only answers on the tailnet.
2. **restore from the vault** (restic, `rest:http://100.93.44.40:8000/t490`). Prompts
   for the vault password (KeePass) once, stores it in `~/.config/restic/password`.
   Restores the **essentials first** — `.ssh`, `.config/zsh` (incl. the private
   `.zshrc.work`), `.config/restic`, `.claude`, `.codex` — so deploy can reach GitHub
   and the shell is mine. The **bulk** of `~` (code, media…) restores in the background
   (`~/ripcord-restore.log`); hours over the Pi's link.
3. **deploy --yes** — see below.
4. **YubiKey** — if the key is enrolled: makes sure GRUB's cmdline actually asks for it
   (`rd.luks.options=<uuid>=fido2-device=auto`). If not enrolled and a key is plugged
   in: enrolls it, converts the initramfs hooks udev/encrypt → systemd/sd-encrypt and
   the cmdline `cryptdevice=` → `rd.luks.*`, rebuilds initramfs + grub.cfg.

### 3. `deploy --yes` — the machine's configuration (repo root)
The same script that has always configured my Arch boxes, now installing from
generated lists and safe to run unattended:
- packages from `pkglist.txt` (~137 repo) and `aurlist.txt` (18 AUR, via paru built
  from source; `MAKEFLAGS=-j$(nproc)` so AUR builds use every core; a broken AUR
  package is reported, not fatal)
- **dwm / dmenu / dwmblocks compiled from my GitHub forks** (`~/code/suckless`)
- configs linked into place: herdr, nvim (vendored), alacritty, dunst, zathura,
  greenclip, fontconfig, autorandr profiles, restic excludes, Xresources, xbindkeys;
  `.zshrc` / `.zprofile` / `tmux.conf` are *wrappers* that source the repo (local
  secrets/work lines survive re-runs); flameshot is seeded once (it rewrites its ini)
- user systemd units (restic backup timer, rclone mounts, phone mount)
- herdr (release binary from herdr.dev) + `/usr/local/bin/herdr` symlink
- Google Cloud SDK, system files (NetworkManager dispatcher, pacman-stage, acpi lid
  hook), services + timers (`pcscd.socket` for the YubiKey, reflector, fstrim…)

### 4. `rehearse.sh` — run the whole thing in a VM first
`rehearse.sh <archlinux.iso> [install|boot|ripcord|ripcord-only|all|kill]`
QEMU/KVM + OVMF (UEFI), emulated NVMe, 120G sparse disk in `~/vm/rehearsal`. Boots
the ISO with a serial console, drops an ssh key in, copies the **working tree** (so
uncommitted changes are what gets tested), runs `install.py`, reboots from disk, types
the passphrase (serial, or QEMU-monitor keystrokes), runs `ripcord` with rehearsal
flags (skip tailscale, essentials-only restore), then prints checks. All VM passwords
are `rehearse`. A QEMU window opens on the desktop — log in there and `startx` for the
visual check. `rehearse.sh <iso> kill` stops the VM.

## What the rehearsal proved (2026-09-12)
- install.py end to end, twice; boot + unlock; vault reachable; essentials restore
  (795 MiB / 10.6k files, 22 s); GitHub ssh via restored keys; deploy complete; dwm
  built; links; units; herdr. Ten-plus real bugs found and fixed by running it.
- Not exercised in the VM: `startx` visually (human), YubiKey enrollment (VM has no
  key — real day uses the native path), the bulk restore (same command, bigger),
  tailscale join (skipped on purpose).

## Day of (the short version — see README.md)
USB in → `git clone` → `install.py --dry-run` → key in → `install.py` → confirm disk,
passphrase, touch key → reboot → log in (zsh wizard: `q`) → `git clone` →
`ripcord` → approve tailscale, vault password → `startx`.

## Secrets: what lives where
Nothing secret is in this repo. The LUKS passphrase, the vault password, and the ssh
keys come from KeePass / the vault at install time. `.zshrc.work` (company aliases)
and `.zshrc.secrets` are restored from the vault, never committed.
