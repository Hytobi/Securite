#!/bin/bash

BLEU='\033[0;34m'
JAUNE='\033[1;33m'
VERT='\033[1;32m'
RESET='\033[0m'

echo -e "${BLEU}On calcule h(m) pour m='Bonjour'${RESET}"
echo Bonjour > toto

echo -e "${VERT}md5sum : ${RESET}${JAUNE}$(md5sum toto)${RESET}"  # empreinte sur 2^8 = 128 bits (hexa c'est 4 bit ...)
echo -e "${VERT}sha1sum : ${RESET}${JAUNE}$(sha1sum toto)${RESET}"  #160 bits : dd934886cb654a0776a918288619e600955b5e3f
echo -e "${VERT}sha256sum : ${RESET}${JAUNE}$(sha256sum toto)${RESET}" # 256 bits : 8dc2a6966f1be1644ec6b1f7223f47e53de5ad05e1c976736d948e7977a13dd3
echo -e "${VERT}sha512sum : ${RESET}${JAUNE}$(sha512sum toto)${RESET}" # 512 bits : 6ecfc5a4414940fcd6f939a5268d1b70d0695b63e4bb45b841119359b4325346203b74dfd0b971384dc980610bbf8549ac54f7bed979a1ddc583b56b83b8a038

echo
echo -e "${BLEU}On modifie seulement 1 caractère pour voir${RESET}"

echo Conjour > toto
echo -e "${VERT}md5sum : ${RESET}${JAUNE}$(md5sum toto)${RESET}" # 26d5a9188000d0e4fd6a7a8bacbc5c4e
echo -e "${VERT}sha1sum : ${RESET}${JAUNE}$(sha1sum toto)${RESET}" # 160 bits : 8d3b3cf35c1034f028cb8e91991cf2e3e866c95e
echo -e "${VERT}sha256sum : ${RESET}${JAUNE}$(sha256sum toto)${RESET}" # 256 bits : 3930134daf279a4ea03d3b1409f7b118a8eca55d2eef1d27e8f6c7242aebe8b7
echo -e "${VERT}sha512sum : ${RESET}${JAUNE}$(sha512sum toto)${RESET}" # 512 bits : c630bec7b6b4b8a07975f6d4b61d18d5f8ea2dc5ff4fed69f122bae75983791821e089a1ff6da08c7bb902205c1f2ddee13c82e73dd335b12840b3e222027a86

echo
echo -e "${BLEU}Commande pour vérifier l'intégrité${RESET}"

echo Bonjour > toto
sha256sum toto > emprintes
echo -e "${JAUNE}$(sha256sum -c emprintes)${RESET}" # va rechercher le fichier toto et recalculer la valeur : "toto: Réussi"

echo
echo -e "${BLEU}Commande pour récupérer les h de tous les fichiers d'un répertoire${RESET}"

echo -e "${JAUNE}"
find /tmp -type f -exec sha256sum {} \; > empreintes2
echo -e "${RESET}"
