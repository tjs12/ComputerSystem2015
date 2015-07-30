
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name VGA -dir "D:/VGA/planAhead_run_2" -part xc6slx100fgg676-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "VGA.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {ROM_Font.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {Render.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {Divider.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {Decoder.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {Controller.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {VGA.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top VGA $srcset
add_files [list {VGA.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx100fgg676-3
