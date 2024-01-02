#!/bin/bash
echo "Enter your desired root user password"
read -s ROOTPWD
echo "Enter your desired username"
read USERNAME
echo "Enter your desired user password"
read -s USER_PWD
echo "Confirm password"
read -s CHECK_PWD
if [[ $password != $password_check ]]; then
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

archinstall --config archinstall.json --creds creds.json

echo "Enter a github username (optional)"
read GH_USERNAME

arch-chroot /mnt/archinstall zsh -c "
cd /home/${USERNAME}
sudo -u ${USERNAME} git clone https://aur.archlinux.org/yay.git
cd yay
sudo -u ${USERNAME} makepkg -si
yay -Sy aur_packages.txt
cd ..
mkdir ohmyzsh
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
cd ohmyzsh
sh install.sh
"

if [[ $GH_USERNAME != "" ]]; then
	arch-chroot /mnt/archinstall bash -c "
	su -u ${USERNAME} chezmoi init --apply --verbose https://github.com/${GH_USERNAME}/dotfiles.git
	"
fi
