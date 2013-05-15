#!/bin/bash

# Usage: ./gromacs_energy.sh ensemble begin end binwidth

#rm tmp.out

g_energy -f $1.edr -s $1.tpr << EOF
Total-Energy
0
EOF

g_analyze -f energy.xvg -b $2 -e $3 -dist -bw $4 > tmp

cat tmp | grep SS1 >> energy.txt
rm tmp
