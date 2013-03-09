#!/bin/bash


#

# semester work from subject BI-SKJ, FIT CVUT, 2013, summer semester
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
# function for printing information about script progress
# parameters:
#   function takes 
# all parameters ale printed to the standart output
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# funkce pro vypisovani informaci o prubehu skriptu
# parametry:
#   funkce bere libovolny pocet parametru
# vsechny parametry jsou vypsany na standartni vystup
#-------------------------------------------------------------------------------
function verbose()
{
  for i in "$@"
  do
    echo "VERBOSE: $i"
  done

  exit 1;
}
#-------------------------------------------------------------------------------











#-------------------------------------------------------------------------------
# funkce pro vypisovani chyb
# parametry:
#   funkce bere libovolny pocet parametru
# vsechny parametry jsou vypsany na standartni chybovy vystup
# funkce nasledne ukoncuje cely skript pomoci exit 1
#-------------------------------------------------------------------------------


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
# funkce pro cteni a vyhodnoceni paramemetru
# parametry:
#	1) "$@" - zpracujeme vsechny prepinace zadane skritu
# vysledek zpracovani je ulozen v globalnich promennych
# pri chybe rovnou koncime program pomoci exit 1
#-------------------------------------------------------------------------------
function readParams()
{
  J=0 # indexace $SWITCHES
  A=0 # indexace $GNUPLOTPARAMS
  B=0 # indexace $EFFECTPARAMS


  while getopts ":t:X:x:Y:y:S:T:F:l:g:e:f:n:v" opt  	# cyklus pro zpracovani prepinacu	
  do
   case "$opt" in
      t) # TIMEFORM
         # ma smysl tu nejak testovat hodnotu v OPTARG, pokud ano, tak jak?
         
		 [ -z "$OPTARG" ] && error "the value of the switch -t was not provided"
         SWITCHES[$((J++))]="t"	# zapamatujeme si zpracovany prepinac
		 TIMEFORM="$OPTARG";; # ok

      X) # XMAX
		 [ -z "$OPTARG" ] && error "the value of the switch -X was not provided"
         SWITCHES[$((J++))]="X"	# zapamatujeme si zpracovany prepinac
		 XMAX="$OPTARG";; # ok
      
      x) # XMIN 
		 [ -z "$OPTARG" ] && error "the value of the switch -x was not provided"
         SWITCHES[$((J++))]="x"	# zapamatujeme si zpracovany prepinac
		 XMIN="$OPTARG";; # ok

      Y) # YMAX
		 [ -z "$OPTARG" ] && error "the value of the switch -Y was not provided"
		 ! [[ "$OPTARG" =~ ^-?[0-9]+$ || "$OPTARG" =~ ^-?[0-9]+\.[0-9]+$ || "$OPTARG" == "auto" || "$OPTARG" == "max" ]] && {  # ani jedna z definovanych hodnot
		   error "spatny parametr prepinace Y"; }
         SWITCHES[$((J++))]="Y"	# zapamatujeme si zpracovany prepinac
		 YMAX="$OPTARG";; 	# ok

      y) # YMIN
		 [ -z "$OPTARG" ] && error "the value of the switch -y was not provided"
		 ! [[ "$OPTARG" =~ ^-?[0-9]+$ || "$OPTARG" =~ ^-?[0-9]+\.[0-9]+$ || "$OPTARG" == "auto" || $OPTARG == "min" ]] && { # ani jedna z definovanych hodnot
		   error "spatny parametr prepinace y"; }
         SWITCHES[$((J++))]="y"	# zapamatujeme si zpracovany prepinac
		 YMIN="$OPTARG";;	# ok

      S) # SPEED
		 [ -z "$OPTARG" ] && error "the value of the switch -S was not provided"
		 ! [[ "$OPTARG" =~ ^[0-9]+$ || "$OPTARG" =~ ^[0-9]+\.[0-9]+$ ]] && {	# neciselna hodnota, mel by byt int/float
		   error "spatny parametr prepinace S"; }
         SWITCHES[$((J++))]="S"	# zapamatujeme si zpracovany prepinac
		 SPEED="$OPTARG";;	# ok

      T) # DURATION
		 [ -z "$OPTARG" ] && error "the value of the switch -T was not provided"
		 ! [[ "$OPTARG" =~ ^[0-9]+$ || "$OPTARG" =~ ^[0-9]+\.[0-9]+$ ]] && {	# neciselna hodnota, mel by byt int/float
		   error "spatny parametr prepinace T"; }
         SWITCHES[$((J++))]="T"	# zapamatujeme si zpracovany prepinac
		 DURATION="$OPTARG";;	# ok

      l) # LEGEND		 
		 [ -z "$OPTARG" ] && error "the value of the switch -l was not provided"
         SWITCHES[$((J++))]="l"	# zapamatujeme si zpracovany prepinac
		 LEGEND="$OPTARG";; #text, neni potreba kontrola

      g) # GNUPLOTPARAMS
		 [ -z "$OPTARG" ] && error "the value of the switch -g was not provided"
		 GNUPLOTPARAMS[$((A++))]="$OPTARG"	# ulozime si hodnotu
         SWITCHES[$((J++))]="g";;	# zapamatujeme si zpracovany prepinac
      
      e) # EFFECTPARAMS
		 [ -z "$OPTARG" ] && error "the value of the switch -e was not provided"
		 OPTARG=`echo "$OPTARG" | tr ":" " "`	# zmena oddelovace na mezeru, abychom mohli iterovat
		 for i in $OPTARG
		 do
		   ! [[ "$i" =~ ^bgcolor=.*$ || "$i" =~ ^changebgcolor$ || "$i" =~ ^changespeed=[1-5]$ ]] && { # kontrola, zda ma promenna spravny tvar
             error "spatny parametr prepinace e"; }
		   EFFECTPARAMS[$((B++))]="$i"	# ok, uloz do pole
	     done
         SWITCHES[$((J++))]="e";;	# zapamatujeme si zpracovany prepinac
		 
      f) # CONFIG
		 [ -z "$OPTARG" ] && error "the value of the switch -f was not provided"
		 ! [ -e $OPTARG ] && error "provided configuration file \"$OPTARG\" does not exist"
		 ! [ -f $OPTARG ] && error "provided configuration file \"$OPTARG\" is not a regular file"
		 ! [ -r $OPTARG ] && error "provided configuration file \"$OPTARG\" cannot be read"

		 #! [ -e $OPTARG ] && error "zadany konfiguracni soubor \"$OPTARG\" neexistuje"
		 #! [ -f $OPTARG ] && error "zadany konfiguracni soubor \"$OPTARG\" neni bezny soubor"
		 #! [ -r $OPTARG ] && error "zadany konfiguracni soubor \"$OPTARG\" neni mozne cist"

         # tady jeste muze nastat situace, ze soubor lze cist -> ale cesta je takova, ze ho nelze napr ani listovat
         # => /root/.bashrc

		 #! [ -e $OPTARG ] && { echo "zadany konfiguracni soubor $OPTARG neexistuje"; exit 1; }
		 #! [ -f $OPTARG ] && { echo "zadany konfiguracni soubor $OPTARG neni bezny soubor"; exit 1; }
		 #! [ -r $OPTARG ] && { echo "zadany konfiguracni soubor $OPTARG neni mozne cist"; exit 1; }
         SWITCHES[$((J++))]="f"	# zapamatujeme si zpracovany prepinac
		 CONFIG="$OPTARG";;	# ok

      n) # NAME
		 [ -z "$OPTARG" ] && error "the value of the switch -n was not provided"
         SWITCHES[$((J++))]="n"	# zapamatujeme si zpracovany prepinac
		 NAME="$OPTARG";;	# kontrola neni nutna

      F) # FPS
		 [ -z "$OPTARG" ] && error "the value of the switch -F was not provided"
		 ! [[ "$OPTARG" =~ ^[0-9]+$ || "$OPTARG" =~ ^[0-9]+\.[0-9]+$ ]]	&& { # neciselna hodnota, mel by byt int/float
           error "spatny parametr prepinace F"; }
         SWITCHES[$((J++))]="F"	# zapamatujeme si zpracovany prepinac
		 FPS="$OPTARG";;	# kontrola neni nutna

      v) # VERBOSE
         SWITCHES[$((J++))]="v"	# zapamatujeme si zpracovany prepinac
         VERBOSE=1;;

     \?) echo "accepted switches: t, X, x, Y, y, S, T, F, c, l, g, e, f, n, v"; 	# prepinac, ktery neni definovan
     #\?) echo "pripustne prepinace: t, X, x, Y, y, S, T, F, c, l, g, e, f, n, v"; 	# prepinac, ktery neni definovan
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
# funkce pro kontrolu datovych souboru
#	1) "$@" - vsechny zbyle argumenty, ktere byly zadany pri spusteni - datove soubory
# probiha pouze kontrola, zda soubory existuji, jsou citelne
# mohlo by se zkoumat zda na sebe i napr nejak navazuji ?
#-------------------------------------------------------------------------------
function checkFiles()
{
  for i in "$1"
  do
    [[ -z "$1" ]] && error "no data files were provided"
    ! [[ -e "$i" ]] && error "provided data file \"$i\" does not exist"
    ! [[ -f "$i" ]] && error "provided data file \"$i\" is not a regular file"
    ! [[ -r "$i" ]] && error "provided data file \"$i\" cannot be read"


    #[[ -z "$1" ]] && error "nebyly zadany zadne datove soubory"
    #! [[ -e "$i" ]] && error "zadany datovy soubor \"$i\" neexistuje"
    #! [[ -f "$i" ]] && error "zadany datovy soubor \"$i\" neni bezny soubor"
    #! [[ -r "$i" ]] && error "zadany datovy soubor \"$i\" neni mozne cist"


  done
}


