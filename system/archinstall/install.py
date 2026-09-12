#!/usr/bin/env python3
"""
install.py — Arch base install for Ernie's laptops, driven through archinstall
as a LIBRARY (no JSON config to drift, no interactive menus).

From the Arch ISO (wired ethernet plugged in):
    pacman -Sy --noconfirm git
    git clone https://github.com/Emassei/dotfiles /root/dotfiles
    python /root/dotfiles/system/archinstall/install.py --dry-run   # show the plan, touch nothing
    python /root/dotfiles/system/archinstall/install.py             # install

Layout (the t490's, minus /boot-inside-LUKS which archinstall can't do):
    p1  1 GiB   fat32  /boot  (ESP)
    p2  rest    LUKS2 -> LVM "vg": root 60 GiB, home = rest.  Swap = zram.
Encryption: LUKS passphrase (typed here) + FIDO2 enrolled NOW if a YubiKey is
plugged in -> sd-encrypt hooks, disk unlocks with the key from the first boot.
Then GRUB, NetworkManager, sshd, user ernie (wheel, zsh). Everything else is
`ripcord` after the first boot.

Human checkpoints, on purpose: confirm the target disk, type the passphrase,
touch the key.
"""
import argparse
import getpass
import sys
from pathlib import Path

from archinstall.lib.disk.device_handler import device_handler
from archinstall.lib.disk.fido import Fido2
from archinstall.lib.disk.filesystem import FilesystemHandler
from archinstall.lib.installer import Installer
from archinstall.lib.models.bootloader import Bootloader
from archinstall.lib.models.device import (
    DeviceModification, DiskEncryption, DiskLayoutConfiguration, DiskLayoutType,
    EncryptionType, FilesystemType, LvmConfiguration, LvmLayoutType, LvmVolume,
    LvmVolumeGroup, ModificationStatus, PartitionFlag, PartitionModification,
    PartitionType, Size, Unit,
)
from archinstall.lib.models.locale import LocaleConfiguration
from archinstall.lib.models.users import Password, User

USERNAME = "ernie"
HOSTNAME_DEFAULT = "p14s"
TIMEZONE = "America/Bogota"
ROOT_GIB = 60
EXTRA_PKGS = ["base-devel", "git", "zsh", "networkmanager", "openssh", "vim", "libfido2", "restic", "tailscale"]
SERVICES = ["NetworkManager", "sshd"]


def gib(size: Size) -> float:
    """Best-effort bytes->GiB for display (Size is value*unit, or sectors)."""
    u = size.unit.value
    b = size.value * (u if isinstance(u, int) else size.sector_size.value)
    return b / 1024**3


def pick_disk(preselect: str | None):
    devs = [d for d in device_handler.devices
            if not str(d.device_info.path).startswith(("/dev/loop", "/dev/sr", "/dev/zram", "/dev/mapper"))]
    print("Disks:")
    for d in devs:
        print(f"  {d.device_info.path}  {gib(d.device_info.total_size):7.1f} GiB")
    if preselect:
        chosen = next((d for d in devs if str(d.device_info.path) == preselect), None)
    else:
        big = max(devs, key=lambda d: gib(d.device_info.total_size))
        print(f"\n>>> TARGET = {big.device_info.path}  — EVERYTHING ON IT WILL BE ERASED.")
        typed = input(f">>> type the device path to confirm ({big.device_info.path}): ").strip()
        chosen = next((d for d in devs if str(d.device_info.path) == typed), None)
    if not chosen:
        sys.exit("no such disk — aborting, nothing touched")
    return chosen


