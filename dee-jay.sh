#!/bin/bash
##########################################################################################
# Name: dee-jay <rmusic>
# Author: Hiei <blascogasconiban@gmail.com>
# Version: 2.1.8-rc/stable
# Description:
#              AI plays music for you from given folder using cvlc(vlc)
# Bugs:
#	       None found yet!
##########################################################################################
red=`tput setaf 1`;reset=`tput sgr0`;yellow=`tput setaf 3`;bold=`tput bold` #adding colors to the script
#DEFAULT_CONFIG#
FOLDER=("/mnt/data/MUSICA" "/mnt/data/MUSICA2") #Add your folders here (I find the files recursively if they are not in different places just mark the main one)

function rmusic { #main function
	cvlc -q "$1" &
	echo;echo "${yellow}PLAYING $2"
	SECONDS=0
	while [[ $SECONDS -le $3 ]]
	do
		echo -ne "${blond}${red}TIME: ${yellow}$SECONDS | $3${reset}"\\r
		read -s -n1 -t 0.001 KEY 2>/dev/null #Silent mode, nchars mode, timeout
                if [[ $KEY = $'\e' ]]; then #If escape is detected, switches song
			check-choice "$4"
			break
                fi
	done
	echo;echo;echo "Song $2 finished";echo
	check-choice "$4"
}

function check-choice {
        if [[ -z $1 ]]; then
                VLC_PID=$(ps -C vlc | sed 's/|/ /' | awk '{print $1}' | sed -n '2p')
                kill $VLC_PID
		echo;menu
        else
		VLC_PID=$(ps -C vlc | sed 's/|/ /' | awk '{print $1}' | sed -n '2p')
                kill $VLC_PID
		echo;SONG=$(find ${FOLDER[*]} -name "*.mp3" -type f | shuf -n1);AUTO=1;song "$SONG" "$AUTO"
        fi
}

function song { #this function simply sets the vars for the main function
        SONG="$1"
        NAME=$(echo "$SONG" | rev | cut -d"/" -f1 | rev | iconv -f utf-8)
        DURATION=$(mp3info -p "%S" "$SONG")
        rmusic "$SONG" "$NAME" "$DURATION" "$2"
}

function menu { #menu function
	echo;echo "${red} OPTIONS MENU"
	echo "1.- Play random music from your default mp3 folder"
	echo "2.- Choose a song from your default mp3 folder"
	echo "3.- Choose a song from your default mp3 folder with name"
	echo "4.- Exit" ; echo
	read -p "${yellow}Which option you want to choose: " OPTION
	OPTION=$(echo $OPTION | sed 's/[^0-9]//g') #sed to remove non-number characters
	case $OPTION in
		1) SONG=$(find ${FOLDER[*]} -name "*.mp3" -type f | shuf -n1);AUTO=1;song "$SONG" "$AUTO" ;; #shuf chooses one randomly
		2) select SONG in $(find ${FOLDER[*]} -name "*mp3" -type f);do song "$SONG";done ;; #selecting song with select statement
		3) read -p "Name of song: " SEARCH;select SONG in $(find ${FOLDER[*]} -iname "*$SEARCH*mp3" -type f);do song "$SONG";done ;;
		4) exit 0 ;;
		*) echo;echo "${bold}${red}Warning: option not supported${reset}" ; menu ;;
	esac
}

#dependencies
if [[ -z $(dpkg -l | grep "mp3info") ]]; then
	read -p "${red}mp3info not installed, wish to install it now?[n/y] " ANSWER
	if [[ $ANSWER = "y" ]] || [[ $ANSWER = "Y" ]]; then
		sudo apt-get install mp3info
		echo "${yellow}Run dee-jay again";exit 0
	else
		echo "${yellow}Can't run without mp3info, try again when you will have it";exit 1
	fi
fi

IFS=$(echo -en "\n\b") #fixing spaces problem with "select" statement
menu
VLC_PID=$(ps -C vlc | sed 's/|/ /' | awk '{print $1}' | sed -n '2p')
kill $VLC_PID
