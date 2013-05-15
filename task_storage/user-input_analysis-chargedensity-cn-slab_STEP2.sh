#!/bin/bash

# User input is specified here in form of input lists stored in a specific folder.
# Don't change the variable names, only add/rename lists given within the brackets

inputlists_folder=inputlists_slab_Sr_LCr_LAr_no_preparation

# Delete replica.list as replicas will be combined, the same for numberdens.list
inputlists=(particle.list cation.list anion.list impurity.list temperature.list version.list surfacecharge.list duration_NVT.list)

# Lists that are also of importance:
# particledensity_LCr_SAr.list
# numberofionpairs.list 
# numberdens.list
# electrode.list


####### Add here the file that contains the task list
tasks=task_analysis-chargedensity-cn-slab_STEP2.sh

####### Add here where to find the topology and the where to put the experimental results
currentdir=$(pwd)

dir_systempreparation=$currentdir/sysprep
dir_experiments=/media/Elements_/Experiments
dir_analysis=/media/Elements_/Analysis

dir_packmol=~/Programs/packmol
#dir_packmol=$HOME/Programs/packmol
dir_gromacs=/opt/local/gromacs-4.5.5/share/gromacs
#dir_gromacs=/usr/local/gromacs/share/gromacs
matlabdir=/opt/local/bin