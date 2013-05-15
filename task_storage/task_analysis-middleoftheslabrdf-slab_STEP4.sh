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
#replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

rdf_name=$(echo ${current_rdf[0]} | awk '{print $1"-"$2}')
rdf_specie1=$(echo ${current_rdf[0]} | awk '{print $1}')
rdf_specie2=$(echo ${current_rdf[0]} | awk '{print $2}')

# Define path for storing configurations / simulation data
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath2simulate/middleoftheslabrdf/surfacecharge-dependence/
cd $dir_analysis/$fullpath2simulate/middleoftheslabrdf/surfacecharge-dependence/

#date >> $dir_analysis/$fullpath2simulate/rdf/output.out

# Calculate the electrode positions
#calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
#deltaz=0.015 #nm
#calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

pwd

plotdata='rdf+'$rdf_name'+'$temperature_name'.dat'

if [ -e $plotdata ]
then
  rm $plotdata
fi
touch $plotdata

touch tmp.dat

legend_1='g(r)'

#+++++++++++++++++++++++
while read surfacecharge_name;do
fullpath_allreplicas=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name
legend_1=$legend_1' '$surfacecharge_name' r(nm)'
paste $plotdata  $dir_analysis/$fullpath_allreplicas/'rdf+'$rdf_name'+combined.dat' > tmp.dat
mv tmp.dat $plotdata
done < $currentdir/$inputlists_folder/surfacecharge_publication.list
#+++++++++++++++++++++++

# Append legend
#sed -i "1i$legend_1" $plotdata
echo $legend_1 > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata

ncols=$(cat $currentdir/$inputlists_folder/surfacecharge_publication.list | wc -l)
ncols=$(($ncols*2))

# Edit the Matlab function to plot all replicas in one figure (basic plotting)
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting.m > basic_plotting.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' basic_plotting.m
sed -i 's/SED_title_SED/'$rdf_name' {\\itT}='$temperature_name'K/g' basic_plotting.m
sed -i 's/SED_savename_SED/'$plotdata'.dat/g' basic_plotting.m

sed -i 's/SED_legend_name_SED/\\sigma(\\muC cm^{-2})/g' basic_plotting.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "basic_plotting($ncols)"


# Edit the Matlab function to plot all replicas in one figure (basic plotting)
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting_profile_withylim.m > basic_plotting_profile_withylim.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' basic_plotting_profile_withylim.m
sed -i 's/SED_title_SED/'$rdf_name' {\\itT}='$temperature_name'K/g' basic_plotting_profile_withylim.m
sed -i 's/SED_savename_SED/'$plotdata'.dat/g' basic_plotting_profile_withylim.m
sed -i 's/SED_xlim_SED/0 4/g' basic_plotting_profile_withylim.m
sed -i 's/SED_ylim_SED/0 5/g' basic_plotting_profile_withylim.m
sed -i 's/SED_verticallines_SED/-100/g' basic_plotting_profile_withylim.m

sed -i 's/SED_legend_name_SED/\\sigma(\\muC cm^{-2})/g' basic_plotting_profile_withylim.m

# Run matlab
#$matlabdir/matlab -nodisplay -nosplash -r  "basic_plotting_profile_withylim($ncols)"

