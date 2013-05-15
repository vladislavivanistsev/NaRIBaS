#!/bin/bash

function listtest { result=$(zenity --list --width=600 --height=450 --title="NaRIBaS v0.1" --text "How can I help?" --radiolist --column " " --column " " TRUE "Start a calculation" FALSE "Select input" FALSE "What is NaRIBaS?" FALSE "Help" FALSE "Exit");
					listout
}

function listout {
	if [ "$result" = "Start a calculation" ] ; then
		select_user-input
		listtest
	elif [ "$result" = "Select input" ] ; then
		select_user-input
		listtest
	elif [ "$result" = "What is NaRIBaS?" ] ; then
		read_welcome
		listtest
	elif [ "$result" = "Help" ] ; then
		read_help
		listtest
	elif [ "$result" = "Exit" ] ; then
		exit
	else
		#clear
      exit
	fi
}

function read_welcome {
# You must place file "WELCOME" in same folder of this script.
FILE=`dirname $0`/WELCOME
zenity --text-info --title="Welcome to NaRIBaS" --filename=$FILE --width=800 --height=600
}

function read_help {
# You must place file "WELCOME" in same folder of this script.
FILE=`dirname $0`/Help.html
zenity --text-info --title="NaRIBaS Help" --filename=Help.html --width=800 --height=600
}


function select_user-input {
items=( "Default" "Test" )
# append some items
items+=( "$zenlist"* )
zenity --list --title='A single-column List' --width=600 --height=450 \
       --column='Select the input file:' "${items[@]}"
}

function fileselect 
{ 
zenity --file-selection 
}

function warning 
{ 
zenity --warning 
}

unset WINDOWID
cat WELCOME | zenity --text-info --width=800 --height=600
listtest
