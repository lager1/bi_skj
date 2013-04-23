#!/bin/bash


#
#
# semester work from subject BI-SKswitches_idx, FIT CVUT, 2013, summer semester
#
# This script generates animation based on provided data files,
# additionaly its behavior can be affected by switches or by configuration file.
# Its possible to use both options together, if switch and corresponding
# directive are used, then switch is preffered.
#
#






# prozatim implementovane vsechny povinne prepinace
# navic definovan prepinac -v ==> verbose
# navic definovan prepinac -p ==> play
#
#
# TODO: 
#   zkontrolovat funkci na cteni parametru -> jsou definovany vsechny povinne i volitelne prepinace?
#   jsou vsechny promenne zpracovany spravne ?
#   
#
#   vymyslet novy efekt ?


#
# pokud by se melo kreslit vice grafu pro stejny casovy interval, tak:
# pokud se neshouji casove udaje pro vsechny soubory -> odriznout prvni casti vsech souboru a navzajem porovnat diffem
# -> error uzivateli, spatny format dat


# otazka na konfiguracni soubor:
# text začínající znakem # představuje komentář až do konce řádku.
# ==> takze pokud zacina text mezerou(nebo cimkoliv jinym) a nasleduje # tak to je komentar ?
# z prikladu to ale vypada, ze komentar je cokoliv od znaku # !!!!


# jak se zachovat v pripade, ze je na radce zadan prepinac u ktereho je pripustnych vice vyskytu a zaroven bude zadana odpovidajici direktiva v konfiguracnim souboru


# Direktiva má právě jednu hodnotu (odpovídá jednomu arumentu na příkazové řádce).  -> jak to resit? v ukazkovem konfiguraku gnuplotparams -> vice slov !!

# je mozne do matematickeho vyhodnoceni zaroven dat znak promenne s specifikovat tak o co se jedna? -> viz prednasky

# ma cenu definovat ruzne navratove kody pro ruzne chyby?


#
# pridat reakci na signaly -> trap

# napisu nekam do manualu, ze kontrolni sekvence %t musi byt vzdy oddelene nejakym znakem


