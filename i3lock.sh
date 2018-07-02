#!/bin/sh
revert() {
xset dpms 0 0 0
}
trap revert HUP INT TERM
xset +dpms dpms 5 5 5
xset dpms force suspend
i3lock -n -c 000000
revert    
