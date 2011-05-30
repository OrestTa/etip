#!/bin/bash
#if [ `nmcli con status | grep "LRZ IPsec ETI" | awk '{ print $1, $2, $3, $NF }'` != "LRZ IPsec ETI yes" ] ; then
if ! nmcli con status | grep "LRZ IPsec" ; then
	nmcli con up id "LRZ IPsec ETI"
fi
git svn rebase
git commit -a
git svn dcommit
