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

confirm() {
    printf ":: ${color_yellow}$1 [Y/n]:${color_normal} "
    read -rp "" option
    if [ "$option" == "y" ] || [ "$option" == "Y" ] || [ "$remove_vkBasalt" == "" ]; then return 0; fi
    if [ "$option" == "n" ] || [ "$option" == "N" ]; then return 1; fi
}

choose_installation() {
    printf ":: ${color_yellow}Choose a fix [v]kBasalt (default), [d]isplay, [o]ri: ${color_normal} "
    read -rp "" fix
    if [ "$fix" == "" ]; then fix="vkBasalt"; fi

    case $fix in
        vkBasalt|vkBasa|vkBas|vk|v )
            return 0
        ;;
        display|displ|disp|dis|d )
            return 1
        ;;
        ori|or|o )
            return 2
        ;;
        * )
            printf "No such option..."
            choose_installation
    esac
}

install_vkBasalt() {
    distro="$(lsb_release -i | cut -f 2-)"

    case $distro in
        Arch|chachyos )
            pacman -Qi vkbasalt > /dev/null 2>&1
            if [ $? == 0 ]; then
                printf "\n> vkBasalt already installed, skipping install.";
                return
            fi

            if [ -x "$(command -v curl)" ]; then
                confirm "\n'yay' was detected on your system, do you want to use it?"
                if [ $? == 0 ]; then
                    yay -S --noconfirm --mflags --skipinteg vkBasalt
                else
                    install_vkBasalt_arch
                fi
            else
                install_vkBasalt_arch
            fi
        ;;
        Fedora )
            dnf list installed vkbasalt > /dev/null 2>&1
            if [ $? == 0 ]; then
                printf "\n> vkBasalt already installed, skipping install.";
                return
            fi

            sudo dnf install vkBasalt
        ;;
        Ubuntu )
            apt list --installed vkbasalt > /dev/null 2>&1
            if [ $? == 0 ]; then
                printf "\n> vkBasalt already installed, skipping install.";
                return
            fi

            sudo apt install vkbasalt
        ;;
        Debian )
            apt list --installed vkbasalt > /dev/null 2>&1
            if [ $? == 0 ]; then
                printf "\n> vkBasalt already installed, skipping install.";
                return
            fi

            sudo apt install vkbasalt
        ;;
    esac
}

install_vkBasalt_arch() {
    location=$PWD
    git clone https://aur.archlinux.org/vkbasalt.git /tmp/smurf-fix/vkBasalt/
    cd  /tmp/smurf-fix/vkBasalt/
    makepkg -si
    cd $location
    rm -rf /tmp/smurf-fix/vkBasalt/
}

uninstall_vkBasalt() {
    distro="$(lsb_release -i | cut -f 2-)"

    case $distro in
        Arch|chachyos )
            pacman -Qi vkbasalt > /dev/null 2>&1
            if [ $? == 1 ]; then
                printf "\n> vkBasalt not installed, skipping removal.";
                return
            fi

            sudo pacman -R vkbasalt --noconfirm
            sudo pacman -R vkbasalt-debug --noconfirm
        ;;
        Fedora )
            dnf list installed vkbasalt > /dev/null 2>&1
            if [ $? == 1 ]; then
                printf "\n> vkBasalt not installed, skipping removal.";
                return
            fi

            sudo dnf remove vkBasalt
        ;;
        Ubuntu )
            apt list --installed vkbasalt > /dev/null 2>&1
            if [ $? == 1 ]; then
                printf "\n> vkBasalt not installed, skipping removal.";
                return
            fi

            sudo apt remove vkbasalt
        ;;
        Debian )
            apt list --installed vkbasalt > /dev/null 2>&1
            if [ $? == 1 ]; then
                printf "\n> vkBasalt not installed, skipping removal.";
                return
            fi

            sudo apt remove vkbasalt
        ;;
    esac

    rm -rf ~/.config/vkBasalt/
    rm -rf ~/.local/share/vkBasalt
}

