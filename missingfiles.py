#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from subprocess import Popen, PIPE
from os.path import isfile, isdir

'''
this will report all files that should exist
on the filesystem according to pacman but do not exist
'''

cmd = 'pacman -Ql'.split(' ')
proc = Popen(cmd, stdin=PIPE, stdout=PIPE, stderr=PIPE)
stdout, stderr = proc.communicate()
pkgs = stdout.decode('utf-8').splitlines()
for n, pkg in enumerate(pkgs):
    pkgs[n] = pkg.split(' ', 1)
    if not isfile(pkgs[n][1]) and not isdir(pkgs[n][1]):
        print(pkgs[n][0], pkgs[n][1])

