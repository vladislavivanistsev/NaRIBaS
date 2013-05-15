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
#surfacecharge_name=$(echo ${current_surfacecharge[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

#numberdens_name=$(echo ${current_numberdens[0]} | awk '{print $1}')
#electrode_name=$(echo ${current_electrode[0]} | awk '{print $1}')

fitexponent_name=$(echo ${current_fitexponent[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath2simulate/potentialdrop-error/$temperature_name
cd $dir_analysis/$fullpath2simulate/potentialdrop-error/$temperature_name

#date >> $dir_analysis/$fullpath2simulate/rdf/output.out

# Calculate the electrode positions
#calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
#deltaz=0.015 #nm
#calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

pwd

cp $dir_analysis/$fullpath2simulate/potentialdrop/potentialdrop+$temperature_name.dat .

# Edit the Matlab function to calculate the capacitance
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/Uvssigma2capacitance_fitexponent.m > Uvssigma2capacitance_fitexponent.m
sed -i 's/SED_fitexponent_SED/'$fitexponent_name'/g' Uvssigma2capacitance_fitexponent.m
sed -i 's/SED_file_SED/potentialdrop+'$temperature_name'.dat/g' Uvssigma2capacitance_fitexponent.m
sed -i 's/SED_savename-smoothpotentialdrop_SED/potentialdrop-smooth+'$temperature_name'+'$fitexponent_name'.dat/g' Uvssigma2capacitance_fitexponent.m
sed -i 's/SED_savename_SED/capacitance+'$temperature_name'+'$fitexponent_name'.dat/g' Uvssigma2capacitance_fitexponent.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "Uvssigma2capacitance_fitexponent($fitexponent_name)"

#read -p "Press enter to continue..."

