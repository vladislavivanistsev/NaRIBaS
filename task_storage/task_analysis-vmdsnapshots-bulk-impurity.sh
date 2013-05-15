#!/bin/bash

# Place to add code

# Some basic functions to access the data

#echo ${concentration[*]} # All elements of the array
#echo ${concentration[9]} # Element number 10 (counter starts at 0)
#numberofitems=${#concentration[*]} # calculate the number of elements in array
#echo $numberofitems
#echo ${concentration[1]} | awk '{print $1}' # Access the data that is stored within an element array
#echo '-----'
#print_current_setup

# Transfer list entries to bash variables
particle_name=$(echo ${current_particle[0]} | awk '{print $1}')
cation_name=$(echo ${current_cation[0]} | awk '{print $1}')
anion_name=$(echo ${current_anion[0]} | awk '{print $1}')
impurity_name=$(echo ${current_impurity[0]} | awk '{print $1}')
combination_name=$(echo ${current_combination[0]} | awk '{print $1"-"$2"-"$3}')
temperature_name=$(echo ${current_temperature[0]} | awk '{print $1}')
version_name=$(echo ${current_version[0]} | awk '{print $1}')
replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$combination_name/$temperature_name/$version_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath
mkdir -p $dir_analysis/$fullpath/vmd
mkdir -p $dir_analysis/$fullpath2simulate/vmd

cd $dir_analysis/$fullpath/vmd

grofile=$dir_experiments/$fullpath/NPT.gro

sed 's+SED_grofile_SED+'$grofile'+g' $currentdir/source/vmd_create-snapshots_bulk_impurity.tcl > vmd_create-snapshots.tcl

$dir_vmd/vmd -e vmd_create-snapshots.tcl

# try later putting all snapshots in one file. Idea: create article, delete last line, cut figure template, add data Problem: How to know if a file needs to created new?

#cd $dir_analysis/$fullpath2simulate/vmd
#sed '$d' $currentdir/source/latex-template-article.tex > vmdsnapshots.tex

#sed 's+SED_add_SED+'SED\_add\_SED\\nSED\_addfigure\_SED'+g' $currentdir/source/latex-template-article.tex > vmdsnapshots.tex

#sed -i 's+SED_addfigure_SED+'$grofile'+g' vmdsnapshots.tex

#sed 's+SED_addcaption_SED+'123\nabc'+g' $currentdir/source/latex-template-article.tex > vmdsnapshots.tex

#latex-template-article
#latex-template-figure

#latex vmdsnapshots
#dvi2pdf vmdsnapshots
