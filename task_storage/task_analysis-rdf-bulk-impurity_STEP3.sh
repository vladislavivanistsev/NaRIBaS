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
#combination_name=$(echo ${current_combination[0]} | awk '{print $1"-"$2"-"$3}')
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
#fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$combination_name/$temperature_name/$version_name/$replica_name
#fullpath_allreplicas=$particle_name/$cation_name/$anion_name/$impurity_name/$combination_name/$temperature_name/$version_name/
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

cd $dir_analysis/$fullpath2simulate/rdf

pwd

# Create the files that combine all supbfiles of a specific property, e.g. all replicas
plotdata_rdf='rdf+'$rdf_name'+'$duration_name'+allcombinations.dat'
if [ -e $plotdata_rdf ]; then
  rm $plotdata_rdf 
fi
touch $plotdata_rdf

plotdata_cn='cn+'$rdf_name'+'$duration_name'+allcombinations.dat'
if [ -e $plotdata_cn ]; then
  rm $plotdata_cn 
fi
touch $plotdata_cn

# That is the legend. Should look like: "y plot1 x plot2 x plot3" if plotting is used later
legend_rdf='g(r)'
legend_cn='cn(r)'

while read inputline
do
#i1="$(echo $inputline | cut -d' ' -f1)"
#i2="$(echo $inputline | cut -d' ' -f2)"
#i3="$(echo $inputline | cut -d' ' -f3)"
#combination_name=$i1'-'$i2'-'$i3
combination_name=$(echo ${inputline} | awk '{print $1"-"$2"-"$3}')
combination_3=$(echo ${inputline} | awk '{print $3/$2*100"%"}')
fullpath_allreplicas=$particle_name/$cation_name/$anion_name/$impurity_name/$combination_name/$temperature_name/$version_name/
legend_rdf=$legend_rdf' '$combination_3' r(nm)'
legend_cn=$legend_cn' '$combination_3' r(nm)'
cp $plotdata_rdf tmp
paste tmp $dir_analysis/$fullpath_allreplicas/'rdf+'$rdf_name'+'$duration_name'+combined.dat' > $plotdata_rdf 
cp $plotdata_cn tmp
paste tmp $dir_analysis/$fullpath_allreplicas/'cn+'$rdf_name'+'$duration_name'+combined.dat' > $plotdata_cn 
rm tmp
done < $currentdir/$inputlists_folder/combination.list

# Delete the last lines of a file until number of rows is equal for all columns
edit_delete_last_lines $plotdata_rdf
edit_delete_last_lines $plotdata_cn

# Append legend
sed -i 1i"$legend_rdf" $plotdata_rdf 
sed -i 1i"$legend_cn" $plotdata_cn

ncols=$(cat $currentdir/$inputlists_folder/combination.list | wc -l)
ncols=$(($ncols*2))

# Edit the Matlab function to plot all replicas in one figure
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting_xlim.m > basic_plotting.m
sed -i 's/SED_plotfile_SED/'$plotdata_rdf'/g' basic_plotting.m
sed -i 's/SED_title_SED/rdf+'$rdf_name'+'$duration_name'/g' basic_plotting.m
sed -i 's/SED_savename_SED/'$plotdata_rdf'/g' basic_plotting.m
sed -i 's/SED_legend_name_SED/Impurity conc./g' basic_plotting.m
sed -i 's/SED_xlim_SED/0 4/g' basic_plotting.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "basic_plotting($ncols)"

# Edit the Matlab function to plot all replicas in one figure
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting.m > basic_plotting.m
sed -i 's/SED_plotfile_SED/'$plotdata_cn'/g' basic_plotting.m
sed -i 's/SED_title_SED/cn+'$rdf_name'+'$duration_name'/g' basic_plotting.m
sed -i 's/SED_savename_SED/'$plotdata_cn'/g' basic_plotting.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "basic_plotting($ncols)"
