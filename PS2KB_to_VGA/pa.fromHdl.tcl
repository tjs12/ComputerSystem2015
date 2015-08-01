
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name PS2KB_to_VGA -dir "D:/ComputerSystem2015/PS2KB_to_VGA/planAhead_run_2" -part xc6slx100fgg676-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "PS2KB_to_VGA.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {VGA/VGA_ROM_Font.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {VGA/VGA_RAM_Text.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {VGA/VGA_Render.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {VGA/VGA_Divider.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {VGA/VGA_Decoder.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {VGA/VGA_Controller.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {PS2KB/PS2KB_Listener.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {PS2KB/PS2KB_Divider.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {PS2KB/PS2KB_Decoder.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {VGA/VGA.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {PS2KB/PS2KB.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {PS2KB_to_VGA.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top PS2KB_to_VGA $srcset
add_files [list {PS2KB_to_VGA.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx100fgg676-3
