#!/usr/bin/env bash

NOTES_FILE=~/.notes

# KEYS
delete_line="Ctrl+d"
edit_note="Ctrl+e"

menu=$(echo -e "< Exit\n---\n1 [ Browse Library ]>\n2 [ Current Artist ]>\n3 [ Current Queue ]>\n---\n4 [ Options ]>\n5 [ Ratings ]>\n6 [ Help ]")

function _rofi(){
	#rofi -dmenu -p "Note > "
	rofi -i -lines 25 -width 1000 -no-lavenshtein-sort "$@"
}


if [[ ! -a "${NOTES_FILE}" ]]; then
    echo "empty" >> "${NOTES_FILE}"
fi

ALL_NOTES="$(cat $NOTES_FILE)"

NOTE=$( (echo "${ALL_NOTES}")  | rofi -dmenu -i -lines 25 -width 1000 -p "Note > ")
MATCHING=$( (echo "${ALL_NOTES}") | grep "^${NOTE}$")

if [[ -n "${MATCHING}" ]]; then
    NEW_NOTES=$( (echo "${ALL_NOTES}")  | grep -v "^${NOTE}$" )
else
    NEW_NOTES=$( (echo -e "${ALL_NOTES}\n${NOTE}") | grep -v "^$")
fi

echo "${NEW_NOTES}" > "${NOTES_FILE}"



## Original src

# NOTES_FILE=~/.notes

# if [[ ! -a "${NOTES_FILE}" ]]; then
#     echo "empty" >> "${NOTES_FILE}"
# fi

# ALL_NOTES="$(cat $NOTES_FILE)"

# NOTE=$( (echo "${ALL_NOTES}")  | rofi -dmenu -p "Note:")
# MATCHING=$( (echo "${ALL_NOTES}") | grep "^${NOTE}$")

# if [[ -n "${MATCHING}" ]]; then
#     NEW_NOTES=$( (echo "${ALL_NOTES}")  | grep -v "^${NOTE}$" )
# else
#     NEW_NOTES=$( (echo -e "${ALL_NOTES}\n${NOTE}") | grep -v "^$")
# fi

# echo "${NEW_NOTES}" > "${NOTES_FILE}"
