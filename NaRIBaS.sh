#!/bin/bash

if [ "$1" == 'gui' ]; then

# Not working yet - still in test mode
./_gui.sh

else

#+++ Bulk simulations, preparation and analysis +++

#+++ Neat Ionic liquid +++
#+ Prepare simulations of bulk coarse grained ionic liquid
./_main.sh user-input_preparation-bulk.sh

# Add here the input file TEST_user-input_*.sh
#read -p "Press enter to continue..." # allows to generate a break (e.g. to check the output of a former step) and proceed after enter is pressed).

# NOTE: Tasks marked with a "#+" in the descriptive title are updated and stored in task_storage_public/ .
# All other tasks are stored in task_storage/ and should be checked carefully before usage. 
# Error messages due to not found files might occur. These files are stored in source/old_functions_seeREADMEinside/ .


#+++ Bulk simulations, preparation and analysis +++

#+++ Neat Ionic liquid +++
#+ Calculate the rdf and cn using a gromacs tool
#./_main.sh user-input_analysis-rdf-bulk_STEP1.sh

#+ Plot all replicas in one figure, calculate the mean rdf and cn from the replicas
#./_main.sh user-input_analysis-rdf-bulk_STEP2.sh

#+ Plot the mean rdf for all temperatures in one figure
#./_main.sh user-input_analysis-rdf-bulk_STEP3.sh

#+ Calculate energy properties using a gromacs tool
#./_main.sh user-input_analysis-energy-bulk_STEP1.sh

#+ Plot one figure per physical proeprty, including all replicas and all temperatures
#./_main.sh user-input_analysis-energy-bulk_STEP2.sh


#+++ With impurities (see Demo for description, including snapshots and energy analysis) +++
#./_main.sh user-input_preparation-bulk-impurity.sh
#./_main.sh user-input_running-bulk-impurity.sh
#./_main.sh user-input_analysis-rdf-bulk-impurity_STEP1.sh
#./_main.sh user-input_analysis-rdf-bulk-impurity_STEP2.sh
#./_main.sh user-input_analysis-rdf-bulk-impurity_STEP3.sh
#./_main.sh user-input_analysis-vmdsnapshots-bulk-impurity.sh
#./_main.sh user-input_analysis-energy-bulk-impurity_STEP1.sh


#+++ Surface tension +++

# Prepare simulations for calculating the surface tension
#./_main.sh user-input_preparation-surfacetension-bulk_STEP1.sh

# Analyse simulations for calculating the surface tension (in preparation)
#./_main.sh user-input_analysis-surfacetension-bulk_STEP1.sh


#+++ Slab geometry with electrodes +++

#+++ Preparation +++
# Prepare slab simulations (neutral walls - equilibration)
#./_main.sh user-input_preparation-slab_STEP1.sh

# Prepare slab simulations (charged walls - equilibration)
#./_main.sh user-input_preparation-slab_STEP2.sh

# Prepare slab simulations (charged walls - final simulation)
#./_main.sh user-input_preparation-slab_STEP3.sh

# Prepare slab simulations with temperature coupling only for the walls
#./_main.sh user-input_preparation-slab-newversion_STEP3.sh

# Prepare slab simulations (T-REMD with T=500K being the reference.gro)
#./_main.sh user-input_preparation-TREMD-slab_STEP1.sh

# Prepare slab simulations (sigma-REMD with old simulations being the reference.gro)
#./_main.sh user-input_preparation-sigmaREMD-slab_STEP1.sh


#+++ Analysis +++

#+++ Number density +++

# Calculate the number density in slab using a gromacs tool
#./_main.sh user-input_analysis-numberdensity-slab_STEP1.sh

# Plot all replicas in one figure (optional)
#./_main.sh user-input_analysis-numberdensity-slab_STEP2.sh

# Plot different time frames in one figure (optional)
#./_main.sh user-input_analysis-numberdensity-slab_STEP2b.sh

# Calculate the mean from the replicas
#./_main.sh user-input_analysis-numberdensity-slab_STEP3.sh

# Collect and plot the middle-of-the-slab number density
#./_main.sh user-input_analysis-numberdensity-slab_STEP4.sh

# Plot the middle-of-the-slab number density for all temperatures
#./_main.sh user-input_analysis-numberdensity-slab_STEP5.sh

# (Time evolution) Calculate the number density in slab using a gromacs toolfor different time steps
#./_main.sh user-input_analysis-numberdensity-timeevolution-slab_STEP1.sh


#+++ Process number density to cumulative number density, charge density and various plotting combinations +++

# Calculate the charge density and the cumulative number densities
#./_main.sh user-input_analysis-chargedensity-cn-slab_STEP1.sh

# Plot number densities for all ion-electrode combinations
#./_main.sh user-input_analysis-chargedensity-cn-slab_STEP2.sh

# Plot charge densities for all electrode combinations
#./_main.sh user-input_analysis-chargedensity-cn-slab_STEP3.sh

# Plot number densities for all surface charges
#./_main.sh user-input_analysis-chargedensity-cn-slab_STEP4.sh

