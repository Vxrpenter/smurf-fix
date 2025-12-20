#!/bin/bash

#
#################### Root Check ####################
#

if [ "$(id -u)" -eq 0 ]; then
    printf "\nsmurf_fix.sh: This script is not supposed to be run as root!"
    exit 9
fi

#
#################### Check for dependencies ####################
#

if [ ! -x "$(command -v curl)" ]; then
    printf "\nsmurf_fix.sh: The required package 'curl' was not found on this system.\n" 1>&2
    exit 1
fi

#
#################### Colors ####################
#

color_normal=$(tput sgr0)
color_yellow=$(tput setaf 3)
color_red=$(tput setaf 1)

#
#################### Opening Text ####################
#

printf "
   _____                       __   ______ _
  / ____|                     / _| |  ____(_)
 | (___  _ __ ___  _   _ _ __| |_  | |__   ___  __
  \___ \| '_ \` _ \| | | | '__|  _| |  __| | \ \/ /
  ____) | | | | | | |_| | |  | |   | |    | |>  <
 |_____/|_| |_| |_|\__,_|_|  |_|   |_|    |_/_/\_\
 \n                            (Arch Linux)
 by Rodson & Vxrpenter Dec '25
"
printf "\nThis fix uses vkBasalt along with reshade shaders (specifically ColorMatrix.fx) to swap BGR to RGB on SC Vulkan."
printf "\nThis red & blue colour channel swap will make the colours normal again."
printf "\nPlease note, this requires the lug-wine-tkg-git-11.0rc1-2 LUG runner or newer (use LUG Helper to install)."

install_fix() {
    #
    #################### Variable Declaration ####################
    #

    printf "\n:: ${color_yellow}Enter Star Citizen wine prefix folder (Default: ${color_normal}/home/$USER/Games/star-citizen${color_yellow}):${color_normal} "
    read -rp "" starcitizen_dir
    if [$starcitizen_dir == ""]; then starcitizen_dir="/home/$USER/Games/star-citizen"; fi

    printf ":: ${color_yellow}The shader on/off toggle key (Default: ${color_normal}Home${color_yellow}): ${color_normal} "
    read -rp "" toggle_key
    if [$toggle_key == ""]; then toggle_key="Home"; fi

    #
    #################### Shader Configuration  ####################
    #

    printf "\n> Installing vkBasalt...\n"
    location=$PWD
    git clone https://aur.archlinux.org/vkbasalt.git ~/Downloads/vkBasalt/
    cd  ~/Downloads/vkBasalt/
    makepkg -si
    cd $location
    rm -rf ~/Downloads/vkBasalt/

    printf "\n> Configuring shader & texture folders..."
    mkdir -p ~/.config/vkBasalt/reshade-shaders  > /dev/null 2>&1
    mkdir -p ~/.config/vkBasalt/reshade-shaders/Shaders  > /dev/null 2>&1
    mkdir -p ~/.config/vkBasalt/reshade-shaders/Textures  > /dev/null 2>&1

    printf "\n> Downloading reshade shaders..."
    curl -LO --output-dir ~/Downloads/ https://github.com/crosire/reshade-shaders/archive/master.zip > /dev/null 2>&1
    mv ~/Downloads/master.zip ~/Downloads/reshade-shaders.zip

    curl -LO --output-dir ~/Downloads/ https://github.com/CeeJayDK/SweetFX/archive/refs/heads/master.zip  > /dev/null 2>&1
    mv ~/Downloads/master.zip ~/Downloads/sweetfx.zip

    printf "\n> Extracting shaders..."
    unzip -qqo ~/Downloads/reshade-shaders.zip -d ~/Downloads
    rm -f ~/Downloads/reshade-shaders.zip
    unzip -qqo ~/Downloads/sweetfx.zip -d ~/Downloads
    rm -f ~/Downloads/sweetfx.zip

    printf "\n> Moving shaders to folders..."
    mv ~/Downloads/reshade-shaders-slim/Shaders/* ~/.config/vkBasalt/reshade-shaders/Shaders/
    mv ~/Downloads/reshade-shaders-slim/Textures/* ~/.config/vkBasalt/reshade-shaders/Textures/
    mv ~/Downloads/SweetFX-master/Shaders/SweetFX/* ~/.config/vkBasalt/reshade-shaders/Shaders/
    mv ~/Downloads/SweetFX-master/Textures/SweetFX/* ~/.config/vkBasalt/reshade-shaders/Textures/
    rm -rf ~/Downloads/reshade-shaders-slim/
    rm -rf ~/Downloads/SweetFX-master/

    #
    #################### vkBasalt Configuration  ####################
    #

    printf "\n> Creating vkBasalt configuration..."
    vkbconfig="toggleKey = $toggle_key\nenableOnLaunch = True\neffects = ColorMatrix\nColorMatrix = /home/$USER/.config/vkBasalt/reshade-shaders/Shaders/ColorMatrix.fx\nreshadeTexturePath = /home/$USER/.config/vkBasalt/reshade-shaders/Textures\nreshadeIncludePath = /home/$USER/.config/vkBasalt/reshade-shaders/Shaders"
    echo -e $vkbconfig > /home/$USER/.config/vkBasalt/vkBasalt.conf

    printf "\n> Applying ColorMatrix BGR>RGB configuration..."
    sed -i -e '14s/.*/> = float3(0.000, 0.000, 1.000);/' ~/.config/vkBasalt/reshade-shaders/Shaders/ColorMatrix.fx
    sed -i -e '19s/.*/> = float3(0.000, 1.000, 0.000);/' ~/.config/vkBasalt/reshade-shaders/Shaders/ColorMatrix.fx
    sed -i -e '24s/.*/> = float3(1.000, 0.000, 0.000);/' ~/.config/vkBasalt/reshade-shaders/Shaders/ColorMatrix.fx

    printf "\n> Enabling vkBasalt in LUG sc-launch.sh script..."
    sed -i '/# Optional HUDs/a export ENABLE_VKBASALT=1' $starcitizen_dir/sc-launch.sh

    #
    #################### Ending Text ####################
    #

    printf "\n\nDone!\n"
    printf "Now when you launch SC, the launcher will appear orange, this indicates vkBasalt has loaded & is working.\n"
    printf "You can use the toggle key (default Home) to turn the effect on & off.\n"
    printf "vkBasalt is compatible with reshade shaders & configurations"
}

uninstall_fix() {
    printf "\n:: ${color_yellow}Enter Star Citizen wine prefix folder (Default: ${color_normal}/home/$USER/Games/star-citizen${color_yellow}):${color_normal} "
    read -rp "" starcitizen_dir
    if [$starcitizen_dir == ""]; then starcitizen_dir="/home/$USER/Games/star-citizen"; fi

    printf "\n> Removing vkBasalt...\n"
    sudo pacman -R vkbasalt --noconfirm
    sudo pacman -R vkbasalt-debug --noconfirm

    printf "\n> Reverting launchscript..."
    rm -rf ~/.config/vkBasalt/
    sed -i 's/export ENABLE_VKBASALT=1//g' $starcitizen_dir/sc-launch.sh
}

option() {
    printf "\n:: ${color_yellow}Do you want to [i]nstall or [u]ninstall:${color_normal} "
    read -rp "" installation_option
    case $installation_option in
        install|inst|in|ini|i )
            install_fix
        ;;
        uninstall|uninst|uni|un|u )
            uninstall_fix
        ;;
        * )
            printf "No such option..."
            option
    esac
}
option
