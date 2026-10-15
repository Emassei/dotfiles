# Immich on the t420

Photo server. Lives at /opt/immich on the t420; this is a tracked copy so the
host can be rebuilt without rediscovering it.

- Web/API on port 2283 (not 3001).
- Library data: /home/ernie/immich-data/library
- Rescued photos are bind-mounted read-only at /mnt/rescued.
- Its restic repo is `t420-immich` inside the vault, i.e. on a disk attached to
  the machine it protects. Ernie's call, 2026-10-15: fine, the SSD is new.

## 2026-10-15, the vault migration

That bind mount used to be `/mnt/pivault-rescued` - an sshfs mount of the Pi.
When the vault drive moved to this machine the sshfs mount went away, and
because the container's restart policy is `always` it retry-looped all day
failing with:

    error mounting "/mnt/pivault-rescued" to rootfs at "/mnt/rescued":
    ... no such device

The photos are local now, so the mount is `/srv/data/rescued` instead. If this
container ever fails at startup with "no such device", check that /srv/data is
mounted (the vault drive is USB and fstab carries `nofail`).

env.example has the secrets stripped; the real .env is on the t420 only.
