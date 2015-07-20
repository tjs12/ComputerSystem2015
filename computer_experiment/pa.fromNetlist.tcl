
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name computer_experiment -dir "E:/classes/grade_3_vacation/csproject2014/computer_experiment/planAhead_run_4" -part xc6slx100fgg676-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "E:/classes/grade_3_vacation/csproject2014/computer_experiment/cpu.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {E:/classes/grade_3_vacation/csproject2014/computer_experiment} {ipcore_dir} }
add_files [list {ipcore_dir/multiplier.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "cpu.ucf" [current_fileset -constrset]
add_files [list {cpu.ucf}] -fileset [get_property constrset [current_run]]
link_design
