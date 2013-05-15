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

# Create the files that combine all supbfiles of a specific property
plotdata='capacitance+'$temperature_name'+error.dat'
if [ -e $plotdata ]; then
  rm $plotdata
fi
touch $plotdata

# That is the legend. Should look like: "y plot1 x plot2 x plot3" if plotting is used later
legend='{\itC}_d(\muFcm^{-2})'

legend=$legend' \lambda=0.5 {\itU}_{drop}(V)'
cp $plotdata tmp
paste tmp 'capacitance+'$temperature_name'+0.5.dat' > $plotdata
rm tmp
legend=$legend' \lambda=\lambda({\itT}) {\itU}_{drop}(V)'
cp $plotdata tmp
paste tmp 'capacitance+'$temperature_name'+corrected.dat' > $plotdata
rm tmp

# Delete the last lines of a file until number of rows is equal for all columns
edit_delete_last_lines $plotdata

# Append legend
echo $legend > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata


# Create the files that combine all supbfiles of a specific property
plotdata2='potentialdrop+'$temperature_name'+error.dat'
if [ -e $plotdata2 ]; then
  rm $plotdata2
fi
touch $plotdata2

# That is the legend. Should look like: "y plot1 x plot2 x plot3" if plotting is used later
legend2='{\sigma}(\muCcm^{-2})'

legend2=$legend2' \lambda=0.5 {\itU}_{drop}(V)'
cp $plotdata2 tmp
paste tmp 'potentialdrop+'$temperature_name'.dat' > $plotdata2
rm tmp
legend2=$legend2' \lambda=\lambda({\itT}) {\itU}_{drop}(V)'
cp $plotdata2 tmp
paste tmp 'potentialdrop-smooth+'$temperature_name'+corrected.dat' > $plotdata2
rm tmp

# Delete the last lines of a file until number of rows is equal for all columns
edit_delete_last_lines $plotdata2

# Append legend
echo $legend2 > tmp.dat; cat $plotdata2 >> tmp.dat; mv tmp.dat $plotdata2

factor=2
ncols=$(($factor*2))

# Edit the Matlab function to plot all replicas in one figure
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/Uvssigma2capacitance_error.m > Uvssigma2capacitance_error.m 
sed -i 's/SED_plotfile1_SED/'$plotdata'/g' Uvssigma2capacitance_error.m 
sed -i 's/SED_plotfile2_SED/'$plotdata2'/g' Uvssigma2capacitance_error.m 

sed -i 's|SED_replica0_SED|replica/udropvssigma+Sr+LCr+SAr+no+'$temperature_name'+c+10000-35000+0.dat|g' Uvssigma2capacitance_error.m 
sed -i 's|SED_replica1_SED|replica/udropvssigma+Sr+LCr+SAr+no+'$temperature_name'+c+10000-35000+1.dat|g' Uvssigma2capacitance_error.m 
sed -i 's|SED_replica2_SED|replica/udropvssigma+Sr+LCr+SAr+no+'$temperature_name'+c+10000-35000+2.dat|g' Uvssigma2capacitance_error.m 
sed -i 's|SED_replica3_SED|replica/udropvssigma+Sr+LCr+SAr+no+'$temperature_name'+c+10000-35000+3.dat|g' Uvssigma2capacitance_error.m 
sed -i 's|SED_replica4_SED|replica/udropvssigma+Sr+LCr+SAr+no+'$temperature_name'+c+10000-35000+4.dat|g' Uvssigma2capacitance_error.m 

sed -i 's/SED_title_SED/''/g' Uvssigma2capacitance_error.m 
sed -i 's/SED_savename1_SED/'$plotdata'/g' Uvssigma2capacitance_error.m 
sed -i 's/SED_savename2_SED/'$plotdata2'/g' Uvssigma2capacitance_error.m 

sed -i 's/SED_verticallines_SED/-100/g' Uvssigma2capacitance_error.m  # position in nm
sed -i 's/SED_xlim_SED/-7 7/g' Uvssigma2capacitance_error.m  # in nm

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "Uvssigma2capacitance_error($ncols)"

read -p "Press enter to continue..."
