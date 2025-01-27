# TP2

## Exercice 1

Donnez la configuration nftables pour bloquer tout le trafic à destination de la machine locale.
Donnez ensuite la (ou les) commande(s) pour autoriser les connexions sur le port 80 (http)

lors d'une connection a une page web, le client va prendre le premier port non reservé disponible donc pas besoin de mettre un sport

```
flush ruleset

table inet FILTER {
  chain INPUT {
    type filter hook input priority filter; policy drop;
    # les règles de filtrage pour INPUT
    iif lo accept

    # accepter les réponses aux datagrammes qu'on envoie
    ct state { established, related } accept

    tcp dport 80 accept
  }
  chain FORWARD {
    type filter hook forward priority filter; policy drop;
    # les règles de filtrage pour FORWARD

    # accepter les réponses aux datagrammes qu'on envoie
    ct state { established, related } accept
  }
  chain OUTPUT {
    type filter hook output priority filter; policy accept;
    # les règles de filtrage pour OUTPUT
  }
}
```

## Exercice 2

Donnez la configuration nftables pour bloquer tout le trafic qui transite par la machine (routeur). (fait dans le skeleton)
Donnez ensuite la (ou les) commande(s) pour autoriser les connexions provenant de l’interface eth0 et à destination du port 80 (http) vers eth1.

```
flush ruleset

table inet FILTER {
  chain INPUT {
    type filter hook input priority filter; policy drop;
    # les règles de filtrage pour INPUT
    iif lo accept

    # accepter les réponses aux datagrammes qu'on envoie
    ct state { established, related } accept

    tcp dport 80 accept
  }
  chain FORWARD {
    type filter hook forward priority filter; policy drop;
    # les règles de filtrage pour FORWARD

    # accepter les réponses aux datagrammes qu'on envoie
    ct state { established, related } accept

    tcp dport http iff eth0 oif eth1 accept
  }
  chain OUTPUT {
    type filter hook output priority filter; policy accept;
    # les règles de filtrage pour OUTPUT
  }
}
```

## Exercice 3
Vous voulez protéger votre machine personnelle (sous Linux). Celle-ci possède une interface réseau eth0 sur laquelle ne sont connectées que vos machines auxquelles vous faites toute confiance. L’interface eth1 vous relie à l’Internet. Donnez la configuration nftables pour :
— vous protéger de l’IP-spoofing (pensez à créer une chaîne)
— créer une chaîne qui va bloquer des ports bien connus pour générer du trafic indésirable (par exemple
135-139 et 4662)
— accepter le retour des connexions que vous avez initié
— autoriser une connexion sur le port ssh de votre machine mais uniquement depuis une adresse IP fixée
(1.30.30.30).
— enregistrer dans le journal les connexions ssh qui s’effectuent sur votre machine
— garder une trace dans le journal des tentatives de connexions qui échouent
— renvoyer un message d’erreur ICMP si éventuellement vous refusez un datagramme (mais uniquement sur
eth0)

```conf
flush ruleset
define localnet=10.0.0.0/8

table inet FILTER {

  chain ipspoofing {
    iif eth1 ip saddr $localnet drop # on refuse l'entré des truc qui ressemble a mon ip
    iif eth0 ip saddr != $localnet reject # a l'interieur je dois avoir qqc qui ressemble a mon addresse local
  }
  chain wkp {
    tcp dport {135-139,4662} drop
  }

  chain INPUT {
    type filter hook input priority filter; policy drop;
    # les règles de filtrage pour INPUT
    iif lo accept

    # accepter les réponses aux datagrammes qu'on envoie
    ct state { established, related } accept

    jump ipspoofing
    jump wkp
    ip saddr 1.30.30.30 tcp dport ssh log prefix "connexion ssh: " # enlever ip saddr 1.30.30.30 pour voir TOUTE les requettes
    ip saddr 1.30.30.30 tcp dport ssh accept
    # A partir d'ici tout est interdit
    ct state {new} limit 10/s log log prefix "denied: "
    iif eth0 reject
  }
  chain FORWARD {
    type filter hook forward priority filter; policy drop;
    # les règles de filtrage pour FORWARD

    # accepter les réponses aux datagrammes qu'on envoie
    ct state { established, related } accept

    jump ipspoofing
    jump wkp
  }
  chain OUTPUT {
    type filter hook output priority filter; policy accept;
    # les règles de filtrage pour OUTPUT
  }
}
```

## Exercice 4

