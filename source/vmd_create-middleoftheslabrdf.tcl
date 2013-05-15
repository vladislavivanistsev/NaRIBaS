proc set_unitcell {a b c {molid top} {alpha 90.0} {beta 90.0} {gamma 90.0}} {
if {![string compare $molid top]} {
set molid [molinfo top]
}
set n [molinfo $molid get numframes]
for {set i 0} {$i < $n} {incr i} {
molinfo $molid set frame $i
molinfo $molid set {a b c alpha beta gamma} \
[list $a $b $c $alpha $beta $gamma]
}
}

set gro NVT_ions.gro
set xtc NVT.xtc
mol load gro $gro xtc $xtc

# set the unit cell side length in all frames (Does not work, somehow the pbc command is not recognized when calling this script from a bash terminal. However it does work for Tom... )
#pbc set {110.0 110.0 228.0} -all 
set_unitcell SED_xbox_SED SED_ybox_SED SED_zbox_SED

set outfile1 [open measuregofr_Cation-Cation.dat w]
set sel1 [atomselect top "name LCr  and z>80 and x>40 and y>40 and z<160 and x<70 and y<70"]
set sel2 [atomselect top "name LCr"]    
set gr0 [measure gofr $sel1 $sel2 delta 0.1 rmax 40.0 usepbc 1 selupdate 1 first 2000 last -1 step 1]
set r [lindex $gr0 0]
set gr [lindex $gr0 1]
set igr [lindex $gr0 2]
set isto [lindex $gr0 3]
foreach j $r k $gr l $igr m $isto {
  puts $outfile1 [format "%.4f\t%.4f\t%.4f\t%.4f" $j $k $l $m]
}
close $outfile1


set outfile2 [open measuregofr_Anion-Anion.dat w]
set sel1 [atomselect top "name SAr  and z>80 and x>40 and y>40 and z<160 and x<70 and y<70"]
set sel2 [atomselect top "name SAr"]    
set gr0 [measure gofr $sel1 $sel2 delta 0.1 rmax 40.0 usepbc 1 selupdate 1 first 2000 last -1 step 1]
set r [lindex $gr0 0]
set gr [lindex $gr0 1]
set igr [lindex $gr0 2]
set isto [lindex $gr0 3]
foreach j $r k $gr l $igr m $isto {
  puts $outfile2 [format "%.4f\t%.4f\t%.4f\t%.4f" $j $k $l $m]
}
close $outfile2


set outfile3 [open measuregofr_Cation-Anion.dat w]
set sel1 [atomselect top "name LCr  and z>80 and x>40 and y>40 and z<160 and x<70 and y<70"]
set sel2 [atomselect top "name SAr"]    
set gr0 [measure gofr $sel1 $sel2 delta 0.1 rmax 40.0 usepbc 1 selupdate 1 first 2000 last -1 step 1]
set r [lindex $gr0 0]
set gr [lindex $gr0 1]
set igr [lindex $gr0 2]
set isto [lindex $gr0 3]
foreach j $r k $gr l $igr m $isto {
  puts $outfile3 [format "%.4f\t%.4f\t%.4f\t%.4f" $j $k $l $m]
}
close $outfile3



exit 
