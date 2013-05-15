mol addrep 0
display resetview
mol new {SED_grofile_SED} type {gro} first 0 last -1 step 1 waitfor 1

#mol addfile {/media/Elements_/Experiments/Bulk/LCr/SAr/SCr/900-1000-100/450/a/0/NPT.xtc} type {xtc} first 0 last -1 step 1 waitfor 1 0

pbc box

display projection Orthographic
color Display Background white
axes location Off

menu graphics off
menu graphics on

set min_pos_start SED_min_pos_start_SED
set min_pos_end SED_min_pos_end_SED

mol modselect 0 0 "name LCr and z>$min_pos_start and z<$min_pos_end"
mol modcolor 0 0 ColorID 0
mol modcolor 0 0 ColorID 1
mol modstyle 0 0 VDW 2.000000 8.000000
mol color ColorID 1
mol representation VDW 2.000000 8.000000
mol selection name LCr
mol material Opaque
mol addrep 0
mol modcolor 1 0 ColorID 0
mol modselect 1 0 "name SAr and z>$min_pos_start and z<$min_pos_end"
mol modstyle 1 0 VDW 1.000000 8.000000
mol color ColorID 0
mol representation VDW 1.000000 8.000000
mol selection name SAr

render snapshot SED_grofile_SED1.tga display %s

rotate x by 30.000000
rotate y by 30.000000

render snapshot SED_grofile_SED2.tga display %s

mol modstyle 0 0 VDW 4.000000 8.000000
mol modstyle 1 0 VDW 2.000000 8.000000

render snapshot SED_grofile_SED3.tga display %s

exit
