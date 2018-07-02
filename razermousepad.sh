#!/bin/zsh

error(){ 
    echo "[!] Error [!]" && exit 1 
}

parse_args(){
    key1="${1:-F21}"
    key2="${2:-F22}"
    key3="${3:-F23}"
    key4="${4:-F24}"
    key5="${5:-F25}"
    key6="${6:-F26}"
    key7="${7:-F27}"
    key8="${8:-F28}"
    key9="${9:-xkill}"
    key10="${10:-XF86AudioLowerVolume}"
    key11="${11:-XF86AudioMute}"
    key12="${12:-XF86AudioRaiseVolume}"
}

parse_args "${@}" || error

remote_id=$(
  xinput list |
  sed -n 's/.*Naga.*id=\([0-9]*\).*keyboard.*/\1/p'
)
[ "$remote_id" ] || error

mkdir -p /tmp/xkb/symbols || error
echo """xkb_symbols \"remote\" {
    key <AE01>   { [$key1, $key1] };
    key <AE02>   { [$key2, $key2] };
    key <AE03>   { [$key3, $key3] };
    key <AE04>   { [$key4, $key4] };
    key <AE05>   { [$key5, $key5] };
    key <AE06>   { [$key6, $key6] };
    key <AE07>   { [$key7, $key7] };
    key <AE08>   { [$key8, $key8] };
    key <AE09>   { [$key9, $key9] };
    key <AE10>   { [$key10, $key10] };
    key <AE11>   { [$key11, $key11] };
    key <AE12>   { [$key12, $key12] };
};""" > /tmp/xkb/symbols/custom || error

setxkbmap -device $remote_id -print | sed 's/\(xkb_symbols.*\)"/\1+custom(remote)"/' | xkbcomp -I/tmp/xkb -i $remote_id -synch - $DISPLAY 2>/dev/null || error

