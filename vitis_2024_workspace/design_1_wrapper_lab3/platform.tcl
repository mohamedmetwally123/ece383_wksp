# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\C27Mohamed.Metwally\vitis_2024_workspace\design_1_wrapper_lab3\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\C27Mohamed.Metwally\vitis_2024_workspace\design_1_wrapper_lab3\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {design_1_wrapper_lab3}\
-hw {C:\Users\C27Mohamed.Metwally\ece383_wksp\ublaze3\design_1_wrapper_lab3.xsa}\
-out {C:/Users/C27Mohamed.Metwally/vitis_2024_workspace}

platform write
domain create -name {standalone_microblaze_0} -display-name {standalone_microblaze_0} -os {standalone} -proc {microblaze_0} -runtime {cpp} -arch {32-bit} -support-app {hello_world}
platform generate -domains 
platform active {design_1_wrapper_lab3}
platform generate -quick
platform generate
platform generate
