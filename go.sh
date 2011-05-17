#!/bin/sh
git svn rebase
git commit -a
git svn dcommit
