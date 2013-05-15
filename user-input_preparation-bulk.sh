#!/bin/bash

# User input is specified here in form of input lists stored in a specific folder.
# Don't change the variable names, only add/rename lists given within the brackets

inputlists_folder=inputlists_preparation-bulk

inputlists=(particle.list cation.list anion.list boxsize.list temperature.list version.list replica.list)

#sysprepfiles=(packmol_bulk.inp topol_local_bulk.top 0_Bulk_STEEP.mdp 1_Bulk_NPT_highpressure.mdp 2_Bulk_NPT.mdp)

####### Add here the file that contains the task list
tasks=task_preparation-bulk.sh

####### Add here where to find the topology and the where to put the experimental results
currentdir=$(pwd)

dir_systempreparation=$currentdir/sysprep
dir_experiments=../Experiments
dir_analysis=../Analysis

dir_packmol=/home/vladislav/Ubuntu One/scripts/packmol
dir_gromacs=/opt/gromacs-4.6/share/gromacs

