#!/usr/bin/env bash

# JackofSpades707

#########
# (\_/) #
# (O O) #
# (   ) #
#########
username="jack"
password=$(sudo --user=$USER pass show crypt/l337)
dependencies=(rsync echo)
filename=$(hostname)-$(date "+%Y-%m-%d")
local_path=/home/$USER/tmp/$filename
mount_point="/mnt/drives/3TB"
backup_dir="$mount_point/backup"
excludes_array=()
flags=(verbose_flag quiet_flag upload_flag, no_confirm_flag)
while [ ${#} != 0 ]; do case "${1}" in
    -u|--user) username="${$2}" ; shift 2;;
    -x|--exclude) excludes_array+="\"${2}\""; shift 2;;
    -m|--mount-point) mount_point="${2}" ; shift 2;;
    -b|--backup-dir) backup_dir="${2}" ; shift 2;;
    -h|--help) helptext && exit 0 ;;
    -v|--verbose) verbose_flag=1 ; shift;;
    -q|--quiet) quiet_flag=1 ; shift;;
    --no-check) nocheck_flag=1 ; shift;;
    --no-confirm) no_confirm_flag=1 ; shift;;
esac ; done

if [[ $excludes_array == "" ]]; then
    excludes=$(echo --exclude={$(echo $excludes_array | tr " " ",")})
else
    excludes=$(echo --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/var/*","/lost+found","/home/jack/.local","/home/jack/.wine","/home/jack/Downloads","/home/jack/Videos","/home/jack/Music","/home/jack/vmware","/home/jack/tmp","/home/jack/.cache","/home/jack/VM"})
fi

err(){
    echo >&2 `tput bold; tput setaf 1`"[-] ERROR: ${*}"`tput sgr0` ; exit $1
}

warn(){
    echo >&2 `tput bold; tput setaf 1`"[!] WARNING: ${*}"`tput sgr0` && return 1
}

msg(){
    if [[ $quiet_flag -eq 0 ]]; then echo `tput bold; tput setaf 2`"[+] ${*}"`tput sgr0` ; fi && return 0
}

helptext(){
    echo -e """Usage: $0 [args]\n\v
    \t -x --exclude         \t\texcludes the directory from being backed up (takes 1 argument, can be used multiple times)
    \t -v --verbose         \t\toutputs additional information\n
    \t -q --quiet           \t\tsilences all msgs to stdout\n
    \t --no-check           \t\tskips checking free space on HDD\n
    \t --no-confirm         \t\taccepts all prompts without user interaction\n\n\n

    \t Example: ${0} -x ~/Downloads -x ~/Music -x ~/Videos
    """
}

runtime_check(){
    if whoami != "root" ; then
        err "Script must be run as root"
    fi
    for dep in $dependencies; do
        if is_installed $dep -eq 1; then err "$dep must be installed" ; fi
    done
}

is_installed(){
    # 0 = True, 1 = False
    which $1 &>/dev/null
    echo $?
}

define_pkgmngr(){
    pkgmngrs=(pacman apt yum rpm portage)
    for pkgmngr in $pkgmngrs; do
        if is_installed $pkgmngr
            then echo $pkgmngr && return 0
        fi
    done || warn "Failed to identify package manager"
}

check_free_space(){
    if [[ $nocheck_flag -eq 1 ]]; then return; fi
    free_space_on_drive=$(df --block-size=1 --output=avail $drive | tail -n 1)
    dry_run=$(rsync -r --dry-run --stats --human-readable "$excludes" / "$local_path" 2>/dev/null)
    backup_dir_size=$(echo "$dry_run" | grep -E 'Total file size:' | grep -o -E "[0-9].+[P|T|G|M|K]"'b')
    BACKUP_DIRECTORY_SIZE_BITS=$(echo "$backup_dir_size" | numfmt --from=iec)
    if [[ $verbose_flag -eq 1 ]]; then
        msg "$BACKUP_DIRECTORY_SIZE_BITS / $free_space_on_drive Will be used"
    fi
}

push_backup(){
    if [[ ! $nocheck_flag -eq 1 && $SPACE_NEEDED -gt $free_space_on_drive ]]; then
        err "Not enough Hard drive space!"
    fi
    mv "$local_path.tar.bz2.gpg" $backup_dir && msg "Transferring backup locally"
}

compress(){
    msg 'Compressing backup to archive' && 
        tar cfj "$local_path.tar.bz2" "$local_path" && 
        msg "archive created sucessfully, removing directory" && 
        rm -rf "$local_path" &>/dev/null &&
        return 0 || 
        err "Compression Failed"
}

encrypt(){
    msg "Encrypting Archive" && 
        sudo --user=jack gpg --yes --batch --passphrase="$password" -c "$local_path.tar.bz2" &&
        msg encrypted archive created sucessfully, removing unencrypted archive &&
        rm -rf "$local_path.tar.bz2" || 
        warn "Archive Encryption Failed"
}

backup_mysql(){
    DATABASE_BIN='mysql'
    DATABASES=('dspdb' 'flaskapp' 'mysql')
    DB_USER='root'
    DB_PASS=$(sudo -u jack pass show mysql/root)
    for db in "${DATABASES[@]}"; do
        mkdir -p "$local_path/extras/db/$db"
        FILE="$local_path/extras/db/$db/$(date +"%Y%m%d").sql"
        mysqldump --user root --password=$DB_PASS $db > $FILE
        if [[ $verbose_flag -eq 1 ]]; then
            echo "$FILE was created"
        fi
    done
}

backup_sysctl(){
    sysctl -a > $local_path/sysctl.output
}

db_vars(){
    DATABASE_BIN="$1"
    DB_USER=$2
    DB_PASS=$(pass show $DATABASE_BIN/$DB_USER)
    DATABASES=(${@}[3:])
}

backup(){
    if is_installed mysql -eq 0; then
        msg "Backing up Databases" && backup_mysql
    fi
    msg "Creating backup" &&
    rsync -aAX $excludes / "$local_path" --info=progress2 &&
    pacman -Q > "$local_path/extras/pkgs.log"
}

main(){
    rm -rf "$local_path" "$local_path.tar.bz2" "$local_path.tar.bz2.gpg"
    check_free_space
    backup
    compress
    encrypt
    push_backup
    if [ -e "$backup_dir/$filename" ]; then
        msg "Script ran sucessfully! :)"
    fi
    exit 0
}

main

