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
temperature_name=$(echo ${current_temperature[0]} | awk '{print $1}')
version_name=$(echo ${current_version[0]} | awk '{print $1}')
replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

rdf_name=$(echo ${current_rdf[0]} | awk '{print $1"-"$2}')
rdf_specie1=$(echo ${current_rdf[0]} | awk '{print $1}')
rdf_specie2=$(echo ${current_rdf[0]} | awk '{print $2}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath

cd $dir_experiments/$fullpath

mkdir -p $dir_analysis/$fullpath
mkdir -p $dir_analysis/$fullpath2simulate/rdf/

echo "Setup $totalnumberofsetups"
pwd
echo "execute $currentdir/source/gromacs_rdf.sh NVT $rdf_specie1 $rdf_specie2 $duration_begin $duration_end"
xterm -e "$currentdir/source/gromacs_rdf.sh NVT $rdf_specie1 $rdf_specie2 $duration_begin $duration_end > log.file"
if grep -F "Error" log.file; then
	read -p "Error detected. Press enter to continue or Ctrl+C to abort..."
fi
rm log.file

echo "Move files to $dir_analysis/$fullpath/"
mv rdf.xvg $dir_analysis/$fullpath/rdf+$rdf_name+$duration_name.xvg 
mv rdf_cn.xvg $dir_analysis/$fullpath/cn+$rdf_name+$duration_name.xvg 

cat $dir_analysis/$fullpath/'rdf+'$rdf_name'+'$duration_name'.xvg' | grep -v '@' | grep -v '#' > $dir_analysis/$fullpath/'rdf+'$rdf_name'+'$duration_name'.dat'
cat $dir_analysis/$fullpath/'cn+'$rdf_name'+'$duration_name'.xvg' | grep -v '@' | grep -v '#' > $dir_analysis/$fullpath/'cn+'$rdf_name'+'$duration_name'.dat'

#read -p "Press enter to continue..."
