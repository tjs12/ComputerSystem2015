
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name PS2KB -dir "D:/PS2KB/planAhead_run_2" -part xc6slx100fgg676-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "PS2KB.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {Listener.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {Divider.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {Decoder.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {PS2KB.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top PS2KB $srcset
add_files [list {PS2KB.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx100fgg676-3
