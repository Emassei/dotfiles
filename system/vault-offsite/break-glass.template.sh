#!/bin/bash
# BREAK GLASS — get Ernie's machine back from the OFFSITE S3 copy.
# This file lives as an attachment in KeePass ("break-glass-restore.sh").
# It CONTAINS SECRETS: the S3 key and the vault password. Shred it after use.
#
# Scenario: laptop AND the Pi vault are gone. You have: any x86 machine,
# the Arch ISO, this file (from KeePass on your phone / gdrive).
#
#   1. Install Arch: boot the ISO, clone the repo, run
#        python system/archinstall/install.py        (see system/archinstall/REBUILD.md)
#      (or any plain Arch install with a user "ernie" + sudo)
#   2. Log in as ernie, copy this file over, then:
#        bash break-glass-restore.sh
#      It clones dotfiles and runs `ripcord --from-s3`: essentials first
#      (ssh, shell, restic, agent history), bulk home in the background,
#      then deploy builds the machine. ~200G pull ≈ $18 egress, a few hours.
#
# If ripcord itself is broken, do it by hand with the same secrets:
#   export AWS_ACCESS_KEY_ID=… AWS_SECRET_ACCESS_KEY=… AWS_DEFAULT_REGION=us-east-1
#   echo -n '<vault password>' > ~/.config/restic/password
#   restic -r s3:s3.us-east-1.amazonaws.com/massei-vault-offsite/vault/t490 \
#          -p ~/.config/restic/password snapshots
#   restic -r s3:s3.us-east-1.amazonaws.com/massei-vault-offsite/vault/t490 \
#          -p ~/.config/restic/password restore latest --target /
# Other repos in the same bucket: vault/t420-immich (Immich library, its own
# password in KeePass) and vault/rescued (family archive, its own password).
# Bucket: massei-vault-offsite, personal AWS account 3120…, region us-east-1.
set -e
export AWS_ACCESS_KEY_ID='@AK@'
export AWS_SECRET_ACCESS_KEY='@SK@'
export AWS_DEFAULT_REGION=us-east-1
export VAULT_PASSWORD='@PW@'

command -v git >/dev/null && command -v restic >/dev/null || sudo pacman -Sy --noconfirm --needed git restic
[ -d ~/dotfiles ] || git clone https://github.com/Emassei/dotfiles ~/dotfiles
exec ~/dotfiles/ripcord --from-s3
