#!/bin/bash

# HyprV4 By SolDoesTech - https://www.youtube.com/@SolDoesTech
# License..? - You may copy, edit and distribute this script any way you like, enjoy! :)

# The following will attempt to install all needed packages to run Hyprland
# This is a quick and dirty script there are some error checking
# IMPORTANT - This script is meant to run on a clean fresh Arch install on physical hardware

# Define the software that would be inbstalled
#Need some prep work
prep_stage=(
  qt5-wayland
  qt5ct
  qt6-wayland
  qt6ct
  qt5-svg
  qt5-quickcontrols2
  qt5-graphicaleffects
  gtk3
  polkit-gnome
  pipewire
  wireplumber
  jq
  wl-clipboard
  cliphist
  python-requests
  pacman-contrib
)

#software for nvidia GPU only
nvidia_stage=(
  linux-headers
  nvidia-dkms
  nvidia-settings
  libva
  libva-nvidia-driver-git
)

#the main packages
install_stage=(
  alacritty
  betterbird-bin
  bitwarden
  bitwarden-cli
  blueman
  bluez
  bluez-utils
  brave-bin
  brightnessctl
  btop
  curl
  curlie
  file-roller
  firefox
  fuzzel
  grim
  gvfs
  htop
  httpie
  hyprlang
  hyprlock
  hyprpaper
  hyprpicker-git
  hyprshot
  keyd
  kitty
  lxappearance
  mpv
  neovide
  neovim
  network-manager-applet
  noto-fonts-emoji
  nwg-look-bin
  pamixer
  papirus-icon-theme
  pavucontrol
  pfetch
  rofi-wayland
  sddm
  slurp
  starship
  stow
  swappy
  swaync
  swww
  thunar
  thunar-archive-plugin
  ttf-jetbrains-mono-nerd
  waybar
  wlogout
  xdg-desktop-portal-hyprland
  xfce4-settings
  xorg-xhost
  yazi
)

development=(
  air-bin
  docker
  docker-compose
  esbuild
  github-cli
  glab
  go
  lazydocker
  lazygit
  nodejs-lts-iron
  npm
  pgcli
  pnpm
  rustup
)

utils=(
  eza
  bat
  fd
  fzf
  zoxide
  dust
  ripgrep
  git-delta
  tmux
  gum
  spotify-launcher
  webcord
  acpi
  timeshift
  timeshift-autosnap
  otf-monaspace-nerd
  smartmontools
  stacer
  powertop
  xdg-user-dirs
  xdg-ninja
)

# set some colors
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
CAT="[\e[1;37mATTENTION\e[0m]"
CWR="[\e[1;35mWARNING\e[0m]"
CAC="[\e[1;33mACTION\e[0m]"
INSTLOG="install.log"

######
# functions go here

# function that would show a progress bar to the user
show_progress() {
  while ps | grep $1 &>/dev/null; do
    echo -n "."
    sleep 2
  done
  echo -en "Done!\n"
  sleep 2
}

# function that will test for a package and if not found it will attempt to install it
install_software() {
  # First lets see if the package is there
  if paru -Q $1 &>>/dev/null; then
    echo -e "$COK - $1 is already installed."
  else
    # no package found so installing
    echo -en "$CNT - Now installing $1 ."
    paru -S --noconfirm $1 &>>$INSTLOG &
    show_progress $!
    # test to make sure package installed
    if paru -Q $1 &>>/dev/null; then
      echo -e "\e[1A\e[K$COK - $1 was installed."
    else
      # if this is hit then a package is missing, exit to review log
      echo -e "\e[1A\e[K$CER - $1 install had failed, please check the install.log"
      exit
    fi
  fi
}

# clear the screen
clear

# set some expectations for the user
echo -e "$CNT - You are about to execute a script that would attempt to setup Hyprland.
Please note that Hyprland is still in Beta."
sleep 1

# attempt to discover if this is a VM or not
echo -e "$CNT - Checking for Physical or VM..."
ISVM=$(hostnamectl | grep Chassis)
echo -e "Using $ISVM"
if [[ $ISVM == *"vm"* ]]; then
  echo -e "$CWR - Please note that VMs are not fully supported and if you try to run this on
    a Virtual Machine there is a high chance this will fail."
  sleep 1
fi

# let the user know that we will use sudo
echo -e "$CNT - This script will run some commands that require sudo. You will be prompted to enter your password.
If you are worried about entering your password then you may want to review the content of the script."
sleep 1

# give the user an option to exit out
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to continue with the install (y,n) ' CONTINST
if [[ $CONTINST == "Y" || $CONTINST == "y" ]]; then
  echo -e "$CNT - Setup starting..."
  sudo touch /tmp/hyprv.tmp
else
  echo -e "$CNT - This script will now exit, no changes were made to your system."
  exit
fi

# find the Nvidia GPU
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
  ISNVIDIA=true
