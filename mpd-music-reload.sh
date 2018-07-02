#!/bin/bash

# Dependencies :
# mpd, mpc, clerk, sshfs, grep, sed
#

PLEXPI=pi@10.0.0.5
MUSIC_PATH=/media/pi/7c44e615-d42d-4013-92a6-209836f0d662/Music

# Number of artists/folders
MAX_NUM=`ls ~/Music | wc -l`

mpd --kill &> /dev/null
mpd &> /dev/null

# if [ "$MAX_NUM" == "0" ]; then
# 	echo "[!] ~/Music Not Mounted, Mounting Now"
# 	# Mount the music
# 	sudo sshfs -p 22 -o allow_other $PLEXPI:$MUSIC_PATH ~/Music -r
# 	# Update Number of artists/folders
# 	MAX_NUM=`ls ~/Music | wc -l`
# else echo "[+] ~/Music is Mounted Already"
# fi

mpc clear &> /dev/null
mpc update &> /dev/null
mpc ls | mpc add &> /dev/null
while [[ $NUM != $MAX_NUM ]]; do
	NUM=`mpc ls | wc -l`
	ARTISTS=`mpc stats | grep Artists | sed 's/    / /'`
	ALBUMBS=`mpc stats | grep Albums | sed 's/     / /'`
	SONGS=`mpc stats | grep Songs | sed 's/     / /'`
	echo -ne "[+] $NUM/$MAX_NUM Directories loaded | $ARTISTS | $ALBUMBS | $SONGS\r"
	sleep 1
done

clerk --update

echo ""
echo "[+] Done"
