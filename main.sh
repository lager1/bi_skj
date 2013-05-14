#!/bin/bash


#
#
# semester work from subject BI-SKJ, FIT CVUT, 2013, summer semester
#
# This script generates animation based on provided data files,
# additionaly its behavior can be affected by switches or by configuration file.
# Its possible to use both options together, if switch and corresponding
# directive are used, then switch is preffered.
#
#

# two more switches defined:
# switch -v ==> verbose
# switch -p ==> play


#-------------------------------------------------------------------------------
# function to print warning message
# parameters:
#   function takes arbitrary number of arguments
# all of the parameters ale printed to the standart output
#-------------------------------------------------------------------------------
function warning()
{
  echo -en "\e[1;33mWARNING: \e[0m"     # print in yellow color

  for i in "$@"
  do
    echo -en "\e[1;33m$i \e[0m"       # print in yellow color 
  done
  echo ""

  [[ "${CONFIG["E"]}" == "true" ]] && exit 2;
}
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
  (($VERBOSE)) || return
  
  echo -en "\e[1;32mVERBOSE: \e[0m"     # print in green color

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
# all of the parameters ale printed to the standart error output
# fuction subsequently exits the whole script with exit 1
#-------------------------------------------------------------------------------
function error()
{
  for i in "$@"
  do
    echo -e "\e[1;31mERROR: $i\e[0m" >&2    # print in red color
  done

  echo -e "\e[1;31mexitting\e[0m" >&2    # print in red color

  exit 2;
}
#-------------------------------------------------------------------------------
# function for reading and evaluation of parameters
# parameters:
#	1) "$@" - we process all of the switches passed to the script
# result of the processing is saved in the global variables
# when an error occurs it is sent to the error function
#-------------------------------------------------------------------------------
function readParams()
{
  local switches_idx=0      # indexing of $SWITCHES
  local gp_params_idx=0     # indexing of $GNUPLOTPARAMS
  local eff_params_idx=0    # indexing of $EFFECTPARAMS
  local crit_val_idx=0      # indexing of $CRITICALVALUES

  [[ $# -lt 1 ]] && usage     # print how to use

  while getopts ":t:X:x:Y:y:S:T:F:c:l:g:e:f:n:Evp" opt  	# cycle for processing the switches
  do
   case "$opt" in
      t) # TIMEFORM
		 [ -z "$OPTARG" ] && error "the value of the switch -t was not provided"
         [[ "$OPTARG" =~ %[dHjklmMSuUVwWyY] ]] || warning "make sure you have entered correct Timeformat, it does not contain any control sequences"
         SWITCHES[$((switches_idx++))]="t"	# save the processed switch
         CONFIG["t"]="$OPTARG";;            # save the argument of the switch

      X) # XMAX
		 [ -z "$OPTARG" ] && error "the value of the switch -X was not provided"
         
         if ! [[ "$OPTARG" == "auto" || "$OPTARG" == "max" ]] # none of acceptable text values
         then
           # there may be specific value, needs to be checked
           # first check if the format of the argument is correct, then check by date
           [[ "$OPTARG" =~ ^$(echo "${CONFIG["t"]}" | sed 's/\\/\\\\/g; s/\./\\./g; s/\[/\\[/g; s/\]/\\]/g; s/%d/(0\[1-9\]|\[1-2\]\[0-9\]|3\[0-1\])/g; s/%H/(\[0-1\]\[0-9\]|2\[0-3\])/g; s/%I/(0\[1-9\]|1\[0-2\])/g; s/%j/(00\[1-9\]|0\[0-9\]\[0-9\]|\[1-2\]\[0-9\]\[0-9\]|3\[0-5\]\[0-9\]|36\[0-6\])/g; s/%k/(\[0-9\]|1\[0-9\]|2\[0-3\])/g; s/%l/(\[0-9\]|1\[0-2\])/g; s/%m/(0\[1-9\]|1\[0-2\])/g; s/%M/(\[0-5\]\[0-9\]|60)/g; s/%S/(\[0-5\]\[0-9\]|60)/g; s/%u/\[1-7\]/g; s/%U/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%V/(0\[1-9\]|\[1-4\]\[0-9\]|5\[0-3\])/g; s/%w/\[0-6\]/g; s/%W/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%y/\[0-9\]\[0-9\]/g; s/%Y/(\[0-1\]\[0-9\]\[0-9\]\[0-9\]|200\[0-9\]|201\[0-3\])/g;')$ ]] || error "provided timestamp format and argument of the switch -X does not match"

         fi

         SWITCHES[$((switches_idx++))]="X"	# save the processed switch
         CONFIG["X"]="$OPTARG";;            # save the argument of the switch
      
      x) # XMIN 
		 [ -z "$OPTARG" ] && error "the value of the switch -x was not provided"

         if ! [[ "$OPTARG" == "auto" || "$OPTARG" == "min" ]] # none of acceptable text values
         then
           # there may be specific value, needs to be checked
           # first check if the format of the argument is correct, then check by date
           [[ "$OPTARG" =~ ^$(echo "${CONFIG["t"]}" | sed 's/\\/\\\\/g; s/\./\\./g; s/\[/\\[/g; s/\]/\\]/g; s/%d/(0\[1-9\]|\[1-2\]\[0-9\]|3\[0-1\])/g; s/%H/(\[0-1\]\[0-9\]|2\[0-3\])/g; s/%I/(0\[1-9\]|1\[0-2\])/g; s/%j/(00\[1-9\]|0\[0-9\]\[0-9\]|\[1-2\]\[0-9\]\[0-9\]|3\[0-5\]\[0-9\]|36\[0-6\])/g; s/%k/(\[0-9\]|1\[0-9\]|2\[0-3\])/g; s/%l/(\[0-9\]|1\[0-2\])/g; s/%m/(0\[1-9\]|1\[0-2\])/g; s/%M/(\[0-5\]\[0-9\]|60)/g; s/%S/(\[0-5\]\[0-9\]|60)/g; s/%u/\[1-7\]/g; s/%U/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%V/(0\[1-9\]|\[1-4\]\[0-9\]|5\[0-3\])/g; s/%w/\[0-6\]/g; s/%W/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%y/\[0-9\]\[0-9\]/g; s/%Y/(\[0-1\]\[0-9\]\[0-9\]\[0-9\]|200\[0-9\]|201\[0-3\])/g;')$ ]] || error "provided timestamp format and argument of the switch -x does not match"

         fi

         SWITCHES[$((switches_idx++))]="x"	# save the processed switch
         CONFIG["x"]="$OPTARG";;            # save the argument of the switch

      Y) # YMAX
		 [ -z "$OPTARG" ] && error "the value of the switch -Y was not provided"
		 ! [[ "$OPTARG" =~ ^-?[0-9]+$ || "$OPTARG" =~ ^-?[0-9]+\.[0-9]+$ || "$OPTARG" =~ ^\+?[0-9]+$ || "$OPTARG" =~ ^\+?[0-9]+\.[0-9]+$ || "$OPTARG" == "auto" || "$OPTARG" == "max" ]] && {  # none of acceptable values
		   error "wrong argument of the switch -Y"; }
         SWITCHES[$((switches_idx++))]="Y"	# save the processed switch
         CONFIG["Y"]="$OPTARG";;            # save the argument of the switch

      y) # YMIN
		 [ -z "$OPTARG" ] && error "the value of the switch -y was not provided"
		 ! [[ "$OPTARG" =~ ^-?[0-9]+$ || "$OPTARG" =~ ^-?[0-9]+\.[0-9]+$ || "$OPTARG" =~ ^\+?[0-9]+$ || "$OPTARG" =~ ^\+?[0-9]+\.[0-9]+$ || "$OPTARG" == "auto" || "$OPTARG" == "min" ]] && { # none of acceptable values
		   error "wrong argument of the switch -y"; }
         SWITCHES[$((switches_idx++))]="y"	# save the processed switch
         CONFIG["y"]="$OPTARG";;            # save the argument of the switch

      S) # SPEED
		 [ -z "$OPTARG" ] && error "the value of the switch -S was not provided"
		 ! [[ "$OPTARG" =~ ^\+?[1-9]([0-9])*$ || "$OPTARG" =~ ^\+?[1-9]([0-9])*\.[0-9]+$ || "$OPTARG" =~ ^\+?[0-9]+\.[1-9]([0-9])*$ || "$OPTARG" =~ ^\+?[0-9]+\.[0-9]*[1-9]$ ]] && {	# non-numeric value, should be int/float, must not be zero
		   error "wrong argument of the switch -S"; }
         SWITCHES[$((switches_idx++))]="S"	# save the processed switch
         CONFIG["S"]="$OPTARG";;            # save the argument of the switch

      T) # TIME
		 [ -z "$OPTARG" ] && error "the value of the switch -T was not provided"
		 ! [[ "$OPTARG" =~ ^\+?[1-9]([0-9])*$ || "$OPTARG" =~ ^\+?[1-9]([0-9])*\.[0-9]+$ || "$OPTARG" =~ ^\+?[0-9]+\.[1-9]([0-9])*$ || "$OPTARG" =~ ^\+?[0-9]+\.[0-9]*[1-9]$ ]] && {	# non-numeric value, should be int/float, must not be zero
		   error "wrong argument of the switch -T"; }
         SWITCHES[$((switches_idx++))]="T"	# save the processed switch
         CONFIG["T"]="$OPTARG";;            # save the argument of the switch

      F) # FPS
		 [ -z "$OPTARG" ] && error "the value of the switch -F was not provided"
		 ! [[ "$OPTARG" =~ ^\+?[1-9]([0-9])*$ || "$OPTARG" =~ ^\+?[1-9]([0-9])*\.[0-9]+$ || "$OPTARG" =~ ^\+?[0-9]+\.[1-9]([0-9])*$ || "$OPTARG" =~ ^\+?[0-9]+\.[0-9]*[1-9]$ ]] && {	# non-numeric value, should be int/float, must not be zero
		   error "wrong argument of the switch -F"; }
         SWITCHES[$((switches_idx++))]="F"	# save the processed switch
         CONFIG["F"]="$OPTARG";;            # save the argument of the switch

      c) # CRITICALVALUE
		 [ -z "$OPTARG" ] && error "the value of the switch -c was not provided"
         
         for i in $(echo "$OPTARG" | sed 's/:x=/ x=/g; s/:y=/ y=/g')
         do

           if [[ "$i" =~ x= ]]  # check x, x values are in format defined by Timeformat
           then
             tmp="$(echo "${CONFIG["t"]}" | sed 's/\\/\\\\/g; s/\./\\./g; s/\[/\\[/g; s/\]/\\]/g; s/%d/(0\[1-9\]|\[1-2\]\[0-9\]|3\[0-1\])/g; s/%H/(\[0-1\]\[0-9\]|2\[0-3\])/g; s/%I/(0\[1-9\]|1\[0-2\])/g; s/%j/(00\[1-9\]|0\[0-9\]\[0-9\]|\[1-2\]\[0-9\]\[0-9\]|3\[0-5\]\[0-9\]|36\[0-6\])/g; s/%k/(\[0-9\]|1\[0-9\]|2\[0-3\])/g; s/%l/(\[0-9\]|1\[0-2\])/g; s/%m/(0\[1-9\]|1\[0-2\])/g; s/%M/(\[0-5\]\[0-9\]|60)/g; s/%S/(\[0-5\]\[0-9\]|60)/g; s/%u/\[1-7\]/g; s/%U/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%V/(0\[1-9\]|\[1-4\]\[0-9\]|5\[0-3\])/g; s/%w/\[0-6\]/g; s/%W/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%y/\[0-9\]\[0-9\]/g; s/%Y/(\[0-1\]\[0-9\]\[0-9\]\[0-9\]|200\[0-9\]|201\[0-3\])/g;')$"

             [[ "$i" =~ ^x=$tmp$ ]] || error "wrong argument of the switch -c"

           else
             # check y
             ! [[ "$i" =~ ^y=\+?[0-9]+$  || "$i" =~ ^y=\+?[0-9]+\.[0-9]+$ || "$i" =~ ^y=-?[0-9]+$ || "$i" =~ ^y=-?[0-9]+\.[0-9]+$ ]] && error "wrong argument of the switch -c"
           fi

           CRITICALVALUES[$((crit_val_idx++))]="$i" # save the argument of the switch

           if [[ "${CONFIG["c"]}" == "" ]]
           then
             CONFIG["c"]="${CONFIG["c"]}$i"              # save the argument of the switch, this way it can be displayed by verbose
           else
             CONFIG["c"]="${CONFIG["c"]} $i"             # save the argument of the switch, this way it can be displayed by verbose
           fi

         done
         
         ! [[ "${SWITCHES[@]}" =~ c ]] &&	# check if this particular switch was processed on the command line, do not save duplicit values
           SWITCHES[$((switches_idx++))]="c";;	# save the processed switch

      l) # LEGEND		 
		 [ -z "$OPTARG" ] && error "the value of the switch -l was not provided"
         SWITCHES[$((switches_idx++))]="l"	# save the processed switch
         CONFIG["l"]="$OPTARG";;            # save the argument of the switch

      g) # GNUPLOTPARAMS
		 [ -z "$OPTARG" ] && error "the value of the switch -g was not provided"

         if [[ "${CONFIG["g"]}" == "" ]]
         then
           CONFIG["g"]="${CONFIG["g"]}$OPTARG"              # save the argument of the switch, this way it can be displayed by verbose
         else
           CONFIG["g"]="${CONFIG["g"]} $OPTARG"              # save the argument of the switch, this way it can be displayed by verbose
         fi

		 GNUPLOTPARAMS[$((gp_params_idx++))]="$OPTARG" # save the argument of the switch, no value check needed
         ! [[ "${SWITCHES[@]}" =~ g ]] &&	# check if this particular switch was processed on the command line, do not save duplicit values
           SWITCHES[$((switches_idx++))]="g";;	# save the processed switch
   
      e) # EFFECTPARAMS
		 [ -z "$OPTARG" ] && error "the value of the switch -e was not provided"
		 OPTARG="$(echo "$OPTARG" | tr ":" " ")"	# change the seperator to space so we could iterate
		 for i in $OPTARG
		 do
		   ! [[ "$i" =~ ^bounce$ || "$i" =~ ^factor=[5-9]$ ]] && { # check the argument value
             error "wrong argument of the switch -e"; }
		   EFFECTPARAMS[$((eff_params_idx++))]="$i"	# save the argument of the switch or a part of it
           [[ "$i" =~ ^factor=[5-9]$ ]] && FACTOR="$(echo "$i" | sed 's/factor=//')"
	     done
         SWITCHES[$((switches_idx++))]="e";;	# save the processed switch
		 
      f) # CONFIG
		 [ -z "$OPTARG" ] && error "the value of the switch -f was not provided"
		 ! [ -e $OPTARG ] && error "provided configuration file \"$OPTARG\" does not exist"
		 ! [ -f $OPTARG ] && error "provided configuration file \"$OPTARG\" is not a regular file"
		 ! [ -r $OPTARG ] && error "provided configuration file \"$OPTARG\" cannot be read"

         SWITCHES[$((switches_idx++))]="f"	# save the processed switch
         CONFIG["f"]="$OPTARG";;            # save the argument of the switch

      n) # NAME
		 [ -z "$OPTARG" ] && error "the value of the switch -n was not provided"
         SWITCHES[$((switches_idx++))]="n"	# save the processed switch
         CONFIG["n"]="$OPTARG";;            # save the argument of the switch

      E) # IGNOREERRORS
         SWITCHES[$((switches_idx++))]="E"	# save the processed switch
         CONFIG["E"]="false";;

      v) # VERBOSE
         SWITCHES[$((switches_idx++))]="v"	# save the processed switch
         CONFIG["v"]="1"
         VERBOSE=1;;                        # set the value of global variable

      p) # PLAY
         SWITCHES[$((switches_idx++))]="p"	# save the processed switch
         CONFIG["p"]="1"
         PLAY=1;;                           # set the value of global variable

     \?) echo "accepted switches: t, X, x, Y, y, S, T, F, c, l, g, e, f, n, v"; 	# undefined switch
		 exit 2;;
   esac
  done
}
#-------------------------------------------------------------------------------
# function for checking data files
#	1) "$@" - all remaining arguments, which vere provided on execution - data files
# function checks if the files exist and if they are readable
# result of the processing is saved in the global variables
# if the files are on the web, they are downloaded to temporary files
# checks if the files are continuous
#-------------------------------------------------------------------------------
function checkFiles()
{
  local data_idx=0      # index for data files

  [[ -z "$1" ]] && error "no data files were provided"

  for i in "$@"
  do
    if [[ "$i" =~ ^http://.*$|^https://.*$ ]]     # the file is somewhere on the web
    then
      local tmp
      local st
      tmp=`mktemp` # create a temporary file to save the data
      
      wget -q -O "$tmp" "$i"    # download
      
      if [[ "$?" -eq 0 ]]       # check return code
      then
        verbose "file \"$i\" downloaded as \"$tmp\""
        DATA[$((data_idx++))]="$tmp"  # provided data file is ok
      else
        st=$(wget -O "$tmp" "$i" 2>&1)
        error "an error occured when downloading the file, details:\n$st"
      fi
    
    else
      ! [[ -e "$i" ]] && error "provided data file \"$i\" does not exist"
      ! [[ -f "$i" ]] && error "provided data file \"$i\" is not a regular file"
      ! [[ -r "$i" ]] && error "provided data file \"$i\" cannot be read"
        
      DATA[$((data_idx++))]="$i"  # provided data file is ok
    fi

  done

  # need to check, that the provided timestamp matches the data file

  local words=$(head -1 ${DATA[0]} | wc -w)

  # check if the provided TimeFormat is equal with the timestamp in the data file

  [[ "$(cat "${DATA[0]}" | cut -d " " -f1-$((words -1)) | tr "\n" " ")" =~ ^($(echo "${CONFIG["t"]}" | sed 's/\\/\\\\/g; s/\./\\./g; s/\[/\\[/g; s/\]/\\]/g; s/%d/(0\[1-9\]|\[1-2\]\[0-9\]|3\[0-1\])/g; s/%H/(\[0-1\]\[0-9\]|2\[0-3\])/g; s/%I/(0\[1-9\]|1\[0-2\])/g; s/%j/(00\[1-9\]|0\[0-9\]\[0-9\]|\[1-2\]\[0-9\]\[0-9\]|3\[0-5\]\[0-9\]|36\[0-6\])/g; s/%k/(\[0-9\]|1\[0-9\]|2\[0-3\])/g; s/%l/(\[0-9\]|1\[0-2\])/g; s/%m/(0\[1-9\]|1\[0-2\])/g; s/%M/(\[0-5\]\[0-9\]|60)/g; s/%S/(\[0-5\]\[0-9\]|60)/g; s/%u/\[1-7\]/g; s/%U/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%V/(0\[1-9\]|\[1-4\]\[0-9\]|5\[0-3\])/g; s/%w/\[0-6\]/g; s/%W/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%y/\[0-9\]\[0-9\]/g; s/%Y/(\[0-1\]\[0-9\]\[0-9\]\[0-9\]|200\[0-9\]|201\[0-3\])/g;') )+$ ]] || error "provided TimeFormat and timestamp in data file \"${DATA[0]}\" does not match"

  # cant check specific dates with only regex, but should be enough

  if [[ $# -gt 1 ]]
  then

    local ret

    for i in "${DATA[@]}"
    do
      [[ $(wc -l < "${DATA[0]}") -ne $(wc -l < "$i") ]] && { MULTIPLOT="false"; return; }

      [[ "$(cat "$i" | cut -d " " -f1-$((words -1)) | tr "\n" " ")" =~ ^($(echo "${CONFIG["t"]}" | sed 's/\\/\\\\/g; s/\./\\./g; s/\[/\\[/g; s/\]/\\]/g; s/%d/(0\[1-9\]|\[1-2\]\[0-9\]|3\[0-1\])/g; s/%H/(\[0-1\]\[0-9\]|2\[0-3\])/g; s/%I/(0\[1-9\]|1\[0-2\])/g; s/%j/(00\[1-9\]|0\[0-9\]\[0-9\]|\[1-2\]\[0-9\]\[0-9\]|3\[0-5\]\[0-9\]|36\[0-6\])/g; s/%k/(\[0-9\]|1\[0-9\]|2\[0-3\])/g; s/%l/(\[0-9\]|1\[0-2\])/g; s/%m/(0\[1-9\]|1\[0-2\])/g; s/%M/(\[0-5\]\[0-9\]|60)/g; s/%S/(\[0-5\]\[0-9\]|60)/g; s/%u/\[1-7\]/g; s/%U/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%V/(0\[1-9\]|\[1-4\]\[0-9\]|5\[0-3\])/g; s/%w/\[0-6\]/g; s/%W/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%y/\[0-9\]\[0-9\]/g; s/%Y/(\[0-1\]\[0-9\]\[0-9\]\[0-9\]|200\[0-9\]|201\[0-3\])/g;') )+$ ]] || error "provided TimeFormat and timestamp in data file \"$i\" does not match"  
      
      ret=$(diff <(cat ${DATA[0]} | cut -d" " -f1-$((words - 1))) <(cat $i | cut -d" " -f1-$((words - 1))))
      [[ "$ret" != "" ]] && { MULTIPLOT="false"; return; }  # timestamps in data files does not match each other
    done
  
  else
    MULTIPLOT="false"
    return
  fi
  
  MULTIPLOT="true"
}
#-------------------------------------------------------------------------------
# fucntion for reading the configuration file
# parameters:
#	1) the configuration file
# the result of the processing is saved in the global variables
# when an error occurs it is sent to the error function
#-------------------------------------------------------------------------------
function readConfig()
{
  [[ "${CONFIG["f"]}" != "" ]] || return;        # configuration file was not provided
  [[ $(wc -l < "${CONFIG["f"]}") -eq 0 ]] && { warning "provided configuration file \"${CONFIG["f"]}\" is empty"; return; } # empty configuration file

  local ret             # for checking values of the directives
  local directives=0    # number of processed directives

  # ==================================
  # TIMEFORMAT
  if ! [[ "${SWITCHES[@]}" =~ t || "$(grep -i "^[^#]*TimeFormat .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then
   
    ret=$(sed -n '/^[^#]*TimeFormat /Ip' "$1" | sed -n 's/^.*TimeFormat/TimeFormat/I; s/TimeFormat[[:space:]]*/TimeFormat /; s/TimeFormat //; s/[[:space:]]*#.*$//; $p')
    [[ "$ret" == "" ]] && error "value of the directive TimeFormat was not provided in the configuration file \"$1\""
    
    [[ "$ret" =~ %[dHjklmMSuUVwWyY] ]] || warning "make sure you have entered correct Timeformat, it does not contain any control sequences"

    CONFIG["t"]="$ret"
    ((directives++))
    verbose "value of the TimeFormat directive: $ret"
  fi

  # ==================================
  #XMAX
  if ! [[ "${SWITCHES[@]}" =~ X || "$(grep -i "^[^#]*Xmax .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then
    ret=$(sed -n '/^[^#]*Xmax /Ip' "$1" | sed -n 's/^.*Xmax/Xmax/I; s/Xmax[[:space:]]*/Xmax /; s/Xmax //; s/[[:space:]]*#.*$//; $p')

    [[ "$ret" == "" ]] && error "value of the Xmax directive was not provided in the configuration file \"$1\""

    if ! [[ "$ret" == "auto" || "$ret" == "max" ]] # none of acceptable text values
    then
      # there may be specific value, needs to be checked
      # first check if the format of the argument is correct, then check by date

      [[ "$ret" =~ ^$(echo "${CONFIG["t"]}" | sed 's/\\/\\\\/g; s/\./\\./g; s/\[/\\[/g; s/\]/\\]/g; s/\\/\\\\/g; s/%d/(0\[1-9\]|\[1-2\]\[0-9\]|3\[0-1\])/g; s/%H/(\[0-1\]\[0-9\]|2\[0-3\])/g; s/%I/(0\[1-9\]|1\[0-2\])/g; s/%j/(00\[1-9\]|0\[0-9\]\[0-9\]|\[1-2\]\[0-9\]\[0-9\]|3\[0-5\]\[0-9\]|36\[0-6\])/g; s/%k/(\[0-9\]|1\[0-9\]|2\[0-3\])/g; s/%l/(\[0-9\]|1\[0-2\])/g; s/%m/(0\[1-9\]|1\[0-2\])/g; s/%M/(\[0-5\]\[0-9\]|60)/g; s/%S/(\[0-5\]\[0-9\]|60)/g; s/%u/\[1-7\]/g; s/%U/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%V/(0\[1-9\]|\[1-4\]\[0-9\]|5\[0-3\])/g; s/%w/\[0-6\]/g; s/%W/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%y/\[0-9\]\[0-9\]/g; s/%Y/(\[0-1\]\[0-9\]\[0-9\]\[0-9\]|200\[0-9\]|201\[0-3\])/g;')$ ]] || error "provided timestamp format and argument of the Xmax directive in the configuration file \"$1\" does not match"

    fi
    
    CONFIG["X"]="$ret"
    ((directives++))
    verbose "value of the Xmax directive: $ret"
  fi
  
  # ==================================
  #XMIN
  if ! [[ "${SWITCHES[@]}" =~ x || "$(grep -i "^[^#]*Xmin .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then
    ret=$(sed -n '/^[^#]*Xmin /Ip' "$1" | sed -n 's/^.*Xmin/Xmin/I; s/Xmin[[:space:]]*/Xmin /; s/Xmin //; s/[[:space:]]*#.*$//; $p')

    [[ "$ret" == "" ]] && error "value of the Xmin directive was not provided in the configuration file \"$1\""

    if ! [[ "$ret" == "auto" || "$ret" == "min" ]] # none of acceptable text values
    then
      # there may be specific value, needs to be checked
      # first check if the format of the argument is correct, then check by date
      [[ "$ret" =~ ^$(echo "${CONFIG["t"]}" | sed 's/\\/\\\\/g; s/\./\\./g; s/\[/\\[/g; s/%d/(0\[1-9\]|\[1-2\]\[0-9\]|3\[0-1\])/g; s/%H/(\[0-1\]\[0-9\]|2\[0-3\])/g; s/%I/(0\[1-9\]|1\[0-2\])/g; s/%j/(00\[1-9\]|0\[0-9\]\[0-9\]|\[1-2\]\[0-9\]\[0-9\]|3\[0-5\]\[0-9\]|36\[0-6\])/g; s/%k/(\[0-9\]|1\[0-9\]|2\[0-3\])/g; s/%l/(\[0-9\]|1\[0-2\])/g; s/%m/(0\[1-9\]|1\[0-2\])/g; s/%M/(\[0-5\]\[0-9\]|60)/g; s/%S/(\[0-5\]\[0-9\]|60)/g; s/%u/\[1-7\]/g; s/%U/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%V/(0\[1-9\]|\[1-4\]\[0-9\]|5\[0-3\])/g; s/%w/\[0-6\]/g; s/%W/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%y/\[0-9\]\[0-9\]/g; s/%Y/(\[0-1\]\[0-9\]\[0-9\]\[0-9\]|200\[0-9\]|201\[0-3\])/g;')$ ]] || error "provided timestamp format and argument of the Xmin directive in the configuration file \"$1\" does not match"

    fi
    
    CONFIG["x"]="$ret"
    ((directives++))
    verbose "value of the Xmin directive: $ret"
  fi

  # ==================================
  # YMAX
  if ! [[ "${SWITCHES[@]}" =~ Y || "$(grep -i "^[^#]*Ymax .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then
    
    ret=$(sed -n '/^[^#]*Ymax /Ip' "$1" | sed -n 's/^.*Ymax/Ymax/I; s/Ymax[[:space:]]*/Ymax /; s/Ymax //; s/[[:space:]]*#.*$//; $p')

    [[ "$ret" == "" ]] && error "value of the Ymax directive was not provided in the configuration file \"$1\""
    ! [[ "$ret" =~ ^-?[0-9]+$ || "$ret" =~ ^-?[0-9]+\.[0-9]+$ || "$ret" =~ ^\+?[0-9]+$ || "$ret" =~ ^\+?[0-9]+\.[0-9]+$ || "$ret" == "auto" || "$ret" == "max" ]] && {  # none of acceptable values
      error "wrong argument of the Ymax directive in configuration file \"$1\""; }

    CONFIG["Y"]="$ret"
    ((directives++))
    verbose "value of the directive Ymax: $ret"
  fi

  # ==================================
  # YMIN
  if ! [[ "${SWITCHES[@]}" =~ y || "$(grep -i "^[^#]*Ymin .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then

    ret=$(sed -n '/^[^#]*Ymin /Ip' "$1" | sed -n 's/^.*Ymin/Ymin/I; s/Ymin[[:space:]]*/Ymin /; s/Ymin //; s/[[:space:]]*#.*$//; $p')

    [[ "$ret" == "" ]] && error "value of the Ymin directive was not provided in the configuration file \"$1\""
    ! [[ "$ret" =~ ^-?[0-9]+$ || "$ret" =~ ^-?[0-9]+\.[0-9]+$ || "$ret" =~ ^\+?[0-9]+$ || "$ret" =~ ^\+?[0-9]+\.[0-9]+$ || "$ret" == "auto" || "$ret" == "min" ]] && {  # none of acceptable values
      error "wrong argument of the Ymin directive in configuration file \"$1\""; }
    
    CONFIG["y"]="$ret"
    ((directives++))
    verbose "value of the directive Ymin: $ret"
  fi

  # ==================================
  # SPEED
  if ! [[ "${SWITCHES[@]}" =~ S || "$(grep -i "^[^#]*Speed .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then
    ret=$(sed -n '/^[^#]*Speed /Ip' "$1" | sed -n 's/^.*Speed/Speed/I; s/Speed[[:space:]]*/Speed /; s/Speed //; s/[[:space:]]*#.*$//; $p')

    [[ "$ret" == "" ]] && error "value of the Speed directive was not provided in the configuration file \"$1\""


    ! [[ "$ret" =~ ^\+?[1-9]([0-9])*$ || "$ret" =~ ^\+?[1-9]([0-9])*\.[0-9]+$ || "$ret" =~ ^\+?[0-9]+\.[1-9]([0-9])*$ || "$ret" =~ ^\+?[0-9]+\.[0-9]*[1-9]$ ]] && {	# non-numeric value, should be int/float, must not be zero
      error "wrong argument of the Speed directive in configuration file \"$1\""; }
    
    CONFIG["S"]="$ret"
    ((directives++))
    verbose "value of the directive Speed: $ret"
  fi

  # ==================================
  # TIME
  if ! [[ "${SWITCHES[@]}" =~ T || "$(grep -i "^[^#]*Time .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then
    ret=$(sed -n '/^[^#]*Time /Ip' "$1" | sed -n 's/^.*Time/Time/I; s/Time[[:space:]]*/Time /; s/Time //; s/[[:space:]]*#.*$//; $p')
    
    [[ "$ret" == "" ]] && error "value of the Time directive was not provided in the configuration file \"$1\""
    ! [[ "$ret" =~ ^\+?[1-9]([0-9])*$ || "$ret" =~ ^\+?[1-9]([0-9])*\.[0-9]+$ || "$ret" =~ ^\+?[0-9]+\.[1-9]([0-9])*$ || "$ret" =~ ^\+?[0-9]+\.[0-9]*[1-9]$ ]] && {	# non-numeric value, should be int/float, must not be zero
      error "wrong argument of the Time directive in configuration file \"$1\""; }

    CONFIG["T"]="$ret"
    ((directives++))
    verbose "value of the directive Time: $ret"
  fi

  # ==================================
  # FPS
  if ! [[ "${SWITCHES[@]}" =~ F || "$(grep -i "^[^#]*FPS .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then
    ret=$(sed -n '/^[^#]*FPS /Ip' "$1" | sed -n 's/^.*FPS/FPS/I; s/FPS[[:space:]]*/FPS /; s/FPS //; s/[[:space:]]*#.*$//; $p')
  
    [[ "$ret" == "" ]] && error "value of the FPS directive was not provided in the configuration file \"$1\""
    ! [[ "$ret" =~ ^\+?[1-9]([0-9])*$ || "$ret" =~ ^\+?[1-9]([0-9])*\.[0-9]+$ || "$ret" =~ ^\+?[0-9]+\.[1-9]([0-9])*$ || "$ret" =~ ^\+?[0-9]+\.[0-9]*[1-9]$ ]] && {	# non-numeric value, should be int/float, must not be zero
      error "wrong argument of the FPS directive in configuration file \"$1\""; }

    CONFIG["F"]="$ret"
    ((directives++))
    verbose "value of the directive FPS: $ret"
  fi

  # ==================================
  # CRITICALVALUE
  if ! [[ "$(grep -i "^[^#]*CriticalValue .*$" "$1")" == "" ]]	# check if the directive was provided in the configuration file
  then
    ret=$(sed -n '/^[^#]*CriticalValue /Ip' "$1" | sed -n 's/^.*CriticalValue/CriticalValue/I; s/CriticalValue[[:space:]]*/CriticalValue /; s/CriticalValue //; s/[[:space:]]*#.*$//; $p')
  
    [[ "$ret" == "" ]] && error "value of the CriticalValue directive was not provided in the configuration file \"$1\""
    
    for i in $(echo "$ret" | sed 's/:x=/ x=/; s/:y=/ y=/')
    do

      # check both x and y, x values are in format defined by Timeformat
      ! [[ "$i" =~ ^y=\+?[0-9]+$  || "$i" =~ ^y=\+?[0-9]+\.[0-9]+$ || "$i" =~ ^y=-?[0-9]+$ || "$i" =~ ^y=-?[0-9]+\.[0-9]+$ || "$i" =~ ^x="$(echo "${CONFIG["t"]}" | sed 's/\\/\\\\/g; s/\./\\./g; s/\[/\\[/g; s/%d/(0\[1-9\]|\[1-2\]\[0-9\]|3\[0-1\])/g; s/%H/(\[0-1\]\[0-9\]|2\[0-3\])/g; s/%I/(0\[1-9\]|1\[0-2\])/g; s/%j/(00\[1-9\]|0\[0-9\]\[0-9\]|\[1-2\]\[0-9\]\[0-9\]|3\[0-5\]\[0-9\]|36\[0-6\])/g; s/%k/(\[0-9\]|1\[0-9\]|2\[0-3\])/g; s/%l/(\[0-9\]|1\[0-2\])/g; s/%m/(0\[1-9\]|1\[0-2\])/g; s/%M/(\[0-5\]\[0-9\]|60)/g; s/%S/(\[0-5\]\[0-9\]|60)/g; s/%u/\[1-7\]/g; s/%U/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%V/(0\[1-9\]|\[1-4\]\[0-9\]|5\[0-3\])/g; s/%w/\[0-6\]/g; s/%W/(\[0-4\]\[0-9\]|5\[0-3\])/g; s/%y/\[0-9\]\[0-9\]/g; s/%Y/(\[0-1\]\[0-9\]\[0-9\]\[0-9\]|200\[0-9\]|201\[0-3\])/g;')"$ ]] && error "wrong argument of the CriticalValue directive in configuration file \"$1\""

      CRITICALVALUES[$((${#CRITICALVALUES[@]} + 1))]="$i" # save the argument of the directive
      
      if [[ "${CONFIG["c"]}" == "" ]]
      then
        CONFIG["c"]="${CONFIG["c"]}$i"               # save the argument of the switch, this way it can be displayed by verbose
      else
        CONFIG["c"]="${CONFIG["c"]} $i"              # save the argument of the switch, this way it can be displayed by verbose
      fi

    done
    
    ((directives++))
    verbose "value of the directive CriticalValue: $ret"
  fi

  # ==================================
  # LEGEND
  if ! [[ "${SWITCHES[@]}" =~ l || "$(grep -i "^[^#]*Legend .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then
    ret=$(sed -n '/^[^#]*Legend /Ip' "$1" | sed -n 's/^.*Legend/Legend/I; s/Legend[[:space:]]*/Legend /; s/Legend //; s/[[:space:]]*#.*$//; $p')
  
    [[ "$ret" == "" ]] && error "value of the Legend directive was not provided in the configuration file \"$1\""
    CONFIG["l"]="$ret"
    ((directives++))
    verbose "value of the directive Legend: $ret"
  fi

  # ==================================
  # GNUPLOTPARAMS
  if ! [[ "$(grep -i "^[^#]*GnuplotParams .*$" "$1")" == "" ]]	# check if the directive was provided in the configuration file
  then
    ret=$(sed -n '/^[^#]*GnuplotParams /Ip' "$1" | sed -n 's/^.*GnuplotParams/GnuplotParams/I; s/GnuplotParams[[:space:]]*/GnuplotParams /; s/GnuplotParams //; s/[[:space:]]*#.*$//; $p')

    [[ "$ret" == "" ]] && error "value of the GnuplotParams directive was not provided in the configuration file \"$1\""
    GNUPLOTPARAMS[$((${#GNUPLOTPARAMS[@]} + 1))]="$ret" # save the argument of the directive

    if [[ "${CONFIG["g"]}" == "" ]]
    then
      CONFIG["g"]="${CONFIG["g"]}$ret"               # save the argument of the switch, this way it can be displayed by verbose
    else
      CONFIG["g"]="${CONFIG["g"]} $ret"              # save the argument of the switch, this way it can be displayed by verbose
    fi

    ((directives++))
    verbose "value of the directive GnuplotParams: $ret"
  fi

  # ==================================
  # EFFECTPARAMS
  if ! [[ "$(grep -i "^[^#]*EffectParams .*$" "$1")" == "" ]]	# check if the directive was provided in the configuration file
  then
    ret=$(sed -n '/^[^#]*EffectParams /Ip' "$1" | sed -n 's/^.*EffectParams/EffectParams/I; s/EffectParams[[:space:]]*/EffectParams /; s/EffectParams //; s/[[:space:]]*#.*$//; $p')
		   
    [[ "$ret" == "" ]] && error "value of the EffectParams directive was not provided in the configuration file \"$1\""
    
    for i in $(echo "$ret" | tr ":" " ")
    do
      ! [[ "$i" =~ ^bounce$ || "$i" =~ ^factor=[5-9]$ ]] && # check the argument value
      error "wrong argument of the EffectParams directive in configuration file \"$1\""

      EFFECTPARAMS[$((${#EFFECTPARAMS[@]} + 1))]="$ret" # save the argument of the directive
      [[ "$i" =~ ^factor=[5-9]$ ]] && FACTOR="$(echo "$i" | sed 's/factor=//')"

      if [[ "${CONFIG["e"]}" == "" ]]
      then
        CONFIG["e"]="${CONFIG["e"]}$ret"               # save the argument of the switch, this way it can be displayed by verbose
      else
        CONFIG["e"]="${CONFIG["e"]} $ret"              # save the argument of the switch, this way it can be displayed by verbose
      fi

    done

  fi

  # ==================================
  # NAME
  if ! [[ "${SWITCHES[@]}" =~ n || "$(grep -i "^[^#]*Name .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then
    ret=$(sed -n '/^[^#]*Name /Ip' "$1" | sed -n 's/^.*Name/Name/I; s/Name[[:space:]]*/Name /; s/Name //; s/[[:space:]]*#.*$//; $p')
  
    [[ "$ret" == "" ]] && error "value of the Name directive was not provided in the configuration file \"$1\""
    CONFIG["n"]="$ret"
    ((directives++))
    verbose "value of the directive Name: $ret"
  fi
  
  # ==================================
  # IGNOREERRORS
  if ! [[ "${SWITCHES[@]}" =~ E || "$(grep -i "^[^#]*IgnoreErrors .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then
    ret=$(sed -n '/^[^#]*IgnoreErrors /Ip' "$1" | sed -n 's/^.*IgnoreErrors/IgnoreErrors/I; s/IgnoreErrors[[:space:]]*/IgnoreErrors /; s/IgnoreErrors //; s/[[:space:]]*#.*$//; $p')

    [[ "$ret" == "" ]] && error "value of the IgnoreErrors directive was not provided in the configuration file \"$1\""
    ! [[ "$ret" == "true" || "$ret" == "false" ]] && error "wrong argument of the CriticalValue directive in configuration file \"$1\""
    CONFIG["E"]="$ret"
    ((directives++))
    verbose "value of the directive Name: $ret"
  fi

  if [[ $directives -eq 0 ]]
  then
    warning "provided configuration file \"${CONFIG["f"]}\" does not contain any directives" ; warning "check if the switch was not provided on the command line or if the directive format is correct" ;

  else
    verbose "number of processed directives: $directives"
  fi
}
#-------------------------------------------------------------------------------
# function for checking values of the directives/switches
# parameters:
#   function takes no parameters, it works with global variables
# function checks value of Xmax, Xmin, Ymax, Ymin and name of the output directory
# furthermore function checks if the values are in the data files
#-------------------------------------------------------------------------------
function checkValues()
{
  if [[ "${CONFIG["Y"]}" != "auto" && "${CONFIG["Y"]}" != "max" && "${CONFIG["y"]}" != "auto" && "${CONFIG["y"]}" != "min" ]]
  then
    [[ $(echo "${CONFIG["Y"]} <= ${CONFIG["y"]}" | bc) -eq 1 ]] && error "Value of Ymin is greater or equal than value of Ymax"
  fi

  if [[ "${CONFIG["X"]}" != "auto" && "${CONFIG["X"]}" != "max" && "${CONFIG["x"]}" != "auto" && "${CONFIG["x"]}" != "min" ]]
  then

    # convert to unix timestamp, then compare
    # date is not reliable with some characters !!
    X=$(date "+%s" -d "$(echo "${CONFIG["X"]}")" 2>/dev/null)
    X="$?"

    x=$(date "+%s" -d "$(echo "${CONFIG["x"]}")" 2>/dev/null)
    x="$?"

    if [[ "$X" == "0" && "$x" == "0" ]] # no errors
    then
      [[ $(echo "$(date "+%s" -d "$(echo "${CONFIG["X"]}")" 2>/dev/null) <= $(date "+%s" -d "$(echo "${CONFIG["x"]}")" 2>/dev/null)" | bc) -eq 1 ]] && error "Value of Xmin is greater or equal than value of Xmax"

    fi
  fi
  
  [[ "${CONFIG["n"]}" == "" ]] && CONFIG["n"]="main"      # default name

  if [[ "${CONFIG["Y"]}" != "auto" && "${CONFIG["Y"]}" != "max" ]]
  then
    [[ "$(grep "${CONFIG["Y"]}" "${DATA[@]}")" == "" ]] && error "Value of Ymax is not listed in the data files"
  fi
    
  if [[ "${CONFIG["y"]}" != "auto" && "${CONFIG["y"]}" != "min" ]]
  then
    [[ "$(grep "${CONFIG["y"]}" "${DATA[@]}")" == "" ]] && error "Value of Ymin is not listed in the data files"
  fi

  if [[ "${CONFIG["X"]}" != "auto" && "${CONFIG["X"]}" != "max" ]]
  then
    [[ "$(grep "${CONFIG["X"]}" "${DATA[@]}")" == "" ]] && error "Value of Xmax is not listed in the data files"
  fi
    
  if [[ "${CONFIG["x"]}" != "auto" && "${CONFIG["x"]}" != "min" ]]
  then
    [[ "$(grep "${CONFIG["x"]}" "${DATA[@]}")" == "" ]] && error "Value of Xmin is not listed in the data files"
  fi
}
#-------------------------------------------------------------------------------
# function for creating animation
# parameters: 
#   function takes no parameters, it works with global variables
#   sets ranges for graphs
#-------------------------------------------------------------------------------
function createAnim()
{
  local directory="${CONFIG["n"]}"
  local i=1
  local records=0       # total number of records
  local fps             # frames per second
  local frames          # number of frames
  local gnuplot         # commands for gnuplot
  local plot            # data to plot
  local len             # length of individual data files
  local using=""        # how many columns
  local columns         # columns of data file
  local YMAX            # Ymax
  local YMIN            # Ymin
  local tmp             # for temporary data
  local time_len        # timestamp length
  local more            # more plots
  local ef_gnuplot      # gnuplot with effects
  local output          # final gnuplot output
  local ef_output          # final gnuplot output with effects

  while [[ -d "$directory" ]]
  do
    directory="${CONFIG["n"]}_$((i++))"
  done
  
  mkdir "$directory"
  
  if [[ "$?" != "0" ]]
  then
    local st=$(mkdir "$directory" 2>&1)
    error "error creating directory $directory, details:\n$st"

  fi

  CONFIG["n"]="$directory"  # for cleanup

  gnuplot="set terminal png size 1024,768; set font 'verdana'; set timefmt '${CONFIG["t"]}'; set xdata time; set format x '${CONFIG["t"]}'; set xlabel 'Time'; set ylabel 'Value'; set y2label 'Value'; unset key; "
#-------------------------------------------------------------------------------

  YMAX="$(head -1 "${DATA[0]}" | awk '{ print $NF }')"
  YMIN="$(head -1 "${DATA[0]}" | awk '{ print $NF }')"
  time_len="$(head -1 "${DATA[0]}" | awk '{ for(i = 1; i < NF; i++); } END { print i; }')"

  for i in ${DATA[@]}
  do
    tmp="$(cat "$i" | awk '{ print $NF }' | sort -n -r)"
    [[ "$(echo "$(echo "$tmp" | head -1) > $YMAX" | bc)" == "1" ]] && YMAX="$(echo "$tmp" | head -1)"
    [[ "$(echo "$(echo "$tmp" | tail -1) < $YMIN" | bc)" == "1" ]] && YMIN="$(echo "$tmp" | tail -1)"
  done

  if [[ "$MULTIPLOT" == "true" ]]
  then

    cat "${DATA[0]}" >> "$directory/data"
    gnuplot="$gnuplot set multiplot; "

    for((i = 1; i < ${#DATA[@]}; i++))
    do
      len=$(wc -l < "${DATA[$i]}")

      for((k = 1; k <= $len; k++))
      do
        num="$(sed -n ''${k}'p' "${DATA[$i]}" | awk '{ print $NF }')"
        sed -i ''$k's/$/ '$num'/' "$directory/data"  # susbstitute on chosen line !
      done
    done        # finally all values for same times in one file
    
    columns="$columns$(head -1 "$directory/data" | wc -w)"
    records="$(wc -l < "$directory/data")"   # count the records

  else

    for i in ${DATA[@]}
    do
      records=$(echo "$records +$(wc -l < "$i")" | bc)    # count the records
      cat "$i" >> "$directory/data"
    done
    columns="$(head -1 "${DATA[0]}" | wc -w)"

  fi

#-------------------------------------------------------------------------------
  if [[ "${CONFIG["l"]}" != "" ]]           # legend
    then
    gnuplot="$gnuplot set key ${CONFIG["l"]}; "
  fi

#-------------------------------------------------------------------------------

  if [[ "${GNUPLOTPARAMS[@]}" != "" ]]      # other gnuplot parameters
  then
    gnuplot="$gnuplot ${GNUPLOTPARAMS[@]}; "
  fi

  if [[ "${CRITICALVALUES[@]}" != "" ]]     # critical values
  then
    for i in ${CRITICALVALUES[@]}
    do
      if [[ "$(echo "$i" | sed 's/y=//; s/x=//')" =~ ^-?[0-9]+$ || "$i" =~ ^-?[0-9]+\.[0-9]+$ || "$i" =~ ^\+?[0-9]+$ || "$i" =~ ^\+?[0-9]+\.[0-9]+$ ]] # y value
      then
        plot="$plot "$(echo $i | sed 's/y=//')","

      else      # x value
        gnuplot="$gnuplot set arrow from \""$(echo "$i" | sed 's/x=//')"\",graph(0,0) to \""$(echo "$i" | sed 's/x=//')"\",graph(1,1) nohead; "
      fi
    done
  fi

#-------------------------------------------------------------------------------
  # setting Y values

  if [[ "${CONFIG["Y"]}" != "auto" && "${CONFIG["Y"]}" != "max" && "${CONFIG["y"]}" != "auto" && "${CONFIG["y"]}" != "min" ]]   # specific values
  then
    gnuplot="$gnuplot set yrange[${CONFIG["y"]}:${CONFIG["Y"]}]; "
  fi

  if [[ "${CONFIG["Y"]}" == "max" && "${CONFIG["y"]}" != "min" && "${CONFIG["y"]}" != "auto" ]]    # max + value
  then
    gnuplot="$gnuplot set yrange[${CONFIG["y"]}:$YMAX]; "
  fi

  if [[ "${CONFIG["Y"]}" == "max" && "${CONFIG["y"]}" == "min" ]]    # max + min
  then
    gnuplot="$gnuplot set yrange[$YMIN:$YMAX]; "
  fi

  if [[ "${CONFIG["y"]}" == "min" && "${CONFIG["Y"]}" != "max" && "${CONFIG["Y"]}" != "auto" ]]    # min + value
  then
    gnuplot="$gnuplot set yrange[$YMIN:${CONFIG["Y"]}]; "
  fi

  if [[ "${CONFIG["Y"]}" == "max" && "${CONFIG["y"]}" == "auto" ]]    # max + auto
  then
    gnuplot="$gnuplot set yrange[:$YMAX]; "
  fi

  if [[ "${CONFIG["y"]}" == "min" && "${CONFIG["Y"]}" == "auto" ]]    # min + auto
  then
    gnuplot="$gnuplot set yrange[$YMIN:]; "
  fi

#-------------------------------------------------------------------------------
  # setting X values

  if [[ "${CONFIG["X"]}" != "auto" && "${CONFIG["X"]}" != "max" && "${CONFIG["x"]}" != "auto" && "${CONFIG["x"]}" != "min" ]]   # specific values
  then
    gnuplot="$gnuplot set xrange[\"${CONFIG["x"]}\":\"${CONFIG["X"]}\"]; "
  fi

  if [[ "${CONFIG["X"]}" == "max" && "${CONFIG["x"]}" != "min" && "${CONFIG["x"]}" != "auto" ]]   # max + value
  then
    gnuplot="$gnuplot set xrange[\"${CONFIG["x"]}\":\""$(sort -n -r "$directory/data" | head -1 | awk -v len=$time_len 'BEGIN { ORS=" " } { for(i = 1; i < len; i++ ) print $i }' | sed 's/ $//')"\"]; "
  fi

  if [[ "${CONFIG["X"]}" == "max" && "${CONFIG["x"]}" == "min" ]]   # max + min
  then
    gnuplot="$gnuplot set xrange[\""$(sort -n "$directory/data" | head -1 | awk -v len=$time_len 'BEGIN { ORS=" " } { for(i = 1; i < len; i++ ) print $i }' | sed 's/ $//')"\":\""$(sort -n -r "$directory/data" | head -1 | awk -v len=$time_len 'BEGIN { ORS=" " } { for(i = 1; i < len; i++ ) print $i }' | sed 's/ $//')"\"]; "
  fi

  if [[ "${CONFIG["x"]}" == "min" && "${CONFIG["X"]}" != "max" && "${CONFIG["X"]}" != "auto" ]]   # min + value
  then
    gnuplot="$gnuplot set xrange[\""$(sort -n "$directory/data" | head -1 | awk -v len=$time_len 'BEGIN { ORS=" " } { for(i = 1; i < len; i++ ) print $i }' | sed 's/ $//')"\":\"${CONFIG["X"]}\"]; "
  fi

#-------------------------------------------------------------------------------

  if [[ "${SWITCHES[@]}" =~ S && "${SWITCHES[@]}" =~ T && "${SWITCHES[@]}" =~ F ]] # Speed, Time and FPS
  then
    warning "Speed, Time and FPS were provided, using Speed and Time"
  fi


  if [[ "${SWITCHES[@]}" =~ S && "${SWITCHES[@]}" =~ T ]] # Speed and Time
  then
    # need to calculate fps
    # need to know how many frames we got
    # fps = frames / time
    frames=$((records / ${CONFIG["S"]}))
    fps=$(($frames / ${CONFIG["T"]}))


  elif [[ "${SWITCHES[@]}" =~ S && "${SWITCHES[@]}" =~ F ]] # Speed and FPS
  then
    fps="${CONFIG["F"]}"
    # time is set by these two values


  elif [[ "${SWITCHES[@]}" =~ T && "${SWITCHES[@]}" =~ F ]] # Time and FPS
  then
    fps="${CONFIG["F"]}"
    # calculate speed
    CONFIG["S"]="$(echo "($records / ${CONFIG["F"]}) / ${CONFIG["T"]}")"


  elif [[ "${SWITCHES[@]}" =~ T ]] # only Time 
  then
    fps="${CONFIG["F"]}"
    CONFIG["S"]="$(echo "($records / ${CONFIG["F"]}) / ${CONFIG["T"]}")"

  elif [[ "${SWITCHES[@]}" =~ S ]] # only Speed
  then
    fps="${CONFIG["F"]}"

  elif [[ "${SWITCHES[@]}" =~ F ]] # only FPS
  then
    fps="${CONFIG["F"]}"

  else      # nothing
    fps="${CONFIG["F"]}"

  fi

#-------------------------------------------------------------------------------

  # just generate output for gnuplot
  local j=0
  for((i = ${CONFIG["S"]}; i <= ${CONFIG["S"]}; i += ${CONFIG["S"]}))
  do

    if [[ $MULTIPLOT == "true" ]]
    then

      columns=$((columns - 2))
      for((k = 0; k <= $columns; k++))
      do
        # red, green, blue, yellow, black
        if ! [[ "$using" =~ red ]]
        then
          using="$using plot '<head -$i $directory/data' using 1:$((k + 2)) with lines linecolor rgb \"red\" smooth unique; "

        elif ! [[ "$using" =~ green ]]
        then
          using="$using plot '<head -$i $directory/data' using 1:$((k + 2)) with lines linecolor rgb \"green\" smooth unique; "

        elif ! [[ "$using" =~ blue ]]
        then
          using="$using plot '<head -$i $directory/data' using 1:$((k + 2)) with lines linecolor rgb \"blue\" smooth unique; "

        elif ! [[ "$using" =~ yellow ]]
        then
          using="$using plot '<head -$i $directory/data' using 1:$((k + 2)) with lines linecolor rgb \"yellow\" smooth unique; "

        elif ! [[ "$using" =~ black ]]
        then
          using="$using plot '<head -$i $directory/data' using 1:$((k + 2)) with lines linecolor rgb \"black\" smooth unique; "

        else
          using="$using plot '<head -$i $directory/data' using 1:$((k + 2)) with lines smooth unique; "

        fi
      done

    else
      using="$using plot '<head -$i $directory/data' using 1:$columns with lines smooth unique; "
    fi

    if [[ "$plot" != "" ]]
    then
      output="$gnuplot; plot ${plot:0:$((${#plot} -1))}; $using"    # cut off last ','
    else
      output="$gnuplot; $using"
    fi

  done

#-------------------------------------------------------------------------------

  #echo "=============="
  #echo "$columns"
  #echo "=============="
  #echo "$gnuplot"
  #echo "=============="
  #echo "$output"
  #echo "=============="
  #echo "$MULTIPLOT "
  #echo "=============="
  #echo "$fps"
  #echo "=============="
  #return

  # start at the first multiple, end at the records
  local j=0
  for((i = ${CONFIG["S"]}; i <= $records; i += ${CONFIG["S"]}))
  do

    if [[ "${EFFECTPARAMS[@]}" =~ bounce && "$((j % 10))" == "$FACTOR" ]] # add effect
    then
      ef_output="unset yrange; set yrange[$YMIN:$((YMAX * 2))]; $output;"

    else
      ef_output="$output"
    fi

    echo "set output '$directory/$(printf %0${#records}d $j).png'; $ef_output" | sed 's/head -[1-9][0-9]*/head -'$i'/g' | gnuplot &>/dev/null

    ((j++))
  done

  ffmpeg -r "$fps" -i "$directory/%0${#records}d.png" -vcodec libx264 "$directory/anim.mp4" &>/dev/null

  play "$directory/anim.mp4"
}
#-------------------------------------------------------------------------------
# function to play created animation
# parameters:
#   1) file to play
#-------------------------------------------------------------------------------
function play()
{
  (($PLAY)) || return;
  mplayer "$1" &>/dev/null
}
#-------------------------------------------------------------------------------
# function to remove all the created frames
# parameters:
#   function takes no parameters
#-------------------------------------------------------------------------------
function cleanup()
{
  if [[ -d "${CONFIG["n"]}" ]]
  then
    find "${CONFIG["n"]}" -maxdepth 1 -name '*.png' -exec rm {} \;
    find "${CONFIG["n"]}" -maxdepth 1 -name 'data' -exec rm {} \;
  fi
}
#-------------------------------------------------------------------------------
# signal reactions
#-------------------------------------------------------------------------------
trap cleanup EXIT
trap 'trap - EXIT; cleanup' INT TERM
#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------
  # main configuration variables, global for whole file
  typeset -A CONFIG                 # associative field for configuration variables, indexes are switches, values are their arguments
  CONFIG["t"]="[%Y-%m-%d %H:%M:%S]" # timestamp format
  CONFIG["X"]="max"                 # maximum x-axis value
  CONFIG["x"]="min"                 # minimum X-axis value
  CONFIG["Y"]="auto"                # maximum y-axis value
  CONFIG["y"]="auto"                # minimum y-axis value
  CONFIG["S"]=1                     # speed - number of data entries in one picture 
  CONFIG["T"]=""                    # duration of the animation
  CONFIG["F"]=25                    # frames per second
  CONFIG["c"]=""                    # critical values, just for verbose function
  CONFIG["f"]=""                    # configuration file
  CONFIG["n"]="main"                # name of the output directory
  CONFIG["l"]=""                    # legend of the graph
  CONFIG["g"]=""                    # parameters for gnuplot, just for verbose function
  CONFIG["E"]="true"                # IgnoreErrors, do not ignore errors
  
  typeset -a SWITCHES               # field for all processed switches
  typeset -a DATA			        # filed containing data files
  typeset -a GNUPLOTPARAMS          # field for gnuplot parameters
  typeset -a EFFECTPARAMS           # field for effect parameters
  typeset -a CRITICALVALUES         # field for critical values

  FACTOR=0                          # effect
  MULTIPLOT="false"                 # more curves in one animation
  VERBOSE=0                         # debug information
  PLAY=0                            # play after script has finished

#-------------------------------------------------------------------------------
  readParams "$@"
  shift `expr $OPTIND - 1`	# shift on the command line
  
  verbose "processed switches: ${SWITCHES[@]}"         # report processed switches

  for i in "${SWITCHES[@]}"
  do
    verbose "value of the switch -$i: ${CONFIG["$i"]}" # report values of all entered switches
  done

  readConfig "${CONFIG["f"]}"   # read the configuration file
  
  checkFiles "$@"           # check the data files at this point, so its not necessary later - possible errors are solved close to the start
  verbose "data files: ${DATA[@]}"   # report data files
  checkValues               # check provided values of the switches or directives from the configuration file

  createAnim                # create the final animation

