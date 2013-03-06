#!/bin/bash


#

# ------------------------------------------------ >>>>> napsat spravne hlavicku

# semester work predmetu BI-SKJ, FIT CVUT, 2013, summer semester
#
# This script generates animation based on provided data files,
# additionaly its behavior can be affected by switches or by configuration file.
# Its possible to use both options together, if switch and corresponding
# configuration dicertive are used, then switch is preffered.
#
#






















#-------------------------------------------------------------------------------
# funkce pro cteni a vyhodnoceni paramemetru
# parametry:
#	1) "$@" - zpracujeme vsechny prepinace zadane skritu
# vysledek zpracovani je ulozen v globalnich promennych
# pri chybe rovnou koncime program pomoci exit 1
#-------------------------------------------------------------------------------
function readParams()
{
  J=0 # indexace $PREPINACE
  A=0 # indexace $GNUPLOTPARAMS
  B=0 # indexace $EFFECTPARAMS

#		 [ -z $OPTARG ] && { echo "nebyla zadana hodnota prepinace -t"; exit 1; }
# tento kod se stejne neuplatni, pokud je getopts v silent rezimu

  while getopts ":t:X:x:Y:y:S:T:F:l:g:e:f:n:" opt  	# cyklus pro zpracovani prepinacu	
  do
   case "$opt" in
      t) # TIMEFORM
		 ! checkSwitch t && { echo "prepinac -t byl zadan vicekrat"; exit 1; }	# prepinac byl zadan vicekrat
         PREPINACE[$J]="t"	# zapamatujeme si zpracovany prepinac
         ((J++))
		 TIMEFORM="$OPTARG";; # ok

      Y) # YMAX
		 ! checkSwitch Y && { echo "prepinac -Y byl zadan vicekrat"; exit 1; }	# prepinac byl zadan vicekrat
		 ! [[ "$OPTARG" =~ ^-?[0-9]+$ || "$OPTARG" =~ ^-?[0-9]+\.[0-9]+$ || "$OPTARG" == "auto" || "$OPTARG" == "max" ]] && {  # ani jedna z definovanych hodnot
		   echo "spatny parametr prepinace Y"; exit 1; }
         PREPINACE[$J]="Y"
         ((J++))
		 YMAX="$OPTARG";; 	# ok

      y) # YMIN
		 [ -z "$OPTARG" ] && { echo "nebyla zadana hodnota prepinace -y"; exit 1; }
		 ! checkSwitch y && { echo "prepinac -y byl zadan vicekrat"; exit 1; }	# prepinac byl zadan vicekrat
		 ! [[ "$OPTARG" =~ ^-?[0-9]+$ || "$OPTARG" =~ ^-?[0-9]+\.[0-9]+$ || "$OPTARG" == "auto" || $OPTARG == "min" ]] && { # ani jedna z definovanych hodnot
		   echo "spatny parametr prepinace y"; exit 1; }
         PREPINACE[$J]="y"	# zapamatujeme si zpracovany prepinac
         ((J++))
		 YMIN="$OPTARG";;	# ok

      S) # SPEED
		 ! checkSwitch S && { echo "prepinac -S byl zadan vicekrat"; exit 1; }	# prepinac byl zadan vicekrat
		 ! [[ "$OPTARG" =~ ^[0-9]+$ || "$OPTARG" =~ ^[0-9]+\.[0-9]+$ ]] && {	# neciselna hodnota, mel by byt int/float
		   echo "spatny parametr prepinace S"; exit 1; }
         PREPINACE[$J]="S"	# zapamatujeme si zpracovany prepinac
         ((J++))
		 SPEED="$OPTARG";;	# ok

      T) # DURATION
		 ! checkSwitch T && { echo "prepinac -T byl zadan vicekrat"; exit 1; }	# prepinac byl zadan vicekrat
		 ! [[ "$OPTARG" =~ ^[0-9]+$ || "$OPTARG" =~ ^[0-9]+\.[0-9]+$ ]] && {	# neciselna hodnota, mel by byt int/float
		   echo "spatny parametr prepinace T"; exit 1; }
         PREPINACE[$J]="T"	# zapamatujeme si zpracovany prepinac
         ((J++))
		 DURATION="$OPTARG";;	# ok

      l) # LEGEND		 
		 ! checkSwitch l && { echo "prepinac -l byl zadan vicekrat"; exit 1; }	# prepinac byl zadan vicekrat
		 PREPINACE[$J]="l"	# zapamatujeme si zpracovany prepinac
         ((J++))
		 LEGEND="$OPTARG";; #text, neni potreba kontrola

      g) # GNUPLOTPARAMS
		 GNUPLOTPARAMS[$A]="$OPTARG"	# ulozime si hodnotu
		 ((A++))
         PREPINACE[$J]="g"	# zapamatujeme si zpracovany prepinac
         ((J++));;
      
      e) # EFFECTPARAMS
		 OPTARG=`echo "$OPTARG" | tr ":" " "`	# zmena oddelovace na mezeru, abychom mohli iterovat
		 for i in $OPTARG
		 do
		   ! [[ $i =~ ^bgcolor=.*$ || $i =~ ^changebgcolor$ || $i =~ ^changespeed=[1-5]$ ]] && { # kontrola, zda ma promenna spravny tvar
		     echo "spatna hodnota parametru e"; exit 1; }
		   EFFECTPARAMS[$B]=$i	# ok, uloz do pole
		   ((B++))
	     done
         PREPINACE[$J]="e"	# zapamatujeme si zpracovany prepinac
         ((J++));;
		 
      f) # CONFIG
		 ! checkSwitch f && { echo "prepinac -f byl zadan vicekrat"; exit 1; }	# prepinac byl zadan vicekrat
		 ! [ -e $OPTARG ] && { echo "zadany konfiguracni soubor $OPTARG neexistuje"; exit 1; }
		 ! [ -f $OPTARG ] && { echo "zadany konfiguracni soubor $OPTARG neni bezny soubor"; exit 1; }
		 ! [ -r $OPTARG ] && { echo "zadany konfiguracni soubor $OPTARG neni mozne cist"; exit 1; }
         PREPINACE[$J]="f"	# zapamatujeme si zpracovany prepinac
         ((J++))
		 CONFIG="$OPTARG";;	# ok

      n) # NAME
		 ! checkSwitch n && { echo "prepinac -n byl zadan vicekrat"; exit 1; }	# prepinac byl zadan vicekrat
		 PREPINACE[$J]="n"	# zapamatujeme si zpracovany prepinac
         ((J++))
		 NAME="$OPTARG";;	# kontrola neni nutna

      F) # FPS
		 ! checkSwitch F && { echo "prepinac -n byl zadan vicekrat"; exit 1; }	# prepinac byl zadan vicekrat
		 ! [[ "$OPTARG" =~ ^[0-9]+$ || "$OPTARG" =~ ^[0-9]+\.[0-9]+$ ]]	&& { # neciselna hodnota, mel by byt int/float
		   echo "spatny parametr prepinace F"; exit 1; }
		 PREPINACE[$J]="F"	# zapamatujeme si zpracovany prepinac
         ((J++))
		 FPS="$OPTARG";;	# kontrola neni nutna

     \?) echo "pripustne prepinace: t, X, x, Y, y, S, T, F, c, l, g, e, f, n"; 	# prepinac, ktery neni definovan
		 exit 2;;
   esac
  done
}
#-------------------------------------------------------------------------------


