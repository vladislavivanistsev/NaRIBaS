#!/bin/bash

# Access folder that contains the simulation files
cd /media/Elements_/Experiments/Sr+LCr+LAr+no+f

sed 's/.tpr/.log/g' copyback.txt > copyback.sh
bash copyback.sh

sed 's/.tpr/.gro/g' copyback.txt > copyback.sh
bash copyback.sh

sed 's/.tpr/.xtc/g' copyback.txt > copyback.sh
bash copyback.sh

sed 's/.tpr/.trr/g' copyback.txt > copyback.sh
bash copyback.sh

sed 's/.tpr/.cpt/g' copyback.txt > copyback.sh
bash copyback.sh

sed 's/.tpr/.edr/g' copyback.txt > copyback.sh
bash copyback.sh
