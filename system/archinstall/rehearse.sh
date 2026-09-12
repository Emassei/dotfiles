#!/bin/bash
# rehearse.sh — run the WHOLE new-laptop procedure in a QEMU VM on the t490:
#   ISO boot -> install.py -> reboot from disk (passphrase over serial) -> ripcord.
# Drives the VM over a serial socket + ssh (port 2222). Opens a VM window too.
#   usage: rehearse.sh <archlinux.iso> [install|boot|ripcord|all]   (default all)
set -e
ISO=$(readlink -f "${1:?path to archlinux iso}"); STAGE=${2:-all}
W=~/vm/rehearsal; mkdir -p $W; cd $W
DISK=$W/disk.qcow2; VARS=$W/OVMF_VARS.fd; CODE=/usr/share/edk2/x64/OVMF_CODE.4m.fd
SER=$W/serial.sock; MON=$W/monitor.sock; LOG=$W/serial.log; PID=$W/qemu.pid; SSH="ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -o LogLevel=ERROR"
PUB=$(cat ~/.ssh/id_ed25519.pub 2>/dev/null || cat ~/.ssh/id_rsa.pub)
say(){ echo -e "\033[1;36m[rehearse]\033[0m $1"; }
send(){ printf '%s\n' "$1" | socat - UNIX-CONNECT:$SER; }
typekeys(){ # type a string into the VM keyboard via the QEMU monitor (works wherever the prompt is drawn)
  local str=$1 c; for ((i=0;i<${#str};i++)); do c=${str:i:1}; case $c in " ") c=spc;; "-") c=minus;; ".") c=dot;; esac; echo "sendkey $c" | socat - UNIX-CONNECT:$MON >/dev/null; sleep 0.08; done; echo "sendkey ret" | socat - UNIX-CONNECT:$MON >/dev/null; }
waitlog(){ local pat=$1 t=${2:-300}; for ((i=0;i<t;i++)); do grep -q "$pat" $LOG 2>/dev/null && return 0; sleep 1; done; echo "timeout waiting for: $pat"; return 1; }
waitssh(){ local u=$1 t=${2:-180}; for ((i=0;i<t;i++)); do $SSH $u@localhost true 2>/dev/null && return 0; sleep 2; done; echo "ssh timeout"; return 1; }
vm_kill(){ [ -f $PID ] && kill "$(cat $PID)" 2>/dev/null || true; sleep 1; rm -f $PID $SER; }
vm_common="-enable-kvm -m 6G -smp 4 -machine q35 -cpu host
  -drive if=pflash,format=raw,readonly=on,file=$CODE -drive if=pflash,format=raw,file=$VARS
  -device nvme,drive=d0,serial=rehearsal -drive if=none,id=d0,file=$DISK,format=qcow2
  -netdev user,id=n0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=n0
  -chardev socket,id=ser,path=$SER,server=on,wait=off,logfile=$LOG -serial chardev:ser
  -monitor unix:$MON,server,nowait
  $([ -n "$DISPLAY" ] && echo "-display gtk" || echo "-display none") -daemonize -pidfile $PID"

if [ "$STAGE" = all ] || [ "$STAGE" = install ]; then
  say "fresh disk + firmware vars"; vm_kill; rm -f $DISK $LOG; qemu-img create -f qcow2 $DISK 120G >/dev/null; cp /usr/share/edk2/x64/OVMF_VARS.4m.fd $VARS
  say "extracting kernel/initrd + boot params from the ISO"; mkdir -p isoboot
  bsdtar -xf "$ISO" -C isoboot arch/boot/x86_64/vmlinuz-linux arch/boot/x86_64/initramfs-linux.img loader/entries/01-archiso-linux.conf
  PARAMS=$(grep -E '^options' isoboot/loader/entries/01-archiso-linux.conf | grep -oE 'archisobasedir=[^ ]+ archisosearchuuid=[^ ]+' | head -1)
  [ -n "$PARAMS" ] || PARAMS="archisobasedir=arch archisolabel=$(blkid -o value -s LABEL "$ISO")"
  say "booting the ISO (serial console)"; eval qemu-system-x86_64 $vm_common -cdrom "$ISO" -kernel isoboot/arch/boot/x86_64/vmlinuz-linux -initrd isoboot/arch/boot/x86_64/initramfs-linux.img -append "'$PARAMS console=ttyS0,115200 console=tty0'"
  waitlog 'archiso login\|root@archiso' 240; sleep 3; send root; sleep 3   # covers both autologin and a login: prompt
  say "dropping ssh key into the live system"; send "mkdir -p /root/.ssh && echo '$PUB' > /root/.ssh/authorized_keys && chmod 700 /root/.ssh && systemctl start sshd && echo SSH-READY"
  waitlog 'SSH-READY' 60; waitssh root 60
  say "copying the working tree (uncommitted changes included)"; tar -C ~ -czf - --exclude=.git dotfiles | $SSH root@localhost 'tar -C /root -xzf -'
  say "installing archinstall on the live system + running install.py"
  $SSH root@localhost "pacman -Sy --noconfirm archinstall >/dev/null 2>&1; INSTALL_LUKS_PW=rehearse INSTALL_USER_PW=rehearse INSTALL_SERIAL_CONSOLE=1 INSTALL_SSH_PUBKEY='$PUB' python /root/dotfiles/system/archinstall/install.py --disk /dev/nvme0n1 --hostname rehearsal --no-yubikey" 2>&1 | tee $W/install.log
  say "install.py finished — powering off the ISO"; $SSH root@localhost 'poweroff' 2>/dev/null || true; sleep 6; vm_kill
fi
if [ "$STAGE" = all ] || [ "$STAGE" = boot ] || [ "$STAGE" = ripcord ]; then  # (ripcord-only skips this)
  say "booting from the installed disk"; rm -f $LOG; eval qemu-system-x86_64 $vm_common
  if waitlog 'assphrase\|nlock' 45; then sleep 2; send "rehearse"
  else say "no LUKS prompt on serial — typing the passphrase via the QEMU monitor"; waitlog 'starting Boot' 60 || true; sleep 15; typekeys rehearse; fi
  waitlog 'rehearsal login' 180 || true; waitssh ernie 120
  say "installed system is up — ssh as ernie works"; $SSH ernie@localhost 'uname -r; lsblk -o NAME,FSTYPE,MOUNTPOINT | grep -E "crypt|vg-"; grep ^HOOKS /etc/mkinitcpio.conf; grep -oE "(rd.luks|cryptdevice)[^ ]*" /proc/cmdline' || true   # informational; never fatal
fi
if [ "$STAGE" = all ] || [ "$STAGE" = ripcord ] || [ "$STAGE" = ripcord-only ]; then
  say "running ripcord (skip tailscale, essentials-only restore)"
  $SSH ernie@localhost "mkdir -p ~/.config/restic && chmod 700 ~/.config/restic"; scp -P 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR ~/.config/restic/password ernie@localhost:.config/restic/password
  say "copying the working tree into the VM (not a git clone — tests uncommitted changes)"; tar -C ~ -czf - dotfiles | $SSH ernie@localhost 'tar -C ~ -xzf -'
  $SSH -t ernie@localhost "RIPCORD_SKIP_TAILSCALE=1 RIPCORD_ESSENTIALS_ONLY=1 RIPCORD_KEEP_KEY='$PUB' ~/dotfiles/ripcord" 2>&1 | tee $W/ripcord.log
  say "ripcord finished. Checks:"; $SSH ernie@localhost 'which dwm dmenu dwmblocks alacritty nvim herdr 2>&1; ls -la ~/.xinitrc ~/.config/herdr/config.toml ~/.config/nvim 2>&1 | cut -c1-100; systemctl --user is-enabled restic-backup.timer'
  say "VM left running — open the window, log in on tty1 as ernie/rehearse, type startx. Kill: rehearse.sh <iso> kill"
fi
[ "$STAGE" = kill ] && vm_kill && say "VM stopped"
