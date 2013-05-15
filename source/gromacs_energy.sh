#!/bin/bash

# Usage: ./gromacs_energy.sh ensemble begin end numberofmolecules

rm tmp.out

if [[ "$1" == "NPT" ]]; then

# Heat capacity Cp (NPT sims): Enthalpy, Temp
# Absolute heat capacity might be divided by the number of ions and the mass to obtain the specific heat capacity

# Thermal expansion coeff. (NPT): Enthalpy, Vol, Temp
# Isothermal compressibility: Vol, Temp
# Adiabatic bulk modulus: Vol, Temp

g_energy -f $1.edr -s $1.tpr -b $2 -e $3 -nmol $4 > tmp << EOF
Enthalpy
Volume
Temperature
0
EOF

cat tmp | grep Volume >> energy.txt
cat tmp | grep Expansion >> energy.txt
cat tmp | grep Compressibility >> energy.txt
cat tmp | grep modulus >> energy.txt
#cat tmp | grep capacity >> energy.txt

rm tmp

elif [[ "$1" == "NVT" ]]; then

# Heat capacity Cv (NVT sims): Etot, Temp
# Isothermal compressibility: Vol, Temp
# Adiabatic bulk modulus: Vol, Temp

g_energy -f $1.edr -s $1.tpr -b $2 -e $3 -nmol $4 > tmp << EOF
Etot
Volume
Temperature
0
EOF

cat tmp | grep Volume >> energy.txt
cat tmp | grep Compressibility >> energy.txt
cat tmp | grep modulus >> energy.txt
#cat tmp | grep capacity >> energy.txt

rm tmp


elif [[ "$1" == "SurfTen" ]]; then

# Heat capacity Cv (NVT sims): Etot, Temp
# Isothermal compressibility: Vol, Temp
# Adiabatic bulk modulus: Vol, Temp

g_energy -f NVT.edr -s NVT.tpr -b $2 -e $3 -nmol $4 > tmp << EOF
#Surf
0
EOF

cat tmp | grep SurfTen >> energy.txt

rm tmp

fi
