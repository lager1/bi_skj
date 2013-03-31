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



#
# pokud by se melo kreslit vice grafu pro stejny casovy interval, tak:
# pokud se neshouji casove udaje pro vsechny soubory -> odriznout prvni casti vsech souboru a navzajem porovnat diffem
# -> error uzivateli, spatny format dat



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
# function for reporting information about script progress
# parameters:
#   function takes arbitrary number of arguments
# all of the parameters ale printed to the standart output
#-------------------------------------------------------------------------------
function verbose()
{
  (($VERBOSE)) || return
  
  echo -n "VERBOSE: "

  for i in "$@"
  do
    echo -n "$i "
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
    echo -e "ERROR: $i" >&2
  done

  echo "exitting"

  exit 1;
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
  local eff_params_idx=0    # indexing of $GNUPLOTPARAMS 

  while getopts ":t:X:x:Y:y:S:T:F:l:g:e:f:n:v" opt  	# cycle for processing the switches
  do
   case "$opt" in
      t) # TIMEFORM
         # ma smysl tu nejak testovat hodnotu v OPTARG, pokud ano, tak jak?
         
		 [ -z "$OPTARG" ] && error "the value of the switch -t was not provided"
         SWITCHES[$((switches_idx++))]="t"	# save the processed switch
         CONFIG["t"]="$OPTARG"
		 TIMEFORM="$OPTARG";; # save the argument of the switch

      X) # XMAX
		 [ -z "$OPTARG" ] && error "the value of the switch -X was not provided"
         SWITCHES[$((switches_idx++))]="X"	# save the processed switch
         CONFIG["X"]="$OPTARG"
		 XMAX="$OPTARG";; # save the argument of the switch
      
      x) # XMIN 
		 [ -z "$OPTARG" ] && error "the value of the switch -x was not provided"
         SWITCHES[$((switches_idx++))]="x"	# save the processed switch
         CONFIG["x"]="$OPTARG"
		 XMIN="$OPTARG";; # save the argument of the switch

      Y) # YMAX
		 [ -z "$OPTARG" ] && error "the value of the switch -Y was not provided"
		 ! [[ "$OPTARG" =~ ^-?[0-9]+$ || "$OPTARG" =~ ^-?[0-9]+\.[0-9]+$ || "$OPTARG" == "auto" || "$OPTARG" == "max" ]] && {  # none of acceptable values
		   error "wrong argument of the switch -Y"; }
         SWITCHES[$((switches_idx++))]="Y"	# save the processed switch
         CONFIG["Y"]="$OPTARG"
		 YMAX="$OPTARG";; # save the argument of the switch

      y) # YMIN
		 [ -z "$OPTARG" ] && error "the value of the switch -y was not provided"
		 ! [[ "$OPTARG" =~ ^-?[0-9]+$ || "$OPTARG" =~ ^-?[0-9]+\.[0-9]+$ || "$OPTARG" == "auto" || $OPTARG == "min" ]] && { # none of acceptable values
		   error "wrong argument of the switch -y"; }
         SWITCHES[$((switches_idx++))]="y"	# save the processed switch
         CONFIG["y"]="$OPTARG"
		 YMIN="$OPTARG";; # save the argument of the switch

      S) # SPEED
		 [ -z "$OPTARG" ] && error "the value of the switch -S was not provided"
		 ! [[ "$OPTARG" =~ ^[0-9]+$ || "$OPTARG" =~ ^[0-9]+\.[0-9]+$ ]] && {	# non-numeric value, should be int/float
		   error "wrong argument of the switch -S"; }
         SWITCHES[$((switches_idx++))]="S"	# save the processed switch
         CONFIG["S"]="$OPTARG"
		 SPEED="$OPTARG";; # save the argument of the switch

      T) # DURATION
		 [ -z "$OPTARG" ] && error "the value of the switch -T was not provided"
		 ! [[ "$OPTARG" =~ ^[0-9]+$ || "$OPTARG" =~ ^[0-9]+\.[0-9]+$ ]] && {	# non-numeric value, should be int/float
		   error "wrong argument of the switch -T"; }
         SWITCHES[$((switches_idx++))]="T"	# save the processed switch
         CONFIG["T"]="$OPTARG"
		 DURATION="$OPTARG";; # save the argument of the switch

      l) # LEGEND		 
		 [ -z "$OPTARG" ] && error "the value of the switch -l was not provided"
         SWITCHES[$((switches_idx++))]="l"	# save the processed switch
         CONFIG["l"]="$OPTARG"
		 LEGEND="$OPTARG";; # save the argument of the switch, no value check needed

      g) # GNUPLOTPARAMS
		 [ -z "$OPTARG" ] && error "the value of the switch -g was not provided"
         SWITCHES[$((switches_idx++))]="g"	# save the processed switch
         CONFIG["g"]="$OPTARG"
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
         CONFIG["e"]="$OPTARG"
         SWITCHES[$((switches_idx++))]="e";;	# save the processed switch
		 
      f) # CONFIG
		 [ -z "$OPTARG" ] && error "the value of the switch -f was not provided"
		 ! [ -e $OPTARG ] && error "provided configuration file \"$OPTARG\" does not exist"
		 ! [ -f $OPTARG ] && error "provided configuration file \"$OPTARG\" is not a regular file"
		 ! [ -r $OPTARG ] && error "provided configuration file \"$OPTARG\" cannot be read"

         # tady jeste muze nastat situace, ze soubor lze cist -> ale cesta je takova, ze ho nelze napr ani listovat
         # => /root/.bashrc

         SWITCHES[$((switches_idx++))]="f"	# save the processed switch
         CONFIG["f"]="$OPTARG"
		 CONFIG="$OPTARG";;	# save the argument of the switch

      n) # NAME
		 [ -z "$OPTARG" ] && error "the value of the switch -n was not provided"
         SWITCHES[$((switches_idx++))]="n"	# save the processed switch
         CONFIG["n"]="$OPTARG"
		 NAME="$OPTARG";; # save the argument of the switch, no value check needed

      F) # FPS
		 [ -z "$OPTARG" ] && error "the value of the switch -F was not provided"
		 ! [[ "$OPTARG" =~ ^[0-9]+$ || "$OPTARG" =~ ^[0-9]+\.[0-9]+$ ]]	&& { # non-numeric value, should be int/float
           error "wrong argument of the switch -F"; }
         SWITCHES[$((switches_idx++))]="F"	# save the processed switch
         CONFIG["F"]="$OPTARG"
		 FPS="$OPTARG";; # save the argument of the switch

      v) # VERBOSE
         SWITCHES[$((switches_idx++))]="v"	# save the processed switch
         CONFIG["v"]="1"
         VERBOSE=1;; # set the value of global variable

     \?) echo "accepted switches: t, X, x, Y, y, S, T, F, c, l, g, e, f, n, v"; 	# undefined switch
		 exit 2;;
   esac
  done
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
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
    local t1
    local t2

    for((j = 1; j < "$words"; j++))
    do
      cols=$(echo "${cols}${j},")     # add column number
    done

    cols=$(echo "${cols%,}")          # cut off the first , from the left

    echo "words: $words"
    echo "cols: $cols"

    for i in "${DATA[@]}"
    do
      [[ $(wc -l < "${DATA[0]}") -ne $(wc -l < "$i") ]] && { MULTIPLOT="false"; return; }
      

      # na toto se jeste poptat, zda je implicitne timeformat a hodnota oddelena mezerou
      # dale, muze byt vice hodnot pro jeden casovy udaj v jednom souboru ?
      
      # neco takoveho pouzit v pripade, ze je v jednom souboru povoleno vice hodnot pro jeden casovy udaj

      ret=$(diff <(cat ${DATA[0]} | cut -d" " -f${cols}) <(cat $i | cut -d" " -f${cols}))
      #[[ $(diff <(cat ${DATA[0]} | cut -d" " -f${cols}) <(cat $i | cut -d" " -f${cols}) &>/dev/null) -ne 0 ]] && { echo "diff"; MULTIPLOT="false"; return; }

      [[ "$ret" != "" ]] && { echo "diff"; MULTIPLOT="false"; return; }


    done
  fi
  
  MULTIPLOT="true"

  echo "MULTIPLOT: $MULTIPLOT"

}


