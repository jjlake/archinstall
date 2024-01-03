#!/bin/bash
echo "Enter your desired root user password"
read -s ROOT_PWD
echo "Confirm root user password"
read -s CHECK_ROOTPWD

if [[ $ROOT_PWD != $CHECK_ROOTPWD ]]; then
	echo "Root passwords do not match."
	exit 0
fi

echo "Enter your desired username"
read USERNAME

echo "Enter your desired user password"
read -s USER_PWD
echo "Confirm password"
read -s CHECK_PWD
if [[ $USER_PWD != $CHECK_PWD ]]; then
	echo "Passwords do not match."
	exit 0
fi

echo """
{
	\"!root-password\":\"${ROOT_PWD}\",
	\"!users\": [{
		\"username\": \"${USERNAME}\",
		\"!password\": \"${USER_PWD}\",
		\"sudo\": true
	}]
}
""" > creds.json

sudo pacman -Sy archlinux-keyring --noconfirm

archinstall --config archinstall.json --creds creds.json

echo "Enter a github username (optional)"
read GH_USERNAME

arch-chroot /mnt/archinstall zsh -c "
cd /home/${USERNAME}
sudo -u ${USERNAME} git clone https://aur.archlinux.org/yay.git
cd yay
sudo -u ${USERNAME} makepkg -si
cd ..
rm -R yay
git clone https://github.com/${GH_USERNAME}/archinstall.git
yay -Sy --noconfirm - < archinstall/aur_packages.txt
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh > install.sh
sudo -u ${USERNAME} sh install.sh
rm install.sh
sudo -u ${USERNAME} git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
"

if [[ $GH_USERNAME != "" ]]; then
	arch-chroot /mnt/archinstall bash -c "
	sudo -u ${USERNAME} chezmoi init --apply --verbose https://github.com/${GH_USERNAME}/dotfiles.git
	"
fi
