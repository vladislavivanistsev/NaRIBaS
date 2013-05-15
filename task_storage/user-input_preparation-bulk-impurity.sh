#!/bin/bash

# User input is specified here in form of input lists stored in a specific folder.
# Don't change the variable names, only add/rename lists given within the brackets

inputlists_folder=inputlists_preparation-bulk-impurity

inputlists=(particle.list cation.list anion.list impurity.list combination.list replica.list temperature.list version.list boxsize.list)

#sysprepfiles=(packmol_bulk.inp topol_local_bulk.top 0_Bulk_STEEP.mdp 1_Bulk_NPT_highpressure.mdp 2_Bulk_NPT.mdp)

####### Add here the file that contains the task list
tasks=task_preparation-bulk-impurity.sh

####### Add here where to find the topology and the where to put the experimental results
currentdir=$(pwd)

dir_systempreparation=$currentdir/sysprep
dir_experiments=/media/Elements_/Experiments
dir_analysis=/media/Elements_/Analysis

dir_packmol=~/Programs/packmol
#dir_packmol=$HOME/Programs/packmol
dir_gromacs=/opt/local/gromacs-4.5.5/share/gromacs
#dir_gromacs=/usr/local/gromacs/share/gromacs
#dir_matlab=


