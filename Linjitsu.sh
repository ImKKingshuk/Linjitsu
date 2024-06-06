#!/usr/bin/env bash


ORANGE='\033[1m\033[38;5;214m'
PEACH='\e[1;38;2;255;204;153m'
GREEN='\033[1m\033[38;2;0;255;0m'
RED='\033[1m\033[38;5;196m'
NC='\033[0m' 


declare -A package_managers=(
    [APT]="apt"
    [DEB]="dpkg"
    [DNF]="dnf"
    [Flatpak]="flatpak"
    [Pacman]="pacman"
    [RPM]="rpm"
    [Snap]="snap"
)



print_banner() {
    local banner=(
        "******************************************"
        "*                 Linjitsu               *"
        "*   The Ultimate Linux Package Manager   *"
        "*                  v1.0.1                *"
        "*      ----------------------------      *"
        "*                        by @ImKKingshuk *"
        "* Github- https://github.com/ImKKingshuk *"
        "******************************************"
    )
    local width=$(tput cols)
    for line in "${banner[@]}"; do
        printf "%*s\n" $(((${#line} + width) / 2)) "$line"
    done
    echo
}


display_title() {
    local title="$1"
    local width=$(tput cols)
    printf "${PEACH}%*s\n${NC}" $(((${#title} + width) / 2)) "$title"
}


display_main_menu() {
    clear
    print_banner
    echo -e "${PEACH}Select Your Package Manager:${NC}"
    echo " 1. APT"
    echo " 2. DEB"
    echo " 3. DNF"
    echo " 4. Flatpak"
    echo " 5. Pacman"
    echo " 6. RPM"
    echo " 7. Snap"
    echo " 8. Firmware"
    echo " 9. Exit"
    echo ""
    echo -n "Enter your choice: "
}


display_package_menu() {
    local pm_name="$1"
    clear
    print_banner
    display_title "$pm_name App Manager"
    echo -e "${PEACH}Select Your Choice:${NC}"
    echo " 1. List All Apps"
    echo " 2. List User Installed Apps"
    echo " 3. Update All Apps"
    echo " 4. Search & Install App"
    echo " 5. Uninstall App"
    echo " 6. Delete Cache & Unnecessary Data"
    if [[ "$pm_name" == "Flatpak" ]]; then
        echo " 7. Add FlatHub Repository"
        echo " 8. Delete Unused Runtime & Flatpak Cache"
        echo " 9. Manage Permissions"
    fi
    echo "10. Go Back To Main Menu"
    echo ""
    echo -n "Enter your choice: "
}


execute_command() {
    local pm="$1"
    local cmd="$2"

    case "$pm" in
        APT)
            case "$cmd" in
                list_all) apt list --installed ;;
                list_user) apt list --manual-installed ;;
                update) sudo apt update && sudo apt upgrade -y ;;
                search_install) read -rp "Enter the app name to search: " app_name; apt search "$app_name"; read -rp "Enter the app name to install: " app_install; sudo apt install "$app_install" ;;
                uninstall) read -rp "Enter the app name to uninstall: " app_name; sudo apt remove "$app_name" ;;
                clean) sudo apt autoclean && sudo apt autoremove -y && sudo rm -rf /var/cache/apt/archives/* ;;
            esac
            ;;
        DEB)
            case "$cmd" in
                list_all) dpkg -l ;;
                list_user) echo "Not applicable for DEB";; 
                update) sudo apt update && sudo apt upgrade -y ;;
                search_install) read -rp "Enter the full path or URL of the DEB package to install: " deb_path; sudo dpkg -i "$deb_path"; sudo apt-get install -f ;;
                uninstall) read -rp "Enter the app name to uninstall: " app_name; sudo dpkg --remove "$app_name" ;;
                clean) sudo apt autoclean && sudo apt autoremove -y ;;
            esac
            ;;
        DNF)
            case "$cmd" in
                list_all) sudo dnf list installed ;;
                list_user) sudo dnf history userinstalled ;;
                update) sudo dnf update -y ;;
                search_install) read -rp "Enter the app name to search: " app_name; sudo dnf search "$app_name"; read -rp "Enter the app name to install: " app_install; sudo dnf install "$app_install" -y ;;
                uninstall) read -rp "Enter the app name to uninstall: " app_name; sudo dnf remove "$app_name" -y ;;
                clean) sudo dnf clean all && sudo dnf autoremove -y ;;
            esac
            ;;
        Flatpak)
            case "$cmd" in
                list_all) flatpak list ;;
                list_user) flatpak list --user ;;
                update) sudo flatpak update -y ;;
                search_install) read -rp "Enter the app name to search: " app_name; flatpak search "$app_name"; read -rp "Enter the app name to install: " app_install; sudo flatpak install "$app_install" -y ;;
                uninstall) read -rp "Enter the app name to uninstall: " app_name; sudo flatpak uninstall "$app_name" -y ;;
                clean) sudo flatpak uninstall --unused ;;
                add_flathub) flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo ;;
                delete_unused) sudo flatpak uninstall --unused; sudo flatpak repair ;;
                manage_permissions)
                    if ! command -v flatseal >/dev/null; then
                        flatpak install flathub com.github.tchx84.Flatseal -y
                    fi
                    flatpak run com.github.tchx84.Flatseal ;;
            esac
            ;;
        Pacman)
            case "$cmd" in
                list_all) pacman -Q ;;
                list_user) pacman -Qe ;;
                update) sudo pacman -Syu ;;
                search_install) read -rp "Enter the app name to search: " app_name; pacman -Ss "$app_name"; read -rp "Enter the app name to install: " app_install; sudo pacman -S "$app_install" ;;
                uninstall) read -rp "Enter the app name to uninstall: " app_name; sudo pacman -R "$app_name" ;;
                clean) sudo pacman -Sc ;;
            esac
            ;;
        RPM)
            case "$cmd" in
                list_all) rpm -qa ;;
                list_user) echo "Not applicable for RPM";; 
                update) sudo dnf update -y ;; 
                search_install) read -rp "Enter the full path or URL of the RPM package to install: " rpm_path; sudo rpm -ivh "$rpm_path" ;;
                uninstall) read -rp "Enter the app name to uninstall: " app_name; sudo rpm -e "$app_name" ;;
                clean) sudo dnf clean all && sudo dnf autoremove -y ;;
            esac
            ;;
        Snap)
            case "$cmd" in
                list_all) snap list ;;
                list_user) snap list | grep -v -e 'snapd\|core' ;; 
                update) sudo snap refresh ;;
                search_install) read -rp "Enter the app name to search: " app_name; snap find "$app_name"; read -rp "Enter the app name to install: " app_install; sudo snap install "$app_install" ;;
                uninstall) read -rp "Enter the app name to uninstall: " app_name; sudo snap remove "$app_name" ;;
                clean) sudo snap remove --purge $(snap list | grep -v -e 'Name\|core\|snapd' | awk '{print $1}') ;;
            esac
            ;;
    esac
}


fwupdmgr_check_updates() {
    sudo fwupdmgr get-updates
}

fwupdmgr_install_updates() {
    sudo fwupdmgr update
}

fwupdmgr_show_info() {
    sudo fwupdmgr get-updates --show-all
}

fwupdmgr_refresh_metadata() {
    sudo fwupdmgr refresh
}

fwupdmgr_rollback() {
    sudo fwupdmgr rollback
}


while true; do
    display_main_menu
    read -r main_choice
    case $main_choice in
        1)
            pm="APT"
            ;;
        2)
            pm="DEB"
            ;;
        3)
            pm="DNF"
            ;;
        4)
            pm="Flatpak"
            ;;
        5)
            pm="Pacman"
            ;;
        6)
            pm="RPM"
            ;;
        7)
            pm="Snap"
            ;;
        8)
            pm="Firmware"
            ;;
        9)
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice! Please try again.${NC}"
            continue
            ;;
    esac

    if [[ "$pm" != "Firmware" ]]; then
        while true; do
            display_package_menu "$pm"
            read -r pm_choice
            case $pm_choice in
                1) execute_command "$pm" "list_all" ;;
                2) execute_command "$pm" "list_user" ;;
                3) execute_command "$pm" "update" ;;
                4) execute_command "$pm" "search_install" ;;
                5) execute_command "$pm" "uninstall" ;;
                6) execute_command "$pm" "clean" ;;
                7) [[ "$pm" == "Flatpak" ]] && execute_command "$pm" "add_flathub" ;;
                8) [[ "$pm" == "Flatpak" ]] && execute_command "$pm" "delete_unused" ;;
                9) [[ "$pm" == "Flatpak" ]] && execute_command "$pm" "manage_permissions" ;;
                10) break ;;
                *) echo -e "${RED}Invalid choice! Please try again.${NC}" ;;
            esac
            read -rp "Press Enter to continue..."
        done
    else
        while true; do
            display_package_menu "Firmware"
            read -r fw_choice
            case $fw_choice in
                1) fwupdmgr_check_updates ;;
                2) fwupdmgr_install_updates ;;
                3) fwupdmgr_show_info ;;
                4) fwupdmgr_refresh_metadata ;;
                5) fwupdmgr_rollback ;;
                6) break ;;
                *) echo -e "${RED}Invalid choice! Please try again.${NC}" ;;
            esac
            read -rp "Press Enter to continue..."
        done
    fi
done
