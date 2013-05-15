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
replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

numberdens_name=$(echo ${current_numberdens[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath_allreplicas=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

cd $dir_analysis/$fullpath_allreplicas

#mkdir -p $dir_analysis/$fullpath2simulate/numberdens/
#date >> $dir_analysis/$fullpath2simulate/rdf/output.out

# Calculate the electrode positions
calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
#deltaz=0.015 #nm
#calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

pwd

plotdata='numberdens_normalized+'$numberdens_name'+'$duration_name'.dat'
plotdata2='numberdens+'$numberdens_name'+'$duration_name'.dat'

if [ -e $plotdata ]
then
  rm $plotdata
  rm $plotdata2
fi
touch $plotdata
touch $plotdata2

touch tmp.dat

legend_1='\rho_N/\rho_{N0}'
legend_2='\rho_N'

#+++++++++++++++++++++++
while read replica_name;do
legend_1=$legend_1' '$replica_name' z(nm)'
legend_2=$legend_2' '$replica_name' z(nm)'
paste $plotdata  $replica_name/$plotdata > tmp.dat
mv tmp.dat $plotdata
paste $plotdata2  $replica_name/$plotdata2 > tmp.dat
mv tmp.dat $plotdata2
done < $currentdir/$inputlists_folder/replica.list
#+++++++++++++++++++++++

# Append legend
#sed -i "1i$legend_1" $plotdata
echo $legend_1 > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata
echo $legend_2 > tmp.dat; cat $plotdata2 >> tmp.dat; mv tmp.dat $plotdata2

ncols=$(cat $currentdir/$inputlists_folder/replica.list | wc -l)
ncols=$(($ncols*2))

# Edit the Matlab function to calculate the mean of all replicas
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/combine_replicas.m > combine_replicas.m
sed -i 's/SED_file_SED/'$plotdata2'/g' combine_replicas.m
sed -i 's/SED_savename_SED/numberdens+'$numberdens_name'+'$duration_name'+combined.dat/g' combine_replicas.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "combine_replicas($ncols)"
