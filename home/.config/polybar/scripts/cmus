#!/bin/bash

cmusstatus=$(cmus-remote -C status)
grep position <<< "$cmusstatus" 1>/dev/null 2>&1
if [ ! $? -eq 0 ]; then exit; fi

strindex() {
  x="${1%%$2*}"
  [[ "$x" = "$1" ]] && echo -1 || echo "${#x}"
}

prepend_zero () {
    seq -f "%02g" $1 $1
}

get_all_but_first() {
  shift
  echo "$@"
}

get_stat() {
  line=$(grep "$1" -m 1 <<< "$cmusstatus")
  a=$(strindex "$line" "$1")
  sub="${line:a}"
  echo "$(get_all_but_first $sub)"
}

min_sec_from_sec() {
  echo -n "$(prepend_zero $(($1 / 60))):$(prepend_zero $(($1 % 60)))"
}

echo -n "$(get_stat artist)  -  $(get_stat title)  [$(min_sec_from_sec $(get_stat position)) / $(min_sec_from_sec $(get_stat duration))]"
