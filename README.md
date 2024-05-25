# HyprInstall
This is a fork of the V4 of the Hyprland install script made by [SolDoesTech](https://github.com/soldoestech/hyprv4).

It contains a simple install script to streamline the installation of Hyprland on Arch Linux.  
IMPORTANT - This script is meant to run on a clean fresh Arch install on physical hardware  

Note that the dotfiles will be managed by stow, so if you remove it from the dependencies the script will not work unless you modify it accordingly.  
These repositories will be cloned by the script:
- [dotfiles](https://github.com/mhirii/dotfiles)
- [neovim config](https://github.com/mhirii/lazyvim)
- [tmux config](https://github.com/mhirii/tmux)
  
If you're planning to run this script make sure you read it first to understand what it does.  

Feel free to fork and modify the script to your liking.

Note that the packages section will not always be up to date, so manual verification is recommended.  
Packages that will be installed:
prep:
```bash
	qt5-wayland qt5ct qt6-wayland qt6ct qt5-svg qt5-quickcontrols2 qt5-graphicaleffects gtk3 polkit-gnome pipewire wireplumber jq wl-clipboard cliphist python-requests pacman-contrib
```
Nvidia:
```bash
	linux-headers nvidia-dkms nvidia-settings libva libva-nvidia-driver-git
```
main ones:
```bash
	xorg-xhost neovim neovide kitty alacritty hyprlock mako waybar swaync swww swaylock-effects wofi wlogout xdg-desktop-portal-hyprland swappy grim slurp thunar btop floorp thunderbird mpv pamixer pavucontrol brightnessctl bluez bluez-utils blueman network-manager-applet gvfs thunar-archive-plugin file-roller starship papirus-icon-theme ttf-jetbrains-mono-nerd noto-fonts-emoji lxappearance xfce4-settings nwg-look-bin sddm hyprland-git hyprlang hyprprop-git hyprshot hyprlock-git hyprpicker-git xdg-desktop-portal-hyprland-git alacritty keyd swaync waybar mako yazi curl httpie curlie rofi-lbonn-wayland-git fuzzel pfetch bitwarden bitwarden-cli stow eza bat fd fzf zoxide dust ripgrep git-delta tmux gum spotify-launcher webcord acpi timeshift timeshift-autosnap otf-monaspace-nerd smartmontools stacer powertop xdg-user-dirs xdg-ninja

```
development
```bash
	docker docker-compose github-cli glab visual-studio-code-bin lazygit lazydocker nodejs-lts-hydrogen pnpm npm esbuild go air-bin pgcli
```