#-------------------------------------------------------------------------------
# function to print warning message
# parameters:
#   function takes arbitrary number of arguments
# all of the parameters ale printed to the standart output
#-------------------------------------------------------------------------------
function warning()
{
  echo -en "\e[1;33mWARNING: \e[0m"     # print in green color

  for i in "$@"
  do
    echo -en "\e[1;33m$i \e[0m"       # print in green color 
  done
  echo ""
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
           [[ "$OPTARG" =~ ^$(echo "${CONFIG["t"]}" | sed 's/%H/\[0-9\]\{2\}/g; s/%M/\[0-9\]\{2\}/g; s/%S/\[0-9\]\{2\}/g; s/%S/\[0-9\]\{2\}/g; s/%d/\[0-9\]\{2\}/g; s/%j/\[0-9\]\{3\}/g; s/%k/\[0-9\]\{2\}/g; s/%m/\[0-9\]\{2\}/g; s/%u/\[0-9\]\{1\}/g; s/%w/\[0-9\]\{1\}/g; s/%W/\[0-9\]\{2\}/g; s/%y/\[0-9\]\{2\}/g; s/%Y/\[0-9\]\{4\}/g; s/%l/\[0-9\]\{2\}/g; s/%U/\[0-9\]\{2\}/g; s/%V/\[0-9\]\{2\}/g;')$ ]] || error "provided timestamp format and argument of the switch -X does not match"

           local ret=""

           for((i = 0; i < ${#CONFIG["t"]}; i++))   # seperate control sequences, that are just after each other, by space
           do
             if [[ "${CONFIG["t"]:$i:1}" == "%" && "${CONFIG["t"]:$((i + 1)):1}" =~ ^[dHjklmMSuUVwWyY]$ && "${CONFIG["t"]:$((i + 2)):1}" == "%" && "${CONFIG["t"]:$((i + 3)):1}" =~ ^[dHjklmMSuUVwWyY]$ ]] # two control sequences just after each other
             then
               ret="$ret${OPTARG:$i:2} ${OPTARG:$((i + 2)):2}"
               i=$((i + 3))
             else
               ret="$ret${OPTARG:$i:1}"
             fi
           done

           #warning "tady"
           #set -v
           #set -x

           # first print the timestamp, then process by date with the argument of the switch -X, it is important that the argument contains only numbers
           [[ "$(date "+$(printf "%s" "${CONFIG["t"]}")" -d "$(echo "$ret" | sed 's$/$:$g')" 2> /dev/null)" == "$OPTARG" ]] || error "provided timestamp format and argument of the switch -X does not match"



           #[[ "$(date "+$(printf "%s" "${CONFIG["t"]}")" -d "$(echo "$ret" | sed 's$/$$g')" 2> /dev/null)" == "$OPTARG" ]] || error "provided timestamp format and argument of the switch -X does not match"

         fi

         SWITCHES[$((switches_idx++))]="X"	# save the processed switch
         CONFIG["X"]="$OPTARG";;            # save the argument of the switch
      
      x) # XMIN 
		 [ -z "$OPTARG" ] && error "the value of the switch -x was not provided"

         if ! [[ "$OPTARG" == "auto" || "$OPTARG" == "min" ]] # none of acceptable text values
         then
           # there may be specific value, needs to be checked
           # first check if the format of the argument is correct, then check by date
           [[ "$OPTARG" =~ ^$(echo "${CONFIG["t"]}" | sed 's/%H/\[0-9\]\{2\}/g; s/%M/\[0-9\]\{2\}/g; s/%S/\[0-9\]\{2\}/g; s/%S/\[0-9\]\{2\}/g; s/%d/\[0-9\]\{2\}/g; s/%j/\[0-9\]\{3\}/g; s/%k/\[0-9\]\{2\}/g; s/%m/\[0-9\]\{2\}/g; s/%u/\[0-9\]\{1\}/g; s/%w/\[0-9\]\{1\}/g; s/%W/\[0-9\]\{2\}/g; s/%y/\[0-9\]\{2\}/g; s/%Y/\[0-9\]\{4\}/g; s/%l/\[0-9\]\{2\}/g; s/%U/\[0-9\]\{2\}/g; s/%V/\[0-9\]\{2\}/g;')$ ]] || error "provided timestamp format and argument of the switch -x does not match"

           local ret=""

           for((i = 0; i < ${#CONFIG["t"]}; i++))   # seperate control sequences, that are just after each other, by space
           do
             if [[ "${CONFIG["t"]:$i:1}" == "%" && "${CONFIG["t"]:$((i + 1)):1}" =~ ^[dHjklmMSuUVwWyY]$ && "${CONFIG["t"]:$((i + 2)):1}" == "%" && "${CONFIG["t"]:$((i + 3)):1}" =~ ^[dHjklmMSuUVwWyY]$ ]] # two control sequences just after each other
             then
               ret="$ret${OPTARG:$i:2} ${OPTARG:$((i + 2)):2}"
               i=$((i + 3))
             else
               ret="$ret${OPTARG:$i:1}"
             fi
           done

           # first print the timestamp, then process by date with the argument of the switch -X, it is important that the argument contains only numbers
           [[ "$(date "+$(printf "%s" "${CONFIG["t"]}")" -d "$(echo "$ret" | sed 's$/$$g')" 2> /dev/null)" == "$OPTARG" ]] || error "provided timestamp format and argument of the switch -x does not match"

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
		 ! [[ "$OPTARG" =~ ^\+?[0-9]+$ || "$OPTARG" =~ ^\+?[0-9]+\.[0-9]+$ ]] && {	# non-numeric value, should be int/float
		   error "wrong argument of the switch -S"; }
         SWITCHES[$((switches_idx++))]="S"	# save the processed switch
         CONFIG["S"]="$OPTARG";;            # save the argument of the switch

      T) # TIME
		 [ -z "$OPTARG" ] && error "the value of the switch -T was not provided"
		 ! [[ "$OPTARG" =~ ^\+?[0-9]+$ || "$OPTARG" =~ ^\+?[0-9]+\.[0-9]+$ ]] && {	# non-numeric value, should be int/float
		   error "wrong argument of the switch -T"; }
         SWITCHES[$((switches_idx++))]="T"	# save the processed switch
         CONFIG["T"]="$OPTARG";;            # save the argument of the switch

      F) # FPS
		 [ -z "$OPTARG" ] && error "the value of the switch -F was not provided"
		 ! [[ "$OPTARG" =~ ^\+?[0-9]+$ || "$OPTARG" =~ ^\+?[0-9]+\.[0-9]+$ ]] && {	# non-numeric value, should be int/float
           error "wrong argument of the switch -F"; }
         SWITCHES[$((switches_idx++))]="F"	# save the processed switch
         CONFIG["F"]="$OPTARG";;            # save the argument of the switch

      c) # CRITICALVALUE
		 [ -z "$OPTARG" ] && error "the value of the switch -c was not provided"
         
         for i in $(echo "$OPTARG" | tr ":" " ")
         do

           # check both x and y, x values are in format defined by Timeformat
           ! [[ "$i" =~ ^y=\+?[0-9]+$  || "$i" =~ ^y=\+?[0-9]+\.[0-9]+$ || "$i" =~ ^y=-?[0-9]+$ || "$i" =~ ^y=-?[0-9]+\.[0-9]+$ || "$i" =~ ^x="$(date "+$(printf "%s" "${CONFIG["t"]}")" -d "$(echo "$i" | sed 's/x=//; s/[^0-9]//g')")"$ ]] && error "wrong argument of the switch -c"

           CRITICALVALUES[$((crit_val_idx++))]="$i" # save the argument of the switch

           if [[ "${CONFIG["c"]}" == "" ]]
           then
             CONFIG["c"]="${CONFIG["c"]}$i"              # save the argument of the switch, this way it can be displayed by verbose
           else
             CONFIG["c"]="${CONFIG["c"]} $i"              # save the argument of the switch, this way it can be displayed by verbose
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
   
   # tady jeste upravit podle efektu !!
      e) # EFFECTPARAMS
		 [ -z "$OPTARG" ] && error "the value of the switch -e was not provided"
		 OPTARG=`echo "$OPTARG" | tr ":" " "`	# change the seperator to space so we could iterate
		 for i in $OPTARG
		 do
		   ! [[ "$i" =~ ^bgcolor=.*$ || "$i" =~ ^changebgcolor$ || "$i" =~ ^changespeed=[1-5]$ ]] && { # check the argument value
             error "wrong argument of the switch -e"; }
		   EFFECTPARAMS[$((eff_params_idx++))]="$i"	# save the argument of the switch or a part of it
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

      v) # PLAY
         SWITCHES[$((switches_idx++))]="p"	# save the processed switch
         CONFIG["p"]="1"
         PLAY=1;;                        # set the value of global variable

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

  # jeste je nutne zkontrolovat, ze se shoduje zadany format timestampu s tim, co je v datovem souboru

  local words=$(head -1 ${DATA[0]} | wc -w)

  # check if the provided TimeFormat is equal with the timestamp in the data file
  [[ "$(cat "${DATA[0]}" | cut -d " " -f1-$((words -1)) | tr "\n" " ")" =~ ^($(echo "${CONFIG["t"]}" | sed 's/%H/\[0-9\]\{2\}/g; s/%M/\[0-9\]\{2\}/g; s/%S/\[0-9\]\{2\}/g; s/%S/\[0-9\]\{2\}/g; s/%d/\[0-9\]\{2\}/g; s/%j/\[0-9\]\{3\}/g; s/%k/\[0-9\]\{2\}/g; s/%m/\[0-9\]\{2\}/g; s/%u/\[0-9\]\{1\}/g; s/%w/\[0-9\]\{1\}/g; s/%W/\[0-9\]\{2\}/g; s/%y/\[0-9\]\{2\}/g; s/%Y/\[0-9\]\{4\}/g; s/%l/\[0-9\]\{2\}/g; s/%U/\[0-9\]\{2\}/g; s/%V/\[0-9\]\{2\}/g;') )+$ ]] || error "provided TimeFormat and timestamp in data file \"${DATA[0]}\" does not match"

  # jeste kontrola pomoci date?
  # pokud to ma smysl tak dodelat nekdy pozdeji

  if [[ $# -gt 1 ]]
  then

    local ret

    for i in "${DATA[@]}"
    do
      [[ $(wc -l < "${DATA[0]}") -ne $(wc -l < "$i") ]] && { MULTIPLOT="false"; return; }
      
      # na toto se jeste poptat, zda je implicitne timeformat a hodnota oddelena mezerou
      # dale, muze byt vice hodnot pro jeden casovy udaj v jednom souboru ?
      # pocitame, ze ano
      # pripadne to jeste dodefinovat v zadani
      
      # neco takoveho pouzit v pripade, ze je v jednom souboru povoleno vice hodnot pro jeden casovy udaj

      #[[ "$(diff <(cat ${DATA[0]} | cut -d" " -f${cols}) <(cat $i | cut -d" " -f${cols}) &>/dev/null)" != "0" ]] && { echo "diff"; MULTIPLOT="false"; return; }
      # tohle pouze nefunguje, jen se zeptat jak

      [[ "$(cat "$i" | cut -d " " -f1-$((words - 1)) | tr "\n" " ")" =~ ^($(echo "${CONFIG["t"]}" | sed 's/%H/\[0-9\]\{2\}/g; s/%M/\[0-9\]\{2\}/g; s/%S/\[0-9\]\{2\}/g; s/%S/\[0-9\]\{2\}/g; s/%d/\[0-9\]\{2\}/g; s/%j/\[0-9\]\{3\}/g; s/%k/\[0-9\]\{2\}/g; s/%m/\[0-9\]\{2\}/g; s/%u/\[0-9\]\{1\}/g; s/%w/\[0-9\]\{1\}/g; s/%W/\[0-9\]\{2\}/g; s/%y/\[0-9\]\{2\}/g; s/%Y/\[0-9\]\{4\}/g; s/%l/\[0-9\]\{2\}/g; s/%U/\[0-9\]\{2\}/g; s/%V/\[0-9\]\{2\}/g;') )+$ ]] || error "provided TimeFormat and timestamp in data file \"$i\" does not match"
      
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
# function for sorting multiple files
# parameters:
#   function takes no parameters, it works with global variables
# function sorts the data files depending on timestamp in data files
#-------------------------------------------------------------------------------
function sortFiles()
{
  [[ "${#DATA[@]}" -eq 1 ]] && return   # just one file

  # tady jeste ty soubory seradit ve spravnem poradi dle casu, pokud na sebe nenavazuji ?
  local words=$(head -1 ${DATA[0]} | wc -w)
  for ((i = 1; i < ${#DATA[@]}; i++))
  do

    #warning "kontroluji ${DATA[$((i - 1))]} a ${DATA[$i]}"
    #echo "neco"
    #echo "${DATA[$i]}"
    #echo "${DATA[i]}"
    echo "kontroluji ${DATA[$((i - 1))]} a ${DATA[$i]}"
    #warning "${DATA[i]}"
    #warning "${DATA[$i]}"

    #set -v
    #set -x



    #date "+%s" -d "$(tail -1 "${DATA[$((i - 1))]}" | cut -d " " -f1-$((words - 1)))


    #[[ $(echo "$(date "+%s" -d "$(tail -1 "${DATA[$((i - 1))]}" | cut -d " " -f1-$((words - 1)))")" >= "$(date "+%s" -d "$(head -1 "${DATA[$i]}" | cut -d " " -f1-$((words - 1)))")" | bc) -eq 1 ]] && error "chyba"
    
    [[ $(echo "$(date "+%s" -d "$(tail -1 "${DATA[$((i - 1))]}" | cut -d " " -f1-$((words - 1)))")" >= "$(date "+%s" -d "$(head -1 "${DATA[$i]}" | cut -d " " -f1-$((words - 1)))")" | bc) -eq 1 ]] && error "chyba"


  done
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
      [[ "$ret" =~ ^$(echo "${CONFIG["t"]}" | sed 's/%H/\[0-9\]\{2\}/g; s/%M/\[0-9\]\{2\}/g; s/%S/\[0-9\]\{2\}/g; s/%S/\[0-9\]\{2\}/g; s/%d/\[0-9\]\{2\}/g; s/%j/\[0-9\]\{3\}/g; s/%k/\[0-9\]\{2\}/g; s/%m/\[0-9\]\{2\}/g; s/%u/\[0-9\]\{1\}/g; s/%w/\[0-9\]\{1\}/g; s/%W/\[0-9\]\{2\}/g; s/%y/\[0-9\]\{2\}/g; s/%Y/\[0-9\]\{4\}/g; s/%l/\[0-9\]\{2\}/g; s/%U/\[0-9\]\{2\}/g; s/%V/\[0-9\]\{2\}/g;')$ ]] || error "provided timestamp format and argument of the Xmax directive in the configuration file \"$1\" does not match"

      local return=""

      for((i = 0; i < ${#CONFIG["t"]}; i++))   # seperate control sequences, that are just after each other, by space
      do
        if [[ "${CONFIG["t"]:$i:1}" == "%" && "${CONFIG["t"]:$((i + 1)):1}" =~ ^[dHjklmMSuUVwWyY]$ && "${CONFIG["t"]:$((i + 2)):1}" == "%" && "${CONFIG["t"]:$((i + 3)):1}" =~ ^[dHjklmMSuUVwWyY]$ ]] # two control sequences just after each other
        then
          return="$return${ret:$i:2} ${ret:$((i + 2)):2}"
          i=$((i + 3))
        else
          return="$return${ret:$i:1}"
        fi
      done

      # first print the timestamp, then process by date with the argument of the switch -X, it is important that the argument contains only numbers
      [[ "$(date "+$(printf "%s" "${CONFIG["t"]}")" -d "$(echo "$return" | sed 's$/$$g')" 2> /dev/null)" == "$ret" ]] || error "provided timestamp format and argument of the Xmax directive in the configuration file \"$1\" does not match"

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
      [[ "$ret" =~ ^$(echo "${CONFIG["t"]}" | sed 's/%H/\[0-9\]\{2\}/g; s/%M/\[0-9\]\{2\}/g; s/%S/\[0-9\]\{2\}/g; s/%S/\[0-9\]\{2\}/g; s/%d/\[0-9\]\{2\}/g; s/%j/\[0-9\]\{3\}/g; s/%k/\[0-9\]\{2\}/g; s/%m/\[0-9\]\{2\}/g; s/%u/\[0-9\]\{1\}/g; s/%w/\[0-9\]\{1\}/g; s/%W/\[0-9\]\{2\}/g; s/%y/\[0-9\]\{2\}/g; s/%Y/\[0-9\]\{4\}/g; s/%l/\[0-9\]\{2\}/g; s/%U/\[0-9\]\{2\}/g; s/%V/\[0-9\]\{2\}/g;')$ ]] || error "provided timestamp format and argument of the Xmin directive in the configuration file \"$1\" does not match"

      local return=""

      for((i = 0; i < ${#CONFIG["t"]}; i++))   # seperate control sequences, that are just after each other, by space
      do
        if [[ "${CONFIG["t"]:$i:1}" == "%" && "${CONFIG["t"]:$((i + 1)):1}" =~ ^[dHjklmMSuUVwWyY]$ && "${CONFIG["t"]:$((i + 2)):1}" == "%" && "${CONFIG["t"]:$((i + 3)):1}" =~ ^[dHjklmMSuUVwWyY]$ ]] # two control sequences just after each other
        then
          return="$return${ret:$i:2} ${ret:$((i + 2)):2}"
          i=$((i + 3))
        else
          return="$return${ret:$i:1}"
        fi
      done

      # first print the timestamp, then process by date with the argument of the switch -X, it is important that the argument contains only numbers
      [[ "$(date "+$(printf "%s" "${CONFIG["t"]}")" -d "$(echo "$return" | sed 's$/$$g')" 2> /dev/null)" == "$ret" ]] || error "provided timestamp format and argument of the Xmin directive in the configuration file \"$1\" does not match"

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
    ! [[ "$ret" =~ ^\+?[0-9]+$ || "$ret" =~ ^\+?[0-9]+\.[0-9]+$ ]] && {  # none of acceptable values
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
    ! [[ "$ret" =~ ^\+?[0-9]+$ || "$ret" =~ ^\+?[0-9]+\.[0-9]+$ ]] && {  # none of acceptable values
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
    ! [[ "$ret" =~ ^\+?[0-9]+$ || "$ret" =~ ^\+?[0-9]+\.[0-9]+$ ]] && {  # none of acceptable values
      error "wrong argument of the FPS directive in configuration file \"$1\""; }

    CONFIG["F"]="$ret"
    ((directives++))
    verbose "value of the directive FPS: $ret"
  fi

  # ==================================
  # CRITICALVALUE
  if ! [[ "$(grep -i "^[^#]*CriticalValue .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then
    ret=$(sed -n '/^[^#]*CriticalValue /Ip' "$1" | sed -n 's/^.*CriticalValue/CriticalValue/I; s/CriticalValue[[:space:]]*/CriticalValue /; s/CriticalValue //; s/[[:space:]]*#.*$//; $p')
  
    [[ "$ret" == "" ]] && error "value of the CriticalValue directive was not provided in the configuration file \"$1\""
    
    for i in $(echo "$ret" | tr ":" " ")
    do

      # check both x and y, x values are in format defined by Timeformat
      ! [[ "$i" =~ ^y=\+?[0-9]+$  || "$i" =~ ^y=\+?[0-9]+\.[0-9]+$ || "$i" =~ ^y=-?[0-9]+$ || "$i" =~ ^y=-?[0-9]+\.[0-9]+$ || "$i" =~ ^x="$(date "+$(printf "%s" "${CONFIG["t"]}")" -d "$(echo "$i" | sed 's/x=//; s/[^0-9]//g')")"$ ]] && error "wrong argument of the CriticalValue directive in configuration file \"$1\""

      CRITICALVALUES[$((${#CRITICALVALUES[@]} + 1))]="$i" # save the argument of the directive
      
      if [[ "${CONFIG["c"]}" == "" ]]
      then
        CONFIG["c"]="${CONFIG["c"]}$i"              # save the argument of the switch, this way it can be displayed by verbose
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
  if ! [[ "$(grep -i "^[^#]*GnuplotParams .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then
    ret=$(sed -n '/^[^#]*GnuplotParams /Ip' "$1" | sed -n 's/^.*GnuplotParams/GnuplotParams/I; s/GnuplotParams[[:space:]]*/GnuplotParams /; s/GnuplotParams //; s/[[:space:]]*#.*$//; $p')

    [[ "$ret" == "" ]] && error "value of the GnuplotParams directive was not provided in the configuration file \"$1\""
    GNUPLOTPARAMS[$((${#GNUPLOTPARAMS[@]} + 1))]="$ret" # save the argument of the directive

    if [[ "${CONFIG["g"]}" == "" ]]
    then
      CONFIG["g"]="${CONFIG["g"]}$ret"              # save the argument of the switch, this way it can be displayed by verbose
    else
      CONFIG["g"]="${CONFIG["g"]} $ret"              # save the argument of the switch, this way it can be displayed by verbose
    fi

    ((directives++))
    verbose "value of the directive GnuplotParams: $ret"
  fi

  # ==================================
  # EFFECTPARAMS
  # direktiva muze byt uvedene vicekrat, kontrola neni potreba
  if ! [[ "$(grep -i "^[^#]*EffectParams .*$" "$1")" == "" ]]	# check if this particular switch was processed on the command line
  then
    ret=$(sed -n '/^[^#]*EffectParams /Ip' "$1" | sed -n 's/^.*EffectParams/EffectParams/I; s/EffectParams[[:space:]]*/EffectParams /; s/EffectParams //; s/[[:space:]]*#.*$//; $p')

    echo "EFFECTPARAMS:: ret: $ret"
    
    [[ "$ret" == "" ]] && error "value of the EffectParams directive was not provided in the configuration file \"$1\""

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
#-------------------------------------------------------------------------------
function checkValues()
{
  if [[ "${CONFIG["Y"]}" != "auto" && "${CONFIG["Y"]}" != "max" && "${CONFIG["y"]}" != "auto" && "${CONFIG["x"]}" != "min" ]]
  then
    [[ $(echo "${CONFIG["Y"]} <= ${CONFIG["y"]}" | bc) -eq 1 ]] && error "Value of Ymin is greater or equal than value of Ymax"
  fi

  if [[ "${CONFIG["X"]}" != "auto" && "${CONFIG["X"]}" != "max" && "${CONFIG["x"]}" != "auto" && "${CONFIG["x"]}" != "min" ]]
  then

    # convert to unix timestamp, then compare
    [[ $(echo "$(date "+%s" -d "$(echo "${CONFIG["X"]}" | sed 's/[^0-9[:space:]\:]//g')") <= $(date "+%s" -d "$(echo "${CONFIG["x"]}" | sed 's/[^0-9[:space:]\:]//g')")" | bc) -eq 1 ]] && error "Value of Xmin is greater or equal than value of Xmax"
  fi
  
  [[ "${CONFIG["n"]}" == "" ]] && CONFIG["n"]="main"      # default name
}
#-------------------------------------------------------------------------------
# function for creating animation
# parameters: 
#   function takes no parameters, it works with global variables
#-------------------------------------------------------------------------------
function createAnim()
{
  tmp="$(mktemp)"
  dir="$(mktemp -d)"
  TEMPFILES[${#TEMPFILES}]="$tmp"
  TEMPFILES[${#TEMPFILES}]="$dir"
 
  echo "set terminal png xffffff x000000 font verdana 8 size 1024,768
set output \"${CONFIG["n"]}/1.png\"
set timefmt \""${CONFIG["t"]}"\"
set xdata time
set format x\"${CONFIG["t"]}\"
set xlabel \"Time\"
set ylabel \"Value\"
set y2label \"Value\"
set title \"${CONFIG["l"]}\"
set nokey" > "$tmp"


  echo "vse uvedeno v souboru $tmp"
}
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
  CONFIG["n"]=""                    # name of the output directory
  CONFIG["l"]=""                    # legend of the graph
  CONFIG["g"]=""                    # parameters for gnuplot, just for verbose function
  CONFIG["E"]="true"                # IgnoreErrors, do not ignore errors
  
  typeset -a SWITCHES               # field for all processed switches
  typeset -a DATA			        # filed containing data files
  typeset -a TEMPFILES		        # temporary files
  typeset -a GNUPLOTPARAMS          # field for gnuplot parameters
  typeset -a EFFECTPARAMS           # field for effect parameters
  typeset -a CRITICALVALUES         # field for critical values

  FRAMES=0					        # total number of generated frames
  RECORDS=0					        # number of records in the file .... ?
  
  MULTIPLOT="false"
  
  #CHANGESPEED=1				# rychlost zmeny barvy pozadi
  #DIRECTION=0				# "smer", kterym menime barvu pozadi
  VERBOSE=0                         # debug information
  PLAY=0                            # play after script has finished


#-------------------------------------------------------------------------------
  readParams "$@"
  shift `expr $OPTIND - 1`	# posun na prikazove radce

  verbose "processed switches: ${SWITCHES[@]}"         # report processed switches

  for i in "${SWITCHES[@]}"
  do
    verbose "value of the switch -$i: ${CONFIG["$i"]}" # report values of all entered switches
  done

  readConfig "${CONFIG["f"]}"   # read the configuration file
  checkValues               # check provided values of the switches or directives from the configuration file
  checkFiles "$@"           # check the data files at this point, so its not necessary later - possible errors are solved close to the start
  #sortFiles
  # prozatim asi neni nutne, mozna to gnuplot umi primo v zavislosti na datu?
  # pokud by to bylo nutne, tak jeste pridat serazeni zaznamu v samotnem souboru ?
  # samotna data v datovych souborech by mela byt setridena podle casovych udaju, gnuplot si s tim sice poradi, ale vypada to zvlastne
  # pokud pridame smooth unique, tak neni treba data sortovat, gnuplot to udela za nas

  createAnim

  verbose "data files: ${DATA[@]}"   # report data files

  # pouze debug
  echo "MULTIPLOT: $MULTIPLOT"


