# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\C27Mohamed.Metwally\vitis_2024_workspace\final_doodle_jump\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\C27Mohamed.Metwally\vitis_2024_workspace\final_doodle_jump\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

catch {platform remove final_doodle_jump}
platform write
