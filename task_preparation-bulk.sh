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
cation_r_nm=$(echo ${current_cation[0]} | awk '{print $2}') #in nm

anion_name=$(echo ${current_anion[0]} | awk '{print $1}')
anion_r_nm=$(echo ${current_anion[0]} | awk '{print $2}') #in nm

impurity_name=$(echo ${current_impurity[0]} | awk '{print $1}')
impurity_r_nm=$(echo ${current_impurity[0]} | awk '{print $2}') #in nm

temperature_name=$(echo ${current_temperature[0]} | awk '{print $1}')
version_name=$(echo ${current_version[0]} | awk '{print $1}')
replica_name=$(echo ${current_replica[0]} | awk '{print $1}')

numionpairs=$(echo ${current_numberofionpairs[0]} | awk '{print $1}')

xbox=$(echo ${current_boxsize[0]} | awk '{print $1}') # in A
ybox=$(echo ${current_boxsize[0]} | awk '{print $2}') # in A
zbox=$(echo ${current_boxsize[0]} | awk '{print $3}') # in A

begin=$(echo ${current_duration_NPT[0]} | awk '{print $1}')
end=$(echo ${current_duration_NPT[0]} | awk '{print $2}')
dt=$(echo ${current_duration_NPT[0]} | awk '{print $3}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$temperature_name/$version_name/$replica_name

echo $dir_experiments
mkdir -p $dir_experiments/$fullpath

cd $dir_systempreparation

echo 'Start converting the packmol input file packmol.inp ...'
#sed 's+SCRIPTDIR_BY_SED+'$dir_systempreparation'+g' packmol_bulk.inp > packmol.inp
sed 's+SED_dir_systempreparation_SED+'$dir_systempreparation'+g' packmol_bulk.inp > packmol.inp

seeds=( 173627 1983757 9305733 938561 7552618 3542638 9361537 39571623 )
seed=${seeds[$replica_name]}
sed -i 's/SED_seed_SED/'$seed'/g' packmol.inp

sed -i 's/SED_cation_name_SED/'$cation_name'/g' packmol.inp
sed -i 's/SED_cation_num_SED/'$cation_num'/g' packmol.inp

sed -i 's/SED_anion_name_SED/'$anion_name'/g' packmol.inp
sed -i 's/SED_anion_num_SED/'$anion_num'/g' packmol.inp

sed -i 's/SED_xbox_SED/'$xbox'/g' packmol.inp
sed -i 's/SED_ybox_SED/'$ybox'/g' packmol.inp
sed -i 's/SED_zbox_SED/'$zbox'/g' packmol.inp

echo 'Run packmol and convert packmol output to gromacs input ...'
$dir_packmol/packmol < packmol.inp
editconf -f packmol.pdb -o packmol.gro
rm packmol.pdb packmol.inp

echo 'Create the index file ...'
make_ndx -f packmol.gro -o index_bulk.ndx << EOF
keep 0
a $cation_name
name 1 Cation
a $anion_name
name 2 Anion
q
EOF

echo 'Start converting the mdp input files ...'
sed 's/SED_temperature_name_SED/'$temperature_name'/g' 0_Bulk_STEEP_emptyTemp.mdp > 0_STEEP.mdp
sed -i 's/SED_energygrps_SED/Cation Anion Impurity/g' 0_STEEP.mdp
sed 's/SED_temperature_name_SED/'$temperature_name'/g' 1_Bulk_NPT_highpressure_emptyTemp.mdp > 1_NPT_highpressure.mdp
sed -i 's/SED_energygrps_SED/Cation Anion Impurity/g' 1_NPT_highpressure.mdp
sed 's/SED_temperature_name_SED/'$temperature_name'/g' 2_Bulk_NPT_emptyTemp.mdp > 2_NPT.mdp
sed -i 's/SED_energygrps_SED/Cation Anion Impurity/g' 2_NPT.mdp

echo 'Start converting the topology files ...'
sed 's+SED_dir_systempreparation_SED+'$dir_systempreparation'+g' topol_local_bulk.top > topol_local.top
sed -i 's+SED_dir_gromacs_SED+'$dir_gromacs'+g' topol_local.top
sed -i 's/SED_cation_name_SED/'$cation_name'/g' topol_local.top
sed -i 's/SED_cation_num_SED/'$cation_num'/g' topol_local.top
sed -i 's/SED_anion_name_SED/'$anion_name'/g' topol_local.top
sed -i 's/SED_anion_num_SED/'$anion_num'/g' topol_local.top
sed -i 's/SED_impurity_name_SED/'$impurity_name'/g' topol_local.top
sed -i 's/SED_impurity_num_SED/'$impurity_num'/g' topol_local.top

echo 'Move all files to the experiment directory ...'
mv packmol.gro index_bulk.ndx 0_STEEP.mdp 1_NPT_highpressure.mdp 2_NPT.mdp topol_local.top $dir_experiments/$fullpath

echo 'Compile (grompp) the setup files and run energy minimization ...'
cd $dir_experiments/$fullpath
grompp -f 0_STEEP.mdp -c packmol.gro -p topol_local.top -n index_bulk.ndx -o STEEP
rm mdout.mdp
mdrun -deffnm STEEP -nt 1
grompp -f 1_NPT_highpressure.mdp -c STEEP.gro -p topol_local.top -n index_bulk.ndx -o NPT_highpressure
rm mdout.mdp
mdrun -deffnm NPT_highpressure -nt 1 -v 
# Takes to long, moved to task_running-bulk-impurity.sh
#grompp -f 2_NPT.mdp -c NPT_highpressure.gro -p topol_local.top -n index_bulk.ndx -o NPT
#rm mdout.mdp
#mdrun -deffnm NPT -nt 1 -v
