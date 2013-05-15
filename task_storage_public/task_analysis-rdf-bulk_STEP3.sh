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
#temperature_name=$(echo ${current_temperature[0]} | awk '{print $1}')
version_name=$(echo ${current_version[0]} | awk '{print $1}')
#replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

rdf_name=$(echo ${current_rdf[0]} | awk '{print $1"-"$2}')
rdf_specie1=$(echo ${current_rdf[0]} | awk '{print $1}')
rdf_specie2=$(echo ${current_rdf[0]} | awk '{print $2}')

# Define path for storing configurations / simulation data
#fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$replica_name
#fullpath_allreplicas=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

cd $dir_analysis/$fullpath2simulate/rdf

pwd

# Create the files that combine all subfiles of a specific property, e.g. all replicas
plotdata_rdf='rdf+'$rdf_name'+'$duration_name'+alltemperatures.dat'
if [ -e $plotdata_rdf ]; then
  rm $plotdata_rdf 
fi
touch $plotdata_rdf

plotdata_cn='cn+'$rdf_name'+'$duration_name'+alltemperatures.dat'
if [ -e $plotdata_cn ]; then
  rm $plotdata_cn 
fi
touch $plotdata_cn

# That is the legend. Should look like: "y plot1 x plot2 x plot3"
legend_rdf='g(r)'
legend_cn='cn(r)'

while read inputline
do
temperature_name=$(echo ${inputline} | awk '{print $1}')
fullpath_allreplicas=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/
legend_rdf=$legend_rdf' '$temperature_name' r(nm)'
cp $plotdata_rdf tmp
paste tmp $dir_analysis/$fullpath_allreplicas/'rdf+'$rdf_name'+'$duration_name'+combined.dat' > $plotdata_rdf 
rm tmp
done < $currentdir/$inputlists_folder/temperature.list

while read inputline
do
temperature_name=$(echo ${inputline} | awk '{print $1}')
fullpath_allreplicas=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/
legend_cn=$legend_cn' '$temperature_name' r(nm)'
cp $plotdata_cn tmp
paste tmp $dir_analysis/$fullpath_allreplicas/'cn+'$rdf_name'+'$duration_name'+combined.dat' > $plotdata_cn 
rm tmp
done < $currentdir/$inputlists_folder/temperature.list

# Delete the last lines of a file until number of rows is equal for all columns
edit_delete_last_lines $plotdata_rdf
edit_delete_last_lines $plotdata_cn

# Append legend
sed -i 1i"$legend_rdf" $plotdata_rdf 
sed -i 1i"$legend_cn" $plotdata_cn

ncols=$(cat $currentdir/$inputlists_folder/temperature.list | wc -l)
ncols=$(($ncols*2))

# Edit the Matlab function to plot all replicas in one figure
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting_alloptions.m > plotscript.m
sed -i 's/SED_plotfile_SED/'$plotdata_rdf'/g' plotscript.m
sed -i 's/SED_title_SED/'$rdf_name'/g' plotscript.m
sed -i 's/SED_savename_SED/'$plotdata_rdf'/g' plotscript.m
sed -i 's/SED_xlim_SED/0 4/g' plotscript.m
sed -i 's/SED_legend_name_SED/{\\itT}(K)/g' plotscript.m

# Run matlab
#Description: basic_plotting_alloptions(ncols,setdifference,setxlim,setylim,setcolorstyle,setlegendloc,setxsize,setysize)
echo "execute $matlabdir/matlab -nodisplay -nosplash -r plotscript($ncols,0,1,0,6)"
xterm -e $matlabdir/matlab -nodisplay -nosplash -r "plotscript($ncols,0,1,0,6)"
xdg-open ${plotdata_rdf/dat/eps}

# Edit the Matlab function to plot all replicas in one figure
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting_alloptions.m > plotscript.m
sed -i 's/SED_plotfile_SED/'$plotdata_cn'/g' plotscript.m
sed -i 's/SED_title_SED/'$rdf_name'/g' plotscript.m
sed -i 's/SED_savename_SED/'$plotdata_cn'/g' plotscript.m
sed -i 's/SED_legend_name_SED/{\\itT}(K)/g' plotscript.m

sed -i 's/SED_xlim_SED/0 2/g' plotscript.m

# Run matlab
#Description: basic_plotting_alloptions(ncols,setdifference,setxlim,setylim,setcolorstyle,setlegendloc,setxsize,setysize)
echo "execute $matlabdir/matlab -nodisplay -nosplash -r plotscript($ncols,0,1,0,6)"
xterm -e $matlabdir/matlab -nodisplay -nosplash -r "plotscript($ncols,0,1,0,6)"
xdg-open ${plotdata_cn/dat/eps}

#read -p "Press enter to continue..."
