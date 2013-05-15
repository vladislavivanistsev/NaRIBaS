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

numberofionpairs_name=$(echo ${current_numberofionpairs[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$surfacecharge_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name
fullpath2equilibration=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$replica_name
#fullpath_referencegro=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/c/$surfacecharge_name/$replica_name

mkdir -p $dir_experiments/$fullpath
mkdir -p $dir_experiments/$fullpath2simulate

cd $dir_experiments/$fullpath
pwd

# Calculate the electrode positions
#calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
#deltaz=0.015 #nm
#calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

# Copy equillibrated structure
#cp $dir_experiments/$fullpath_referencegro/NPT.gro reference.gro

####################################

particle_left=$particle_name'l1'
particle_right=$particle_name'r1'

cp $dir_experiments/$fullpath2equilibration/NVT_lowtimestep.gro packmol.gro

#Prepare the index file
make_ndx -f packmol.gro -o index_slab.ndx << EOF
keep 0
a $cation_name
name 1 Cation
a $anion_name
name 2 Anion
a $particle_left
name 3 Anode
a $particle_right
name 4 Cathode
a $particle_left | a $particle_right
name 5 Electrodes 
q
EOF


#Add all necessary .mdp files
sed 's/SED_temperature_name_SED/'$temperature_name'/g' $dir_systempreparation/0_STEEP_Slab_emptyTemp.mdp > 0_STEEP_Slab.mdp
sed 's/SED_temperature_name_SED/'$temperature_name'/g' $dir_systempreparation/1_NVT_Slab_lowtimestep_emptyTemp.mdp > 1_NVT_Slab_lowtimestep.mdp
sed 's/SED_temperature_name_SED/'$temperature_name'/g' $dir_systempreparation/5_NVT_final_Slab_emptyTemp.mdp > 5_NVT_final_Slab.mdp

###################
# Sample calculation for charging an electrode modelled as small graphene sheet
#atoms/area = 1344/(5.90283 nm * 5.96400 nm) = 38.177 / nm^2 = 38.177 * 10^14 / cm^2
#surface charge [ muC/cm^2 = 10^-6 C/cm^2 ]
#elementary charge = 1.602 * 10^-19 C
#charge/atom = surface charge / (atoms/area) = 10^-6 / (1.602 * 10^-19 * 38.177 * 10^14) = 1.635068  * 10^-3 [ elementary charges ]
#A surface charge of 1 muC/cm^2 would result in a charge per atom of 1.635 * 10^-3 elementary charges, a surface charge of 2 muC/cm^2 would result in a charge per atom of 3.270 * 10^-3 elementary charges, etc.
#This charge needs to be multiplied by 1/sqrt(2) again due to polarization effects. 
###################

exp="$surfacecharge_name * 10^-6 / (1.602 * 10^-19 * $electrodeatoms/($xbox_nm*$ybox_nm) * 10^14) * 0.707"
charge=$(awk "BEGIN {print $exp}" /dev/null)

sed '/'$particle_name'l1/s/      0/'$charge'/g' $dir_systempreparation/top/Electrode.itp > Electrode_local.itp
sed -i '/'$particle_name'r1/s/       0/-'$charge'/g' Electrode_local.itp
#cp $scriptdir/top/Graphene/posre.itp .

echo 'Start converting the topology files ...'
sed 's+SED_dir_systempreparation_SED+'$dir_systempreparation'+g' $dir_systempreparation/topol_local_slab.top > topol_local.top
sed -i 's+SED_dir_gromacs_SED+'$dir_gromacs'+g' topol_local.top
sed -i 's/SED_cation_name_SED/'$cation_name'/g' topol_local.top
sed -i 's/SED_cation_num_SED/'$numberofionpairs_name'/g' topol_local.top
sed -i 's/SED_anion_name_SED/'$anion_name'/g' topol_local.top
sed -i 's/SED_anion_num_SED/'$numberofionpairs_name'/g' topol_local.top
sed -i 's/SED_particle_left_SED/'$particle_left'/g' topol_local.top
sed -i 's/SED_particle_right_SED/'$particle_right'/g' topol_local.top
sed -i 's/SED_electrodeatoms_SED/'$electrodeatoms'/g' topol_local.top

sed '/Electrode.itp/s/#include.*/#include "Electrode_local.itp"/' topol_local.top > topol_local_charged.top

#read -p "Press enter to continue..."

grompp -f 0_STEEP_Slab.mdp -c packmol.gro -p topol_local_charged.top -n index_slab.ndx -o STEEP -maxwarn 1
rm mdout.mdp
mdrun -deffnm STEEP -nt 1

grompp -f 1_NVT_Slab_lowtimestep.mdp -c STEEP.gro -p topol_local_charged.top -n index_slab.ndx -o NVT_lowtimestep -maxwarn 1
rm mdout.mdp
#mdrun -deffnm NVT_lowtimestep$replica -nt 12 -npme 6 -dd 3 2 1

runningnumber=$((totalnumberofsetups - 1))

# copy tpr files to run them somewhere as multijobs
cp NVT_lowtimestep.tpr $dir_experiments/$fullpath2simulate/NVT_lowtimestep$runningnumber.tpr

if [ $totalnumberofsetups -eq 1 ]; then
rm $dir_experiments/$fullpath2simulate/copyback.txt
fi

pathtocopyback=$(pwd)
echo "cp NVT_lowtimestep$runningnumber.tpr $pathtocopyback/NVT_lowtimestep.tpr" >> $dir_experiments/$fullpath2simulate/copyback.txt

#read -p "Press enter to continue..."
