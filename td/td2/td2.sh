#!/bin/bash

# chifrement symetrique : meme cle pour decrypt/crypt ; asym deux cle diff

# Etape 1

#m1: admin
# sur m1 on va cree user Alice et sur m2 user Bob
su -l ## root
ip addr add 10.0.0.1/8 brd + dev eth0
useradd -c 'Alice DUPONT' alice
passwd alice # alice
systemctl start sshd

#m2
su -l ## root
ip addr add 10.0.0.2/8 brd + dev eth0
useradd -c 'Bob DURANT' bob
passwd bob # bob
systemctl start sshd

#etape 2

# sur m2 se mettre en tant que Bob
gpg --gen-key 
# renseigner :
## "Bob DURANT"
## "bob@dom.fr"
## O  # mdp : bobi ## On a en info l'endroit ou c'est gen etc ...
emacs contrat.txt ## rajouter du texte dans le fichier
gpg --clearsign contrat.txt
less contrat.txt.asc ## contient le contrat en txt et la signature codé en base 64
gpg --verify contrat.txt.asc ## "Bonne signature de Bob DURANT"
# Si je modifi le fichier contrat.txt et que je test j'aurais encore "bonne signature"
# Il faut modifier le .asc pour obtenir "mauvaise signature"
gpg --output bob.pub --armor --export 'Bob DURANT' # bob.pub peut s'appeler comme on veut / armor pour coder en base64
cat bob.pub # c'est la clé public de bob
scp bob.pub alice@10.0.0.1: # si on met pas le : scp = cp
# on triche un peu car bob ne devrait pas connaitre le mdp de Alice

#Sur m1 se mettre en tant que Alice
ls # on voit un bob.pub
emacs MassageSecretPourBob.txt ## mettre du texte
gpg --import bob.pub
gpg -e -r 'Bob DURANT' MessageSecretPourBob.txt # 0 / car on est passé par scp donc c'est fiable
cat MessageSecretPourBob.txt.gpg
scp MessageSecretPourBob.txt.gpg bob@10.0.0.2:
# on triche un peu car alice ne devrait pas connaitre le mdp de Bob

# Retour sur m2
ls # on voit MessageSecretPourBob.txt.gpg
gpg -d MessageSecretPourBob.txt.gpg # mdp: bobi / Le message s'affiche
gpg --output Message -d MessageSecretPourBob.txt.gpg # le mdp est stocké en cache (gpgagent) / le message est dans le fichier Message
ps aux | grep gpg # pour voir le cache mdp


# Etape 3 : alice signe aussi

#Sur m1
gpg --gen-key
# renseigner :
## "Alice DUPONT"
## "alice"@dom.fr"
## O  # mdp : ali
gpg --sign -e -r 'Bob DURANT' MessageSecretPourBob.txt # o / o / ali
scp MessageSecretPourBob.txt.gpg bob@10.0.0.2:
gpg --output alice.pub --export 'Alice DUPONT'
scp alice.pub bob@10.0.0.2:

# Sur m2
gpg --import alice.pub
gpg --output Message -d MessageSecretPourBob.txt.gpg
cat Message

## Etape 4:  Chiffrement symetrique
# Sur m2
gpg -c Message ## alice
gpg -d Message.gpg ## mdp en cache
scp Message.gpg bob@10.0.0.2:

#Sur m1
gpg -d Message.gpg #mdp : alice


# Etape 5 : self crypto
touch mdp.txt
gpg -e -r 'Bob DURANT' mdp.txt
rm mdp.txt
emacs mdp.txt.gpg # bobi
# maintenant on peut ecrire dans ce fichier
# Lorsque on sauvegarde ca crypte avec la clé public donc on a pas a mettre de mdp
# Si on fait un less, il va utiliser le cache pour avoir la clé ; un more ou cat n'est pas aussi perfomant