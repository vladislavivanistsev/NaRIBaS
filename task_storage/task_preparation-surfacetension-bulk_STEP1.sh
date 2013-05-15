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
temperature_name=$(echo ${current_temperature[0]} | awk '{print $1}')
version_name=$(echo ${current_version[0]} | awk '{print $1}')
replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

version_property1=$(echo ${current_version[0]} | awk '{print $2}') # total vacuum size
version_property2=$(echo ${current_version[0]} | awk '{print $3}') # translation in z direction

numberofionpairs_name=$(echo ${current_numberofionpairs[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

fullpath_referencegro=Bulk/$cation_name/$anion_name/$impurity_name/$temperature_name/a/$replica_name

mkdir -p $dir_experiments/$fullpath
mkdir -p $dir_experiments/$fullpath2simulate

cd $dir_experiments/$fullpath

# Copy equillibrated structure
cp $dir_experiments/$fullpath_referencegro/NPT.gro reference.gro

# Add a 35 nm slab (recommendation: at least 10 times the largest ionic diamater. This would result in at least 10 nm vacuum slab.)
editconf -f reference.gro -o reference_translated.gro -translate 0 0 $version_property2
head -n -1 reference_translated.gro > reference_extended.gro
echo $(tail -1 reference.gro | awk '{print $1, $2, $3 + '$version_property1'}') >> reference_extended.gro # Change here the slab size!

echo 'Create the index file ...'
make_ndx -f reference_extended.gro -o index_bulk.ndx << EOF
keep 0
a $cation_name
name 1 Cation
a $anion_name
name 2 Anion
q
EOF

# Copy the appropriate topology and mdp files
echo 'Start converting the mdp input files ...'
sed 's/SED_temperature_name_SED/'$temperature_name'/g' $dir_systempreparation/0_surfacetension_emptyTemp.mdp > 0_surfacetension.mdp
sed -i 's/SED_energygrps_SED/Cation Anion/g' 0_surfacetension.mdp
sed -i 's/SED_xtcgrps_SED/Cation Anion/g' 0_surfacetension.mdp

echo 'Start converting the topology files ...'
sed 's+SED_dir_systempreparation_SED+'$dir_systempreparation'+g' $dir_systempreparation/topol_local_bulk.top > topol_local.top
sed -i 's+SED_dir_gromacs_SED+'$dir_gromacs'+g' topol_local.top
sed -i 's/SED_cation_name_SED/'$cation_name'/g' topol_local.top
sed -i 's/SED_cation_num_SED/'$numberofionpairs_name'/g' topol_local.top
sed -i 's/SED_anion_name_SED/'$anion_name'/g' topol_local.top
sed -i 's/SED_anion_num_SED/'$numberofionpairs_name'/g' topol_local.top
sed -i 's/SED_impurity_name_SED/''/g' topol_local.top
sed -i 's/SED_impurity_num_SED/''/g' topol_local.top

# Compile and run the system
echo 'Compile (grompp) the setup files and run energy minimization ...'
grompp -f 0_surfacetension.mdp -c reference_extended.gro -p topol_local.top -n index_bulk.ndx -o NVT
rm mdout.mdp
#mdrun -deffnm NVT -nt 12 -v

cp NVT.tpr $dir_experiments/$fullpath2simulate/NVT$totalnumberofsetups.tpr
pathtocopyback=$(pwd)
rm copyback.txt
echo "cp NVT$totalnumberofsetups.tpr $pathtocopyback/NVT.tpr" >> $dir_experiments/$fullpath2simulate/copyback.txt

#read -p "Press enter to continue..."
