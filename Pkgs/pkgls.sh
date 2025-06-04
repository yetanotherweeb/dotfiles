#!/bin/bash

pacman -Qqe > pacman-pkgs.txt
yay -Qm | awk '{print $1}' > aur-pkgs.txt
echo "The package lists have been retrieved"
