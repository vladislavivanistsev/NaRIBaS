#!/bin/bash

# Usage: ./gromacs_density_profile.sh ensemble specie begin end numberofslices

g_density -dens number -f $1.xtc -s $1.tpr -n index_slab.ndx -b $3 -e $4 -sl $5 << EOF
$2
EOF
