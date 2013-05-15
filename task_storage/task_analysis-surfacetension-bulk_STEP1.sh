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
cation_name=$(echo ${current_cation[0]} | awk '{print $1}')
anion_name=$(echo ${current_anion[0]} | awk '{print $1}')
impurity_name=$(echo ${current_impurity[0]} | awk '{print $1}')
temperature_name=$(echo ${current_temperature[0]} | awk '{print $1}')
version_name=$(echo ${current_version[0]} | awk '{print $1}')
version_property=$(echo ${current_version[0]} | awk '{print $2}')
replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

numberofionpairs_name=$(echo ${current_numberofionpairs[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath
mkdir -p $dir_analysis/$fullpath2simulate/energy

cd $dir_experiments/$fullpath

$currentdir/source/gromacs_energy.sh SurfTen $duration_begin $duration_end $numberofionpairs_name

mv energy.xvg $dir_analysis/$fullpath/energy_$duration_name.xvg 
mv energy.txt $dir_analysis/$fullpath/energy_$duration_name.txt 

cat $dir_analysis/$fullpath/energy_$duration_name.xvg  | grep -v '@' | grep -v '#' | awk '{print $1, $2/20}' > $dir_analysis/$fullpath/surften_$duration_name.dat

cd $dir_analysis/$fullpath/

echo -n $temperature_name' ' > tmp
cat energy.txt | grep SurfTen | awk '{print $2/20}' >> tmp
cat tmp >> $dir_analysis/$fullpath2simulate/energy/surften_mean_$duration_name.dat
rm tmp


# simply plot the files given in the path
plotdata=surften_toplot_$duration_name.dat

# That the legend. Should look like: "y plot1 x plot2 x plot3" if plotting is used later
legend='\gamma_{liquid-vapour}(mN/m)'
legend=$legend' {\itt}(ps)'

cp surften_$duration_name.dat $plotdata

# Append legend
echo $legend > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata

ncols=1
ncols=$(($ncols*2))

# Edit the Matlab function to plot all replicas in one figure
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting.m > basic_plotting.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' basic_plotting.m
sed -i 's/SED_title_SED/Surface tension with '$version_property'nm slab length T='$temperature_name'K/g' basic_plotting.m
sed -i 's/SED_savename_SED/'$plotdata'/g' basic_plotting.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "basic_plotting($ncols)"

# Edit the Matlab function to plot all replicas in one figure
#sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting_xlim.m > basic_plotting_xlim.m
#sed -i 's/SED_plotfile_SED/'$plotdata'/g' basic_plotting_xlim.m
#sed -i 's/SED_title_SED/Surface tension with '$version_property'nm slab length T='$temperature_name'K/g' basic_plotting_xlim.m
#sed -i 's/SED_savename_SED/close-up+'$plotdata'/g' basic_plotting_xlim.m
#sed -i 's/SED_xlim_SED/400 1400/g' basic_plotting_xlim.m

# Run matlab
#$matlabdir/matlab -nodisplay -nosplash -r  "basic_plotting_xlim($ncols)"


#read -p "Press enter to continue..."
