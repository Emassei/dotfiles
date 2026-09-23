# Offsite copy of the vault — S3 (personal AWS account), set up 2026-09-22

Bucket `massei-vault-offsite` (us-east-1): private, versioned, AES256, lifecycle
moves each repo's `data/` to Glacier Instant Retrieval; old versions expire 90d.
IAM user `vault-offsite`: list/get/put only — a compromised vault box cannot
delete the offsite copy. Cleanup (canaries, orphan packs after a prune) is done
from the laptop with the `personal` profile (`awsp personal`).

On the vault box (Pi today, T420 after the cascade):
- `/etc/rclone-offsite.conf` + `/etc/restic-offsite.env` (root 0600, the key)
- `vault-offsite-sync.timer` 04:30 Bogotá: `rclone copy /srv/data/vault → s3://…/vault`
  (copy-only, `--size-only`, locks/ excluded, log /var/log/vault-offsite-sync.log,
  stamp /var/lib/vault-offsite/last-success)
- `vault-offsite-check.timer` Sun 06:00 Bogotá: `restic check --read-data-subset=2%`
  of the rescued repo copy (only repo whose password lives on the vault box)

Install on a new vault box:
    sudo install -m600 rclone-offsite.conf /etc/rclone-offsite.conf   # real one, from KeePass
    sudo install -m644 vault-offsite-*.{service,timer} /etc/systemd/system/
    sudo mkdir -p /var/lib/vault-offsite && sudo systemctl daemon-reload
    sudo systemctl enable --now vault-offsite-sync.timer vault-offsite-check.timer

Restore from S3 (any box, needs the repo password + an S3 key):
    AWS_ACCESS_KEY_ID=… AWS_SECRET_ACCESS_KEY=… \
    restic -r s3:s3.us-east-1.amazonaws.com/massei-vault-offsite/vault/t490 restore latest --target /mnt/restore
Cost: ~$14/yr at ~200G. Full restore egress ≈ $0.09/GB.
Setup scripts (one-shot, run by Ernie): ~/aws-offsite-setup.sh, ~/aws-offsite-prune-old-key.sh

break-glass.template.sh: fill @AK@/@SK@/@PW@ and attach to KeePass as break-glass-restore.sh (never commit the filled one).
