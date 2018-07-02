#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from rofi import Rofi
import pyperclip
import json

def read_history_file(hist_file='/home/jack/.dotfiles/clipster/history'):
    try:
        with open(hist_file) as hist_f:
            data = (json.load(hist_f))
        return data
    except FileNotFoundError as exc:
        Rofi.error("[!] Missing History File [!]")
        raise SystemExit(1)

def main():
    history = read_history_file()
    history['PRIMARY'].reverse()
    history['CLIPBOARD'].reverse()
    history = history['PRIMARY'] + history['CLIPBOARD']
    history = sorted(set(history), key=history.index)
    r = Rofi()
    prompt = r.select('>', history, message='Select an item to copy to your clipboard')
    if prompt == (-1, -1):  # Bad Exit for rofi
        raise SystemExit(1)
    print("Copying {}".format(history[prompt[0]]))
    pyperclip.copy(history[prompt[0]])


if __name__ == '__main__':
    main()


