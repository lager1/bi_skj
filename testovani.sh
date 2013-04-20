#!/bin/bash

#
# testing script for semestr work from subject BI-SKJ, FIT CVUT, 2013, summer semester
#
# the script takes an argument, which is full path of the script, which should be tested
#
#






#-------------------------------------------------------------------------------
# function to print how to use this script
# parameters:
#   function takes no parameters
#-------------------------------------------------------------------------------
function usage()
{
  echo -e "\e[1;31musage: $0 [OPTION]... FILE... \e[0m" >&2    # print in red color
  exit 1;
}
#-------------------------------------------------------------------------------
# function for reporting information about script progress
# parameters:
#   function takes arbitrary number of arguments
# all of the parameters ale printed to the standart output
#-------------------------------------------------------------------------------
function verbose()
{
  for i in "$@"
  do
    echo -en "\e[1;32m$i \e[0m"       # print in green color 
  done
  echo ""
}
#-------------------------------------------------------------------------------
# function for error reporting
# parameters:
#   function takes arbitrary number of arguments
# all of the parameters are printed on the standard error output
# function subsequently exits the whole script with exit 1
#-------------------------------------------------------------------------------
function error()
{
  for i in "$@"
  do
    echo -e "\e[1;31mERROR: $i\e[0m" >&2    # print in red color
  done

  echo -e "\e[1;31mexitting\e[0m" >&2    # print in red color

  exit 1;
}
#-------------------------------------------------------------------------------
# function for checking the script parameters
# parameters:
#   1)full path of the script
#   2)the switch, which should be tested
# function passes an empty value to the switch
#-------------------------------------------------------------------------------
function switchTest1()
{
  if [[ "$DISPLAY" == "1" ]]
  then

    echo "testing $1 -$2 \"\""
    eval "$1 -$2 \"\"" 
    [[ "$?" == "1" ]] && FAIL=1

    echo "testing $1 -$2 ''"
    eval "$1 -$2 ''" 
    [[ "$?" == "1" ]] && FAIL=1

  else
    
    echo "testing $1 -$2 \"\"" &>/dev/null
    eval "$1 -$2 \"\"" &>/dev/null
    [[ "$?" == "1" ]] && FAIL=1

    echo "testing $1 -$2 ''" &>/dev/null
    eval "$1 -$2 ''" &>/dev/null
    [[ "$?" == "1" ]] && FAIL=1

  fi
}
#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------
  # we are only interested in the first and second passed argument, nothing more

  [[ $# -lt 1 ]] && usage     # print how to use

  while getopts ":d" opt  	# cycle for processing the switches
  do
    case "$opt" in
      d) DISPLAY=1;;
         
      \?) echo "accepted switches: d"; 	# undefined switch
		 exit 1;;
    esac
  done

  shift `expr $OPTIND - 1`	# posun na prikazove radce

  ! [[ -e "$1" ]] && error "provided script \"$1\" does not exist"
  ! [[ -f "$1" ]] && error "provided script \"$1\" is not a regular file"
  ! [[ -r "$1" ]] && error "provided script \"$1\" cannot be read"

  ! [[ "$1" =~ ^/.*$ ]] && error "provided script has ho be entered with full path"

  TEST="$1"
  SWITCHES="t X x Y y S T F c l g e f n v"
  
  for i in ${SWITCHES[@]}
  do
    switchTest1 "$TEST" "$i"
  done
  
  if [[ "$FAIL" == "1" ]] 
  then
    error "test \"switchTest1\" failed"
  else
    verbose "test \"switchTest1\" passed"
  fi




