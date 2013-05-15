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

duration_name=$(echo ${current_duration_NPT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NPT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NPT[0]} | awk '{print $2}')

numberofionpairs_name=$(echo ${current_numberofionpairs[0]} | awk '{print $1}')

energy_name=$(echo ${current_energy[0]} | awk '{print $1}')
energy_legend=$(echo ${current_energy[0]} | awk '{print $2}')

# Define path for storing configurations / simulation data
#fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

cd $dir_analysis/$fullpath2simulate/energy/

pwd

# simply plot the files given in the path
plotdata=$energy_name'_toplot.dat'

# That the legend. Should look like: "y plot1 x plot2 x plot3" if plotting is used later
legend=$energy_legend
legend=$legend' {\itT}(K)'

cp $energy_name'.dat' $plotdata

# Append legend
echo $legend > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata

ncols=1
ncols=$(($ncols*2))

# Edit the Matlab function to plot all replicas in one figure
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting_alloptions.m > plotscript.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' plotscript.m
sed -i 's/SED_title_SED/'$energy_name'/g' plotscript.m
sed -i 's/SED_savename_SED/'$plotdata'/g' plotscript.m
#sed -i 's/SED_legend_name_SED/{\\itT}(K)/g' plotscript.m

# Run matlab
#Description: basic_plotting_alloptions(ncols,setdifference,setxlim,setylim,setcolorstyle,setlegendloc,setxsize,setysize,setverticallines,sethorizontallines,setspecificplot)
echo "execute $matlabdir/matlab -nodisplay -nosplash -r plotscript($ncols,0,0,0,0,3,0,0,0,0,1)"
xterm -e $matlabdir/matlab -nodisplay -nosplash -r "plotscript($ncols,0,0,0,0,3,0,0,0,0,1)"
xdg-open ${plotdata/dat/eps}

# Edit the Matlab function to plot all replicas in one figure
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/basic_plotting_alloptions.m > plotscript.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' plotscript.m
sed -i 's/SED_title_SED/'$energy_name'/g' plotscript.m
sed -i 's/SED_savename_SED/'$plotdata'/g' plotscript.m
sed -i 's/SED_xlim_SED/200 400/g' plotscript.m
#sed -i 's/SED_legend_name_SED/{\\itT}(K)/g' plotscript.m

# Run matlab
#Description: basic_plotting_alloptions(ncols,setdifference,setxlim,setylim,setcolorstyle,setlegendloc,setxsize,setysize,setverticallines,sethorizontallines,setspecificplot)
echo "execute $matlabdir/matlab -nodisplay -nosplash -r plotscript($ncols,0,1,0,0,3,0,0,0,0,1)"
xterm -e $matlabdir/matlab -nodisplay -nosplash -r "plotscript($ncols,0,1,0,0,3,0,0,0,0,1)"
xdg-open ${plotdata/dat/eps}



