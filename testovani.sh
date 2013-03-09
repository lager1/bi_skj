#!/bin/bash

#
# testovaci skript pro semetralni praci z predmetu BI-SKJ, FIT CVUT, 2013, letni semestr
#
# skript bere jako parametr nazev skriptu, ktery ma byt otestovan
#
#

#-------------------------------------------------------------------------------
# funkce pro vypisovani chyb
# parametry:
#   funkce bere libovolny pocet parametru
# vsechny parametry jsou vypsany na standartni chybovy vystup
# funkce nasledne ukoncuje cely skript pomoci exit 1
#-------------------------------------------------------------------------------
function error()
{
  for i in "$@"
  do
    echo "ERROR: $i" >&2
  done

  echo "exitting"

  exit 1;
}

#-------------------------------------------------------------------------------
# funkce pro kontrolu prepinacu skriptu
# parametry:
#   funkce bere jeden argument - prepinac, ktery ma byt testovan
# funkce predava prepinaci prazdnout hodnotu
#-------------------------------------------------------------------------------
function switchTest1()
{
  eval "$1 -$2 \"\"" 
  eval "$1 -$2 \'\'"
#  eval "$1 -$2 \'\`\'"
}



#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------
  # zajima nas pouze prvni prednany argument, vic nic

  ! [[ -e "$1" ]] && error "provided script \"$1\" does not exist"
  ! [[ -f "$1" ]] && error "provided script \"$1\" is not a regular file"
  ! [[ -r "$1" ]] && error "provided script \"$1\" cannot be read"

  ! [[ "$1" =~ ^/.*$ ]] && error "provided script has ho be entered with full path"

  TEST="$1"
  SWITCHES="t X x Y y S T F l g e f n v"
  
  for i in ${SWITCHES[@]}
  do
    switchTest1 "$TEST" "$i"
  done