def build_layout(device, luks_pw: str | None, hsm):
    sec = device.device_info.sector_size
    mod = DeviceModification(device, wipe=True)
    boot = PartitionModification(
        status=ModificationStatus.CREATE, type=PartitionType.PRIMARY,
        start=Size(1, Unit.MiB, sec), length=Size(1, Unit.GiB, sec),
        mountpoint=Path("/boot"), fs_type=FilesystemType("fat32"), flags=[PartitionFlag.BOOT],
    )
    pv_start = boot.start + boot.length
    pv_len = device.device_info.total_size - pv_start - Size(1, Unit.MiB, sec)
    pv = PartitionModification(  # the LUKS container; LVM PV lives inside it
        status=ModificationStatus.CREATE, type=PartitionType.PRIMARY,
        start=pv_start, length=pv_len, mountpoint=None, fs_type=FilesystemType("ext4"),
    )
    mod.add_partition(boot)
    mod.add_partition(pv)

    vg = LvmVolumeGroup("vg", pvs=[pv])
    root = LvmVolume(status=ModificationStatus.CREATE, name="root", fs_type=FilesystemType("ext4"),
                     length=Size(ROOT_GIB, Unit.GiB, sec), mountpoint=Path("/"))
    home_len = pv_len - root.length - Size(512, Unit.MiB, sec)  # LUKS header + LVM metadata margin
    home = LvmVolume(status=ModificationStatus.CREATE, name="home", fs_type=FilesystemType("ext4"),
                     length=home_len, mountpoint=Path("/home"))
    vg.volumes.extend([root, home])

    cfg = DiskLayoutConfiguration(
        config_type=DiskLayoutType.Default, device_modifications=[mod],
        lvm_config=LvmConfiguration(LvmLayoutType.Default, [vg]),
    )
    cfg.disk_encryption = DiskEncryption(
        encryption_type=EncryptionType.LVM_ON_LUKS,
        encryption_password=Password(plaintext=luks_pw) if luks_pw else None,
        partitions=[pv], hsm_device=hsm,
    )
    return cfg


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true", help="build + print the plan, touch nothing")
    ap.add_argument("--disk", help="target device path (skips the confirm prompt)")
    ap.add_argument("--hostname", default=HOSTNAME_DEFAULT)
    args = ap.parse_args()

    device = pick_disk(args.disk)
    keys = Fido2.get_fido2_devices()
    hsm = keys[0] if keys else None
    print(f"YubiKey: {hsm.path if hsm else 'NOT plugged in (enroll later with system/luks-fido2/enroll-luks-yubikey)'}")

    if args.dry_run:
        cfg = build_layout(device, None, hsm)
        import json
        print(json.dumps(cfg.json(), indent=2))
        print("\n(dry run — nothing touched)")
        return

    luks_pw = getpass.getpass("LUKS passphrase (the fallback if the key is lost — put it in KeePass): ")
    if luks_pw != getpass.getpass("again: "):
        sys.exit("passphrases differ")
    user_pw = getpass.getpass(f"password for user {USERNAME}: ")
    cfg = build_layout(device, luks_pw, hsm)

    FilesystemHandler(cfg).perform_filesystem_operations()  # partitions, luksFormat (+fido2 enroll), pv/vg/lv, mkfs
    with Installer(Path("/mnt"), cfg, kernels=["linux"]) as inst:
        inst.mount_ordered_layout()
        inst.sanity_check(False, False, False)
        inst.generate_key_files()
        inst.minimal_installation(hostname=args.hostname,
                                  locale_config=LocaleConfiguration(kb_layout="us", sys_lang="en_US", sys_enc="UTF-8"))
        inst.setup_swap()  # zram, ZSTD default
        inst.add_bootloader(Bootloader.Grub)
        inst.add_additional_packages(EXTRA_PKGS)
        user = User(USERNAME, Password(plaintext=user_pw), True)
        inst.create_users([user])
        inst.set_user_password(User("root", Password(plaintext=user_pw), False))
        inst.arch_chroot(f"chsh -s /usr/bin/zsh {USERNAME}")
        inst.set_timezone(TIMEZONE)
        inst.activate_time_synchronization()
        inst.enable_service(SERVICES)
        inst.genfstab()
    print("\nBase install done. Reboot, unlock (key or passphrase), log in as ernie, then:")
    print("  git clone https://github.com/Emassei/dotfiles ~/dotfiles && ~/dotfiles/ripcord")


if __name__ == "__main__":
    main()
