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
echo $surfacecharge_name
replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

numberdens_name=$(echo ${current_numberdens[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath

cd $dir_experiments/$fullpath

mkdir -p $dir_analysis/$fullpath

#mkdir -p $dir_analysis/$fullpath2simulate/rdf/
#date >> $dir_analysis/$fullpath2simulate/rdf/output.out

# Calculate the electrode positions
calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
deltaz=0.015 #nm
calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

# Prepare the execution of the gromacs tool and output storage

if [ ! -e index_slab.ndx ] 
then

if [ ! -e NVT.gro ] 
then
make_ndx -f NVT_lowtimestep.gro -o index_slab.ndx << EOF
keep 0
a $cation
name 1 Cation
a $anion
name 2 Anion
a CGl1
name 3 Gl1
a CGr1
name 4 Gr1
a CGl1 | a CGl2 | a CGl3 | a CGl4 | a CGl5 | a CGr1 | a CGr2 | a CGr3 | a CGr4 | a CGr5 | 
name 5 Electrodes 
q
EOF
else
make_ndx -f NVT.gro -o index_slab.ndx << EOF
keep 0
a $cation
name 1 Cation
a $anion
name 2 Anion
a CGl1
name 3 Gl1
a CGr1
name 4 Gr1
a CGl1 | a CGl2 | a CGl3 | a CGl4 | a CGl5 | a CGr1 | a CGr2 | a CGr3 | a CGr4 | a CGr5 | 
name 5 Electrodes 
q
EOF
fi

fi

# Usage: ./gromacs_density_profile.sh ensemble specie begin end numberofslices
$currentdir/source/gromacs_density_profile.sh NVT $numberdens_name $duration_begin $duration_end $numberofslices

mv density.xvg $dir_analysis/$fullpath/numberdens+$numberdens_name+$duration_name.xvg

cat $dir_analysis/$fullpath/numberdens+$numberdens_name+$duration_name.xvg | grep -v '#' | grep -v '@' > $dir_analysis/$fullpath/numberdens+$numberdens_name+$duration_name.dat

# While deleteing the xvg header, the number density is normalized by the bulk density in one goal, this is probably only possible for the model system
# IMPORTANT: Delete "/$currentdens" in case you have another system
# As I want to get the charge density profile, I shouldn't normalize the number density.

awk < $dir_analysis/$fullpath/numberdens+$numberdens_name+$duration_name.dat '{ print $1, $2/'$currentdens' }' > $dir_analysis/$fullpath/numberdens_normalized+$numberdens_name+$duration_name.dat
