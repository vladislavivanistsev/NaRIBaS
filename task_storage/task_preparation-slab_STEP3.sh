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

numberofionpairs_name=$(echo ${current_numberofionpairs[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name
fullpath2equilibration=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$replica_name
#fullpath_referencegro=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/c/$surfacecharge_name/$replica_name

mkdir -p $dir_experiments/$fullpath
mkdir -p $dir_experiments/$fullpath2simulate

cd $dir_experiments/$fullpath
pwd

# Calculate the electrode positions
#calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
#deltaz=0.015 #nm
#calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

# Copy equillibrated structure
#cp $dir_experiments/$fullpath_referencegro/NPT.gro reference.gro

####################################


grompp -f 5_NVT_final_Slab.mdp -c NVT_lowtimestep.gro -p topol_local_charged.top -n index_slab.ndx -o NVT -maxwarn 1
rm mdout.mdp

#mdrun -deffnm NVT -nt 12 -npme 6 -dd 3 2 1

runningnumber=$((totalnumberofsetups - 1))

# copy tpr files to run them somewhere as multijobs
cp NVT.tpr $dir_experiments/$fullpath2simulate/NVT$runningnumber.tpr

if [ $totalnumberofsetups -eq 1 ]; then
rm $dir_experiments/$fullpath2simulate/copyback.txt
fi

pathtocopyback=$(pwd)
echo "cp NVT$runningnumber.tpr $pathtocopyback/NVT.tpr" >> $dir_experiments/$fullpath2simulate/copyback.txt

#read -p "Press enter to continue..."
