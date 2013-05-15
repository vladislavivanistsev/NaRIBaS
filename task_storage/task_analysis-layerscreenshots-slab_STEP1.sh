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
echo $surfacecharge_name
replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

duration_name=$(echo ${current_duration_NVT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NVT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NVT[0]} | awk '{print $2}')

numberdens_name=$(echo ${current_numberdens[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath/layer_snapshots/
dir_to_store=$dir_analysis/$fullpath2simulate/layer_snapshots/$temperature_name/
mkdir -p $dir_to_store

cd $dir_experiments/$fullpath

#mkdir -p $dir_analysis/$fullpath2simulate/rdf/
#date >> $dir_analysis/$fullpath2simulate/rdf/output.out

# Calculate the electrode positions
calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
#deltaz=0.015 #nm
#calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

# Prepare the execution of the gromacs tool and output storage

if [ ! -e index_screenshot.ndx ] 
then
make_ndx -f NVT.gro -o index_screenshot.ndx << EOF
keep 0
a $cation_name
name 1 Cation
a $anion_name
name 2 Anion
a $cation_name | a $anion_name
name 3 Ions
q
EOF
fi

grofile=NVT_Ions_30000.gro

echo Ions | trjconv -f NVT.xtc -s NVT.tpr -n index_screenshot.ndx -b 30000 -e 30000 -o $grofile

mv $grofile $dir_analysis/$fullpath/layer_snapshots/
cd $dir_analysis/$fullpath/layer_snapshots/

######################################################
# Cations at the Cathode

# Get the minima positions
min_pos_1=0.0
min_pos_2=0.0

while read inputline
do
   currentsigma="$(echo $inputline | cut -d' ' -f1)"
   currentmin1="$(echo $inputline | cut -d' ' -f2)"
   currentmin2="$(echo $inputline | cut -d' ' -f3)"
   tmp=$(echo $currentsigma $surfacecharge_name |  awk '{print $1 == -1*$2 }')
   if [ $tmp -eq 1 ]; then
      exp="$currentmin1" #*10.0"
      min_pos_1=$(awk "BEGIN {print $exp}" /dev/null)  #in A
      exp="$currentmin2" #*10.0"
      min_pos_2=$(awk "BEGIN {print $exp}" /dev/null)  #in A
   fi
done < $dir_analysis/$fullpath2simulate/layer/$temperature_name/ionnumber+Cation-Cathode+$temperature_name+minposition+oversigma.dat

# First layer
exp="$pos_right_electrode_nm-$min_pos_1"
min_pos_start=$(awk "BEGIN {print $exp}" /dev/null)  #in A
min_pos_end=$pos_right_electrode_nm

echo $min_pos_start $min_pos_end

plotdata=plotfile_Cation_Cathode.dat
if [ -e $plotdata ]; then
	rm $plotdata
fi
touch $plotdata

cat $grofile | grep "$cation_name" | awk '{print $(NF-2),$(NF-1),$(NF)}' |  awk -v minposstart="$min_pos_start" '$3 > minposstart' | awk -v minposend="$min_pos_end" '$3 < minposend' >> $plotdata

#cat $plotdata

#sed 's+SED_grofile_SED+'$grofile'+g' $currentdir/source/vmd_create-snapshots_slab_electrode.tcl > vmd_create-snapshots_slab_electrode.tcl
#sed -i 's+SED_min_pos_start_SED+'$min_pos_start'+g' vmd_create-snapshots_slab_electrode.tcl
#sed -i 's+SED_min_pos_end_SED+'$min_pos_end'+g' vmd_create-snapshots_slab_electrode.tcl

#$dir_vmd/vmd -dispdev text -eofexit -e vmd_create-snapshots_slab_electrode.tcl # does not work here as I need the gui for graphical representation
#$dir_vmd/vmd -e vmd_create-snapshots_slab_electrode.tcl

#$dir_vmd/vmd << EOF
#source vmd_create-snapshots_slab_electrode.tcl
#quit
#EOF

legend='x(nm) y(nm) z(nm)'

# Append legend
echo $legend > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata

ncols=3
#ncols=$(($ncols*2))

# Edit the Matlab function to plot the snapshot
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/plotting_snapshots_slab_electrode.m > plotting_snapshots_slab_electrode.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' plotting_snapshots_slab_electrode.m
#sed -i 's/SED_title_SED/Cation Cathode '$min_pos_start'nm-'$min_pos_end'nm/g' plotting_snapshots_slab_electrode.m
sed -i 's|SED_title_SED|Cation Cathode -'$surfacecharge_name'\\muCcm^{-2} 0.0-'$min_pos_1'nm|g' plotting_snapshots_slab_electrode.m
sed -i 's/SED_savename_SED/'$plotdata'/g' plotting_snapshots_slab_electrode.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "plotting_snapshots_slab_electrode($ncols,1)" # The number defines the color: 1=red, 2=blue


######################################################
# Cations at the Cathode, 2. minimum

# Get the minima positions
min_pos_1=0.0
min_pos_2=0.0

while read inputline
do
   currentsigma="$(echo $inputline | cut -d' ' -f1)"
   currentmin1="$(echo $inputline | cut -d' ' -f2)"
   currentmin2="$(echo $inputline | cut -d' ' -f3)"
   tmp=$(echo $currentsigma $surfacecharge_name |  awk '{print $1 == -1*$2 }')
   if [ $tmp -eq 1 ]; then
      exp="$currentmin1" #*10.0"
      min_pos_1=$(awk "BEGIN {print $exp}" /dev/null)  #in A
      exp="$currentmin2" #*10.0"
      min_pos_2=$(awk "BEGIN {print $exp}" /dev/null)  #in A
   fi
done < $dir_analysis/$fullpath2simulate/layer/$temperature_name/ionnumber+Cation-Cathode+$temperature_name+minposition+oversigma.dat

# First layer
exp="$pos_right_electrode_nm-$min_pos_2"
min_pos_start=$(awk "BEGIN {print $exp}" /dev/null)  #in A
exp="$pos_right_electrode_nm-$min_pos_1"
min_pos_end=$(awk "BEGIN {print $exp}" /dev/null)  #in A

echo $min_pos_start $min_pos_end

plotdata=plotfile_Cation_Cathode_second.dat
if [ -e $plotdata ]; then
	rm $plotdata
fi
touch $plotdata

cat $grofile | grep "$cation_name" | awk '{print $(NF-2),$(NF-1),$(NF)}' |  awk -v minposstart="$min_pos_start" '$3 > minposstart' | awk -v minposend="$min_pos_end" '$3 < minposend' >> $plotdata

legend='x(nm) y(nm) z(nm)'

# Append legend
echo $legend > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata

ncols=3
#ncols=$(($ncols*2))

# Edit the Matlab function to plot the snapshot
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/plotting_snapshots_slab_electrode.m > plotting_snapshots_slab_electrode.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' plotting_snapshots_slab_electrode.m
#sed -i 's/SED_title_SED/Cation Cathode '$min_pos_start'nm-'$min_pos_end'nm/g' plotting_snapshots_slab_electrode.m
sed -i 's|SED_title_SED|Cation Cathode -'$surfacecharge_name'\\muCcm^{-2} '$min_pos_1'-'$min_pos_2'nm|g' plotting_snapshots_slab_electrode.m
sed -i 's/SED_savename_SED/'$plotdata'/g' plotting_snapshots_slab_electrode.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "plotting_snapshots_slab_electrode($ncols,1)" # The number defines the color: 1=red, 2=blue


######################################################
# Cations at the Cathode, 1. and 2. minimum

# Get the minima positions
min_pos_1=0.0
min_pos_2=0.0

while read inputline
do
   currentsigma="$(echo $inputline | cut -d' ' -f1)"
   currentmin1="$(echo $inputline | cut -d' ' -f2)"
   currentmin2="$(echo $inputline | cut -d' ' -f3)"
   tmp=$(echo $currentsigma $surfacecharge_name |  awk '{print $1 == -1*$2 }')
   if [ $tmp -eq 1 ]; then
      exp="$currentmin1" #*10.0"
      min_pos_1=$(awk "BEGIN {print $exp}" /dev/null)  #in A
      exp="$currentmin2" #*10.0"
      min_pos_2=$(awk "BEGIN {print $exp}" /dev/null)  #in A
   fi
done < $dir_analysis/$fullpath2simulate/layer/$temperature_name/ionnumber+Cation-Cathode+$temperature_name+minposition+oversigma.dat

# First layer
exp="$pos_right_electrode_nm-$min_pos_2"
min_pos_start=$(awk "BEGIN {print $exp}" /dev/null)  #in A
min_pos_end=$pos_right_electrode_nm

echo $min_pos_start $min_pos_end

plotdata=plotfile_Cation_Cathode_firstsecond.dat
if [ -e $plotdata ]; then
	rm $plotdata
fi
touch $plotdata

cat $grofile | grep "$cation_name" | awk '{print $(NF-2),$(NF-1),$(NF)}' |  awk -v minposstart="$min_pos_start" '$3 > minposstart' | awk -v minposend="$min_pos_end" '$3 < minposend' >> $plotdata

legend='x(nm) y(nm) z(nm)'

# Append legend
echo $legend > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata

ncols=3
#ncols=$(($ncols*2))

# Edit the Matlab function to plot the snapshot
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/plotting_snapshots_slab_electrode.m > plotting_snapshots_slab_electrode.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' plotting_snapshots_slab_electrode.m
#sed -i 's/SED_title_SED/Cation Cathode '$min_pos_start'nm-'$min_pos_end'nm/g' plotting_snapshots_slab_electrode.m
sed -i 's|SED_title_SED|Cation Cathode -'$surfacecharge_name'\\muCcm^{-2} 0.0-'$min_pos_2'nm|g' plotting_snapshots_slab_electrode.m
sed -i 's/SED_savename_SED/'$plotdata'/g' plotting_snapshots_slab_electrode.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "plotting_snapshots_slab_electrode($ncols,1)" # The number defines the color: 1=red, 2=blue


######################################################
# Anions at the Cathode

# Get the minima positions
min_pos_1=0.0
min_pos_2=0.0

while read inputline
do
   currentsigma="$(echo $inputline | cut -d' ' -f1)"
   currentmin1="$(echo $inputline | cut -d' ' -f2)"
   currentmin2="$(echo $inputline | cut -d' ' -f3)"
   tmp=$(echo $currentsigma $surfacecharge_name |  awk '{print $1 == -1*$2 }')
   if [ $tmp -eq 1 ]; then
      exp="$currentmin1" #*10.0"
      min_pos_1=$(awk "BEGIN {print $exp}" /dev/null)  #in A
      exp="$currentmin2" #*10.0"
      min_pos_2=$(awk "BEGIN {print $exp}" /dev/null)  #in A
   fi
done < $dir_analysis/$fullpath2simulate/layer/$temperature_name/ionnumber+Anion-Cathode+$temperature_name+minposition+oversigma.dat

# First layer
exp="$pos_right_electrode_nm-$min_pos_1"
min_pos_start=$(awk "BEGIN {print $exp}" /dev/null)  #in A
min_pos_end=$pos_right_electrode_nm

echo $min_pos_start $min_pos_end

plotdata=plotfile_Anion_Cathode.dat
if [ -e $plotdata ]; then
	rm $plotdata
fi
touch $plotdata

cat $grofile | grep "$anion_name" | awk '{print $(NF-2),$(NF-1),$(NF)}' |  awk -v minposstart="$min_pos_start" '$3 > minposstart' | awk -v minposend="$min_pos_end" '$3 < minposend' >> $plotdata

legend='x(nm) y(nm) z(nm)'

# Append legend
echo $legend > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata

ncols=3
#ncols=$(($ncols*2))

# Edit the Matlab function to plot the snapshot
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/plotting_snapshots_slab_electrode.m > plotting_snapshots_slab_electrode.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' plotting_snapshots_slab_electrode.m
#sed -i 's/SED_title_SED/Cation Cathode '$min_pos_start'nm-'$min_pos_end'nm/g' plotting_snapshots_slab_electrode.m
sed -i 's|SED_title_SED|Anion Cathode -'$surfacecharge_name'\\muCcm^{-2} 0.0-'$min_pos_1'nm|g' plotting_snapshots_slab_electrode.m
sed -i 's/SED_savename_SED/'$plotdata'/g' plotting_snapshots_slab_electrode.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "plotting_snapshots_slab_electrode($ncols,2)" # The number defines the color: 1=red, 2=blue



######################################################
# Cations at the Anode

# Get the minima positions
min_pos_1=0.0
min_pos_2=0.0

while read inputline
do
   currentsigma="$(echo $inputline | cut -d' ' -f1)"
   currentmin1="$(echo $inputline | cut -d' ' -f2)"
   currentmin2="$(echo $inputline | cut -d' ' -f3)"
   tmp=$(echo $currentsigma $surfacecharge_name |  awk '{print $1 == 1*$2 }')
   if [ $tmp -eq 1 ]; then
      exp="$currentmin1" #*10.0"
      min_pos_1=$(awk "BEGIN {print $exp}" /dev/null)  #in A
      exp="$currentmin2" #*10.0"
      min_pos_2=$(awk "BEGIN {print $exp}" /dev/null)  #in A
   fi
done < $dir_analysis/$fullpath2simulate/layer/$temperature_name/ionnumber+Cation-Anode+$temperature_name+minposition+oversigma.dat

# First layer
min_pos_start=0 
min_pos_end=$min_pos_1

echo $min_pos_start $min_pos_end

plotdata=plotfile_Cation_Anode.dat
if [ -e $plotdata ]; then
	rm $plotdata
fi
touch $plotdata

cat $grofile | grep "$cation_name" | awk '{print $(NF-2),$(NF-1),$(NF)}' |  awk -v minposstart="$min_pos_start" '$3 > minposstart' | awk -v minposend="$min_pos_end" '$3 < minposend' >> $plotdata

#cat $plotdata

#sed 's+SED_grofile_SED+'$grofile'+g' $currentdir/source/vmd_create-snapshots_slab_electrode.tcl > vmd_create-snapshots_slab_electrode.tcl
#sed -i 's+SED_min_pos_start_SED+'$min_pos_start'+g' vmd_create-snapshots_slab_electrode.tcl
#sed -i 's+SED_min_pos_end_SED+'$min_pos_end'+g' vmd_create-snapshots_slab_electrode.tcl

#$dir_vmd/vmd -dispdev text -eofexit -e vmd_create-snapshots_slab_electrode.tcl # does not work here as I need the gui for graphical representation
#$dir_vmd/vmd -e vmd_create-snapshots_slab_electrode.tcl

#$dir_vmd/vmd << EOF
#source vmd_create-snapshots_slab_electrode.tcl
#quit
#EOF

legend='x(nm) y(nm) z(nm)'

# Append legend
echo $legend > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata

ncols=3
#ncols=$(($ncols*2))

# Edit the Matlab function to plot the snapshot
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/plotting_snapshots_slab_electrode.m > plotting_snapshots_slab_electrode.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' plotting_snapshots_slab_electrode.m
sed -i 's|SED_title_SED|Cation Anode +'$surfacecharge_name'\\muCcm^{-2} 0.0-'$min_pos_1'nm|g' plotting_snapshots_slab_electrode.m
sed -i 's/SED_savename_SED/'$plotdata'/g' plotting_snapshots_slab_electrode.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "plotting_snapshots_slab_electrode($ncols,1)" # The number defines the color: 1=red, 2=blue

######################################################
# Anions at the Anode

# Get the minima positions
min_pos_1=0.0
min_pos_2=0.0

while read inputline
do
   currentsigma="$(echo $inputline | cut -d' ' -f1)"
   currentmin1="$(echo $inputline | cut -d' ' -f2)"
   currentmin2="$(echo $inputline | cut -d' ' -f3)"
   tmp=$(echo $currentsigma $surfacecharge_name |  awk '{print $1 == 1*$2 }')
   if [ $tmp -eq 1 ]; then
      exp="$currentmin1" #*10.0"
      min_pos_1=$(awk "BEGIN {print $exp}" /dev/null)  #in A
      exp="$currentmin2" #*10.0"
      min_pos_2=$(awk "BEGIN {print $exp}" /dev/null)  #in A
   fi
done < $dir_analysis/$fullpath2simulate/layer/$temperature_name/ionnumber+Anion-Anode+$temperature_name+minposition+oversigma.dat

# First layer
min_pos_start=0 
min_pos_end=$min_pos_1

echo $min_pos_start $min_pos_end

plotdata=plotfile_Anion_Anode.dat
if [ -e $plotdata ]; then
	rm $plotdata
fi
touch $plotdata

cat $grofile | grep "$anion_name" | awk '{print $(NF-2),$(NF-1),$(NF)}' |  awk -v minposstart="$min_pos_start" '$3 > minposstart' | awk -v minposend="$min_pos_end" '$3 < minposend' >> $plotdata

legend='x(nm) y(nm) z(nm)'

# Append legend
echo $legend > tmp.dat; cat $plotdata >> tmp.dat; mv tmp.dat $plotdata

ncols=3
#ncols=$(($ncols*2))

# Edit the Matlab function to plot the snapshot
sed 's+SED_dir_scripts_SED+'$currentdir'/source+g' $currentdir/source/plotting_snapshots_slab_electrode.m > plotting_snapshots_slab_electrode.m
sed -i 's/SED_plotfile_SED/'$plotdata'/g' plotting_snapshots_slab_electrode.m
sed -i 's|SED_title_SED|Anion Anode +'$surfacecharge_name'\\muCcm^{-2} 0.0-'$min_pos_1'nm|g' plotting_snapshots_slab_electrode.m
sed -i 's/SED_savename_SED/'$plotdata'/g' plotting_snapshots_slab_electrode.m

# Run matlab
$matlabdir/matlab -nodisplay -nosplash -r  "plotting_snapshots_slab_electrode($ncols,2)" # The number defines the color: 1=red, 2=blue

######################################################

convert plotfile_Cation_Cathode.eps $dir_to_store/Cation_Cathode_$surfacecharge_name\_$replica_name.jpg
convert plotfile_Cation_Cathode_firstsecond.eps $dir_to_store/Cation_Cathode_firstsecond_$surfacecharge_name\_$replica_name.jpg
convert plotfile_Cation_Cathode_second.eps $dir_to_store/Cation_Cathode_second_$surfacecharge_name\_$replica_name.jpg
convert plotfile_Anion_Cathode.eps $dir_to_store/Anion_Cathode_$surfacecharge_name\_$replica_name.jpg
convert plotfile_Cation_Anode.eps $dir_to_store/Cation_Anode_$surfacecharge_name\_$replica_name.jpg
convert plotfile_Anion_Anode.eps $dir_to_store/Anion_Anode_$surfacecharge_name\_$replica_name.jpg

#read -p "Press Enter to continue..."

