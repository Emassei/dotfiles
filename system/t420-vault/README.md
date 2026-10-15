# T420 vault migration (Pi retirement)

Staged, NOT installed. Moves pivault's duties to the t420.

## Facts established 2026-10-14

- Pi drive `sda` = 931.5G ext4, **not encrypted**, UUID
  `aade82f4-e642-4188-8263-c832606fe903`, mounted `/srv/data`.
- 596G used / 916G (69%).
- Vault sub-repos: `rescued`, `t420-immich`, `t490`.
- T420 `sda` is 465.8G, fully partitioned, **no free space and no spare bay**
  -> the 1TB attaches as an external USB disk, exactly as on the Pi.
- Pi's `/usr/local/bin/rest-server` is **ARM aarch64** -> cannot be copied.
  Install an x86_64 build on the t420.

## Prerequisites on the t420 (all currently ABSENT)

- `rclone`
- `rest-server` (x86_64; AUR `rest-server` or upstream release)
- system user `restserver`
- `/var/lib/vault-offsite/` (ExecStartPost writes `last-success` there)

## Secrets — copy by hand, deliberately. Not staged here.

- `/etc/rclone-offsite.conf`        (root:root 0600) S3 creds for rclone
- `/etc/restic-offsite.env`         (root:root 0600) AWS_* for restic check
- `~/.config/restic/password-rescued`            repo password

## Mounts that break the moment the drive leaves the Pi

These four t420 fstab lines point at pivault (100.93.44.40) and must be
replaced in the same change — see fstab.t420.patch:

    ernie@100.93.44.40:/srv/data/rescued /mnt/pivault-rescued fuse.sshfs ...
    100.93.44.40:/srv/data/movies    /srv/media/movies  nfs4 ...
    100.93.44.40:/srv/data/tv_shows  /srv/media/tv      nfs4 ...

After the move the media is local: bind-mount or point Jellyfin straight at
/srv/data/{movies,tv_shows}. The NFS export on the Pi then has no clients.

## Open decision (do not implement silently)

`t420-immich` backs the t420 up. After the move that repo lives on a disk
attached to the machine it is protecting — one failure or compromise loses
both. Either keep that repo elsewhere or accept the reduced protection.

## Order of operations

1. Install prereqs + create user + copy secrets (above).
2. Stop/disable the Pi's timers so nothing writes mid-move.
3. Move the drive. Add the fstab entry by UUID.
4. Install these units, `daemon-reload`, enable.
5. Repoint the t490 backup at the t420's rest-server.
6. **Prove a restore from the t420.**
7. Only then retire the Pi — powered down, intact, not wiped (rollback).
