#!/bin/bash
##########################################################################################
# Name: Random Music <-> rmusic
# Author: Hiei <blascogasconiban@gmail.com>
# Version: 1.2b
# Description:
#              Plays random music from given folder using cvlc(vlc)
#
#
##########################################################################################

#COLORS
red=`tput setaf 1`
reset=`tput sgr0`
yellow=`tput setaf 3`
bold=`tput bold`
#END_OF_COLORS

function playlist {
#find /mnt/data/MUSICA -name *.mp3 -printf '%f\n' | awk '{print NR ":" $0}' | shuf -n1 ###Shows List with ID
song=`find /mnt/data/MUSICA -name *.mp3 | shuf -n 1` #Randomly selecting song from the folder /mnt/data/MUSICA
duration=`mp3info -p "%m:%02s\n" "$song"` #Checking the duration of the song
totalduration=`mp3info -p "%S\n" "$song"`
name=`echo "$song" | rev | cut -d"/" -f1 | cut -c"5-90" | rev | iconv -f utf-8` #Cleaning out the name / Change cut range if too short

cvlc -q "$song" &  #Starts vlc with the randomly selected song
sleep 0.0001
pid=`ps -C vlc | sed 's/|/ /' | awk '{print $1}' | sed -n '2p'` #Getting the PID of the VLC Process

printf "\033c" #Cleaning screen

	#INFO
	echo "${bold}##########################################################################################"
	echo "${bold}# ${red}${bold}NAME: "${yellow} $name ${reset}${bold}
	echo "${bold}# ${red}${bold}DURATION: "${yellow} $duration ${reset}${bold}
	echo "${bold}# ${red}${bold}PID: "${yellow} $pid ${reset}${bold}
	echo "${bold}#################(\__/)###################################################################"
	echo "# ~Made by Hiei~ (O.o )"
	#END_OF_INFO
}

function countdown {

#TIMECOUNTER
(
echo -ne "#                (> < )"\\n #BUNNY
while [[ $SECONDS -lt $totalduration ]];
do
    num=$SECONDS		#Switch seconds to minutes
    min=0
    if((num>59));then
        ((sec=num%60))
        ((min=num/60))
    else
        ((sec=num))
    fi
    echo -ne "${bold}#${red}${bold} TIME: ${yellow}$min:$sec | $duration ${reset}${bold}"\\r${reset} 2>/dev/null #timecounter
done
enemy1=`ps -C rmusic.sh | sed 's/|/ /' | awk '{print $1}' | sed -n '4p'` #PID of the controler
kill $pid
kill $enemy1 ) & #END_OF_TIMECOUNTER

#CONTROLER
(
enemy=`ps -C rmusic.sh | sed 's/|/ /' | awk '{print $1}' | sed -n '3p'` #PID of the timecounter
while [[ $SECONDS -lt $totalduration ]];
do
	read -s -n1 -t 0.001 key 2>/dev/null #Silent mode, nchars mode, timeout
		if [[ $key = $'\e' ]]; then #If escape is detected, switches song
			echo "${red}${bold}¡¡¡¡¡¡CHANGING SOUNDTRACK!!!!!!!"${reset}
			kill $pid
			kill $enemy #Kills timecounter
			sleep 0.1
			exit 1
		else
			:
		fi
done ) & #END_OF_CONTROLER

wait 2>/dev/null
}

#BEGINNING OF SCRIPT
resize -s 8 91 2>/dev/null #Resizing screen
playlist
countdown
clear
exec /home/ivan/git/rmusic.sh
exit 0
