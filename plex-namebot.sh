#!/bin/bash

#TODO: add --dryrun

base_dir="/mnt/3TB"

function Anime(){
    echo "[+] Renaming Anime"
    filebot -rename --db "${1:-AniDB}" -non-strict --lang en --encoding UTF-8 --action move -extract --format "$base_dir/Videos/Anime/{primaryTitle}/Season {s}/{primaryTitle} - {episode.special ? S00E+special.pad(2) : s00e00} - {t} {vf} {resolution}" -r Videos/Anime/
}

function Cartoons(){
    filebot -rename --db ${1:-TheTVDB} -non-strict --lang en --encoding UTF-8 --action move -extract --format $base_dir/Videos/Cartoons/"{n}/{episode.special ? 'Specials' : 'Season '+s.pad(2)}/{n} - {episode.special ? 'S00E'+special.pad(2) : s00e00} - {t} {vf} {resolution}" -r Videos/Cartoons
}

function TV(){
    echo "[+] Renaming TV Shows"
    filebot -rename --db ${1:-TheTVDB} -non-strict --lang en --encoding UTF-8 --action move -extract --format "$base_dir/Videos/TV Shows/{n}/{episode.special ? Specials : Season +s.pad(2)}/{n} - {episode.special ? S00E+special.pad(2) : s00e00} - {t} {vf} {resolution}" -r 'Videos/TV Shows'
}

function Movies(){
    echo "[+] Renaming Movies"
    filebot -rename --db ${1:-TheMovieDB} -non-strict --lang en --encoding UTF-8 --action move -extract --format "$base_dir/Videos/Movies/{n} ({y})/{n} ({y}) {vf} {resolution}" -r Videos/Movies
}

function Music(){
    echo "[+] Renaming Music"
    filebot -rename --db ${1:-ID3} -non-strict --lang en --encoding UTF-8 --action move -extract --format "$base_dir/Music/{n}/{artist}/{album}/{artist} - {t}" -r Music
}

# function This(){
#     filebot -rename --db "$db" -non-strict --lang en --encoding UTF-8 --action move -extract --format "$pwd/$format" "$args" "$pwd"
# }

# function PromptVal(){
#     read -r -p "" response
#     echo $val
# }

function CleanUp(){
    echo "[+] Cleaning all archives within library"
    python3 cleanup_helper.py
    # echo "[+] Cleaning all files under 20MB"
    # filebot -script fn:cleaner $base_dir/Videos/
    # filebot -script fn:cleaner $base_dir/Music/
    echo "[+] Removing all empty directories"
    find $base_dir -type d -empty -delete
    mkdir $base_dir/downloads &> /dev/null
    echo "[+] done"
}

function ArgParse(){
    cleanup_flag=1
    help_text="Usage : $0 [args]\n\v
    \t --cartoons|--tv|--movies|--music            \tRenames Predefined selection\n
    \t --this               \t\t\t\tRename custom selection (requires --db, --format)\n
    \t -V --videos          \t\t\t\tRenames all Videos [cartoons, tv shows, movies]\n
    \t -A --all             \t\t\t\tRenames All Media [cartoons, tv shows, movies, music]\n
    \t -h --help            \t\t\t\tOutputs this help and exits\n\n
    \t Args:                \t\t\t\t\tOptional Additional Args\n
    \t --db:                \t\t\t\t\tDatabase to use for operation(s) [Defaults to most sensible DB]\n
    \t --format             \t\t\t\tFormat for filename to be renamed too\n
    \t Databases:           \t\t\t\tTheTVDB, AniDB, TheMovieDB, AcoustID, ID3, xattr\n\n
       Examples:            \n
    \t $0 --other --db AniDB --format {plex}\n
    \t $0 --tv\n
    \t $0 -A"
    if [[ ${#} -eq 0 ]]; then
        echo -e $help_text; exit 0
    fi
    while [ ${#} != 0 ]; do
        case "${1}" in
            --anime) Anime_flag=1 ; shift;;
            --cartoon|--cartoons) Cartoons_flag=1 ; shift;;
            --tv) TV_flag=1 ; shift;;
            --movie|--movies) Movies_flag=1 ; shift;;
            --music) Music_flag=1; shift;;
            --this) This_flag=1; shift;;
            --db) db=$1; shift;;
            --path) target_path=$1; shift;;
            --format) format=$1; shift;;
            --noclean) cleanup_flag=0; shift;;
            --this|--here) db=$1; format=$2; shift 2; args=${*} ; shift ${#};;
            -V | --videos) Anime_flag=1; Cartoons_flag=1; TV_flag=1; Movies_flag=1; shift;;
            -A | --all) Anime_flag=1; Cartoons_flag=1; TV_flag=1; Movies_flag=1; Music_flag=1; break;;
            -h | --help) echo -e $help_text; exit 0;;
            *) echo "[!] Invalid Option: $1"; shift;;
        esac
    done
    # If target_path is undefined
    if [[ $VAR_STATUS -eq 0 ]]; then
        target_path=$(pwd)
    fi
}

function Main(){
    old_cwd=$(pwd)
    cd $base_dir || exit 1
    ArgParse "${@}"
    if [[ $Anime_flag -eq 1 ]]; then Anime; fi
    if [[ $Cartoons_flag -eq 1 ]]; then Cartoons; fi
    if [[ $TV_flag -eq 1 ]]; then TV; fi
    if [[ $Movies_flag -eq 1 ]]; then Movies; fi
    if [[ $Music_flag -eq 1 ]]; then Music; fi
    if [[ $cleanup_flag -eq 1 ]]; then CleanUp; fi
    if [[ $This_flag -eq 1 ]]; then This; fi
    cd "$old_cwd" || exit 1
}

Main "${@}"

