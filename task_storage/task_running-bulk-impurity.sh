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

combination_name=$(echo ${current_combination[0]} | awk '{print $1"-"$2"-"$3}')
cation_num=$(echo ${current_combination[0]} | awk '{print $1}')
anion_num=$(echo ${current_combination[0]} | awk '{print $2}')
impurity_num=$(echo ${current_combination[0]} | awk '{print $3}')

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
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$combination_name/$temperature_name/$version_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

echo $dir_experiments
mkdir -p $dir_experiments/$fullpath2simulate

cd $dir_experiments/$fullpath

echo 'Start converting the topology files ...'
sed 's+SED_dir_systempreparation_SED+'$dir_systempreparation'+g' $dir_systempreparation/topol_local_bulk.top > topol_local.top
sed -i 's+SED_dir_gromacs_SED+'$dir_gromacs'+g' topol_local.top
sed -i 's/SED_cation_name_SED/'$cation_name'/g' topol_local.top
sed -i 's/SED_cation_num_SED/'$cation_num'/g' topol_local.top
sed -i 's/SED_anion_name_SED/'$anion_name'/g' topol_local.top
sed -i 's/SED_anion_num_SED/'$anion_num'/g' topol_local.top
sed -i 's/SED_impurity_name_SED/'$impurity_name'/g' topol_local.top
sed -i 's/SED_impurity_num_SED/'$impurity_num'/g' topol_local.top


sed 's/SED_temperature_name_SED/'$temperature_name'/g' $dir_systempreparation/2_Bulk_NPT_emptyTemp.mdp > 2_NPT.mdp
sed -i 's/SED_energygrps_SED/Cation Anion Impurity/g' 2_NPT.mdp

runningnumber=$((totalnumberofsetups - 1))

# Compile (grompp) the setup files and run energy minimization ...
grompp -f 2_NPT.mdp -c NPT_highpressure.gro -p topol_local.top -n index_bulk.ndx -o NPT
rm mdout.mdp

# copy tpr files to run them somewhere as multijobs
cp NPT.tpr $dir_experiments/$fullpath2simulate/NPT$runningnumber.tpr

if [ $totalnumberofsetups -eq 1 ]; then
rm $dir_experiments/$fullpath2simulate/copyback.txt
fi

pathtocopyback=$(pwd)
echo "cp NPT$runningnumber.tpr $pathtocopyback/NPT.tpr" >> $dir_experiments/$fullpath2simulate/copyback.txt

#read -p "Press enter to continue..."
