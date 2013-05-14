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
#   1) full path of the script
#   2) the switch, which should be tested
# function passes an empty value to the switch
#-------------------------------------------------------------------------------
function switchTest1()
{
  if [[ "$DISPLAY" == "1" ]]
  then

    echo "testing $1 -$2 \"\""
    eval "$1 -$2 \"\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 ''"
    eval "$1 -$2 ''" 
    [[ "$?" == "0" ]] && FAIL=1

  else
    eval "$1 -$2 \"\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    eval "$1 -$2 ''" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

  fi
}
#-------------------------------------------------------------------------------
# function for checking the script parameters
# parameters:
#   1) full path of the script
#   2) the switch, which should be tested
# checking: matching timestamp and specific value
#-------------------------------------------------------------------------------
function switchTest2()
{
  if [[ "$DISPLAY" == "1" ]]
  then

    echo "testing $1 -t \"%H:%M:%S\" -$2 \"00:00:00 2012/01/01\""
    eval "$1 -t \"%H:%M:%S\" -$2 \"00:00:00 2012/01/01\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%H:%M:%S\" -$2 \"24:00:00\""
    eval "$1 -t \"%H:%M:%S\" -$2 \"24:00:00\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%H:%M:%S\" -$2 \"12:61:00\""
    eval "$1 -t \"%H:%M:%S\" -$2 \"12:61:00\"" 
    [[ "$?" == "0" ]] && FAIL=1
    
    echo "testing $1 -t \"%H:%M:%S\" -$2 \"12:59:61\""
    eval "$1 -t \"%H:%M:%S\" -$2 \"12:59:61\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%Y/%m/%d\" -$2 \"2012/13/01\""
    eval "$1 -t \"%Y/%m/%d\" -$2 \"2012/13/01\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%Y/%m/%d\" -$2 \"2012/12/32\""
    eval "$1 -t \"%Y/%m/%d\" -$2 \"2012/12/32\"" 
    [[ "$?" == "0" ]] && FAIL=1

  else

    echo "testing $1 -t \"%H:%M:%S\" -$2 \"00:00:00 2012/01/01\"" &>/dev/null
    eval "$1 -t \"%H:%M:%S\" -$2 \"00:00:00 2012/01/01\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%H:%M:%S\" -$2 \"24:00:00\"" &>/dev/null
    eval "$1 -t \"%H:%M:%S\" -$2 \"24:00:00\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%H:%M:%S\" -$2 \"12:61:00\"" &>/dev/null
    eval "$1 -t \"%H:%M:%S\" -$2 \"12:61:00\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1
    
    echo "testing $1 -t \"%H:%M:%S\" -$2 \"12:59:61\"" &>/dev/null
    eval "$1 -t \"%H:%M:%S\" -$2 \"12:59:61\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%Y/%m/%d\" -$2 \"2012/13/01\"" &>/dev/null
    eval "$1 -t \"%Y/%m/%d\" -$2 \"2012/13/01\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%Y/%m/%d\" -$2 \"2012/12/32\"" &>/dev/null
    eval "$1 -t \"%Y/%m/%d\" -$2 \"2012/12/32\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

  fi
}
#-------------------------------------------------------------------------------
# function for checking the script parameters
# parameters:
#   1) full path of the script
#   2) the switch, which should be tested
# checking: values of switches -Y and -y
#-------------------------------------------------------------------------------
function switchTest3()
{
  if [[ "$DISPLAY" == "1" ]]
  then

    echo "testing $1 -$2 \"-5,150\""
    eval "$1 -$2 \"-5,150\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"+5,150\""
    eval "$1 -$2 \"+5,150\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"-5.-5\""
    eval "$1 -$2 \"-5.-5\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"+5.+5\""
    eval "$1 -$2 \"+5.+5\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"-+5\""
    eval "$1 -$2 \"-+5\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"-+5\""
    eval "$1 -$2 \"-+5\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"automax\""
    eval "$1 -$2 \"automax\"" 
    [[ "$?" == "0" ]] && FAIL=1

  else

    echo "testing $1 -$2 \"-5,150\"" &>/dev/null
    eval "$1 -$2 \"-5,150\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"+5,150\"" &>/dev/null
    eval "$1 -$2 \"+5,150\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"-5.-5\"" &>/dev/null
    eval "$1 -$2 \"-5.-5\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"+5.+5\"" &>/dev/null
    eval "$1 -$2 \"+5.+5\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"-+5\"" &>/dev/null
    eval "$1 -$2 \"-+5\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"-+5\"" &>/dev/null
    eval "$1 -$2 \"-+5\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"automax\"" &>/dev/null
    eval "$1 -$2 \"automax\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

  fi
}
#-------------------------------------------------------------------------------
# function for checking the script parameters
# parameters:
#   1) full path of the script
#   2) the switch, which should be tested
# checking: values of switches -S, -T and -F
#-------------------------------------------------------------------------------
function switchTest4()
{
  if [[ "$DISPLAY" == "1" ]]
  then

    echo "testing $1 -$2 \"-5\""
    eval "$1 -$2 \"-5\"" 
    [[ "$?" == "0" ]] && fail=1

    echo "testing $1 -$2 \"+5,5\""
    eval "$1 -$2 \"+5,5\"" 
    [[ "$?" == "0" ]] && fail=1

    echo "testing $1 -$2 \"+5.+5\""
    eval "$1 -$2 \"+5.+5\"" 
    [[ "$?" == "0" ]] && fail=1

    echo "testing $1 -$2 \"0\""
    eval "$1 -$2 \"0\"" 
    [[ "$?" == "0" ]] && fail=1

    echo "testing $1 -$2 \"0.0\""
    eval "$1 -$2 \"0.0\"" 
    [[ "$?" == "0" ]] && fail=1

  else

    echo "testing $1 -$2 \"-5\"" &>/dev/null
    eval "$1 -$2 \"-5\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"+5,5\"" &>/dev/null
    eval "$1 -$2 \"+5,5\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"+5.+5\"" &>/dev/null
    eval "$1 -$2 \"+5.+5\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"0\"" &>/dev/null
    eval "$1 -$2 \"0\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"0.0\"" &>/dev/null
    eval "$1 -$2 \"0.0\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

  fi
}
#-------------------------------------------------------------------------------
# function for checking the script parameters
# parameters:
#   1) full path of the script
#   2) the switch, which should be tested
# checking: values of switch -c
#-------------------------------------------------------------------------------
function switchTest5()
{
  if [[ "$DISPLAY" == "1" ]]
  then

    echo "testing $1 -t \"%H:%M:%S\" -$2 \"y=+5,5\""
    eval "$1 -t \"%H:%M:%S\" -$2 \"+5,5\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%H:%M:%S\" -$2 \"x=24:00:00\""
    eval "$1 -t \"%H:%M:%S\" -$2 \"x=24:00:00\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%H:%M:%S\" -$2 \"x=12:61:00\""
    eval "$1 -t \"%H:%M:%S\" -$2 \"x=12:61:00\"" 
    [[ "$?" == "0" ]] && FAIL=1
    
    echo "testing $1 -t \"%H:%M:%S\" -$2 \"x=12:59:61\""
    eval "$1 -t \"%H:%M:%S\" -$2 \"x=12:59:61\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%Y/%m/%d\" -$2 \"x=2012/13/01\""
    eval "$1 -t \"%Y/%m/%d\" -$2 \"x=2012/13/01\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%Y/%m/%d\" -$2 \"x=2012/12/32\""
    eval "$1 -t \"%Y/%m/%d\" -$2 \"x=2012/12/32\"" 
    [[ "$?" == "0" ]] && FAIL=1

  else

    echo "testing $1 -t \"%H:%M:%S\" -$2 \"y=+5,5\"" &>/dev/null
    eval "$1 -t \"%H:%M:%S\" -$2 \"+5,5\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%H:%M:%S\" -$2 \"x=24:00:00\"" &>/dev/null
    eval "$1 -t \"%H:%M:%S\" -$2 \"x=24:00:00\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%H:%M:%S\" -$2 \"x=12:61:00\"" &>/dev/null
    eval "$1 -t \"%H:%M:%S\" -$2 \"x=12:61:00\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1
    
    echo "testing $1 -t \"%H:%M:%S\" -$2 \"x=12:59:61\"" &>/dev/null
    eval "$1 -t \"%H:%M:%S\" -$2 \"x=12:59:61\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%Y/%m/%d\" -$2 \"x=2012/13/01\"" &>/dev/null
    eval "$1 -t \"%Y/%m/%d\" -$2 \"x=2012/13/01\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -t \"%Y/%m/%d\" -$2 \"x=2012/12/32\"" &>/dev/null
    eval "$1 -t \"%Y/%m/%d\" -$2 \"x=2012/12/32\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

  fi
}
#-------------------------------------------------------------------------------
# function for checking the script parameters
# parameters:
#   1) full path of the script
#   2) the switch, which should be tested
# checking: values of switch -f
#-------------------------------------------------------------------------------
function switchTest6()
{
  if [[ "$DISPLAY" == "1" ]]
  then

    echo "testing $1 -$2 \"/abc\""
    eval "$1 -$2 \"/abc\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"/dev/null\""
    eval "$1 -$2 \"/dev/null\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"/etc/shadow\""
    eval "$1 -$2 \"/etc/shadow\"" 
    [[ "$?" == "0" ]] && FAIL=1

  else

    echo "testing $1 -$2 \"/abc\"" &>/dev/null
    eval "$1 -$2 \"/abc\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"/dev/null\"" &>/dev/null
    eval "$1 -$2 \"/dev/null\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "testing $1 -$2 \"/etc/shadow\"" &>/dev/null
    eval "$1 -$2 \"/etc/shadow\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

  fi
}
#-------------------------------------------------------------------------------
# function for checking the script parameters
# parameters:
#   1) full path of the script
#   2) data file
# checking: data files
#-------------------------------------------------------------------------------
function dataTest1()
{
  if [[ "$DISPLAY" == "1" ]]
  then

    echo "testing $1 \"$2\""
    eval "$1 \"$2\"" 
    [[ "$?" == "0" ]] && FAIL=1

  else
    echo "testing $1 \"$2\"" &>/dev/null
    eval "$1 \"$2\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

  fi
}
#-------------------------------------------------------------------------------
# function for checking the script parameters
# parameters:
#   1) full path of the script
#   2) directive, which should be tested
# checking: values of all directives - passes empty value
#-------------------------------------------------------------------------------
function configTest1()
{
  if [[ "$DISPLAY" == "1" ]]
  then

    echo "$2 " > "config"
    echo "testing echo \"$2\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

  else
    echo "$2 " > "config"
    echo "testing echo \"$2\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\"" &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

  fi
  rm config
}
#-------------------------------------------------------------------------------
# function for checking the script parameters
# parameters:
#   1) full path of the script
#   2) directive, which should be tested
# checking: values of directives Xmax and Xmin
#-------------------------------------------------------------------------------
function configTest2()
{
  if [[ "$DISPLAY" == "1" ]]
  then

    echo "$2 00:00:00 2012/01/01" > "config"
    echo "testing echo \"$2 00:00:00 2012/01/01\" > \"config\""
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 24:00:00" > "config"
    echo "testing echo \"$2 24:00:00\" > \"config\""
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 12:61:00" > "config"
    echo "testing echo \"$2 12:61:00\" > \"config\""
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 12:59:61" > "config"
    echo "testing echo \"$2 12:59:61\" > \"config\""
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 2012/13/01" > "config"
    echo "testing echo \"$2 2012/13/01\" > \"config\""
    echo "testing $1 -t \"%Y/%m/%d\" -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 2012/12/32" > "config"
    echo "testing echo \"$2 2012/12/32\" > \"config\""
    echo "testing $1 -t \"%Y/%m/%d\" -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

  else

    echo "$2 00:00:00 2012/01/01" > "config"
    echo "testing echo \"$2 00:00:00 2012/01/01\" > \"config\"" &>/dev/null
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 24:00:00" > "config"
    echo "testing echo \"$2 24:00:00\" > \"config\"" &>/dev/null
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 12:61:00" > "config"
    echo "testing echo \"$2 12:61:00\" > \"config\"" &>/dev/null
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 12:59:61" > "config"
    echo "testing echo \"$2 12:59:61\" > \"config\"" &>/dev/null
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 2012/13/01" > "config"
    echo "testing echo \"$2 2012/13/01\" > \"config\"" &>/dev/null
    echo "testing $1 -t \"%Y/%m/%d\" -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 2012/12/32" > "config"
    echo "testing echo \"$2 2012/12/32\" > \"config\"" &>/dev/null
    echo "testing $1 -t \"%Y/%m/%d\" -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

  fi
  rm config
}
#-------------------------------------------------------------------------------
# function for checking the script parameters
# parameters:
#   1) full path of the script
#   2) directive, which should be tested
# checking: values of directives Ymax and Ymin
#-------------------------------------------------------------------------------
function configTest3()
{
  if [[ "$DISPLAY" == "1" ]]
  then

    echo "$2 -5,150" > "config"
    echo "testing echo \"$2 -5,150\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 +5,150" > "config"
    echo "testing echo \"$2 +5,150\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 -5.-5" > "config"
    echo "testing echo \"$2 -5.-5\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 +5.+5" > "config"
    echo "testing echo \"$2 +5.+5\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 +-5" > "config"
    echo "testing echo \"$2 +-5\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 -+5" > "config"
    echo "testing echo \"$2 -+5\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 automax" > "config"
    echo "testing echo \"$2 automax\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

  else

    echo "$2 -5,150" > "config"
    echo "testing echo \"$2 -5,150\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 +5,150" > "config"
    echo "testing echo \"$2 +5,150\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 -5.-5" > "config"
    echo "testing echo \"$2 -5.-5\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 +5.+5" > "config"
    echo "testing echo \"$2 +5.+5\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 +-5" > "config"
    echo "testing echo \"$2 +-5\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 -+5" > "config"
    echo "testing echo \"$2 -+5\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 automax" > "config"
    echo "testing echo \"$2 automax\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

  fi
  rm config
}
#-------------------------------------------------------------------------------
# function for checking the script parameters
# parameters:
#   1) full path of the script
#   2) directive, which should be tested
# checking: values of directives Speed, Time and FPS
#-------------------------------------------------------------------------------
function configTest4()
{
  if [[ "$DISPLAY" == "1" ]]
  then

    echo "$2 -5" > "config"
    echo "testing echo \"$2 -5\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 +5,5" > "config"
    echo "testing echo \"$2 +5,5\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 +5.+5" > "config"
    echo "testing echo \"$2 +5.+5\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 0" > "config"
    echo "testing echo \"$2 0\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 0.0" > "config"
    echo "testing echo \"$2 0.0\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

  else

    echo "$2 -5" > "config"
    echo "testing echo \"$2 -5\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 +5,5" > "config"
    echo "testing echo \"$2 +5,5\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 +5.+5" > "config"
    echo "testing echo \"$2 +5.+5\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 0" > "config"
    echo "testing echo \"$2 0\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 0.0" > "config"
    echo "testing echo \"$2 0.0\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

  fi
  rm config
}
#-------------------------------------------------------------------------------
# function for checking the script parameters
# parameters:
#   1) full path of the script
#   2) directive, which should be tested
# checking: values of directive CriticalValue
#-------------------------------------------------------------------------------
function configTest5()
{
  if [[ "$DISPLAY" == "1" ]]
  then

    echo "$2 y=+5,5" > "config"
    echo "testing echo \"$2 y=+5,5\" > \"config\""
    echo "testing $1 -f \"config\""
    eval "$1 -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 x=24:00:00" > "config"
    echo "testing echo \"$2 x=24:00:00\" > \"config\""
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\""
    eval "$1 -t \"%H:%M:%S\" -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 x=12:61:00" > "config"
    echo "testing echo \"$2 x=12:61:00\" > \"config\""
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\""
    eval "$1 -t \"%H:%M:%S\" -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 x=12:59:61" > "config"
    echo "testing echo \"$2 x=12:59:61\" > \"config\""
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\""
    eval "$1 -t \"%H:%M:%S\" -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 x=2012/13/01" > "config"
    echo "testing echo \"$2 x=2012/13/01\" > \"config\""
    echo "testing $1 -t \"%Y/%m/%d\" -f \"config\""
    eval "$1 -t \"%Y/%m/%d\" -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 x=2012/12/32" > "config"
    echo "testing echo \"$2 x=2012/12/32\" > \"config\""
    echo "testing $1 -t \"%Y/%m/%d\" -f \"config\""
    eval "$1 -t \"%Y/%m/%d\" -f \"config\"" 
    [[ "$?" == "0" ]] && FAIL=1

  else

    echo "$2 y=+5,5" > "config"
    echo "testing echo \"$2 y=+5,5\" > \"config\"" &>/dev/null
    echo "testing $1 -f \"config\"" &>/dev/null
    eval "$1 -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 x=24:00:00" > "config"
    echo "testing echo \"$2 x=24:00:00\" > \"config\"" &>/dev/null
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\"" &>/dev/null
    eval "$1 -t \"%H:%M:%S\" -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 x=12:61:00" > "config"
    echo "testing echo \"$2 x=12:61:00\" > \"config\"" &>/dev/null
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\"" &>/dev/null
    eval "$1 -t \"%H:%M:%S\" -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 x=12:59:61" > "config"
    echo "testing echo \"$2 x=12:59:61\" > \"config\"" &>/dev/null
    echo "testing $1 -t \"%H:%M:%S\" -f \"config\"" &>/dev/null
    eval "$1 -t \"%H:%M:%S\" -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 x=2012/13/01" > "config"
    echo "testing echo \"$2 x=2012/13/01\" > \"config\"" &>/dev/null
    echo "testing $1 -t \"%Y/%m/%d\" -f \"config\"" &>/dev/null
    eval "$1 -t \"%Y/%m/%d\" -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

    echo "$2 x=2012/12/32" > "config"
    echo "testing echo \"$2 x=2012/12/32\" > \"config\"" &>/dev/null
    echo "testing $1 -t \"%Y/%m/%d\" -f \"config\"" &>/dev/null
    eval "$1 -t \"%Y/%m/%d\" -f \"config\""  &>/dev/null
    [[ "$?" == "0" ]] && FAIL=1

  fi
  rm config
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


  # create testing data file
  datafile="$(mktemp)"
  date +"%H:%M:%S 1" > $datafile 

  TEST="$1"
  SWITCHES="t X x Y y S T F c l g e f n"
  
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

  switchTest2 "$TEST" "X"
  switchTest2 "$TEST" "x"
  
  if [[ "$FAIL" == "1" ]] 
  then
    error "test \"switchTest2\" failed"
  else
    verbose "test \"switchTest2\" passed"
  fi

  switchTest3 "$TEST" "Y"
  switchTest3 "$TEST" "y"
  
  if [[ "$FAIL" == "1" ]] 
  then
    error "test \"switchTest3\" failed"
  else
    verbose "test \"switchTest3\" passed"
  fi

  switchTest4 "$TEST" "S"
  switchTest4 "$TEST" "T"
  switchTest4 "$TEST" "F"
  
  if [[ "$FAIL" == "1" ]] 
  then
    error "test \"switchTest4\" failed"
  else
    verbose "test \"switchTest4\" passed"
  fi

  switchTest5 "$TEST" "c"
  
  if [[ "$FAIL" == "1" ]] 
  then
    error "test \"switchTest5\" failed"
  else
    verbose "test \"switchTest5\" passed"
  fi

  switchTest6 "$TEST" "f"
  
  if [[ "$FAIL" == "1" ]] 
  then
    error "test \"switchTest6\" failed"
  else
    verbose "test \"switchTest6\" passed"
  fi

#-------------------------------------------------------------------------------

  DATA=("http://abc" "/abc" "/dev/null" "/etc/shadow")
  
  for i in ${DATA[@]}
  do
    dataTest1 "$TEST" "$i"
  done

  if [[ "$FAIL" == "1" ]] 
  then
    error "test \"dataTest1\" failed"
  else
    verbose "test \"dataTest1\" passed"
  fi

#-------------------------------------------------------------------------------

  DIRECTIVES=("TimeFormat" "Xmax" "Xmin" "Ymax" "Ymin" "Speed" "Time" "FPS" "CriticalValue" "Legend" "Name" "IgnoreErrors")

  for i in ${DIRECTIVES[@]}
  do
    configTest1 "$TEST" "$i"
  done

  if [[ "$FAIL" == "1" ]] 
  then
    error "test \"configTest1\" failed"
  else
    verbose "test \"configTest1\" passed"
  fi

  configTest2 "$TEST" "${DIRECTIVES[1]}"   # Xmax
  configTest2 "$TEST" "${DIRECTIVES[2]}"   # Xmin
  
  if [[ "$FAIL" == "1" ]] 
  then
    error "test \"configTest2\" failed"
  else
    verbose "test \"configTest2\" passed"
  fi

  configTest3 "$TEST" "${DIRECTIVES[3]}"   # Ymax
  configTest3 "$TEST" "${DIRECTIVES[4]}"   # Ymin
  
  if [[ "$FAIL" == "1" ]] 
  then
    error "test \"configTest3\" failed"
  else
    verbose "test \"configTest3\" passed"
  fi

  configTest4 "$TEST" "${DIRECTIVES[5]}"   # Speed
  configTest4 "$TEST" "${DIRECTIVES[6]}"   # Time
  configTest4 "$TEST" "${DIRECTIVES[7]}"   # FPS
  
  if [[ "$FAIL" == "1" ]] 
  then
    error "test \"configTest4\" failed"
  else
    verbose "test \"configTest4\" passed"
  fi

  configTest5 "$TEST" "${DIRECTIVES[8]}"   # CriticalValue
  
  if [[ "$FAIL" == "1" ]] 
  then
    error "test \"configTest5\" failed"
  else
    verbose "test \"configTest5\" passed"
  fi

  rm $datafile

