#!/bin/bash


#
#
# semester work from subject BI-SKswitches_idx, FIT CVUT, 2013, summer semester
#
# This script generates animation based on provided data files,
# additionaly its behavior can be affected by switches or by configuration file.
# Its possible to use both options together, if switch and corresponding
# configuration directive are used, then switch is preffered.
#
#






# prozatim implementovane vsechny povinne prepinace
# navic definovan prepinac -v ==> verbose
#
#
# TODO: 
#   zkontrolovat funkci na cteni parametru -> jsou definovany vsechny povinne i volitelne prepinace?
#   jsou vsechny promenne zpracovany spravne ?
#   
#   kontrola funkce na cteni konfigurace
#   je pripustny prazdny konfiguracni soubor?
#
#   muzou byt zadavany kladne hodnoty vsectne znamenka +?
#
#   kontrola zda ma prepinac zadan nejaky argument -> -prepinac ""
#   -> hodnota neni definovana
#
#   vymyslet novy efekt ?


#   funkce na cteni parametru na radce by mela byt ok -> vymyslet na to testy + rovnou je pouzit do finalniho skriptu na testovani
#
#   neda se indexovani a inkrementace udelat v ramci jednoho prikazu?
#
#   funkci na cteni parametru by mohla zaroven koukat na datove soubory
#
#   muze byt vice konfiguracnich souboru najednou?
#
#
#
#

# udelat print usage, pokud je skript spusten bez parametru ?


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

#lager@maniac:/data/data/skola/6.semestr/skj/semestralka$ j=0
#lager@maniac:/data/data/skola/6.semestr/skj/semestralka$ sw[$((j++))]="retezec"
#lager@maniac:/data/data/skola/6.semestr/skj/semestralka$ echo $j
#1
#lager@maniac:/data/data/skola/6.semestr/skj/semestralka$ echo $sw[0]
#retezec[0]
#lager@maniac:/data/data/skola/6.semestr/skj/semestralka$ echo ${sw[0]}
#retezec
#lager@maniac:/data/data/skola/6.semestr/skj/semestralka$ sw[$((j++))]="jiny_retezec"
#lager@maniac:/data/data/skola/6.semestr/skj/semestralka$ echo ${sw[1]}
#jiny_retezec
#lager@maniac:/data/data/skola/6.semestr/skj/semestralka$ echo $j
#2


# je mozne do matematickeho vyhodnoceni zaroven dat znak promenne s specifikovat tak o co se jedna? -> viz prednasky


# ma cenu definovat ruzne navratove kody pro ruzne chyby?