# Plot cumulative number densities for all surface charges
#./_main.sh user-input_analysis-chargedensity-cn-slab_STEP5.sh

# Plot charge densities for all surface charges
#./_main.sh user-input_analysis-chargedensity-cn-slab_STEP6.sh

# Plot cumulative charge densities for all surface charges
#./_main.sh user-input_analysis-chargedensity-cn-slab_STEP7.sh

# Plot number densities for specific surface charges but all temperatures
#./_main.sh user-input_analysis-chargedensity-cn-slab_STEP8.sh

# Plot charge densities for specific surface charges but all temperatures
#./_main.sh user-input_analysis-chargedensity-cn-slab_STEP9.sh

# Calculate the peak height of the 1. peak of the cumulative number difference
#./_main.sh user-input_analysis-cndifferencepeakheight-slab_STEP1.sh

# Plot the peak height of the 1. peak of the cumulative number difference
#./_main.sh user-input_analysis-cndifferencepeakheight-slab_STEP2.sh


#+++ Potential drop and capacitance +++

# Calculate the potential drop based on the charge densities and run Uvssigma2capacitance.m
#./_main.sh user-input_analysis-potentialdrop-slab_STEP1.sh

# Plot the potential drop, the differential capacitance and the integral capacitance
#./_main.sh user-input_analysis-potentialdrop-slab_STEP2.sh

# Calculate the potential drop based on the charge densities and run Uvssigma2capacitance_fitexponent.m
#./_main.sh user-input_analysis-potentialdrop-error-slab_STEP1.sh

# Plot the potential drop, the differential capacitance and the integral capacitance with different fit exponents
#./_main.sh user-input_analysis-potentialdrop-error-slab_STEP2.sh

# Calculate the potential drop, the differential capacitance and the integral capacitance with an estimated fit exponent
#./_main.sh user-input_analysis-potentialdrop-error-slab_STEP3.sh

# Plot the potential drop, the differential capacitance with error bars
#./_main.sh user-input_analysis-potentialdrop-error-slab_STEP4.sh


#+++ Potential drop and capacitance +++

# Calculate the number of ions within a given cutoff from the electrode
#./_main.sh user-input_analysis-ionnumberatcutoff-slab_STEP1.sh

# Plot the number of ions within a given cutoff from the electrode
#./_main.sh user-input_analysis-ionnumberatcutoff-slab_STEP2.sh

# Plot the number of ions within a given cutoff from the electrode, but combine anode and cathode in one figure
#./_main.sh user-input_analysis-ionnumberatcutoff-slab_STEP3.sh

# Calculate the number of ions within a specific layer determined by the minima of the number density profile
#./_main.sh user-input_analysis-ionnumberinlayer-slab_STEP1.sh

# Plot several properties concerning the number of ions within a specific layer determined by the minima of the number density profile
#./_main.sh user-input_analysis-ionnumberinlayer-slab_STEP2.sh

# Plot the number of ions within a specific layer, but combine anode and cathode in one figure
#./_main.sh user-input_analysis-ionnumberinlayer-slab_STEP3.sh

# Plot the number of ions within a specific layer normalized by the electrode charge, with inset
#./_main.sh user-input_analysis-ionnumberinlayer-slab_STEP4.sh

# Plot the number of ions within a specific layer over the number of electrons (instead voltage), larger view
#./_main.sh user-input_analysis-ionnumberinlayer-slab_STEP5.sh


#+++ Screenshots +++

# Make screenshots showing the number of ions within a specific layer determined by the minima of the number density profile
#./_main.sh user-input_analysis-layerscreenshots-slab_STEP1.sh


#+++ Radial distribution functions in the middle of the slab between the electrodes +++

# Calculate the RDFs in the middle of the slab
#./_main.sh user-input_analysis-middleoftheslabrdf-slab_STEP1.sh

# Plot the RDFs of the middle of the slab - all replicas in one figure to check them
#./_main.sh user-input_analysis-middleoftheslabrdf-slab_STEP2.sh

# Plot the RDFs of the middle of the slab - comparing temperatures
#./_main.sh user-input_analysis-middleoftheslabrdf-slab_STEP3.sh

# Plot the RDFs of the middle of the slab - comparing surface charges
#./_main.sh user-input_analysis-middleoftheslabrdf-slab_STEP4.sh


#+++ Energy evolution +++

# Calculate the total energy and resulting distribution
#./_main.sh user-input_analysis-energydistribution-slab_STEP1.sh

# Plot the total energy and resulting distribution independent for all simulations
#./_main.sh user-input_analysis-energydistribution-slab_STEP2.sh

# Plot the energy distribution for all replicas (and calculate mean? no - to difficult right now, proceed with one figure per replica. maybe take only the last 5-10 ns?)
#./_main.sh user-input_analysis-energydistribution-slab_STEP3.sh

# Plot the energy distribution for temperatures
#./_main.sh user-input_analysis-energydistribution-slab_STEP4.sh

# Plot the energy distribution for surface charges
#./_main.sh user-input_analysis-energydistribution-slab_STEP5.sh


fi
