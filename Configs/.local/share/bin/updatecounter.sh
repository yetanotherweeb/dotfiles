#!/usr/bin/env bash

# Check release
if [ ! -f /etc/arch-release ] ; then
    exit 0
fi

# source variables
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"
get_aurhlpr
export -f pkg_installed
fpk_exup="pkg_installed flatpak && flatpak update"

# Trigger upgrade
if [ "$1" == "up" ] ; then
    trap 'pkill -RTMIN+20 waybar' EXIT
    command="
    fastfetch
    update.sh
    "
    kitty --title systemupdate sh -c "${command}"
fi

# Check for AUR updates
aur=$(${aurhlpr} -Qua | wc -l)
ofc=$( (while pgrep -x checkupdates > /dev/null ; do sleep 1; done) ; checkupdates | wc -l)
tltp=$( (while pgrep -x checkupdates-with-aur > /dev/null ; do sleep 1; done) ; checkupdates-with-aur | sed ':a;N;$!ba;s/\n/\\n/g')

# Check for flatpak updates
if pkg_installed flatpak ; then
    fpk=$(flatpak remote-ls --updates | wc -l)
    fpk_disp="\n󰏓 Flatpak $fpk"
else
    fpk=0
    fpk_disp=""
fi

# Calculate total available updates
upd=$(( ofc + aur + fpk ))

[ "${1}" == upgrade ] && printf "[Official] %-10s\n[AUR]      %-10s\n[Flatpak]  %-10s\n" "$ofc" "$aur" "$fpk" && exit

# Show tooltip
if [ $upd -eq 0 ] ; then
    upd="" #Remove Icon completely
    # upd="󰮯"   #If zero Display Icon only
    echo "{\"text\":\"$upd\", \"tooltip\":\" Packages are up to date\"}"
else
    echo "{\"text\":\"󱧘 $upd\", \"tooltip\":\"$tltp\"}"
fi
