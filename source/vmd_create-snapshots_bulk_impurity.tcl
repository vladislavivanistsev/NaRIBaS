# VMD for LINUXAMD64, version 1.8.7beta5 (June 1, 2009)
# Log file '/media/Elements_/Experiments/Bulk/LCr/SAr/SCr/900-1000-100/450/a/0/vmd-log.log', created by user kirchner

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

mol modselect 0 0 name LCr
mol modcolor 0 0 ColorID 0
mol modcolor 0 0 ColorID 1
mol modstyle 0 0 VDW 2.000000 8.000000
mol color ColorID 1
mol representation VDW 2.000000 8.000000
mol selection name LCr
mol material Opaque
mol addrep 0
mol modcolor 1 0 ColorID 0
mol modselect 1 0 name SAr
mol modstyle 1 0 VDW 1.000000 8.000000
mol color ColorID 0
mol representation VDW 1.000000 8.000000
mol selection name SAr
mol material Opaque
mol addrep 0
mol modselect 2 0 name SCr
mol modcolor 2 0 ColorID 7
mol modstyle 2 0 VDW 3.000000 8.000000

render snapshot snap1.tga display %s

rotate x by 30.000000
rotate y by 30.000000
render snapshot snap2.tga display %s

mol modstyle 2 0 VDW 2.000000 8.000000
mol modstyle 1 0 VDW 2.000000 8.000000
mol modstyle 0 0 VDW 4.000000 8.000000
render snapshot snap3.tga display %s

exit

# VMD for LINUXAMD64, version 1.8.7beta5 (June 1, 2009)
# end of log file.