#-------------------------------------------------------------------------------
# function to print warning message
# parameters:
#   function takes one argument, it is printed to the standart output
#-------------------------------------------------------------------------------
function warning()
{
  echo -e "\e[1;33mWARNING: $1\e[0m" >&2    # print in yellow color
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


# dodelat prepinac -c !!!!!! -E take
#=====================
#=====================
#=====================
#=====================
#=====================
#=====================
#=====================





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

  [[ $# -lt 2 ]] && usage     # print how to use

  while getopts ":t:X:x:Y:y:S:T:F:l:g:e:f:n:v" opt  	# cycle for processing the switches
  do
   case "$opt" in
      t) # TIMEFORM
         # ma smysl tu nejak testovat hodnotu v OPTARG, pokud ano, tak jak?
         
		 [ -z "$OPTARG" ] && error "the value of the switch -t was not provided"
         SWITCHES[$((switches_idx++))]="t"	# save the processed switch
         CONFIG["t"]="$OPTARG";;            # save the argument of the switch

      X) # XMAX
		 [ -z "$OPTARG" ] && error "the value of the switch -X was not provided"
		 
         # TADY JESTE DODELAT KONTRENI HODNOTU !!!
         # JE TO ZAVISLE NA DEFINOVANEM CASOVEM FORMATU
         # TADY JESTE MUZE NASTAT PROBLEM S TIM, ZE -X BUDE UVEDENO DRIVE NEZ -t A PAK BY MOHL NASTAT PROBLEM !!!
         

         #echo "(2012-02-11 17:15:00)" | gawk '{if (NR==1) print strftime("(%Y-%m-%d %H:%M:%S)"), $0}'



         #echo "(2012-02-11 17:15:00)" | awk '{print strftime("(%Y-%m-%d %H:%M:%S)"), $0}'
         #echo "$OPTARG" | awk -v d="${CONFIG["t"]}" '{print "datum je" d ; print strftime("(d)"), $0}'
         
         
         #echo "$OPTARG" | awk -v d="${CONFIG["t"]}" '{print strftime("(d)"), $0}'
         #echo "$OPTARG" | awk -v d="${CONFIG["t"]}" '{print strftime(d), $0}'
         
         #echo "$OPTARG" | awk -v d="${CONFIG["t"]}" '{print strftime($0)}'
         #echo "$OPTARG" | awk -v f="${CONFIG["t"]}" -v t="$OPTARG" '{print strftime(f, t)}'
         
         
         #echo "$OPTARG" | awk -v f="${CONFIG["t"]}" -v t="$OPTARG" '{print strftime(t, f)}'
         
         
         #echo "$OPTARG" | awk -v f="${CONFIG["t"]}" -v t="$OPTARG" '{print strftime(f)}'
         
         #awk -v f="${CONFIG["t"]}" -v t="$OPTARG" '{print strftime(f, t)}'
         
         
         echo "$OPTARG" | awk -v f="${CONFIG["t"]}" -v t="$OPTARG" '{printf("format %s\n", f); printf("timestamp %s\n", t); }'
         
         
         ! [[ "$OPTARG" == "auto" || "$OPTARG" == "max" ]] && {  # none of acceptable values
		   error "wrong argument of the switch -X"; }
         SWITCHES[$((switches_idx++))]="X"	# save the processed switch
         CONFIG["X"]="$OPTARG";;            # save the argument of the switch
      
      x) # XMIN 
		 [ -z "$OPTARG" ] && error "the value of the switch -x was not provided"

         # TADY JESTE DODELAT KONTRENI HODNOTU !!!
         # JE TO ZAVISLE NA DEFINOVANEM CASOVEM FORMATU
         # TADY JESTE MUZE NASTAT PROBLEM S TIM, ZE -X BUDE UVEDENO DRIVE NEZ -t A PAK BY MOHL NASTAT PROBLEM !!!
         


		 ! [[ "$OPTARG" == "auto" || $OPTARG == "min" ]] && { # none of acceptable values
		   error "wrong argument of the switch -x"; }
         SWITCHES[$((switches_idx++))]="x"	# save the processed switch
         CONFIG["x"]="$OPTARG";;            # save the argument of the switch

      Y) # YMAX
		 [ -z "$OPTARG" ] && error "the value of the switch -Y was not provided"
		 ! [[ "$OPTARG" =~ ^-?[0-9]+$ || "$OPTARG" =~ ^-?[0-9]+\.[0-9]+$ || "$OPTARG" == "auto" || "$OPTARG" == "max" ]] && {  # none of acceptable values
		   error "wrong argument of the switch -Y"; }
         SWITCHES[$((switches_idx++))]="Y"	# save the processed switch
         CONFIG["Y"]="$OPTARG";;            # save the argument of the switch

      y) # YMIN
		 [ -z "$OPTARG" ] && error "the value of the switch -y was not provided"
		 ! [[ "$OPTARG" =~ ^-?[0-9]+$ || "$OPTARG" =~ ^-?[0-9]+\.[0-9]+$ || "$OPTARG" == "auto" || $OPTARG == "min" ]] && { # none of acceptable values
		   error "wrong argument of the switch -y"; }
         SWITCHES[$((switches_idx++))]="y"	# save the processed switch
         CONFIG["y"]="$OPTARG";;            # save the argument of the switch

      S) # SPEED
		 [ -z "$OPTARG" ] && error "the value of the switch -S was not provided"
		 ! [[ "$OPTARG" =~ ^[0-9]+$ || "$OPTARG" =~ ^[0-9]+\.[0-9]+$ ]] && {	# non-numeric value, should be int/float
		   error "wrong argument of the switch -S"; }
         SWITCHES[$((switches_idx++))]="S"	# save the processed switch
         CONFIG["S"]="$OPTARG";;            # save the argument of the switch

      T) # TIME
		 [ -z "$OPTARG" ] && error "the value of the switch -T was not provided"
		 ! [[ "$OPTARG" =~ ^[0-9]+$ || "$OPTARG" =~ ^[0-9]+\.[0-9]+$ ]] && {	# non-numeric value, should be int/float
		   error "wrong argument of the switch -T"; }
         SWITCHES[$((switches_idx++))]="T"	# save the processed switch
         CONFIG["T"]="$OPTARG";;            # save the argument of the switch

      F) # FPS
		 [ -z "$OPTARG" ] && error "the value of the switch -F was not provided"
		 ! [[ "$OPTARG" =~ ^[0-9]+$ || "$OPTARG" =~ ^[0-9]+\.[0-9]+$ ]]	&& { # non-numeric value, should be int/float
           error "wrong argument of the switch -F"; }
         SWITCHES[$((switches_idx++))]="F"	# save the processed switch
         CONFIG["F"]="$OPTARG";;            # save the argument of the switch

      c) # CRITICALVALUE
		 [ -z "$OPTARG" ] && error "the value of the switch -c was not provided"
         SWITCHES[$((switches_idx++))]="c"	# save the processed switch
         
         # kontrola hodnoty
          
		 GNUPLOTPARAMS[$((gp_params_idx++))]="$OPTARG";; # save the argument of the switch, no value check needed

      l) # LEGEND		 
		 [ -z "$OPTARG" ] && error "the value of the switch -l was not provided"
         SWITCHES[$((switches_idx++))]="l"	# save the processed switch
         CONFIG["l"]="$OPTARG";;            # save the argument of the switch

      g) # GNUPLOTPARAMS
		 [ -z "$OPTARG" ] && error "the value of the switch -g was not provided"
         SWITCHES[$((switches_idx++))]="g"	# save the processed switch
		 GNUPLOTPARAMS[$((gp_params_idx++))]="$OPTARG";; # save the argument of the switch, no value check needed
   
   
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

         # tady jeste muze nastat situace, ze soubor lze cist -> ale cesta je takova, ze ho nelze napr ani listovat
         # => /root/.bashrc

         SWITCHES[$((switches_idx++))]="f"	# save the processed switch
         CONFIG["f"]="$OPTARG";;            # save the argument of the switch

      n) # NAME
		 [ -z "$OPTARG" ] && error "the value of the switch -n was not provided"
         SWITCHES[$((switches_idx++))]="n"	# save the processed switch
         CONFIG["n"]="$OPTARG";;            # save the argument of the switch

      v) # VERBOSE
         SWITCHES[$((switches_idx++))]="v"	# save the processed switch
         CONFIG["v"]="1"
         VERBOSE=1;;                        # set the value of global variable

     \?) echo "accepted switches: t, X, x, Y, y, S, T, F, c, l, g, e, f, n, v"; 	# undefined switch
		 exit 2;;
   esac
  done
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# function for checking the data files
#	1) "$@" - all remaining arguments, which vere provided on execution - data files
# function checks if the files exist and if they are readable
# result of the processing is saved in the global variables
# mohlo by se zkoumat zda na sebe i napr nejak navazuji ?
# dale by bylo vhodne konktrolovat zda neni soubor na webu, pokud ano, tak stahnout abychom s nim mohli dale pracovat
# je nutne ukladat data nekam do docasneho umisteni
#
# -> mktemp
#

