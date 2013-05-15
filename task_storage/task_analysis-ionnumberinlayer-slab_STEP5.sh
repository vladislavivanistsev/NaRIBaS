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
#temperature_name=$(echo ${current_temperature[0]} | awk '{print $1}')
version_name=$(echo ${current_version[0]} | awk '{print $1}')
#surfacecharge_name=$(echo ${current_surfacecharge[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

numberdens_name=$(echo ${current_numberdens[0]} | awk '{print $1}')
numberdens_legendlocation=$(echo ${current_numberdens[0]} | awk '{print $2}')
numberdens_upperylim=$(echo ${current_numberdens[0]} | awk '{print $3}')
#electrode_name=$(echo ${current_electrode[0]} | awk '{print $1}')

layerdata_name=$(echo ${current_layerdata_overelectrons[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath2simulate/layer/
cd $dir_analysis/$fullpath2simulate/layer/

#date >> $dir_analysis/$fullpath2simulate/rdf/output.out

# Calculate the electrode positions
#calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
#deltaz=0.015 #nm
#calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

pwd

# Create the files that combine all subfiles of a specific property
plotdata='ionnumber+'$numberdens_name'+'$layerdata_name'.dat'
if [ -e $plotdata ]; then
  rm $plotdata
fi
touch $plotdata

cat 'ionnumber+'$numberdens_name'-Cathode+'$layerdata_name'.dat' > $plotdata
tail -n +3 'ionnumber+'$numberdens_name'-Anode+'$layerdata_name'.dat' >> $plotdata

factor=$(cat $currentdir/$inputlists_folder/temperature.list | wc -l)
ncols=$(($factor*2))

# Edit the Matlab function to plot
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting_profile_long_legendoutside.m > basic_plotting_profile_long_legendoutside.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' basic_plotting_profile_long_legendoutside.m
sed -i 's|SED_title_SED|'$numberdens_name' '$layerdata_name'|g' basic_plotting_profile_long_legendoutside.m
sed -i 's/SED_savename_SED/fullrange+'$plotdata'/g' basic_plotting_profile_long_legendoutside.m

sed -i 's/SED_verticallines_SED/0/g' basic_plotting_profile_long_legendoutside.m # position in nm
sed -i 's/SED_xlim_SED/-377 377/g' basic_plotting_profile_long_legendoutside.m # in nm
#sed -i 's/SED_legendlocation_SED/'$numberdens_legendlocation'/g' advanced_plotting_profile_long_noylim.m # in nm

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "basic_plotting_profile_long_legendoutside($ncols)"

#read -p "Press enter to continue..."

