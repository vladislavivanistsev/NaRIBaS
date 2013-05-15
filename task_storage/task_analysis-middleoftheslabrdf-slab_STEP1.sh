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

rdf_name=$(echo ${current_rdf[0]} | awk '{print $1"-"$2}')
rdf_specie1=$(echo ${current_rdf[0]} | awk '{print $1}')
rdf_specie2=$(echo ${current_rdf[0]} | awk '{print $2}')

numberofionpairs_name=$(echo ${current_numberofionpairs[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath/middleoftheslabrdf/

cd $dir_experiments/$fullpath

#mkdir -p $dir_analysis/$fullpath2simulate/rdf/
#date >> $dir_analysis/$fullpath2simulate/rdf/output.out

# Calculate the electrode positions
calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
deltaz=0.015 #nm
calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

# Prepare the execution of the gromacs tool and output storage

if [ ! -e index_ions.ndx ] 
then
make_ndx -f NVT.gro -o index_ions.ndx << EOF
keep 0
del 0
a $cation | a $anion
name 1 Ions
q
EOF
fi

if [ ! -e NVT_ions.gro ] 
then
editconf -f NVT.gro -n index_ions.ndx -o NVT_ions.gro
fi

exp="$xbox_nm*10"
xbox_A=$(awk "BEGIN {print $exp}" /dev/null)  #in A

exp="$ybox_nm*10"
ybox_A=$(awk "BEGIN {print $exp}" /dev/null)  #in A

# Get the particle density
particledensity=0.0
while read inputline
do
   currentsigma="$(echo $inputline | cut -d' ' -f1)"
   currentdens="$(echo $inputline | cut -d' ' -f2)"
   boolean_sigma=$(echo $currentsigma $surfacecharge_name | awk '{print $1 == 1*$2 }')
   if [ $boolean_sigma -eq 1 ]; then
      particledensity=$currentdens
      break
   fi
done < $dir_analysis/$fullpath2simulate/middleoftheslabrdf/'mean-middle-numberdens+Anion+'$temperature_name'.dat'

exp="$numberofionpairs_name/($particledensity*$xbox_nm*$ybox_nm)*10"
zbox_A=$(awk "BEGIN {print $exp}" /dev/null)  #in A

sed 's/SED_xbox_SED/'$xbox_A'/g' $currentdir/source/vmd_create-middleoftheslabrdf.tcl > vmd_create-middleoftheslabrdf.tcl
sed -i 's/SED_ybox_SED/'$ybox_A'/g' vmd_create-middleoftheslabrdf.tcl
sed -i 's/SED_zbox_SED/'$zbox_A'/g' vmd_create-middleoftheslabrdf.tcl

$dir_vmd/vmd -dispdev text -eofexit -e vmd_create-middleoftheslabrdf.tcl 
#$dir_vmd/vmd -e vmd_create-snapshots_slab_electrode.tcl

#$dir_vmd/vmd << EOF
#source vmd_create-snapshots_slab_electrode.tcl
#quit
#EOF

rm vmd_create-middleoftheslabrdf.tcl 

mv measuregofr_Cation-Cation.dat $dir_analysis/$fullpath/middleoftheslabrdf/measuregofr+Cation-Cation.dat
mv measuregofr_Anion-Anion.dat $dir_analysis/$fullpath/middleoftheslabrdf/measuregofr+Anion-Anion.dat
mv measuregofr_Cation-Anion.dat $dir_analysis/$fullpath/middleoftheslabrdf/measuregofr+Cation-Anion.dat

cat $dir_analysis/$fullpath/middleoftheslabrdf/measuregofr+Cation-Cation.dat | awk '{print $1/10, $2}' > $dir_analysis/$fullpath/middleoftheslabrdf/rdf+Cation-Cation.dat
cat $dir_analysis/$fullpath/middleoftheslabrdf/measuregofr+Anion-Anion.dat | awk '{print $1/10, $2}' > $dir_analysis/$fullpath/middleoftheslabrdf/rdf+Anion-Anion.dat
cat $dir_analysis/$fullpath/middleoftheslabrdf/measuregofr+Cation-Anion.dat | awk '{print $1/10, $2}' > $dir_analysis/$fullpath/middleoftheslabrdf/rdf+Cation-Anion.dat

cat $dir_analysis/$fullpath/middleoftheslabrdf/measuregofr+Cation-Cation.dat | awk '{print $1/10, $3}' > $dir_analysis/$fullpath/middleoftheslabrdf/cn+Cation-Cation.dat
cat $dir_analysis/$fullpath/middleoftheslabrdf/measuregofr+Anion-Anion.dat | awk '{print $1/10, $3}' > $dir_analysis/$fullpath/middleoftheslabrdf/cn+Anion-Anion.dat
cat $dir_analysis/$fullpath/middleoftheslabrdf/measuregofr+Cation-Anion.dat | awk '{print $1/10, $3}' > $dir_analysis/$fullpath/middleoftheslabrdf/cn+Cation-Anion.dat


#read -p "Press Enter to continue..."
