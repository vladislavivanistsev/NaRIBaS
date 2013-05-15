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
combination_name=$(echo ${current_combination[0]} | awk '{print $1"-"$2"-"$3}')
temperature_name=$(echo ${current_temperature[0]} | awk '{print $1}')
version_name=$(echo ${current_version[0]} | awk '{print $1}')
#replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NPT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NPT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NPT[0]} | awk '{print $2}')

rdf_name=$(echo ${current_rdf[0]} | awk '{print $1"-"$2}')
rdf_specie1=$(echo ${current_rdf[0]} | awk '{print $1}')
rdf_specie2=$(echo ${current_rdf[0]} | awk '{print $2}')


# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$combination_name/$temperature_name/$version_name/$replica_name
fullpath_allreplicas=$particle_name/$cation_name/$anion_name/$impurity_name/$combination_name/$temperature_name/$version_name/
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

cd $dir_analysis/$fullpath_allreplicas

pwd

mkdir -p $dir_analysis/$fullpath2simulate/rdf/

date >> $dir_analysis/$fullpath2simulate/rdf/output_extrema.txt
echo $fullpath_allreplicas >> $dir_analysis/$fullpath2simulate/rdf/output_extrema.txt

# Create the files that combine all subfiles of a specific property, e.g. all replicas
if [ -e 'rdf+'$rdf_name'+'$duration_name'.dat' ]; then
  rm 'rdf+'$rdf_name'+'$duration_name'.dat'
fi
touch 'rdf+'$rdf_name'+'$duration_name'.dat'

if [ -e 'cn+'$rdf_name'+'$duration_name'.dat' ]; then
  rm 'cn+'$rdf_name'+'$duration_name'.dat'
fi
touch 'cn+'$rdf_name'+'$duration_name'.dat'

# That the legend. Should look like: "y plot1 x plot2 x plot3" if plotting is used later
legend_rdf='g(r)'
legend_cn='cn(r)'

while read replica_name; do
legend_rdf=$legend_rdf' '$replica_name' r(nm)'
legend_cn=$legend_cn' '$replica_name' r(nm)'
cp 'rdf+'$rdf_name'+'$duration_name'.dat' tmp
paste tmp $replica_name/'rdf+'$rdf_name'+'$duration_name'.dat' > 'rdf+'$rdf_name'+'$duration_name'.dat'
cp 'cn+'$rdf_name'+'$duration_name'.dat' tmp
paste tmp $replica_name/'cn+'$rdf_name'+'$duration_name'.dat' > 'cn+'$rdf_name'+'$duration_name'.dat'
rm tmp
done < $currentdir/$inputlists_folder/replica.list

# Delete the last lines of a file until number of rows is equal for all columns
edit_delete_last_lines 'rdf+'$rdf_name'+'$duration_name'.dat'
edit_delete_last_lines 'cn+'$rdf_name'+'$duration_name'.dat'

# Append legend
sed -i 1i"$legend_rdf" 'rdf+'$rdf_name'+'$duration_name'.dat'
sed -i 1i"$legend_cn" 'cn+'$rdf_name'+'$duration_name'.dat'

ncols=$(cat $currentdir/$inputlists_folder/replica.list | wc -l)
ncols=$(($ncols*2))

# Edit the Matlab function to plot all replicas in one figure
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting.m > basic_plotting.m
sed -i 's/SED_plotfile_SED/rdf+'$rdf_name'+'$duration_name'.dat/g' basic_plotting.m
sed -i 's/SED_title_SED/rdf+'$rdf_name'+'$duration_name'/g' basic_plotting.m
sed -i 's/SED_savename_SED/rdf+'$rdf_name'+'$duration_name'+replicas.dat/g' basic_plotting.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "basic_plotting($ncols)"

# Edit the Matlab function to combine the replicas
#sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/rdf_combine_replicas.m > rdf_combine_replicas.m
#sed -i 's/SED_rdf-file_SED/rdf+'$rdf_name'+'$duration_name'.dat/g' rdf_combine_replicas.m
#sed -i 's/SED_cn-file_SED/cn+'$rdf_name'+'$duration_name'.dat/g' rdf_combine_replicas.m
#sed -i 's/SED_title_SED/rdf+'$rdf_name'+'$duration_name'/g' rdf_combine_replicas.m
#sed -i 's/SED_rdf_savename_SED/rdf+'$rdf_name'+'$duration_name'+combined.dat/g' rdf_combine_replicas.m
#sed -i 's/SED_cn_savename_SED/cn+'$rdf_name'+'$duration_name'+combined.dat/g' rdf_combine_replicas.m

# Run matlab
#$matlabdir/matlab -nodisplay -nosplash -r  "rdf_combine_replicas($ncols)"

#echo $rdf_name+$duration_name >> $dir_analysis/$fullpath2simulate/rdf/output_extrema.txt
#head -4 tmp >> $dir_analysis/$fullpath2simulate/rdf/output_extrema.txt
#rm tmp

# Edit the Matlab function to plot all replicas in one figure
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/combine_replicas.m > combine_replicas.m
sed -i 's/SED_file_SED/rdf+'$rdf_name'+'$duration_name'.dat/g' combine_replicas.m
sed -i 's/SED_savename_SED/rdf+'$rdf_name'+'$duration_name'+combined.dat/g' combine_replicas.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "combine_replicas($ncols)"

# Edit the Matlab function to plot all replicas in one figure
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/combine_replicas.m > combine_replicas.m
sed -i 's/SED_file_SED/cn+'$rdf_name'+'$duration_name'.dat/g' combine_replicas.m
sed -i 's/SED_savename_SED/cn+'$rdf_name'+'$duration_name'+combined.dat/g' combine_replicas.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "combine_replicas($ncols)"

