#!/bin/bash

#
# testing script for semestr work from subject BI-SKJ, FIT CVUT, 2013, summer semester
#
# the script takes an argument, which is full path of the script, which should be tested
#
#


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
    echo "ERROR: $i" >&2
  done

  echo "exitting"

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
  echo "testing $1 -$2 \"\""
  eval "$1 -$2 \"\"" 

  echo "testing $1 -$2 ''"
  eval "$1 -$2 ''"
}
#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------
  # we are only interested in the first passed argument, nothing more

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



