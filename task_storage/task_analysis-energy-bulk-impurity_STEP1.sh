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

duration_name=$(echo ${current_duration_NPT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NPT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NPT[0]} | awk '{print $2}')

rdf_name=$(echo ${current_rdf[0]} | awk '{print $1"-"$2}')
rdf_specie1=$(echo ${current_rdf[0]} | awk '{print $1}')
rdf_specie2=$(echo ${current_rdf[0]} | awk '{print $2}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$combination_name/$temperature_name/$version_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath

cd $dir_experiments/$fullpath

mkdir -p $dir_analysis/$fullpath
mkdir -p $dir_analysis/$fullpath2simulate/energy/

date >> $dir_analysis/$fullpath2simulate/energy/output.out

$currentdir/source/gromacs_energy.sh NPT $duration_begin $duration_end

mv energy.xvg $dir_analysis/$fullpath/energy+$duration_name.xvg 

cat $dir_analysis/$fullpath/'energy+'$duration_name'.xvg' | grep -v '@' | grep -v '#' > $dir_analysis/$fullpath/'energy+'$duration_name'.dat'

echo $fullpath >> $dir_analysis/$fullpath2simulate/energy/output.out
cat tmp.out >> $dir_analysis/$fullpath2simulate/energy/output.out
rm tmp.out