# tady jeste rovnou soubory ukladat do nejake promenne, pokud jsou validni





#-------------------------------------------------------------------------------
# funkce pro kontrolu, zda je jsme zpracovali zadany prepinac
# parametry:
#	1) prepinac, ktery kontrolujeme
# navratova hodnota: cislo, ktere rika, kolikrat byl dany prepinac
# (direktiva v konfiguracnim souboru) zpracovan
#-------------------------------------------------------------------------------
function checkSwitch()
{
  CNT=0;
  for i in ${PREPINACE[@]}
  do
    [ $i == $1 ] && ((CNT++));
  done
  return $CNT;
}










#-------------------------------------------------------------------------------
# funkce pro cteni konfiguracniho souboru
# parametry:
#	1) konfiguracni soubor
# vysledek zpracovani je ulozen v globalnich promennych
# pri chybe rovnou koncime program pomoci exit 1
#-------------------------------------------------------------------------------
function readConfig()
{
  # indexace pomocneho pole
  J=${#PREPINACE[@]}	# delka pole, budeme zapisovat dal
  X=${#PREPINACE[@]}	# promenna pro kontrolu, zda vubec konfiraguracni soubor neco obsahuje

  # TIMEFORM
  if checkSwitch t 	# zkoumame, zda jsme prepinac zpracovali
  then
    [ `cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /TimeFormat/' | wc -l` -gt 1 ] && 
    { echo "direktiva TimeFormat je v zadanem konfiguracnim souboru $CONFIG uvedena vicekrat"; exit 1; }    # direktiva je v souboru uvedena vice nez jednou
	TMP=`cat $1 | grep ^[a-Z] | awk 'BEGIN{IGNORECASE=1} /TimeFormat/' | sed 's/TimeFormat //'`
	! [[ $TMP =~ ^$ ]] && TIMEFORM=$TMP	# ok, direktiva je evedena
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
	  PREPINACE[$J]="T"	# zapamutujeme si zpracovanou direktivu pro kontrolu, zda byla zadana hodnota
	  ((J++))
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
    PREPINACE[$J]="e"	# zapamutujeme si zpracovanou direktivu pro kontrolu, zda byla zadana hodnota
    ((J++))
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
	  PREPINACE[$J]="g";	# zapamutujeme si zpracovanou direktivu pro kontrolu, zda byla zadana hodnota
	  ((J++));
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
	  PREPINACE[$J]="l"	# zapamutujeme si zpracovanou direktivu pro kontrolu, zda byla zadana hodnota
	  ((J++))
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
	  PREPINACE[$J]="n"	# zapamutujeme si zpracovanou direktivu pro kontrolu, zda byla zadana hodnota
	  ((J++))
    fi
  fi

  [ $X -eq $J ] && { echo "zadany konfiguracni soubor $CONFIG neobsahuje zadne direktivy"; exit 1; }
}






#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------
  # hlavni konfiguracni promenne, globalni pro cely soubor

  XMAX="max"
  XMIN="min"
  VERBOSE=0




#-------------------------------------------------------------------------------
  readParams "$@"
  shift `expr $OPTIND - 1`	# posun na prikazove radce
  [[ "$VERBOSE" == 1 ]] && verbose "zpracovane prepinace ${SWITCHES[@]}"
  checkFiles "$@"           # kontrola datovych souboru, at to neni nutne delat nekdy pozdeji


# pokud je definovan verbose, tak vypsat vsechny zpracovane prepinace a datove soubory


  echo "${SWITCHES[@]}"


