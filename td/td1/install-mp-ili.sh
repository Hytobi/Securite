#!/bin/sh
echo "Installation des dépendances (root password required)"
sudo apt install udpcast qemu-kvm qemu-utils inkscape libboost-program-options-dev libboost-filesystem-dev libjsoncpp25
sudo usermod -a -G kvm $USER

echo "Récupération des archives"
udp-receiver --no-progress --nokbd | tar xvzpSf -
