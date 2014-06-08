wget 'https://www.archlinux.org/mirrorlist/?country=CN' -O /etc/pacman.d/mirrorlist.backup
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup

rankmirrors /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
rm /etc/pacman.d/mirrorlist.backup

pacstrap -i /mnt base base-devel vim grub gnome git nodejs opencc alsa-utils ttf-dejavu wqy-microhei wqy-zenhei xf86-video-ati dhclient fcitx-im fcitx-sunpinyin os-prober file-roller wget axel gvfs-mtp gvfs-goa goagent fcitx-cloudpinyin openvpn nautilus-sendto gnome-logs gedit

genfstab -U -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash <<ARCH_CHROOT

echo 'en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8' > /etc/locale.gen
echo 'LANG=zh_CN.UTF-8' > /etc/locale.conf
locale-gen

ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc

echo 'zh99998-arch' > /etc/hostname

grub-install --target=i386-pc --recheck /dev/sdb
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable gdm
systemctl enable NetworkManager

useradd -m -G wheel -s /bin/bash -p `openssl passwd zh112998` zh99998

chmod u+w /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
chmod u-w /etc/sudoers

su - zh99998 << SU_USER

echo 'export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"' > ~/.xprofile

curl -O https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz
tar zxvf package-query.tar.gz
cd package-query
makepkg -si --noconfirm
cd ..
curl -O https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz
tar zxvf yaourt.tar.gz
cd yaourt
makepkg -si --noconfirm
cd ..

yaourt -S google-chrome sublime-text-imfix webstorm --noconfirm
SU_USER
ARCH_CHROOT
#umount -R /mnt
#reboot
