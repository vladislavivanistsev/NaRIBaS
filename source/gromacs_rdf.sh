#!/bin/bash

# Usage: ./gromacs_rdf.sh ensemble specie1 specie2 begin end

g_rdf -f $1.xtc -s $1.tpr -n index_bulk.ndx -cn -b $4 -e $5 << EOF
$2
$3
EOF