install_fix() {
    #
    #################### Variable Declaration ####################
    #

    choose_installation
    fix=$?

    printf "\n:: ${color_yellow}Enter Star Citizen wine prefix folder (Default: ${color_normal}/home/$USER/Games/star-citizen${color_yellow}):${color_normal} "
    read -rp "" starcitizen_dir
    if [ "$starcitizen_dir" == "" ]; then starcitizen_dir="/home/$USER/Games/star-citizen"; fi

    if [ $fix == 0 ] || [ $fix == 2 ]; then
        printf ":: ${color_yellow}The shader on/off toggle key (Default: ${color_normal}Home${color_yellow}): ${color_normal} "
        read -rp "" toggle_key
        if [ "$toggle_key" == "" ]; then toggle_key="Home"; fi
    fi

    #
    #################### vkBasalt Installation ####################
    #

    if [ $fix == 0 ] || [ $fix == 2 ]; then
        printf "\n> Installing vkBasalt..."
        install_vkBasalt
    fi

    #
    #################### Pick Installation ####################
    #

    case $fix in
        0 )
            vkBasalt_rod_fix $starcitizen_dir
        ;;
        1 )
            display_fix $starcitizen_dir
        ;;
        2 )
            vkBasalt_ori_fix $starcitizen_dir
        ;;
    esac
}

