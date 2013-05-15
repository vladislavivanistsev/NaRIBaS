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

duration_name=$(echo ${current_duration_NPT[0]} | awk '{print $1"-"$2}')
duration_begin=$(echo ${current_duration_NPT[0]} | awk '{print $1}')
duration_end=$(echo ${current_duration_NPT[0]} | awk '{print $2}')

numberofionpairs_name=$(echo ${current_numberofionpairs[0]} | awk '{print $1}')

# Define path for storing configurations / simulation data
fullpath=$particle_name/$cation_name/$anion_name/$impurity_name/$temperature_name/$version_name/$replica_name
fullpath2simulate=$particle_name'+'$cation_name'+'$anion_name'+'$impurity_name'+'$version_name

mkdir -p $dir_analysis/$fullpath

cd $dir_experiments/$fullpath

mkdir -p $dir_analysis/$fullpath
mkdir -p $dir_analysis/$fullpath2simulate/energy/
#date >> $dir_analysis/$fullpath2simulate/rdf/output.out

echo "Setup $totalnumberofsetups"
pwd
echo "execute $currentdir/source/gromacs_energy.sh NPT $duration_begin $duration_end $numberofionpairs_name"
xterm -e "$currentdir/source/gromacs_energy.sh NPT $duration_begin $duration_end $numberofionpairs_name > log.file"
if grep -F "Error" log.file; then
	read -p "Error detected. Press enter to continue or Ctrl+C to abort..."
fi
rm log.file

mv energy.xvg $dir_analysis/$fullpath/energy.xvg 
mv energy.txt $dir_analysis/$fullpath/energy.txt 

cat $dir_analysis/$fullpath/energy.xvg  | grep -v '@' | grep -v '#' > $dir_analysis/$fullpath/energy.dat

cd $dir_analysis/$fullpath/

tail -n +2 energy.txt | grep Volume > tmp
sed -i 's/Volume                                   =/'$temperature_name' /g' tmp
sed -i 's+m^3/mol++g' tmp
cat tmp >> $dir_analysis/$fullpath2simulate/energy/volume.dat
rm tmp

cat energy.txt | grep Expansion > tmp
sed -i 's/Coefficient of Thermal Expansion Alpha_P =/'$temperature_name' /g' tmp
sed -i 's+(1/K)++g' tmp
cat tmp >> $dir_analysis/$fullpath2simulate/energy/thermalexpansion.dat
rm tmp

cat energy.txt | grep Compressibility > tmp
sed -i 's/Isothermal Compressibility Kappa         =/'$temperature_name' /g' tmp
sed -i 's+(J/m^3)++g' tmp
cat tmp >> $dir_analysis/$fullpath2simulate/energy/compressibility.dat
rm tmp

cat energy.txt | grep modulus > tmp
sed -i 's/Adiabatic bulk modulus                   =/'$temperature_name' /g' tmp
sed -i 's+(m^3/J)++g' tmp
cat tmp >> $dir_analysis/$fullpath2simulate/energy/adiabaticbulkmodulus.dat
rm tmp
