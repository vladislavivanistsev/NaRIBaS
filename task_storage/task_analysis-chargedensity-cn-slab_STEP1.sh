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

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

# Define path for storing configurations / simulation data
fullpath_allreplicas=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

cd $dir_analysis/$fullpath_allreplicas

#mkdir -p $dir_analysis/$fullpath2simulate/numberdens/
#date >> $dir_analysis/$fullpath2simulate/rdf/output.out

# Calculate the electrode positions
calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
deltaz=0.015 #nm
#calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

pwd

ncols=2

# Edit the Matlab function to calculate the charge density and cumulative number of the mean
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/numberdens2chargedens2cn.m > numberdens2chargedens2cn.m
sed -i 's/SED_numberdenscation_SED/numberdens+Cation+'$duration_name'+combined.dat/g' numberdens2chargedens2cn.m
sed -i 's/SED_numberdensanion_SED/numberdens+Anion+'$duration_name'+combined.dat/g' numberdens2chargedens2cn.m

sed -i 's/SED_posanode_SED/'$pos_left_electrode_nm'/g' numberdens2chargedens2cn.m
sed -i 's/SED_poscathode_SED/'$pos_right_electrode_nm'/g' numberdens2chargedens2cn.m

sed -i 's/SED_savename-numberdens_SED/numberdens+'$duration_name'.dat/g' numberdens2chargedens2cn.m
sed -i 's/SED_savename-chargedens_SED/chargedens+'$duration_name'.dat/g' numberdens2chargedens2cn.m
sed -i 's/SED_savename-cn-numberdens_SED/numberdens-cn+'$duration_name'.dat/g' numberdens2chargedens2cn.m
sed -i 's/SED_savename-cn-chargedens_SED/chargedens-cn+'$duration_name'.dat/g' numberdens2chargedens2cn.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "numberdens2chargedens2cn($ncols,$deltaz,$xbox_nm,$ybox_nm)"

#read -p "Press enter to continue..."

