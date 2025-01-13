#!/bin/bash

# Authenth par certificat

## Context 
# J'ai un serveur intranet, je veux que les users ont acces depuis le reseau local, et depuis l'exterieur
# Alice, employé de l'entrprise, va demmandé un cert au CA(bob)
# m1 : Alice
# m2 : Bob le CA
# m3 : serveur intranet

# Etape 1 :
# Sur m1
su -l ## root
ip addr add 10.0.0.1/8 brd + dev eth0
useradd -c 'Alice DUPONT' alice
passwd alice # alice
systemctl start sshd

# Sur m2
su -l ## root
ip addr add 10.0.0.2/8 brd + dev eth0
useradd -c 'Bob DURANT' bob
passwd bob # bob
systemctl start sshd

# Sur m3
su -l ## root
ip addr add 10.0.0.3/8 brd + dev eth0




# Etape 2 :

# Sur m2 : Bob
cp -r /usr/share/easy-rsa/3/ easy-rsa
cd easy-rsa
./easyrsa init-pki
./easyrsa build-ca 
# mdp : bobca
# CN : M2 ILI

# Sur m1 : Alice
cp -r /usr/share/easy-rsa/3/ easy-rsa
cd easy-rsa
./easyrsa init-pki
./easyrsa gen-req alice
# PEM passphrase : alice
# CN : Alice DUPONT
## On a un fichier .key et un .req
scp pki/reqs/alice.req bob@10.0.0.2:

# Sur m2
./easyrsa import-req ~/alice.req alice ## import de la requete
./easyrsa sign-req client alice ## signe le client alice
# yes ; avant ca il faudrait aller voir alice et qu'elle fournisse l'emprunte du fichier pour etre sur que c'est elle
# mdp : bobca
## le certificat a ete signé
./easyrsa show-cert alice
scp pki/issued/alice.crt alice@10.0.0.1:

# Sur m1
cp ~/alice.crt pki/issued/
./easyrsa export-p12 alice noca
# mdp de priv alice : alice
# mdp du p12 : alicep12
## ouvrir un navigateur > setting > privicy and security > view certificate > your certificates > import  # mettre le .p12 et le mdp: alicep12

# Sur m3 : admin
scp bob@10.0.0.2:easy-rsa/pki/ca.crt /etc/pki/tls/certs/ca.crt
cd /etc/httpd/conf.d/
emacs ssl.conf & 
# decommente le SSLCACertificateFile et modif le nom
# decommente SSLVerifyClient
# decomment SSLVerifyDepth a 1 (directement a mon ca)
emacs ../conf/httpd.conf
# on cherche <Directory "/var/www/html"> et juste en dessous on rajoute "SSLRequireSSL" pour exiger du https
echo Intranet > /var/www/html/index.html
ls -l /var/www/html/index.html # -rw------- Attention le serveur web ne tourne pas en tant que root, si y'a une faille de secu un attaquant a acces au root de la machine
# le serveur demare en root, prend les ports 80 et 443 puis passe en user normal
chmod a+x /var/www/html/index.html # -rw-r--r--
systemctl start httpd
# cas ou ca lance pas :
apachectl configtest ## check les erreur de syntaxt

# Sur m1
# page web https://10.0.0.3 > advanced > accept risk > send certificate
