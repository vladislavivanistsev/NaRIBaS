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
surfacecharge_name=$(echo ${current_surfacecharge[0]} | awk '{print $1}')
replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

# Define path for storing configurations / simulation data
#fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name/$replica_name
#fullpath_allreplicas=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath2simulate/energydistribution/temperature

cd $dir_analysis/$fullpath2simulate/energydistribution/temperature

pwd

plotdata=distr_$surfacecharge_name\_$replica_name.dat

if [ -e $plotdata ]
then
  rm $plotdata
fi
touch $plotdata

touch tmp.dat

legend='P({\itE_{total}})'

#+++++++++++++++++++++++
while read temperature_name;do
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name/$replica_name
legend=$legend' '$temperature_name' {\itE_{total}}(kJ/mol)'
paste $plotdata  $dir_analysis/$fullpath/energydistribution/distr.dat > tmp.dat
mv tmp.dat $plotdata
done < $currentdir/$inputlists_folder/temperature.list
#+++++++++++++++++++++++

edit_delete_last_lines $plotdata

# Append legend
#sed -i "1i$legend_1" $plotdata
echo $legend > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata

ncols=$(cat $currentdir/$inputlists_folder/temperature.list | wc -l)
ncols=$(($ncols*2))

# Edit the Matlab function to plot all replicas in one figure
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting.m > basic_plotting.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' basic_plotting.m
sed -i 's/SED_title_SED/''/g' basic_plotting.m
sed -i 's/SED_savename_SED/'$plotdata'/g' basic_plotting.m
sed -i 's/SED_legend_name_SED/{\\itT}(K)/g' basic_plotting.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "basic_plotting($ncols)"

#read -p 'Press Enter to continue...'

