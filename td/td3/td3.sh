#!/bin/bash




touch toto
chown admin:users toto
chmod g+r toto

setfacl -m  u:apache:r toto
ls -l ## on voit un + a la fin des droits
getfacl toto

setfacl -m  g:wheel:rw toto # ajoute rw
setfacl -m  g:wheel:- toto # retire tout
setfacl -x  g:wheel toto  # retir le groupe

setfacl --set u::rw,g::-,o::-,u:apache:r toto # sup les droits et repartir de 0
chmod go= toto ## sup le mask ie tout les droits mak que peut avoir un user