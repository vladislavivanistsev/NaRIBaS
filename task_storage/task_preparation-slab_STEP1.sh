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

numionpairs=$(echo ${current_numberofionpairs[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

#fullpath_referencegro=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/c/$surfacecharge_name/$replica_name

mkdir -p $dir_experiments/$fullpath
mkdir -p $dir_experiments/$fullpath2simulate

# Calculate the electrode positions
calc_electrode_positions_in_slab

# How many slices to take into account? deltaz is the width
#deltaz=0.015 #nm
#calc_slicing_of_slab
# Two properties should now be available: $numberofslices and $currentdens

# Copy equillibrated structure
#cp $dir_experiments/$fullpath_referencegro/NPT.gro reference.gro

####################################

# Start with packmol: Add all particle names and calculated values concerning the box size to the packmpl script.

cd $dir_systempreparation

echo 'Start converting the packmol input file packmol.inp ...'
sed 's+SED_dir_systempreparation_SED+'$dir_systempreparation'+g' packmol_slab.inp > packmol.inp

seeds=( 173627 1983757 9305733 938561 7552618 3542638 9361537 39571623 )
seed=${seeds[$replica_name]}
sed -i 's/SED_seed_SED/'$seed'/g' packmol.inp

sed -i 's/SED_cation_name_SED/'$cation_name'/g' packmol.inp
sed -i 's/SED_cation_num_SED/'$numionpairs'/g' packmol.inp

sed -i 's/SED_anion_name_SED/'$anion_name'/g' packmol.inp
sed -i 's/SED_anion_num_SED/'$numionpairs'/g' packmol.inp

sed -i 's/SED_xbox_SED/'$xbox'/g' packmol.inp
sed -i 's/SED_ybox_SED/'$ybox'/g' packmol.inp
sed -i 's/SED_zbox_left_SED/'$z1_ion'/g' packmol.inp
sed -i 's/SED_zbox_right_SED/'$z2_ion'/g' packmol.inp

particle_left=$particle_name'l1'
particle_right=$particle_name'r1'

sed -i 's/SED_electrode_name_left_SED/'$particle_left'/g' packmol.inp
sed -i 's/SED_electrode_name_right_SED/'$particle_right'/g' packmol.inp

sed -i 's/SED_pos_left_electrode_SED/'$pos_left_electrode'/g' packmol.inp
sed -i 's/SED_pos_right_electrode_SED/'$pos_right_electrode'/g' packmol.inp

echo 'Run packmol and convert packmol output to gromacs input ...'
$dir_packmol/packmol < packmol.inp
editconf -f packmol.pdb -o packmol.gro
rm packmol.pdb packmol.inp

#read -p "Press enter to continue..."

#+++++++++++++++++++++++

#Edit the box size to insert the vacuum slab
sed -i '$d' packmol.gro
echo $xbox_nm $ybox_nm $zbox_vacuum >> packmol.gro

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
sed 's/SED_temperature_name_SED/'$temperature_name'/g' 0_STEEP_Slab_emptyTemp.mdp > 0_STEEP_Slab.mdp
sed 's/SED_temperature_name_SED/'$temperature_name'/g' 1_NVT_Slab_lowtimestep_emptyTemp.mdp > 1_NVT_Slab_lowtimestep.mdp
sed 's/SED_temperature_name_SED/'$temperature_name'/g' 5_NVT_final_Slab_emptyTemp.mdp > 5_NVT_final_Slab.mdp

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

#Move everything to the rundirectory
mv 0_STEEP_Slab.mdp 1_NVT_Slab_lowtimestep.mdp 5_NVT_final_Slab.mdp topol_local.top packmol.gro index_slab.ndx $dir_experiments/$fullpath/

#read -p "Press enter to continue..."

#+++++++++++++++++++++++
cd $dir_experiments/$fullpath/

#grompp and run the energy minimzation
grompp -f 0_STEEP_Slab.mdp -c packmol.gro -p topol_local.top -n index_slab.ndx -o STEEP -maxwarn 1
rm mdout.mdp
mdrun -deffnm STEEP -nt 1
#grompp the first equilibration step
grompp -f 1_NVT_Slab_lowtimestep.mdp -c STEEP.gro -p topol_local.top -n index_slab.ndx -o NVT_lowtimestep
rm mdout.mdp
# takes approx. 2 hours
#mdrun -deffnm NVT_lowtimestep -nt 12 -npme 6 -dd 3 2 1 -v

runningnumber=$((totalnumberofsetups - 1))

# copy tpr files to run them somewhere as multijobs
cp NVT_lowtimestep.tpr $dir_experiments/$fullpath2simulate/NVT_lowtimestep$runningnumber.tpr

if [ $totalnumberofsetups -eq 1 ]; then
rm $dir_experiments/$fullpath2simulate/copyback.txt
fi

pathtocopyback=$(pwd)
echo "cp NVT_lowtimestep$runningnumber.tpr $pathtocopyback/NVT_lowtimestep.tpr" >> $dir_experiments/$fullpath2simulate/copyback.txt

#read -p "Press enter to continue..."
