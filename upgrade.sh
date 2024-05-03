#!/bin/bash
echo "### UPGRADING NATIVE PACKAGES ###"
sudo pacman -Syu --noconfirm

echo "### UPGRADING AUR AND OTHER PACKAGES ###"
yay --noconfirm

echo "### CLEANING UP ORPHANED PACKAGES ###"
sudo -s pacman -Qdtq | ifne sudo pacman --noconfirm -Rns -

echo "### UPGRADES COMPLETE ###"
read -p "Press any key to exit ..."
