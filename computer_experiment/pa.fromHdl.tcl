
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name computer_experiment -dir "E:/classes/grade_3_vacation/csproject2014/computer_experiment/planAhead_run_2" -part xc6slx100fgg676-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "cpu.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {ipcore_dir/multiplier.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {registers.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {multiplication.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {alu.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {cpu.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top cpu $srcset
add_files [list {cpu.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/multiplier.ncf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx100fgg676-3
