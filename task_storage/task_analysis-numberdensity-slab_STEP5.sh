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
replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

numberdens_name=$(echo ${current_numberdens[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath2simulate/middleoftheslabrdf
cd $dir_analysis/$fullpath2simulate/middleoftheslabrdf

#mkdir -p $dir_analysis/$fullpath2simulate/numberdens/
#date >> $dir_analysis/$fullpath2simulate/rdf/output.out

# Calculate the electrode positions
#calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
#deltaz=0.015 #nm
#calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

pwd

plotdata='mean-middle-numberdens+'$numberdens_name'.dat'

if [ -e $plotdata ]
then
  rm $plotdata
fi
touch $plotdata

# That is the legend. Should look like: "y plot1 x plot2 x plot3" if plotting is used later
legend='\rho_N(nm^{-3})'

while read inputline
do
temperature_name=$(echo $inputline | awk '{print $1}')

legend=$legend' '$temperature_name'K \sigma(\muC/cm^2)'
cp $plotdata tmp
paste tmp 'mean-middle-numberdens+'$numberdens_name'+'$temperature_name'.dat' > $plotdata
rm tmp

done < $currentdir/$inputlists_folder/temperature.list

# Delete the last lines of a file until number of rows is equal for all columns
edit_delete_last_lines $plotdata

# Append legend
echo $legend > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata

factor=$(cat $currentdir/$inputlists_folder/temperature.list | wc -l)
ncols=$(($factor*2))

# Edit the Matlab function to plot
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting_profile_withylim.m > basic_plotting_profile.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' basic_plotting_profile.m
sed -i 's|SED_title_SED|Ion pair number density|g' basic_plotting_profile.m
sed -i 's/SED_savename_SED/'$plotdata'/g' basic_plotting_profile.m

sed -i 's/SED_verticallines_SED/-100/g' basic_plotting_profile.m # position in nm
sed -i 's/SED_xlim_SED/0 50/g' basic_plotting_profile.m # in nm
sed -i 's/SED_ylim_SED/0.1 0.4/g' basic_plotting_profile.m # in nm

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "basic_plotting_profile($ncols)"

# Edit the Matlab function to plot
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting_profile_withylim.m > basic_plotting_profile.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' basic_plotting_profile.m
sed -i 's|SED_title_SED|Ion pair number density|g' basic_plotting_profile.m
sed -i 's/SED_savename_SED/closeup+'$plotdata'/g' basic_plotting_profile.m

sed -i 's/SED_verticallines_SED/-100/g' basic_plotting_profile.m # position in nm
sed -i 's/SED_xlim_SED/10 20/g' basic_plotting_profile.m # in nm
sed -i 's/SED_ylim_SED/0.33 0.36/g' basic_plotting_profile.m # in nm

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "basic_plotting_profile($ncols)"

#read -p "Press enter to continue ..."
