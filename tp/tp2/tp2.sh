# ./bin/ns 3h1r

# dans r1

su -l # root
ip addr add 10.0.0.1/8 brd + dev eth0
ip addr add 1.0.0.1/8 brd + dev eth1

ls /mnt/host/home
nft -f /mnt/host/home/Securite/tp/tp2/exo3.nft
nft list ruleset
systemctl start sshd

# dans le schema on voit que m2 comm en eth1

# sur m2 : simule une machine externe

su -l # root
ip addr add 1.30.30.30/8 brd + dev eth0
ssh admin@1.0.0.1


# sur r1
journalctl -e # "? connection" pour faire une recherche