Vous devez cette fois protéger un réseau en configurant la machine linux qui sert de routeur. Celle-ci
possède une interface réseau eth0 sur laquelle sont connectées vos machines fixes, une interface eth1 sur laquelles
sont connectées vos ordinateurs portables et une interface eth2 reliée à l’internet. Donnez la configuration nftables
pour :
— éviter les attaques de type IP spoofing
— autoriser un accès SSH sur le pare-feu depuis l’unique machine de l’administrateur
— laisser vos machines accéder aux serveurs DNS
— laisser votre relai de messagerie accéder au relai de votre FAI
— autoriser l’accès à votre serveur web depuis l’internet
— autoriser votre proxy web à dialoguer avec l’internet
— interdire toute connexion web qui ne passerait pas par le proxy
— autoriser les connexions SSH, POP3, SMTP, WWW depuis votre deuxième site
— envoyer un message ICMP d’erreur quand vous rejetez un datagramme et si ce n’est pas trop dangereux
— le réseau des portables ne peut pas échanger de datagramme avec le réseau des machines fixes (sauf pour
échanger ou recevoir du courrier électronique)
Serveur DNS : 1.1.1.4
Relai de messagerie du FAI : smtp.fai.fr
Votre réseau : 10.1.0.0/17 pour les fixes, 10.1.128.0/17 pour les portables
Votre relai de messagerie : mail.mondomaine.fr
Votre proxy web : 10.1.0.10 et 10.1.128.10
Deuxième site : 10.2.0.0/16
Machine de l’administrateur : master.mondomaine.fr

```conf
flush ruleset

define fixes=10.1.0.0/17
define portables=10.1.128.0/17

table inet FILTER {
  chain ipspoofing {
    # Eviter l'IP spoofing : vérifier que les paquets viennent des interfaces correctes
    # iifname si le nom ne changera jamais
    iif eth0 ip saddr != $fixes reject
    iif eth1 ip saddr != $portables reject
    iif eth2 ip saddr {$fixes, $portables} reject # drop si pas une entreprise
  }

  chain noInternalCom {
    # Interdire le trafic direct entre les réseaux fixes et portables
    
  }

  chain INPUT {
    type filter hook input priority filter; policy drop;
    iif lo accept

    # Accepter les réponses aux datagrammes envoyés (connexions établies et liées)
    ct state { established, related } accept

    jump ipspoofing

    # Autoriser l'accès SSH depuis l'unique machine de l'administrateur (master.mondomaine.fr)
    ip saddr master.mondomaine.fr tcp dport ssh accept # ssh = 22

    reject
  }

  chain FORWARD {
    type filter hook forward priority filter; policy drop;

    # Accepter les réponses aux datagrammes envoyés (connexions établies et liées)
    ct state { established, related } accept

    jump ipspoofing

    # Autoriser l'accès aux serveurs DNS (1.1.1.4)
    # 10.1.0.0/17 union 10.1.128.0/17 = 10.1.0.0/16
    ip daddr 1.1.1.4 ip saddr 10.1.0.0/16 udp dport domain accept # domaine = 53
    # ou bien ip daddr 1.1.1.4 ip saddr {$fixes, $portables} udp dport domain accept

    # Autoriser le relai de messagerie à accéder au serveur de messagerie du FAI (smtp.fai.fr)
    ip saddr mail.mondomaine.fr ip daddr smtp.fai.fr tcp dport smtp accept # smtp = 25
    ip saddr smtp.fai.fr ip daddr mail.mondomaine.fr tcp dport smtp accept

    # Autoriser l’accès à votre serveur web depuis l’internet
    ip daddr www.mondomaine.fr tcp dport {http, https} accept

    # Autoriser le proxy web à accéder à Internet
    ip saddr {10.1.0.10, 10.1.128.10} oif eth2 tcp dport {http, https} accept

    # Interdire toute connexion web directe qui ne passerait pas par le proxy
    oif eth2 tcp dport {http, https} reject

    # Autoriser l'accès SSH, POP3, SMTP, WWW depuis le deuxième site
    ip saddr 10.2.0.0/16 ip daddr $fixes tcp dport {ssh,pop3,imap,smtp,http,https} accept 

    # Bloquer la communication entre le réseau des machines fixes et celui des portables sauf pour le mail
    ip saddr $portables ip daddr mail.mondomaine.fr tcp dport {pop3,imap,smtp} accept

    reject
  }

  chain OUTPUT {
    type filter hook output priority filter; policy accept;
    # Les règles de filtrage pour OUTPUT peuvent être laissées ouvertes par défaut.
  }
}
```