vkBasalt_rod_fix() {
    starcitizen_dir=$1
    mkdir -p /tmp/smurf-fix/
    #
    #################### Shader Configuration  ####################
    #

    printf "\n> Configuring shader & texture folders..."
    mkdir -p ~/.config/vkBasalt/reshade-shaders  > /dev/null 2>&1
    mkdir -p ~/.config/vkBasalt/reshade-shaders/Shaders  > /dev/null 2>&1
    mkdir -p ~/.config/vkBasalt/reshade-shaders/Textures  > /dev/null 2>&1

    printf "\n> Downloading reshade shaders..."
    curl -LO --output-dir /tmp/smurf-fix/ https://github.com/crosire/reshade-shaders/archive/master.zip > /dev/null 2>&1
    mv /tmp/smurf-fix/master.zip /tmp/smurf-fix/reshade-shaders.zip

    curl -LO --output-dir /tmp/smurf-fix/ https://github.com/CeeJayDK/SweetFX/archive/refs/heads/master.zip  > /dev/null 2>&1
    mv /tmp/smurf-fix/master.zip /tmp/smurf-fix/sweetfx.zip

    printf "\n> Extracting shaders..."
    unzip -qqo /tmp/smurf-fix/reshade-shaders.zip -d /tmp/smurf-fix/
    unzip -qqo /tmp/smurf-fix/sweetfx.zip -d /tmp/smurf-fix/

    printf "\n> Moving shaders to folders..."
    mv /tmp/smurf-fix/reshade-shaders-slim/Shaders/* ~/.config/vkBasalt/reshade-shaders/Shaders/
    mv /tmp/smurf-fix/reshade-shaders-slim/Textures/* ~/.config/vkBasalt/reshade-shaders/Textures/
    mv /tmp/smurf-fix/SweetFX-master/Shaders/SweetFX/* ~/.config/vkBasalt/reshade-shaders/Shaders/
    mv /tmp/smurf-fix/SweetFX-master/Textures/SweetFX/* ~/.config/vkBasalt/reshade-shaders/Textures/

    #
    #################### vkBasalt Configuration ####################
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

    rm -rf /tmp/smurf-fix/
}

display_fix() {
    starcitizen_dir=$1

    printf "\n> Applying Fix..."
    sed -i '/# Performance options/a export DISPLAY=' $starcitizen_dir/sc-launch.sh

    printf "\n\nDone!\n"
    printf "Now when you launch SC, the launcher will appear be a bit broken.\n"
    printf "Your aspect ratio and resolution may be a bit borkend.\n"
}

vkBasalt_ori_fix() {
    starcitizen_dir=$1
    #
    #################### Setup Folders ####################
    #

    printf "\n> Setup Folders...\n"
    mkdir -p ~/.local/share/vkBasalt
    mkdir -p ~/.config/vkBasalt

    #
    #################### Clone Shaders ####################
    #

    printf "\n> Clone Shaders...\n"
    cd ~/.local/share/vkBasalt
    git clone https://github.com/crosire/reshade-shaders.git

    #
    #################### Setup Shaders ####################
    #

    printf "\n> Setup Shader Configs...\n"
    cat > ~/.local/share/vkBasalt/reshade-shaders/Shaders/SwapRB.fx << EOF
    #include "ReShade.fxh"

    float3 SwapRB(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target {
        float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
        return float3(color.b, color.g, color.r);
    }

    technique SwapRB {
        pass {
            VertexShader = PostProcessVS;
            PixelShader = SwapRB;
        }
    }
EOF

    #
    #################### Setup Configs ####################
    #

    printf "\n> Setup vkBasalt configs...\n"
    cat > ~/.config/vkBasalt/StarCitizen.conf << EOF
    reshadeTexturePath = "$HOME/.local/share/vkBasalt/reshade-shaders/Textures"
    reshadeIncludePath = "$HOME/.local/share/vkBasalt/reshade-shaders/Shaders"
    effects = SwapRB
    SwapRB = "$HOME/.local/share/vkBasalt/reshade-shaders/Shaders/SwapRB.fx"
EOF

    #
    #################### Editing Launchscript ####################
    #

    printf "\n> Applying vkBasalt in Launchscript...\n"
    sed -i '/# Optional HUDs/a export ENABLE_VKBASALT=1' $starcitizen_dir/sc-launch.sh
    sed -i '/# Optional HUDs/a export VKBASALT_CONFIG_FILE="$HOME/.config/vkBasalt/StarCitizen.conf"' $starcitizen_dir/sc-launch.sh

    sed -i 's/export DISPLAY=//g' $starcitizen_dir/sc-launch.sh
    sed -i 's/"$wine_path"/wine "C:\Program Files\Roberts Space Industries\RSI Launcher\RSI Launcher.exe" --in-process-gpu > "$launch_log" 2>&1/"$wine_path"/wine "C:\Program Files\Roberts Space Industries\RSI Launcher\RSI Launcher.exe" > "$launch_log" 2>&1/g'$starcitizen_dir/sc-launch.sh

    #
    #################### Ending Text ####################
    #

    printf "\n\nDone!\n"
}

uninstall_fix() {
    choose_installation
    case $? in
        0 )
            printf "\n:: ${color_yellow}Enter Star Citizen wine prefix folder (Default: ${color_normal}/home/$USER/Games/star-citizen${color_yellow}):${color_normal} "
            read -rp "" starcitizen_dir
            if [ "$starcitizen_dir" == "" ]; then starcitizen_dir="/home/$USER/Games/star-citizen"; fi

            confirm "Remove vkBasalt?"
            if [ $? == 0 ]; then
                printf "\n> Removing vkBasalt..."
                uninstall_vkBasalt
            fi

            printf "\n> Reverting launchscript..."
            sed -i 's/export ENABLE_VKBASALT=1//g' $starcitizen_dir/sc-launch.sh

            printf "\n\nDone!\n"
        ;;
        1 )
            printf "\n:: ${color_yellow}Enter Star Citizen wine prefix folder (Default: ${color_normal}/home/$USER/Games/star-citizen${color_yellow}):${color_normal} "
            read -rp "" starcitizen_dir
            if [ "$starcitizen_dir" == "" ]; then starcitizen_dir="/home/$USER/Games/star-citizen"; fi

            printf "\n> Reverting launchscript..."
            sed -i 's/export DISPLAY=//g' $starcitizen_dir/sc-launch.sh

            printf "\n\nDone!\n"
        ;;
        2 )
            printf "\n:: ${color_yellow}Enter Star Citizen wine prefix folder (Default: ${color_normal}/home/$USER/Games/star-citizen${color_yellow}):${color_normal} "
            read -rp "" starcitizen_dir
            if [ "$starcitizen_dir" == "" ]; then starcitizen_dir="/home/$USER/Games/star-citizen"; fi

            confirm "Remove vkBasalt?"
            if [ $? == 0 ]; then
                printf "\n> Removing vkBasalt..."
                uninstall_vkBasalt
            fi

            printf "\n> Reverting launchscript..."
            sed -i 's/export ENABLE_VKBASALT=1//g'
            sed -i 's/export VKBASALT_CONFIG_FILE="$HOME/.config/vkBasalt/StarCitizen.conf//g' $starcitizen_dir/sc-launch.sh
            sed -i 's/"$wine_path"/wine "C:\Program Files\Roberts Space Industries\RSI Launcher\RSI Launcher.exe" > "$launch_log" 2>&1/"$wine_path"/wine "C:\Program Files\Roberts Space Industries\RSI Launcher\RSI Launcher.exe" --in-process-gpu > "$launch_log" 2>&1/g'$starcitizen_dir/sc-launch.sh

            printf "\n\nDone!\n"
        ;;
    esac
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
