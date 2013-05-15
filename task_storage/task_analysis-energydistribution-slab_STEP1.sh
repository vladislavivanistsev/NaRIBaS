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
xbox_nm=$(echo ${current_particle[0]} | awk '{print $2}') #in nm
ybox_nm=$(echo ${current_particle[0]} | awk '{print $3}') #in nm
r_wall_nm=$(echo ${current_particle[0]} | awk '{print $4}') #in nm
electrodeatoms=$(echo ${current_particle[0]} | awk '{print $5}')

cation_name=$(echo ${current_cation[0]} | awk '{print $1}')
r_cation_nm=$(echo ${current_cation[0]} | awk '{print $2}') #in nm

anion_name=$(echo ${current_anion[0]} | awk '{print $1}')
r_anion_nm=$(echo ${current_anion[0]} | awk '{print $2}') #in nm

impurity_name=$(echo ${current_impurity[0]} | awk '{print $1}')
temperature_name=$(echo ${current_temperature[0]} | awk '{print $1}')
version_name=$(echo ${current_version[0]} | awk '{print $1}')
surfacecharge_name=$(echo ${current_surfacecharge[0]} | awk '{print $1}')
replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath/energydistribution
mkdir -p $dir_analysis/$fullpath2simulate/energydistribution

cd $dir_experiments/$fullpath

pwd

#mkdir -p $dir_analysis/$fullpath2simulate/rdf/
#date >> $dir_analysis/$fullpath2simulate/rdf/output.out

# Calculate the electrode positions
#calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
#deltaz=0.015 #nm
#calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

binwidth=100 # in energy units

# Usage: ./gromacs_energydistribution.sh ensemble begin end binwidth
$currentdir/source/gromacs_energydistribution.sh NVT $duration_begin $duration_end $binwidth

mv energy.xvg $dir_analysis/$fullpath/energydistribution/energy.xvg
mv distr.xvg $dir_analysis/$fullpath/energydistribution/distr.xvg

cat $dir_analysis/$fullpath/energydistribution/energy.xvg | grep -v '#' | grep -v '@' > $dir_analysis/$fullpath/energydistribution/energy.dat
cat $dir_analysis/$fullpath/energydistribution/distr.xvg | grep -v '#' | grep -v '@' > $dir_analysis/$fullpath/energydistribution/distr.dat

mv energy.txt $dir_analysis/$fullpath/energydistribution/energy.txt 

cd $dir_analysis/$fullpath/energydistribution/

if [ $totalnumberofsetups -eq 1 ]; then
rm $dir_analysis/$fullpath2simulate/energydistribution/energydistribution_$temperature_name\_$replica_name.dat
fi

cat energy.txt | grep SS1 > tmp
sed -i 's/SS1/'$surfacecharge_name'/g' tmp
cat tmp >> $dir_analysis/$fullpath2simulate/energydistribution/energydistribution_$temperature_name\_$replica_name.dat
rm tmp

