#!/bin/sh
if [ nmcli con status | grep "LRZ IPsec ETI" | awk '{ print $1, $2, $3, $NF }' = "LRZ IPsec ETI yes"] ; then
	nmcli con up id "LRZ IPsec ETI"
fi
git svn rebase
git commit -a
git svn dcommit