# predelano -> staci kdyz bude vracet pouze true/false


#-------------------------------------------------------------------------------
# funkce pro kontrolu, zda je jsme zpracovali zadany prepinac
# parametry:
#	1) prepinac, ktery kontrolujeme
# navratova hodnota: cislo, ktere rika, kolikrat byl dany prepinac
# (direktiva v konfiguracnim souboru) zpracovan
#-------------------------------------------------------------------------------




#-------------------------------------------------------------------------------
# funkce pro kontrolu, zda je jsme zpracovali zadany prepinac
# parametry:
#	1) prepinac, ktery kontrolujeme
# navratova hodnota -> 1 ==> prepinac jsme zpracovali
#                      0 ==> prepinac jsme nezpracovali



# pokud bychom meli nekolik konfiguracnich souboru, tak by mohl byt problem
# -> nedostali bychom posledni hodnotu
# -> konfiguracni soubor muze byt pouze jeden -> posledni zadany na prikazove radce


# navratova hodnota: cislo, ktere rika, kolikrat byl dany prepinac
# (direktiva v konfiguracnim souboru) zpracovan
#-------------------------------------------------------------------------------
function checkSwitch()
{
  for i in ${SWITCHES[@]}
  do
    [[ $i == $1 ]] && return 1;
  done
  return 0;
}


