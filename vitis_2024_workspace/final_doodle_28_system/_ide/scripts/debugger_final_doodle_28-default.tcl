# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: C:\Users\C27Mohamed.Metwally\vitis_2024_workspace\final_doodle_28_system\_ide\scripts\debugger_final_doodle_28-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source C:\Users\C27Mohamed.Metwally\vitis_2024_workspace\final_doodle_28_system\_ide\scripts\debugger_final_doodle_28-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Nexys Video 210276689238B" && level==0 && jtag_device_ctx=="jsn-Nexys Video-210276689238B-13636093-0"}
fpga -file C:/Users/C27Mohamed.Metwally/vitis_2024_workspace/final_doodle_28/_ide/bitstream/final_doodle_wrapper.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw C:/Users/C27Mohamed.Metwally/vitis_2024_workspace/final_doodle_wrapper/export/final_doodle_wrapper/hw/final_doodle_wrapper.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow C:/Users/C27Mohamed.Metwally/vitis_2024_workspace/final_doodle_28/Debug/final_doodle_28.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con
