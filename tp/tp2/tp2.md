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