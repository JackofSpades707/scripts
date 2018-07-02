#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from subprocess import Popen, PIPE
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument('-m', '--main')
parser.add_argument('-l', '--left')
parser.add_argument('-r', '--right')
parser.add_argument('-a', '--all')
args = parser.parse_args()

monitors = {
    "Main": {"resolution": "1920x1080", "selection": ":0+1680+1"},
    "Left": {"resolution": "1680x1050", "selection": ":0+0+0"},
    "Right": {"resolution": "1680x900", "selection": ":0+3600+0"},
    "All": {"resolution": "5020x1080", "selection": ":0+0+0"}
}

cmd = f"ffmpeg -video_size {resolution} -framerate 30 -f x11grab -i {selection} -c:v libx264 -qp 0 -preset ultrafast {filename}".split(' ')

