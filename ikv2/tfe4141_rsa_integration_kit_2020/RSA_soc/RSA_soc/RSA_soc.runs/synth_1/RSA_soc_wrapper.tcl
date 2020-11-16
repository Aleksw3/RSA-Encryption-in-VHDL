# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_msg_config -id {Common 17-41} -limit 10000000
create_project -in_memory -part xc7z020clg400-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/RSA_soc/RSA_soc.cache/wt [current_project]
set_property parent.project_path /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/RSA_soc/RSA_soc.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_FIFO XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part www.digilentinc.com:pynq-z1:part0:1.0 [current_project]
set_property ip_repo_paths /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_accelerator/IP [current_project]
update_ip_catalog
set_property ip_output_repo /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/RSA_soc/RSA_soc.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -vhdl2008 -library xil_defaultlib /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/source/rsa_soc.vhd
add_files /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/rsa_soc.bd
set_property used_in_implementation false [get_files -all /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/ip/rsa_soc_rsa_acc_0/src/PYNQ-Z1_C.xdc]
set_property used_in_implementation false [get_files -all /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/ip/rsa_soc_rsa_dma_0/rsa_soc_rsa_dma_0.xdc]
set_property used_in_implementation false [get_files -all /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/ip/rsa_soc_rsa_dma_0/rsa_soc_rsa_dma_0_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/ip/rsa_soc_rsa_dma_0/rsa_soc_rsa_dma_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/ip/rsa_soc_processing_system7_0_0/rsa_soc_processing_system7_0_0.xdc]
set_property used_in_implementation false [get_files -all /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/ip/rsa_soc_rst_ps7_0_100M_0/rsa_soc_rst_ps7_0_100M_0_board.xdc]
set_property used_in_implementation false [get_files -all /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/ip/rsa_soc_rst_ps7_0_100M_0/rsa_soc_rst_ps7_0_100M_0.xdc]
set_property used_in_implementation false [get_files -all /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/ip/rsa_soc_rst_ps7_0_100M_0/rsa_soc_rst_ps7_0_100M_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/ip/rsa_soc_axi_smc_0/ooc.xdc]
set_property used_in_implementation false [get_files -all /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/ip/rsa_soc_xbar_0/rsa_soc_xbar_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/ip/rsa_soc_auto_pc_0/rsa_soc_auto_pc_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/rsa_soc_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/Master_constraints/PYNQ-Z1_C.xdc
set_property used_in_implementation false [get_files /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/Master_constraints/PYNQ-Z1_C.xdc]

read_xdc /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/rsa_soc_ooc.xdc
set_property used_in_implementation false [get_files /home/aleksw/Documents/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/rsa_soc_ooc.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top RSA_soc_wrapper -part xc7z020clg400-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef RSA_soc_wrapper.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file RSA_soc_wrapper_utilization_synth.rpt -pb RSA_soc_wrapper_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
