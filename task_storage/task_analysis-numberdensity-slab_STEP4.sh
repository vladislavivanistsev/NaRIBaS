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
replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

numberdens_name=$(echo ${current_numberdens[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath2simulate/middleoftheslabrdf
cd $dir_analysis/$fullpath2simulate/middleoftheslabrdf

#mkdir -p $dir_analysis/$fullpath2simulate/numberdens/
#date >> $dir_analysis/$fullpath2simulate/rdf/output.out

# Calculate the electrode positions
calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
#deltaz=0.015 #nm
#calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

exp="($pos_right_electrode_nm-$pos_left_electrode_nm)/2+$pos_left_electrode_nm"
pos_middle_of_the_slab_nm=$(awk "BEGIN {print $exp}" /dev/null)  #in nm

distance_calculate_mean=8 # in nm

exp="$pos_middle_of_the_slab_nm-$distance_calculate_mean/2"
pos_start_counting_nm=$(awk "BEGIN {print $exp}" /dev/null)  #in nm

exp="$pos_middle_of_the_slab_nm+$distance_calculate_mean/2"
pos_end_counting_nm=$(awk "BEGIN {print $exp}" /dev/null)  #in nm

pwd

plotdata='middle-numberdens+'$numberdens_name'+'$temperature_name'.dat'
plotdata_mean='mean-middle-numberdens+'$numberdens_name'+'$temperature_name'.dat'

if [ -e $plotdata ]
then
  rm $plotdata
  rm $plotdata_mean
fi
touch $plotdata
touch $plotdata_mean

ncols=$(cat $currentdir/$inputlists_folder/replica.list | wc -l)
ncols=$(($ncols*2))

#+++++++++++++++++++++++ Read the very first file to obtain the z value that is used for all files
head -1 $currentdir/$inputlists_folder/surfacecharge.list > surfacecharge_firstvalue.list

while read inputline;do

surfacecharge_name=$(echo $inputline | awk '{print $1}')
fullpath_allreplicas=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name

#echo $surfacecharge_name $pos_middle_of_the_slab_nm

tail -n +2 $dir_analysis/$fullpath_allreplicas/'numberdens+'$numberdens_name'+'$duration_name'.dat' > tmp.dat

linenumber=0
former_z_value=-1 # Assumption: the number density profile starts with zero or positive z value

while read fileinputline;do
   linenumber=$(($linenumber+1))
   current_z_value=$(echo $fileinputline | awk '{print $1}')
#   currentsigma="$(echo $inputline | cut -d' ' -f1)"
   boolean_start_former=$(echo $former_z_value $pos_start_counting_nm | awk '{print $1 < 1*$2 }') # true=1 if the former z value (last line) is less than the start value
   boolean_start_current=$(echo $current_z_value $pos_start_counting_nm | awk '{print $1 >= 1*$2 }') # true=1 if the current z value (current line) is more or equal than the start value
   boolean_end_former=$(echo $former_z_value $pos_end_counting_nm | awk '{print $1 < 1*$2 }')
   boolean_end_current=$(echo $current_z_value $pos_end_counting_nm | awk '{print $1 >= 1*$2 }')
   if [ $boolean_start_current -eq 1 -a $boolean_start_former -eq 1 ] ; then
      z_value_to_use=$current_z_value
      linennumber_start=$linenumber
   elif [ $boolean_end_current -eq 1 -a $boolean_end_former -eq 1 ] ; then
      linennumber_end=$linenumber
      break
   fi
   former_z_value=$current_z_value
done < tmp.dat # rm first line as it is the header

done < surfacecharge_firstvalue.list
#+++++++++++++++++++++++

rm surfacecharge_firstvalue.list

exp="$linennumber_end-$linennumber_start"
number_of_lines_to_scan=$(awk "BEGIN {print $exp}" /dev/null) 

#echo $pos_start_counting_nm $pos_end_counting_nm $linennumber_start $linennumber_end $number_of_lines_to_scan

#+++++++++++++++++++++++ Now run through all files and use sed or grep for the correct value
while read inputline;do

surfacecharge_name=$(echo $inputline | awk '{print $1}')
fullpath_allreplicas=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name

#echo $surfacecharge_name

#cat $dir_analysis/$fullpath_allreplicas/'numberdens+'$numberdens_name'+'$duration_name'.dat' | grep '  '$current_z_value'  ' | sed 's/  '$current_z_value'  /'$surfacecharge_name'/g' >> $plotdata

cat $dir_analysis/$fullpath_allreplicas/'numberdens+'$numberdens_name'+'$duration_name'.dat' | grep --after-context=$number_of_lines_to_scan '  '$z_value_to_use'  ' > calc.dat

cat calc.dat | awk -vcharge=$surfacecharge_name '{ SUM2 += $2; SUM4 += $4; SUM6 += $6; SUM8 += $8; SUM10 += $10; } END {print charge, SUM2/NR,charge, SUM4/NR,charge, SUM6/NR,charge, SUM8/NR,charge, SUM10/NR }' >> $plotdata

done < $currentdir/$inputlists_folder/surfacecharge.list
#+++++++++++++++++++++++

rm calc.dat 

legend=$(head -1 $dir_analysis/$fullpath_allreplicas/'numberdens+'$numberdens_name'+'$duration_name'.dat')
legend=$legend' mean z(nm)'

# add two columns containing again sigma and the mean of all densities
cat $plotdata | awk '{sum=0; for (col=2; col<=NF; col+=2) sum += $col; print $0,$1,sum/NF*2}' > tmp

cat $plotdata | awk '{sum=0; for (col=2; col<=NF; col+=2) sum += $col; print $1,sum/NF*2}' > $plotdata_mean

mv tmp $plotdata

# Append legend
#sed -i "1i$legend_1" $plotdata
echo $legend > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata

#change z(nm) in the legend to \sigma(\muC/cm^2)
sed -i 's|z(nm)|\\sigma(\\muCcm^{-2})|g' $plotdata

ncols=$(cat $currentdir/$inputlists_folder/replica.list | wc -l)
ncols=$(($ncols*2+2))

# Edit the Matlab function to calculate the mean of all replicas
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/plot_scatter_and_mean.m > plot_scatter_and_mean.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' plot_scatter_and_mean.m
sed -i 's/SED_savename_SED/'$plotdata'/g' plot_scatter_and_mean.m
sed -i 's/SED_title_SED/Ion pair number density T='$temperature_name' K/g' plot_scatter_and_mean.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "plot_scatter_and_mean($ncols)"


# Edit the Matlab function to calculate the mean of all replicas
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/plot_scatter_and_mean_limits.m > plot_scatter_and_mean_limits.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' plot_scatter_and_mean_limits.m
sed -i 's/SED_savename_SED/closeup+'$plotdata'/g' plot_scatter_and_mean_limits.m
sed -i 's/SED_title_SED/Ion pair number density T='$temperature_name' K/g' plot_scatter_and_mean_limits.m
sed -i 's/SED_xlim_SED/10 20/g' plot_scatter_and_mean_limits.m
sed -i 's/SED_ylim_SED/0.32 0.38/g' plot_scatter_and_mean_limits.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "plot_scatter_and_mean_limits($ncols)"

#read -p "Press enter to continue ..."
