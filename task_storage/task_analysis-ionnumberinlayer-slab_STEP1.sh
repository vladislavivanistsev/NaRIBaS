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

numberdens_name=$(echo ${current_numberdens_ionnumberinlayer[0]} | awk '{print $1}')
electrode_name=$(echo ${current_electrode_ionnumberinlayer[0]} | awk '{print $1}')
electrode_sign=$(echo ${current_electrode_ionnumberinlayer[0]} | awk '{print $2}')

# Define path for storing configurations / simulation data
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath2simulate/layer/$temperature_name
cd $dir_analysis/$fullpath2simulate/layer/$temperature_name

#date >> $dir_analysis/$fullpath2simulate/rdf/output.out

# Calculate the electrode positions
#calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
#deltaz=0.015 #nm
#calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

pwd

# Create the files that combine all subfiles of a specific property
plotdata='numberdens-cn+'$numberdens_name'-'$electrode_name'+'$temperature_name'.dat'
if [ -e $plotdata ]; then
  rm $plotdata
fi
touch $plotdata

plotdata2='numberdens+'$numberdens_name'-'$electrode_name'+'$temperature_name'.dat'
if [ -e $plotdata2 ]; then
  rm $plotdata2
fi
touch $plotdata2

# That is the legend. Should look like: "y plot1 x plot2 x plot3" if plotting is used later
legend='cn_N(z)'
legend2='\rho_N(nm^{-3})'

while read inputline
do
surfacecharge_name=$(echo $inputline | awk '{print $1}')
fullpath_allreplicas=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name

legend=$legend' '$electrode_sign$surfacecharge_name' z(nm)'
legend2=$legend2' '$electrode_sign$surfacecharge_name' z(nm)'
cp $plotdata tmp
paste tmp $dir_analysis/$fullpath_allreplicas/'numberdens-cn+'$duration_name'+'$numberdens_name'-'$electrode_name'.dat' > $plotdata
rm tmp
cp $plotdata2 tmp
paste tmp $dir_analysis/$fullpath_allreplicas/'numberdens+'$duration_name'+'$numberdens_name'-'$electrode_name'.dat' > $plotdata2
rm tmp

done < $currentdir/$inputlists_folder/surfacecharge.list  ######## WARNING: may be changed to surfacecharge_publication.list ############

# Delete the last lines of a file until number of rows is equal for all columns
edit_delete_last_lines $plotdata
edit_delete_last_lines $plotdata2

# Append legend
echo $legend > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata
echo $legend2 > tmp.dat; cat $plotdata2 >> tmp.dat; mv tmp.dat $plotdata2

factor=$(cat $currentdir/$inputlists_folder/surfacecharge.list | wc -l)  ######## WARNING: may be changed to surfacecharge_publication.list ############
ncols=$(($factor*2))


# Edit the Matlab function to calculate the number of ions in the EDL
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/ion_number_in_layer_$numberdens_name\_$electrode_name.m > ion_number_in_layer.m
sed -i 's/SED_cnfile_SED/'$plotdata'/g' ion_number_in_layer.m
sed -i 's/SED_numberdensfile_SED/'$plotdata2'/g' ion_number_in_layer.m
sed -i 's|SED_potentialdropfile_SED|'$dir_analysis'/'$fullpath2simulate'/potentialdrop/potentialdrop-smooth+'$temperature_name'.dat|g' ion_number_in_layer.m
sed -i 's/SED_title_SED/'$numberdens_name'-'$electrode_name'+'$temperature_name'K/g' ion_number_in_layer.m
sed -i 's/SED_savename_SED/ionnumber+'$numberdens_name'-'$electrode_name'+'$temperature_name'.dat/g' ion_number_in_layer.m

if [ $numberdens_name == "Cation" ]; then
  r_ion_nm=0.6
elif [ $numberdens_name == "Anion" ]; then
  r_ion_nm=0.35
else
  echo "Ion radius not defined." 
  read -p "Press enter to continue..."
fi


# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "ion_number_in_layer($ncols,$electrodeatoms,$xbox_nm,$ybox_nm)"

# To reduce file spamming clean up
rm $plotdata $plotdata2

#read -p "Press enter to continue..."