#-------------------------------------------------------------------------------




#-------------------------------------------------------------------------------
# funkce pro kontrolu datovych souboru
#	1) "$@" - vsechny zbyle argumenty, ktere byly zadany pri spusteni - datove soubory
# probiha pouze kontrola, zda soubory existuji, jsou citelne
# mohlo by se zkoumat zda na sebe i napr nejak navazuji ?
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

# tady pridelat nejakou dalsi kontrolu neceho .. 
# kontrola poctu zaznamu -> pokud mame vice souboru, tak nas zajima, zda kreslime do jednoho grafu vice krivek
  if [[ $# -gt 1 ]]
  then

    local words=$(head -1 ${DATA[0]} | wc -w)
    local cols
    local ret

    for((j = 1; j < "$words"; j++))
    do
      cols=$(echo "${cols}${j},")     # add column number
    done

    cols=$(echo "${cols%,}")          # cut off the first , from the left

    for i in "${DATA[@]}"
    do
      [[ $(wc -l < "${DATA[0]}") -ne $(wc -l < "$i") ]] && { MULTIPLOT="false"; return; }
      
      # na toto se jeste poptat, zda je implicitne timeformat a hodnota oddelena mezerou
      # dale, muze byt vice hodnot pro jeden casovy udaj v jednom souboru ?
      
      # neco takoveho pouzit v pripade, ze je v jednom souboru povoleno vice hodnot pro jeden casovy udaj

      ret=$(diff <(cat ${DATA[0]} | cut -d" " -f${cols}) <(cat $i | cut -d" " -f${cols}))
      #[[ $(diff <(cat ${DATA[0]} | cut -d" " -f${cols}) <(cat $i | cut -d" " -f${cols}) &>/dev/null) -ne 0 ]] && { echo "diff"; MULTIPLOT="false"; return; }

      [[ "$ret" != "" ]] && { MULTIPLOT="false"; return; }

    done
  fi
  
  MULTIPLOT="true"



  # tady jeste ty soubory seradit ve spravnem poradi dle casu, pokud na sebe nenavazuji ?

}


#-------------------------------------------------------------------------------
# fucntion for reading the configuration file
# parameters:
#	1) the configuration file
# the result of the processing is saved in the global variables
# when an error occurs it is sent to the error function

# je dovolen prazdny(neobsahujici zadne direktivy) konfiguracni soubor?

#-------------------------------------------------------------------------------
function readConfig()
{
  [[ "${CONFIG["f"]}" != "" ]] || return;        # configuration file was not provided
  [[ $(wc -l < "${CONFIG["f"]}") -eq 0 ]] && { warning "provided configuration file \"${CONFIG["f"]}\" is empty"; return; } # empty configuration file


  len=${#SWITCHES[@]}	# number

  # indexace pomocneho pole
  switches_idx=${#SWITCHES[@]}	# delka pole, budeme zapisovat dal
  #X=${#SWITCHES[@]}	# promenna pro kontrolu, zda vubec konfiraguracni soubor neco obsahuje
  # ve vysledku mozna nebude treba?


#
#
#
#       JESTE KONTROLA, ZDA CTEME VSECHNY V ZADANI DEFINOVANE DIREKTIVY - PREPINACE
#


  local ret
  # variable for checking values of the configuration directives



  # ==================================
  # TIMEFORMAT
  if ! [[ "${SWITCHES[@]}" =~ t ]]	# check if this particular switch was processed on command line
  then

    # znak # predstavuje komentar az do konce radku
    # prazdne radky jsou nevyznamne, stejne tak jako radky obsahujici pouze mezery a taby
    # na jednom radku maximalne jedna direktiva             ==== JAK TO RESIT ?????
    # Direktiva má právě jednu hodnotu (odpovídá jednomu arumentu na příkazové řádce). - toto by se dalo jednoduse resit pomoci wc, ale problem s gnuplotparams -> viz ukazkovy konfiguracni soubor
    

    ret=$(sed -n '/^[^#]*TimeFormat /Ip' "$1" | sed -n 's/^.*TimeFormat/TimeFormat/I; s/TimeFormat[[:space:]]*/TimeFormat /; s/TimeFormat //; s/[[:space:]]*#.*$//; $p')
    
    echo "TIMEFORMAT:: ret: $ret"


    # nezacina znakem #, pak je cokoliv, pak TimeFormat
    # hodnota a direktiva jsou oddeleny pomoci mezery, tabulatoru pripadne jejich kombinaci

    #[[ $( -n '/^[^#].*TimeFormat/Ip' "$1" | sed -n 's/^.*TimeFormat/TimeFormat/I; s/TimeFormat[[:space:]]*/TimeFormat /; s/TimeFormat //; $p') ]]
    # kontrola hodnoty - jak na to v tomto pripade?
  fi
  
  
  # ==================================
  #XMAX
  # DOPLNIT KONKRETNI HODNOTY !!!
  if ! [[ "${SWITCHES[@]}" =~ X ]]	# check if this particular switch was processed on command line
  then
    ret=$(sed -n '/^[^#]*Xmax /Ip' "$1" | sed -n 's/^.*Xmax/Xmax/I; s/Xmax[[:space:]]*/Xmax /; s/Xmax //; s/[[:space:]]*#.*$//; $p')


    echo "XMAX:: ret: $ret"

    # TOTO PREDELAT ---> "RET" == "" JE NESMYSL !!!

    #! [[ "$ret" == "auto" || "$ret" == "max" || "$ret" == "" ]] && {  # none of acceptable values or the directive was not found
    #  error "wrong argument of the Xmax directive in configuration file \"$1\""; }

  fi
  
  # ==================================
  #XMIN
  # DOPLNIT KONKRETNI HODNOTY !!!
  if ! [[ "${SWITCHES[@]}" =~ x ]]	# check if this particular switch was processed on command line
  then
    ret=$(sed -n '/^[^#]*Xmin /Ip' "$1" | sed -n 's/^.*Xmin/Xmin/I; s/Xmin[[:space:]]*/Xmin /; s/Xmin //; s/[[:space:]]*#.*$//; $p')

    echo "XMIN:: ret: $ret"

    # TOTO PREDELAT ---> "RET" == "" JE NESMYSL !!!

    #! [[ "$ret" == "auto" || "$ret" == "min" || "$ret" == "" ]] && {  # none of acceptable values or the directive was not found
    #  error "wrong argument of the Xmin directive in configuration file \"$1\""; }

  fi

  # ==================================
  # YMAX
  if ! [[ "${SWITCHES[@]}" =~ Y ]]	# check if this particular switch was processed on command line
  then
    
    ret=$(sed -n '/^[^#]*Ymax /Ip' "$1" | sed -n 's/^.*Ymax/Ymax/I; s/Ymax[[:space:]]*/Ymax /; s/Ymax //; s/[[:space:]]*#.*$//; $p')
    
    if [[ "$ret" != "" ]]   # was provided in configuration file
    then
    
      ! [[ "$ret" =~ ^-?[0-9]+$ || "$ret" =~ ^-?[0-9]+\.[0-9]+$ || "$ret" == "auto" || "$ret" == "max" ]] && {  # none of acceptable values
        error "wrong argument of the Ymax directive in configuration file \"$1\""; }

      CONFIG["Y"]="$ret"
      verbose "value of the configuration directive Ymax: $ret"
    fi
  fi

  # ==================================
  # YMIN
  if ! [[ "${SWITCHES[@]}" =~ y ]]	# check if this particular switch was processed on command line
  then

    ret=$(sed -n '/^[^#]*Ymin /Ip' "$1" | sed -n 's/^.*Ymin/Ymin/I; s/Ymin[[:space:]]*/Ymin /; s/Ymin //; s/[[:space:]]*#.*$//; $p')

    if [[ "$ret" != "" ]]   # was provided in configuration file
    then

      ! [[ "$ret" =~ ^-?[0-9]+$ || "$ret" =~ ^-?[0-9]+\.[0-9]+$ || "$ret" == "auto" || "$ret" == "min" ]] && {  # none of acceptable values
        error "wrong argument of the Ymin directive in configuration file \"$1\""; }
      
      CONFIG["y"]="$ret"
      verbose "value of the configuration directive Ymin: $ret"
    fi
  fi

  # ==================================
  # SPEED
  if ! [[ "${SWITCHES[@]}" =~ S ]]	# check if this particular switch was processed on command line
  then
    ret=$(sed -n '/^[^#]*Speed /Ip' "$1" | sed -n 's/^.*Speed/Speed/I; s/Speed[[:space:]]*/Speed /; s/Speed //; s/[[:space:]]*#.*$//; $p')

    if [[ "$ret" != "" ]]   # was provided in configuration file
    then

      ! [[ "$ret" =~ ^[0-9]+$ || "$ret" =~ ^[0-9]+\.[0-9]+$ ]] && {  # none of acceptable values
        error "wrong argument of the Speed directive in configuration file \"$1\""; }
      
      CONFIG["S"]="$ret"
      verbose "value of the configuration directive Speed: $ret"
    fi
  fi

  # ==================================
  # TIME
  if ! [[ "${SWITCHES[@]}" =~ T ]]	# check if this particular switch was processed on command line
  then
    ret=$(sed -n '/^[^#]*Time /Ip' "$1" | sed -n 's/^.*Time/Time/I; s/Time[[:space:]]*/Time /; s/Time //; s/[[:space:]]*#.*$//; $p')
    
    if [[ "$ret" != "" ]]   # was provided in configuration file
    then

      ! [[ "$ret" =~ ^[0-9]+$ || "$ret" =~ ^[0-9]+\.[0-9]+$ ]] && {  # none of acceptable values
        error "wrong argument of the Time directive in configuration file \"$1\""; }

      CONFIG["T"]="$ret"
      verbose "value of the configuration directive Time: $ret"
    fi
  fi

  # ==================================
  # FPS
  if ! [[ "${SWITCHES[@]}" =~ F ]]	# check if this particular switch was processed on command line
  then
    ret=$(sed -n '/^[^#]*FPS /Ip' "$1" | sed -n 's/^.*FPS/FPS/I; s/FPS[[:space:]]*/FPS /; s/FPS //; s/[[:space:]]*#.*$//; $p')
  
    if [[ "$ret" != "" ]]   # was provided in configuration file
    then

      ! [[ "$ret" =~ ^[0-9]+$ || "$ret" =~ ^[0-9]+\.[0-9]+$ ]] && {  # none of acceptable values
        error "wrong argument of the FPS directive in configuration file \"$1\""; }

      CONFIG["F"]="$ret"
      verbose "value of the configuration directive FPS: $ret"
    fi
  fi

  # ==================================
  # CRITICALVALUE
  if ! [[ "${SWITCHES[@]}" =~ c ]]	# check if this particular switch was processed on command line
  then
    ret=$(sed -n '/^[^#]*CriticalValue /Ip' "$1" | sed -n 's/^.*CriticalValue/CriticalValue/I; s/CriticalValue[[:space:]]*/CriticalValue /; s/CriticalValue //; s/[[:space:]]*#.*$//; $p')
  
    echo "CRITICALVALUE:: ret: $ret"


  fi

  # ==================================
  # LEGEND
  if ! [[ "${SWITCHES[@]}" =~ l ]]	# check if this particular switch was processed on command line
  then
    ret=$(sed -n '/^[^#]*Legend /Ip' "$1" | sed -n 's/^.*Legend/Legend/I; s/Legend[[:space:]]*/Legend /; s/Legend //; s/[[:space:]]*#.*$//; $p')
  
    if [[ "$ret" != "" ]]   # was provided in configuration file
    then
      CONFIG["l"]="$ret"
      verbose "value of the configuration directive Legend: $ret"
    fi
  fi

  # ==================================
  # GNUPLOTPARAMS
  if ! [[ "${SWITCHES[@]}" =~ g ]]	# check if this particular switch was processed on command line
  then
    ret=$(sed -n '/^[^#]*GnuplotParams /Ip' "$1" | sed -n 's/^.*GnuplotParams/GnuplotParams/I; s/GnuplotParams[[:space:]]*/GnuplotParams /; s/GnuplotParams //; s/[[:space:]]*#.*$//; $p')

    echo "GNUPLOTPARAMS:: ret: $ret"
    
#    CNT=`cat $1 | grep ^[a-Z] | grep "GnuplotParams" | wc -l`
#    B=0
#    for ((i=1; i<=$CNT; i++))
#    do
#      VAL=`cat $1 | grep ^[a-Z] | grep "GnuplotParams" | sed 's/ *#.*// ; s/GnuplotParams //' | awk '{if(NR=='$i') print }'`
#      GNUPLOTPARAMS[$B]=$VAL
#	  ((B++))
#    done
#	[ $CNT -gt 1 ] && { 
#	  # direktiva je v souboru uvedena alespon 1x
#	  SWITCHES[$switches_idx]="g";	# zapamutujeme si zpracovanou direktivu pro kontrolu, zda byla zadana hodnota
#	  ((switches_idx++));
#	}
  fi

  # ==================================
  # EFFECTPARAMS
  # direktiva muze byt uvedene vicekrat, kontrola neni potreba
  if ! [[ "${SWITCHES[@]}" =~ e ]]	# check if this particular switch was processed on command line
  then
    ret=$(sed -n '/^[^#]*EffectParams /Ip' "$1" | sed -n 's/^.*EffectParams/EffectParams/I; s/EffectParams[[:space:]]*/EffectParams /; s/EffectParams //; s/[[:space:]]*#.*$//; $p')

    echo "EFFECTPARAMS:: ret: $ret"

  #[ `cat $1 | grep ^[a-Z] | sed 's/#.*//' | awk 'BEGIN{IGNORECASE=1} /EffectParams/' | wc -w` -gt 2 ] && 
  #{ echo "direktiva EffectParams obsahuje vice nez jedno klicove slovo"; exit 1; }    		# direktiva obsahuje vice klicovych slov
  #TMP=`cat $1 | grep ^[a-Z] | grep -i "EffectParams" | awk '{print $2}'`
  #TMP=`echo "$TMP" | tr ":" " "`	# zmena oddelovace na mezeru, abychom mohli iterovat
  #if [[ ! $TMP =~ ^$ ]]		# neni prazdny retezec
  #then
  #  A=0
  #  for i in $TMP
  #  do
  #     if ! [[ $i =~ ^bgcolor=.*$ || $i =~ ^changebgcolor$ || $i =~ ^changespeed=[1-5]$ ]]
  #     then
  #       echo "spatny format direktivy EffectParams v zadanem konfiguracnim souboru"
  #       exit 1;
  #    fi
  #    EFFECTPARAMS[$A]=$i	# ok, uloz do pole
  #    ((A++))
  #  done
  #  SWITCHES[$switches_idx]="e"	# zapamutujeme si zpracovanou direktivu pro kontrolu, zda byla zadana hodnota
  #  ((switches_idx++))
  fi

  # ==================================
  # NAME
  if ! [[ "${SWITCHES[@]}" =~ n ]]	# check if this particular switch was processed on command line
  then
    ret=$(sed -n '/^[^#]*Name /Ip' "$1" | sed -n 's/^.*Name/Name/I; s/Name[[:space:]]*/Name /; s/Name //; s/[[:space:]]*#.*$//; $p')
  
    if [[ "$ret" != "" ]]   # was provided in configuration file
    then
      CONFIG["n"]="$ret"
      verbose "value of the configuration directive Name: $ret"
    fi
  fi
  
  # ==================================
  # ERRORS
  if ! [[ "${SWITCHES[@]}" =~ E ]]	# check if this particular switch was processed on command line
  then
    ret=$(sed -n '/^[^#]*IgnoreErrors /Ip' "$1" | sed -n 's/^.*IgnoreErrors/IgnoreErrors/I; s/IgnoreErrors[[:space:]]*/IgnoreErrors /; s/IgnoreErrors //; s/[[:space:]]*#.*$//; $p')

    echo "ERRORS:: ret: $ret"

 # [ `cat $1 | grep ^[a-Z] | grep -i "IgnoreErrors" | wc -l` -gt 1 ] && 
 # { echo "direktiva IgnoreErrors je v zadanem konfiguracnim souboru $CONFIG uvedena vicekrat"; exit 1; }    # direktiva je v souboru uvedena vice nez jednou
 # [ `cat $1 | grep ^[a-Z] | sed 's/#.*//' | awk 'BEGIN{IGNORECASE=1} /IgnoreErrors/' | wc -w` -gt 2 ] && 
 #   { echo "direktiva IgnoreErrors v zadanem konfiguracnim souboru $CONFIG obsahuje vice hodnot"; exit 1; }    		# direktiva obsahuje vice hodnot
 # TMP=`cat $1 | grep ^[a-Z] | grep -i "IgnoreErrors" | awk '{print $2}'`
 # if ! [[ $TMP =~ ^$ ]]
 # then
 #   if ! [[ "$TMP" == "true" || "$TMP" == "false" ]]		# ma spatny format
 #   then
 #     echo "spatny format direktivy IgnoreErrors v zadanem konfiguracnim souboru"
 #     echo "direktiva pripousti pouze hodnoty true, false"
 #     exit 1;
 #   fi
 #   ERRORS=$TMP	# ok, direktiva je evedena a ma spravnou hodnotu
  fi


#  [[ $X -eq $switches_idx ]] && { echo "zadany konfiguracni soubor $CONFIG neobsahuje zadne direktivy"; exit 1; }
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
  CONFIG["f"]=""                    # configuration file
  CONFIG["n"]=""                    # name of the output directory
  CONFIG["l"]=""                    # legend of the graph


  # doplnit neimplementovane prepinace -c, -E
  
  typeset -a SWITCHES       # field for all processed switches
  typeset -a DATA			# filed containing data files
  typeset -a TEMPFILES		# temporary files
  typeset -a GNUPLOTPARAMS  # field for gnuplot parameters
  typeset -a EFFECTPARAMS   # field for effect parameters
  typeset -a CRITICALVALUES # field for critical values

  GNUPLOTDEF=0
  FRAMES=0					# celkovy pocet generovanych snimku
  RECORDS=0					# pocet zaznamu v souboru
  TIMEREGEX=0
  MULTIPLOT="false"
  CHANGESPEED=1				# rychlost zmeny barvy pozadi
  DIRECTION=0				# "smer", kterym menime barvu pozadi
  VERBOSE=0


#-------------------------------------------------------------------------------
  readParams "$@"
  shift `expr $OPTIND - 1`	# posun na prikazove radce

  verbose "processed switches ${SWITCHES[@]}"         # report processed switches

  for i in "${SWITCHES[@]}"
  do
    verbose "value of the switch -$i: ${CONFIG["$i"]}" # report values of all entered switches
  done

  readConfig "${CONFIG["f"]}"   # read the configuration file

  checkFiles "$@"           # check the data files at this point, so its not necessary later - possible errors are solved close to the start
  verbose "data files ${DATA[@]}"   # report data files


  # pouze debug
  echo "MULTIPLOT: $MULTIPLOT"