#-------------------------------------------------------------------------------
# fucntion for reading the configuration file
# parameters:
#	1) the configuration file
# the result of the processing is saved in the global variables
# when an error occurs it is sent to the error function

# je dovolen prazdny(neobsahujici zadne direktivi) konfiguracni soubor?

#-------------------------------------------------------------------------------
function readConfig()
{
  # indexace pomocneho pole
  switches_idx=${#SWITCHES[@]}	# delka pole, budeme zapisovat dal
  #X=${#SWITCHES[@]}	# promenna pro kontrolu, zda vubec konfiraguracni soubor neco obsahuje
  # ve vysledku mozna nebude treba?

  # TIMEFORM
  #if [[ checkSwitch t -eq 0 ]]	# zkoumame, zda jsme prepinac zpracovali
  #if [[ checkSwitch -eq 0 ]]	# zkoumame, zda jsme prepinac zpracovali
  if [[ "$(checkSwitch) t" -eq 0 ]]	# zkoumame, zda jsme prepinac zpracovali
  then

    echo "hm"

  #  [ `cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /TimeFormat/' | wc -l` -gt 1 ] && 
  #  { echo "direktiva TimeFormat je v zadanem konfiguracnim souboru $CONFIG uvedena vicekrat"; exit 1; }    # direktiva je v souboru uvedena vice nez jednou
  #	TMP=`cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /TimeFormat/' | sed 's/TimeFormat //'`
  #	! [[ $TMP =~ ^$ ]] && TIMEFORM=$TMP	# ok, direktiva je evedena
  fi

  # YMAX
  # jedna hodnota ~ jedno slovo
  if checkSwitch Y # zkoumame, zda jsme prepinac zpracovali
  then
    [ `cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /Ymax/' | wc -l` -gt 1 ] && 
    { echo "direktiva Ymax je v zadanem konfiguracnim souboru $CONFIG uvedena vicekrat"; exit 1; }    # direktiva je v souboru uvedena vice nez jednou
    [ `cat $1 | grep ^[a-Z] | sed 's/#.*//' | awk 'BEGIN{IGNORECASE=1} /Ymax/' | wc -w` -gt 2 ] && 
    { echo "direktiva Ymax v zadanem konfiguracnim souboru $CONFIG obsahuje vice hodnot"; exit 1; }    		# direktiva obsahuje vice hodnot
      TMP=`cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /Ymax/ {print $2}'`
    if [[ ! $TMP =~ ^$ ]]		# neni prazdny retezec
    then
      if [[ ! $TMP =~ ^-?[0-9]+$ && ! $TMP =~ ^-?[0-9]+\.[0-9]+$ && ! $TMP == "auto" && ! $TMP == "max" ]]		# ma spatny format
      then
        echo "spatny format direktivy Ymax v zadanem konfiguracnim souboru"
        exit 1;
      fi
      YMAX=$TMP	# ok, direktiva je evedena a ma spravny format
    fi
  fi

  # YMIN
  # jedna hodnota ~ jedno slovo
  if checkSwitch y # zkoumame, zda jsme prepinac zpracovali
  then
    [ `cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /Ymin/' | wc -l` -gt 1 ] && 
    { echo "direktiva Ymin je v zadanem konfiguracnim souboru $CONFIG uvedena vicekrat"; exit 1; }    # direktiva je v souboru uvedena vice nez jednou
    [ `cat $1 | grep ^[a-Z] | sed 's/#.*//' | awk 'BEGIN{IGNORECASE=1} /Ymin/' | wc -w` -gt 2 ] && 
    { echo "direktiva Ymin v zadanem konfiguracnim souboru $CONFIG obsahuje vice hodnot"; exit 1; }    		# direktiva obsahuje vice hodnot
    TMP=`cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /Ymin/ {print $2}'`
    if [[ ! $TMP =~ ^$ ]]		# neni prazdny retezec
    then
      if [[ ! $TMP =~ ^-?[0-9]+$ && ! $TMP =~ ^-?[0-9]+\.[0-9]+$ && ! $TMP == "auto" && ! $TMP == "min" ]]		# ma spatny format
      then
        echo "spatny format direktivy Ymin v zadanem konfiguracnim souboru"
        exit 1;
      fi
      YMIN=$TMP	# ok, direktiva je evedena a ma spravny format
    fi
  fi

  # SPEED
  # jedna hodnota ~ jedno slovo
  if checkSwitch S # zkoumame, zda jsme prepinac zpracovali
  then
    [ `cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /Speed/' | wc -l` -gt 1 ] && 
    { echo "direktiva Speed je v zadanem konfiguracnim souboru $CONFIG uvedena vicekrat"; exit 1; }    # direktiva je v souboru uvedena vice nez jednou
    [ `cat $1 | grep ^[a-Z] | sed 's/#.*//' | awk 'BEGIN{IGNORECASE=1} /Speed/' | wc -w` -gt 2 ] && 
    { echo "direktiva Speed v zadanem konfiguracnim souboru $CONFIG obsahuje vice hodnot"; exit 1; }    		# direktiva obsahuje vice hodnot
    TMP=`cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /Speed/ {print $2}'`
    if [[ ! $TMP =~ ^$ ]]		# neni prazdny retezec
    then
      if ! [[ $TMP =~ ^[0-9]+$ || $TMP =~ ^[0-9]+\.[0-9]+$ ]]		# ma spatny format
      then
        echo "spatny format direktivy Speed v zadanem konfiguracnim souboru"
        exit 1;
      fi
      SPEED=$TMP	# ok, direktiva je evedena a ma spravny format
    fi
  fi

  # DURATION
  # jedna hodnota ~ jedno slovo
  if checkSwitch T # zkoumame, zda jsme prepinac zpracovali
  then
    [ `cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /Time /' | wc -l` -gt 1 ] && 
    { echo "direktiva Time je v zadanem konfiguracnim souboru $CONFIG uvedena vicekrat"; exit 1; }    # direktiva je v souboru uvedena vice nez jednou
    [ `cat $1 | grep ^[a-Z] | sed 's/#.*//' | awk 'BEGIN{IGNORECASE=1} /Time /' | wc -w` -gt 2 ] && 
    { echo "direktiva Time v zadanem konfiguracnim souboru $CONFIG obsahuje vice hodnot"; exit 1; }    		# direktiva obsahuje vice hodnot
    TMP=`cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /Time / {print $2}'`
    if [[ ! $TMP =~ ^$ ]]		# neni prazdny retezec
    then
      if ! [[ $TMP =~ ^[0-9]+$ || $TMP =~ ^[0-9]+\.[0-9]+$ ]]		# ma spatny format
      then
        echo "spatny format direktivy Time v zadanem konfiguracnim souboru"
        exit 1;
      fi
      DURATION=$TMP	# ok, direktiva je evedena a ma spravny format
	  SWITCHES[$switches_idx]="T"	# zapamutujeme si zpracovanou direktivu pro kontrolu, zda byla zadana hodnota
	  ((switches_idx++))
    fi
  fi

  # FPS
  # jedna hodnota ~ jedno slovo
  if checkSwitch F # zkoumame, zda jsme prepinac zpracovali
  then
    [ `cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /FPS/' | wc -l` -gt 1 ] && 
    { echo "direktiva FPS je v zadanem konfiguracnim souboru $CONFIG uvedena vicekrat"; exit 1; }    # direktiva je v souboru uvedena vice nez jednou
    [ `cat $1 | grep ^[a-Z] | sed 's/#.*//' | awk 'BEGIN{IGNORECASE=1} /FPS/' | wc -w` -gt 2 ] && 
    { echo "direktiva FPS v zadanem konfiguracnim souboru $CONFIG obsahuje vice hodnot"; exit 1; }    		# direktiva obsahuje vice hodnot
    TMP=`cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /FPS/ {print $2}'`
    if [[ ! $TMP =~ ^$ ]]		# neni prazdny retezec
    then
	  if ! [[ $TMP =~ ^[0-9]+$ || $TMP =~ ^[0-9]+\.[0-9]+$ ]]		# ma spatny format
	  then
	    echo "spatny format direktivy FPS v zadanem konfiguracnim souboru"
	    exit 1;
	  fi
	  FPS=$TMP	# ok, direktiva je evedena a ma spravny format
    fi
  fi

  # EFFECTPARAMS
  # direktiva muze byt uvedene vicekrat, kontrola neni potreba
  [ `cat $1 | grep ^[a-Z] | sed 's/#.*//' | awk 'BEGIN{IGNORECASE=1} /EffectParams/' | wc -w` -gt 2 ] && 
  { echo "direktiva EffectParams obsahuje vice nez jedno klicove slovo"; exit 1; }    		# direktiva obsahuje vice klicovych slov
  TMP=`cat $1 | grep ^[a-Z] | grep -i "EffectParams" | awk '{print $2}'`
  TMP=`echo "$TMP" | tr ":" " "`	# zmena oddelovace na mezeru, abychom mohli iterovat
  if [[ ! $TMP =~ ^$ ]]		# neni prazdny retezec
  then
    A=0
    for i in $TMP
    do
	   if ! [[ $i =~ ^bgcolor=.*$ || $i =~ ^changebgcolor$ || $i =~ ^changespeed=[1-5]$ ]]
       then
         echo "spatny format direktivy EffectParams v zadanem konfiguracnim souboru"
         exit 1;
      fi
      EFFECTPARAMS[$A]=$i	# ok, uloz do pole
      ((A++))
    done
    SWITCHES[$switches_idx]="e"	# zapamutujeme si zpracovanou direktivu pro kontrolu, zda byla zadana hodnota
    ((switches_idx++))
  fi
  
  # ERRORS
  # jedna hodnota ~ jedno slovo
  # prepinac neni implementovan -> nemusime kontrolovat, zda byl zpracovan
  [ `cat $1 | grep ^[a-Z] | grep -i "IgnoreErrors" | wc -l` -gt 1 ] && 
  { echo "direktiva IgnoreErrors je v zadanem konfiguracnim souboru $CONFIG uvedena vicekrat"; exit 1; }    # direktiva je v souboru uvedena vice nez jednou
  [ `cat $1 | grep ^[a-Z] | sed 's/#.*//' | awk 'BEGIN{IGNORECASE=1} /IgnoreErrors/' | wc -w` -gt 2 ] && 
    { echo "direktiva IgnoreErrors v zadanem konfiguracnim souboru $CONFIG obsahuje vice hodnot"; exit 1; }    		# direktiva obsahuje vice hodnot
  TMP=`cat $1 | grep ^[a-Z] | grep -i "IgnoreErrors" | awk '{print $2}'`
  if ! [[ $TMP =~ ^$ ]]
  then
	if ! [[ "$TMP" == "true" || "$TMP" == "false" ]]		# ma spatny format
	then
	  echo "spatny format direktivy EffectParams v zadanem konfiguracnim souboru"
	  echo "direktiva pripousti pouze hodnoty true, false"
	  exit 1;
	fi
    ERRORS=$TMP	# ok, direktiva je evedena a ma spravnou hodnotu
  fi

  # GNUPLOTPARAMS
  if checkSwitch g # zkoumame, zda jsme prepinac zpracovali
  then  # direktiva muze byt uvedene nekolikrat, kontrola neni potreba
    CNT=`cat $1 | grep ^[a-Z] | grep "GnuplotParams" | wc -l`
    B=0
    for ((i=1; i<=$CNT; i++))
    do
      VAL=`cat $1 | grep ^[a-Z] | grep "GnuplotParams" | sed 's/ *#.*// ; s/GnuplotParams //' | awk '{if(NR=='$i') print }'`
      GNUPLOTPARAMS[$B]=$VAL
	  ((B++))
    done
	[ $CNT -gt 1 ] && { 
	  # direktiva je v souboru uvedena alespon 1x
	  SWITCHES[$switches_idx]="g";	# zapamutujeme si zpracovanou direktivu pro kontrolu, zda byla zadana hodnota
	  ((switches_idx++));
	}
  fi

  # LEGEND
  if checkSwitch l # zkoumame, zda jsme prepinac zpracovali
  then
    [ `cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /Legend/' | wc -l` -gt 1 ] && 
    { echo "direktiva Legend je v zadanem konfiguracnim souboru $CONFIG uvedena vicekrat"; exit 1; }    # direktiva je v souboru uvedena vice nez jednou
    TMP=`cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /Legend/' | sed 's/Legend //'`
    if [[ ! $TMP =~ ^$ ]]		# neni prazdny retezec
    then
      LEGEND=$TMP	# ok, direktiva je evedena a ma spravny format
	  SWITCHES[$switches_idx]="l"	# zapamutujeme si zpracovanou direktivu pro kontrolu, zda byla zadana hodnota
	  ((switches_idx++))
    fi
  fi

  # NAME
  if checkSwitch n # zkoumame, zda jsme prepinac zpracovali
  then
    [ `cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /Name/' | wc -l` -gt 1 ] && 
    { echo "direktiva Legend je v zadanem konfiguracnim souboru $CONFIG uvedena vicekrat"; exit 1; }    # direktiva je v souboru uvedena vice nez jednou
    TMP=`cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /Name/ {print $2}'`
    if [[ ! $TMP =~ ^$ ]]		# neni prazdny retezec
    then
      NAME=$TMP	# ok, direktiva je evedena a ma spravny format
	  SWITCHES[$switches_idx]="n"	# zapamutujeme si zpracovanou direktivu pro kontrolu, zda byla zadana hodnota
	  ((switches_idx++))
    fi
  fi


  echo "nic"

#  [[ $X -eq $switches_idx ]] && { echo "zadany konfiguracni soubor $CONFIG neobsahuje zadne direktivy"; exit 1; }
}






#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------
  # main configuration variables, global for whole file
  typeset -A CONFIG                 # asociativni pole pro konfiguracni promenne, indexy jsou prepinace, hodnoty jsou jejich argumenty
  CONFIG["t"]="[%Y-%m-%d %H:%M:%S]" # timestamp format
  CONFIG["X"]="max"                 # maximum x-axis value
  CONFIG["x"]="min"                 # minimum X-axis value
  CONFIG["Y"]="auto"                # maximum y-axis value
  CONFIG["y"]="auto"                # minimum y-axis value
  CONFIG["S"]=1                     # speed - number of data entries in one picture 
  CONFIG["F"]=25                    # frames per second
  CONFIG["f"]=""                    # configuration file
  CONFIG["n"]=""                    # name of the output directory
  CONFIG["l"]=""                    # legend of the graph


  # doplnit neimplementovane prepinace -c, -E
  
  
  
  
  typeset -a SWITCHES       # pole, zapiseme jake prepinace jsme zpracovali
  typeset -a DATA			# pole obsahujici soubory s daty
  typeset -a TEMPFILES		# docasne soubory
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
    verbose "value of the switch -$i ${CONFIG["$i"]}" # report values of all entered switches
  done

  # tuhle podminku dat mozna primo do samotne funkce ?
  [[ "${CONFIG["f"]}" != "" ]] && readConfig "${CONFIG["f"]}"   # read the configuration file

  checkFiles "$@"           # check the data files at this point, so its not necessary later - possible errors are solved close to the start
  verbose "data files ${DATA[@]}"   # report data files



  echo "MULTIPLOT: $MULTIPLOT"

