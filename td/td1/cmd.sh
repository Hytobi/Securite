#!/bin/bash

# Etape 1

#m1: admin
su -l
ip addr show
ip addr add 1.0.0.1/8 brd + dev eth0
useradd -c 'Jean DUPONT' jean
passwd jean # jean

#m2: admin
su -l
ip addr add 1.0.0.2/8 brd + dev eth0
useradd -c 'Jean DUPONT' dupont
passwd dupont # dupont
systemctl enable --now sshd

# Etape 2

#m1: jean
ssh 1.0.0.2 #1 : donne l'id de la cle pub et le debut de la clé (ok si on a la meme login)
ssh dupont@1.0.0.2 #1bis si pas meme login
hostname #3 pour verif : affiche m2
logout #4 pour se deco
exit #4bis pour se deco
#ctrl + d   #4ter

#de retour sur m1
less .ssh/known_hosts

#m2
ssh-keygen -l -f /etc/ssh/ssh_host_<id donné par m1>_key.pub #2


# Etape 3 : co sans mdp

#m1 : jean
ssh-keygen # 3* entrer - donne l'id de la cle "mon_id", fingerprint
ssh-copy-id -i ~/.ssh/id_<mon_id>.pub dupont@1.0.0.2 # et mettre le mdp
ssh dupont@1.0.0.2
cat ./.ssh/authorized_keys # on doit voir m1

# modificer le mdp
ssh-keygen -p # mettre un mdp : coucou
#deco/reco
ssh dupont@1.0.0.2 # le mdp va etre demmandé seulement a la premiere co de la session
ps x | grep ssh-agent # ce processus garde la clé privé