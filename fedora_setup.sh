#!/bin/bash

gnome_settings_sctions() {
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "'Terminal'"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "'Launch1'"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "'gnome-terminal'"
	gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Alt>F1']"
	gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Alt>F2']"
	gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Alt>F3']"
	gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Alt>F4']"
	gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>x']"
	gsettings set org.gnome.desktop.wm.keybindings panel-run-dialog "['<Alt>r']"

	DEF_TERM_PROFILE=`gsettings get org.gnome.Terminal.ProfilesList default`
	DEF_TERM_PROFILE=${DEF_TERM_PROFILE:1:-1}
	echo $DEF_TERM_PROFILE
	gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEF_TERM_PROFILE/ default-size-columns 170
	gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEF_TERM_PROFILE/ default-size-rows 50
	gsettings set org.gnome.desktop.interface menubar-accel ''
	gsettings set org.gnome.desktop.wm.preferences audible-bell false
	gsettings set org.gnome.desktop.wm.preferences button-layout 'menu:minimize,maximize,close'
	#gsettings set org.gnome.shell.overrides dynamic-workspaces false
	gsettings set org.gnome.mutter dynamic-workspaces false
	gsettings set org.gnome.desktop.wm.preferences num-workspaces 4
	echo "Gnome Settings done."
}

git_actions() {
	git config --global credential.helper 'cache --timeout=54000'
}
powerline_actions() {
sudo bash -c 'cat > /etc/bashrc' << EOF
if [ -f `which powerline-daemon` ]; then
  powerline-daemon -q
  POWERLINE_BASH_CONTINUATION=1
  POWERLINE_BASH_SELECT=1
  . /usr/share/powerline/bash/powerline.sh
fi
EOF
mkdir -p ~/.config/powerline
cat <<'EOF' >~/.config/powerline/config.json
{
    "ext": {
        "shell": {
            "theme": "default_leftonly"
        }
    }
}
EOF
powerline-daemon --replace

}


package_actions() {
	sudo dnf -y install fedora-workstation-repositories &&\
	sudo dnf -y config-manager --set-enabled google-chrome &&\
	sudo dnf -y update &&\
	sudo dnf -y install nano git mc powerline google-chrome-stable apfs-fuse autoconf automake wget gnome-tweaks gnome-shell-extension-user-theme.noarch chrome-gnome-shell.x86_64 gnome-shell-extension-system-monitor-applet.noarch &&\
	sudo dnf -y groupinstall "Development Tools" &&\
	sudo dnf -y remove abrt*
	git_actions
	powerline_actions
}

macos_documents() {
	ME=$( whoami )
	sudo apfs-fuse /dev/sdc2 /mnt | true &&\
	sudo rsync -ah --info=progress2 --include=".git" --exclude=".*" --exclude="createRamDisk*" --exclude="WoT*" --exclude="Microsoft*" /mnt/root/Users/joe/Documents/ /home/$ME/Dokumenty &&\
	sudo rsync -ah --info=progress2 --exclude=".*" /mnt/root/Users/joe/Pictures/ /home/$ME/Obrazy &&\
	sudo rsync -ah --info=progress2 --include=Tahoma* --include=SFN* --exclude=* /mnt/root/Library/Fonts/ /mnt/root/System/Library/Fonts/ /home/$ME/.fonts &&\
	sudo rsync -ah --min-size=1 --exclude=".*" /mnt/root/Library/Fonts/Microsoft/ /home/$ME/.fonts &&\
	sudo chown -R $ME. /home/$ME/Dokumenty /home/$ME/.fonts /home/$ME/Obrazy &&\
	sudo umount /mnt
}

usage_action() {
cat << EOF
usage:
	-p --package run system wide package action
	-g --gnome-settings run gnome settings action
	-i --interactive You'll be asked for every step one by one
	-m --macdoc rsync macos documents
	-h --help help
EOF
}

interactive_action() {
	echo "Press any key to package actions..."
	read -t 3 -n 1 && package_actions
	echo "Press any key to Gnome Settings Actions..."
	read -t 3 -n 1 && gnome_settings_actions
}

while [ "$1" != "" ]; do
    case $1 in
        -p | --package )        package_actions
				exit
                                ;;
	-g | --gnome-settings ) gnome-settings_action
                                exit
                                ;;
        -m | --macdoc )    	macos_documents
                                exit
                                ;;
        -i | --interactive ) 	interactive_action
				exit
                                ;;
        -h | --help )           usage_action
                                exit
                                ;;
        * )                     usage_action
                                exit 1
    esac
    shift
done

usage_action