else
  ISNVIDIA=false
fi

### Disable wifi powersave mode ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to disable WiFi powersave? (y,n) ' WIFI
if [[ $WIFI == "Y" || $WIFI == "y" ]]; then
  LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
  echo -e "$CNT - The following file has been created $LOC.\n"
  echo -e "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC &>>$INSTLOG
  echo -en "$CNT - Restarting NetworkManager service, Please wait."
  sleep 2
  sudo systemctl restart NetworkManager &>>$INSTLOG

  #wait for services to restore (looking at you DNS)
  for i in {1..6}; do
    echo -n "."
    sleep 1
  done
  echo -en "Done!\n"
  sleep 2
  echo -e "\e[1A\e[K$COK - NetworkManager restart completed."
fi

#### Check for package manager ####
if [ ! -f /sbin/paru ]; then
  echo -en "$CNT - Configuring paru."
  git clone https://aur.archlinux.org/paru.git &>>$INSTLOG
  cd paru
  makepkg -si --noconfirm &>>../$INSTLOG &
  show_progress $!
  if [ -f /sbin/paru ]; then
    echo -e "\e[1A\e[K$COK - paru configured"
    cd ..

    # update the paru database
    echo -en "$CNT - Updating paru."
    paru -Suy --noconfirm &>>$INSTLOG &
    show_progress $!
    echo -e "\e[1A\e[K$COK - paru updated."
  else
    # if this is hit then a package is missing, exit to review log
    echo -e "\e[1A\e[K$CER - paru install failed, please check the install.log"
    exit
  fi
fi

### Install all of the above packages ####
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install the packages? (y,n) ' INST
if [[ $INST == "Y" || $INST == "y" ]]; then

  # Prep Stage - Bunch of needed items
  echo -e "$CNT - Prep Stage - Installing needed components, this may take a while..."
  for SOFTWR in ${prep_stage[@]}; do
    install_software "$SOFTWR"
  done

  # Setup Nvidia if it was found
  if [[ "$ISNVIDIA" == true ]]; then
    echo -e "$CNT - Nvidia GPU support setup stage, this may take a while..."
    for SOFTWR in ${nvidia_stage[@]}; do
      install_software "$SOFTWR"
    done

    # update config
    sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
    echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf &>>$INSTLOG
  fi

  # Install the correct hyprland version
  echo -e "$CNT - Installing Hyprland, this may take a while..."
  install_software hyprland

  # Stage 1 - main components
  echo -e "$CNT - Installing main components, this may take a while..."
  for SOFTWR in ${install_stage[@]}; do
    install_software "$SOFTWR"
  done

  echo -e "$CNT - Installing utilities..."
  for SOFTWR in ${utils[@]}; do
    install_software "$SOFTWR"
  done

  echo -e "$CNT - Installing development specefic packages..."
  for SOFTWR in ${development[@]}; do
    install_software "$SOFTWR"
  done

  # Start the bluetooth service
  echo -e "$CNT - Starting the Bluetooth Service..."
  sudo systemctl enable --now bluetooth.service &>>$INSTLOG
  sleep 2

  # Enable the sddm login manager service
  echo -e "$CNT - Enabling the SDDM Service..."
  sudo systemctl enable sddm &>>$INSTLOG
  sleep 2

  # Clean out other portals
  echo -e "$CNT - Cleaning out conflicting xdg portals..."
  paru -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk &>>$INSTLOG
fi

### Config Files ###
git clone https://github.com/Mhirii/dotfiles "$HOME/dotfiles"
cd "$HOME/dotfiles" || exit
stow .
git clone https://github.com/Mhirii/hyprland "$HOME/.config/hypr"
git clone https://github.com/Mhirii/tmux "$HOME/.config/tmux"
git clone https://github.com/Mhirii/lazyvim "$HOME/.config/nvim"

### Install the starship shell ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to activate the starship shell? (y,n) ' STAR
if [[ $STAR == "Y" || $STAR == "y" ]]; then
  # install the starship shell
  echo -e "$CNT - Hansen Crusher, Engage!"
  echo -e "$CNT - Updating .bashrc..."
  echo -e '\neval "$(starship init bash)"' >>~/.bashrc
  echo -e "$CNT - copying starship config file to ~/.config ..."
  cp Extras/starship.toml ~/.config/
fi

### Script is done ###
echo -e "$CNT - Script had completed!"
if [[ "$ISNVIDIA" == true ]]; then
  echo -e "$CAT - Since we attempted to setup an Nvidia GPU the script will now end and you should reboot.
    Please type 'reboot' at the prompt and hit Enter when ready."
  exit
fi

read -rep $'[\e[1;33mACTION\e[0m] - Would you like to start Hyprland now? (y,n) ' HYP
if [[ $HYP == "Y" || $HYP == "y" ]]; then
  exec sudo systemctl start sddm &>>$INSTLOG
else
  exit
fi
